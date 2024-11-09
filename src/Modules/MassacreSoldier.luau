local isServer = game:GetService('RunService'):IsServer()
local Workspace = game:GetService('Workspace')

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
    local srvc_cntxtactn = game:GetService('ContextActionService')
    local srvc_run = game:GetService('RunService')

    srvc_cntnprvdr:PreloadAsync(srvc_rplctstrg:WaitForChild('Gadget'):GetChildren())
    local gdgt = srvc_rplctstrg:WaitForChild('Gadget')
    local gdgt_anims = gdgt:WaitForChild('Animations')
    local frwrdFX = gdgt:WaitForChild('ForwardFX')
    local trndFX = gdgt:WaitForChild('TornadoFX')
    local cnfttFX = gdgt:WaitForChild('ConfettiFX')
    local gdgt_bullet = gdgt:WaitForChild('Bullet')

    function self.initialize()
        local ply = game.Players.LocalPlayer
        local char = ply.Character
        local hum = char:WaitForChild('Humanoid')
        local mouse = ply:GetMouse()
        local controls = require(ply.PlayerScripts:WaitForChild('PlayerModule')):GetControls()

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

        --// Funcs_Core

        local _posting = nil
        local function _Pose(trck :AnimationTrack)
            if _posting then _posting:Stop() end
            if trck then
                _posting = hum.Animator:LoadAnimation(trck) ;
                _posting:Play() ;
                return _posting
            end
        end

        local function _PlayAnim(trck :AnimationTrack)
            for _, v in hum.Animator:GetPlayingAnimationTracks() do v:Stop() end
            if trck then
                self['animing'] = hum.Animator:LoadAnimation(trck) ;
                self['animing']:Play() ;
                return self['animing']
            end
        end

        --// Funcs_Sub
        local function _SpinTheBlade()
            local AAA1 = self['Gauntlet_Left'].AnimationController:LoadAnimation(gdgt_anims['Killer - Weapon - Spin'])
            local AAA2 = self['Gauntlet_Right'].AnimationController:LoadAnimation(gdgt_anims['Killer - Weapon - Spin'])
            AAA1.Looped = false
            AAA2.Looped = false
            AAA1:Play()
            AAA2:Play()
            self['Gauntlet_Left'].Cube.Attachment0.W1:Emit(1)
            self['Gauntlet_Right'].Cube.Attachment0.W1:Emit(1)
            self['Gauntlet_Left'].Cube.Attachment0.W2:Emit(1)
            self['Gauntlet_Right'].Cube.Attachment0.W2:Emit(1)
            return AAA1, AAA2
        end

        local _LoopSpinningBlade = {}
        _LoopSpinningBlade.__index = _LoopSpinningBlade
        function _LoopSpinningBlade.Connect()
            local clss_nw = setmetatable({}, _LoopSpinningBlade)
            clss_nw.AAA1 = self['Gauntlet_Left'].AnimationController:LoadAnimation(gdgt_anims['Killer - Weapon - Spin'])
            clss_nw.AAA2 = self['Gauntlet_Right'].AnimationController:LoadAnimation(gdgt_anims['Killer - Weapon - Spin'])
            clss_nw.AAA1.Looped = true
            clss_nw.AAA2.Looped = true
            clss_nw.AAA1:AdjustSpeed(2)
            clss_nw.AAA2:AdjustSpeed(2)
            clss_nw.AAA1:Play()
            clss_nw.AAA2:Play()

            local db = false
            local func = function()
                if db then return end
                db = true
                self['Gauntlet_Left'].Cube.Attachment0.W1:Emit(1)
                self['Gauntlet_Right'].Cube.Attachment0.W1:Emit(1)
                self['Gauntlet_Left'].Cube.Attachment0.W2:Emit(1)
                self['Gauntlet_Right'].Cube.Attachment0.W2:Emit(1)
                task.delay(.1, function()
                    db = false
                end)
            end
            clss_nw.CNCTN = srvc_run.RenderStepped:Connect(func)
            gdgt['Spin1']:Play()

            return clss_nw
        end
        function _LoopSpinningBlade:Disconnect()
            self.AAA1:Stop()
            self.AAA2:Stop()
            self.CNCTN:Disconnect()
            gdgt['Spin1']:Stop()
        end

        local _LoopCharacterLock = {}
        _LoopCharacterLock.__index = _LoopCharacterLock
        function _LoopCharacterLock.Connect(up)
            local clss_nw = setmetatable({}, _LoopCharacterLock)
            local cf_nw = char.HumanoidRootPart.CFrame + Vector3.new(0,up,0)
            clss_nw['func'] = function()
                local mouse_pos = mouse.Hit.Position
                local pivot_cf = CFrame.lookAt(
                    cf_nw.Position,
                    Vector3.new(mouse_pos.X, cf_nw.Position.Y, mouse_pos.Z)
                )
                char:PivotTo(pivot_cf)
                return pivot_cf
            end
            clss_nw['CNCTN'] = srvc_run.Heartbeat:Connect(clss_nw['func'])
            return clss_nw
        end
        function _LoopCharacterLock:Disconnect()
            self.CNCTN:Disconnect()
            return self['func']()
        end

        local _Blue = false
        local function _Switch()
            local v1,v2, v3
            local w101 = self['Gauntlet_Left'].Cube.Attachment0.W1
            local w102 = self['Gauntlet_Left'].Cube.Attachment0.W2
            local w201 = self['Gauntlet_Right'].Cube.Attachment0.W1
            local w202 = self['Gauntlet_Right'].Cube.Attachment0.W2
            if _Blue then
                v1 = ColorSequence.new(Color3.new(0,0,0))
                v2 = ColorSequence.new(Color3.new(255,255,255))
                v3 = Color3.fromRGB(255,255,255)
                w101.Brightness = 0
                w101.LightEmission = 0
                w201.Brightness = 0
                w201.LightEmission = 0
                _Blue = false
            else
                v1 = ColorSequence.new(Color3.new(0, 0.466666, 1))
                v2 = ColorSequence.new(Color3.new(0, 170, 255))
                v3 = Color3.fromRGB(85, 255, 255)
                w101.Brightness = 2
                w101.LightEmission = 1
                w201.Brightness = 2
                w201.LightEmission = 1
                _Blue = true
            end
            w101.Color = v1
            w201.Color = v1
            w102.Color = v2
            w202.Color = v2
            frwrdFX.Wind1.MainWind.Color = v2
            trndFX.Wind1.MainWind.Color = v2
            gdgt_bullet.Color = v3
            gdgt_bullet.Trail.Color = v2
            local cnfttFX_nw = cnfttFX.ParticleEmitter:Clone()
            cnfttFX_nw.Color = v2
            game:GetService('Debris'):AddItem(cnfttFX_nw, 2)
            cnfttFX_nw.Parent = char.HumanoidRootPart
            cnfttFX_nw:Emit(50)
            gdgt['Switch1'].PitchShiftSoundEffect.Octave = math.random(.1,2)
            gdgt['Switch1']:Play()
        end

        --// SetAnimations
        self['AnimState'] = 'Stand'
        self['_LoadAnim'] = function(objct)
            if objct then
                _PlayAnim(objct)
            else
                if self['AnimState'] == 'Moving' then
                    _Pose(gdgt_anims['Killer_Run'])
                else
                    _Pose(gdgt_anims['Killer_Idle'])
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

        --// ContextFunc
        local _ACT = {
            ['thread'] = nil ;
            ['key'] = '' ;
            ['tickID'] = '' ;
        }
        local function _Audit(ky :string)
            if _ACT['thread'] then
                if coroutine.status(_ACT['thread']) == 'suspended' then
                    if _ACT['key'] ~= ky then return false end
                    coroutine.resume(_ACT['thread'])
                    return false
                else
                    coroutine.close(_ACT['thread'])
                    _ACT['thread'] = nil
                    _ACT['key'] = ''
                    return true
                end
            else
                return true
            end
        end

        local function _Activate(ky :string, func, tck :number)
            _ACT['thread'] = coroutine.create(func)
            _ACT['key'] = ky
            coroutine.resume(_ACT['thread'])
            if tck and tck > 0 then
                local tckID_nw = workspace:GetServerTimeNow()
                _ACT['tickID'] = tckID_nw
                task.delay(tck, function()
                    if _ACT['tickID'] ~= tckID_nw then return end
                    while not _Audit(ky) do end
                end)
            end
        end

        local _Debounce = {
            ['tick'] = nil ;
            ['value'] = 0 ;
        }

        local function _Check()
            if not _Debounce['tick'] then return true end
            local tck = _Debounce['tick'] + _Debounce['value']
            if workspace:GetServerTimeNow() >= tck then
                _Debounce['tick'] = nil
                _Debounce['value'] = 0
                return true
            else
                return false
            end
        end

        local function _Set(v)
            v = v or 0
            _Debounce['tick'] = workspace:GetServerTimeNow()
            _Debounce['value'] = v
        end

        --// LoadContext
        local _NormalAttack = {
            ['Anims'] = {
                [1] = 'Killer_Normal1' ;
                [2] = 'Killer_Normal2' ;
                [3] = 'Killer_Normal3' ;
                [4] = 'Killer_Normal4' ;
                [5] = 'Killer_Normal5' ;
            } ;
            ['Key'] = nil ;
        }
        self['_Act_NormalAttack'] = function(actn, stte, objct)
            local key = objct.UserInputType.Name
            if stte.Name ~= 'Begin' then return end
            if _Audit(key) then
                if not _Check() then return end
                local func_nw = function()
                    controls:Disable()
                    _SpinTheBlade()
                    local a, b
                    repeat a, b = next(_NormalAttack['Anims'], _NormalAttack['Key']) ; _NormalAttack['Key'] = a
                    until b
                    if a >= 5 then _Switch() end
                    _PlayAnim(gdgt_anims[b])
                    gdgt['Slash1'].PitchShiftSoundEffect.Octave = math.random(.1,2)
                    gdgt['Slash1']:Play()
                    controls:Enable()
                    _Set(.5)
                end
                _Activate(key, func_nw, 0)
            end
        end

        self['_Act_Skill1'] = function(actn, stte, objct)
            local key = objct.KeyCode.Name
            if _Audit(key) then
                if not _Check() then return end
                if stte.Name ~= 'Begin' then return end
                local func_nw = function()
                    local chrctr_lck = _LoopCharacterLock.Connect(.5)
                    controls:Disable()
                    _PlayAnim(gdgt_anims['Killer_Skill1_Hold'])
                    coroutine.yield()
                    local cf_final = chrctr_lck:Disconnect()
                    gdgt['WIndDash1'].PitchShiftSoundEffect.Octave = math.random(.1,2)
                    gdgt['WIndDash1']:Play()
                    local trck = _PlayAnim(gdgt_anims['Killer_Skill1_Release'])
                    trck:GetMarkerReachedSignal('Cast'):Once(function()
                        local frwrdFX_nw = frwrdFX.Wind1:Clone()
                        game:GetService('Debris'):AddItem(frwrdFX_nw, 2)
                        frwrdFX_nw.Parent = char.HumanoidRootPart
                        frwrdFX_nw.MainWind:Emit(7)
                        char.HumanoidRootPart.CFrame += (cf_final.LookVector*25)
                    end)
                    trck.Ended:Once(function()
                        controls:Enable()
                    end)
                    _Set(1)
                end
                _Activate(key, func_nw, 5)
            end
        end

        self['_Act_Skill2'] = function(actn, stte, objct)
            local key = objct.KeyCode.Name
            if _Audit(key) then
                if not _Check() then return end
                if stte.Name ~= 'Begin' then return end
                local func_nw = function()
                    local spnng = _LoopSpinningBlade.Connect()
                    _PlayAnim(gdgt_anims['Killer_Skill2_Hold'])
                    hum.WalkSpeed *= 3
                    coroutine.yield()
                    hum.WalkSpeed /= 3
                    _PlayAnim(nil)
                    spnng:Disconnect()
                    self['_LoadAnim']()
                    _Set(1)
                end
                _Activate(key, func_nw, 5)
            end
        end

        self['_Act_Skill3'] = function(actn, stte, objct)
            local key = objct.KeyCode.Name
            if _Audit(key) then
                if not _Check() then return end
                if stte.Name ~= 'Begin' then return end
                local func_nw = function()
                    local chrctr_lck = _LoopCharacterLock.Connect(1.5)
                    local spnng = _LoopSpinningBlade.Connect()
                    controls:Disable()
                    _PlayAnim(gdgt_anims['Skill302_Hold'])
                    coroutine.yield()
                    local trck = _PlayAnim(gdgt_anims['Skill302_Release'])
                    trck:GetMarkerReachedSignal('Cast'):Once(function()
                        spnng:Disconnect()
                        local cf_final = chrctr_lck:Disconnect()

                        local prjctl_bllt = gdgt_bullet:Clone()
                        prjctl_bllt.Parent = workspace.Terrain
                        prjctl_bllt.CFrame = cf_final
                        local prjctl_cnt = 0
                        local prjctl_cnnctn
                        gdgt['Shoot1'].PitchShiftSoundEffect.Octave = math.random(.1,2)
                        gdgt['Shoot1']:Play()
                        local function fire()
                            if prjctl_cnt >= 30 then
                                local prjctl_cf = prjctl_bllt.CFrame
                                prjctl_bllt:Destroy()
                                prjctl_cnnctn:Disconnect()
                                local trndFX_nw = trndFX:Clone()
                                game:GetService('Debris'):AddItem(trndFX_nw, 5)
                                trndFX_nw:PivotTo(prjctl_cf)
                                trndFX_nw.Parent = Workspace.Terrain
                                trndFX_nw.Wind1.MainWind.Enabled = true
                                gdgt['Tornado1'].PitchShiftSoundEffect.Octave = math.random(.1,2)
                                gdgt['Tornado1']:Play()
                                task.delay(3, function()
                                    trndFX_nw.Wind1.MainWind.Enabled = false
                                end)
                            end
                            prjctl_bllt.CFrame += (cf_final.LookVector*1)
                            prjctl_cnt += 1
                        end
                        prjctl_cnnctn = srvc_run.Heartbeat:Connect(fire)
                    end)
                    trck.Ended:Once(function()
                        controls:Enable()
                    end)
                    _Set(1)
                end
                _Activate(key, func_nw, 5)
            end
        end

        self['_Act_Skill4'] = function(actn, stte, objct)
            local key = objct.KeyCode.Name
            if _Audit(key) then
                if not _Check() then return end
                if stte.Name ~= 'Begin' then return end
                local func_nw = function()
                    local chrctr_lck = _LoopCharacterLock.Connect(1.5)
                    controls:Disable()
                    local spnng = _LoopSpinningBlade.Connect()
                    _PlayAnim(gdgt_anims['Killer_Skill4_Hold'])
                    coroutine.yield()
                    local trck = _PlayAnim(gdgt_anims['Killer_Skill4_Release'])
                    trck:GetMarkerReachedSignal('Cast'):Once(function()
                        _SpinTheBlade()
                        gdgt['Tornado1'].PitchShiftSoundEffect.Octave = math.random(.1,2)
                        gdgt['Tornado1']:Play()
                        local spot = char['HumanoidRootPart'].CFrame
                        spot += (spot.LookVector*7)
                        local trndFX_nw = trndFX:Clone()
                        game:GetService('Debris'):AddItem(trndFX_nw, 5)
                        trndFX_nw:PivotTo(spot)
                        trndFX_nw.Parent = workspace.Terrain
                        trndFX_nw.Wind1.MainWind.Enabled = true
                    end)
                    spnng:Disconnect()
                    chrctr_lck:Disconnect()
                    controls:Enable()
                    _Set(1)
                end
                _Activate(key, func_nw, 5)
            end
        end
    end
    
    function self.start()
        srvc_cntxtactn:BindAction(
            '_Act_NormalAttack',
            self['_Act_NormalAttack'],
            false,
            Enum.UserInputType.MouseButton1
        )

        srvc_cntxtactn:BindAction(
            '_Act_Skill1',
            self['_Act_Skill1'],
            false,
            Enum.KeyCode.Z
        )
        
        srvc_cntxtactn:BindAction(
            '_Act_Skill2',
            self['_Act_Skill2'],
            false,
            Enum.KeyCode.X
        )

        srvc_cntxtactn:BindAction(
            '_Act_Skill3',
            self['_Act_Skill3'],
            false,
            Enum.KeyCode.C
        )

        srvc_cntxtactn:BindAction(
            '_Act_Skill4',
            self['_Act_Skill4'],
            false,
            Enum.KeyCode.V
        )
    end
    
    return self
end