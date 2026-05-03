if not game:IsLoaded() then
	game.Loaded:Wait()
end

getsynasset = getcustomasset
syn_io_listdir = listfiles

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
--
local function requireShit(object)
	local object = game:GetObjects(getsynasset(object))[1]
	object=object:Clone()
	local source = object.Source
	local shit = loadstring(source,object.Name)
	local origEnv = getfenv(shit);
	getfenv(shit).script = object;
	getfenv(shit).require=function(what)
		return requireShit(what);
	end
	local dat = {pcall(function()   
		return shit();   
	end)}   
	if(dat[1]==false)then
		warn(dat[2])
		return nil
	else
		table.remove(dat,1)
		return unpack(dat)
	end
end

local SpringClass = nil
local RaceData = nil
local KeyframeService = nil
local DressUp = nil
local GenderCalculator = nil

local RanOnce = false

local ConfigData = {
	CustomScales = nil,
	ShowChest = true,
	ShowButt = true,
	ShowCrotch = false,
	ApplyToOthers = true,
	UtilizeGender = false,
}

game.Close:Connect(function()
	if not RunService:IsStudio() then
		writefile("BoobWokenData/Configurations.txt",game["HttpService"]:JSONEncode(ConfigData))
	else 
		warn("heehehaha i am se lf a ware that im in stu d i o l ma")
		warn("I Should've saved : ",game["HttpService"]:JSONEncode(ConfigData))
	end
end)

-- INSERT THE LOAD DAMN IT (badumtss.)

if not RunService:IsStudio() then
	if isfile("BoobWokenData/Configurations.txt") then
		ConfigData = game["HttpService"]:JSONDecode(readfile("BoobWokenData/Configurations.txt"))
	end
else
	wait(5)
	warn("something something trying to load something penis")
end

local ConfigGui = nil
local TrackedRigs = {}

if not RunService:IsStudio() then
	SpringClass = requireShit("BoobWokenData/SpringClass.rbxm")
	RaceData = requireShit("BoobWokenData/RaceModule.rbxm")
	KeyframeService = requireShit("BoobWokenData/KeyframeService.rbxm")
	DressUp = requireShit("BoobWokenData/DressUpCharacter.rbxm")
	GenderCalculator = requireShit("BoobWokenData/CalculateGender.rbxm")
	ConfigGui = game:GetObjects(getsynasset("BoobWokenData/CustomizeGui.rbxm"))[1]
	ConfigGui.Parent = game.CoreGui
else 
	SpringClass = require(script:WaitForChild("SpringClass"))
	RaceData = require(script:WaitForChild("RaceModule"))
	KeyframeService = require(script:WaitForChild("KeyframeService"))
	DressUp = require(script:WaitForChild("DressUpCharacter"))	
	GenderCalculator = require(script:WaitForChild("CalculateGender"))
	ConfigGui = script:WaitForChild("bwgui")
	ConfigGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

ConfigGui.Enabled = true

--

--game:GetService("Workspace").Live[".crocco7648"].CustomRig

