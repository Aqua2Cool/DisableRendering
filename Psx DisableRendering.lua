--Other tab
otherTab:AddLabel('Dance:')
local danceDropdown = otherTab:AddDropdown("[ ".. getgenv().settings.danceChoice.. " ]", function(object)
    if settingsLock then
        return
    end
    getgenv().settings.danceChoice = object
    saveSettings()
    if object == "Disabled" then
        Players:Chat("/e wave")
    elseif object == "1" then
        Players:Chat("/e dance")
    else
        Players:Chat("/e dance".. object)
    end
end)
danceDropdown:Add("Disabled")
danceDropdown:Add("1")
danceDropdown:Add("2")
danceDropdown:Add("3")
local render = otherTab:AddSwitch("Disable Rendering", function(bool)
    getgenv().settings.render = bool
    saveSettings()
    if bool then
        game:GetService("RunService"):Set3dRenderingEnabled(false)
    else
        game:GetService("RunService"):Set3dRenderingEnabled(true)
    end
end)
render:Set(getgenv().settings.render)
if setfpscap and type(setfpscap) == "function" then
    local fpsLimit = otherTab:AddSlider("FPS Limit", function(x)
        if settingsLock then
            return 
        end
        getgenv().settings.fpsLimit = x
        setfpscap(x)
        coroutine.wrap(slider)(getgenv().settings.fpsLimit, "fpsLimit")
    end,
    {
        ["min"] = 1,
        ["max"] = 60
    })
    fpsLimit:Set((getgenv().settings.fpsLimit / 60) * 100)
    setfpscap(getgenv().settings.fpsLimit)
end

boothTab:Show()
library:FormatWindows()
settingsLock = false
