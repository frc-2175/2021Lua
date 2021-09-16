function NewTeleopCoroutine(coroutineFunc)
    local t = {
        coroutineFunc = coroutineFunc,
        coroutine = nil,
        wasRunning = false,
        runWhile = function(self, running)
            if running then
                if not self.wasRunning then
                    self.coroutine = coroutine.create(self.coroutineFunc)
                end
                if coroutine.status(self.coroutine) ~= "dead" then
                    local status, err = coroutine.resume(self.coroutine)
                    if status == false then
                        -- TODO: Better logging than this?
                        print(err)
                    end
                end
            end
            self.wasRunning = running
            return running
        end,
    }
    return t
end