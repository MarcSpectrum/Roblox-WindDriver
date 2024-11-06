local self = {}

local srvc_rplctstrg = game:GetService('ReplicatedStorage')

local ply = game.Players.LocalPlayer

local cam = workspace.CurrentCamera
local viewpoint = workspace:WaitForChild('Viewpoint')
cam.CameraType = Enum.CameraType.Scriptable
cam.CFrame = viewpoint.CFrame

local Controller = require(game.Players.LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('PlayerModule')):GetControls()

local wrkspc_Grid = workspace:WaitForChild('Grid')
local wrkspc_Special01 = workspace:WaitForChild('Special01')


local Grid_fltr = {
    Stand = {[true] = {}} ,
    Path = {[true] = {}} ,
    SurfaceLevel = {['Hill'] = {}} ,
} ;
local Map_fltr = {
    ['Traces'] = {
        [1] = {'1:15';'6:12';'9:14';'9:8';'9:5';'12:5';'17:10'}
    }
} ;

function self.initialize()
    -- // Grid
    wrkspc_Grid = wrkspc_Grid or workspace:WaitForChild('Grid') ;
    wrkspc_Special01 = wrkspc_Special01 or workspace:WaitForChild('Special01') ;
    for _, v in wrkspc_Special01:WaitForChild('Path'):GetChildren() do
        v = v.Name ; Grid_fltr['Path'][true][v] = true ; Grid_fltr['Stand'][true][v] = true ;
    end ;
    for _, v in wrkspc_Special01:WaitForChild('Stand'):GetChildren() do
        v = v.Name ; Grid_fltr['Stand'][true][v] = true ;
    end ;
    for _, v in wrkspc_Special01:WaitForChild('Hill'):GetChildren() do
        v = v.Name ; Grid_fltr['Stand'][true][v] = true ; Grid_fltr['SurfaceLevel']['Hill'][v] = true
    end ;
    local Blprnt_nw = shared.Blueprint.new(wrkspc_Grid, Grid_fltr) ;
    self['Blueprint'] = Blprnt_nw ;

    -- // Traces
    self['Traces'] = shared.Traces.new(Map_fltr.Traces or {}) ;
end

function self.start()
    Controller:Disable()
    local success
    repeat success = pcall(function()
        game:GetService('StarterGui'):SetCore('ResetButtonCallback', false) end)
        task.wait(0.2)
    until success

    shared.Task:Start(workspace:GetServerTimeNow())
end

return self