function NewPIDController(p, i, d)
    local p = {
        kp = p,
        ki = i,
        kd = d,
        integral = 0,
        previousError = nil,
        dt = 0,
        shouldRunIntegral = false,
        clear = function(self, time)
            self.dt = 0
            previousTime = time
            integral = 0
            previousError = nil
            shouldRunIntegral = false
        end,
        pid = function(self, input, setpoint, thresh)
            local threshold = thresh or 0
            local error = setpoint - input
            local p = error * self.kp
            local i = 0
            if shouldRunIntegral then
                if threshold == 0 or (input < (threshold + setpoint) and input > (setpoint - threshold)) then
                    integral = integral + dt * error
                else
                    integral = 0
                end
            else
                shouldRunIntegral = true
            end
            local d
            if previousError == nil or dt == 0 then
                d = 0
            else
                d = ((error - previousError) / dt) * kd
            end
            previousError = error
            return p + i + d
        end,
        updateTime = function(self, time)
            self.dt = time - previousTime
            previousTime = time
        end
    }

    return p
end
