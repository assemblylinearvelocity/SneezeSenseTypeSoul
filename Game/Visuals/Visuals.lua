local Visuals = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer


local _connection = nil
local PlayerDrawings = {} -- [player] = { box = {Top,Bottom,Left,Right} }


local function GetBoundingBox(character)
    local min = Vector2.new(math.huge, math.huge)
    local max = Vector2.new(-math.huge, -math.huge)
    local anyOnScreen = false

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
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
                    min = Vector2.new(math.min(min.X, screen.X), math.min(min.Y, screen.Y))
                    max = Vector2.new(math.max(max.X, screen.X), math.max(max.Y, screen.Y))
                end
            end
        end
    end

    return anyOnScreen and min or nil, anyOnScreen and max or nil
end


local function NewBoxDrawings()
    local lines = {}
    for _, name in ipairs({ "Top", "Bottom", "Left", "Right" }) do
        local l = Drawing.new("Line")
        l.Visible   = false
        l.Thickness = 1
        l.Color     = Color3.fromRGB(255, 255, 255)
        lines[name] = l
    end
    return lines
end

local function SetBoxVisible(box, visible)
    for _, l in pairs(box) do l.Visible = visible end
end

local function DrawBox(box, min, max, color)
    local tl = Vector2.new(min.X, min.Y)
    local tr = Vector2.new(max.X, min.Y)
    local bl = Vector2.new(min.X, max.Y)
    local br = Vector2.new(max.X, max.Y)

    box.Top.From    = tl ; box.Top.To    = tr
    box.Bottom.From = bl ; box.Bottom.To = br
    box.Left.From   = tl ; box.Left.To   = bl
    box.Right.From  = tr ; box.Right.To  = br

    for _, l in pairs(box) do
        l.Color   = color or Color3.fromRGB(255, 255, 255)
        l.Visible = true
    end
end

local function RemovePlayerDrawings(player)
    local d = PlayerDrawings[player]
    if not d then return end
    if d.box then
        for _, l in pairs(d.box) do l:Remove() end
    end
    PlayerDrawings[player] = nil
end

local function EnsureDrawings(player)
    if not PlayerDrawings[player] then
        PlayerDrawings[player] = { box = NewBoxDrawings() }
    end
end


local function StartLoop()
    if _connection then return end

    _connection = RunService.RenderStepped:Connect(function()
        local flags    = _G.Flags or {}
        local boxOn    = flags["Box ESP"]
        local boxColor = (flags["Box Color"] and flags["Box Color"].Color) or Color3.fromRGB(255, 255, 255)

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end

            EnsureDrawings(player)
            local d         = PlayerDrawings[player]
            local character = player.Character

            if boxOn and character and character:FindFirstChild("HumanoidRootPart") then
                local min, max = GetBoundingBox(character)
                if min and max then
                    DrawBox(d.box, min, max, boxColor)
                else
                    SetBoxVisible(d.box, false)
                end
            else
                SetBoxVisible(d.box, false)
            end
        end
    end)
end

local function StopLoop()
    if _connection then
        _connection:Disconnect()
        _connection = nil
    end
end

local function AnyFeatureOn()
    local flags = _G.Flags or {}
    return flags["Box ESP"] 
end


function Visuals:Update()
    if AnyFeatureOn() then
        StartLoop()
    else
        StopLoop()
    end
end

function Visuals:Unload()
    StopLoop()
    for player in pairs(PlayerDrawings) do
        RemovePlayerDrawings(player)
    end
end

Players.PlayerRemoving:Connect(function(player)
    RemovePlayerDrawings(player)
end)

return Visuals
