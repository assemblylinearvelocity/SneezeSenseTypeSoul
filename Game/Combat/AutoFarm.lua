local AutoFarm = {}

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer      = Players.LocalPlayer

local _Library  = nil
local _running  = false
local _thread   = nil

local function GetFlags()
    return _Library and _Library.Flags or {}
end

local function GetHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function TeleportTo(position)
    local hrp = GetHRP()
    if hrp then
        hrp.CFrame = CFrame.new(position)
    end
end

local function HasQueueUI()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("QueueUI")
    return gui and gui.Enabled
end

local function GetNearestMissionNPC()
    local hrp = GetHRP()
    if not hrp then return nil end
    local missionFolder = workspace.NPCs:FindFirstChild("MissionNPC")
    if not missionFolder then return nil end

    local nearest, nearestDist = nil, math.huge
    for _, child in ipairs(missionFolder:GetChildren()) do
        if child:IsA("Model") or child:IsA("BasePart") then
            local pivot = pcall(function() return child:GetPivot() end) and child:GetPivot()
            if pivot then
                local dist = (hrp.Position - pivot.Position).Magnitude
                if dist < nearestDist then
                    nearest = child
                    nearestDist = dist
                end
            end
        end
    end
    return nearest
end

local function AcceptQuest(npc)
    local hrp = GetHRP()
    if not hrp or not npc then return end

    local pivot = npc:GetPivot()
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

local function GetNearestMob(mobName)
    local hrp = GetHRP()
    if not hrp then return nil end

    local nearest, nearestDist = nil, math.huge
    local entities = workspace:FindFirstChild("Entities")
    if not entities then return nil end

    for _, child in ipairs(entities:GetChildren()) do
        if child:IsA("Model") then
            local name = child.Name:match("^([^_]+)") or child.Name
            if name:lower() == mobName:lower() then
                local humanoid = child:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local mobHRP = child:FindFirstChild("HumanoidRootPart")
                    if mobHRP then
                        local dist = (hrp.Position - mobHRP.Position).Magnitude
                        if dist < nearestDist then
                            nearest = child
                            nearestDist = dist
                        end
                    end
                end
            end
        end
    end
    return nearest
end

local function AttackMob()
    pcall(function()
        ReplicatedStorage:WaitForChild("Remotes")
            :WaitForChild("ServerCombatHandler")
            :FireServer("LightAttack")
    end)
end

local function FarmLoop()
    while _running do
        local flags = GetFlags()
        if not flags["Auto Farm"] then break end

        local mobName = flags["Farm Mob"] or "Shinigami"

        if not HasQueueUI() then
            local npc = GetNearestMissionNPC()
            if npc then
                AcceptQuest(npc)
            end
        end

        local mob = GetNearestMob(mobName)
        if mob then
            local mobHRP = mob:FindFirstChild("HumanoidRootPart")
            if mobHRP then
                TeleportTo(mobHRP.Position + Vector3.new(0, -2, 0))
                task.wait(0.05)
                AttackMob()
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
    if flags["Auto Farm"] then
        if not _running then
            _running = true
            _thread = task.spawn(FarmLoop)
        end
    else
        _running = false
    end
end

function AutoFarm:Unload()
    _running = false
end

return AutoFarm
