-- ============================================================
-- CLEANUP SCRIPT CU
-- ============================================================
if _G.ScriptRunning then
    _G.ScriptRunning = false
    task.wait(0.5)
end
_G.ScriptRunning = true

-- Xoa tat ca GUI cu trong CoreGui
pcall(function()
    for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
        if gui.Name:find("Fluent") or gui.Name:find("Lucky") or gui.Name:find("Script") then
            gui:Destroy()
        end
    end
end)

-- Xoa tat ca GUI cu trong PlayerGui
pcall(function()
    for _, gui in pairs(game:GetService("Players").LocalPlayer.PlayerGui:GetChildren()) do
        if gui.Name:find("Fluent") or gui.Name:find("Lucky") or gui.Name:find("Script") then
            gui:Destroy()
        end
    end
end)

-- Reset tat ca _G variables
_G.autoClaimingPR = nil
_G.runningRebirth = nil
_G.runningEPR = nil
_G.runningABL = nil
_G.runningCollect = nil
_G.runningSpeed = nil
_G.runningBR1 = nil
_G.runningBR2 = nil
_G.runningBR3 = nil
_G.runningFarm = nil
_G.runningCustomSpeed = nil

task.wait(0.3)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Be a Lucky Block",
    SubTitle = "by Kuma_Hub",
    TabWidth = 160,
    Size = UDim2.fromOffset(550, 430),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "box" }),
    Upgrades = Window:AddTab({ Title = "Upgrades", Icon = "gauge" }),
    Brainrots = Window:AddTab({ Title = "Brainrots", Icon = "bot" }),
    Stats = Window:AddTab({ Title = "Stats", Icon = "chart-column" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local knit = RS
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.7.0")
    :WaitForChild("knit")
    :WaitForChild("Services")

-- ============================================================
-- AUTO CLAIM PLAYTIME REWARDS
-- ============================================================
local claimGift = knit:WaitForChild("PlaytimeRewardService"):WaitForChild("RF"):WaitForChild("ClaimGift")
local autoClaimingPR = false
local ACPR = Tabs.Main:AddToggle("ACPR", { Title = "Auto Claim Playtime Rewards", Default = false })
ACPR:OnChanged(function(state)
    autoClaimingPR = state
    if not state then return end
    task.spawn(function()
        while autoClaimingPR and _G.ScriptRunning do
            for reward = 1, 12 do
                if not autoClaimingPR or not _G.ScriptRunning then break end
                pcall(function() claimGift:InvokeServer(reward) end)
                task.wait(0.25)
            end
            task.wait(1)
        end
    end)
end)
Options.ACPR:SetValue(false)

-- ============================================================
-- AUTO REBIRTH
-- ============================================================
local rebirth = knit:WaitForChild("RebirthService"):WaitForChild("RF"):WaitForChild("Rebirth")
local runningRebirth = false
local AR = Tabs.Main:AddToggle("AR", { Title = "Auto Rebirth", Default = false })
AR:OnChanged(function(state)
    runningRebirth = state
    if not state then return end
    task.spawn(function()
        while runningRebirth and _G.ScriptRunning do
            pcall(function() rebirth:InvokeServer() end)
            task.wait(1)
        end
    end)
end)
Options.AR:SetValue(false)

-- ============================================================
-- AUTO CLAIM EVENT PASS REWARDS
-- ============================================================
local claim = knit:WaitForChild("SeasonPassService"):WaitForChild("RF"):WaitForChild("ClaimPassReward")
local runningEPR = false
local ACEPR = Tabs.Main:AddToggle("ACEPR", { Title = "Auto Claim Event Pass Rewards", Default = false })
ACEPR:OnChanged(function(state)
    runningEPR = state
    if not state then return end
    task.spawn(function()
        while runningEPR and _G.ScriptRunning do
            pcall(function()
                local windows = player.PlayerGui:FindFirstChild("Windows")
                if not windows then return end
                local event = windows:FindFirstChild("Event")
                if not event then return end
                local frame = event:FindFirstChild("Frame")
                if not frame then return end
                local frame2 = frame:FindFirstChild("Frame")
                if not frame2 then return end
                local passWindows = frame2:FindFirstChild("Windows")
                if not passWindows then return end
                local pass = passWindows:FindFirstChild("Pass")
                if not pass then return end
                local main = pass:FindFirstChild("Main")
                if not main then return end
                local sf = main:FindFirstChild("ScrollingFrame")
                if not sf then return end
                for i = 1, 10 do
                    if not runningEPR or not _G.ScriptRunning then break end
                    local item = sf:FindFirstChild(tostring(i))
                    if item and item:FindFirstChild("Frame") and item.Frame:FindFirstChild("Free") then
                        local free = item.Frame.Free
                        local locked = free:FindFirstChild("Locked")
                        local claimed = free:FindFirstChild("Claimed")
                        if claimed and claimed.Visible then continue end
                        if locked and not locked.Visible then
                            pcall(function() claim:InvokeServer("Free", i) end)
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end)
Options.ACEPR:SetValue(false)

-- ============================================================
-- REDEEM ALL CODES
-- ============================================================
local redeem = knit:WaitForChild("CodesService"):WaitForChild("RF"):WaitForChild("RedeemCode")
local codes = { "release" }
Tabs.Main:AddButton({
    Title = "Redeem All Codes",
    Callback = function()
        for _, code in ipairs(codes) do
            pcall(function() redeem:InvokeServer(code) end)
            task.wait(1)
        end
    end
})

-- ============================================================
-- AUTO BUY BEST LUCKYBLOCK
-- ============================================================
local buy = knit:WaitForChild("SkinService"):WaitForChild("RF"):WaitForChild("BuySkin")
local skins = {
    "prestige_mogging_luckyblock", "mogging_luckyblock", "colossus_luckyblock",
    "inferno_luckyblock", "divine_luckyblock", "spirit_luckyblock",
    "cyborg_luckyblock", "void_luckyblock", "gliched_luckyblock",
    "lava_luckyblock", "freezy_luckyblock", "fairy_luckyblock"
}
local suffix = {
    K=1e3, M=1e6, B=1e9, T=1e12, Qa=1e15, Qi=1e18,
    Sx=1e21, Sp=1e24, Oc=1e27, No=1e30, Dc=1e33
}
local function parseCash(text)
    text = text:gsub("%$",""):gsub(",",""):gsub("%s+","")
    local num = tonumber(text:match("[%d%.]+"))
    local suf = text:match("%a+")
    if not num then return 0 end
    if suf and suffix[suf] then return num * suffix[suf] end
    return num
end
local runningABL = false
local ABL = Tabs.Main:AddToggle("ABL", { Title = "Auto Buy Best Luckyblock", Default = false })
ABL:OnChanged(function(state)
    runningABL = state
    if not state then return end
    task.spawn(function()
        while runningABL and _G.ScriptRunning do
            pcall(function()
                local gui = player.PlayerGui:FindFirstChild("Windows")
                if not gui then return end
                local pickaxeShop = gui:FindFirstChild("PickaxeShop")
                if not pickaxeShop then return end
                local sf = pickaxeShop:FindFirstChild("ShopContainer") and
                           pickaxeShop.ShopContainer:FindFirstChild("ScrollingFrame")
                if not sf then return end
                local cash = player.leaderstats.Cash.Value
                local bestSkin, bestPrice = nil, 0
                for _, name in ipairs(skins) do
                    local item = sf:FindFirstChild(name)
                    if item then
                        local btn = item:FindFirstChild("Main") and
                                    item.Main:FindFirstChild("Buy") and
                                    item.Main.Buy:FindFirstChild("BuyButton")
                        if btn and btn.Visible then
                            local cashLabel = btn:FindFirstChild("Cash")
                            if cashLabel then
                                local price = parseCash(cashLabel.Text)
                                if cash >= price and price > bestPrice then
                                    bestSkin = name; bestPrice = price
                                end
                            end
                        end
                    end
                end
                if bestSkin then pcall(function() buy:InvokeServer(bestSkin) end) end
            end)
            task.wait(0.5)
        end
    end)
end)
Options.ABL:SetValue(false)

-- ============================================================
-- SELL HELD BRAINROT
-- ============================================================
Tabs.Main:AddButton({
    Title = "Sell Held Brainrot",
    Callback = function()
        Window:Dialog({
            Title = "Confirm Sale",
            Content = "Are you sure you want to sell this held Brainrot?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        local character = player.Character or player.CharacterAdded:Wait()
                        local tool = character:FindFirstChildOfClass("Tool")
                        if not tool then
                            Fluent:Notify({ Title="ERROR!", Content="Equip the Brainrot you want to Sell", Duration=5 })
                            return
                        end
                        local entityId = tool:GetAttribute("EntityId")
                        if not entityId then return end
                        knit:WaitForChild("InventoryService"):WaitForChild("RF"):WaitForChild("SellBrainrot"):InvokeServer(entityId)
                        Fluent:Notify({ Title="SOLD!", Content="Sold: "..tool.Name, Duration=5 })
                    end
                },
                { Title="Cancel", Callback=function() end }
            }
        })
    end
})

-- ============================================================
-- PICKUP ALL BRAINROTS
-- ============================================================
local pickupRemote = knit:WaitForChild("ContainerService"):WaitForChild("RF"):WaitForChild("PickupBrainrot")
Tabs.Main:AddButton({
    Title = "Pickup All Your Brainrots",
    Callback = function()
        Window:Dialog({
            Title = "Confirm Pickup!",
            Content = "Pick up all Brainrots?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        local plotsFolder = workspace:WaitForChild("Plots")
                        local myPlot = nil
                        for _, plot in pairs(plotsFolder:GetChildren()) do
                            local inner = plot:FindFirstChild(plot.Name)
                            if inner then
                                for _, v in pairs(inner:GetDescendants()) do
                                    if v:IsA("BillboardGui") and v.Name:find(player.Name) then
                                        myPlot = inner; break
                                    end
                                end
                            end
                            if myPlot then break end
                        end
                        if not myPlot then return end
                        local containers = myPlot:FindFirstChild("Containers")
                        if not containers then return end
                        for i = 1, 30 do
                            local cf = containers:FindFirstChild(tostring(i))
                            if cf and cf:FindFirstChild(tostring(i)) then
                                local container = cf[tostring(i)]
                                local innerModel = container:FindFirstChild("InnerModel")
                                if innerModel and #innerModel:GetChildren() > 0 then
                                    pcall(function() pickupRemote:InvokeServer(tostring(i)) end)
                                    task.wait(0.1)
                                end
                            end
                        end
                        Fluent:Notify({ Title="Done!", Content="Picked up all Brainrots", Duration=5 })
                    end
                },
                { Title="Cancel", Callback=function() end }
            }
        })
    end
})

