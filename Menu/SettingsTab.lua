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
}

local function ApplyMorph(name)
    local char = game:GetService("Players").LocalPlayer.Character
    if not char then return end
    local data = MORPH_DATA[name]
    if not data then return end

    if data.skin then
        pcall(function()
            local bc = BrickColor.new(data.skin)
            for _, p in ipairs({"Torso","Left Arm","Right Arm","Left Leg","Right Leg"}) do
                local part = char:FindFirstChild(p)
                if part and part:IsA("BasePart") then part.BrickColor = bc end
            end
        end)
    end

    if data.hair then
        pcall(function()
            local obj = game:GetObjects("rbxassetid://"..data.hair)[1]
            if not obj then return end
            obj.Parent = char
            local handle = obj:FindFirstChild("Handle")
            local head   = char:FindFirstChild("Head")
            if handle and head then
                local w = Instance.new("Weld")
                w.Part0 = head ; w.Part1 = handle
                w.C0 = CFrame.new(data.off[1],data.off[2],data.off[3])
                     * CFrame.Angles(math.rad(data.rot[1]),math.rad(data.rot[2]),math.rad(data.rot[3]))
                w.Parent = handle
            end
        end)
    end

    if data.shirt and data.pants then
        pcall(function()
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("Shirt") or v:IsA("Pants") then v:Destroy() end
            end
            local s = Instance.new("Shirt", char)
            s.ShirtTemplate = "rbxassetid://"..data.shirt
            local p = Instance.new("Pants", char)
            p.PantsTemplate = "rbxassetid://"..data.pants
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
            if flag and flag.Key then
                Library.MenuKeybind = flag.Key
            end
        end
    })

    SettingsSection:Toggle({
        Name     = "Watermark",
        Flag     = "Watermark",
        Default  = true,
        Callback = function(Value)
            Watermark:SetVisibility(Value)
        end
    })

    SettingsSection:Toggle({
        Name     = "Keybind List",
        Flag     = "Keybind List",
        Default  = false,
        Callback = function(Value)
            KeybindList:SetVisibility(Value)
        end
    })

    SettingsSection:Toggle({
        Name     = "Streamer Mode",
        Flag     = "Streamer Mode",
        Default  = false,
        Callback = function(Value)
            Watermark:SetVisibility(not Value)
        end
    })

    SettingsSection:Button({
        Name     = "Unload",
        Callback = function()
            DetachCallback()
        end
    })

    local FunSection = Page:Section({ Name = "Fun", Side = 2 })

    FunSection:Button({
        Name     = "BOOBS",
        Callback = function()
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/0xCiel/scripts/refs/heads/main/boobwoken.lua"))()
            end)
        end
    })

    FunSection:Dropdown({
        Name     = "Morphs",
        Flag     = "Morph",
        Default  = "Goku",
        Items    = MORPHS,
        Callback = function(Value)
            if Value then ApplyMorph(Value) end
        end
    })
end

return SettingsTab
