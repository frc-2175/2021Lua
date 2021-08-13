#include <assert.h>

#include "./md.h"
#include "./md.c"

#define NodeLine(node) MD_CodeLocFromNode(node).line
#define MAX_ARGS 16

void printIndent(int level) {
    for (int i = 0; i < level; i++) {
        printf("| ");
    }
}

void DumpNodeR(MD_Node* node, const char* marker, int level) {
    printIndent(level);
    printf("%s %.*s\n", marker, MD_StringExpand(node->string));
    if (!MD_NodeIsNil(node->first_child) || !MD_NodeIsNil(node->first_tag)) {
        printIndent(level);
        printf("|\\\n");
    }

    for (MD_EachNode(n, node->first_tag)) {
        DumpNodeR(n, "@", level + 1);
    }
    for (MD_EachNode(n, node->first_child)) {
        DumpNodeR(n, "*", level + 1);
    }
}

void DumpNode(MD_Node* node) {
    DumpNodeR(node, "*", 0);
}

MD_String8 ParseType(MD_Node* start, MD_Node* end) {
    MD_String8List pieces = {0};
    for (MD_Node* it = start; !MD_NodeIsNil(it) && it != end; it = it->next) {
        MD_PushStringToList(&pieces, it->string);
    }
    return MD_JoinStringList(pieces, MD_S8Lit(""));
}

typedef struct {
    MD_String8 ReturnType;
    MD_String8 Name;
    MD_String8 CustomBody;
    
    int NumArgs;
    MD_String8 ArgTypes[MAX_ARGS];
    MD_String8 ArgNames[MAX_ARGS];
    int ArgDerefs[MAX_ARGS];
    MD_String8 ArgCasts[MAX_ARGS];

    MD_Node* After;

    MD_String8 Error;
} ParseFuncResult;

ParseFuncResult ParseFunc(MD_Node* n) {
    ParseFuncResult res = {0};

    MD_Node* argsNode = NULL;
    MD_Node* terminator = NULL;

    for (MD_EachNode(it, n)) {
        if (
            (it->flags & MD_NodeFlag_ParenLeft)
            && (it->flags & MD_NodeFlag_ParenRight)
        ) {
            if (argsNode) {
                return (ParseFuncResult) {
                    .Error = MD_S8Lit("Found multiple sets of arguments for function"),
                };
            }
            argsNode = it;
        }

        if (it->flags & MD_NodeFlag_BeforeSemicolon) {
            // This node terminates the definition
            terminator = it;
            break;
        }
    }
    if (!argsNode) {
        return (ParseFuncResult) {
            .Error = MD_S8Lit("Did not find arguments for function"),
        };
    }
    
    MD_Node* nameNode = argsNode->prev;
    res.Name = nameNode->string;

    // Everything before the name is the type
    res.ReturnType = ParseType(n, nameNode);

    // Arg parsing - args are separated by commas
    res.NumArgs = 0;
    MD_Node* argStart = NULL;
    for (MD_EachNode(it, argsNode->first_child)) {
        if (!argStart) {
            argStart = it;
        }

        if (it->flags & MD_NodeFlag_BeforeComma || MD_NodeIsNil(it->next)) {
            res.ArgNames[res.NumArgs] = it->string;
            res.ArgTypes[res.NumArgs] = ParseType(argStart, it);

            MD_Node* derefTag = MD_TagFromString(argStart, MD_S8Lit("deref"));
            if (!MD_NodeIsNil(derefTag)) {
                res.ArgDerefs[res.NumArgs] = 1;
            }
            
            MD_Node* castTag = MD_TagFromString(argStart, MD_S8Lit("cast"));
            if (!MD_NodeIsNil(castTag)) {
                res.ArgCasts[res.NumArgs] = castTag->first_child->string;
            }

            res.NumArgs++;
            argStart = NULL;
        }
    }

    // Custom body
    if (argsNode != terminator) {
        res.CustomBody = argsNode->next->string;
    }

    res.After = terminator->next;

    return res;
}

typedef struct {
    MD_String8 LuaDef;
    MD_String8 CppDef;
} GenFuncResult;

