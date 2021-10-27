local ffi = require("ffi")

function PutNumber(name, value)
    ffi.C.PutNumber(name, value)
end

function PutNumberArray(name, value)
    ffi.C.PutNumberArray(name, ffi.new("double[?]", #value, value), #value)
end

function PutString(name, value)
    ffi.C.PutString(name, value)
end

function PutStringArray(name, value)
    ffi.C.PutStringArray(name, ffi.new("const char*[?]", #value, value), #value)
end

function PutBoolean(name, value)
    ffi.C.PutBoolean(name, value)
end

function PutBooleanArray(name, value)
    ffi.C.PutBooleanArray(name, ffi.new("int[?]", #value, value), #value)
end