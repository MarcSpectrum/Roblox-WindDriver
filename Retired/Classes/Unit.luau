local class = {}
class.__index = class

local wrkspc_Dump = workspace:WaitForChild('Dump')
local Dump_Units = wrkspc_Dump:WaitForChild('Units')

local unt_sprt = Instance.new('Part')
unt_sprt.Size = Vector3.one ; unt_sprt.Position = Vector3.new(0,100,0) ;
unt_sprt.Anchored = true ;
unt_sprt.CanCollide = false ; unt_sprt.CanQuery = false ; unt_sprt.CanTouch = false ;

function class.new(fltr :{})
    local self = setmetatable({}, class)
    for i, v in (shared.UnitMeta) do self[i] = fltr[i] or v end
    for i, v in (shared[self.PackageID] or {}) do self[i] = v end
    self['Spirit'] = unt_sprt:Clone()
    self['Spirit'].Parent = Dump_Units
    self['selfLink'] = shared.Mobs['List']:InsertBack({Value = self})
    self:Drive()
    return self
end

function class:Destroy()
    if not self['Link'] then return end
    self['Link']:Remove()
    self['Link'] = nil
    self['Spirit']:Destroy()
    self['Spirit'] = nil
    return true
end

function class:Drive(track :number)
    -- Trace, Track, TrackPercent
    local _grid = shared.Game.Blueprint.Grid
    local _trace = shared.Game.Traces[self['Trace'] or 1] ;
    self['Track'] = math.clamp((track or 2), 2, #_trace) ;
    self['TrackAlpha'] = 0
    local function Step(_,tick)
        print(self['Track'])
        self['TrackAlpha'] = math.clamp((self['TrackAlpha']+self['TrackRate']), 0, 10)
        local _tileA, _tileZ = _grid[_trace[self['Track']]].Tile, _grid[_trace[self['Track']-1]].Tile
        local _lerp = _tileA.CFrame:Lerp(_tileZ.CFrame, self['TrackAlpha']/10)
        self['Spirit']:PivotTo(_lerp)
        if self['TrackAlpha'] >= 10 then
            self['Track'] = math.clamp((self['Track']+1), 2, #_trace)
            self['TrackAlpha'] = 0
        end
    end
    shared.Task.OnTick:Connect(Step, {})
    shared.Task.OnTick:Connect(Step, {})
end

function class:Embark(track :number)
    local trace = shared.Game.Traces[self['Trace'] or 1] ;
    if not trace then return end ;
    if self.Connections['Tracing'] then self.Connections['Tracing']:Disconnect() ; self.Connections['Tracing'] = nil end ;
    self['Track'] = math.clamp((track or 2), 2, #trace) ;
    local Grid = shared.Game.Blueprint.Grid
    local function Step()
        local trck_strt, trck_end = trace[self['Track']-1], trace[self['Track']] ;
        trck_strt, trck_end = Grid[trck_strt].Tile.CFrame, Grid[trck_end].Tile.CFrame ;
        self['TrackPercent'] += self['TraceSpeed'] ;
        self['TrackPercent'] = math.clamp(self['TrackPercent'], .1, 1) ;
        self['Spirit']:PivotTo(trck_strt:Lerp(trck_end, self['TrackPercent']) + Vector3.new(0,3,0)) ;
        if self['TrackPercent'] < 1 then return end
        self['TrackPercent'] = 0 ;
        self['Track'] += 1 ;
        if not trace[self['Track']] then self.Connections['Tracing']:Disconnect() ; self.Connections['Tracing'] = nil end ;
    end
    self.Connections['Tracing'] = shared.Task.OnTick:Connect(Step) ;
end

function class:Launch(...)
end

return class