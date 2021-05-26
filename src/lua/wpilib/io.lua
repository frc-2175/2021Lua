local ffi = require("ffi")
ffi.cdef[[
    void* Joystick_new(int port);
    double Joystick_GetX(void* j);
    double Joystick_GetY(void* j);
    bool Joystick_GetRawButton(void* j, int button);
    bool Joystick_GetRawButtonPressed(void* j, int button);
    bool Joystick_GetRawButtonReleased(void* j, int button);
    double Joystick_GetRawAxis(void* j, int axis);
]]


-- Constants

GAMEPAD_X = 1
GAMEPAD_A = 2
GAMEPAD_B = 3
GAMEPAD_Y = 4
GAMEPAD_LEFT_BUMPER = 5
GAMEPAD_RIGHT_BUMPER = 6
GAMEPAD_LEFT_TRIGGER = 7
GAMEPAD_RIGHT_TRIGGER = 8
GAMEPAD_SELECT = 9
GAMEPAD_START = 10
GAMEPAD_LEFT_STICK_PRESS = 11
GAMEPAD_RIGHT_STICK_PRESS = 12

XBOX_A = 1
XBOX_B = 2
XBOX_X = 3
XBOX_Y = 4
XBOX_LEFT_BUMPER = 5
XBOX_RIGHT_BUMPER = 6
XBOX_SELECT = 7
XBOX_START = 8
XBOX_LEFT_STICK_PRESS = 9
XBOX_RIGHT_STICK_PRESS = 10

XBOX_AXIS_X = 0
XBOX_AXIS_Y = 1
XBOX_AXIS_LEFT_TRIGGER = 2
XBOX_AXIS_RIGHT_TRIGGER = 3
XBOX_AXIS_RIGHT_STICK_X = 4
XBOX_AXIS_RIGHT_STICK_Y = 5


-- Joystick

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

function Joystick:getButton(button)
    return ffi.C.Joystick_GetRawButton(self.joystick, button)
end

function Joystick:getButtonPressed(button)
    return ffi.C.Joystick_GetRawButtonPressed(self.joystick, button)
end

function Joystick:getButtonReleased(button)
    return ffi.C.Joystick_GetRawButtonReleased(self.joystick, button)
end

function Joystick:getAxis(axis)
    return ffi.C.Joystick_GetRawAxis(self.joystick, axis);
end
