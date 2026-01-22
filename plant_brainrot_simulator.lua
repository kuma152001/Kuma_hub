-- // Kuma Hub V63: RECONNECT & HOP //
-- Update: Thêm Auto Reconnect (Tự vào lại khi bị Kick).
-- Update: Thêm Server Hop (Random & Low Player).
-- Update: Giữ Fix Auto Code & Manual Config.

-- ====================================================
-- [1. VARIABLES & STORAGE]
-- ====================================================
getgenv().ShopIDs = {
    ["Tomato Seed"] = 1, ["Pumpkin Seed"] = 2, ["Melon Seed"] = 3, ["Mini Corn Seed"] = 4,
    ["Mushroom Seed"] = 5, ["Cactus Seed"] = 6, ["Broccoli Seed"] = 7, ["Sunflower Seed"] = 8,
    ["Chrysanthemum Seed"] = 9, ["Peashooter Seed"] = 10, ["Corn Seed"] = 11, ["Cactus Flower Seed"] = 12,
    ["Fire Peashooter Seed"] = 13, ["Threepeater Seed"] = 14, ["Man-Eating Flower Seed"] = 15,
    ["Alien Onion Seed"] = 16, ["Capsid Brute Seed"] = 17,
    ["Water Bucket (Thường)"] = 1, ["Granade"] = 2,
    ["Purple Bucket"] = 11, ["Orange Bucket"] = 10, ["Yellow Bucket"] = 9,
    ["Reversion Fruit"] = 8, ["Frozen Fruit"] = 3, ["Darkness Fruit"] = 6, ["Kg Fruit"] = 12,
    ["Venom Fruit"] = 5, ["Flame Fruit"] = 4, ["Bomb Fruit"] = 7
}

local UI_Storage = { Toggles = {}, Sliders = {}, Dropdowns = {} }

getgenv().Config = {
    SmartBuy = false, 
    AutoPlant = false,
    AutoHarvest = false,
    AutoBoss = false,
    ActivePlots = {[1]=false, [2]=false, [3]=false, [4]=false, [5]=false, [6]=false},
    DelayTime = 0.2, 
    ClaimGift = false,
    ClaimEvent = false,
    ClaimEgg = false,
    AutoSpin = false,
    AutoReconnect = false -- [NEW]
}
getgenv().BuyQueue = {} 

local CATEGORY_SEED_V29 = "\231\167\141\229\173\144" 
local CATEGORY_GEAR_V29 = "\233\129\147\229\133\183" 
local BOSS_NAME_CODE = "\228\184\150\231\149\140Boss"
local BOSS_NAME_TEXT = "世界Boss"
local ACTION_PLANT  = "放置_宠物" 
local ACTION_SHOVEL = "拾取_宠物" 
local ACTION_WATER  = "变化_宠物" 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage:WaitForChild("RemoteEvent"):WaitForChild("ServerRemoteEvent")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

if game.CoreGui:FindFirstChild("Rayfield") then
    game.CoreGui:FindFirstChild("Rayfield"):Destroy()
end

local function FireRemote(...)
    local args = {...}
    if Remote then 
        pcall(function() Remote:FireServer(unpack(args)) end)
    end
end

local function GetPlotTiles(PlotNum)
    return (PlotNum - 1) * 9 + 1, PlotNum * 9
end

-- ====================================================
-- [CORE LOOPS]
-- ====================================================

-- 1. Auto Buy
task.spawn(function()
    local BuyIndex = 1
    while true do
        if getgenv().Config.SmartBuy then
            local activeItems = {}
            for k, v in pairs(getgenv().BuyQueue) do
                if v.Active then table.insert(activeItems, v) end
            end
            if #activeItems > 0 then
                local CurrentDelay = (getgenv().Config.AutoPlant or getgenv().Config.AutoHarvest) and 2.0 or 0.8
                if BuyIndex > #activeItems then BuyIndex = 1 end
                local item = activeItems[BuyIndex]
                FireRemote("Buy_ArrayBool_Item", item.Category, item.ID)
                BuyIndex = BuyIndex + 1 
                task.wait(CurrentDelay)
            else
                task.wait(1)
            end
        else
            task.wait(1)
        end
    end
end)

