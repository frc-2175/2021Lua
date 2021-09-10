local ffi = require("ffi")

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

JoystickAxes = {
    X = 0,
    Y = 1,
    Throttle = 2,
}


-- Joystick
-- JOYSTICK IS MAPPED FROM -1 TO 1

Joystick = {}

function Joystick:new(port)
    o = {
        joystick = ffi.C.Joystick_new(port),
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

deadvalue = 0.1

function Deadband(value, band)
    result = 0
    if (value > band)
    then
        result = (value - band) / (1 - band);
    elseif (value < -band)
    then
        result = (value + band) / (1 - band);
    end
    return result
end

function Joystick:getX()
    return Deadband(ffi.C.Joystick_GetX(self.joystick), deadvalue)
end

function Joystick:getY()
    return Deadband(ffi.C.Joystick_GetY(self.joystick), deadvalue)
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
    return Deadband(ffi.C.Joystick_GetRawAxis(self.joystick, axis), deadvalue)
end

function Joystick:getThrottle()
    x = self:getAxis(JoystickAxes.Throttle)
    return -0.5 * x + 0.5
end
