function robot.robotInit()
    leftMotor = PWMSparkMax:new(2)
    rightMotor = PWMSparkMax:new(3)
    gamepad = Joystick:new(0)
    robotDrive = DifferentialDrive:new(leftMotor, rightMotor)
end

function robot.teleopPeriodic()
    robotDrive:arcadeDrive(
        gamepad:getY(),
        gamepad:getX()
    )
end

function robot.autonomousInit()
    autoRoutine = coroutine.create(function()
        while not gamepad:getButtonPressed(XBOX_A) do
            robotDrive:arcadeDrive(math.sin(getTimeSeconds()), 0)
            coroutine.yield()
        end

        while not gamepad:getButtonPressed(XBOX_A) do
            robotDrive:arcadeDrive(0, math.sin(getTimeSeconds()))
            coroutine.yield()
        end

        robotDrive:arcadeDrive(0, 0)
    end)
end

function robot.autonomousPeriodic()
    status, err = coroutine.resume(autoRoutine)
    print(status, err)
end
