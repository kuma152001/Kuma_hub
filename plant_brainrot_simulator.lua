-- // Kuma Hub V62: REBRANDED & OPTIMIZED //
-- Update: Đổi tên thành Kuma Hub.
-- Update: Xóa Blue Bucket.
-- Update: Auto Boss chuyển sang Tab Event.
-- Update New: Thêm hệ thống lưu Profile đa người dùng.

-- ====================================================
-- [1. CẤU HÌNH DATA & ID]
-- ====================================================
getgenv().ShopIDs = {
    -- [[ SEEDS ]]
    ["Tomato Seed"] = 1, ["Pumpkin Seed"] = 2, ["Melon Seed"] = 3, ["Mini Corn Seed"] = 4,
    ["Mushroom Seed"] = 5, ["Cactus Seed"] = 6, ["Broccoli Seed"] = 7, ["Sunflower Seed"] = 8,
    ["Chrysanthemum Seed"] = 9, ["Peashooter Seed"] = 10, ["Corn Seed"] = 11, ["Cactus Flower Seed"] = 12,
    ["Fire Peashooter Seed"] = 13, ["Threepeater Seed"] = 14, ["Man-Eating Flower Seed"] = 15,
    ["Alien Onion Seed"] = 16, ["Capsid Brute Seed"] = 17,

    -- [[ GEARS / BUCKETS ]] (Đã xóa Blue Water Bucket)
    ["Water Bucket (Thường)"] = 1, ["Granade"] = 2,
    ["Purple Bucket"] = 11, ["Orange Bucket"] = 10, ["Yellow Bucket"] = 9,

    -- [[ FRUITS ]]
    ["Reversion Fruit"] = 8, ["Frozen Fruit"] = 3, ["Darkness Fruit"] = 6, ["Kg Fruit"] = 12,
    ["Venom Fruit"] = 5, ["Flame Fruit"] = 4, ["Bomb Fruit"] = 7
}

local OrderedSeeds = {
    "Tomato Seed", "Pumpkin Seed", "Melon Seed", "Mini Corn Seed", 
    "Mushroom Seed", "Cactus Seed", "Broccoli Seed", "Sunflower Seed", 
    "Chrysanthemum Seed", "Peashooter Seed", "Corn Seed", "Cactus Flower Seed", 
    "Fire Peashooter Seed", "Threepeater Seed", "Man-Eating Flower Seed", 
    "Alien Onion Seed", "Capsid Brute Seed"
}

-- Đã xóa Blue Water Bucket khỏi danh sách sắp xếp
local OrderedGears = {
    "Granade",
    "Purple Bucket", "Orange Bucket", "Yellow Bucket",  "Water Bucket (Thường)"
}

local OrderedFruits = {
    "Reversion Fruit", "Frozen Fruit", "Darkness Fruit", "Kg Fruit", 
    "Venom Fruit", "Flame Fruit", "Bomb Fruit"
}

-- [2. CẤU HÌNH CHUNG]
getgenv().Config = {
    SmartBuy = false, 
    AutoPlant = false,
    AutoHarvest = false,
    AutoBoss = false,
    ActivePlots = {[1]=false, [2]=false, [3]=false, [4]=false, [5]=false, [6]=false},
    DelayTime = 0.2, 
    
    -- Events
    ClaimGift = false,
    ClaimEvent = false,
    ClaimEgg = false,
    AutoSpin = false
}
getgenv().BuyQueue = {} 

-- CONSTANTS TỪ CODE V29 CỦA BẠN
local CATEGORY_SEED_V29 = "\231\167\141\229\173\144" 
local CATEGORY_GEAR_V29 = "\233\129\147\229\133\183" 

local BOSS_NAME_CODE = "\228\184\150\231\149\140Boss"
local BOSS_NAME_TEXT = "世界Boss"

local ACTION_PLANT  = "放置_宠物" 
local ACTION_SHOVEL = "拾取_宠物" 
local ACTION_WATER  = "变化_宠物" 

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage:WaitForChild("RemoteEvent"):WaitForChild("ServerRemoteEvent")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService") -- Thêm HttpService để xử lý JSON

