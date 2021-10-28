local ffi = require("ffi")

function PutNumber(name, value)
    ffi.C.SmartDashboard_PutNumber(name, value)
end

function PutNumberArray(name, value)
    ffi.C.SmartDashboard_PutNumberArray(name, ffi.new("double[?]", #value, value), #value)
end

function PutString(name, value)
    ffi.C.SmartDashboard_PutString(name, value)
end

function PutStringArray(name, value)
    ffi.C.SmartDashboard_PutStringArray(name, ffi.new("const char*[?]", #value, value), #value)
end

function PutBoolean(name, value)
    ffi.C.SmartDashboard_PutBoolean(name, value)
end

function PutBooleanArray(name, value)
    ffi.C.SmartDashboard_PutBooleanArray(name, ffi.new("int[?]", #value, value), #value)
end