-- 2. Farming
task.spawn(function()
    while true do
        local Delay = getgenv().Config.DelayTime
        local activePlotsFound = false
        for i = 1, 6 do if getgenv().Config.ActivePlots[i] then activePlotsFound = true break end end

        if activePlotsFound then
            if getgenv().Config.AutoHarvest then
                FireRemote("Change_ArrayBool_Item", "手牌", 1)
                task.wait(0.4) 
                for PlotNum = 1, 6 do
                    if getgenv().Config.ActivePlots[PlotNum] then
                        local StartID, EndID = GetPlotTiles(PlotNum)
                        for i = StartID, EndID do
                            if not getgenv().Config.AutoHarvest then break end
                            FireRemote("Business", ACTION_SHOVEL, i)
                            task.wait(Delay)
                        end
                    end
                end
                task.wait(0.2)
            end

            if getgenv().Config.AutoPlant then
                for PlotNum = 1, 6 do
                    if getgenv().Config.ActivePlots[PlotNum] then
                        local StartID, EndID = GetPlotTiles(PlotNum)
                        for i = StartID, EndID do
                            if not getgenv().Config.AutoPlant then break end
                            FireRemote("Business", ACTION_PLANT, i)
                            task.wait(Delay)
                        end
                    end
                end
                task.wait(0.2)
            end
        end

        if not getgenv().Config.AutoPlant and not getgenv().Config.AutoHarvest then
            task.wait(0.5)
        else
            task.wait(0.1)
        end
    end
end)

-- 3. Events
task.spawn(function()
    local GiftIndex, EventIndex, TimeCounter = 1, 1, 0
    while true do
        TimeCounter = TimeCounter + 1
        if TimeCounter > 20 then
            TimeCounter = 0
            if getgenv().Config.ClaimGift then
                FireRemote("GetOnlineGift", GiftIndex)
                GiftIndex = GiftIndex % 12 + 1
            end
            if getgenv().Config.ClaimEvent then
                 FireRemote("Business", "\229\133\145\230\141\162\230\153\174\233\128\154\230\180\187\229\138\168\229\165\150\229\138\177", EventIndex)
                 EventIndex = EventIndex % 7 + 1
            end
            if getgenv().Config.ClaimEgg then FireRemote("OpenEventEgg", 2) end
            if getgenv().Config.AutoSpin then FireRemote("OpenSpecialEgg", "\232\189\172\231\155\152\232\155\139") end
        end
        task.wait(0.1)
    end
end)

-- 4. Auto Boss
task.spawn(function()
    while true do
        if getgenv().Config.AutoBoss then
             FireRemote("Business", BOSS_NAME_CODE, 1) 
             FireRemote("Business", BOSS_NAME_TEXT, 1) 
             pcall(function() FireRemote("Business", "FightBoss", 1) end)
             task.wait(1) 
        else
             task.wait(1)
        end
    end
end)

-- 5. Auto Reconnect (NEW)
task.spawn(function()
    CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
        if getgenv().Config.AutoReconnect then
            if child.Name == 'ErrorPrompt' and child:FindFirstChild('MessageArea') and child.MessageArea:FindFirstChild("ErrorFrame") then
                TeleportService:Teleport(game.PlaceId)
            end
        end
    end)
end)

-- Anti-AFK
task.spawn(function()
    while true do
        task.wait(120)
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
        end)
    end
end)

-- ====================================================
-- [UI RAYFIELD]
-- ====================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Kuma Hub | V63",
   LoadingTitle = "Kuma Hub",
   LoadingSubtitle = "Reconnect & Hop Added",
   Theme = "AmberGlow",
   DisableRayfieldPrompts = true,
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

-- TAB 1: FARMING
local FarmTab = Window:CreateTab("Farming🌱", nil)
FarmTab:CreateSection("1. Chọn Các Mảnh Đất")

for i = 1, 6 do
    UI_Storage.Toggles["Plot_"..i] = FarmTab:CreateToggle({
        Name = "Mảnh " .. i, 
        CurrentValue = false, 
        Callback = function(V) getgenv().Config.ActivePlots[i] = V end
    })
end

FarmTab:CreateSection("2. Auto Loop")
UI_Storage.Toggles["AutoHarvest"] = FarmTab:CreateToggle({
    Name = "⛏️ Auto Thu Hoạch", 
    CurrentValue = false, 
    Callback = function(V) getgenv().Config.AutoHarvest = V end
})

UI_Storage.Toggles["AutoPlant"] = FarmTab:CreateToggle({
    Name = "🔥 Auto Trồng", 
    CurrentValue = false, 
    Callback = function(V) getgenv().Config.AutoPlant = V end
})