-- Reset UI
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
    local StartID = (PlotNum - 1) * 9 + 1
    local EndID = PlotNum * 9
    return StartID, EndID
end

-- ====================================================
-- [CORE 1: AUTO BUY (GENTLE MODE V60)]
-- ====================================================
task.spawn(function()
    local BuyIndex = 1
    while true do
        if getgenv().Config.SmartBuy then
            local activeItems = {}
            for k, v in pairs(getgenv().BuyQueue) do
                if v.Active then table.insert(activeItems, v) end
            end
            
            if #activeItems > 0 then
                -- Nhường đường cho Auto Farm
                local CurrentDelay = 0.8
                if getgenv().Config.AutoPlant or getgenv().Config.AutoHarvest then
                    CurrentDelay = 2.0 
                end

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

-- ====================================================
-- [CORE 2: FARMING & BOSS]
-- ====================================================
task.spawn(function()
    while true do
        local Delay = getgenv().Config.DelayTime
        local activePlotsFound = false

        for i = 1, 6 do
            if getgenv().Config.ActivePlots[i] then activePlotsFound = true break end
        end

        if activePlotsFound then
            -- 1. AUTO HARVEST
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

            -- 2. AUTO PLANT
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

        -- AUTO BOSS (Logic nằm ở đây, nhưng nút bật nằm ở Tab Event)
        if getgenv().Config.AutoBoss then
             FireRemote("Business", BOSS_NAME_CODE, 1) 
             FireRemote("Business", BOSS_NAME_TEXT, 1) 
             task.wait(1.5) 
        end

        if not getgenv().Config.AutoPlant and not getgenv().Config.AutoHarvest then
            task.wait(0.5)
        end
    end
end)

-- ====================================================
-- [CORE 3: EVENTS & UTILITIES]
-- ====================================================
task.spawn(function()
    local GiftIndex = 1
    local EventIndex = 1
    local TimeCounter = 0
    while true do
        TimeCounter = TimeCounter + 1
        if TimeCounter > 20 then
            TimeCounter = 0
            if getgenv().Config.ClaimGift then
                FireRemote("GetOnlineGift", GiftIndex)
                GiftIndex = GiftIndex + 1
                if GiftIndex > 12 then GiftIndex = 1 end
            end
            if getgenv().Config.ClaimEvent then
                 FireRemote("Business", "\229\133\145\230\141\162\230\153\174\233\128\154\230\180\187\229\138\168\229\165\150\229\138\177", EventIndex)
                 EventIndex = EventIndex + 1
                 if EventIndex > 7 then EventIndex = 1 end
            end
            if getgenv().Config.ClaimEgg then FireRemote("OpenEventEgg", 2) end
            if getgenv().Config.AutoSpin then FireRemote("OpenSpecialEgg", "\232\189\172\231\155\152\232\155\139") end
        end
        task.wait(0.1)
    end
end)

-- ANTI-AFK
task.spawn(function()
    while true do
        task.wait(120)
        pcall(function()
            if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                Players.LocalPlayer.Character.Humanoid.Jump = true
            end
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
   Name = "Kuma Hub | V62",
   Icon = 0,
   LoadingTitle = "Kuma Hub Script",
   LoadingSubtitle = "Gentle Buy & Smooth Farm",
   Theme = "AmberGlow",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = true,
   ConfigurationSaving = { Enabled = true, FolderName = "KumaHubConfig", FileName = "ManagerV62" }, 
   KeySystem = false,
})

-- TAB 1: FARMING
local FarmTab = Window:CreateTab("Farming🌱", nil)
FarmTab:CreateSection("1. Chọn Các Mảnh Đất")
for i = 1, 6 do
    FarmTab:CreateToggle({Name = "Mảnh " .. i, CurrentValue = (i == 1), Callback = function(V) getgenv().Config.ActivePlots[i] = V end})
end
FarmTab:CreateSection("2. Auto Loop")
FarmTab:CreateToggle({Name = "⛏️ Auto Thu Hoạch (Cầm Xẻng 1 lần -> Đào hết)", CurrentValue = false, Callback = function(V) getgenv().Config.AutoHarvest = V end})
FarmTab:CreateToggle({Name = "🔥 Auto Trồng (Bạn cầm hạt -> Trồng hết)", CurrentValue = false, Callback = function(V) getgenv().Config.AutoPlant = V end})
FarmTab:CreateSlider({Name = "Tốc Độ (Delay)", Range = {0.15, 0.5}, Increment = 0.05, Suffix = "s", CurrentValue = 0.2, Callback = function(V) getgenv().Config.DelayTime = V end})
FarmTab:CreateSection("3. Tưới Nước")
local isWatering = false
FarmTab:CreateButton({
   Name = "💦 TƯỚI CÁC MẢNH ĐÃ CHỌN (1 Lượt)",
   Callback = function()
       if isWatering then return end
       isWatering = true
       local Delay = getgenv().Config.DelayTime
       Rayfield:Notify({Title = "Đang tưới...", Content = "Chạy một mạch qua các mảnh...", Duration = 2})
       task.spawn(function()
           FireRemote("Change_ArrayBool_Item", "手牌", 3)
           task.wait(0.5) 
           for PlotNum = 1, 6 do
               if getgenv().Config.ActivePlots[PlotNum] then
                   local StartID, EndID = GetPlotTiles(PlotNum)
                   for i = StartID, EndID do
                       FireRemote("Business", ACTION_WATER, i)
                       task.wait(Delay)
                   end
               end
           end
           Rayfield:Notify({Title = "Xong!", Content = "Đã tưới hết.", Duration = 2})
           isWatering = false
       end)
   end,
})

-- TAB 2: EVENTS (Đã thêm Auto Boss vào đây)
local EventTab = Window:CreateTab("Events🎁", nil)
EventTab:CreateSection("Boss & Chiến Đấu")
EventTab:CreateToggle({Name = "🔥 Auto Boss (Chuẩn V29)", CurrentValue = false, Callback = function(V) getgenv().Config.AutoBoss = V end})

EventTab:CreateSection("Quà & Sự Kiện")
EventTab:CreateToggle({Name = "Auto Claim Gift", CurrentValue = false, Callback = function(V) getgenv().Config.ClaimGift = V end})
EventTab:CreateToggle({Name = "Auto Claim Event", CurrentValue = false, Callback = function(V) getgenv().Config.ClaimEvent = V end})
EventTab:CreateToggle({Name = "Auto Claim Egg", CurrentValue = false, Callback = function(V) getgenv().Config.ClaimEgg = V end})
EventTab:CreateToggle({Name = "Auto Spin", CurrentValue = false, Callback = function(V) getgenv().Config.AutoSpin = V end})

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
            for round = 1, 3 do
                for i = 1, 54 do
                    FireRemote("Business", "\230\139\190\229\143\150_\229\174\160\231\137\169", i)
                    task.wait(0.05)
                end
                task.wait(0.5)
            end
            FireRemote("QuickFuse", "\229\174\160\231\137\169")
            task.wait(0.8)
            FireRemote("Change_ArrayBool_Item", "\230\137\139\231\137\140", 3)
            Rayfield:Notify({Title = "Merge", Content = "Đã xong!", Duration = 3})
        end)
   end,
})