-- ============================================================
-- AUTO COLLECT CASH
-- ============================================================
Tabs.Main:AddSection("Auto Collect Cash")

local runningCollect = false
local collectInterval = 1
local sethidden = getgenv().sethiddenproperty

local collectSlider = Tabs.Main:AddSlider("CollectDelay", {
    Title = "Collect Interval (giay)",
    Default = 1, Min = 0.1, Max = 5, Rounding = 1,
    Callback = function(Value) collectInterval = Value end
})
collectSlider:OnChanged(function(Value) collectInterval = Value end)
collectSlider:SetValue(1)

local function findMyPlot()
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then return nil end
    for _, plotOuter in pairs(plotsFolder:GetChildren()) do
        local plotInner = plotOuter:FindFirstChild(plotOuter.Name)
        if plotInner then
            for _, v in pairs(plotInner:GetDescendants()) do
                if v:IsA("BillboardGui") and v.Name:find(player.Name) then
                    return plotInner
                end
            end
        end
    end
    for _, plotOuter in pairs(plotsFolder:GetChildren()) do
        local plotInner = plotOuter:FindFirstChild(plotOuter.Name)
        if plotInner and plotInner:FindFirstChild("Containers") then
            return plotInner
        end
    end
    return nil
end

local function collectCashFireTouch()
    if not sethidden then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local myPlot = findMyPlot()
    if not myPlot then return end
    local containers = myPlot:FindFirstChild("Containers")
    if not containers then return end

    for i = 1, 30 do
        if not runningCollect or not _G.ScriptRunning then break end
        pcall(function()
            local cf = containers:FindFirstChild(tostring(i))
            if not cf then return end
            local inner = cf:FindFirstChild(tostring(i))
            if not inner then return end
            local collection = inner:FindFirstChild("Collection")
            if not collection then return end
            local pad = collection:FindFirstChild("CollectionPad")
            if not pad then return end
            local originalCFrame = pad.CFrame
            sethidden(pad, "CFrame", hrp.CFrame + Vector3.new(0, -3, 0))
            task.wait(0.1)
            sethidden(pad, "CFrame", originalCFrame)
        end)
        task.wait(0.05)
    end
