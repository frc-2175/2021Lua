local ffi = require("ffi")
ffi.cdef[[
    double GetFPGATimestamp();
]]

getFPGATimestamp = ffi.C.GetFPGATimestamp
getTimeSeconds = ffi.C.GetFPGATimestamp
