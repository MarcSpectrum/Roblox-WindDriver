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

    local srvc_run = game:GetService('RunService')
    local srvc_uis = game:GetService('UserInputService')

    function self.initialize()
        local ply = game.Players.LocalPlayer
        local char = ply.Character
        local hum = char:WaitForChild("Humanoid")
        local root = hum.RootPart 
        local mouse = ply:GetMouse()
        mouse.Icon = "http://www.roblox.com/asset/?id=120542387673045"
        
        self['shiftLock'] = function(active)
            if active then		
                hum.CameraOffset = Vector3.new(1.75,0,0) -- I assume this is about the right camera offset.
                hum.AutoRotate = false --Disable the automatic rotation since we are the ones setting it.
        
                srvc_run:BindToRenderStep("ShiftLock", Enum.RenderPriority.Character.Value, function()
                    srvc_uis.MouseBehavior = Enum.MouseBehavior.LockCenter --Set the mouse to center every frame.
        
                    local _, y = workspace.CurrentCamera.CFrame.Rotation:ToEulerAnglesYXZ() --Get the angles of the camera
                    root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0,y,0) --Set the root part to the camera's rotation
                end) 
            else
                hum.AutoRotate = true --Let the humanoid handle the camera rotations again.
                hum.CameraOffset = Vector3.new(0,0,0) --Move the camera back to normal.
                srvc_run:UnbindFromRenderStep("ShiftLock") -- Allow mouse to move freely.
                srvc_uis.MouseBehavior = Enum.MouseBehavior.Default -- Let the mouse move freely
            end
        end
    end
    
    function self.start()
        self['shiftLock'](true)
    end
    
    return self
end