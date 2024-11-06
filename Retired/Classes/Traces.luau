local class = {}
class.__index = class

function class.new(guide :{})
    local self = setmetatable({}, class)
    local avbl = shared.Game.Blueprint.Data.Path[true]
    for i, v in guide do
        local trc_nw = {}
        for i_trc = 2, #v, 1 do
            local a,z = v[i_trc-1], v[i_trc] ;
            local pth_fnd = shared.GridMath.PathFinding(a, z, avbl) ;
            table.remove(pth_fnd, #pth_fnd)
            for _, v3 in pth_fnd do table.insert(trc_nw, v3) end ;
        end ;
        self[i] = trc_nw
    end
    return self
end

return class