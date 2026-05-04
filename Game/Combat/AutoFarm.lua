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

local function TeleportTo(pos)
    local hrp = GetHRP()
    if hrp then hrp.CFrame = CFrame.new(pos) end
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
                    if dist < downedD then
                        nearestDowned = child
                        downedD = dist
                    end
                elseif hum.Health > 0 then
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
    while _running do
        local flags = GetFlags()
        if not flags["Mission Farm"] then break end

        if not HasActiveQuest() then
            AcceptQuest()
        end

        local alive, downed = GetNearestTarget()

        if downed then
            local mobHRP = downed:FindFirstChild("HumanoidRootPart")
            if mobHRP then
                TeleportTo(mobHRP.Position + Vector3.new(0, -1, 0))
                task.wait(0.1)
                PressB()
                task.wait(0.3)
            end
        elseif alive then
            local mobHRP = alive:FindFirstChild("HumanoidRootPart")
            if mobHRP then
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
end

return AutoFarm
