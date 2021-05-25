ffi = require("ffi")
ffi.cdef[[
void* PWMSparkMax_new(int channel);
void* PWMSparkMax_toSpeedController(void* m);
void PWMSparkMax_Set(void* m, double value);
void* DifferentialDrive_new(void* leftMotor, void* rightMotor);
void DifferentialDrive_ArcadeDrive(void* d, double xSpeed, double zRotation, bool squareInputs);
void* Joystick_new(int port);
double Joystick_GetX(void* j);
double Joystick_GetY(void* j);
]]

local function makeMotorController(motor, toSCFunc)
    return {
        _motor = motor,
        _toSpeedController = toSCFunc,
    }
end

PWMSparkMax = {}

function PWMSparkMax:new(channel)
    o = makeMotorController(ffi.C.PWMSparkMax_new(channel), ffi.C.PWMSparkMax_toSpeedController)
    setmetatable(o, self)
    self.__index = self
    return o
end

function PWMSparkMax:set(value)
    ffi.C.PWMSparkMax_Set(self._motor, value)
end

DifferentialDrive = {}

function DifferentialDrive:new(leftMotor, rightMotor)
    leftSC = leftMotor._toSpeedController(leftMotor._motor)
    rightSC = rightMotor._toSpeedController(rightMotor._motor)
    o = {
        _drive = ffi.C.DifferentialDrive_new(leftSC, rightSC),
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function DifferentialDrive:arcadeDrive(xSpeed, zRotation, squareInputs)
    squareInputs = squareInputs == nil and true or squareInputs
    ffi.C.DifferentialDrive_ArcadeDrive(self._drive, xSpeed, zRotation, squareInputs)
end

Joystick = {}

function Joystick:new(port)
    o = {
        _joystick = ffi.C.Joystick_new(port),
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Joystick:getX()
    return ffi.C.Joystick_GetX(self._joystick)
end

function Joystick:getY()
    return ffi.C.Joystick_GetY(self._joystick)
end
