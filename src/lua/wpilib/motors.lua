local ffi = require("ffi")

local function makeMotorController(motor, toSCFunc, toIMCFunc)
    return {
        motor = motor,
        toSpeedController = toSCFunc,
        toIMotorController = toIMCFunc
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
    o = makeMotorController(ffi.C.PWMSparkMax_new(channel), ffi.C.PWMSparkMax_toSpeedController, nil)
    setmetatable(o, self)
    self.__index = self
    return o
end

function PWMSparkMax:set(value)
    ffi.C.PWMSparkMax_Set(self.motor, value)
end


-- Victor SPX

VictorSPX = {}

function VictorSPX:new(deviceNumber)
    o = makeMotorController(ffi.C.VictorSPX_new(deviceNumber), ffi.C.VictorSPX_toSpeedController, ffi.C.VictorSPX_toIMotorController)
    setmetatable(o, self)
    self.__index = self
    return o
end

function VictorSPX:get()
    return ffi.C.VictorSPX_Get(self.motor)
end

function VictorSPX:set(value)
    ffi.C.VictorSPX_Set(self.motor, value)
end

function VictorSPX:setInverted(invertType)
    ffi.C.VictorSPX_SetInverted(self.motor, invertType)
end

function VictorSPX:follow(masterToFollow)
    -- TODO: Test that the master is a motor controller
    masterIMC = masterToFollow.toIMotorController(masterToFollow.motor)
    ffi.C.VictorSPX_Follow(self.motor, masterIMC)
end


-- Talon SRX

TalonSRX = {}

function TalonSRX:new(deviceNumber)
    o = makeMotorController(ffi.C.TalonSRX_new(deviceNumber), ffi.C.TalonSRX_toSpeedController, ffi.C.TalonSRX_toIMotorController)
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

function TalonSRX:follow(masterToFollow)
    -- TODO: Test that the master is a motor controller
    masterIMC = masterToFollow.toIMotorController(masterToFollow.motor)
    ffi.C.TalonSRX_Follow(self.motor, masterIMC)
end

function TalonSRX:getOutputCurrent()
    return ffi.C.TalonSRX_GetOutputCurrent(self.motor)
end

function TalonSRX:getMotorOutputVoltage()
    return ffi.C.TalonSRX_GetMotorOutputVoltage(self.motor)
end


-- Talon FX

TalonFX = {}

function TalonFX:new(deviceNumber)
    o = makeMotorController(ffi.C.TalonFX_new(deviceNumber), ffi.C.TalonFX_toSpeedController, ffi.C.TalonFX_toIMotorController)
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

function TalonFX:follow(masterToFollow)
    -- TODO: Test that the master is a motor controller
    masterIMC = masterToFollow.toIMotorController(masterToFollow.motor)
    ffi.C.TalonFX_Follow(self.motor, masterIMC)
end


-- Differential Drive

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
