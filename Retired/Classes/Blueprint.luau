local class = {}
class.__index = class

local Data_Fltr = {'Stand', 'Path', 'SurfaceLevel'}

function class.new(Grid :Model, Grid_Fltr :{})
    local self = setmetatable({}, class)
    self['Grid'] = {}
    for _, v in Grid:GetChildren() do
        self['Grid'][v.Name] = {
            Tile = v ,
            Position = v.Position ,
            Stand = false ,
            Path = false ,
            SurfaceLevel = 'Ground' ,
        } ;
    end ;
    for t,_ in self['Grid'] do
        for i, v in shared.GridMath.GetClose4Tiles(t) do
            if not self['Grid'][v] then continue end
            self['Grid'][t][i] = v ;
        end ;
    end ;
    for i, t1 in Grid_Fltr do
        for v, t2 in t1 do
            for tl,_ in t2 do
                self['Grid'][tl][i] = v ;
            end ;
        end ;
    end ;

    self['Data'] = {}
    for _, i in Data_Fltr do self['Data'][i] = {} end ;
    for tl, t in self['Grid'] do
        for _, i in Data_Fltr do
            local v = t[i]
            if not v then continue end
            if not self['Data'][i][v] then self['Data'][i][v] = {} end
            self['Data'][i][v][tl] = true
        end
    end
    return self
end

return class