end

local AutoCollect = Tabs.Main:AddToggle("AutoCollect", {
    Title = "Auto Collect Cash",
    Default = false
})
AutoCollect:OnChanged(function(state)
    runningCollect = state
    if not state then return end
    task.spawn(function()
        while runningCollect and _G.ScriptRunning do
            collectCashFireTouch()
            task.wait(collectInterval)
        end
    end)
end)
Options.AutoCollect:SetValue(false)

Tabs.Main:AddButton({
    Title = "Collect Cash 1 Lan",
    Callback = function()
        task.spawn(function()
            collectCashFireTouch()
            Fluent:Notify({ Title="Done!", Content="Da collect toan bo cash!", Duration=2 })
        end)
    end
})

-- ============================================================
-- SPEED UPGRADES TAB
-- ============================================================
Tabs.Upgrades:AddSection("Speed Upgrades")

local upgrade = knit:WaitForChild("UpgradesService"):WaitForChild("RF"):WaitForChild("Upgrade")
local upgradeAmount = 1
local upgradeDelay = 0.5
local runningSpeed = false

local IMS = Tabs.Upgrades:AddInput("IMS", {
    Title = "Speed Amount", Default = "1", Placeholder = "Number",
    Numeric = true, Finished = false,
    Callback = function(Value) upgradeAmount = tonumber(Value) or 1 end
})
IMS:OnChanged(function(Value) upgradeAmount = tonumber(Value) or 1 end)