-- TAB 3: SHOP (Mua Chậm - V29 Logic)
local ShopTab = Window:CreateTab("Shop (Mua Chậm)🛒", nil)
ShopTab:CreateToggle({
    Name = "🔴 BẬT/TẮT AUTO BUY",
    CurrentValue = false,
    Callback = function(Value) getgenv().Config.SmartBuy = Value end,
})

local function CreateBuyBtn(name, categoryCode, id)
    ShopTab:CreateToggle({
        Name = "[" .. id .. "] " .. name,
        Callback = function(Value) 
            getgenv().BuyQueue[name] = {Active = Value, Category = categoryCode, ID = id} 
        end
    })
end

ShopTab:CreateSection("--- [ DỤNG CỤ/GEAR ] ---")
for _, name in ipairs(OrderedGears) do 
    if getgenv().ShopIDs[name] then CreateBuyBtn(name, CATEGORY_GEAR_V29, getgenv().ShopIDs[name]) end 
end

ShopTab:CreateSection("--- [ HẠT GIỐNG ] ---")
for _, name in ipairs(OrderedSeeds) do 
    if getgenv().ShopIDs[name] then CreateBuyBtn(name, CATEGORY_SEED_V29, getgenv().ShopIDs[name]) end 
end

ShopTab:CreateSection("--- [ TRÁI CÂY ] ---")
for _, name in ipairs(OrderedFruits) do 
    if getgenv().ShopIDs[name] then CreateBuyBtn(name, CATEGORY_GEAR_V29, getgenv().ShopIDs[name]) end 
