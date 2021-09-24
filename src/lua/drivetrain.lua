local rampTable = {}
rampTable.__index = rampTable

function NewRamp()
    local r = {
        currentSpeed = 0,
        maxAccel = 0.2,
        maxDeccel = 0.1,
    }
    setmetatable(r, rampTable)
    return r
end

function doGrossRampStuff(curr, targ, accel, deccel)
    if curr - targ > deccel then
        curr = curr - deccel
    elseif curr - targ < accel then
        curr = curr + accel
    else
        curr = targ
    end
    return curr
end

function rampTable:Ramp(targetSpeed)
    local outSpeed
    local speedDiff = self.currentSpeed - targetSpeed
    if self.currentSpeed < 0 then
        outSpeed = -doGrossRampStuff(-self.currentSpeed, -targetSpeed, self.maxAccel, self.maxDeccel)
    else
        outSpeed = doGrossRampStuff(self.currentSpeed, targetSpeed, self.maxAccel, self.maxDeccel)
    end
    self.currentSpeed = outSpeed
    return outSpeed
end