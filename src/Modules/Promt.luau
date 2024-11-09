local isServer = game:GetService('RunService'):IsServer()

if isServer then
    local self = {}

    local frwrdFX = workspace:WaitForChild('Dummy'):WaitForChild('ForwardFX')
    local dwnFX = workspace:WaitForChild('Dummy'):WaitForChild('DownFX')
    local trndFX = workspace:WaitForChild('Dummy'):WaitForChild('TornadoFX')

    function self.initialize()
        self['Promt'] = workspace:WaitForChild('Part'):WaitForChild('ProximityPrompt')
        self['Anims'] = game:GetService('ServerStorage'):WaitForChild('Killer_Animations'):GetChildren()
        self['Dummy'] = workspace:WaitForChild('Dummy'):WaitForChild('R6'):WaitForChild('Humanoid'):WaitForChild('Animator')

        self['101'] = workspace:WaitForChild('Dummy'):WaitForChild('101')
        self['102'] = workspace:WaitForChild('Dummy'):WaitForChild('102')

        self['current'] = 1
        self['vers'] = 0

        self['animing'] = nil
        local function _PlayAnim(trck :AnimationTrack)
            if self['animing'] then self['animing']:Stop() ; self['animing'] = nil end
            if trck then
                self['animing'] = self['Dummy']:LoadAnimation(trck) ;
                self['animing']:Play() ;
                return self['animing']
            end
        end

        self['func_atk1'] = function()
            self['102'].HingeConstraint.LimitsEnabled = false
            local vers = tick()
            self['vers'] = vers
            task.delay(.1, function()
                if self['vers'] ~= vers then return end
                self['102'].HingeConstraint.LimitsEnabled = true
            end)
            _PlayAnim(game.ServerStorage.Killer_Animations['Killer_Normal1'])
            self['102'].Cube.Attachment0.W1:Emit(1)
            self['102'].Cube.Attachment0.W2:Emit(1)
        end

        self['func_atk2'] = function()
            self['101'].HingeConstraint.LimitsEnabled = false
            local vers = tick()
            self['vers'] = vers
            task.delay(.1, function()
                if self['vers'] ~= vers then return end
                self['101'].HingeConstraint.LimitsEnabled = true
            end)
            _PlayAnim(game.ServerStorage.Killer_Animations['Killer_Normal2'])
            self['101'].Cube.Attachment0.W1:Emit(1)
            self['101'].Cube.Attachment0.W2:Emit(1)
        end

        self['func_atk3'] = function()
            self['102'].HingeConstraint.LimitsEnabled = false
            local vers = tick()
            self['vers'] = vers
            task.delay(.1, function()
                if self['vers'] ~= vers then return end
                self['102'].HingeConstraint.LimitsEnabled = true
            end)
            _PlayAnim(game.ServerStorage.Killer_Animations['Killer_Normal3'])
            self['102'].Cube.Attachment0.W1:Emit(1)
            self['102'].Cube.Attachment0.W2:Emit(1)
        end

        self['func_atk4'] = function()
            self['101'].HingeConstraint.LimitsEnabled = false
            local vers = tick()
            self['vers'] = vers
            task.delay(.1, function()
                if self['vers'] ~= vers then return end
                self['101'].HingeConstraint.LimitsEnabled = true
            end)
            _PlayAnim(game.ServerStorage.Killer_Animations['Killer_Normal4'])
            self['101'].Cube.Attachment0.W1:Emit(1)
            self['101'].Cube.Attachment0.W2:Emit(1)
        end

        self['func_atk5'] = function()
            _PlayAnim(game.ServerStorage.Killer_Animations['Killer_Normal5'])
        end

        self['func_skill1'] = function()
            _PlayAnim(game.ServerStorage.Killer_Animations['Killer_Skill1_Hold'])
            local frwrdFX_nw = frwrdFX.Wind1:Clone()
            game:GetService('Debris'):AddItem(frwrdFX_nw, 2)
            coroutine.yield()
            local trck = _PlayAnim(game.ServerStorage.Killer_Animations['Killer_Skill1_Release'])
            trck:GetMarkerReachedSignal('Cast'):Once(function()
                frwrdFX_nw.Parent = workspace.Dummy.R6.HumanoidRootPart
                frwrdFX_nw.MainWind:Emit(7)
            end)
        end

        self['func_skill2'] = function()
            _PlayAnim(game.ServerStorage.Killer_Animations['Killer_Skill2_Hold'])
            self['101'].HingeConstraint.LimitsEnabled = false
            self['102'].HingeConstraint.LimitsEnabled = false
            self['101'].Cube.Attachment0.W1.Enabled = true
            self['101'].Cube.Attachment0.W2.Enabled = true
            self['102'].Cube.Attachment0.W1.Enabled = true
            self['102'].Cube.Attachment0.W2.Enabled = true
            coroutine.yield()
            self['101'].HingeConstraint.LimitsEnabled = true
            self['102'].HingeConstraint.LimitsEnabled = true
            self['101'].Cube.Attachment0.W1.Enabled = false
            self['101'].Cube.Attachment0.W2.Enabled = false
            self['102'].Cube.Attachment0.W1.Enabled = false
            self['102'].Cube.Attachment0.W2.Enabled = false
        end

        self['func_skill3'] = function()
            local dwnFX_nwL = dwnFX.Wind1:Clone()
            local dwnFX_nwR = dwnFX.Wind1:Clone()
            game:GetService('Debris'):AddItem(dwnFX_nwL, 3)
            game:GetService('Debris'):AddItem(dwnFX_nwR, 3)
            dwnFX_nwL.Parent = workspace.Dummy.R6['Left Arm']
            dwnFX_nwR.Parent = workspace.Dummy.R6['Right Arm']
            local trck = _PlayAnim(game.ServerStorage.Killer_Animations['Killer_Skill3_Release'])
            trck:GetMarkerReachedSignal('Cast'):Once(function()
                dwnFX_nwL.CFrame *= CFrame.Angles(0,0,-math.rad(90))
                dwnFX_nwR.CFrame *= CFrame.Angles(0,0,math.rad(90))
                dwnFX_nwL.MainWind:Emit(25)
                dwnFX_nwR.MainWind:Emit(25)
            end)
        end

        self['func_skill4'] = function()
            self['101'].HingeConstraint.LimitsEnabled = false
            self['102'].HingeConstraint.LimitsEnabled = false
            _PlayAnim(game.ServerStorage.Killer_Animations['Killer_Skill4_Hold'])
            coroutine.yield()
            local trndFX_nw = trndFX:Clone()
            game:GetService('Debris'):AddItem(trndFX_nw, 5)
            local trck = _PlayAnim(game.ServerStorage.Killer_Animations['Killer_Skill4_Release'])
            trck:GetMarkerReachedSignal('Cast'):Once(function()
                self['101'].HingeConstraint.LimitsEnabled = true
                self['102'].HingeConstraint.LimitsEnabled = true
                self['101'].Cube.Attachment0.W1:Emit(1)
                self['101'].Cube.Attachment0.W2:Emit(1)
                self['102'].Cube.Attachment0.W1:Emit(1)
                self['102'].Cube.Attachment0.W2:Emit(1)
                local spot = workspace.Dummy.R6['HumanoidRootPart'].CFrame
                spot += (spot.LookVector*7)
                trndFX_nw:PivotTo(spot)
                trndFX_nw.Parent = workspace.Terrain
                trndFX_nw.Wind1.MainWind.Enabled = true
            end)
            trck.Ended:Once(function()
                trndFX_nw.Wind1.MainWind.Enabled = false
            end)
        end

    end
    
    function self.start()
        --self['Promt'].Triggered:Connect(self['func_atk1'])
        local list = {
            'func_atk1' ; 'func_atk2' ; 'func_atk3' ; 'func_atk4' ; 'func_atk5' ;
            'func_skill1' ; 'func_skill2' ; 'func_skill3' ; 'func_skill4'
        }
        --list = {'func_skill3'}
        local routine = nil
        --[[
                while true do
            if routine and coroutine.status(routine) == 'suspended' then
                coroutine.resume(routine)
            else
                local a, b
                repeat a, b = next(list, self['current']) ; self['current'] = a ;
                until b
                routine = coroutine.create(self[b])
                coroutine.resume(routine)
            end
            task.wait(1)
        end
        ]]--
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