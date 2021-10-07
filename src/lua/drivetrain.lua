require("utils.math")

local rampTable = {}
rampTable.__index = rampTable

function NewRamp(timeToMax, timeToStop)
    local r = {
        currentSpeed = 0,
        maxAccel = 1 / (50 * timeToMax),
        maxDecel = 1 / (50 * timeToStop)
    }
    setmetatable(r, rampTable)
    return r
end

function DoGrossRampStuff(curr, targ, accel, decel)
    if curr == 0 or (curr > 0 and targ > curr) or (curr < 0 and targ < curr) then
        -- accelerating
        change = math.min(math.abs(curr - targ), accel) * sign(targ - curr)
        curr = curr + change
    elseif (curr > 0 and targ < curr) or (curr < 0 and targ > curr) then
        -- decelerating
        change = math.min(math.abs(curr - targ), decel) * sign(targ - curr)
        curr = curr + change
    end

    return curr
end

function rampTable:Ramp(targetSpeed)
    self.currentSpeed = DoGrossRampStuff(self.currentSpeed, targetSpeed, self.maxAccel, self.maxDecel)
    return self.currentSpeed
end
