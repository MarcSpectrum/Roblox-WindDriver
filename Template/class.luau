local isServer = game:GetService('RunService'):IsServer()

if isServer then
    local class = {}
    class.__index = class

    function class.new()
        local self = setmetatable({}, class)
        return self
    end

    return class
else
    local class = {}
    class.__index = class

    function class.new()
        local self = setmetatable({}, class)
        return self
    end
    
    return class
end