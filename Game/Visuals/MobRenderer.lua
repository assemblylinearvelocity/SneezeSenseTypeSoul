local MobRenderer = {}

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
    t.Color   = color or Color3.fromRGB(255, 200, 100)
    return t
end

local function NewLine(color)
    local l = Drawing.new("Line")
    l.Visible   = false
    l.Color     = color or Color3.fromRGB(255, 200, 100)
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
        l.Color   = color or Color3.fromRGB(255, 200, 100)
        l.Visible = true
    end
end

local function GetBoundingBox(character)
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local any = false
    for _, part in ipairs(character:GetDescendants()) do
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

local function RemoveMob(model)
    local e = _active[model]
    if not e then return end
    RunService:UnbindFromRenderStep(e.renderName)
    if e.nameText  then e.nameText:Remove()  end
    if e.hpText    then e.hpText:Remove()    end
    if e.box       then for _, l in pairs(e.box) do l:Remove() end end
    if e.ancestryConn then e.ancestryConn:Disconnect() end
    _active[model] = nil
end

local function AddMob(model)
    if _active[model] then return end
    local hrp      = model:FindFirstChild("HumanoidRootPart")
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    local nameText = NewText(13, Color3.fromRGB(255, 200, 100))
    local hpText   = NewText(11, Color3.fromRGB(255, 200, 100))
    local box      = NewBoxSet(Color3.fromRGB(255, 200, 100))
    local renderName = "MobESP_" .. model:GetDebugId()

    RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 1, function()
        local flags = GetFlags()
        if not flags["Mob ESP"] or not model.Parent then
            RemoveMob(model)
            return
        end

        local localChar = Players.LocalPlayer.Character
        local localHRP  = localChar and localChar:FindFirstChild("HumanoidRootPart")
        if not localHRP then
            nameText.Visible = false
            hpText.Visible   = false
            SetBoxVisible(box, false)
            return
        end

        local dist    = (hrp.Position - localHRP.Position).Magnitude
        local maxDist = flags["Mob ESP Distance"] or 500

        if dist > maxDist then
            nameText.Visible = false
            hpText.Visible   = false
            SetBoxVisible(box, false)
            return
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            nameText.Visible = false
            hpText.Visible   = false
            SetBoxVisible(box, false)
            return
        end

        local sx = math.round(screenPos.X)
        local sy = math.round(screenPos.Y)

        if flags["Mob Box"] then
            local min, max = GetBoundingBox(model)
            if min and max then
                DrawBox(box, min, max, Color3.fromRGB(255, 200, 100))
            else
                SetBoxVisible(box, false)
            end
        else
            SetBoxVisible(box, false)
        end

        if flags["Mob Name"] then
            nameText.Text     = string.format("[%s] [%.0fm]", model.Name, dist)
            nameText.Position = Vector2.new(sx, sy - 20)
            nameText.Visible  = true
        else
            nameText.Visible = false
        end

        if flags["Mob Health"] then
            local hp    = humanoid.Health
            local maxHp = math.max(humanoid.MaxHealth, 1)
            hpText.Text     = string.format("%.0f/%.0f", hp, maxHp)
            hpText.Position = Vector2.new(sx, sy - 6)
            hpText.Visible  = true
        else
            hpText.Visible = false
        end
    end)

    local ancestryConn = model.AncestryChanged:Connect(function(_, parent)
        if not parent then RemoveMob(model) end
    end)

    _active[model] = { nameText=nameText, hpText=hpText, box=box, renderName=renderName, ancestryConn=ancestryConn }
end

local function IsPlayer(model)
    return Players:FindFirstChild(model.Name) ~= nil
end

local _scanConn  = nil
local _addedConn = nil

local function ScanEntities()
    local entities = workspace:FindFirstChild("Entities")
    if not entities then return end
    for _, child in ipairs(entities:GetChildren()) do
        if child:IsA("Model") and not IsPlayer(child) then AddMob(child) end
    end
end

function MobRenderer:Init(Library)
    _Library = Library
end

function MobRenderer:Enable()
    ScanEntities()
    if not _scanConn then
        _scanConn = RunService.Heartbeat:Connect(function()
            if not GetFlags()["Mob ESP"] then MobRenderer:Disable() end
        end)
    end
    if not _addedConn then
        local entities = workspace:FindFirstChild("Entities")
        if entities then
            _addedConn = entities.ChildAdded:Connect(function(child)
                if child:IsA("Model") and not IsPlayer(child) then
                    task.wait(0.1) ; AddMob(child)
                end
            end)
        end
    end
end

function MobRenderer:Disable()
    if _scanConn  then _scanConn:Disconnect()  ; _scanConn  = nil end
    if _addedConn then _addedConn:Disconnect() ; _addedConn = nil end
    for model in pairs(_active) do RemoveMob(model) end
end

function MobRenderer:Update()
    if GetFlags()["Mob ESP"] then MobRenderer:Enable() else MobRenderer:Disable() end
end

function MobRenderer:Unload()
    MobRenderer:Disable()
end

return MobRenderer