end

-- TAB 4: MISC & PS & PROFILE SYSTEM
local MiscTab = Window:CreateTab("Misc/PS🚀", nil)
MiscTab:CreateButton({Name = "Redeem All Codes", Callback = function()
    local codes = {"UPDATE1", "UPDATE2", "UPDATE3", "UPDATE4", "kgfruit", "CRYSTAL500", "Fuse777", "Best999", "Redress", "VIP888", "Grow888", "New666", "CRYSTAL1", "CRYSTAL2", "ITEMS100"}
    for _, code in ipairs(codes) do FireRemote("GetCode", code) task.wait(0.2) end
end})
MiscTab:CreateButton({Name = "🥔 FPS Boost", Callback = function()
    game:GetService("Lighting").GlobalShadows = false
    settings().Rendering.QualityLevel = 1
    for i,v in pairs(game:GetDescendants()) do
        if v:IsA("Part") then v.Material = "Plastic" end
    end
end})
MiscTab:CreateButton({Name = "⬜ White Screen", Callback = function() game:GetService("RunService"):Set3dRenderingEnabled(false) end})
MiscTab:CreateButton({Name = "📺 Normal Screen", Callback = function() game:GetService("RunService"):Set3dRenderingEnabled(true) end})

MiscTab:CreateSection("Private Servers")
getgenv().ServerList = {
    ["Server 1"] = "DIEN_MA_CODE_VAO_DAY", 
    ["Server 2"] = "DIEN_MA_CODE_VAO_DAY",
    ["Server 3"] = "DIEN_MA_CODE_VAO_DAY",
    ["Server 4"] = "DIEN_MA_CODE_VAO_DAY",
    ["Server 5"] = "DIEN_MA_CODE_VAO_DAY",
}
local SelectedServerKey = "Server 1"
MiscTab:CreateDropdown({
    Name = "Chọn Server",
    Options = {"Server 1", "Server 2", "Server 3", "Server 4", "Server 5"},
    Callback = function(Option) SelectedServerKey = Option[1] end,
})
MiscTab:CreateButton({
    Name = "🚀 Vào Server Đã Chọn",
    Callback = function()
        local Code = getgenv().ServerList[SelectedServerKey]
        if Code and Code ~= "DIEN_MA_CODE_VAO_DAY" then
            game:GetService("TeleportService"):TeleportToPrivateServer(game.PlaceId, Code, {game.Players.LocalPlayer})
        else
            Rayfield:Notify({Title = "Lỗi", Content = "Chưa điền Code vào Script!", Duration = 3})
        end
    end
})

-- ====================================================
-- [ HỆ THỐNG LƯU PROFILE (MỚI THÊM) ]
-- ====================================================
MiscTab:CreateSection("📁 QUẢN LÝ HỒ SƠ (PROFILES)")

local ProfileFileName = "KumaHub_Profiles_V62.json"
local Profiles = {}
local ProfileNames = {}

