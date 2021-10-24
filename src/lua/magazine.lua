local magazineMotor = TalonSRX:new(7)
local otherMagazineMotor = TalonSRX:new(6)

otherMagazineMotor:setInverted(CTREInvertType.InvertMotorOutput);
magazineMotor:setInverted(CTREInvertType.InvertMotorOutput);


-- ✩  ✩
function magazineRollIn() 
    magazineMotor:set(0.87)
    otherMagazineMotor:set(0.87)
end

function stopMagazine() 
    magazineMotor:set(0)
    otherMagazineMotor:set(0)
end

--- ✩ Actually just sets speed of magazine motor ✩
---@param speed number
function setMagazineMotor(speed) 
    magazineMotor:set(speed)
    otherMagazineMotor:set(speed)
end

function magazineRollOut() 
    magazineMotor:set(-1)
    otherMagazineMotor:set(-1)
end
