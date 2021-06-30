require("intake")

function robot.robotInit()
    leftMotor = TalonSRX:new(1)
    rightMotor = TalonSRX:new(2)
    gamepad = Joystick:new(0)
    robotDrive = DifferentialDrive:new(leftMotor, rightMotor)
end

function robot.teleopPeriodic()
    robotDrive:arcadeDrive(
        -gamepad:getAxis(XboxAxes.Y),
        gamepad:getAxis(XboxAxes.RightStickX)
    )

    --intake piston 
    if gamepad:getButtonPressed(XboxButtons.B) then 
        intakePutOut() 
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