local SMS = Tabs.Upgrades:AddSlider("SMS", {
    Title = "Upgrade Interval", Default = 1, Min = 0, Max = 5, Rounding = 1,
    Callback = function(Value) upgradeDelay = Value end
})
SMS:OnChanged(function(Value) upgradeDelay = Value end)
SMS:SetValue(1)

local AMS = Tabs.Upgrades:AddToggle("AMS", { Title = "Auto Upgrade Speed", Default = false })
AMS:OnChanged(function(state)
    runningSpeed = state
    if not state then return end
    task.spawn(function()
        while runningSpeed and _G.ScriptRunning do
            pcall(function() upgrade:InvokeServer("MovementSpeed", upgradeAmount) end)
            task.wait(upgradeDelay)
        end
    end)
end)
Options.AMS:SetValue(false)

-- ============================================================
-- AUTO UPGRADE BRAINROT
-- ============================================================
Tabs.Upgrades:AddSection("Brainrot Upgrades")

local upgradeBrainrot = knit:WaitForChild("ContainerService"):WaitForChild("RF"):WaitForChild("UpgradeBrainrot")
local brainrotDelay = 0.5
local runningBR1, runningBR2, runningBR3 = false, false, false

local BRSlider = Tabs.Upgrades:AddSlider("BRSlider", {
    Title = "Upgrade Interval (giay)", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1,
    Callback = function(Value) brainrotDelay = Value end
})
BRSlider:OnChanged(function(Value) brainrotDelay = Value end)
BRSlider:SetValue(0.5)