GenFuncResult GenFunc(
    ParseFuncResult res,
    MD_String8 customReturnType,
    MD_String8 customName,
    MD_String8 defaultBody,
    MD_b32 isMethod
) {
    MD_String8 returnType = res.ReturnType;
    MD_String8 name = res.Name;
    MD_String8 body = defaultBody;

    if (customReturnType.size > 0) {
        returnType = customReturnType;
    }
    if (customName.size > 0) {
        name = customName;
    }

    if (returnType.size == 0) {
        returnType = MD_S8Lit("void");
    }
    if (res.CustomBody.size > 0) {
        body = res.CustomBody;
    }

    MD_String8List argsList = {0};
    if (isMethod) {
        MD_PushStringToList(&argsList, MD_S8Lit("void* _this"));
    }
    for (int i = 0; i < res.NumArgs; i++) {
        MD_PushStringToList(&argsList, MD_PushStringF("%.*s %.*s", MD_StringExpand(res.ArgTypes[i]), MD_StringExpand(res.ArgNames[i])));
    }
    MD_String8 signature = MD_PushStringF(
        "%.*s %.*s(%.*s)",
        MD_StringExpand(returnType),
        MD_StringExpand(name),
        MD_StringExpand(MD_JoinStringList(argsList, MD_S8Lit(", ")))
    );

    return (GenFuncResult) {
        .LuaDef = MD_PushStringF("%.*s;", MD_StringExpand(signature)),
        .CppDef = MD_PushStringF(
            "LUAFUNC %.*s {\n%.*s\n}\n",
            MD_StringExpand(signature),
            MD_StringExpand(body)
        ),
    };
}

