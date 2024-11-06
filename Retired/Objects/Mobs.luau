local self = {}

function self.initialize()
    self['List'] = shared.LinkedList.new()
end

function self.start()
    local function Aspas()
        if self['Debounce'] and self['Debounce'] < 2 then return end
        self['Debounce'] = (self['Debounce'] or 0)+1
        local unt = self['List'].Previous
        while unt ~= self['List'] do
            unt = unt.Previous
        end
        local unt_fltr = {}
        local unt_nw = self:Spawn(unt_fltr)
    end
    shared.Task.PostTick:Connect(Aspas)
end

function self:Spawn(fltr :{})
    local unt_nw = shared.Unit.new(fltr)
    return unt_nw
end

return self