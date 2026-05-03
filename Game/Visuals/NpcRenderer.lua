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

local function NewLine(color)
    local l = Drawing.new("Line")
    l.Visible   = false
    l.Color     = color or Color3.fromRGB(100, 220, 255)
    l.Thickness = 1
    return l
end

local function NewBoxSet(color)
    return {
        Top    = NewLine(color),
        Bottom = NewLine(color),
        Left   = NewLine(color),
        Right  = NewLine(color),
    }
end

local function SetBoxVisible(box, visible)
    for _, l in pairs(box) do l.Visible = visible end
end

local function DrawBox(box, min, max, color)
    local tl = Vector2.new(min.X, min.Y)
    local tr = Vector2.new(max.X, min.Y)
    local bl = Vector2.new(min.X, max.Y)
    local br = Vector2.new(max.X, max.Y)
    box.Top.From    = tl ; box.Top.To    = Vector2.new(tr.X+1, tr.Y)
    box.Bottom.From = bl ; box.Bottom.To = Vector2.new(br.X+1, br.Y)
    box.Left.From   = tl ; box.Left.To   = Vector2.new(bl.X, bl.Y+1)
    box.Right.From  = tr ; box.Right.To  = Vector2.new(br.X, br.Y+1)
    for _, l in pairs(box) do
        l.Color   = color or Color3.fromRGB(100, 220, 255)
        l.Visible = true
    end
end

local function GetBoundingBox(model)
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local any = false
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local screen, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                any  = true
                minX = math.min(minX, screen.X)
                minY = math.min(minY, screen.Y)
                maxX = math.max(maxX, screen.X)
                maxY = math.max(maxY, screen.Y)
            end
        end
    end
    if not any then return nil, nil end
    return Vector2.new(math.round(minX), math.round(minY)),
           Vector2.new(math.round(maxX), math.round(maxY))
end

local function RemoveNpc(model)
    local e = _active[model]
    if not e then return end
    RunService:UnbindFromRenderStep(e.renderName)
    if e.nameText then e.nameText:Remove() end
    if e.box      then for _, l in pairs(e.box) do l:Remove() end end
    if e.ancestryConn then e.ancestryConn:Disconnect() end
    _active[model] = nil
end

local function AddNpc(model)
    if _active[model] then return end
    local primary = model.PrimaryPart
        or model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChildWhichIsA("BasePart")
    if not primary then return end

    local nameText   = NewText(13, Color3.fromRGB(100, 220, 255))
    local box        = NewBoxSet(Color3.fromRGB(100, 220, 255))
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
            SetBoxVisible(box, false)
            return
        end

        local dist    = (primary.Position - localHRP.Position).Magnitude
        local maxDist = flags["NPC ESP Distance"] or 500

        if dist > maxDist then
            nameText.Visible = false
            SetBoxVisible(box, false)
            return
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(primary.Position)
        if not onScreen then
            nameText.Visible = false
            SetBoxVisible(box, false)
            return
        end

        local color = (flags["NPC Color"] and flags["NPC Color"].Color) or Color3.fromRGB(100, 220, 255)

        if flags["NPC Box"] then
            local min, max = GetBoundingBox(model)
            if min and max then
                DrawBox(box, min, max, color)

                if flags["NPC Name"] then
                    nameText.Size     = math.clamp(math.round((max.Y - min.Y) * 0.15), 10, 16)
                    nameText.Text     = string.format("%s [%.0fm]", model.Name, dist)
                    nameText.Position = Vector2.new(math.round((min.X + max.X) / 2), math.round(min.Y - nameText.Size - 2))
                    nameText.Color    = color
                    nameText.Visible  = true
                else
                    nameText.Visible = false
                end
            else
                SetBoxVisible(box, false)
                nameText.Visible = false
            end
        else
            SetBoxVisible(box, false)

            if flags["NPC Name"] then
                local screenPos2, onScreen2 = Camera:WorldToViewportPoint(primary.Position)
                if onScreen2 then
                    nameText.Size     = 13
                    nameText.Text     = string.format("%s [%.0fm]", model.Name, dist)
                    nameText.Position = Vector2.new(math.round(screenPos2.X), math.round(screenPos2.Y - 20))
                    nameText.Color    = color
                    nameText.Visible  = true
                else
                    nameText.Visible = false
                end
            else
                nameText.Visible = false
            end
        end
    end)

    local ancestryConn = model.AncestryChanged:Connect(function(_, parent)
        if not parent then RemoveNpc(model) end
    end)

    _active[model] = { nameText=nameText, box=box, renderName=renderName, ancestryConn=ancestryConn }
end

local _scanConn  = nil
local _addedConn = nil

local function ScanNpcs()
    local npcs = workspace:FindFirstChild("NPCs")
    if not npcs then return end
    for _, child in ipairs(npcs:GetDescendants()) do
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
