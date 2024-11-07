local modules = game:GetService('ReplicatedStorage'):WaitForChild('Modules')

local ply = game.Players.LocalPlayer
local char = ply.Character or ply.CharacterAppearanceLoaded:Wait()

for _, dscntdnt in modules:GetDescendants() do
    if dscntdnt.ClassName == 'ModuleScript' then shared[dscntdnt.Name] = require(dscntdnt) end
end

for _, mdl in shared do if type(mdl.initialize) == 'function' then mdl.initialize() end end
for _, mdl in shared do if type(mdl.start) == 'function' then task.defer(mdl.start) end end