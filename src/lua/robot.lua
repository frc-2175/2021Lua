require("intake")
require("drivetrain")
require("utils.timer")
require("teleop.coroutines")
require("utils.vector")
require("wpilib.robotbase")
require("wpilib.dashboard")
require("wpilib.shuffleboard")

safeMode = false
minTurnRateLimit = 0.5
minSpeedLimit = 0.7
shooterSpeed = 0
simMode = not IsReal()
flywheelOn = false

function robot.robotInit()
    if simMode then
        PutBoolean("Sim Mode", true)
        -- sim left motor
        leftMaster = TalonSRX:new(15) -- making a motor !
        leftMaster:setInverted(CTREInvertType.None) -- setting up, making it inverted
    else
        PutBoolean("Sim Mode", false)
        -- real left motor
        leftMaster = TalonFX:new(15) -- making a motor !
        leftMaster:setInverted(CTRETalonFXInvertType.CounterClockwise) -- setting up, making it inverted
    end

    leftFollower1 = TalonFX:new(16)
    leftFollower1:follow(leftMaster)
    leftFollower1:setInverted(CTREInvertType.FollowMaster)

    mainMagazine = TalonSRX:new(6)
    -- mainMagazine:setInverted(CTREInvertType.InvertMotorOutput)

    followerMagazine = TalonSRX:new(7)
    followerMagazine:follow(mainMagazine)
    followerMagazine:setInverted(CTREInvertType.FollowMaster)

    if simMode then
        -- sim right motor
        rightMaster = TalonSRX:new(17)
        rightMaster:setInverted(CTREInvertType.None)
    else
        -- real right motor
        rightMaster = TalonFX:new(17)
        rightMaster:setInverted(CTRETalonFXInvertType.CounterClockwise)
    end

    rightFollower1 = TalonFX:new(18)
    rightFollower1:follow(rightMaster)
    rightFollower1:setInverted(CTREInvertType.FollowMaster)

    robotDrive = DifferentialDrive:new(leftMaster, rightMaster) -- DifferentialDrive manages all driving math

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

    ramp = NewRamp(0.2, 0.4)

    peakCurrent = {
        left = 0,
        right = 0
    }
end

-- teleop periodic : WHERE EVERTHING HAPPENS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
function robot.teleopPeriodic()

    if leftMaster:getStatorCurrent() > peakCurrent.left then
        peakCurrent.left = leftMaster:getStatorCurrent()
        PutNumber("Peak left current", rightMaster:getStatorCurrent())
    end
    if rightMaster:getStatorCurrent() > peakCurrent.right then
        peakCurrent.right = rightMaster:getStatorCurrent()
        PutNumber("Peak right current", rightMaster:getStatorCurrent())
    end

    shooterSpeed = rightStick:getThrottle() -- Set the shooterSpeed to the value of the knob thing on the joystick.

    if -leftStick:getAxis(JoystickAxes.Throttle) < minSpeedLimit then
        speedLimiter = minSpeedLimit
    else
        speedLimiter = -leftStick:getAxis(JoystickAxes.Throttle)
    end

    robotDrive:arcadeDrive(
        ramp:Ramp(-leftStick:getAxis(JoystickAxes.Y) * speedLimiter),  -- multiplies speed in forward and backwards
        rightStick:getAxis(JoystickAxes.X)
    )

    if gamepad:getButton(GamepadButtons.RightTrigger) then
        intakePutOut()
        intakeRollIn()
    else
        stopIntake()
        intakePutIn()
    end

    gearSolenoid:set(rightStick:getButton(11))

    -- this is autofeed behavior, which also disables manual control

    -- Clarify what didAutoFeed does.
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
        mainMagazine:set(-gamepad:getAxis(1) * 0.87)
    end

    -- Holding the left joystick trigger, will run the flywheel, and if the left joystick trigger is pressed when the right joystick trigger is pressed, it will turn on the feeder.

    -- intake piston 
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
        robotDrive:arcadeDrive(0.5, 0)
    else
        robotDrive:arcadeDrive(0, 0)
    end
end
