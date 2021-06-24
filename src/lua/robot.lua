require("intake")

function robot.robotInit()
    leftMotor = TalonFX:new(1)
    rightMotor = TalonSRX:new(2)
    gamepad = Joystick:new(0)
    robotDrive = DifferentialDrive:new(leftMotor, rightMotor)
end

function robot.teleopPeriodic()
    robotDrive:arcadeDrive(
        -gamepad:getAxis(XboxAxes.Y),
        gamepad:getAxis(XboxAxes.RightStickX)
    )

    if gamepad:getButtonPressed(XboxButtons.B) then
        intakePutOut()
    end
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
