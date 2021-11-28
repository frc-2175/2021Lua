#include <assert.h>

#include "./md.h"
#include "./md.c"

#define NodeLine(node) MD_CodeLocFromNode(node).line
#define MAX_ARGS 16
#define MAX_BASE_CLASSES 10

// Memory allocator for Metadesk
MD_Arena* a;

// Predefined MD_Joins because the API is terrible
MD_StringJoin newlineJoin = MD_ZERO_STRUCT;
MD_StringJoin commaJoin = MD_ZERO_STRUCT;

void printIndent(int level) {
    for (int i = 0; i < level; i++) {
        printf("| ");
    }
}

void DumpNodeR(MD_Node* node, const char* marker, int level) {
    printIndent(level);
    printf("%s %.*s\n", marker, MD_S8VArg(node->string));
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

MD_String8 TrimNewlines(MD_String8 string) {
    for (MD_u64 i = 0; i < string.size; i += 1) {
        if (!(string.str[i] == '\n' || string.str[i] == '\r')) {
            string = MD_S8Skip(string, i);
            break;
        }
    }
    for (MD_u64 i = string.size-1; i < string.size; i -= 1) {
        if (!(string.str[i] == '\n' || string.str[i] == '\r')) {
            string = MD_S8Prefix(string, i+1);
            break;
        }
    }
    return string;
}

MD_String8 ParseType(MD_Node* start, MD_Node* end) {
    MD_String8List pieces = {0};
    for (MD_Node* it = start; !MD_NodeIsNil(it) && it != end; it = it->next) {
        MD_S8ListPush(a, &pieces, it->string);
    }
    return MD_S8ListJoin(a, pieces, NULL);
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

    MD_Message* Error;
} ParseFuncResult;

ParseFuncResult ParseFunc(MD_Node* n) {
    ParseFuncResult res = {0};

    MD_Node* argsNode = NULL;
    MD_Node* terminator = NULL;

    for (MD_EachNode(it, n)) {
        if (
            (it->flags & MD_NodeFlag_HasParenLeft)
            && (it->flags & MD_NodeFlag_HasParenRight)
        ) {
            if (argsNode) {
                return (ParseFuncResult) {
                    .Error = &(MD_Message) {
                        .kind = MD_MessageKind_Error,
                        .string = MD_S8Lit("Found multiple sets of arguments for function (are you missing a semicolon?)"),
                        .node = it,
                    },
                };
            }
            argsNode = it;
        }

        if (it->flags & MD_NodeFlag_IsBeforeSemicolon) {
            // This node terminates the definition
            terminator = it;
            break;
        }
    }
    if (!argsNode) {
        return (ParseFuncResult) {
            .Error = &(MD_Message) {
                .kind = MD_MessageKind_Error,
                .string = MD_S8Lit("Did not find arguments for function"),
                .node = n,
            },
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

        if (it->flags & MD_NodeFlag_IsBeforeComma || MD_NodeIsNil(it->next)) {
            res.ArgNames[res.NumArgs] = it->string;
            res.ArgTypes[res.NumArgs] = ParseType(argStart, it);

            MD_Node* derefTag = MD_TagFromString(argStart, MD_S8Lit("deref"), 0);
            if (!MD_NodeIsNil(derefTag)) {
                res.ArgDerefs[res.NumArgs] = 1;
            }

            MD_Node* castTag = MD_TagFromString(argStart, MD_S8Lit("cast"), 0);
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
        res.CustomBody = MD_S8ListJoin(a,
            MD_S8Split(a, res.CustomBody, 1, (MD_String8[]) { MD_S8Lit("\r") }),
            NULL
        );
        res.CustomBody = TrimNewlines(MD_S8ChopWhitespace(TrimNewlines(res.CustomBody))); // this could sure be a lot cleaner lol (if they fix some bugs in metadesk)
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
        MD_S8ListPush(a, &argsList, MD_S8Lit("void* _this"));
    }
    for (int i = 0; i < res.NumArgs; i++) {
        MD_S8ListPushFmt(a, &argsList, "%S %S", res.ArgTypes[i], res.ArgNames[i]);
    }
    MD_String8 signature = MD_S8Fmt(a,
        "%S %S(%S)",
        returnType, name, MD_S8ListJoin(a, argsList, &commaJoin)
    );

    return (GenFuncResult) {
        .LuaDef = MD_S8Fmt(a, "%S;", signature),
        .CppDef = MD_S8Fmt(a,
            "LUAFUNC %S {\n%S\n}\n",
            signature, body
        ),
    };
}

// Returns an error message
MD_Message* addClassFuncs(
    MD_Node* klass,
    MD_String8 cppName,
    MD_String8 luaName,
    MD_String8List* cppDefs,
    MD_String8List* luaDefs
    ) {
    MD_Node* fNode = klass->first_child;
    while (1) {
        if (MD_NodeIsNil(fNode)) {
            break;
        }

        ParseFuncResult res = ParseFunc(fNode);
        if (res.Error) {
            return res.Error;
        }

        MD_String8 returnType = res.ReturnType;
        MD_String8 name = MD_S8Fmt(a, "%S_%S", luaName, res.Name);
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
                cast = MD_S8Fmt(a, "(%S)", res.ArgCasts[i]);
            }

            MD_S8ListPushFmt(a, &callArgs,
                "%S%S%S",
                deref, cast, res.ArgNames[i]
            );
        }

        if (MD_NodeHasTag(fNode, MD_S8Lit("constructor"), 0)) {
            returnType = MD_S8Lit("void*");

            body = MD_S8Fmt(a,
                "    return new %S(%S);",
                cppName, MD_S8ListJoin(a, callArgs, &commaJoin)
            );
        } else if (MD_NodeHasTag(fNode, MD_S8Lit("converter"), 0)) {
            returnType = MD_S8Lit("void*");
            isMethod = 1;

            MD_String8 convertTo = MD_TagFromString(fNode, MD_S8Lit("converter"), 0)->first_child->string;
            body = MD_S8Fmt(a,
                "    %S* _converted = (%S*)_this;\n"
                "    return _converted;",
                convertTo, cppName
            );
        } else if (MD_NodeHasTag(fNode, MD_S8Lit("static"), 0)) {
            isMethod = 0;
            MD_String8 staticName = res.Name;

            MD_Node* aliasTag = MD_TagFromString(fNode, MD_S8Lit("alias"), 0);
            if (!MD_NodeIsNil(aliasTag)) {
                staticName = aliasTag->first_child->string;
            }

            body = MD_S8Fmt(a,
                "   %S::%S(%S);",
                cppName, staticName, MD_S8ListJoin(a, callArgs, &commaJoin)
            );
        } else {
            MD_String8 cppFunc = res.Name;
            MD_Node* aliasTag = MD_TagFromString(fNode, MD_S8Lit("alias"), 0);
            if (!MD_NodeIsNil(aliasTag)) {
                cppFunc = aliasTag->first_child->string;
            }

            isMethod = 1;

            MD_b32 isVoid = returnType.size == 0 || MD_S8Match(returnType, MD_S8Lit("void"), 0);
            if (isVoid) {
                body = MD_S8Fmt(a,
                    "    ((%S*)_this)\n"
                    "        ->%S(%S);",
                    cppName,
                    cppFunc, MD_S8ListJoin(a, callArgs, &commaJoin)
                );
            } else {
                MD_String8 returnCast = {0};
                if (MD_NodeHasTag(fNode, MD_S8Lit("cast"), 0)) {
                    returnCast = MD_S8Fmt(a, "(%S) ", returnType);
                }

                MD_Node* allocTag = MD_TagFromString(fNode, MD_S8Lit("alloc"), 0);
                MD_b32 shouldAlloc = !MD_NodeIsNil(allocTag);

                if (shouldAlloc) {
                    MD_String8 allocType = allocTag->first_child->string;

                    body = MD_S8Fmt(a,
                        "    auto _result = (%S*) malloc(sizeof(%S));\n"
                        "    *_result = ((%S*)_this)\n"
                        "        ->%S(%S);\n"
                        "    return %S_result;",
                        allocType, allocType,
                        cppName,
                        cppFunc, MD_S8ListJoin(a, callArgs, &commaJoin),
                        returnCast
                    );
                } else {
                    body = MD_S8Fmt(a,
                        "    auto _result = ((%S*)_this)\n"
                        "        ->%S(%S);\n"
                        "    return %S_result;",
                        cppName,
                        cppFunc, MD_S8ListJoin(a, callArgs, &commaJoin),
                        returnCast
                    );
                }
            }
        }

        GenFuncResult genRes = GenFunc(res, returnType, name, body, isMethod);
        MD_S8ListPush(a, cppDefs, genRes.CppDef);
        MD_S8ListPush(a, luaDefs, genRes.LuaDef);

        fNode = res.After;
    }

    return NULL;
}

void PrintMessage(FILE* file, MD_Message* m) {
    MD_CodeLoc loc = MD_ZERO_STRUCT;
    if (m->node) {
        loc = MD_CodeLocFromNode(m->node);
    }
    MD_PrintMessage(file, loc, m->kind, m->string);
}

void PrintMessages(FILE* file, MD_Message* first) {
    if (!first) {
        return;
    }
    for (MD_Message* m = first; m; m = m->next) {
        PrintMessage(file, m);
    }
}

void PrintMessageList(FILE* file, MD_MessageList messages) {
    PrintMessages(file, messages.first);
}

int main(int argc, char** argv) {
    a = MD_ArenaAlloc();
    newlineJoin.mid = MD_S8Lit("\n");
    commaJoin.mid = MD_S8Lit(", ");

    MD_ParseResult parse = MD_ParseWholeFile(a, MD_S8Lit("src/bindings/bindings.metadesk"));

    PrintMessageList(stderr, parse.errors);
    if (parse.errors.max_message_kind >= MD_MessageKind_Error) {
        return 1;
    }

    // DumpNode(parse.node);

    char filename_buf[128];
    MD_String8List luaDefs = {0};

    for (MD_EachNode(f, parse.node->first_child)) {
        fprintf(stderr, "Processing file \"%.*s\"...\n", MD_S8VArg(f->string));

        sprintf(filename_buf, "src/main/cpp/wpiliblua/%.*s.cpp", MD_S8VArg(f->string));
        FILE* cppfile = fopen(filename_buf, "w");

        fprintf(cppfile, "// Automatically generated by bindings.c. DO NOT EDIT.\n\n");

        for (MD_EachNode(tag, f->first_tag)) {
            if (MD_S8Match(tag->string, MD_S8Lit("include"), 0)) {
                fprintf(cppfile, "#include %.*s\n", MD_S8VArg(tag->first_child->string));
            } else {
                fclose(cppfile);
                PrintMessage(stderr, &(MD_Message) {
                    .kind = MD_MessageKind_Error,
                    .string = MD_S8Fmt(a, "Unrecognized tag \"%S\" on file", tag->string),
                    .node = tag,
                });
                return 1;
            }
        }
        fprintf(cppfile, "\n");

        fprintf(cppfile, "#include \"luadef.h\"\n\n");

        int numBaseClasses = 0;
        MD_Node* baseClasses[MAX_BASE_CLASSES] = {0};

        MD_String8List cppDefs = {0};

        MD_Node* fentry = f->first_child;
        while (1) {
            if (MD_NodeIsNil(fentry)) {
                break;
            }

            if (MD_NodeHasTag(fentry, MD_S8Lit("baseclass"), 0)) {
                // Base class (save node for later lookup)
                baseClasses[numBaseClasses] = fentry;
                numBaseClasses++;
                fentry = fentry->next;
            } else if (MD_NodeHasTag(fentry, MD_S8Lit("class"), 0)) {
                // Class definition

                MD_String8 cppName = MD_TagFromString(fentry, MD_S8Lit("class"), 0)->first_child->string;
                MD_String8 luaName = fentry->string;

                for (MD_EachNode(tag, fentry->first_tag)) {
                    if (!MD_S8Match(tag->string, MD_S8Lit("extends"), 0)) {
                        continue;
                    }

                    // Look up base class
                    MD_String8 baseClassName = tag->first_child->string;
                    MD_Node* baseClass = 0;
                    for (int i = 0; i < numBaseClasses; i++) {
                        if (MD_S8Match(baseClasses[i]->string, baseClassName, 0)) {
                            baseClass = baseClasses[i];
                            break;
                        }
                    }
                    if (!baseClass) {
                        fclose(cppfile);
                        MD_PrintMessageFmt(stderr, MD_CodeLocFromNode(tag), MD_MessageKind_Error,
                            "Couldn't find base class \"%S\"",
                            baseClassName
                        );
                        return 1;
                    }

                    MD_Message* error = addClassFuncs(baseClass, cppName, luaName, &cppDefs, &luaDefs);
                    if (error) {
                        fclose(cppfile);
                        MD_Message* msg = &(MD_Message) {
                            .kind = MD_MessageKind_Error,
                            .string = MD_S8Fmt(a, "Failed to add functions from base class \"%S\"", baseClassName),
                            .node = tag,
                            .next = error,
                        };
                        PrintMessages(stderr, msg);
                        return 1;
                    }
                }

                MD_Message* error = addClassFuncs(fentry, cppName, luaName, &cppDefs, &luaDefs);
                if (error) {
                    fclose(cppfile);
                    MD_Message* msg = &(MD_Message) {
                        .kind = MD_MessageKind_Error,
                        .string = MD_S8Fmt(a, "Failed to add functions for class \"%S\"", luaName),
                        .node = fentry,
                        .next = error,
                    };
                    PrintMessages(stderr, msg);
                    return 1;
                }

                fentry = fentry->next;
            } else {
                // Plain old function

                ParseFuncResult res = ParseFunc(fentry);
                if (res.Error) {
                    fclose(cppfile);
                    PrintMessage(stderr, res.Error);
                    return 1;
                }

                GenFuncResult genRes = GenFunc(res, MD_S8Lit(""), MD_S8Lit(""), MD_S8Lit(""), 0);
                MD_S8ListPush(a, &cppDefs, genRes.CppDef);
                MD_S8ListPush(a, &luaDefs, genRes.LuaDef);

                fentry = res.After;
            }
        }

        fprintf(cppfile, "%.*s", MD_S8VArg(MD_S8ListJoin(a, cppDefs, &newlineJoin)));
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
        MD_S8VArg(MD_S8ListJoin(a, luaDefs, &newlineJoin))
    );
    fclose(luafile);

    return 0;
}
