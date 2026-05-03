local Visuals = {}

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer

local _Library     = nil
local _EspRenderer = nil
local _MobRenderer = nil
local _NpcRenderer = nil
local _connection  = nil
local Renderers    = {}

local _freecamConn    = {}
local _origFOV        = nil
local _origCamType    = nil

local function GetFlags()
    return _Library and _Library.Flags or {}
end

local function GetEntityCharacter(player)
    local entities = workspace:FindFirstChild("Entities")
    if not entities then return nil end
    return entities:FindFirstChild(player.Name)
end

local function StartLoop()
    if _connection then return end
    _connection = RunService.RenderStepped:Connect(function()
        local flags = GetFlags()
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not Renderers[player] then
                Renderers[player] = _EspRenderer.new(player)
            end
            Renderers[player]:Update(GetEntityCharacter(player), flags)
        end
    end)
end

local function StopLoop()
    if _connection then
        _connection:Disconnect()
        _connection = nil
    end
end

local function StopFreecam()
    for _, c in ipairs(_freecamConn) do c:Disconnect() end
    _freecamConn = {}
    if _origCamType then
        workspace.CurrentCamera.CameraType = _origCamType
        _origCamType = nil
    end
end

local function StartFreecam(sens, speed)
    StopFreecam()
    _origCamType = workspace.CurrentCamera.CameraType
    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

    local keys    = {}
    local rmb     = false
    local cam     = workspace.CurrentCamera

    table.insert(_freecamConn, RunService.RenderStepped:Connect(function()
        local flags = GetFlags()
        if not flags["Freecam"] then StopFreecam() return end

        local spd = (flags["Freecam Speed"] or speed or 0.5)
        local s   = (flags["Freecam Sens"]  or sens  or 0.3)

        if keys["W"] then cam.CFrame = cam.CFrame * CFrame.new(0, 0, -spd) end
        if keys["S"] then cam.CFrame = cam.CFrame * CFrame.new(0, 0,  spd) end
        if keys["A"] then cam.CFrame = cam.CFrame * CFrame.new(-spd, 0, 0) end
        if keys["D"] then cam.CFrame = cam.CFrame * CFrame.new( spd, 0, 0) end
    end))

    table.insert(_freecamConn, UserInputService.InputBegan:Connect(function(inp)
        if inp.KeyCode == Enum.KeyCode.W then keys["W"] = true end
        if inp.KeyCode == Enum.KeyCode.A then keys["A"] = true end
        if inp.KeyCode == Enum.KeyCode.S then keys["S"] = true end
        if inp.KeyCode == Enum.KeyCode.D then keys["D"] = true end
        if inp.UserInputType == Enum.UserInputType.MouseButton2 then rmb = true end
    end))

    table.insert(_freecamConn, UserInputService.InputEnded:Connect(function(inp)
        if inp.KeyCode == Enum.KeyCode.W then keys["W"] = false end
        if inp.KeyCode == Enum.KeyCode.A then keys["A"] = false end
        if inp.KeyCode == Enum.KeyCode.S then keys["S"] = false end
        if inp.KeyCode == Enum.KeyCode.D then keys["D"] = false end
        if inp.UserInputType == Enum.UserInputType.MouseButton2 then rmb = false end
    end))

    table.insert(_freecamConn, UserInputService.InputChanged:Connect(function(inp)
        local flags = GetFlags()
        if not rmb then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local s = (flags["Freecam Sens"] or sens or 0.3)
        local delta = inp.Delta
        local cf = cam.CFrame
        local newCF = CFrame.Angles(0, -math.rad(delta.X) * s, 0) * cf * CFrame.Angles(-math.rad(delta.Y) * s, 0, 0)
        cam.CFrame = CFrame.new(cf.Position, cf.Position + newCF.LookVector)
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    end))
end

function Visuals:Init(Library, EspRenderer, MobRenderer, NpcRenderer)
    _Library = Library
    _EspRenderer = EspRenderer
    _MobRenderer = MobRenderer
    _NpcRenderer = NpcRenderer
    _MobRenderer:Init(Library)
    _NpcRenderer:Init(Library)
    StartLoop()
end

function Visuals:Update()
    local flags = GetFlags()

    if flags["FOV Changer"] then
        if _origFOV == nil then _origFOV = workspace.CurrentCamera.FieldOfView end
        workspace.CurrentCamera.FieldOfView = flags["FOV Value"] or 70
    else
        if _origFOV ~= nil then
            workspace.CurrentCamera.FieldOfView = _origFOV
            _origFOV = nil
        end
    end

    if flags["Freecam"] then
        if #_freecamConn == 0 then
            StartFreecam(flags["Freecam Sens"], flags["Freecam Speed"])
        end
    else
        StopFreecam()
    end

    if _MobRenderer then _MobRenderer:Update() end
    if _NpcRenderer then _NpcRenderer:Update() end
end

function Visuals:Unload()
    StopLoop()
    StopFreecam()
    if _origFOV ~= nil then
        workspace.CurrentCamera.FieldOfView = _origFOV
        _origFOV = nil
    end
    if _MobRenderer then _MobRenderer:Unload() end
    if _NpcRenderer then _NpcRenderer:Unload() end
    for _, renderer in pairs(Renderers) do
        renderer:Destroy()
    end
    Renderers = {}
end

Players.PlayerRemoving:Connect(function(player)
    if Renderers[player] then
        Renderers[player]:Destroy()
        Renderers[player] = nil
    end
end)

return Visuals
