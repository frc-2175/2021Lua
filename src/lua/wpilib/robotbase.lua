local ffi = require("ffi")

---@return boolean isReal
function IsReal()
    return ffi.C.IsReal()
end
