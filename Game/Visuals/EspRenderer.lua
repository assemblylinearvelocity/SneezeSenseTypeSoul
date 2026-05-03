local EspRenderer = {}
EspRenderer.__index = EspRenderer

local Camera = workspace.CurrentCamera

local BODY_PARTS = {"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg","HumanoidRootPart"}
local BAR_GAP      = 3
local SMOOTH_SPEED = 0.12

local function NewLine(color, thickness)
    local l = Drawing.new("Line")
    l.Visible   = false
    l.Color     = color
    l.Thickness = thickness
    return l
end

local function NewBoxSet(color, thickness)
    return {
        Top    = NewLine(color, thickness),
        Bottom = NewLine(color, thickness),
        Left   = NewLine(color, thickness),
        Right  = NewLine(color, thickness),
    }
end

local function SetSetVisible(set, visible)
    for _, l in pairs(set) do
        l.Visible = visible
    end
end

local function GetBoundingBox(character)
    if not character:FindFirstChild("HumanoidRootPart") then return nil, nil end
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyOnScreen = false
    for _, partName in ipairs(BODY_PARTS) do
        local part = character:FindFirstChild(partName)
        if not part or not part:IsA("BasePart") then continue end
        local size = part.Size
        local cf   = part.CFrame
        local offsets = {
            Vector3.new( size.X/2,  size.Y/2,  size.Z/2),
            Vector3.new(-size.X/2,  size.Y/2,  size.Z/2),
            Vector3.new( size.X/2, -size.Y/2,  size.Z/2),
            Vector3.new(-size.X/2, -size.Y/2,  size.Z/2),
            Vector3.new( size.X/2,  size.Y/2, -size.Z/2),
            Vector3.new(-size.X/2,  size.Y/2, -size.Z/2),
            Vector3.new( size.X/2, -size.Y/2, -size.Z/2),
            Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
        }
        for _, offset in ipairs(offsets) do
            local screen, onScreen = Camera:WorldToViewportPoint(cf * offset)
            if onScreen then
                anyOnScreen = true
                minX = math.min(minX, screen.X)
                minY = math.min(minY, screen.Y)
                maxX = math.max(maxX, screen.X)
                maxY = math.max(maxY, screen.Y)
            end
        end
    end
    if not anyOnScreen then return nil, nil end
    return Vector2.new(math.round(minX), math.round(minY)),
           Vector2.new(math.round(maxX), math.round(maxY))
end

