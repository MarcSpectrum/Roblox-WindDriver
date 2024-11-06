local isServer = game:GetService('RunService'):IsServer()

if isServer then
    local self = {}

    function self.initialize()
    end
    
    function self.start()
    end
    
    return self
else
    local self = {}

    function self.initialize()
    end
    
    function self.start()
    end
    
    return self
end