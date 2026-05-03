local WorldModulation = {}

local Lighting  = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local _connection = nil
local _originals  = {}

local function SaveOriginals()
    if _originals.saved then return end
    _originals.ClockTime       = Lighting.ClockTime
    _originals.FogEnd          = Lighting.FogEnd
    _originals.Brightness      = Lighting.Brightness
    _originals.GlobalShadows   = Lighting.GlobalShadows
    _originals.OutdoorAmbient  = Lighting.OutdoorAmbient
    _originals.saved           = true
end

local function RestoreOriginals()
    if not _originals.saved then return end
    Lighting.ClockTime      = _originals.ClockTime
    Lighting.FogEnd         = _originals.FogEnd
    Lighting.Brightness     = _originals.Brightness
    Lighting.GlobalShadows  = _originals.GlobalShadows
    Lighting.OutdoorAmbient = _originals.OutdoorAmbient
    _originals = {}
end

local function AnyFeatureOn()
    local flags = _G.Flags or {}
    return flags["Time Change"] or flags["No Fog"] or flags["Fullbright"]
end

local function StartLoop()
    if _connection then return end
    _connection = RunService.Heartbeat:Connect(function()
        local flags = _G.Flags or {}

        if flags["Time Change"] then
            local target = flags["Time Value"] or 14
            if Lighting.ClockTime ~= target then
                Lighting.ClockTime = target
            end
        end

        if flags["No Fog"] then
            if Lighting.FogEnd ~= 1e9 then
                Lighting.FogEnd = 1e9
            end
        end

        if flags["Fullbright"] then
            Lighting.Brightness     = 3
            Lighting.GlobalShadows  = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            if Lighting.ClockTime ~= 14 and not flags["Time Change"] then
                Lighting.ClockTime = 14
            end
        end
    end)
end

local function StopLoop()
    if _connection then
        _connection:Disconnect()
        _connection = nil
    end
end

function WorldModulation:Update()
    if AnyFeatureOn() then
        SaveOriginals()
        StartLoop()
    else
        StopLoop()
        RestoreOriginals()
    end
end

function WorldModulation:Unload()
    StopLoop()
    RestoreOriginals()
end

return WorldModulation