-- Hàm Load File
local function LoadProfilesFromFile()
    if isfile(ProfileFileName) then
        local success, result = pcall(function() return HttpService:JSONDecode(readfile(ProfileFileName)) end)
        if success and result then
            Profiles = result
        else
            Profiles = {}
        end
    else
        Profiles = {}
    end
    -- Cập nhật danh sách tên
    ProfileNames = {}
    for name, _ in pairs(Profiles) do
        table.insert(ProfileNames, name)
    end
    if #ProfileNames == 0 then table.insert(ProfileNames, "Chưa có Profile") end
end

-- Hàm Save File
local function SaveProfilesToFile()
    writefile(ProfileFileName, HttpService:JSONEncode(Profiles))
end

-- Khởi động lần đầu
LoadProfilesFromFile()

local InputProfileName = ""
local SelectedProfileToLoad = ProfileNames[1] or "Chưa có Profile"

MiscTab:CreateInput({
    Name = "Nhập Tên Profile Mới",
    PlaceholderText = "VD: Farm_Dem, Auto_Boss...",
    NumbersOnly = false,
    OnEnter = true, 
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        InputProfileName = Text
    end,
})

local ProfileDropdown -- Khai báo trước để dùng bên dưới

MiscTab:CreateButton({
    Name = "💾 Lưu Cấu Hình Hiện Tại (Tạo Mới/Ghi Đè)",
    Callback = function()
        if InputProfileName == "" then 
            Rayfield:Notify({Title = "Lỗi", Content = "Vui lòng nhập tên Profile!", Duration = 2})
            return 
        end
        
        -- Lưu cấu hình hiện tại vào bảng
        Profiles[InputProfileName] = {
            Config = getgenv().Config,
            BuyQueue = getgenv().BuyQueue
        }
        
        SaveProfilesToFile()
        LoadProfilesFromFile() -- Reload lại danh sách
        Rayfield:Notify({Title = "Thành Công", Content = "Đã lưu Profile: " .. InputProfileName, Duration = 2})
        
        -- Refresh Dropdown
        if ProfileDropdown then
            ProfileDropdown:Refresh(ProfileNames)
        end
    end,
})

ProfileDropdown = MiscTab:CreateDropdown({
    Name = "Chọn Profile Đã Lưu",
    Options = ProfileNames,
    CurrentOption = ProfileNames[1] or "",
    MultipleOptions = false,
    Callback = function(Option)
        SelectedProfileToLoad = Option[1]
    end,
})

MiscTab:CreateButton({
    Name = "📂 Load Profile Đã Chọn",
    Callback = function()
        if not Profiles[SelectedProfileToLoad] then
            Rayfield:Notify({Title = "Lỗi", Content = "Không tìm thấy dữ liệu Profile này!", Duration = 2})
            return
        end
        
        local data = Profiles[SelectedProfileToLoad]
        
        -- Nạp dữ liệu vào getgenv
        if data.Config then
            for k, v in pairs(data.Config) do
                getgenv().Config[k] = v
            end
        end
        
        if data.BuyQueue then
            -- Reset BuyQueue cũ và nạp mới
            getgenv().BuyQueue = data.BuyQueue
        end
        
        Rayfield:Notify({Title = "Đã Load", Content = "Cấu hình: " .. SelectedProfileToLoad .. "\n(Lưu ý: Bật tắt lại UI để hiển thị đúng)", Duration = 3})
    end,
})

MiscTab:CreateButton({
    Name = "🗑️ Xóa Profile Đã Chọn",
    Callback = function()
        if Profiles[SelectedProfileToLoad] then
            Profiles[SelectedProfileToLoad] = nil
            SaveProfilesToFile()
            LoadProfilesFromFile()
            Rayfield:Notify({Title = "Đã Xóa", Content = "Đã xóa Profile: " .. SelectedProfileToLoad, Duration = 2})
            
            -- Refresh Dropdown
            if ProfileDropdown then
                ProfileDropdown:Refresh(ProfileNames)
            end
        else
            Rayfield:Notify({Title = "Lỗi", Content = "Không tồn tại Profile này!", Duration = 2})
        end
    end,
})
