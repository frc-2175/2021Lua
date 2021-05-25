local ffi = require("ffi")
ffi.cdef[[
void* Joystick_new(int port);
double Joystick_GetX(void* j);
double Joystick_GetY(void* j);
]]

Joystick = {}

function Joystick:new(port)
    o = {
        joystick = ffi.C.Joystick_new(port),
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Joystick:getX()
    return ffi.C.Joystick_GetX(self.joystick)
end

function Joystick:getY()
    return ffi.C.Joystick_GetY(self.joystick)
end
