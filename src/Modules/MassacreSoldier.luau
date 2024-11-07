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

    local srvc_rplctstrg = game:GetService('ReplicatedStorage')
    local srvc_cntnprvdr = game:GetService('ContentProvider')

    srvc_cntnprvdr:PreloadAsync(srvc_rplctstrg:WaitForChild('Gadget'):GetChildren())
    local gdgt = srvc_rplctstrg:WaitForChild('Gadget')
    local gdgt_anims = gdgt:WaitForChild('Animations')

    function self.initialize()
        local ply = game.Players.LocalPlayer
        local char = ply.Character
        local hum = char:WaitForChild('Humanoid')

        --// Funcs
        local function _PlayAnim(trck :AnimationTrack)
            for _, v in hum.Animator:GetPlayingAnimationTracks() do v:Stop() end
            if trck then
                self['animing'] = hum.Animator:LoadAnimation(trck) ;
                self['animing']:Play() ;
                return self['animing']
            end
        end

        --// LoadWeapon
        self['Gauntlet_Left'] = gdgt:WaitForChild('Gauntlet_Left'):Clone()
        self['Gauntlet_Right'] = gdgt:WaitForChild('Gauntlet_Right'):Clone()
        self['Gauntlet_Left'].WeldConstraint.Part0 = char['Left Arm']
        self['Gauntlet_Left'].WeldConstraint.Part1 = self['Gauntlet_Left'].PrimaryPart
        self['Gauntlet_Right'].WeldConstraint.Part0 = char['Right Arm']
        self['Gauntlet_Right'].WeldConstraint.Part1 = self['Gauntlet_Right'].PrimaryPart
        self['Gauntlet_Left']:PivotTo(char['Left Arm'].LeftGripAttachment.WorldCFrame)
        self['Gauntlet_Right']:PivotTo(char['Right Arm'].RightGripAttachment.WorldCFrame*CFrame.Angles(0,math.rad(180),0))
        self['Gauntlet_Left'].Parent = char
        self['Gauntlet_Right'].Parent = char

        --// SetAnimations
        self['AnimState'] = 'Stand'
        self['_LoadAnim'] = function(objct)
            if objct then
                _PlayAnim(objct)
            else
                if self['AnimState'] == 'Moving' then
                    _PlayAnim(gdgt_anims['Killer_Run'])
                else
                    _PlayAnim(gdgt_anims['Killer_Idle'])
                end
            end
        end
        hum:GetPropertyChangedSignal('MoveDirection'):Connect(function()
            local state_nw = nil
            if hum.MoveDirection.Magnitude > 0 then state_nw = 'Moving' ;
            else state_nw = 'Stand' ;
            end
            if self['AnimState'] == state_nw then return end
            self['AnimState'] = state_nw
            self['_LoadAnim']()
        end)
        self['_LoadAnim']()

        local AAA1 = self['Gauntlet_Left'].AnimationController:LoadAnimation(gdgt_anims['Killer - Weapon - Spin'])
        local AAA2 = self['Gauntlet_Right'].AnimationController:LoadAnimation(gdgt_anims['Killer - Weapon - Spin'])
        AAA1.Looped = true
        AAA2.Looped = true
        AAA1:Play()
        AAA2:Play()
        AAA1.DidLoop:Connect(function()
            self['Gauntlet_Left'].Cube.Attachment0.W1:Emit(1)
            self['Gauntlet_Right'].Cube.Attachment0.W1:Emit(1)
            self['Gauntlet_Left'].Cube.Attachment0.W2:Emit(1)
            self['Gauntlet_Right'].Cube.Attachment0.W2:Emit(1)
        end)

        --// LoadContext
    end
    
    function self.start()
    end
    
    return self
end