function BreastPhysics(Model,HumRoot,Scale)
	if not SpringClass then
		return
	end
	
	spawn(function()
		local P = Model:FindFirstChild("BoobJ",true)
		local A = Model:FindFirstChild("BJ",true)
		
		if  P then
			local OGC0 = P.C0
			local OGC02 = A.C0

			local Torso = HumRoot.Parent.Torso

			local BreastSpring = SpringClass.new(Vector3.new(0,0,0))
			BreastSpring.Target = Vector3.new(3,3,3);
			BreastSpring.Velocity = Vector3.new(0,0,0);
			BreastSpring.Speed = 10;
			BreastSpring.Damper = .2;

			local AssSpring = SpringClass.new(Vector3.new(0,0,0))
			AssSpring.Target = Vector3.new(3,3,3);
			AssSpring.Velocity = Vector3.new(0,0,0);
			AssSpring.Speed = 10;
			AssSpring.Damper = .1;


			local OGR = Torso.RotVelocity
			local OGP = Torso.Position

			local StepConn 

			StepConn = RunService.Stepped:Connect(function(t,d)
				if not Model.Parent or not HumRoot.Parent or not HumRoot.Parent.Parent then
					Model:Destroy()
					StepConn:Disconnect()
					AssSpring = nil 
					BreastSpring = nil
					return
				end


				local CURRP = Torso.Position
				local CurrRot = Torso.RotVelocity

				BreastSpring:TimeSkip(d)
				BreastSpring:Impulse((OGP - CURRP) + Vector3.new((OGR - CurrRot).Y/4),0,0)

				--print(BreastSpring.Velocity.Z)

				P.C0 = OGC0 * CFrame.Angles(
					math.rad(10*BreastSpring.Velocity.Y)
					,
					math.rad(5*BreastSpring.Velocity.X)
					,
					0
					--math.rad(5*BreastSpring.Velocity.Z)
				)


				AssSpring:TimeSkip(d)
				AssSpring:Impulse((OGP - CURRP) + Vector3.new(0,0,(OGR - CurrRot).Y/4))

				--print(BreastSpring.Velocity.Z)

				A.C0 = OGC02 * CFrame.Angles(
					math.rad(3*AssSpring.Velocity.Y)
					,
					math.rad(3*AssSpring.Velocity.X)
					,
					math.rad(2*AssSpring.Velocity.Z)
					--math.rad(5*BreastSpring.Velocity.Z)
				)

				OGR = CurrRot
				OGP = CURRP

			end)
		else 
			local OGC02 = A.C0

			local Torso = HumRoot.Parent.Torso

			local AssSpring = SpringClass.new(Vector3.new(0,0,0))
			AssSpring.Target = Vector3.new(3,3,3);
			AssSpring.Velocity = Vector3.new(0,0,0);
			AssSpring.Speed = 10;
			AssSpring.Damper = .1;


			local OGR = Torso.RotVelocity
			local OGP = Torso.Position



			local StepConn 

			StepConn = RunService.Stepped:Connect(function(t,d)
				if not Model.Parent or not HumRoot.Parent or not HumRoot.Parent.Parent then
					warn("dc'd")
					Model:Destroy()
					StepConn:Disconnect()
					AssSpring = nil 
					return
				end


				local CURRP = Torso.Position
				local CurrRot = Torso.RotVelocity


				AssSpring:TimeSkip(d)
				AssSpring:Impulse((OGP - CURRP) + Vector3.new(0,0,(OGR - CurrRot).Y/4))

				--print(BreastSpring.Velocity.Z)

				A.C0 = OGC02 * CFrame.Angles(
					math.rad(3*AssSpring.Velocity.Y)
					,
					math.rad(3*AssSpring.Velocity.X)
					,
					math.rad(2*AssSpring.Velocity.Z)
					--math.rad(5*BreastSpring.Velocity.Z)
				)

				OGR = CurrRot
				OGP = CURRP

			end)
		end
				

	end)
end