local AUBR1 = Tabs.Upgrades:AddToggle("AUBR1", { Title = "Auto Upgrade Tang 1 (1-10)", Default = false })
AUBR1:OnChanged(function(state)
    runningBR1 = state
    if not state then return end
    task.spawn(function()
        while runningBR1 and _G.ScriptRunning do
            for i = 1, 10 do
                if not runningBR1 or not _G.ScriptRunning then break end
                pcall(function() upgradeBrainrot:InvokeServer(tostring(i)) end)
                task.wait(brainrotDelay)
            end
        end
    end)
end)
Options.AUBR1:SetValue(false)

local AUBR2 = Tabs.Upgrades:AddToggle("AUBR2", { Title = "Auto Upgrade Tang 2 (11-20)", Default = false })
AUBR2:OnChanged(function(state)
    runningBR2 = state
    if not state then return end
    task.spawn(function()
        while runningBR2 and _G.ScriptRunning do
            for i = 11, 20 do
                if not runningBR2 or not _G.ScriptRunning then break end
                pcall(function() upgradeBrainrot:InvokeServer(tostring(i)) end)
                task.wait(brainrotDelay)
            end
        end
    end)
end)
Options.AUBR2:SetValue(false)

local AUBR3 = Tabs.Upgrades:AddToggle("AUBR3", { Title = "Auto Upgrade Tang 3 (21-30)", Default = false })
AUBR3:OnChanged(function(state)
    runningBR3 = state
    if not state then return end
    task.spawn(function()
        while runningBR3 and _G.ScriptRunning do
            for i = 21, 30 do
                if not runningBR3 or not _G.ScriptRunning then break end
                pcall(function() upgradeBrainrot:InvokeServer(tostring(i)) end)
                task.wait(brainrotDelay)
            end
        end
    end)
end)
Options.AUBR3:SetValue(false)

Tabs.Upgrades:AddButton({
    Title = "Upgrade All Brainrots 1 lan (1-30)",
    Callback = function()
        task.spawn(function()
            for i = 1, 30 do
                pcall(function() upgradeBrainrot:InvokeServer(tostring(i)) end)
                task.wait(brainrotDelay)
            end
            Fluent:Notify({ Title="Done!", Content="Da upgrade toan bo 30 container!", Duration=3 })
        end)
    end
})

-- ============================================================
-- BRAINROTS TAB
-- ============================================================
local storedParts = {}
local bossFolder = workspace:WaitForChild("BossTouchDetectors")
local RBTD = Tabs.Brainrots:AddToggle("RBTD", {
    Title = "Remove Bad Boss Touch Detectors",
    Description = "will make it so only the last boss can capture you",
    Default = false
})
RBTD:OnChanged(function(state)
    if state then
        storedParts = {}
        for _, obj in ipairs(bossFolder:GetChildren()) do
            if obj.Name ~= "base14" then
                table.insert(storedParts, obj)
                obj.Parent = nil
            end
        end
    else
        for _, obj in ipairs(storedParts) do
            if obj then obj.Parent = bossFolder end
        end
        storedParts = {}
    end
end)
Options.RBTD:SetValue(false)

Tabs.Brainrots:AddButton({
    Title = "Teleport to End",
    Callback = function()
        local modelsFolder = workspace:WaitForChild("RunningModels")
        local target = workspace:WaitForChild("CollectZones"):WaitForChild("base14")
        for _, obj in ipairs(modelsFolder:GetChildren()) do
            if obj:IsA("Model") then
                if obj.PrimaryPart then obj:SetPrimaryPartCFrame(target.CFrame)
                else
                    local part = obj:FindFirstChildWhichIsA("BasePart")
                    if part then part.CFrame = target.CFrame end
                end
            elseif obj:IsA("BasePart") then
                obj.CFrame = target.CFrame
            end
        end
    end
})

Tabs.Brainrots:AddSection("Farming")

