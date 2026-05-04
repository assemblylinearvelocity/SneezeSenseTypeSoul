local NpcRenderer = {}

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera     = workspace.CurrentCamera

local _active  = {}
local _Library = nil

local function GetFlags()
    return _Library and _Library.Flags or {}
end

local function RemoveNpc(model, renderName)
    local e = _active[model]
    if not e then return end
    RunService:UnbindFromRenderStep(renderName or e.renderName)
    if e.espText then e.espText:Remove() end
    if e.ancestryConn then e.ancestryConn:Disconnect() end
    _active[model] = nil
end

local function AddNpc(model)
    if _active[model] then return end
    if not model:IsA("Model") then return end
    local primary = model.PrimaryPart
        or model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChildWhichIsA("BasePart")
    if not primary then return end

    local flags    = GetFlags()
    local color    = (flags["NPC Color"] and flags["NPC Color"].Color) or Color3.fromRGB(100, 220, 255)
    local espText  = Drawing.new("Text")
    espText.Visible = false
    espText.Center  = true
    espText.Outline = true
    espText.Color   = color
    espText.Size    = 14

    local renderName = "NpcESP_" .. model:GetDebugId()

    RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 1, function()
        local f = GetFlags()
        if not f["NPC ESP"] or not model.Parent then
            RemoveNpc(model, renderName)
            return
        end

        local localChar = Players.LocalPlayer.Character
        local localHRP  = localChar and localChar:FindFirstChild("HumanoidRootPart")
        if not localHRP then espText.Visible = false return end

        local dist    = (primary.Position - localHRP.Position).Magnitude
        local maxDist = f["NPC ESP Distance"] or 1000

        local screenPos, onScreen = Camera:WorldToViewportPoint(primary.Position)

        if dist > maxDist or not onScreen then
            espText.Visible = false
            return
        end

        local npcColor = (f["NPC Color"] and f["NPC Color"].Color) or Color3.fromRGB(100, 220, 255)
        espText.Color   = npcColor
        espText.Size    = f["NPC Font Size"] or 14
        espText.Text    = string.format("[%s][%.1fm]", model.Name, dist)
        espText.Position = Vector2.new(screenPos.X, screenPos.Y - 50)
        espText.Visible  = true
    end)

    local ancestryConn = model.AncestryChanged:Connect(function(_, parent)
        if not parent then RemoveNpc(model, renderName) end
    end)

    _active[model] = { espText=espText, renderName=renderName, ancestryConn=ancestryConn }
end

local _scanConn  = nil
local _addedConn = nil

local function ScanNpcs()
    local npcs = workspace:FindFirstChild("NPCs")
    if not npcs then return end
    for _, child in ipairs(npcs:GetDescendants()) do
        if child:IsA("Model") and not _active[child] then
            local primary = child.PrimaryPart
                or child:FindFirstChild("HumanoidRootPart")
                or child:FindFirstChildWhichIsA("BasePart")
            if primary then AddNpc(child) end
        end
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
            _addedConn = npcs.DescendantAdded:Connect(function(child)
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
