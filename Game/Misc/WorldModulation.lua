local WorldModulation = {}

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local _connection = nil
local _originalClockTime = nil
local _originalFogEnd = nil

local function AnyFeatureOn()
    local flags = _G.Flags or {}
    return flags["Time Change"]
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
    end)
end

local function StopLoop()
    if _connection then
        _connection:Disconnect()
        _connection = nil
    end
end

local function RestoreOriginals()
    if _originalClockTime ~= nil then
        Lighting.ClockTime = _originalClockTime
        _originalClockTime = nil
    end
    if _originalFogEnd ~= nil then
        Lighting.FogEnd = _originalFogEnd
        _originalFogEnd = nil
    end
end

function WorldModulation:Update()
    if AnyFeatureOn() then
        if _originalClockTime == nil then
            _originalClockTime = Lighting.ClockTime
            _originalFogEnd = Lighting.FogEnd
        end
        Lighting.FogEnd = 100000
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
