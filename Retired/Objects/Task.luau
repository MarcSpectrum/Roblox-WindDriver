local tickPerSecond = 1
local connection = nil
local taskLists = {}

local self = {}

function self.initialize()
    self.Tick = 0
    self.startTime = nil
    self.PreTick = shared.Event.new()
    self.OnTick = shared.Event.new()
    self.PostTick = shared.Event.new()
end

function self:Start(startTime)
    if connection ~= nil then return false end
    self.Tick = 0
    self.startTime = startTime
    connection = game:GetService('RunService').Heartbeat:Connect(Loop)
    return true
end

function self:Stop()
    if connection == nil then return false end
    connection:Disconnect()
    connection = nil
    table.clear(taskLists)
    self.Tick = 0
    return true
end

function self:Wait(v)
    local scheduledTick = self.Tick + math.max(v, 1)
    local taskList = taskLists[scheduledTick]
    if taskList == nil then taskList = shared.LinkedList.new() ; taskLists[scheduledTick] = taskList end
    taskList:InsertBack({Thread = coroutine.running()})
    return coroutine.yield()
end

function self:Delay(v, func, ...)
    local scheduledTick = self.Tick + math.max(v, 1)
    local taskList = taskLists[scheduledTick]
    if taskList == nil then taskList = shared.LinkedList.new() ; taskLists[scheduledTick] = taskList end
    return taskList:InsertBack({Function = func, Parameter = {...}})
end

function Loop()
    local tick_current = math.round((workspace:GetServerTimeNow() - self.startTime) * tickPerSecond)
    if self.Tick >= tick_current then return end
    self.PreTick:Fire(self.Tick)
    while self.Tick < tick_current do
        self.Tick += 1
        self.OnTick:Fire(self.Tick)

        local taskList = taskLists[self.Tick]
        if taskList then
            local scheduledTask = taskList.Next
            while scheduledTask ~= taskList do
                if scheduledTask.Thread then
                    task.spawn(scheduledTask.Thread, self.Tick)
                elseif scheduledTask.Function then
                    shared.Threads:Spawn(scheduledTask.Function, table.unpack(scheduledTask.Parameter))
                end
                scheduledTask = scheduledTask.Next
            end
            taskLists[self.Tick] = nil
        end
    end
    self.PostTick:Fire(self.Tick)
end

return self