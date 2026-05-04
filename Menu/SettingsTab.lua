local SettingsTab = {}

local MORPHS = {
    "Goku","Naruto","Miku","Aizen","Gawr Gura","Guts","Gojo","Toji",
    "Mahoraga","Kurumi","Changli","Rias Gremory","Akeno Himejima","Akame",
    "Acheron","Esdeath","Sakuya","Sparkle","Jane Doe","Alya","Sung Jin Woo",
    "Ryuko","Hutao","MommyRaga","Castorice","Shadow","Lebron James","Steve",
    "Gilgamesh","Ishtar","Albedo","Astolfo","Zani","Cantarella","Yinlin",
    "Vasto Lorde","Igris","Beru","Cha Hae In","Luffy","Frieren",
    "Raiden Shogun","Rimuru","Zero Two","Columbina","Bocchi","Mavuika",
    "Carlotta","Kafka","Jingliu","Feixiao","Shorekeeper","Kiana HoF",
    "Senti","Mei HoT","Aglaea","Mari Setogaya","Saber","Saber Alter",
    "Jeanne Alter","Vermeil","Vergil","Dante","Neco Arc",
}

local MORPH_DATA = {
    ["Goku"]         = {hair=96778240725860,   shirt=18642081551,    pants=13980707182,    off={0,2.3,0},   rot={0,0,0}},
    ["Naruto"]       = {hair=129818847988995,  shirt=6469644436,     pants=2733834231,     off={0,1.8,0},   rot={0,-90,0}, skin="Pastel yellow"},
    ["Miku"]         = {hair=107263500564078,  shirt=11562331516,    pants=11562350632,    off={0,0.8,0},   rot={0,0,0}},
    ["Aizen"]        = {hair=117644781784979,  shirt=87853669951881, pants=118029167731205,off={0,1.7,0},   rot={0,0,0}},
    ["Gawr Gura"]    = {hair=93023559996037,   shirt=6392201226,     pants=5896597102,     off={0,1.2,0},   rot={0,0,0}},
    ["Guts"]         = {hair=117337600216775,  shirt=13381096342,    pants=13381103162,    off={0,1.6,0},   rot={0,0,0}},
    ["Gojo"]         = {hair=132501783778842,  shirt=73084050138865, pants=15312673306,    off={0,1.9,0},   rot={0,0,0}},
    ["Toji"]         = {hair=135664715112347,  shirt=121088463088431,pants=16149857407,    off={0,1.7,0},   rot={0,0,0}},
    ["Mahoraga"]     = {hair=107798985962651,  shirt=15549196125,    pants=15886594659,    off={0,1.7,0},   rot={0,0,0},  skin="White"},
    ["Vasto Lorde"]  = {hair=93115339379404,   shirt=12389968084,    pants=9153779931,     off={0,0.6,0.3}, rot={15,0,0}, skin="White"},
    ["Luffy"]        = {hair=18543513455,      shirt=12581156224,    pants=12566365740,    off={0,2,0.3},   rot={0,0,0}},
    ["Rimuru"]       = {hair=118948540012480,  shirt=12795104537,    pants=12795105839,    off={0,0.7,0},   rot={0,0,0}},
    ["Lebron James"] = {hair=135528148574372,  shirt=132033269414854,pants=10650849519,    off={0,1.6,-0.1},rot={0,90,0}, skin="Reddish brown"},
    ["Steve"]        = {hair=118830888902962,  shirt=10872887511,    pants=14032414623,    off={0,1.7,0},   rot={0,-90,0}},
    ["Raiden Shogun"]= {hair=18589200366,      shirt=7510268954,     pants=15049045301,    off={0,1.5,0},   rot={0,0,0}},
    ["Zero Two"]     = {hair=15123869167,      shirt=9114999117,     pants=9115000719,     off={0,1.5,0},   rot={0,0,0}},
    ["Frieren"]      = {hair=16018569620,      shirt=16775363591,    pants=16775370003,    off={0,1.5,0},   rot={0,0,0}},
    ["Sung Jin Woo"] = {hair=92171733938281,   shirt=14160558115,    pants=14160562408,    off={0,1.8,0},   rot={0,0,0}},
}

local _selectedMorph = nil

local function ClearMorph(char)
    local head = char:FindFirstChild("Head")
    if head then
        pcall(function()
            head.Transparency = 0
            for _, v in ipairs(head:GetDescendants()) do
                if v:IsA("Decal") then v.Transparency = 0 end
            end
        end)
    end
    pcall(function()
        local effects = workspace:FindFirstChild("Effects")
        if effects then
            local playerEffects = effects:FindFirstChild(game:GetService("Players").LocalPlayer.Name)
            if playerEffects then
                for _, v in ipairs(playerEffects:GetChildren()) do
                    if string.find(v.Name, "Head") or string.find(v.Name, "Face") then
                        v:Destroy()
                    end
                end
            end
        end
    end)
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Hat") then pcall(function() v:Destroy() end) end
        if v:IsA("Shirt") or v:IsA("Pants") then pcall(function() v:Destroy() end) end
    end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("Weld") and (v.Name == "HeadWeld" or v.Name == "HairWeld") then
            pcall(function() v:Destroy() end)
        end
    end
