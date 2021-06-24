local intakePiston = DoubleSolenoid:new(1, 0)

function intakePutOut()
    intakePiston:set(DoubleSolenoidValue.Forward)
end
