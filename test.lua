#!/usr/bin/env lua

PathSep = package.config:sub(1,1)

ResetColor = "\27[0m"
Red = "\27[31m"
Green = "\27[32m"
Blue = "\27[94m"

function getOS()
    if PathSep == "\\" then
        return "windows"
    else
        return "unix"
    end
end

function tableContains(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function hasSuffix(str, suffix)
    if string.len(suffix) == 0 then
        return true
    end
    return string.sub(str, -string.len(suffix)) == suffix
end

function listFiles(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile
    if getOS() == "windows" then
        pfile = popen('dir "'..directory..'" /b /ad')
    else
        pfile = popen('ls -a "'..directory..'"')
    end
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

function listAllFiles(directory, suffix)
    suffix = suffix or ""

    local allFiles = {}
    local function handleDir(directory)
        local numFilesThisDir = 0
        local files = listFiles(directory)
        local ignoreFiles = {directory, ".", ".."}
        for _, file in pairs(files) do
            if not tableContains(ignoreFiles, file) then
                numFilesThisDir = numFilesThisDir + 1

                local fname = directory..PathSep..file
                local isFile = handleDir(fname)
                if isFile and hasSuffix(file, suffix) then
                    table.insert(allFiles, fname)
                end
            end
        end

        -- return true if this is a file and not a directory
        return numFilesThisDir == 0
    end

    handleDir(directory)

    return allFiles
end

-------------------------------------------------------------------------------
-- Set up environment for testing.

package.path = package.path..";./src/lua/?.lua;./src/lua/?/init.lua"

local ffi = {
    C = {}
}
setmetatable(ffi, {
    __index = function ()
        return function() end
    end
})
setmetatable(ffi.C, {
    __index = function ()
        return function() end
    end
})
package.loaded["ffi"] = ffi -- "preload" our fake FFI

-------------------------------------------------------------------------------
-- Create our actual global test module

-- TODO: Support sub-tests?
local tests = {}
function test(name, func)
    tests[name] = func
end

local t = {}

function t:assert(value, message)
    local errorPrefix = message and (message..": ") or ""
    assert(value, errorPrefix.."assertion failed!")
end

function t:assertEqual(actual, expected, message)
    local errorPrefix = message and (message..": ") or ""
    if type(actual) == "table" and type(expected) == "table" then
        assert(#actual == #expected, errorPrefix.."tables were not the same size")
        assert(table.unpack(actual) == table.unpack(expected), errorPrefix.."values were not equal: expected "..tostring(expected)..", but got "..tostring(actual))
    else
        assert(actual == expected, errorPrefix.."values were not equal: expected "..tostring(expected)..", but got "..tostring(actual))
    end
end

function runTests()
    local testItems = {}
    for name, func in pairs(tests) do
        table.insert(testItems, {
            name = name,
            func = func,
        })
    end

    table.sort(testItems, function(a, b)
        return a.name < b.name
    end)

    print()
    print(Green.."-------------------------------------------------------------------------------"..ResetColor)
    print(Green.."Running tests..."..ResetColor)
    print()

    local failed = false
    for _, test in ipairs(testItems) do
        io.write(Blue..test.name..": "..ResetColor)
        io.flush()

        local ok, err = xpcall(test.func, debug.traceback, t)
        if err == nil then
            io.write(Green.."OK"..ResetColor.."\n")
        else
            io.write(Red.."ERROR"..ResetColor.."\n")
            failed = true
            print(err)
        end
    end

    return failed
end

-------------------------------------------------------------------------------
-- Run tests!

local failed = false

local luaFiles = listAllFiles("src", ".lua")
local loadErrs = {}
for _, file in pairs(luaFiles) do
    local runChunk, err = loadfile(file)
    if err ~= nil then
        table.insert(loadErrs, err)
    else
        err = runChunk()
        if err ~= nil then
            table.insert(loadErrs, err)
        end
    end
end

if #loadErrs > 0 then
    failed = true
    print()
    print(Red.."-------------------------------------------------------------------------------"..ResetColor)
    print(Red.."There were errors loading files in the project. Some tests might not run."..ResetColor)
    print()
end
for _, err in pairs(loadErrs) do
    print(err)
end

local testsFailed = runTests()
if testsFailed then
    failed = true
end

print()

if failed then
    os.exit(1)
end