local function RegisterSlider(Gui:Frame)
	local Methods = {}
	local RunMe = {}
	
	local Button = Gui.Button

	local Min,Max = 0,Gui.AbsoluteSize.X
	local BoundaryMinX,BoundaryMaxX = Min,Max

	local CurrentValue = 0

	local IsInside = false
	local LetGo = true

	local OgPos = Gui.Button.Position
	local MouseX = UserInputService:GetMouseLocation().X

	local LoopConn = nil

	Button.MouseEnter:Connect(function()
		IsInside = true
	end)

	Button.MouseLeave:Connect(function()
		IsInside = false
	end)

	function Methods:SetBoundaries(min,max)
		-- assume x is 0-1.
		BoundaryMinX = Max*min
		BoundaryMaxX = Max*max		
	end

	function Methods:SetValue(x)
		CurrentValue = x
		Gui.Button.Position = UDim2.fromOffset(Max*x,OgPos.Y.Offset)
	end


	function Methods:GetValue()
		return CurrentValue
	end
	
	Methods.Updated = {
		Connect = function(self,func)
			local Index = #RunMe+1
			RunMe[Index] = func
						
			return {
				Disconnect = function(self)
					RunMe[Index] = nil
				end,
			}
			
		end,
	}

	UserInputService.InputBegan:Connect(function(io,gpe)
		if io.UserInputType == Enum.UserInputType.MouseButton1 then
			if IsInside == true then
				OgPos = Gui.Button.Position
				MouseX = UserInputService:GetMouseLocation().X

				LetGo = false
				LoopConn = RunService.RenderStepped:Connect(function()
					if LetGo == true then
						LoopConn:Disconnect()
					else 
						local XDiff = UserInputService:GetMouseLocation().X - MouseX
						local NewPos = OgPos + UDim2.fromOffset(XDiff,0)

						if NewPos.X.Offset < BoundaryMinX then
							NewPos = UDim2.fromOffset(BoundaryMinX,OgPos.Y.Offset)
						elseif NewPos.X.Offset > BoundaryMaxX then
							NewPos = UDim2.fromOffset(BoundaryMaxX,OgPos.Y.Offset)
						end
						
						CurrentValue = NewPos.X.Offset/Max
					
						for _,func in pairs(RunMe) do 
							func(CurrentValue)
						end
						--warn(NewValue)
						Gui.Button.Position = NewPos
					end
				end)
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(io,gpe)
		if io.UserInputType == Enum.UserInputType.MouseButton1 then
			LetGo = true
		end
	end)

	return Methods
end



local ButtSlider = RegisterSlider(ConfigGui.CharacterFrame.Characters.ButtSlider)
local ChestSlider = RegisterSlider(ConfigGui.CharacterFrame.Characters.ChestSlider)
local CrotchSlider = RegisterSlider(ConfigGui.CharacterFrame.Characters.CrotchSlider)

local PreviousB,PreviousC,PreviousCDeez = nil,nil,nil



