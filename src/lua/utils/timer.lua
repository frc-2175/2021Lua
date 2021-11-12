require("wpilib.time")

Timer = {}

function Timer:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Timer:start()
    self.startTime = getTimeSeconds()
end

function Timer:getElapsedTimeSeconds()
    local elapsed = 0
    if self.startTime then
        elapsed = getTimeSeconds() - self.startTime
    end
    return elapsed
end
