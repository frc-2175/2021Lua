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
    local i, t = 0, {}
    if getOS() == "windows" then
        local pfile_all = io.popen('dir "'..directory..'" /b')
        local pfile_dir = io.popen('dir "'..directory..'" /b /ad 2>&1')
        if pfile_dir:read() ~= 'File Not Found' then
            -- is a directory
            for filename in pfile_all:lines() do
                i = i + 1
                t[i] = filename
            end
        end
        pfile_all:close()
        pfile_dir:close()
    else
        local pfile = io.popen('ls -a "'..directory..'"')
        for filename in pfile:lines() do
            i = i + 1
            t[i] = filename
        end
        pfile:close()
    end
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

--- Assert that a condition is true.
---@param value The value to check - must be true for the test to pass.
---@param message An optional message to show in case of failure.
function t:assert(value, message)
    local errorPrefix = message and (message..": ") or ""
    assert(value, errorPrefix.."assertion failed!")
end

--- Assert that two values are equal (or in the case of numbers, very nearly equal).
---@param actual The actual value produced by your code. Usually the result of a function call.
---@param expected The value you expect to see.
---@param message An optional message to show in case of failure.
function t:assertEqual(actual, expected, message)
    local errorPrefix = message and (message..": ") or ""
    local defaultMsg = errorPrefix.."values were not equal: expected "..tostring(expected)..", but got "..tostring(actual)
    
    if type(actual) == "table" and type(expected) == "table" then
        assert(#actual == #expected, errorPrefix.."tables were not the same size")
        assert(table.unpack(actual) == table.unpack(expected), errorPrefix.."values were not equal: expected "..tostring(expected)..", but got "..tostring(actual))
    elseif type(actual) == "number" and type(expected) == "number" then
        assert(math.abs(actual - expected) < 0.00001, defaultMsg)
    else
        assert(actual == expected, defaultMsg)
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

        local ok, err = xpcall(function()
            test.func(t)
        end, debug.traceback)
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
