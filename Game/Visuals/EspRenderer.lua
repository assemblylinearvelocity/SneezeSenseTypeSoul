local EspRenderer = {}
EspRenderer.__index = EspRenderer

local Camera = workspace.CurrentCamera

local BODY_PARTS = {
    "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart"
}

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
    for _, l in pairs(set) do l.Visible = visible end
end

local function ApplySet(set, tl, tr, bl, br)
    set.Top.From    = tl ; set.Top.To    = tr
    set.Bottom.From = bl ; set.Bottom.To = br
    set.Left.From   = tl ; set.Left.To   = bl
    set.Right.From  = tr ; set.Right.To  = br
    for _, l in pairs(set) do l.Visible = true end
end

local function GetBoundingBox(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyOnScreen = false

    for _, partName in ipairs(BODY_PARTS) do
        local part = character:FindFirstChild(partName)
        if not part or not part:IsA("BasePart") then continue end

        local size = part.Size
        local cf   = part.CFrame

        local offsets = {
            Vector3.new( size.X / 2,  size.Y / 2,  size.Z / 2),
            Vector3.new(-size.X / 2,  size.Y / 2,  size.Z / 2),
            Vector3.new( size.X / 2, -size.Y / 2,  size.Z / 2),
            Vector3.new(-size.X / 2, -size.Y / 2,  size.Z / 2),
            Vector3.new( size.X / 2,  size.Y / 2, -size.Z / 2),
            Vector3.new(-size.X / 2,  size.Y / 2, -size.Z / 2),
            Vector3.new( size.X / 2, -size.Y / 2, -size.Z / 2),
            Vector3.new(-size.X / 2, -size.Y / 2, -size.Z / 2),
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
        return Color3.fromRGB(math.floor(255 * (1 - pct) * 2), 255, 0)
    else
        return Color3.fromRGB(255, math.floor(255 * pct * 2), 0)
    end
end

function EspRenderer.new(player)
    local self = setmetatable({}, EspRenderer)
    self.player = player

    self.box = {
        outer = NewBoxSet(Color3.fromRGB(0, 0, 0), 1),
        main  = NewBoxSet(Color3.fromRGB(255, 255, 255), 1),
        inner = NewBoxSet(Color3.fromRGB(0, 0, 0), 1),
    }

    self.healthBar = {
        outlineLeft   = NewLine(Color3.fromRGB(0, 0, 0), 1),
        outlineRight  = NewLine(Color3.fromRGB(0, 0, 0), 1),
        outlineTop    = NewLine(Color3.fromRGB(0, 0, 0), 1),
        outlineBottom = NewLine(Color3.fromRGB(0, 0, 0), 1),
        fill          = NewLine(Color3.fromRGB(0, 255, 0), 1),
    }

    local healthText = Drawing.new("Text")
    healthText.Visible = false
    healthText.Size    = 10
    healthText.Center  = false
    healthText.Outline = true
    healthText.Color   = Color3.fromRGB(255, 255, 255)
    self.healthText = healthText

    self._smoothHp = 1
    return self
end

function EspRenderer:UpdateBox(min, max, color)
    local o, i = 1, 1
    ApplySet(self.box.outer,
        Vector2.new(min.X - o, min.Y - o), Vector2.new(max.X + o, min.Y - o),
        Vector2.new(min.X - o, max.Y + o), Vector2.new(max.X + o, max.Y + o)
    )
    ApplySet(self.box.main,
        Vector2.new(min.X, min.Y), Vector2.new(max.X, min.Y),
        Vector2.new(min.X, max.Y), Vector2.new(max.X, max.Y)
    )
    ApplySet(self.box.inner,
        Vector2.new(min.X + i, min.Y + i), Vector2.new(max.X - i, min.Y + i),
        Vector2.new(min.X + i, max.Y - i), Vector2.new(max.X - i, max.Y - i)
    )
    for _, l in pairs(self.box.main) do
        l.Color = color or Color3.fromRGB(255, 255, 255)
    end
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
    local targetPct = hp / maxHp

    self._smoothHp = self._smoothHp + (targetPct - self._smoothHp) * SMOOTH_SPEED

    local pct    = math.clamp(self._smoothHp, 0, 1)
    local top    = math.round(min.Y)
    local bottom = math.round(max.Y)
    local height = bottom - top
    local barX   = math.round(min.X - BAR_GAP - 1)
    local fillY  = math.round(bottom - (height * pct))

    self.healthBar.outlineLeft.From    = Vector2.new(barX - 1, top)
    self.healthBar.outlineLeft.To      = Vector2.new(barX - 1, bottom)
    self.healthBar.outlineLeft.Visible = true

    self.healthBar.outlineRight.From    = Vector2.new(barX + 1, top)
    self.healthBar.outlineRight.To      = Vector2.new(barX + 1, bottom)
    self.healthBar.outlineRight.Visible = true

    self.healthBar.outlineTop.From    = Vector2.new(barX - 1, top)
    self.healthBar.outlineTop.To      = Vector2.new(barX + 1, top)
    self.healthBar.outlineTop.Visible = true

    self.healthBar.outlineBottom.From    = Vector2.new(barX - 1, bottom)
    self.healthBar.outlineBottom.To      = Vector2.new(barX + 1, bottom)
    self.healthBar.outlineBottom.Visible = true

    self.healthBar.fill.From    = Vector2.new(barX, fillY)
    self.healthBar.fill.To      = Vector2.new(barX, bottom)
    self.healthBar.fill.Color   = HpToColor(pct)
    self.healthBar.fill.Visible = pct > 0

    if showText then
        local text = math.floor(hp) .. "/" .. math.floor(maxHp)
        local textWidth = #text * 5
        self.healthText.Text     = text
        self.healthText.Position = Vector2.new(math.round(barX - 2 - textWidth), math.round(top))
        self.healthText.Center   = false
        self.healthText.Color    = Color3.fromRGB(255, 255, 255)
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
end

function EspRenderer:Update(character, flags)
    local boxOn    = flags["Box ESP"]
    local hpBarOn  = flags["HP Bar"]
    local boxColor = (flags["Box Color"] and flags["Box Color"].Color) or Color3.fromRGB(255, 255, 255)

    if boxOn and character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChildOfClass("Humanoid") then
        local min, max = GetBoundingBox(character)
        if min and max then
            self:UpdateBox(min, max, boxColor)
            if hpBarOn then
                self:UpdateHealthBar(min, max, character, flags["Health Text"])
            else
                self:HideHealthBar()
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
end

return EspRenderer