local runningFarm = false
local AutoFarmToggle = Tabs.Brainrots:AddToggle("AutoFarmToggle", {
    Title = "Auto Farm Best Brainrots", Default = false
})
AutoFarmToggle:OnChanged(function(state)
    runningFarm = state
    if not state then return end
    task.spawn(function()
        while runningFarm and _G.ScriptRunning do
            local character = player.Character or player.CharacterAdded:Wait()
            local root = character:WaitForChild("HumanoidRootPart")
            local humanoid = character:WaitForChild("Humanoid")
            local userId = player.UserId
            local modelsFolder = workspace:WaitForChild("RunningModels")
            local target = workspace:WaitForChild("CollectZones"):WaitForChild("base14")
            root.CFrame = CFrame.new(715, 39, -2122)
            task.wait(0.3)
            humanoid:MoveTo(Vector3.new(710, 39, -2122))
            local ownedModel = nil
            repeat
                task.wait(0.3)
                for _, obj in ipairs(modelsFolder:GetChildren()) do
                    if obj:IsA("Model") and obj:GetAttribute("OwnerId") == userId then
                        ownedModel = obj; break
                    end
                end
            until ownedModel ~= nil or not runningFarm or not _G.ScriptRunning
            if not runningFarm or not _G.ScriptRunning then break end
            if ownedModel.PrimaryPart then
                ownedModel:SetPrimaryPartCFrame(target.CFrame)
            else
                local part = ownedModel:FindFirstChildWhichIsA("BasePart")
                if part then part.CFrame = target.CFrame end
            end
            task.wait(0.7)
            if ownedModel and ownedModel.Parent == modelsFolder then
                if ownedModel.PrimaryPart then
                    ownedModel:SetPrimaryPartCFrame(target.CFrame * CFrame.new(0,-5,0))
                else
                    local part = ownedModel:FindFirstChildWhichIsA("BasePart")
                    if part then part.CFrame = target.CFrame * CFrame.new(0,-5,0) end
                end
            end
            repeat task.wait(0.3) until not runningFarm or not _G.ScriptRunning or (ownedModel==nil or ownedModel.Parent~=modelsFolder)
            if not runningFarm or not _G.ScriptRunning then break end
            local oldCharacter = player.Character
            repeat task.wait(0.2) until not runningFarm or not _G.ScriptRunning or (player.Character~=oldCharacter and player.Character~=nil)
            if not runningFarm or not _G.ScriptRunning then break end
            task.wait(0.4)
            local newChar = player.Character
            local newRoot = newChar:WaitForChild("HumanoidRootPart")
            newRoot.CFrame = CFrame.new(737, 39, -2118)
            task.wait(2.1)
        end
    end)
end)
Options.AutoFarmToggle:SetValue(false)

-- ============================================================
-- STATS TAB
-- ============================================================
local runningCustomSpeed = false
local sliderValue = 1000
local originalSpeed = nil
local currentModel = nil

local function getMyModel()
    local f = workspace:FindFirstChild("RunningModels")
    if not f then return nil end
    for _, model in ipairs(f:GetChildren()) do
        if model:GetAttribute("OwnerId") == player.UserId then return model end
    end
    return nil
end

task.spawn(function()
    while _G.ScriptRunning do
        if runningCustomSpeed then
            local model = getMyModel()
            if model then
                if model ~= currentModel then
                    currentModel = model
                    originalSpeed = model:GetAttribute("MovementSpeed")
                end
                if originalSpeed == nil then originalSpeed = model:GetAttribute("MovementSpeed") end
                model:SetAttribute("MovementSpeed", sliderValue)
            else
                currentModel = nil
            end
        end
        task.wait(0.2)
    end
end)

local Toggle = Tabs.Stats:AddToggle("MovementToggle", {
    Title = "Enable Custom Lucky Block Speed", Default = false
})
Toggle:OnChanged(function()
    runningCustomSpeed = Options.MovementToggle.Value
    if not runningCustomSpeed then
        local model = getMyModel()
        if model and originalSpeed ~= nil then
            model:SetAttribute("MovementSpeed", originalSpeed)
        end
        originalSpeed = nil; currentModel = nil
    end
end)

local Slider = Tabs.Stats:AddSlider("MovementSlider", {
    Title = "Lucky Block Speed", Default = 1000, Min = 50, Max = 3000, Rounding = 0
})
Slider:OnChanged(function(Value) sliderValue = Value end)

-- ============================================================
-- ANTI AFK
-- ============================================================
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- ============================================================
-- SETTINGS
-- ============================================================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
end
