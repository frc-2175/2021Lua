require("intake")


safeMode = true

function robot.robotInit()
    leftMaster = TalonSRX:new(15) -- -making a motor !
    leftMaster:setInverted(CTREInvertType.None) --setting up, making it inverted

    leftFollower1 = VictorSPX:new(11)
    leftFollower1:follow(leftMaster)
    leftFollower1:setInverted(CTREInvertType.OpposeMaster)

    leftFollower2 = VictorSPX:new(10)
    leftFollower2:follow(leftMaster)
    leftFollower2:setInverted(CTREInvertType.OpposeMaster)

    rightMaster = TalonSRX:new(16)
    rightMaster:setInverted(CTREInvertType.None)

    rightFollower1 = VictorSPX:new(9)
    rightFollower1:follow(rightMaster)
    rightFollower1:setInverted(CTREInvertType.OpposeMaster)

    rightFollower2 = VictorSPX:new(8)
    rightFollower2:follow(rightMaster)
    rightFollower2:setInverted(CTREInvertType.OpposeMaster)

    robotDrive = DifferentialDrive:new(leftMaster, rightMaster) --DifferentialDrive manages all driving math
    
    leftStick = Joystick:new(0)
    rightStick = Joystick:new(1)
    gamepad = Joystick:new(2)
end
--teleop periodic : WHERE EVERTHING HAPPENS !!i!!!!!!!!!!!!!!!!!!!!!!!!!!!
function robot.teleopPeriodic()
   
    speedLimiter = -leftStick:getAxis(JoystickAxes.Throttle) -- Set the speedLimiter to the value of the knob thing on the joystick.
    turnLimiter = -rightStick:getAxis(JoystickAxes.Throttle) -- Set the turnLimiter to the value of the knob thing on the joystick.


    robotDrive:arcadeDrive(
        -leftStick:getAxis(JoystickAxes.Y) * speedLimiter,  -- multiplies speed in forward and backwards direction by "The value of the knob thing on the joystick."
        rightStick:getAxis(JoystickAxes.X) * turnLimiter
    )
    -- speed = -gamepad:getAxis(XboxAxes.Y)

    -- leftMaster:set(speed)
    -- leftFollower1:set(speed)

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
    status, err = coroutine.resume(autoRoutine)
    print(status, err)
end