UI_Storage.Sliders["DelayTime"] = FarmTab:CreateSlider({
    Name = "Tốc Độ (Delay)", 
    Range = {0.15, 0.5}, 
    Increment = 0.05, 
    Suffix = "s", 
    CurrentValue = 0.2, 
    Callback = function(V) getgenv().Config.DelayTime = V end
})

FarmTab:CreateSection("3. Tưới Nước")
FarmTab:CreateButton({
   Name = "💦 TƯỚI CÁC MẢNH ĐÃ CHỌN",
   Callback = function()
       task.spawn(function()
           FireRemote("Change_ArrayBool_Item", "手牌", 3)
           task.wait(0.5) 
           for PlotNum = 1, 6 do
               if getgenv().Config.ActivePlots[PlotNum] then
                   local StartID, EndID = GetPlotTiles(PlotNum)
                   for i = StartID, EndID do
                       FireRemote("Business", ACTION_WATER, i)
                       task.wait(0.15)
                   end
               end
           end
       end)
   end,
})

-- TAB 2: EVENTS
local EventTab = Window:CreateTab("Events🎁", nil)
EventTab:CreateSection("Boss & Chiến Đấu")
UI_Storage.Toggles["AutoBoss"] = EventTab:CreateToggle({
    Name = "🔥 Auto Boss", 
    CurrentValue = false, 
    Callback = function(V) getgenv().Config.AutoBoss = V end
})

EventTab:CreateSection("Quà & Sự Kiện")
UI_Storage.Toggles["ClaimGift"] = EventTab:CreateToggle({Name = "Auto Claim Gift", CurrentValue = false, Callback = function(V) getgenv().Config.ClaimGift = V end})
UI_Storage.Toggles["ClaimEvent"] = EventTab:CreateToggle({Name = "Auto Claim Event", CurrentValue = false, Callback = function(V) getgenv().Config.ClaimEvent = V end})
UI_Storage.Toggles["ClaimEgg"] = EventTab:CreateToggle({Name = "Auto Claim Egg", CurrentValue = false, Callback = function(V) getgenv().Config.ClaimEgg = V end})
UI_Storage.Toggles["AutoSpin"] = EventTab:CreateToggle({Name = "Auto Spin", CurrentValue = false, Callback = function(V) getgenv().Config.AutoSpin = V end})

EventTab:CreateSection("Tools")
EventTab:CreateButton({
   Name = "Auto Merge (Gộp đồ)",
   Callback = function()
        task.spawn(function()
            Rayfield:Notify({Title = "Merge", Content = "Đang gộp đồ...", Duration = 3})
            FireRemote("Change_ArrayBool_Item", "\230\137\139\231\137\140", 2)
            task.wait(0.8)
            FireRemote("Change_ArrayBool_Item", "\230\137\139\231\137\140", 1)
            task.wait(0.8)
            FireRemote("QuickFuse", "\229\174\160\231\137\169")
            task.wait(0.8)
            FireRemote("Change_ArrayBool_Item", "\230\137\139\231\137\140", 3)
            Rayfield:Notify({Title = "Merge", Content = "Đã xong!", Duration = 3})
        end)
   end,
})

-- TAB 3: SHOP
local ShopTab = Window:CreateTab("Shop🛒", nil)
UI_Storage.Toggles["SmartBuy"] = ShopTab:CreateToggle({
    Name = "🔴 BẬT/TẮT AUTO BUY",
    CurrentValue = false,
    Callback = function(Value) getgenv().Config.SmartBuy = Value end,
})

local function CreateBuyBtn(name, categoryCode, id)
    local tglName = "Shop_" .. name
    UI_Storage.Toggles[tglName] = ShopTab:CreateToggle({
        Name = "[" .. id .. "] " .. name,
        Callback = function(Value) 
            getgenv().BuyQueue[name] = {Active = Value, Category = categoryCode, ID = id} 
        end
    })
end

ShopTab:CreateSection("--- [ DỤNG CỤ ] ---")
local OrderedGears = {"Granade", "Purple Bucket", "Orange Bucket", "Yellow Bucket", "Water Bucket (Thường)"}
for _, name in ipairs(OrderedGears) do if getgenv().ShopIDs[name] then CreateBuyBtn(name, CATEGORY_GEAR_V29, getgenv().ShopIDs[name]) end end