local function GetHealth(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return 100, 100 end
    local maxHp = character:GetAttribute("MaxHealth") or humanoid.MaxHealth
    local hp    = humanoid.Health
    if maxHp <= 0 then maxHp = 100 end
    return math.clamp(hp, 0, maxHp), maxHp
end

local function HpToColor(pct)
    pct = math.clamp(pct, 0, 1)
    if pct > 0.5 then
        return Color3.fromRGB(math.floor(255*(1-pct)*2), 255, 0)
    else
        return Color3.fromRGB(255, math.floor(255*pct*2), 0)
    end
end

function EspRenderer.new(player)
    local self = setmetatable({}, EspRenderer)
    self.player = player

    self.box = {
        outer = NewBoxSet(Color3.fromRGB(0,0,0), 1),
        main  = NewBoxSet(Color3.fromRGB(255,255,255), 1),
        inner = NewBoxSet(Color3.fromRGB(0,0,0), 1),
    }

    self.healthBar = {
        outlineLeft   = NewLine(Color3.fromRGB(0,0,0), 1),
        outlineRight  = NewLine(Color3.fromRGB(0,0,0), 1),
        outlineTop    = NewLine(Color3.fromRGB(0,0,0), 1),
        outlineBottom = NewLine(Color3.fromRGB(0,0,0), 1),
        fill          = NewLine(Color3.fromRGB(0,255,0), 1),
    }

    local healthText = Drawing.new("Text")
    healthText.Visible = false
    healthText.Size    = 10
    healthText.Center  = true
    healthText.Outline = true
    healthText.Color   = Color3.fromRGB(255,255,255)
    self.healthText = healthText

    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Size    = 16
    nameText.Center  = true
    nameText.Outline = true
    nameText.Color   = Color3.fromRGB(255,255,255)
    self.nameText = nameText

    local raceText = Drawing.new("Text")
    raceText.Visible = false
    raceText.Size    = 13
    raceText.Center  = true
    raceText.Outline = true
    raceText.Color   = Color3.fromRGB(255,255,255)
    self.raceText = raceText

    local raceText = Drawing.new("Text")
    raceText.Visible = false
    raceText.Size    = 13
    raceText.Center  = true
    raceText.Outline = true
    raceText.Color   = Color3.fromRGB(255, 255, 255)
    self.raceText = raceText

    self._smoothHp = 1
    return self
end

function EspRenderer:UpdateBox(min, max, color)
    local o = 1
    local i = 1

    local oTL = Vector2.new(min.X-o, min.Y-o)
    local oTR = Vector2.new(max.X+o, min.Y-o)
    local oBL = Vector2.new(min.X-o, max.Y+o)
    local oBR = Vector2.new(max.X+o, max.Y+o)
    self.box.outer.Top.From    = oTL
    self.box.outer.Top.To      = Vector2.new(oTR.X+1, oTR.Y)
    self.box.outer.Bottom.From = oBL
    self.box.outer.Bottom.To   = Vector2.new(oBR.X+1, oBR.Y)
    self.box.outer.Left.From   = oTL
    self.box.outer.Left.To     = Vector2.new(oBL.X, oBL.Y+1)
    self.box.outer.Right.From  = oTR
    self.box.outer.Right.To    = Vector2.new(oBR.X, oBR.Y+1)
    for _, l in pairs(self.box.outer) do l.Visible = true end

    local mTL = Vector2.new(min.X, min.Y)
    local mTR = Vector2.new(max.X, min.Y)
    local mBL = Vector2.new(min.X, max.Y)
    local mBR = Vector2.new(max.X, max.Y)
    self.box.main.Top.From    = mTL
    self.box.main.Top.To      = Vector2.new(mTR.X+1, mTR.Y)
    self.box.main.Bottom.From = mBL
    self.box.main.Bottom.To   = Vector2.new(mBR.X+1, mBR.Y)
    self.box.main.Left.From   = mTL
    self.box.main.Left.To     = Vector2.new(mBL.X, mBL.Y+1)
    self.box.main.Right.From  = mTR
    self.box.main.Right.To    = Vector2.new(mBR.X, mBR.Y+1)
    for _, l in pairs(self.box.main) do
        l.Color   = color or Color3.fromRGB(255,255,255)
        l.Visible = true
    end

    local iTL = Vector2.new(min.X+i, min.Y+i)
    local iTR = Vector2.new(max.X-i, min.Y+i)
    local iBL = Vector2.new(min.X+i, max.Y-i)
    local iBR = Vector2.new(max.X-i, max.Y-i)
    self.box.inner.Top.From    = iTL
    self.box.inner.Top.To      = Vector2.new(iTR.X+1, iTR.Y)
    self.box.inner.Bottom.From = iBL
    self.box.inner.Bottom.To   = Vector2.new(iBR.X+1, iBR.Y)
    self.box.inner.Left.From   = iTL
    self.box.inner.Left.To     = Vector2.new(iBL.X, iBL.Y+1)
    self.box.inner.Right.From  = iTR
    self.box.inner.Right.To    = Vector2.new(iBR.X, iBR.Y+1)
    for _, l in pairs(self.box.inner) do l.Visible = true end
end

function EspRenderer:UpdateRace(min, max, character)
    local race = "Unknown"

    local raceKeywords = {
        {"Shinigami", "Shinigami"},
        {"Arrancar",  "Arrancar"},
        {"Quincy",    "Quincy"},
        {"Hollow",    "Hollow"},
        {"Fullbring", "Fullbringer"},
        {"Vizard",    "Vizard"},
        {"Vastocar",  "Vastocar"},
    }

    for _, desc in ipairs(character:GetDescendants()) do
        local name = desc.Name
        for _, entry in ipairs(raceKeywords) do
            if name:find(entry[1]) then
                race = entry[2]
                break
            end
        end
        if race ~= "Unknown" then break end
    end

    local centerY = math.round((min.Y + max.Y) / 2)
    local fontSize = math.clamp(math.round((max.Y - min.Y) * 0.12), 11, 14)
    self.raceText.Size     = fontSize
    self.raceText.Text     = "[" .. race .. "]"
    self.raceText.Position = Vector2.new(math.round(min.X - 5), centerY - math.round(fontSize / 2))
    self.raceText.Center   = true
    self.raceText.Visible  = true
end

function EspRenderer:HideRace()
    self.raceText.Visible = false
end

function EspRenderer:UpdateRace(min, max, character)
    local race = character:GetAttribute("Race")
        or character:GetAttribute("Faction")
        or character:GetAttribute("Team")

    if not race or race == "" then
        local values = character:FindFirstChild("Values_")
        if values then
            local raceVal = values:FindFirstChild("Race") or values:FindFirstChild("Faction")
            if raceVal then race = raceVal.Value end
        end
    end

    if not race or race == "" then
        self.raceText.Visible = false
        return
    end

    local centerX = math.round(min.X - 10)
    local centerY = math.round((min.Y + max.Y) / 2)
    self.raceText.Text     = "[" .. race .. "]"
    self.raceText.Position = Vector2.new(centerX, centerY - 7)
    self.raceText.Visible  = true
end

function EspRenderer:HideRace()
    self.raceText.Visible = false
end

function EspRenderer:UpdateName(min, max, mode)
    local displayName = self.player.DisplayName
    local userName    = self.player.Name
    local label
    if mode == "Display Name" then
        label = displayName
    elseif mode == "Username" then
        label = "@" .. userName
    else
        label = displayName .. " (@" .. userName .. ")"
    end
    local fontSize = math.clamp(math.round((max.Y - min.Y) * 0.15), 15, 18)
    self.nameText.Size     = fontSize
    self.nameText.Text     = label
    self.nameText.Position = Vector2.new(math.round((min.X+max.X)/2), math.round(min.Y - fontSize - 2))
    self.nameText.Visible  = true
end

function EspRenderer:HideName()
    self.nameText.Visible = false
end

function EspRenderer:HideHealthBar()
    self.healthBar.outlineLeft.Visible   = false
    self.healthBar.outlineRight.Visible  = false
    self.healthBar.outlineTop.Visible    = false
    self.healthBar.outlineBottom.Visible = false
    self.healthBar.fill.Visible          = false
    self.healthText.Visible              = false
end

function EspRenderer:UpdateHealthBar(min, max, character, showText)
    local hp, maxHp = GetHealth(character)
    self._smoothHp = self._smoothHp + (hp/maxHp - self._smoothHp) * SMOOTH_SPEED
    local pct    = math.clamp(self._smoothHp, 0, 1)
    local top    = math.round(min.Y)
    local bottom = math.round(max.Y)
    local height = bottom - top
    local barX   = math.round(min.X - BAR_GAP - 1)
    local fillY  = math.round(bottom - height*pct)

    self.healthBar.outlineLeft.From    = Vector2.new(barX-1, top-1)
    self.healthBar.outlineLeft.To      = Vector2.new(barX-1, bottom+1)
    self.healthBar.outlineLeft.Visible = true
    self.healthBar.outlineRight.From    = Vector2.new(barX+1, top-1)
    self.healthBar.outlineRight.To      = Vector2.new(barX+1, bottom+1)
    self.healthBar.outlineRight.Visible = true
    self.healthBar.outlineTop.From    = Vector2.new(barX-1, top-1)
    self.healthBar.outlineTop.To      = Vector2.new(barX+2, top-1)
    self.healthBar.outlineTop.Visible = true
    self.healthBar.outlineBottom.From    = Vector2.new(barX-1, bottom+1)
    self.healthBar.outlineBottom.To      = Vector2.new(barX+2, bottom+1)
    self.healthBar.outlineBottom.Visible = true
    self.healthBar.fill.From    = Vector2.new(barX, math.max(fillY, top))
    self.healthBar.fill.To      = Vector2.new(barX, bottom+1)
    self.healthBar.fill.Color   = HpToColor(pct)
    self.healthBar.fill.Visible = pct > 0

    if showText then
        self.healthText.Text     = math.floor(hp) .. "/" .. math.floor(maxHp)
        self.healthText.Position = Vector2.new(barX, math.round(top + height/2 - 5))
        self.healthText.Center   = true
        self.healthText.Visible  = true
    else
        self.healthText.Visible = false
    end
end

function EspRenderer:HideBox()
    for _, set in pairs(self.box) do
        SetSetVisible(set, false)
    end
    self:HideHealthBar()
    self:HideName()
    self:HideRace()
end

function EspRenderer:Update(character, flags)
    local boxOn    = flags["Box ESP"]
    local hpBarOn  = flags["HP Bar"]
    local nameOn   = flags["Name ESP"]
    local boxColor = (flags["Box Color"] and flags["Box Color"].Color) or Color3.fromRGB(255,255,255)

    if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChildOfClass("Humanoid") then
        local min, max = GetBoundingBox(character)
        if min and max then
            if boxOn then
                self:UpdateBox(min, max, boxColor)
            else
                for _, set in pairs(self.box) do SetSetVisible(set, false) end
            end
            if hpBarOn then
                self:UpdateHealthBar(min, max, character, flags["Health Text"])
            else
                self:HideHealthBar()
            end
            if nameOn then
                self:UpdateName(min, max, flags["Name Mode"] or "Both")
            else
                self:HideName()
            end
            if flags["Race ESP"] then
                self:UpdateRace(min, max, character)
            else
                self:HideRace()
            end
            if flags["Race ESP"] then
                self:UpdateRace(min, max, character)
            else
                self:HideRace()
            end
        else
            self:HideBox()
        end
    else
        self:HideBox()
    end
end

function EspRenderer:Destroy()
    for _, set in pairs(self.box) do
        for _, l in pairs(set) do l:Remove() end
    end
    self.healthBar.outlineLeft:Remove()
    self.healthBar.outlineRight:Remove()
    self.healthBar.outlineTop:Remove()
    self.healthBar.outlineBottom:Remove()
    self.healthBar.fill:Remove()
    self.healthText:Remove()
    self.nameText:Remove()
    self.raceText:Remove()
end

return EspRenderer
