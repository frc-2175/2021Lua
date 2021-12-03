function robot.robotInit()
    leftMotor = TalonSRX:new(1)
    rightMotor = TalonSRX:new(6)

    leftStick = Joystick:new(0)
    rightStick = Joystick:new(1)
    gamepad = Joystick:new(2)

    robotDrive = DifferentialDrive:new(leftMotor, rightMotor)
end

function robot.teleopPeriodic()
    robotDrive:arcadeDrive(-leftStick:getAxis(JoystickAxes.Y), rightStick:getAxis(JoystickAxes.X))
end

function robot.autonomousInit()

end

function robot.autonomousPeriodic()

end

function deadband(joystickVal)
    if joystickVal < 0.05 and joystickVal > -0.05 then
        return 0
    else
        return joystickVal
    end
end