end

local function AttachHair(char, assetId, offset, rotation)
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if not torso then return end
    local ok, obj = pcall(function()
        return game:GetObjects("rbxassetid://"..tostring(assetId))[1]
    end)
    if not ok or not obj then return end
    obj.Parent = char
    local handle = obj:FindFirstChild("Handle")
    if not handle or not handle:IsA("BasePart") then
        pcall(function() obj:Destroy() end)
        return
    end
    local w = Instance.new("Weld")
    w.Name  = "HeadWeld"
    w.Part0 = torso
    w.Part1 = handle
    local off = offset or {0, 0, 0}
    local rot = rotation or {0, 0, 0}
    local useOffset = Vector3.new(off[1], off[2], off[3])
    if useOffset.Magnitude < 0.01 then
        useOffset = Vector3.new(0, torso.Size.Y / 1.15 + handle.Size.Y / 2, 0)
    end
    w.C0 = CFrame.new(useOffset) * CFrame.Angles(math.rad(rot[1]), math.rad(rot[2]), math.rad(rot[3]))
    w.Parent = handle
    local head = char:FindFirstChild("Head")
    if head then
        pcall(function()
            head.Transparency = 1
            for _, v in ipairs(head:GetDescendants()) do
                pcall(function() v:Destroy() end)
            end
        end)
    end
end

local function AttachClothing(char, shirtId, pantsId)
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Shirt") or v:IsA("Pants") then pcall(function() v:Destroy() end) end
    end
    if shirtId then
        pcall(function()
            local obj = game:GetObjects("rbxassetid://"..tostring(shirtId))[1]
            if obj then obj.Name = "Shirt" ; obj.Parent = char end
        end)
    end
    if pantsId then
        pcall(function()
            local obj = game:GetObjects("rbxassetid://"..tostring(pantsId))[1]
            if obj then obj.Name = "Pants" ; obj.Parent = char end
        end)
    end
end

local function SetSkin(char, colorName)
    local ok, bc = pcall(BrickColor.new, colorName)
    if not ok then return end
    for _, name in ipairs({"Torso","Left Arm","Right Arm","Left Leg","Right Leg"}) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then pcall(function() part.BrickColor = bc end) end
    end
end

local function ApplyMorph(name)
    local char = game:GetService("Players").LocalPlayer.Character
    if not char then return end
    local data = MORPH_DATA[name]
    if not data then return end
    ClearMorph(char)
    if data.skin then SetSkin(char, data.skin) end
    if data.hair then AttachHair(char, data.hair, data.off, data.rot) end
    if data.shirt or data.pants then AttachClothing(char, data.shirt, data.pants) end

    local head = char:FindFirstChild("Head")
    if head then
        task.spawn(function()
            for _ = 1, 20 do
                task.wait(0.1)
                pcall(function()
                    head.Transparency = 1
                    for _, v in ipairs(head:GetDescendants()) do
                        pcall(function() v:Destroy() end)
                    end
                end)
            end
        end)
    end
end

function SettingsTab.Init(Page, Library, KeybindList, Watermark, DetachCallback)
    local SettingsSection = Page:Section({ Name = "Settings", Side = 1 })

    SettingsSection:Label({ Name = "Menu Keybind", Alignment = "Left" }):Keybind({
        Name     = "Menu Keybind",
        Flag     = "Menu Keybind",
        Default  = Enum.KeyCode.RightControl,
        Mode     = "Toggle",
        Callback = function(Value)
            local flag = Library.Flags["Menu Keybind"]
            if flag and flag.Key then Library.MenuKeybind = flag.Key end
        end
    })

    SettingsSection:Toggle({
        Name     = "Watermark",
        Flag     = "Watermark",
        Default  = true,
        Callback = function(Value) Watermark:SetVisibility(Value) end
    })

    SettingsSection:Toggle({
        Name     = "Keybind List",
        Flag     = "Keybind List",
        Default  = false,
        Callback = function(Value) KeybindList:SetVisibility(Value) end
    })

    SettingsSection:Toggle({
        Name     = "Streamer Mode",
        Flag     = "Streamer Mode",
        Default  = false,
        Callback = function(Value) Watermark:SetVisibility(not Value) end
    })

    SettingsSection:Button({
        Name     = "Unload",
        Callback = function() DetachCallback() end
    })

    local FunSection = Page:Section({ Name = "Fun", Side = 2 })

    FunSection:Button({
        Name     = "BOOBS",
        Callback = function()
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/assemblylinearvelocity/SneezeSenseTypeSoul/main/Game/Misc/boobwoken.lua"))()
            end)
        end
    })

    FunSection:Dropdown({
        Name     = "Morphs",
        Flag     = "Morph",
        Default  = "Goku",
        Items    = MORPHS,
        Callback = function(Value) _selectedMorph = Value end
    })

    FunSection:Button({
        Name     = "Apply Morph",
        Callback = function()
            if _selectedMorph then ApplyMorph(_selectedMorph) end
        end
    })
end

return SettingsTab
