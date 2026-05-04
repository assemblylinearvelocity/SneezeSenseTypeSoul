local MobRenderer = {}

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera     = workspace.CurrentCamera

local _active      = {}
local _Library     = nil
local BAR_GAP      = 3
local SMOOTH_SPEED = 0.12

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

local function NewLine(color, thickness)
    local l = Drawing.new("Line")
    l.Visible   = false
    l.Color     = color or Color3.fromRGB(255, 200, 100)
    l.Thickness = thickness or 1
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

local function HpToColor(pct)
    pct = math.clamp(pct, 0, 1)
    if pct > 0.5 then
        return Color3.fromRGB(math.floor(255*(1-pct)*2), 255, 0)
    else
        return Color3.fromRGB(255, math.floor(255*pct*2), 0)
    end
end

local function RemoveMob(model)
    local e = _active[model]
    if not e then return end
    RunService:UnbindFromRenderStep(e.renderName)
    if e.nameText        then e.nameText:Remove()        end
    if e.hpText          then e.hpText:Remove()          end
    if e.distText        then e.distText:Remove()        end
    if e.barFill         then e.barFill:Remove()         end
    if e.barOutlineLeft  then e.barOutlineLeft:Remove()  end
    if e.barOutlineRight then e.barOutlineRight:Remove() end
    if e.barOutlineTop   then e.barOutlineTop:Remove()   end
    if e.barOutlineBot   then e.barOutlineBot:Remove()   end
    if e.box             then for _, l in pairs(e.box) do l:Remove() end end
    if e.ancestryConn    then e.ancestryConn:Disconnect() end
    _active[model] = nil
end

local function AddMob(model)
    if _active[model] then return end
    local hrp      = model:FindFirstChild("HumanoidRootPart")
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    local nameText = NewText(13, Color3.fromRGB(255, 200, 100))
    local hpText   = NewText(10, Color3.fromRGB(255, 255, 255))
    local distText = NewText(11, Color3.fromRGB(200, 200, 200))
    local box      = NewBoxSet(Color3.fromRGB(255, 200, 100))
    local barFill  = NewLine(Color3.fromRGB(0, 255, 0), 1)
    local barOL    = NewLine(Color3.fromRGB(0, 0, 0), 1)
    local barOR    = NewLine(Color3.fromRGB(0, 0, 0), 1)
    local barOT    = NewLine(Color3.fromRGB(0, 0, 0), 1)
    local barOB    = NewLine(Color3.fromRGB(0, 0, 0), 1)
    local smoothHp = 1
    local renderName = "MobESP_" .. model:GetDebugId()

    local function HideAll()
        nameText.Visible = false
        hpText.Visible   = false
        distText.Visible = false
        barFill.Visible  = false
        barOL.Visible = false ; barOR.Visible = false
        barOT.Visible = false ; barOB.Visible = false
        SetBoxVisible(box, false)
    end

    RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 1, function()
        local flags = GetFlags()
        if not flags["Mob ESP"] or not model.Parent then
            RemoveMob(model)
            return
        end

        local localChar = Players.LocalPlayer.Character
        local localHRP  = localChar and localChar:FindFirstChild("HumanoidRootPart")
        if not localHRP then HideAll() return end

        local dist    = (hrp.Position - localHRP.Position).Magnitude
        local maxDist = flags["Mob ESP Distance"] or 500
        if dist > maxDist then HideAll() return end

        local _, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then HideAll() return end

        local color = (flags["Mob Color"] and flags["Mob Color"].Color) or Color3.fromRGB(255, 200, 100)
        local min, max = GetBoundingBox(model)

        if flags["Mob Box"] and min and max then
            DrawBox(box, min, max, color)
        else
            SetBoxVisible(box, false)
        end

        if flags["Mob Name"] and min and max then
            nameText.Text     = model.Name
            nameText.Size     = math.clamp(math.round((max.Y - min.Y) * 0.15), 10, 16)
            nameText.Position = Vector2.new(math.round((min.X + max.X) / 2), math.round(min.Y - nameText.Size - 2))
            nameText.Color    = color
            nameText.Visible  = true
        else
            nameText.Visible = false
        end

        if flags["Mob HP Bar"] and min and max then
            local hp    = humanoid.Health
            local maxHp = math.max(humanoid.MaxHealth, 1)
            smoothHp = smoothHp + (hp/maxHp - smoothHp) * SMOOTH_SPEED
            local pct    = math.clamp(smoothHp, 0, 1)
            local top    = math.round(min.Y)
            local bottom = math.round(max.Y)
            local height = bottom - top
            local barX   = math.round(min.X - BAR_GAP - 1)
            local fillY  = math.round(bottom - height * pct)

            barOL.From = Vector2.new(barX-1, top-1)    ; barOL.To = Vector2.new(barX-1, bottom+1) ; barOL.Visible = true
            barOR.From = Vector2.new(barX+1, top-1)    ; barOR.To = Vector2.new(barX+1, bottom+1) ; barOR.Visible = true
            barOT.From = Vector2.new(barX-1, top-1)    ; barOT.To = Vector2.new(barX+2, top-1)   ; barOT.Visible = true
            barOB.From = Vector2.new(barX-1, bottom+1) ; barOB.To = Vector2.new(barX+2, bottom+1); barOB.Visible = true
            barFill.From    = Vector2.new(barX, math.max(fillY, top))
            barFill.To      = Vector2.new(barX, bottom+1)
            barFill.Color   = HpToColor(pct)
            barFill.Visible = pct > 0

            if flags["Mob HP Text"] then
                hpText.Text     = math.floor(hp) .. "/" .. math.floor(maxHp)
                hpText.Position = Vector2.new(barX, math.round(top + height/2 - 5))
                hpText.Center   = true
                hpText.Visible  = true
            else
                hpText.Visible = false
            end
        else
            barFill.Visible = false
            barOL.Visible = false ; barOR.Visible = false
            barOT.Visible = false ; barOB.Visible = false
            hpText.Visible = false
        end

        if flags["Mob Distance"] and min and max then
            local unit  = flags["Mob Distance Unit"] or "studs"
            local label = unit == "m"
                and string.format("[%.0f m]", dist)
                or  string.format("[%.0f studs]", dist)
            distText.Text     = label
            distText.Position = Vector2.new(math.round((min.X + max.X) / 2), math.round(max.Y + 4))
            distText.Visible  = true
        else
            distText.Visible = false
        end
    end)

    local ancestryConn = model.AncestryChanged:Connect(function(_, parent)
        if not parent then RemoveMob(model) end
    end)

    _active[model] = {
        nameText=nameText, hpText=hpText, distText=distText, box=box,
        barFill=barFill, barOutlineLeft=barOL, barOutlineRight=barOR,
        barOutlineTop=barOT, barOutlineBot=barOB,
        renderName=renderName, ancestryConn=ancestryConn
    }
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
