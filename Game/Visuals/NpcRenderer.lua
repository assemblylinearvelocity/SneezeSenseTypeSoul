local NpcRenderer = {}

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera     = workspace.CurrentCamera

local _active  = {}
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
    t.Color   = color or Color3.fromRGB(100, 220, 255)
    return t
end

local function RemoveNpc(model)
    local e = _active[model]
    if not e then return end
    RunService:UnbindFromRenderStep(e.renderName)
    if e.nameText then e.nameText:Remove() end
    if e.distText then e.distText:Remove() end
    if e.ancestryConn then e.ancestryConn:Disconnect() end
    _active[model] = nil
end

local function AddNpc(model)
    if _active[model] then return end
    local primary = model.PrimaryPart
        or model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChildWhichIsA("BasePart")
    if not primary then return end

    local color      = Color3.fromRGB(100, 220, 255)
    local nameText   = NewText(13, color)
    local distText   = NewText(11, Color3.fromRGB(200, 200, 200))
    local renderName = "NpcESP_" .. model:GetDebugId()

    RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 1, function()
        local flags = GetFlags()
        if not flags["NPC ESP"] or not model.Parent then
            RemoveNpc(model)
            return
        end

        local localChar = Players.LocalPlayer.Character
        local localHRP  = localChar and localChar:FindFirstChild("HumanoidRootPart")
        if not localHRP then
            nameText.Visible = false
            distText.Visible = false
            return
        end

        local dist    = (primary.Position - localHRP.Position).Magnitude
        local maxDist = flags["NPC ESP Distance"] or 500
        if dist > maxDist then
            nameText.Visible = false
            distText.Visible = false
            return
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(primary.Position)
        if not onScreen then
            nameText.Visible = false
            distText.Visible = false
            return
        end

        local npcColor = (flags["NPC Color"] and flags["NPC Color"].Color) or color
        local sx = math.round(screenPos.X)
        local sy = math.round(screenPos.Y)

        if flags["NPC Name"] then
            nameText.Text     = model.Name
            nameText.Size     = 13
            nameText.Position = Vector2.new(sx, sy - 20)
            nameText.Color    = npcColor
            nameText.Visible  = true
        else
            nameText.Visible = false
        end

        if flags["NPC Distance"] then
            local unit  = flags["NPC Distance Unit"] or "studs"
            local label = unit == "m"
                and string.format("[%.0f m]", dist)
                or  string.format("[%.0f studs]", dist)
            distText.Text     = label
            distText.Position = Vector2.new(sx, sy + 6)
            distText.Visible  = true
        else
            distText.Visible = false
        end
    end)

    local ancestryConn = model.AncestryChanged:Connect(function(_, parent)
        if not parent then RemoveNpc(model) end
    end)

    _active[model] = { nameText=nameText, distText=distText, renderName=renderName, ancestryConn=ancestryConn }
end

local _scanConn  = nil
local _addedConn = nil

local function ScanNpcs()
    local npcs = workspace:FindFirstChild("NPCs")
    if not npcs then return end
    for _, child in ipairs(npcs:GetChildren()) do
        if child:IsA("Model") then AddNpc(child) end
    end
end

function NpcRenderer:Init(Library)
    _Library = Library
end

function NpcRenderer:Enable()
    ScanNpcs()
    if not _scanConn then
        _scanConn = RunService.Heartbeat:Connect(function()
            if not GetFlags()["NPC ESP"] then NpcRenderer:Disable() end
        end)
    end
    if not _addedConn then
        local npcs = workspace:FindFirstChild("NPCs")
        if npcs then
            _addedConn = npcs.ChildAdded:Connect(function(child)
                if child:IsA("Model") then task.wait(0.1) ; AddNpc(child) end
            end)
        end
    end
end

function NpcRenderer:Disable()
    if _scanConn  then _scanConn:Disconnect()  ; _scanConn  = nil end
    if _addedConn then _addedConn:Disconnect() ; _addedConn = nil end
    for model in pairs(_active) do RemoveNpc(model) end
end

function NpcRenderer:Update()
    if GetFlags()["NPC ESP"] then NpcRenderer:Enable() else NpcRenderer:Disable() end
end

function NpcRenderer:Unload()
    NpcRenderer:Disable()
end

return NpcRenderer