ShopTab:CreateSection("--- [ HẠT GIỐNG ] ---")
local OrderedSeeds = {"Tomato Seed", "Pumpkin Seed", "Melon Seed", "Mini Corn Seed", "Mushroom Seed", "Cactus Seed", "Broccoli Seed", "Sunflower Seed", "Chrysanthemum Seed", "Peashooter Seed", "Corn Seed", "Cactus Flower Seed", "Fire Peashooter Seed", "Threepeater Seed", "Man-Eating Flower Seed", "Alien Onion Seed", "Capsid Brute Seed"}
for _, name in ipairs(OrderedSeeds) do if getgenv().ShopIDs[name] then CreateBuyBtn(name, CATEGORY_SEED_V29, getgenv().ShopIDs[name]) end end

ShopTab:CreateSection("--- [ TRÁI CÂY ] ---")
local OrderedFruits = {"Reversion Fruit", "Frozen Fruit", "Darkness Fruit", "Kg Fruit", "Venom Fruit", "Flame Fruit", "Bomb Fruit"}
for _, name in ipairs(OrderedFruits) do if getgenv().ShopIDs[name] then CreateBuyBtn(name, CATEGORY_GEAR_V29, getgenv().ShopIDs[name]) end end

-- TAB 4: MISC & CONFIG
local MiscTab = Window:CreateTab("Misc/Config🚀", nil)

MiscTab:CreateSection("Gift Code")
MiscTab:CreateButton({
    Name = "🎁 Redeem All Codes (Safe Mode)", 
    Callback = function()
        local rawCodes = {
            "RELEASE1", "RELEASE2", "RELEASE3", "1KLIKE", "5KLIKE", 
            "NEWFRRUIT1", "NEWFRRUIT2", "UPDATE1", "UPDATE2", "SINP5", 
            "christmas1", "christmas2", "christmas3", "UPDATE3", "UPDATE4", 
            "kgfruit", "CRYSTAL5000", "Fuse777", "Best999", "Redress", 
            "VIP888", "Grow888", "New666", "CRYSTAL1", "CRYSTAL2", 
            "ITEMS100", "8KDC", "9KDC1", "FIXED001"
        }
        Rayfield:Notify({Title = "Code", Content = "Đang chạy...", Duration = 3})
        task.spawn(function()
            for i, code in ipairs(rawCodes) do 
                pcall(function() FireRemote("GetCode", string.upper(code)) end)
                task.wait(0.5)
                pcall(function() FireRemote("GetCode", string.lower(code)) end)
                task.wait(0.5)
            end
            Rayfield:Notify({Title = "Code", Content = "Đã xong!", Duration = 5})
        end)
    end
})

MiscTab:CreateSection("Server & Reconnect")

-- Nút Auto Reconnect
UI_Storage.Toggles["AutoReconnect"] = MiscTab:CreateToggle({
    Name = "🔄 Auto Reconnect (Tự vào lại khi Kick)",
    CurrentValue = false,
    Callback = function(V) getgenv().Config.AutoReconnect = V end,
})

