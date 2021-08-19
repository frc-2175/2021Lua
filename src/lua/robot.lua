require("intake")

function robot.robotInit()
    leftMaster = TalonFX:new(15)
    leftMaster:setInverted(CTRETalonFXInvertType.Clockwise)

    leftFollower1 = VictorSPX:new(11)
    leftFollower1:follow(leftMaster)
    leftFollower1:setInverted(CTREInvertType.OpposeMaster)

    leftFollower2 = VictorSPX:new(10)
    leftFollower2:follow(leftMaster)
    leftFollower2:setInverted(CTREInvertType.OpposeMaster)

    rightMaster = TalonFX:new(16)
    rightMaster:setInverted(CTRETalonFXInvertType.Clockwise)

    rightFollower1 = VictorSPX:new(9)
    rightFollower1:follow(rightMaster)
    rightFollower1:setInverted(CTREInvertType.OpposeMaster)

    rightFollower2 = VictorSPX:new(8)
    rightFollower2:follow(rightMaster)
    rightFollower2:setInverted(CTREInvertType.OpposeMaster)

    robotDrive = DifferentialDrive:new(leftMaster, rightMaster)
    
    gamepad = Joystick:new(2)
end

function robot.teleopPeriodic()
    robotDrive:arcadeDrive(
        -gamepad:getAxis(XboxAxes.Y),
        gamepad:getAxis(XboxAxes.RightStickX)
    )

    -- speed = -gamepad:getAxis(XboxAxes.Y)

    -- leftMaster:set(speed)
    -- leftFollower1:set(speed)

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
