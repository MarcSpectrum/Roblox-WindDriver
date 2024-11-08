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
    local srvc_cntxtactn = game:GetService('ContextActionService')
    local srvc_run = game:GetService('RunService')

    srvc_cntnprvdr:PreloadAsync(srvc_rplctstrg:WaitForChild('Gadget'):GetChildren())
    local gdgt = srvc_rplctstrg:WaitForChild('Gadget')
    local gdgt_anims = gdgt:WaitForChild('Animations')
    local frwrdFX = gdgt:WaitForChild('ForwardFX')
    local dwnFX = gdgt:WaitForChild('DownFX')
    local trndFX = gdgt:WaitForChild('TornadoFX')

    function self.initialize()
        local ply = game.Players.LocalPlayer
        local char = ply.Character
        local hum = char:WaitForChild('Humanoid')
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

            return clss_nw
        end
        function _LoopSpinningBlade:Disconnect()
            self.AAA1:Stop()
            self.AAA2:Stop()
            self.CNCTN:Disconnect()
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
                    _PlayAnim(gdgt_anims[b])
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
                    local frwrdFX_nw = frwrdFX.Wind1:Clone()
                    game:GetService('Debris'):AddItem(frwrdFX_nw, 2)
                    controls:Disable()
                    _PlayAnim(gdgt_anims['Killer_Skill1_Hold'])
                    coroutine.yield()
                    local trck = _PlayAnim(gdgt_anims['Killer_Skill1_Release'])
                    trck:GetMarkerReachedSignal('Cast'):Once(function()
                        frwrdFX_nw.Parent = char.HumanoidRootPart
                        frwrdFX_nw.MainWind:Emit(7)
                    end)
                    controls:Enable()
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
                    hum.WalkSpeed *= 2
                    coroutine.yield()
                    hum.WalkSpeed /= 2
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
                    local dwnFX_nwL = dwnFX.Wind1:Clone()
                    local dwnFX_nwR = dwnFX.Wind1:Clone()
                    game:GetService('Debris'):AddItem(dwnFX_nwL, 3)
                    game:GetService('Debris'):AddItem(dwnFX_nwR, 3)
                    dwnFX_nwL.Parent = char['Left Arm']
                    dwnFX_nwR.Parent = char['Right Arm']
                    local spnng = _LoopSpinningBlade.Connect()
                    controls:Disable()
                    local trck = _PlayAnim(gdgt_anims['Killer_Skill3_Release'])
                    trck:GetMarkerReachedSignal('Cast'):Once(function()
                        dwnFX_nwL.CFrame *= CFrame.Angles(0,0,-math.rad(90))
                        dwnFX_nwR.CFrame *= CFrame.Angles(0,0,math.rad(90))
                        dwnFX_nwL.MainWind:Emit(25)
                        dwnFX_nwR.MainWind:Emit(25)
                        spnng:Disconnect()
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
                    local trndFX_nw = trndFX:Clone()
                    game:GetService('Debris'):AddItem(trndFX_nw, 5)
                    controls:Disable()
                    local spnng = _LoopSpinningBlade.Connect()
                    _PlayAnim(gdgt_anims['Killer_Skill4_Hold'])
                    coroutine.yield()
                    local trck = _PlayAnim(gdgt_anims['Killer_Skill4_Release'])
                    trck:GetMarkerReachedSignal('Cast'):Once(function()
                        _SpinTheBlade()
                        local spot = char['HumanoidRootPart'].CFrame
                        spot += (spot.LookVector*7)
                        trndFX_nw:PivotTo(spot)
                        trndFX_nw.Parent = workspace.Terrain
                        trndFX_nw.Wind1.MainWind.Enabled = true
                    end)
                    spnng:Disconnect()
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