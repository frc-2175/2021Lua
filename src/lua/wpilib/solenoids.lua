local ffi = require("ffi")
ffi.cdef[[
    void* DoubleSolenoid_new(int forwardChannel, int reverseChannel);
    void DoubleSolenoid_set(void* s, int value);
]]

-- Constants

DoubleSolenoidValue = {
    Off = 0, 
    Forward = 1, 
    Reverse = 2,
}


-- Double Solenoid

DoubleSolenoid = {}

function DoubleSolenoid:new(forwardChannel, reverseChannel)
    o = {
        solenoid = ffi.C.DoubleSolenoid_new(forwardChannel, reverseChannel),
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function DoubleSolenoid:set(value)
    ffi.C.DoubleSolenoid_set(self.solenoid, value)
end
