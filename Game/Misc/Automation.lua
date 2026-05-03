local Automation = {}

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local _flyPos     = nil
local _noclipConn = nil
local _infJumpConn = nil
local _noFallPart = nil

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHRP()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetFlyDirection()
    local dir = Vector3.new(0, 0, 0)
    local cam = workspace.CurrentCamera.CFrame
    local look  = Vector3.new(cam.LookVector.X,  0, cam.LookVector.Z).Unit
    local right = Vector3.new(cam.RightVector.X, 0, cam.RightVector.Z).Unit

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + look end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - look end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - right end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + right end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end

    return dir.Magnitude > 0 and dir.Unit or Vector3.new(0,0,0)
end

local function StartSpeedhack(speed)
    RunService:BindToRenderStep("SneezeSpeed", Enum.RenderPriority.Input.Value, function(dt)
        local flags = _G.Flags or {}
        if not flags["Speedhack"] then
            RunService:UnbindFromRenderStep("SneezeSpeed")
            return
        end
        local humanoid = GetHumanoid()
        local hrp = GetHRP()
        if humanoid and hrp and humanoid.Health > 0 then
            local spd = flags["Speedhack Value"] or speed or 100
            local dir = humanoid.MoveDirection
            if dir.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + dir * spd * dt
            end
        end
    end)
end

local function StopSpeedhack()
    RunService:UnbindFromRenderStep("SneezeSpeed")
end
    RunService:BindToRenderStep("SneezeFly", Enum.RenderPriority.Input.Value, function(dt)
        local flags = _G.Flags or {}
        if not flags["Fly"] then
            RunService:UnbindFromRenderStep("SneezeFly")
            _flyPos = nil
            return
        end
        local hrp = GetHRP()
        if not hrp then return end
        if not _flyPos then _flyPos = hrp.CFrame end
        local dir = GetFlyDirection()
        local spd = (flags["Fly Speed"] or speed or 100)
        if dir.Magnitude > 0 then
            _flyPos = _flyPos + dir * spd * dt
        end
        local look = workspace.CurrentCamera.CFrame.LookVector
        local lookFlat = Vector3.new(look.X, 0, look.Z)
        if lookFlat.Magnitude > 0 then
            _flyPos = CFrame.new(_flyPos.Position, _flyPos.Position + lookFlat.Unit)
        end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = _flyPos
    end)
end

local function StopFly()
    RunService:UnbindFromRenderStep("SneezeFly")
    _flyPos = nil
end

local function StartNoclip()
    _noclipConn = RunService.RenderStepped:Connect(function()
        local flags = _G.Flags or {}
        if not flags["Noclip"] then
            _noclipConn:Disconnect()
            _noclipConn = nil
            local char = GetCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
            return
        end
        local char = GetCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

local function StopNoclip()
    if _noclipConn then
        _noclipConn:Disconnect()
        _noclipConn = nil
    end
    local char = GetCharacter()
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

local function StartInfJump()
    _infJumpConn = UserInputService.JumpRequest:Connect(function()
        local flags = _G.Flags or {}
        if not flags["Inf Jump"] then
            _infJumpConn:Disconnect()
            _infJumpConn = nil
            return
        end
        local hrp = GetHRP()
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(
                hrp.AssemblyLinearVelocity.X,
                flags["Jump Power"] or 50,
                hrp.AssemblyLinearVelocity.Z
            )
        end
    end)
end

local function StopInfJump()
    if _infJumpConn then
        _infJumpConn:Disconnect()
        _infJumpConn = nil
    end
end

local function StartNoFall()
    if not workspace:FindFirstChild("_SneezeFallPart") then
        local p = Instance.new("Part", workspace)
        p.Name = "_SneezeFallPart"
        p.Size = Vector3.new(4, 1, 4)
        p.Transparency = 1
        p.CanCollide = true
        p.Anchored = true
        _noFallPart = p
    end
    RunService:BindToRenderStep("SneezeNoFall", Enum.RenderPriority.Last.Value, function()
        local flags = _G.Flags or {}
        if not flags["No Fall"] then
            RunService:UnbindFromRenderStep("SneezeNoFall")
            if _noFallPart then _noFallPart:Destroy() ; _noFallPart = nil end
            return
        end
        local hrp = GetHRP()
        if hrp and _noFallPart then
            _noFallPart.Position = hrp.Position - Vector3.new(0, 3, 0)
        end
    end)
end

local function StopNoFall()
    RunService:UnbindFromRenderStep("SneezeNoFall")
    if _noFallPart then _noFallPart:Destroy() ; _noFallPart = nil end
end

function Automation:Update()
    local flags = _G.Flags or {}

    if flags["Fly"] then StartFly() else StopFly() end
    if flags["Speedhack"] then StartSpeedhack() else StopSpeedhack() end
    if flags["Noclip"] then if not _noclipConn then StartNoclip() end else StopNoclip() end
    if flags["Inf Jump"] then if not _infJumpConn then StartInfJump() end else StopInfJump() end
    if flags["No Fall"] then StartNoFall() else StopNoFall() end
end

function Automation:Unload()
    StopFly()
    StopNoclip()
    StopInfJump()
    StopNoFall()
end

return Automation
