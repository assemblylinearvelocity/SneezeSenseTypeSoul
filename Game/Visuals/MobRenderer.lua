local MobRenderer = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local _active = {}
local _Library = nil

local function GetFlags()
    return _Library and _Library.Flags or {}
end

local function NewText(size, color)
    local t = Drawing.new("Text")
    t.Visible = false
    t.Size    = size or 13
    t.Center  = true
    t.Outline = true
    t.Color   = color or Color3.fromRGB(255, 255, 255)
    return t
end

local function RemoveMob(model)
    local entry = _active[model]
    if not entry then return end
    if entry.renderName then
        RunService:UnbindFromRenderStep(entry.renderName)
    end
    if entry.text then entry.text:Remove() end
    if entry.ancestryConn then entry.ancestryConn:Disconnect() end
    _active[model] = nil
end

local function AddMob(model)
    if _active[model] then return end

    local hrp = model:FindFirstChild("HumanoidRootPart")
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    local text = NewText(13, Color3.fromRGB(255, 200, 100))
    local renderName = "MobESP_" .. model:GetDebugId()

    RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 1, function()
        local flags = GetFlags()
        if not flags["Mob ESP"] or not model.Parent then
            RemoveMob(model)
            return
        end

        local localChar = Players.LocalPlayer.Character
        if not localChar then text.Visible = false return end
        local localHRP = localChar:FindFirstChild("HumanoidRootPart")
        if not localHRP then text.Visible = false return end

        local dist = (hrp.Position - localHRP.Position).Magnitude
        local maxDist = flags["Mob ESP Distance"] or 500

        if dist > maxDist then
            text.Visible = false
            return
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            text.Visible = false
            return
        end

        local hp    = humanoid.Health
        local maxHp = humanoid.MaxHealth
        local hpStr = string.format("%.0f/%.0f", hp, maxHp)

        text.Text     = string.format("[%s] [%s] [%.0fm]", model.Name, hpStr, dist)
        text.Position = Vector2.new(math.round(screenPos.X), math.round(screenPos.Y - 20))
        text.Visible  = true
    end)

    local ancestryConn = model.AncestryChanged:Connect(function(_, parent)
        if not parent then RemoveMob(model) end
    end)

    _active[model] = {
        text        = text,
        renderName  = renderName,
        ancestryConn = ancestryConn,
    }
end

local function IsPlayer(model)
    return Players:FindFirstChild(model.Name) ~= nil
end

local function ScanEntities()
    local entities = workspace:FindFirstChild("Entities")
    if not entities then return end
    for _, child in ipairs(entities:GetChildren()) do
        if child:IsA("Model") and not IsPlayer(child) then
            AddMob(child)
        end
    end
end

local _scanConn = nil
local _addedConn = nil

function MobRenderer:Init(Library)
    _Library = Library
end

function MobRenderer:Enable()
    ScanEntities()

    if not _scanConn then
        _scanConn = RunService.Heartbeat:Connect(function()
            local flags = GetFlags()
            if not flags["Mob ESP"] then
                MobRenderer:Disable()
            end
        end)
    end

    if not _addedConn then
        local entities = workspace:FindFirstChild("Entities")
        if entities then
            _addedConn = entities.ChildAdded:Connect(function(child)
                if child:IsA("Model") and not IsPlayer(child) then
                    task.wait(0.1)
                    AddMob(child)
                end
            end)
        end
    end
end

function MobRenderer:Disable()
    if _scanConn then _scanConn:Disconnect() ; _scanConn = nil end
    if _addedConn then _addedConn:Disconnect() ; _addedConn = nil end
    for model in pairs(_active) do
        RemoveMob(model)
    end
end

function MobRenderer:Update()
    local flags = GetFlags()
    if flags["Mob ESP"] then
        MobRenderer:Enable()
    else
        MobRenderer:Disable()
    end
end

function MobRenderer:Unload()
    MobRenderer:Disable()
end

return MobRenderer
