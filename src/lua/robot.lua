require("intake")

safeMode = true
minTurnRateLimit = 0.5
minSpeedLimit = 0.7
shooterSpeed = 0.6
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

    -- Set up one shooter motor. The two motor IDs are 21 and 22.
    -- I'm not sure what the "5" in this means, but I'm going to assume it's supposed to be the motor ID, if not, it should be fairly easy to hopefully correct.
    -- I don't know the setup of the motors on the rest of the robot so the most I can write is the code to spin up and down the flywheel.
    -- Wish I could write some more comprehensive code, but I just don't have the info.
    -- Ex. code: shooter = SparkMax:new(5, SparkMaxMotorType.Brushless) -- the motors we use, NEOs, are brushless
    -- Ex. code: shooter:restoreFactoryDefaults() -- the controllers can get stuck on old, saved config if we don't do this on startup
    -- Ex. code: shooter:setIdleMode(SparkMaxIdleMode.Coast) -- it is really important to let the shooter wheels gently coast to a stop

    -- Setup the motors
    -- Master motor setup
    shooter = SparkMax:new(21, SparkMaxMotorType.Brushless) -- Read above note about motor IDs
    shooter:restoreFactoryDefaults()
    shooter:setIdleMode(SparkMaxIdleMode.Coast)
    -- Follower motor setup
    secondaryShooter = SparkMax:new(22, SparkMaxMotorType.Brushless)
    -- Not sure if this setup is necessary for a follower motor
    secondaryShooter:restoreFactoryDefaults()
    secondaryShooter:setIdleMode(SparkMaxIdleMode.Coast)
    -- Set secondaryShooter as a follower of shooter
    secondaryShooter:follow(shooter)

    -- you can set the speed of the shooter like so:
    -- shooter:set(0.5)

    -- other motors can use the :follow method like so:
    -- otherShooterMotor:follow(shooter)

    -- when you are doing master/follower stuff, you only need to set
    -- a speed on the master motor, and the followers automatically do
    -- their thing.

    feeder = VictorSPX:new(3)

end

--teleop periodic : WHERE EVERTHING HAPPENS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
function robot.teleopPeriodic()   
    if -rightStick:getAxis(JoystickAxes.Throttle) < minTurnRateLimit then 
        turnLimiter = minTurnRateLimit
    else
        turnLimiter = -rightStick:getAxis(JoystickAxes.Throttle) -- Set the turnLimiter to the value of the knob thing on the joystick.
    end

    if -leftStick:getAxis(JoystickAxes.Throttle) < minSpeedLimit then
        speedLimiter = minSpeedLimit
    else 
        speedLimiter = -leftStick:getAxis(JoystickAxes.Throttle)
    end

    robotDrive:arcadeDrive(
        -leftStick:getAxis(JoystickAxes.Y) * speedLimiter,  -- multiplies speed in forward and backwards
        rightStick:getAxis(JoystickAxes.X) * turnLimiter
    )

    -- speed = -gamepad:getAxis(XboxAxes.Y)

    -- leftMaster:set(speed)
    -- leftFollower1:set(speed)

    gearSolenoid:set(rightStick:getButton(11))

    -- If the trigger on the left trigger is pressed, run the flywheel until it's released.
    -- At least, I think that's what this does, I don't know, I'm just guessing all of these functions.

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

    -- Holding the left joystick trigger, will run the flywheel, and if the left joystick trigger is pressed when the right joystick trigger is pressed, it will turn on the feeder.

    --intake piston 
    if not safeMode then
        if gamepad:getButtonPressed(XboxButtons.B) then 
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

--[[ No autonomous at Woodbury Days
function robot.autonomousInit()
    autoRoutine = coroutine.create(function()
        function getSpeed()
            return 0.75 * math.sin(3 * getTimeSeconds())
        end

        while not gamepad:getButtonPressed(XboxButtons.A) do
            robotDrive:arcadeDrive(getSpeed(), 0)
            coroutine.yield()
        end

        while not gamepad:getButtonPressed(XboxButtons.A) do
            robotDrive:arcadeDrive(0, getSpeed())
            coroutine.yield()
        end

        robotDrive:arcadeDrive(0, 0)
    end)
end

function robot.autonomousPeriodic()
    -- No autonomous at Woodbury Days
    return

    status, err = coroutine.resume(autoRoutine)
    print(status, err)
end
--]]
