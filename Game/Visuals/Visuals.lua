local Visuals = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local _Library = nil
local _EspRenderer = nil
local _connection = nil
local Renderers = {}

local function GetFlags()
    return _Library and _Library.Flags or {}
end

local function GetEntityCharacter(player)
    local entities = workspace:FindFirstChild("Entities")
    if not entities then return nil end
    return entities:FindFirstChild(player.Name)
end

local function AnyFeatureOn()
    local flags = GetFlags()
    return flags["Box ESP"]
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

function Visuals:Init(Library, EspRenderer)
    _Library = Library
    _EspRenderer = EspRenderer
end

function Visuals:Update()
    if AnyFeatureOn() then
        StartLoop()
    else
        StopLoop()
        for _, renderer in pairs(Renderers) do
            renderer:HideBox()
        end
    end
end

function Visuals:Unload()
    StopLoop()
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
