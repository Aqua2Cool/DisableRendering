--Wait until game loads
repeat
    wait()
until game:IsLoaded()

--Stops script if on a different game
if game.PlaceId ~= 6284583030 and game.PlaceId ~= 6284583030 then
    return
end

if getgenv().loaded then
    return
else
    getgenv().loaded = true
end
--Anti-AFK
local Players = game:GetService("Players")
local connections = getconnections or get_signal_cons
if connections then
	for i,v in pairs(connections(Players.LocalPlayer.Idled)) do
		if v["Disable"] then
			v["Disable"](v)
		elseif v["Disconnect"] then
			v["Disconnect"](v)
		end
	end
else
    Players.LocalPlayer.Idled:Connect(function()
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

--Variables
local unclaimed = {}
local counter = 0
local donation, boothText, spamming, hopTimer, vcEnabled
local signPass = false 
local errCount = 0
local httprequest = (syn and syn.request) or http and http.request or http_request or (fluxus and fluxus.request) or request
local httpservice = game:GetService('HttpService')
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/tzechco/roblox-scripts/main/UI/ui-engine-v2.lua"))()

--Load Settings
if isfile("plsdonatesettings.txt") then
    local sl, er = pcall(function()
        getgenv().settings = httpservice:JSONDecode(readfile('plsdonatesettings.txt'))
    end)
    if er ~= nil then
        task.spawn(function()
            errMsg = Instance.new("Hint")
            errMsg.Parent = game.workspace
            errMsg.Text = tostring("Settings reset due to error: ".. er)
            task.wait(15)
            errMsg:Destroy()
        end)
    delfile("plsdonatesettings.txt")
    end

end
local sNames = {"textUpdateToggle", "textUpdateDelay", "serverHopToggle", "serverHopDelay", "hexBox", "goalBox", "webhookToggle", "webhookBox", "danceChoice", "thanksMessage", "signToggle", "customBoothText", "signUpdateToggle", "signText", "signHexBox", "autoThanks", "autoBeg", "begMessage", "begDelay", "fpsLimit", "render", "thanksDelay", "vcServer"}
local sValues = {true, 30, true, 30, "#32CD32", 5, false, "", "Disabled", {"Thank you", "Thanks!", "ty :)", "tysm!"}, false, "GOAL: $C / $G", false, "your text here", "#ffffff", true, false, {"Please donate", "I'm so close to my goal!", "donate to me", "please"}, 300, 60, false, 3, false}
if #getgenv().settings ~= sNames then
    for i, v in ipairs(sNames) do
        if getgenv().settings[v] == nil then
            getgenv().settings[v] = sValues[i]
        end
    end
    writefile('plsdonatesettings.txt', httpservice:JSONEncode(getgenv().settings))
end

--Save Settings
local settingsLock = true
local function saveSettings()
    if settingsLock == false then
        print('Settings saved.')
        writefile('plsdonatesettings.txt', httpservice:JSONEncode(getgenv().settings))
    end
end
--Function to fix slider
local sliderInProgress = false;
local function slider(value, whichSlider)
    if sliderInProgress then
        return
    end
    sliderInProgress = true
    task.wait(5)
    if getgenv().settings[whichSlider] == value then
        saveSettings()
        sliderInProgress = false;
        if whichSlider == "serverHopDelay" then
            hopSet()
        end
    else
        sliderInProgress = false;
        return slider(getgenv().settings[whichSlider], whichSlider)
    end
end


local function webhook(msg)
    httprequest({
        Url = getgenv().settings.webhookBox,
        Body = httpservice:JSONEncode({["content"] = msg}),
        Method = "POST",
        Headers = {["content-type"] = "application/json"}
    })
end
    
--GUI
local Window = library:AddWindow("E13 Disable Render Script",
{
    main_color = Color3.fromRGB(0, 128, 0),
    min_size = Vector2.new(373, 433),
    toggle_key = Enum.KeyCode.RightShift,
})
local otherTab = Window:AddTab("Main")
local webhookTab = Window:AddTab("Webhook")
local serverHopTab = Window:AddTab("")
local boothTab = Window:AddTab("")
local signTab = Window:AddTab("")
local chatTab = Window:AddTab("")




--Webhook Settings
local webhookToggle = webhookTab:AddSwitch("Discord Webhook Notifications", function(bool)
    getgenv().settings.webhookToggle = bool
    saveSettings()
end)
webhookToggle:Set(getgenv().settings.webhookToggle)
local webhookBox = webhookTab:AddTextBox("Webhook URL", function(text)
    if string.find(text, "https://discord.com/api/webhooks/") then
        getgenv().settings.webhookBox = text;
        saveSettings()
    end
end,
{
    ["clear"] = false
})
webhookBox.Text = getgenv().settings.webhookBox
webhookTab:AddLabel('Press Enter to Save')
webhookTab:AddButton("Test", function()
    if getgenv().settings.webhookBox then
        webhook("Sent from PSX!!")
    end
end)


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

--Finds unclaimed booths
local function findUnclaimed()
    for i, v in pairs(Players.LocalPlayer.PlayerGui.MapUIContainer.MapUI.BoothUI:GetChildren()) do
        if (v.Details.Owner.Text == "unclaimed") then
            table.insert(unclaimed, tonumber(string.match(tostring(v), "%d+")))
        end
    end
end
if not pcall(findUnclaimed) then
    serverHop()
end
local claimCount = #unclaimed
--Claim booth function
local function boothclaim()
    require(game.ReplicatedStorage.Remotes).Event("ClaimBooth"):InvokeServer(unclaimed[1])
    if not string.find(Players.LocalPlayer.PlayerGui.MapUIContainer.MapUI.BoothUI:FindFirstChild(tostring("BoothUI".. unclaimed[1])).Details.Owner.Text, Players.LocalPlayer.DisplayName) then
        task.wait(1)
        if not string.find(Players.LocalPlayer.PlayerGui.MapUIContainer.MapUI.BoothUI:FindFirstChild(tostring("BoothUI".. unclaimed[1])).Details.Owner.Text, Players.LocalPlayer.DisplayName) then
            error()
        end
    end
end
--Checks if booth claim fails
while not pcall(boothclaim) do
    if errCount >= claimCount then
        serverHop()
    end
    table.remove(unclaimed, 1)
    errCount = errCount + 1
end

hopSet()
--Walks to booth
local Controls = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
Controls:Disable()
Players.LocalPlayer.Character.Humanoid:MoveTo(Vector3.new(booths[tostring(unclaimed[1])]:match("(.+), (.+), (.+)")))
local atBooth = false
local function noclip()
    for i,v in pairs(Players.LocalPlayer.Character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end
local noclipper = game:GetService("RunService").Stepped:Connect(noclip)
Players.LocalPlayer.Character.Humanoid.MoveToFinished:Connect(function(reached)
    atBooth = true
end)
while not atBooth do
    task.wait(.1)
    if Players.LocalPlayer.Character.Humanoid:GetState() == Enum.HumanoidStateType.Seated then
        Players.LocalPlayer.Character.Humanoid.Jump = true
    end
end
Controls:Enable()
noclipper:Disconnect()
Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(Players.LocalPlayer.Character.HumanoidRootPart.Position, Vector3.new(40, 14, 101)))
require(game.ReplicatedStorage.Remotes).Event("RefreshItems"):InvokeServer()
if getgenv().settings.danceChoice == "1" then
    task.wait(.25)
    Players:Chat("/e dance")
else
    task.wait(.25)
    Players:Chat("/e dance".. getgenv().settings.danceChoice)
end

if getgenv().settings.autoBeg then
    spamming = task.spawn(begging)
end
local RaisedC = Players.LocalPlayer.leaderstats.Raised.value
Players.LocalPlayer.leaderstats.Raised.Changed:Connect(function()
    hopSet()
    if getgenv().settings.webhookToggle and getgenv().settings.webhookBox then
        local LogService = Game:GetService("LogService")
        local logs = LogService:GetLogHistory()
        --Tries to grabs donation message from logs
        if string.find(logs[#logs].message, Players.LocalPlayer.DisplayName) then
            webhook(tostring(logs[#logs].message.. " (Total: ".. Players.LocalPlayer.leaderstats.Raised.value.. ")"))
        else
            webhook(tostring("💰 Somebody tipped ".. Players.LocalPlayer.leaderstats.Raised.value - RaisedC.. " Robux to ".. Players.LocalPlayer.DisplayName.. " (Total: " .. Players.LocalPlayer.leaderstats.Raised.value.. ")"))
        end
    end
    RaisedC = Players.LocalPlayer.leaderstats.Raised.value
    if getgenv().settings.autoThanks then
        task.spawn(function()
            task.wait(getgenv().settings.thanksDelay)
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(getgenv().settings.thanksMessage[math.random(#getgenv().settings.thanksMessage)],"All")
        end)
    end
    task.wait(getgenv().settings.textUpdateDelay)
    update()
end)
update()
if game:GetService("CoreGui").imgui.Windows.Window.Title.Text == "Loading..." then
    game:GetService("CoreGui").imgui.Windows.Window.Title.Text = "PLS DONATE - tzechco"
end
while task.wait(getgenv().settings.serverHopDelay * 60) do
    if not hopTimer then
        hopSet()
    end
end