local NpcRenderer = {}

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera     = workspace.CurrentCamera

local _active  = {}
local _Library = nil

local function GetFlags()
    return _Library and _Library.Flags or {}
end

local function NewText()
    local t = Drawing.new("Text")
    t.Visible = false
    t.Size    = 13
    t.Center  = true
    t.Outline = true
    t.Color   = Color3.fromRGB(100, 220, 255)
    return t
end

local function RemoveNpc(model)
    local entry = _active[model]
    if not entry then return end
    if entry.renderName then RunService:UnbindFromRenderStep(entry.renderName) end
    if entry.text then entry.text:Remove() end
    if entry.ancestryConn then entry.ancestryConn:Disconnect() end
    _active[model] = nil
end

local function AddNpc(model)
    if _active[model] then return end
    local primary = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
    if not primary then return end

    local text       = NewText()
    local renderName = "NpcESP_" .. model:GetDebugId()

    RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 1, function()
        local flags = GetFlags()
        if not flags["NPC ESP"] or not model.Parent then
            RemoveNpc(model)
            return
        end

        local localChar = Players.LocalPlayer.Character
        if not localChar then text.Visible = false return end
        local localHRP = localChar:FindFirstChild("HumanoidRootPart")
        if not localHRP then text.Visible = false return end

        local dist    = (primary.Position - localHRP.Position).Magnitude
        local maxDist = flags["NPC ESP Distance"] or 500

        if dist > maxDist then text.Visible = false return end

        local screenPos, onScreen = Camera:WorldToViewportPoint(primary.Position)
        if not onScreen then text.Visible = false return end

        text.Text     = string.format("[%s] [%.0fm]", model.Name, dist)
        text.Position = Vector2.new(math.round(screenPos.X), math.round(screenPos.Y - 20))
        text.Visible  = true
    end)

    local ancestryConn = model.AncestryChanged:Connect(function(_, parent)
        if not parent then RemoveNpc(model) end
    end)

    _active[model] = { text = text, renderName = renderName, ancestryConn = ancestryConn }
end

local function ScanNpcs()
    local npcs = workspace:FindFirstChild("NPCs")
    if not npcs then return end
    for _, child in ipairs(npcs:GetDescendants()) do
        if child:IsA("Model") then AddNpc(child) end
    end
end

local _scanConn  = nil
local _addedConn = nil

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
            _addedConn = npcs.DescendantAdded:Connect(function(child)
                if child:IsA("Model") then
                    task.wait(0.1)
                    AddNpc(child)
                end
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
    if GetFlags()["NPC ESP"] then
        NpcRenderer:Enable()
    else
        NpcRenderer:Disable()
    end
end

function NpcRenderer:Unload()
    NpcRenderer:Disable()
end

return NpcRenderer
