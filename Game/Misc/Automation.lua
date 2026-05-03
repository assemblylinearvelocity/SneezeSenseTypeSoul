local Automation = {}

local RunService = game:GetService("RunService")

local _connection = nil

local function AnyFeatureOn()
    local flags = _G.Flags or {}
    return false
end

local function StartLoop()
    if _connection then return end

    _connection = RunService.Heartbeat:Connect(function()
        local flags = _G.Flags or {}
    end)
end

local function StopLoop()
    if _connection then
        _connection:Disconnect()
        _connection = nil
    end
end

function Automation:Update()
    if AnyFeatureOn() then
        StartLoop()
    else
        StopLoop()
    end
end

function Automation:Unload()
    StopLoop()
end

return Automation
