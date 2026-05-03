local AutoParry = {}

AutoParry.Enabled = false

function AutoParry:Start()
    AutoParry.Enabled = true
end

function AutoParry:Stop()
    AutoParry.Enabled = false
end

return AutoParry
