local ffi = require("ffi")

-- lil nav x
PortList = {
    kOnboard = 0,
    kMXP = 1,
    kUSB = 2,
    kUSB1 = 2,
    kUSB2 = 3
}

function NewAHRS(port)
    local a = {
        AHRS = ffi.C.AHRS_new(port),
        getAngle = function(self)
            return ffi.C.AHRS_GetPitch(self.AHRS);
        end,
        reset = function(self)
            ffi.C.AHRS_Reset(self.AHRS);
        end,
    }
    return a
end
