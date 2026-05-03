local Visuals = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local EspRenderer = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/assemblylinearvelocity/SneezeSenseTypeSoul/main/Game/Visuals/EspRenderer.lua"
))()

local _connection = nil
local Renderers = {}

local function GetEntityCharacter(player)
    local entities = workspace:FindFirstChild("Entities")
    if not entities then return nil end
    return entities:FindFirstChild(player.Name)
end

local function AnyFeatureOn()
    local flags = _G.Flags or {}
    return flags["Box ESP"]
end

local function StartLoop()
    if _connection then return end

    _connection = RunService.RenderStepped:Connect(function()
        local flags = _G.Flags or {}

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end

            if not Renderers[player] then
                Renderers[player] = EspRenderer.new(player)
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