function CheckIfValidRigAndApply(Model,ApplyPhysics,...)
	wait(.03)
	spawn(function()
		wait(.6)
		-- run asynchronysly.
		local Player = Players:FindFirstChild(Model.Name)
		
		if not Player or Player ~= LocalPlayer then
			if ConfigData.ApplyToOthers == false then
				return
			end
		end
		
		local HumanoidRootPart = Model:FindFirstChild("HumanoidRootPart")
		if not HumanoidRootPart then
			HumanoidRootPart = Model:WaitForChild("HumanoidRootPart")
		end

		local Torso = Model:WaitForChild("Torso")		
		local Humanoid = Model:FindFirstChild("Humanoid")
		local x = true


		if Model:FindFirstChild("CustomRig") or (Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15) then
			return
		end -- we dont need floating tiddies again
		
		local Name = Model.Name
		if string.len(Humanoid.DisplayName) > 1 then
			Name = Humanoid.DisplayName
		end
		--	warn(Name)
		local FirstName = Name 
		if string.find(FirstName," ") then
			FirstName = string.sub(Name,1,string.find(FirstName," ") - 1)
		end
		--	warn(FirstName)

		local Race,Varient = RaceData:GetRaceFromSkinTone(Torso.Color)
		local Scales = RaceData:ScaleViaNameAndRace(Name,Race)
		local Gender = GenderCalculator:DetermineGender(Model,((Player and FirstName) or nil))
		--local Gender = 1

		local NewRig = nil
		

		--[[
		if Gender == 1 then	
			NewRig = DressUp:ApplyFemBody(RaceData,Model)
		elseif Gender == 0 then
			--NewRig = DressUp:ApplyMaleBody(RaceData,Model)
		elseif Gender == 2 then
			--NewRig = DressUp:ApplyHermBody(RaceData,Model)
		end
		]]
		
	

		if Player == LocalPlayer then
			if ConfigData.CustomScales then
				if RanOnce == false then
					ButtSlider:SetValue(ConfigData.CustomScales.Ass)
					ChestSlider:SetValue(ConfigData.CustomScales.Breasts)
					CrotchSlider:SetValue(ConfigData.CustomScales.Dick)
				end
				
				if ConfigData.UtilizeGender and Gender == 0 then
					NewRig = DressUp:ApplyMaleBody(RaceData,Model,ConfigData.CustomScales)
				else 
					NewRig = DressUp:ApplyFemBody(RaceData,Model,ConfigData.CustomScales)
				end
				
			else 
				if RanOnce == false then
					ButtSlider:SetValue(Scales.Ass)
					ChestSlider:SetValue(Scales.Breasts)
					CrotchSlider:SetValue(Scales.Dick)
				end
				
				if ConfigData.UtilizeGender and Gender == 0 then
					NewRig = DressUp:ApplyMaleBody(RaceData,Model,Scales)
				else 
					NewRig = DressUp:ApplyFemBody(RaceData,Model,Scales)
				end			
			end

			if PreviousB then
				PreviousB:Disconnect()
				PreviousB = nil	
			end

			PreviousB = ButtSlider.Updated:Connect(function(value)
				ConfigData.CustomScales = {
					Ass = value,Breasts = ChestSlider:GetValue(),Dick = CrotchSlider:GetValue()
				}
				DressUp.ScalingFunctions:AssScaler(NewRig,value)
			end)

			if PreviousC then
				PreviousC:Disconnect()
				PreviousC = nil
			end

			PreviousC = ChestSlider.Updated:Connect(function(value)
				ConfigData.CustomScales = {
					Ass = ButtSlider:GetValue(),Breasts = value,Dick = CrotchSlider:GetValue()
				}
				if NewRig.T.RT:FindFirstChild("Bust") then
					DressUp.ScalingFunctions:BreastScaler(NewRig,value)
				end
			end)
			
			if PreviousCDeez then
				PreviousCDeez:Disconnect()
				PreviousCDeez = nil
			end
			
			PreviousCDeez = CrotchSlider.Updated:Connect(function(value)
				ConfigData.CustomScales = {
					Ass = ButtSlider:GetValue(),Breasts = ChestSlider:GetValue(),Dick = value
				}
				if NewRig.T.RT:FindFirstChild("Groin") then
					DressUp.ScalingFunctions:CrotchScaler(NewRig,value)
				end
			end)


			if RanOnce == false then
				RanOnce = true
			end
		else 
			if ConfigData.UtilizeGender and Gender == 0 then
				NewRig = DressUp:ApplyMaleBody(RaceData,Model,Scales)
			else 
				NewRig = DressUp:ApplyFemBody(RaceData,Model,Scales)
			end			
		end
		
		if NewRig then
			
			if not ConfigData.ShowButt then
				NewRig.T.RT.Butt["Left Cheek"].Transparency = 1
				NewRig.T.RT.Butt["Right Cheek"].Transparency = 1
				NewRig.T.RT.Butt["Left Cheek"].Shirt.Transparency = 1
				NewRig.T.RT.Butt["Right Cheek"].Shirt.Transparency = 1
				NewRig.T.RT.Butt["Left Cheek"].Pants.Transparency = 1
				NewRig.T.RT.Butt["Right Cheek"].Pants.Transparency = 1
			end
			
			if not ConfigData.ShowChest and NewRig.T.RT:FindFirstChild("Bust") then
				NewRig.T.RT.Bust.Shirt.Transparency = 1
				NewRig.T.RT.Bust.Pants.Transparency = 1
				NewRig.T.RT.Bust.VisualBust.Transparency = 1
				NewRig.T.RT.Bust.VisualBust.Are.Transparency = 1
			end
			
			if not ConfigData.ShowCrotch and NewRig.T.RT:FindFirstChild("Groin") then
				NewRig.T.RT.Groin.Shirt.Transparency = 1
				NewRig.T.RT.Groin.Pants.Transparency = 1
				NewRig.T.RT.Groin.Transparency = 1
			end
			
			TrackedRigs[#TrackedRigs+1] = NewRig

			if ApplyPhysics then
				
				if not HumanoidRootPart or not HumanoidRootPart.Parent or HumanoidRootPart.Parent ~= Model or Model.Parent == nil then
					NewRig:Destroy()
				else 
					BreastPhysics(NewRig,HumanoidRootPart,1)
				end

				--[[
				if Gender == 1 then
					BreastPhysics(NewRig,HumanoidRootPart,1)	
				end
				]]
			end
		else 
			warn("Unsuccessfull, "..tostring(Model))
			return
		end

		return NewRig
	end)
end

-- dw
local NPCADDED = nil
local LIVEADDED = nil
-- lol

ConfigGui.CharacterFrame.Characters.ReplicateButton.Toggle.MouseButton1Click:Connect(function()
	ConfigData.ApplyToOthers = not ConfigData.ApplyToOthers
	ConfigGui.CharacterFrame.Characters.ReplicateButton.Tick.TextLabel.Visible = ConfigData.ApplyToOthers
	if not ConfigData.ApplyToOthers then
		
		if NPCADDED then
			NPCADDED:Disconnect()
			NPCADDED = nil
		end
		
		if LIVEADDED then
			LIVEADDED:Disconnect()
			LIVEADDED = nil	
		end
		
		for i,Rig in pairs(TrackedRigs) do
			if Rig.Parent then
				local Model = Rig.Parent
				if not (Players:FindFirstChild(Model.Name) == LocalPlayer) then
					TrackedRigs[i] = nil
					Rig:Destroy()

					pcall(function()
						Model["Left Leg"].Transparency = 0
						Model["Right Leg"].Transparency = 0
						Model["Torso"].Transparency = 0
						Model["Right Arm"].Transparency = 0
						Model["Left Arm"].Transparency = 0

					end)	
				end
			else 
				TrackedRigs[i] = nil
			end
		end
		
	else 
		
		if (game.CreatorId == 5212858 or RunService:IsStudio()) then
			local LiveFolder = workspace:WaitForChild("Live")
			local NPCFolder = workspace:WaitForChild("NPCs")
			
			for i,m in pairs(LiveFolder:GetChildren()) do
				if m:IsA("Model") and not (Players:FindFirstChild(m.Name) == LocalPlayer) then
					CheckIfValidRigAndApply(m,true)
				end
			end

			LIVEADDED = LiveFolder.ChildAdded:Connect(function(m)
				if m:IsA("Model") then
					CheckIfValidRigAndApply(m,true)
				end
			end)
			
			for i,m in pairs(NPCFolder:GetChildren()) do
				if m:IsA("Model") then
					CheckIfValidRigAndApply(m,false)
				end
			end	

			NPCADDED = NPCFolder.ChildAdded:Connect(function(m)
				if m:IsA("Model") then
					CheckIfValidRigAndApply(m,false)
				end
			end)

		else 
			--if game.CreatorId == 5212858 then
			for i,v in pairs(Players:GetPlayers()) do 
				if v ~= LocalPlayer then
					if v.Character then 
						CheckIfValidRigAndApply(v.Character,true)    
					end
				end
			end

			NPCADDED = Players.PlayerAdded:Connect(function(v)
				if v.Character then 
					CheckIfValidRigAndApply(v.Character,true)    
				end
				v.CharacterAdded:Connect(function()
					spawn(function()
						wait(1)
						CheckIfValidRigAndApply(v.Character,true)  
					end)  
				end)  
			end)
		end
		
	end
end)


ConfigGui.CharacterFrame.Characters.ButtButton.Toggle.MouseButton1Click:Connect(function()
	ConfigData.ShowButt = not ConfigData.ShowButt
	ConfigGui.CharacterFrame.Characters.ButtButton.Tick.TextLabel.Visible = ConfigData.ShowButt
	
	if ConfigData.ShowButt then
		for _,v in pairs(TrackedRigs) do 
			pcall(function()
				v.T.RT.Butt["Left Cheek"].Transparency = 0
				v.T.RT.Butt["Right Cheek"].Transparency = 0
				v.T.RT.Butt["Left Cheek"].Shirt.Transparency = 0
				v.T.RT.Butt["Right Cheek"].Shirt.Transparency = 0
				v.T.RT.Butt["Left Cheek"].Pants.Transparency = 0
				v.T.RT.Butt["Right Cheek"].Pants.Transparency = 0
			end)
		end	
	else 
		for _,v in pairs(TrackedRigs) do 
			pcall(function()
				v.T.RT.Butt["Left Cheek"].Transparency = 1
				v.T.RT.Butt["Right Cheek"].Transparency = 1
				v.T.RT.Butt["Left Cheek"].Shirt.Transparency = 1
				v.T.RT.Butt["Right Cheek"].Shirt.Transparency = 1
				v.T.RT.Butt["Left Cheek"].Pants.Transparency = 1
				v.T.RT.Butt["Right Cheek"].Pants.Transparency = 1
			end)
		end	
	end
	
end)

ConfigGui.CharacterFrame.Characters.ChestButton.Toggle.MouseButton1Click:Connect(function()
	ConfigData.ShowChest = not ConfigData.ShowChest
	ConfigGui.CharacterFrame.Characters.ChestButton.Tick.TextLabel.Visible = ConfigData.ShowChest
	
	if ConfigData.ShowChest then
		for _,v in pairs(TrackedRigs) do 
			pcall(function()
				if v.T.RT:FindFirstChild("Bust") then
					v.T.RT.Bust.Shirt.Transparency = 0
					v.T.RT.Bust.Pants.Transparency = 0
					v.T.RT.Bust.VisualBust.Transparency = 0
					v.T.RT.Bust.VisualBust.Are.Transparency = 0
				end
			end)
		end
	else 
		for _,v in pairs(TrackedRigs) do 
			pcall(function()
				if v.T.RT:FindFirstChild("Bust") then
					v.T.RT.Bust.Shirt.Transparency = 1
					v.T.RT.Bust.Pants.Transparency = 1
					v.T.RT.Bust.VisualBust.Transparency = 1
					v.T.RT.Bust.VisualBust.Are.Transparency = 1
				end
			end)
		end
	end
	
end)

ConfigGui.CharacterFrame.Characters.CrotchButton.Toggle.MouseButton1Click:Connect(function()
	ConfigData.ShowCrotch = not ConfigData.ShowCrotch
	ConfigGui.CharacterFrame.Characters.CrotchButton.Tick.TextLabel.Visible = ConfigData.ShowCrotch

	if ConfigData.ShowCrotch then
		for _,v in pairs(TrackedRigs) do 
			pcall(function()
				if v.T.RT:FindFirstChild("Groin") then
					v.T.RT.Groin.Shirt.Transparency = 0
					v.T.RT.Groin.Pants.Transparency = 0
					v.T.RT.Groin.Transparency = 0
				end
			end)
		end
	else 
		for _,v in pairs(TrackedRigs) do 
			pcall(function()
				if v.T.RT:FindFirstChild("Groin") then
					v.T.RT.Groin.Shirt.Transparency = 1
					v.T.RT.Groin.Pants.Transparency = 1
					v.T.RT.Groin.Transparency = 1
				end
			end)
		end
	end

end)


ConfigGui.CharacterFrame.Characters.GenderButton.Toggle.MouseButton1Click:Connect(function()
	ConfigData.UtilizeGender = not ConfigData.UtilizeGender
	ConfigGui.CharacterFrame.Characters.GenderButton.Tick.TextLabel.Visible = ConfigData.UtilizeGender
	
	
	if ConfigData.UtilizeGender then
		for i,v in pairs(TrackedRigs) do
			if v.Parent then
				local Model = v.Parent
				local Humanoid = Model:FindFirstChildOfClass("Humanoid")

				local Name = Model.Name
				if string.len(Humanoid.DisplayName) > 1 then
					Name = Humanoid.DisplayName
				end
				--	warn(Name)
				local FirstName = Name 
				if string.find(FirstName," ") then
					FirstName = string.sub(Name,1,string.find(FirstName," ") - 1)
				end
				--	warn(FirstName)

				local Gender = GenderCalculator:DetermineGender(Model,((Players:FindFirstChild(Model.Name) and FirstName) or nil))

				if Gender == 0 and v.Name == "FemRig" then
					v:Destroy()
					CheckIfValidRigAndApply(Model,not (Model.Parent.Name == "NPCs" or false))  
				end					
			else 
				TrackedRigs[i] = nil
			end
	
		end
	else 
		for i,v in pairs(TrackedRigs) do
			if v.Parent then
				local Model = v.Parent
				if v.Name ~= "FemRig" then
					v:Destroy()
					CheckIfValidRigAndApply(Model,not (Model.Parent.Name == "NPCs" or false))  
				end					
			else 
				TrackedRigs[i] = nil
			end
	
		end	
	end
end)

if not RunService:IsStudio() then
	ConfigGui.CreditF.Kofi.MouseButton1Click:Connect(function()
		setclipboard("https://ko-fi.com/ukiyodev")
		ConfigGui.CreditF.PaddinglessBehavoir.Copied.Visible = true
		delay(1,function()
			ConfigGui.CreditF.PaddinglessBehavoir.Copied.Visible = false
		end)
	end)
	
	ConfigGui.CreditF.Twitter.MouseButton1Click:Connect(function()
		setclipboard("https://twitter.com/Geno_Dev")
		ConfigGui.CreditF.PaddinglessBehavoir.Copied.Visible = true
		delay(1,function()
			ConfigGui.CreditF.PaddinglessBehavoir.Copied.Visible = false
		end)
	end)
end

ConfigGui.CharacterFrame.Credit.ClickMe.MouseButton1Click:Connect(function()
	ConfigGui.CreditF.Visible = not ConfigGui.CreditF.Visible
end)

ConfigGui.CharacterFrame.Characters.CrotchButton.Tick.TextLabel.Visible = ConfigData.ShowCrotch
ConfigGui.CharacterFrame.Characters.ReplicateButton.Tick.TextLabel.Visible = ConfigData.ApplyToOthers
ConfigGui.CharacterFrame.Characters.ChestButton.Tick.TextLabel.Visible = ConfigData.ShowChest
ConfigGui.CharacterFrame.Characters.ButtButton.Tick.TextLabel.Visible = ConfigData.ShowButt
ConfigGui.CharacterFrame.Characters.GenderButton.Tick.TextLabel.Visible = ConfigData.UtilizeGender

UserInputService.InputBegan:Connect(function(io,gpe)
	if not gpe then
		if io.KeyCode == Enum.KeyCode.LeftAlt and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			ConfigGui.CharacterFrame.Visible = not ConfigGui.CharacterFrame.Visible
			if not ConfigGui.CharacterFrame.Visible then
				ConfigGui.CreditF.Visible = false
			end
		end
	end
end)

if (game.CreatorId == 5212858 or RunService:IsStudio()) then
	local LiveFolder = workspace:WaitForChild("Live")
	local NPCFolder = workspace:WaitForChild("NPCs")

	for i,m in pairs(LiveFolder:GetChildren()) do
		if m:IsA("Model") then
			CheckIfValidRigAndApply(m,true)
		end
	end

	LIVEADDED = LiveFolder.ChildAdded:Connect(function(m)
		if m:IsA("Model") then
			warn(m:GetFullName())
			CheckIfValidRigAndApply(m,true)
		end
	end)

	for i,m in pairs(NPCFolder:GetChildren()) do
		if m:IsA("Model") then
			CheckIfValidRigAndApply(m,false)
		end
	end	

	NPCADDED = NPCFolder.ChildAdded:Connect(function(m)
		if m:IsA("Model") then
			CheckIfValidRigAndApply(m,false)
		end
	end)

else 
	--if game.CreatorId == 5212858 then
	for i,v in pairs(Players:GetPlayers()) do 

		if v.Character then 
			CheckIfValidRigAndApply(v.Character,true)    
		end

		v.CharacterAdded:Connect(function()
			spawn(function()
				wait(1)
				CheckIfValidRigAndApply(v.Character,true)  
			end)  
		end)
	end

	NPCADDED = Players.PlayerAdded:Connect(function(v)
		if v.Character then 
			CheckIfValidRigAndApply(v.Character,true)    
		end
		v.CharacterAdded:Connect(function()
			spawn(function()
				wait(1)
				CheckIfValidRigAndApply(v.Character,true)  
			end)  
		end)  
	end)
end