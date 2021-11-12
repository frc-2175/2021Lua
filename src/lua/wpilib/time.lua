local ffi = require("ffi")

getFPGATimestamp = ffi.C.GetFPGATimestamp()

function getTimeSeconds()
    return ffi.C.GetFPGATimestamp()
end
