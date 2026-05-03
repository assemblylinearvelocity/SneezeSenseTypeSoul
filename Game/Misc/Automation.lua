local Automation = {}

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer

local _flyPos         = nil
local _noclipConn     = nil
local _infJumpRunning = false

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHRP()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetFlyDirection()
    local dir   = Vector3.new(0, 0, 0)
    local cam   = workspace.CurrentCamera.CFrame
    local look  = Vector3.new(cam.LookVector.X,  0, cam.LookVector.Z).Unit
    local right = Vector3.new(cam.RightVector.X, 0, cam.RightVector.Z).Unit
    if UserInputService:IsKeyDown(Enum.KeyCode.W)           then dir = dir + look  end
    if UserInputService:IsKeyDown(Enum.KeyCode.S)           then dir = dir - look  end
    if UserInputService:IsKeyDown(Enum.KeyCode.A)           then dir = dir - right end
    if UserInputService:IsKeyDown(Enum.KeyCode.D)           then dir = dir + right end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then dir = dir + Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
    return dir.Magnitude > 0 and dir.Unit or Vector3.new(0,0,0)
end

local function StartFly()
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
        local spd = flags["Fly Speed"] or 100
        if dir.Magnitude > 0 then
            _flyPos = _flyPos + dir * spd * dt
        end
        local look = workspace.CurrentCamera.CFrame.LookVector
        local flat = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude > 0 then
            _flyPos = CFrame.new(_flyPos.Position, _flyPos.Position + flat.Unit)
        end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = _flyPos
    end)
end

local function StopFly()
    RunService:UnbindFromRenderStep("SneezeFly")
    _flyPos = nil
end

local function SetNoclip(state)
    local char = GetCharacter()
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = not state end
    end
end

local function StartNoclip()
    SetNoclip(true)
    _noclipConn = RunService.RenderStepped:Connect(function()
        local flags = _G.Flags or {}
        if not flags["Noclip"] then
            _noclipConn:Disconnect()
            _noclipConn = nil
            SetNoclip(false)
            return
        end
        SetNoclip(true)
    end)
end

local function StopNoclip()
    if _noclipConn then
        _noclipConn:Disconnect()
        _noclipConn = nil
    end
    SetNoclip(false)
end

local function StartSpeedhack()
    RunService:BindToRenderStep("SneezeSpeed", Enum.RenderPriority.Input.Value + 1, function(dt)
        local flags = _G.Flags or {}
        if not flags["Speedhack"] then
            RunService:UnbindFromRenderStep("SneezeSpeed")
            return
        end
        local char = GetCharacter()
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local moveDir = humanoid.MoveDirection
        if moveDir and moveDir.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + moveDir * ((flags["Speed Value"] or 100) * dt)
        end
    end)
end

local function StopSpeedhack()
    RunService:UnbindFromRenderStep("SneezeSpeed")
end

local function StartInfJump()
    if _infJumpRunning then return end
    _infJumpRunning = true
    coroutine.wrap(function()
        while _infJumpRunning do
            local flags = _G.Flags or {}
            if not flags["Inf Jump"] then
                _infJumpRunning = false
                break
            end
            local char = GetCharacter()
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Jump then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    hrp.AssemblyLinearVelocity.X,
                    flags["Jump Power"] or 50,
                    hrp.AssemblyLinearVelocity.Z
                )
            end
            task.wait(0.1)
        end
    end)()
end

local function StopInfJump()
    _infJumpRunning = false
end

function Automation:Update()
    local flags = _G.Flags or {}
    if flags["Fly"]       then StartFly()                                else StopFly()       end
    if flags["Speedhack"] then StartSpeedhack()                          else StopSpeedhack() end
    if flags["Noclip"]    then if not _noclipConn then StartNoclip() end else StopNoclip()    end
    if flags["Inf Jump"]  then StartInfJump()                            else StopInfJump()   end
end

function Automation:Unload()
    StopFly()
    StopNoclip()
    StopSpeedhack()
    StopInfJump()
end

return Automation
