local VisualsTab = {}

function VisualsTab.Init(Page, Visuals)
    local ESPSection = Page:Section({ Name = "ESP", Side = 1 })

    ESPSection:Toggle({
        Name     = "Box ESP",
        Flag     = "Box ESP",
        Default  = false,
        Callback = function(Value)
            Visuals:Update()
        end
    }):Colorpicker({
        Name     = "Box Color",
        Flag     = "Box Color",
        Default  = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            Visuals:Update()
        end
    })
end

return VisualsTab
