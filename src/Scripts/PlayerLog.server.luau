local srvc_plyr = game:GetService('Players')

local ModulesLoader_Client = script.Parent:WaitForChild('ModulesLoader_Client')

srvc_plyr.PlayerAdded:Connect(function(ply)
    ply.CharacterAppearanceLoaded:Connect(function()
        local scrpt_nw = ModulesLoader_Client:Clone()
        scrpt_nw.Parent = ply.Backpack
        scrpt_nw.Enabled = true
    end)
end)