int main(int argc, char** argv) {
    MD_ParseResult parse = MD_ParseWholeFile(MD_S8Lit("src/bindings/bindings.metadesk"));
    
    if (parse.first_error) {
        for (MD_Error *error = parse.first_error; error != 0; error = error->next) {
            MD_CodeLoc loc = MD_CodeLocFromNode(error->node);
            printf("ERROR (line %d, column %d): %.*s\n", loc.line, loc.column, MD_StringExpand(error->string));
        }
        return 1;
    }
    
    // DumpNode(parse.node);

    char filename_buf[128];
    MD_String8List luaDefs = {0};

    for (MD_EachNode(f, parse.node->first_child)) {
        fprintf(stderr, "Processing file \"%.*s\"...\n", MD_StringExpand(f->string));

        sprintf(filename_buf, "src/main/cpp/wpiliblua/%.*s.cpp", MD_StringExpand(f->string));
        FILE* cppfile = fopen(filename_buf, "w");

        fprintf(cppfile, "// Automatically generated by bindings.c. DO NOT EDIT.\n\n");

        for (MD_EachNode(tag, f->first_tag)) {
            if (MD_StringMatch(tag->string, MD_S8Lit("include"), 0)) {
                fprintf(cppfile, "#include %.*s\n", MD_StringExpand(tag->first_child->string));
            } else {
                fclose(cppfile);
                fprintf(stderr, "ERROR (line %d): Unrecognized tag on file: %.*s\n", NodeLine(tag), MD_StringExpand(tag->string));                return 1;
                return 1;
            }
        }
        fprintf(cppfile, "\n");

        fprintf(cppfile, "#include \"luadef.h\"\n\n");

        MD_String8List cppDefs = {0};

        MD_Node* fentry = f->first_child;
        while (1) {
            if (MD_NodeIsNil(fentry)) {
                break;
            }
            
            if (MD_NodeHasTag(fentry, MD_S8Lit("class"))) {
                // Class definition

                MD_String8 cppName = MD_TagFromString(fentry, MD_S8Lit("class"))->first_child->string;
                MD_String8 luaName = fentry->string;

                MD_Node* fNode = fentry->first_child;
                while (1) {
                    if (MD_NodeIsNil(fNode)) {
                        break;
                    }

                    ParseFuncResult res = ParseFunc(fNode);
                    if (res.Error.size > 0) {
                        fclose(cppfile);
                        fprintf(stderr, "ERROR: %.*s\n", MD_StringExpand(res.Error));
                        return 1;
                    }

                    MD_String8 returnType = res.ReturnType;
                    MD_String8 name = MD_PushStringF("%.*s_%.*s", MD_StringExpand(luaName), MD_StringExpand(res.Name));
                    MD_String8 body = {0};
                    MD_b32 isMethod = 0;

                    MD_String8List callArgs = {0};
                    for (int i = 0; i < res.NumArgs; i++) {
                        MD_String8 deref = MD_S8Lit("");
                        if (res.ArgDerefs[i]) {
                            deref = MD_S8Lit("*");
                        }

                        MD_String8 cast = MD_S8Lit("");
                        if (res.ArgCasts[i].size > 0) {
                            cast = MD_PushStringF("(%.*s)", MD_StringExpand(res.ArgCasts[i]));
                        }

                        MD_PushStringToList(&callArgs, MD_PushStringF(
                            "%.*s%.*s%.*s",
                            MD_StringExpand(deref),
                            MD_StringExpand(cast),
                            MD_StringExpand(res.ArgNames[i])
                        ));
                    }

                    if (MD_NodeHasTag(fNode, MD_S8Lit("constructor"))) {
                        returnType = MD_S8Lit("void*");

                        body = MD_PushStringF(
                            "    return new %.*s(%.*s);",
                            MD_StringExpand(cppName),
                            MD_StringExpand(MD_JoinStringList(callArgs, MD_S8Lit(", ")))
                        );
                    } else if (MD_NodeHasTag(fNode, MD_S8Lit("converter"))) {
                        returnType = MD_S8Lit("void*");
                        isMethod = 1;

                        MD_String8 convertTo = MD_TagFromString(fNode, MD_S8Lit("converter"))->first_child->string;
                        body = MD_PushStringF(
                            "    %.*s* _converted = (%.*s*)_this;\n"
                            "    return _converted;",
                            MD_StringExpand(convertTo),
                            MD_StringExpand(cppName)
                        );
                    } else {
                        MD_String8 cppFunc = res.Name;
                        MD_Node* aliasTag = MD_TagFromString(fNode, MD_S8Lit("alias"));
                        if (!MD_NodeIsNil(aliasTag)) {
                            cppFunc = aliasTag->first_child->string;
                        }

                        MD_String8 returnCast = {0};
                        if (MD_NodeHasTag(fNode, MD_S8Lit("explicitcast"))) {
                            returnCast = MD_PushStringF("(%.*s) ", MD_StringExpand(returnType));
                        }

                        isMethod = 1;
                        MD_b32 doReturn = !MD_StringMatch(returnType, MD_S8Lit("void"), 0);
                        body = MD_PushStringF(
                            "    %.*s%.*s((%.*s*)_this)\n"
                            "        ->%.*s(%.*s);",
                            MD_StringExpand(MD_S8Lit(doReturn ? "return " : "")),
                            MD_StringExpand(returnCast),
                            MD_StringExpand(cppName),
                            MD_StringExpand(cppFunc),
                            MD_StringExpand(MD_JoinStringList(callArgs, MD_S8Lit(", ")))
                        );
                    }

                    GenFuncResult genRes = GenFunc(res, returnType, name, body, isMethod);
                    MD_PushStringToList(&cppDefs, genRes.CppDef);
                    MD_PushStringToList(&luaDefs, genRes.LuaDef);
                    
                    fNode = res.After;
                }

                fentry = fentry->next;
            } else {
                // Plain old function

                ParseFuncResult res = ParseFunc(fentry);
                if (res.Error.size > 0) {
                    fclose(cppfile);
                    fprintf(stderr, "ERROR: %.*s\n", MD_StringExpand(res.Error));
                    return 1;
                }

                GenFuncResult genRes = GenFunc(res, MD_S8Lit(""), MD_S8Lit(""), MD_S8Lit(""), 0);
                MD_PushStringToList(&cppDefs, genRes.CppDef);
                MD_PushStringToList(&luaDefs, genRes.LuaDef);

                fentry = res.After;
            }
        }

        fprintf(cppfile, "%.*s", MD_StringExpand(MD_JoinStringList(cppDefs, MD_S8Lit("\n"))));
        fclose(cppfile);
    }

    // Output Lua definitions
    FILE* luafile = fopen("src/lua/wpilib/bindings/init.lua", "w");
    fprintf(luafile,
        "-- Automatically generated by bindings.c. DO NOT EDIT.\n"
        "\n"
        "local ffi = require(\"ffi\")\n"
        "ffi.cdef[[\n"
        "%.*s\n"
        "]]\n",
        MD_StringExpand(MD_JoinStringList(luaDefs, MD_S8Lit("\n")))
    );
    fclose(luafile);

    return 0;
}
