local PlayerRenderer = {}
PlayerRenderer.__index = PlayerRenderer

local Camera = workspace.CurrentCamera

local BODY_PARTS = {
    "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart"
}

local function NewLine(color, thickness)
    local l = Drawing.new("Line")
    l.Visible = false
    l.Color = color
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
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyOnScreen = false

    for _, partName in ipairs(BODY_PARTS) do
        local part = character:FindFirstChild(partName)
        if not part or not part:IsA("BasePart") then continue end

        local size = part.Size
        local cf = part.CFrame

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
    return Vector2.new(minX, minY), Vector2.new(maxX, maxY)
end

function PlayerRenderer.new(player)
    local self = setmetatable({}, PlayerRenderer)
    self.player = player
    self.box = {
        outer = NewBoxSet(Color3.fromRGB(0, 0, 0), 1),
        main  = NewBoxSet(Color3.fromRGB(255, 255, 255), 1),
        inner = NewBoxSet(Color3.fromRGB(0, 0, 0), 1),
    }
    return self
end

function PlayerRenderer:UpdateBox(min, max, color)
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

function PlayerRenderer:HideBox()
    for _, set in pairs(self.box) do
        SetSetVisible(set, false)
    end
end

function PlayerRenderer:Update(character, flags)
    local boxOn = flags["Box ESP"]
    local boxColor = (flags["Box Color"] and flags["Box Color"].Color) or Color3.fromRGB(255, 255, 255)

    if boxOn and character and character:FindFirstChild("HumanoidRootPart") then
        local min, max = GetBoundingBox(character)
        if min and max then
            self:UpdateBox(min, max, boxColor)
        else
            self:HideBox()
        end
    else
        self:HideBox()
    end
end

function PlayerRenderer:Destroy()
    for _, set in pairs(self.box) do
        for _, l in pairs(set) do l:Remove() end
    end
end

return PlayerRenderer