-- Nút Hop Low
MiscTab:CreateButton({
    Name = "📉 Hop Server Ít Người (Low)",
    Callback = function()
        Rayfield:Notify({Title = "Hop Low", Content = "Đang tìm server vắng...", Duration = 3})
        local PlaceID = game.PlaceId
        local foundAnything = ""
        local function TPReturner()
            local Site;
            if foundAnything == "" then
                Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
            else
                Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
            end
            if Site.nextPageCursor and Site.nextPageCursor ~= "null" then foundAnything = Site.nextPageCursor end
            for i,v in pairs(Site.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(PlaceID, v.id, game.Players.LocalPlayer)
                    return
                end
            end
        end
        TPReturner()
    end
})

-- Nút Hop Random
MiscTab:CreateButton({
    Name = "🎲 Hop Server Ngẫu Nhiên (Random)",
    Callback = function()
        Rayfield:Notify({Title = "Hop Random", Content = "Đang tìm server khác...", Duration = 3})
        local PlaceID = game.PlaceId
        local function Hop()
            local Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
            local servers = {}
            for i,v in pairs(Site.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(servers, v.id)
                end
            end
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(PlaceID, servers[math.random(1, #servers)], game.Players.LocalPlayer)
            end
        end
        pcall(Hop)
    end
})

-- ====================================================
-- [ HỆ THỐNG CONFIG TÙY CHỈNH ]
-- ====================================================
MiscTab:CreateSection("📁 QUẢN LÝ CONFIG (MANUAL SAVE)")

local ProfileFileName = "KumaHub_V63_Profiles.json"
local Profiles = {}
local ProfileNames = {}

local function ReadProfiles()
    if isfile(ProfileFileName) then
        local success, result = pcall(function() return HttpService:JSONDecode(readfile(ProfileFileName)) end)
        if success then Profiles = result else Profiles = {} end
    else
        Profiles = {}
        writefile(ProfileFileName, HttpService:JSONEncode({}))
    end
    ProfileNames = {}
    for name, _ in pairs(Profiles) do table.insert(ProfileNames, name) end
    table.sort(ProfileNames)
    if #ProfileNames == 0 then table.insert(ProfileNames, "Chưa có Profile") end
end

ReadProfiles()

local InputProfileName = ""
local SelectedProfileToLoad = ProfileNames[1] or "Chưa có Profile"
local ProfileDropdown -- Khai báo trước

MiscTab:CreateInput({
    Name = "Tên Profile Mới",
    PlaceholderText = "VD: FarmDem, AutoBoss...",
    NumbersOnly = false,
    OnEnter = true, 
    Callback = function(Text) InputProfileName = Text end,
})

MiscTab:CreateButton({
    Name = "💾 LƯU CONFIG (Bấm để Lưu)",
    Callback = function()
        if InputProfileName == "" then 
            Rayfield:Notify({Title = "Lỗi", Content = "Chưa nhập tên Profile!", Duration = 2})
            return 
        end
        
        Profiles[InputProfileName] = {
            Config = getgenv().Config,
            BuyQueue = getgenv().BuyQueue
        }
        
        writefile(ProfileFileName, HttpService:JSONEncode(Profiles))
        ReadProfiles()
        if ProfileDropdown then ProfileDropdown:Refresh(ProfileNames) end
        Rayfield:Notify({Title = "Đã Lưu", Content = "Profile: " .. InputProfileName, Duration = 2})
    end,
})

ProfileDropdown = MiscTab:CreateDropdown({
    Name = "Chọn Profile",
    Options = ProfileNames,
    CurrentOption = ProfileNames[1] or "",
    MultipleOptions = false,
    Callback = function(Option) SelectedProfileToLoad = Option[1] end,
})

MiscTab:CreateButton({
    Name = "📂 LOAD CONFIG (Tự bật chức năng)",
    Callback = function()
        if not Profiles[SelectedProfileToLoad] then return end
        local data = Profiles[SelectedProfileToLoad]
        
        Rayfield:Notify({Title = "Loading...", Content = "Đang áp dụng cài đặt...", Duration = 2})

        if data.Config then
            if data.Config.ActivePlots then
                for i = 1, 6 do
                    local val = data.Config.ActivePlots[i]
                    if UI_Storage.Toggles["Plot_"..i] then 
                        UI_Storage.Toggles["Plot_"..i]:Set(val)
                    end
                end
            end

            local simpleToggles = {"AutoHarvest", "AutoPlant", "AutoBoss", "ClaimGift", "ClaimEvent", "ClaimEgg", "AutoSpin", "SmartBuy", "AutoReconnect"}
            for _, key in pairs(simpleToggles) do
                if data.Config[key] ~= nil and UI_Storage.Toggles[key] then
                    UI_Storage.Toggles[key]:Set(data.Config[key])
                end
            end

            if data.Config.DelayTime and UI_Storage.Sliders["DelayTime"] then
                UI_Storage.Sliders["DelayTime"]:Set(data.Config.DelayTime)
            end
        end

        if data.BuyQueue then
            for name, info in pairs(data.BuyQueue) do
                local tglKey = "Shop_" .. name
                if UI_Storage.Toggles[tglKey] and info.Active ~= nil then
                    UI_Storage.Toggles[tglKey]:Set(info.Active)
                end
            end
        end

        Rayfield:Notify({Title = "Thành Công", Content = "Đã load và bật lại các chức năng!", Duration = 3})
    end,
})

MiscTab:CreateButton({
    Name = "🗑️ Xóa Profile",
    Callback = function()
        if Profiles[SelectedProfileToLoad] then
            Profiles[SelectedProfileToLoad] = nil
            writefile(ProfileFileName, HttpService:JSONEncode(Profiles))
            ReadProfiles()
            if ProfileDropdown then ProfileDropdown:Refresh(ProfileNames) end
            Rayfield:Notify({Title = "Đã Xóa", Content = "Xóa thành công!", Duration = 2})
        end
    end
})
