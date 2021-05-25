local ffi = require("ffi")
ffi.cdef[[
void* PWMSparkMax_new(int channel);
void* PWMSparkMax_toSpeedController(void* m);
void PWMSparkMax_Set(void* m, double value);
void* DifferentialDrive_new(void* leftMotor, void* rightMotor);
void DifferentialDrive_ArcadeDrive(void* d, double xSpeed, double zRotation, bool squareInputs);
]]

local function makeMotorController(motor, toSCFunc)
    return {
        motor = motor,
        toSpeedController = toSCFunc,
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
    ffi.C.PWMSparkMax_Set(self.motor, value)
end

DifferentialDrive = {}

function DifferentialDrive:new(leftMotor, rightMotor)
    leftSC = leftMotor.toSpeedController(leftMotor.motor)
    rightSC = rightMotor.toSpeedController(rightMotor.motor)
    o = {
        drive = ffi.C.DifferentialDrive_new(leftSC, rightSC),
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function DifferentialDrive:arcadeDrive(xSpeed, zRotation, squareInputs)
    squareInputs = squareInputs == nil and true or squareInputs
    ffi.C.DifferentialDrive_ArcadeDrive(self.drive, xSpeed, zRotation, squareInputs)
end
