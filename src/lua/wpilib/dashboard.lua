local ffi = require("ffi")

---@param name string
---@param value number
function PutNumber(name, value)
    ffi.C.SmartDashboard_PutNumber(name, value)
end

---@param name string
---@param value table
function PutNumberArray(name, value)
    ffi.C.SmartDashboard_PutNumberArray(name, ffi.new("double[?]", #value, value), #value)
end

---@param name string
---@param value string
function PutString(name, value)
    ffi.C.SmartDashboard_PutString(name, value)
end

---@param name string
---@param value table
function PutStringArray(name, value)
    ffi.C.SmartDashboard_PutStringArray(name, ffi.new("const char*[?]", #value, value), #value)
end

---@param name string
---@param value boolean
function PutBoolean(name, value)
    ffi.C.SmartDashboard_PutBoolean(name, value)
end

--- Use integers instead of booleans (`0=false`, `1=true`)
---@param name string
---@param value table
function PutBooleanArray(name, value)
    ffi.C.SmartDashboard_PutBooleanArray(name, ffi.new("int[?]", #value, value), #value)
end