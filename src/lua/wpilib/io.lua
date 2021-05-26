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

GamepadButtons = {
    X = 1,
    A = 2,
    B = 3,
    Y = 4,
    LeftBumper = 5,
    RightBumper = 6,
    LeftTrigger = 7,
    RightTrigger = 8,
    Select = 9,
    Start = 10,
    LeftStick = 11,
    RightStick = 12,
}

-- TODO: Gamepad axes

XboxButtons = {
    A = 1,
    B = 2,
    X = 3,
    Y = 4,
    LeftBumper = 5,
    RightBumper = 6,
    Select = 7,
    Start = 8,
    LeftStick = 9,
    RightStick = 10,
}

XboxAxes = {
    X = 0,
    Y = 1,
    LeftTrigger = 2,
    RightTrigger = 3,
    RightStickX = 4,
    RightStickY = 5,
}


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
