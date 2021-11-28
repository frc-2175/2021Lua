local ffi = require("ffi")

function getFPGATimestamp()
    return ffi.C.GetFPGATimestamp()
end

function getTimeSeconds()
    return ffi.C.GetFPGATimestamp()
end
