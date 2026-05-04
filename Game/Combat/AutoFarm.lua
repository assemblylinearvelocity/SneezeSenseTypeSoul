local AutoFarm = {}

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local VIM               = game:GetService("VirtualInputManager")
local LocalPlayer       = Players.LocalPlayer

local _Library = nil
local _running = false

local function GetFlags()
    return _Library and _Library.Flags or {}
end

local function GetHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local TweenService = game:GetService("TweenService")

local function TeleportTo(pos)
    local hrp = GetHRP()
    if not hrp then return end
    local dist = (hrp.Position - pos).Magnitude
    if dist < 5 then
        hrp.CFrame = CFrame.new(pos)
        return
    end
    local speed = 100
    local duration = dist / speed
    local startPos = hrp.Position
    local elapsed = 0
    while elapsed < duration do
        local hrp2 = GetHRP()
        if not hrp2 then break end
        elapsed = elapsed + task.wait()
        local alpha = math.min(elapsed / duration, 1)
        hrp2.CFrame = CFrame.new(startPos:Lerp(pos, alpha), pos)
        hrp2.AssemblyLinearVelocity = Vector3.zero
    end
    local hrp3 = GetHRP()
    if hrp3 then hrp3.CFrame = CFrame.new(pos) end
end

local function HasActiveQuest()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("QueueUI")
    return gui and gui.Enabled
end

local function Attack()
    pcall(function()
        ReplicatedStorage:WaitForChild("Remotes")
            :WaitForChild("ServerCombatHandler")
            :FireServer("LightAttack")
    end)
end

local function PressB()
    VIM:SendKeyEvent(true,  Enum.KeyCode.B, false, game)
    task.wait(0.1)
    VIM:SendKeyEvent(false, Enum.KeyCode.B, false, game)
end

local function GetNearestMissionNPC()
    local hrp = GetHRP()
    if not hrp then return nil end
    local folder = workspace.NPCs:FindFirstChild("MissionNPC")
    if not folder then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, child in ipairs(folder:GetChildren()) do
        local ok, pivot = pcall(function() return child:GetPivot() end)
        if ok and pivot then
            local dist = (hrp.Position - pivot.Position).Magnitude
            if dist < nearestDist then
                nearest = child
                nearestDist = dist
            end
        end
    end
    return nearest
end

local function AcceptQuest()
    local npc = GetNearestMissionNPC()
    if not npc then return end
    local ok, pivot = pcall(function() return npc:GetPivot() end)
    if not ok then return end
    TeleportTo(pivot.Position + Vector3.new(0, 3, 0))
    task.wait(0.5)
    for _, v in ipairs(npc:GetDescendants()) do
        if v:IsA("ClickDetector") then
            pcall(fireclickdetector, v)
            break
        end
    end
    task.wait(2)
    pcall(function()
        local dialogue = LocalPlayer.PlayerGui:FindFirstChild("Dialogue", true)
        if dialogue then
            local yes = dialogue.Main.Container.Choices.Yes
            for _, conn in ipairs(getconnections(yes.MouseButton1Click)) do
                conn:Fire()
            end
        end
    end)
    task.wait(1)
end

local FARM_RANGE  = 150
local GRIP_RANGE  = 20

-- Tracks mobs we have attacked so we only grip our own kills
local _attackedMobs = {}

local function GetNearestTarget()
    local hrp = GetHRP()
    if not hrp then return nil, nil end
    local entities = workspace:FindFirstChild("Entities")
    if not entities then return nil, nil end

    local nearestAlive,   aliveD   = nil, math.huge
    local nearestDowned,  downedD  = nil, math.huge

    for _, child in ipairs(entities:GetChildren()) do
        if child:IsA("Model") and not Players:GetPlayerFromCharacter(child) then
            local hum    = child:FindFirstChildOfClass("Humanoid")
            local mobHRP = child:FindFirstChild("HumanoidRootPart")
            if hum and mobHRP then
                local dist  = (hrp.Position - mobHRP.Position).Magnitude
                local state = child:GetAttribute("CurrentState")

                if state == "Unconscious" then
                    -- Only grip mobs we attacked, and only if they're close enough
                    -- (don't teleport across the map to grip random downed mobs)
                    if _attackedMobs[child] and dist <= GRIP_RANGE then
                        if dist < downedD then
                            nearestDowned = child
                            downedD = dist
                        end
                    end
                elseif hum.Health > 0 and dist <= FARM_RANGE then
                    if dist < aliveD then
                        nearestAlive = child
                        aliveD = dist
                    end
                end
            end
        end
    end

    return nearestAlive, nearestDowned
end

local function FarmLoop()
    -- Clear the attacked-mob registry each new farm session
    _attackedMobs = {}

    while _running do
        local flags = GetFlags()
        if not flags["Mission Farm"] then break end

        if not HasActiveQuest() then
            AcceptQuest()
            task.wait(1)
            continue
        end

        -- Prune mobs that have been removed from the workspace (already gripped/dead)
        for mob in pairs(_attackedMobs) do
            if not mob.Parent then
                _attackedMobs[mob] = nil
            end
        end

        local alive, downed = GetNearestTarget()

        if downed then
            local mobHRP = downed:FindFirstChild("HumanoidRootPart")
            if mobHRP then
                TeleportTo(mobHRP.Position + Vector3.new(0, -1, 0))
                task.wait(0.1)
                PressB()
                task.wait(0.3)
                -- Remove from registry after gripping
                _attackedMobs[downed] = nil
            end
        elseif alive then
            local mobHRP = alive:FindFirstChild("HumanoidRootPart")
            if mobHRP then
                -- Register this mob as one we are attacking
                _attackedMobs[alive] = true
                TeleportTo(mobHRP.Position + Vector3.new(0, -2, 0))
                task.wait(0.05)
                Attack()
            end
        end

        task.wait(0.1)
    end
    _running = false
end

function AutoFarm:Init(Library)
    _Library = Library
end

function AutoFarm:Update()
    local flags = GetFlags()
    if flags["Mission Farm"] then
        if not _running then
            _running = true
            task.spawn(FarmLoop)
        end
    else
        _running = false
    end
end

function AutoFarm:Unload()
    _running = false
    _attackedMobs = {}
end

return AutoFarm
