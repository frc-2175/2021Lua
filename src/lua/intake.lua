local intakePiston = DoubleSolenoid:new(1, 0)
local intakeMotor = VictorSPX:new(1)
intakeMotor:setInverted(CTREInvertType.InvertMotorOutput)

--rolls intake in at full in

function intakeRollIn()
    intakeMotor:set(-.5)
end

function stopIntake()
    intakeMotor:set(0)
end

function toggleIntake()
    if( intakePiston:get() == DoubleSolenoidValue.Forward) then
        intakePiston:set(DoubleSolenoidValue.Reverse)
    else
        intakePiston:set(DoubleSolenoidValue.Forward)
    end
end

--rolls intake out at full speed

function intakeRollOut()
    intakeMotor:set(0.5)
end

--set intake position out (down)

function intakePutOut()
    intakePiston:set(DoubleSolenoidValue.Forward)
end

--sets intake piston in (up)

function intakePutIn()
    intakePiston:set(DoubleSolenoidValue.Reverse)
end