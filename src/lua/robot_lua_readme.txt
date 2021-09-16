    -- speed = -gamepad:getAxis(XboxAxes.Y)

    -- leftMaster:set(speed)
    -- leftFollower1:set(speed)


    -- Set up one shooter motor. The two motor IDs are 21 and 22.
    -- I'm not sure what the "5" in this means, but I'm going to assume it's supposed to be the motor ID, if not, it should be fairly easy to hopefully correct.
    -- I don't know the setup of the motors on the rest of the robot so the most I can write is the code to spin up and down the flywheel.
    -- Wish I could write some more comprehensive code, but I just don't have the info.
    -- Ex. code: shooter = SparkMax:new(5, SparkMaxMotorType.Brushless) -- the motors we use, NEOs, are brushless
    -- Ex. code: shooter:restoreFactoryDefaults() -- the controllers can get stuck on old, saved config if we don't do this on startup
    -- Ex. code: shooter:setIdleMode(SparkMaxIdleMode.Coast) -- it is really important to let the shooter wheels gently coast to a stop

    --[[ Here Lies the Code for Motor 22
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
    --]]




    

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
