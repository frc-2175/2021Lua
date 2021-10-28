local ffi = require("ffi")

-- Constants

DoubleSolenoidValue = {
    Off = 0, 
    Forward = 1, 
    Reverse = 2,
}

-- Solenoid

Solenoid = {}

function Solenoid:new(channel)
    o = {
        solenoid = ffi.C.Solenoid_new(channel),
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Solenoid:get()
    return ffi.C.Solenoid_Get(self.solenoid)
end

function Solenoid:set(on)
    ffi.C.Solenoid_Set(self.solenoid, on)
end

-- Double Solenoid

DoubleSolenoid = {}

function DoubleSolenoid:new(forwardChannel, reverseChannel)
    local o = {
        solenoid = ffi.C.DoubleSolenoid_new(forwardChannel, reverseChannel),
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function DoubleSolenoid:set(value)
    ffi.C.DoubleSolenoid_Set(self.solenoid, value)
end
