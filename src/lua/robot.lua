require("intake")
require("utils.timer")
require("teleop.coroutines")
require("utils.vector")

safeMode = false
minTurnRateLimit = 0.5
minShooterSpeed =  0.2
minSpeedLimit = 0.7
shooterSpeed = 0
simMode = false
flywheelOn = false

function robot.robotInit()
    if simMode then
        -- sim left motor
        leftMaster = TalonSRX:new(15) -- -making a motor !
        leftMaster:setInverted(CTREInvertType.None) --setting up, making it inverted
    else
        -- real left motor
        leftMaster = TalonFX:new(15) -- -making a motor !
        leftMaster:setInverted(CTRETalonFXInvertType.Clockwise) --setting up, making it inverted
    end

    leftFollower1 = VictorSPX:new(11)
    leftFollower1:follow(leftMaster)
    leftFollower1:setInverted(CTREInvertType.OpposeMaster)

    leftFollower2 = VictorSPX:new(10)
    leftFollower2:follow(leftMaster)
    leftFollower2:setInverted(CTREInvertType.OpposeMaster)

    mainMagazine = TalonSRX:new(6)
    --mainMagazine:setInverted(CTREInvertType.InvertMotorOutput)

    followerMagazine = TalonSRX:new(7)
    followerMagazine:follow(mainMagazine)
    followerMagazine:setInverted(CTREInvertType.FollowMaster)



    if simMode then
        -- sim right motor
        rightMaster = TalonSRX:new(16)
        rightMaster:setInverted(CTREInvertType.None)
    else
        -- real right motor
        rightMaster = TalonFX:new(16)
        rightMaster:setInverted(CTRETalonFXInvertType.Clockwise)
    end

    rightFollower1 = VictorSPX:new(9)
    rightFollower1:follow(rightMaster)
    rightFollower1:setInverted(CTREInvertType.OpposeMaster)

    rightFollower2 = VictorSPX:new(8)
    rightFollower2:follow(rightMaster)
    rightFollower2:setInverted(CTREInvertType.OpposeMaster)

    robotDrive = DifferentialDrive:new(leftMaster, rightMaster) --DifferentialDrive manages all driving math
    
    gearSolenoid = Solenoid:new(2)
    
    leftStick = Joystick:new(0)
    rightStick = Joystick:new(1)
    gamepad = Joystick:new(2)

    -- Setup the motors
    -- Master motor setup
    shooter = SparkMax:new(21, SparkMaxMotorType.Brushless) -- Read above note about motor IDs
    shooter:restoreFactoryDefaults()
    shooter:setIdleMode(SparkMaxIdleMode.Coast)


    feeder = VictorSPX:new(3)

end

--teleop periodic : WHERE EVERTHING HAPPENS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
function robot.teleopPeriodic()   

    shooterSpeed = rightStick:getThrottle() -- Set the shooterSpeed to the value of the knob thing on the joystick.

    if -leftStick:getAxis(JoystickAxes.Throttle) < minSpeedLimit then
        speedLimiter = minSpeedLimit
    else 
        speedLimiter = -leftStick:getAxis(JoystickAxes.Throttle)
    end

    robotDrive:arcadeDrive(
        -leftStick:getAxis(JoystickAxes.Y) * speedLimiter,  -- multiplies speed in forward and backwards
        rightStick:getAxis(JoystickAxes.X)
    )

    if(gamepad:getButton(GamepadButtons.RightTrigger)) then
        intakePutOut()
        intakeRollIn()
    else
        stopIntake()
        intakePutIn()
    end

    gearSolenoid:set(rightStick:getButton(11))

    -- this is autofeed behavior, which also disables manual control
    local didAutoFeed = autoFeed:runWhile(gamepad:getButton(XboxButtons.A))

    if not didAutoFeed then
        if leftStick:getButton(1) then
            shooter:set(shooterSpeed)
            if rightStick:getButton(1) then
                feeder:set(-1)
            else
                feeder:set(0)
            end
        else
            shooter:set(0)
            feeder:set(0)
        end
        mainMagazine:set(-gamepad:getAxis(1)*.87)
    end
    
    -- Holding the left joystick trigger, will run the flywheel, and if the left joystick trigger is pressed when the right joystick trigger is pressed, it will turn on the feeder.

    --intake piston 
    if not safeMode then
        if gamepad:getButtonPressed(GamepadButtons.B) then 
            intakePutOut()
        end 
    end
    --[[ 
    else if gamepad:getButtonPressed(XboxButtons.RightTrigger) or gamepad:getButtonPressed(XboxButtons.RightBumper) 
        intakePutOut() 
    else if gamepad:getButtonReleased(XboxButtons.RightTrigger) or gamepad:getButtonReleased(XboxButtons.RightBumper) 
        intakePutIn() 
    end 
    --]] 
end

function robot.autonomousInit() 
    driveTimer = Timer:new()
    driveTimer:start()
end

function robot.autonomousPeriodic() 
    if driveTimer:getElapsedTimeSeconds() < 2 then
        robotDrive:arcadeDrive(
            0.5,
            0
        )
    else 
        robotDrive:arcadeDrive(
            0,
            0
        )
    end
end

