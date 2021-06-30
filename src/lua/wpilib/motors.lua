local ffi = require("ffi")
ffi.cdef[[
    void* PWMSparkMax_new(int channel);
    void* PWMSparkMax_toSpeedController(void* _m);
    void PWMSparkMax_Set(void* _m, double value);

    void* TalonSRX_new(int deviceNumber);
    void* TalonSRX_toSpeedController(void* _m);
    double TalonSRX_Get(void* _m);
    void TalonSRX_Set(void* _m, double value);
    void TalonSRX_SetInverted(void* _m, int invertType);

    void* TalonFX_new(int deviceNumber);
    void* TalonFX_toSpeedController(void* _m);
    double TalonFX_Get(void* _m);
    void TalonFX_Set(void* _m, double value);
    void TalonFX_SetInverted(void* _m, int invertType);

    void* DifferentialDrive_new(void* leftMotor, void* rightMotor);
    void DifferentialDrive_ArcadeDrive(void* d, double xSpeed, double zRotation, bool squareInputs);
]]

local function makeMotorController(motor, toSCFunc)
    return {
        motor = motor,
        toSpeedController = toSCFunc,
    }
end


-- Constants

CTREInvertType = {
    None = 0, 
    InvertMotorOutput = 1, 
    FollowMaster = 2, 
    OpposeMaster = 3, 
}

-- Clockwise and CounterClockwise here are as viewed from the face of the motor,
-- that is, from the shaft looking toward the body of the motor.
CTRETalonFXInvertType = {
    CounterClockwise = 0, 
    Clockwise = 1, 
    FollowMaster = 2, 
    OpposeMaster = 3, 
}


-- PWM Spark Max

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


-- Talon SRX

TalonSRX = {}

function TalonSRX:new(deviceNumber)
    o = makeMotorController(ffi.C.TalonSRX_new(deviceNumber), ffi.C.TalonSRX_toSpeedController)
    setmetatable(o, self)
    self.__index = self
    return o
end

function TalonSRX:get()
    return ffi.C.TalonSRX_Get(self.motor)
end

function TalonSRX:set(value)
    ffi.C.TalonSRX_Set(self.motor, value)
end

function TalonSRX:setInverted(invertType)
    ffi.C.TalonSRX_SetInverted(self.motor, invertType)
end


-- Talon FX

TalonFX = {}

function TalonFX:new(deviceNumber)
    o = makeMotorController(ffi.C.TalonFX_new(deviceNumber), ffi.C.TalonFX_toSpeedController)
    setmetatable(o, self)
    self.__index = self
    return o
end

function TalonFX:get()
    return ffi.C.TalonFX_Get(self.motor)
end

function TalonFX:set(value)
    ffi.C.TalonFX_Set(self.motor, value)
end

function TalonFX:setInverted(invertType)
    ffi.C.TalonFX_SetInverted(self.motor, invertType)
end


-- Differential Drive

DifferentialDrive = {}

function DifferentialDrive:new(leftMotor, rightMotor)
    print(leftMotor, rightMotor)
    leftSC = leftMotor.toSpeedController(leftMotor.motor)
    print(leftSC)
    rightSC = rightMotor.toSpeedController(rightMotor.motor)
    print(rightSC)
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
