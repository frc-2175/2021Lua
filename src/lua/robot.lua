function robot.robotInit()
    leftMotor = PWMSparkMax:new(2)
    rightMotor = PWMSparkMax:new(3)
    stick = Joystick:new(0)
    robotDrive = DifferentialDrive:new(leftMotor, rightMotor)
end

function robot.teleopPeriodic()
    robotDrive:arcadeDrive(
        stick:getY(),
        stick:getX()
    )
end
