-- [[ 1. CLEANUP & INITIALIZATION ]] --
if _G.ScriptRunning then
    _G.ScriptRunning = false
    task.wait(0.5)
end
if game.CoreGui:FindFirstChild("Rayfield") then
    game.CoreGui.Rayfield:Destroy()
end
_G.ScriptRunning = true

-- [[ 2. DATA & CONFIG ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RemoteEvents = RS:WaitForChild("RemoteEvents")

local Config = {
    KillAura = false, TreeAura = false, Range = 500, Speed = 0.05,
    AutoEat = false, AutoFire = false, WalkSpeed = 16, AutoBringTrees = false
}

local itemsFolder = Workspace:WaitForChild("Items")
local campfireDropPos = Vector3.new(0, 19, 0)
local originalTreeCFrames = {}

-- BRACKETS PHÂN LOẠI VẬT PHẨM
local Brackets = {
    Weapons = {"Laser Sword", "Raygun", "Kunai", "Katana", "Spear"},
    Food = {"Apple", "Berry", "Carrot"},
    Meat = {"Steak", "Cooked Steak", "Cooked Morsel", "Morsel"},
    Medical = {"Bandage", "MedKit"},
    Armor = {"Leather Body", "Iron Body", "Thorn Body"},
    GunsAmmo = {"Rifle", "Revolver", "Raygun", "Tactical Shotgun", "Revolver Ammo", "Rifle Ammo"},
    Materials = {"Sheet Metal", "Bolt", "Broken Fan", "Tyre", "Washing Machine", "Broken Microwave", "Old Car Engine", "Old Radio", "UFO Junk", "UFO Component", "Hologram Emitter", "Laser Fence Blueprint", "Sapling", "Flower", "Cultist Gem"},
    Pelts = {"Alpha Wolf Pelt", "Bear Pelt", "Wolf Pelt", "Bunny Foot"},
    MiscTools = {"Good Sack", "Old Flashlight", "Giant Sack", "Strong Flashlight", "Chainsaw"},
    Fuel = {"Coal", "Fuel Canister", "Oil Barrel", "Biofuel"}
}

local toolsDamageIDs = {
    ["Old Axe"] = "1_8982038982", ["Good Axe"] = "112_8982038982", ["Strong Axe"] = "116_8982038982",
    ["Chainsaw"] = "647_8992824875", ["Spear"] = "196_8999010016"
}

-- [[ 3. UTILITIES ]] --
local function moveItem(item, pos, count)
    pcall(function()
        local part = item:FindFirstChildWhichIsA("BasePart") or item.PrimaryPart
        if part then
            RemoteEvents.RequestStartDraggingItem:FireServer(item)
            task.wait(0.05)
            local offset = Vector3.new(0, (count or 0) * 2.5, 0)
            if item.SetPrimaryPartCFrame then item:SetPrimaryPartCFrame(CFrame.new(pos + offset)) else part.CFrame = CFrame.new(pos + offset) end
            task.wait(0.05)
            RemoteEvents.StopDraggingItem:FireServer(item)
        end
    end)
end

local function bringItems(list)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local c = 0
    for _, item in ipairs(itemsFolder:GetChildren()) do
        if table.find(list, item.Name) then
            moveItem(item, hrp.Position + Vector3.new(0, 5, 0), c)
            c = c + 1
        end
    end
end

-- Logic Tree Bring (Source Logic)
local function getAllSmallTrees()
    local trees = {}
    local map = Workspace:FindFirstChild("Map")
    if map and map:FindFirstChild("Foliage") then
        for _, obj in ipairs(map.Foliage:GetChildren()) do
            if obj.Name == "Small Tree" then table.insert(trees, obj) end
        end
    end
    return trees
end

local function toggleTreeBring(v)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not v then 
        -- Reset vị trí cây khi tắt
        for tree, cf in pairs(originalTreeCFrames) do
            if tree and tree.Parent then
                pcall(function()
                    tree.PrimaryPart.Anchored = false
                    tree:SetPrimaryPartCFrame(cf)
                    tree.PrimaryPart.Anchored = true
                end)
            end
        end
        table.clear(originalTreeCFrames)
        return 
    end

    local target = hrp.CFrame * CFrame.new(0, 0, -10)
    for _, tree in ipairs(getAllSmallTrees()) do
        local trunk = tree:FindFirstChild("Trunk")
        if trunk then
            if not originalTreeCFrames[tree] then originalTreeCFrames[tree] = trunk.CFrame end
            tree.PrimaryPart = trunk
            trunk.CanCollide = false
            trunk.Anchored = false
            tree:SetPrimaryPartCFrame(target + Vector3.new(math.random(-5,5), 0, math.random(-5,5)))
            trunk.Anchored = true
        end
    end
end

-- [[ 4. GIAO DIỆN RAYFIELD ]] --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "99 Nights | Kuma Hub V7",
    LoadingTitle = "Multi-Aura & Detailed ESP Ready",
    ConfigurationSaving = { Enabled = false }
})

-- TAB 1: COMBAT (Aura Multi-Target)
local CombatTab = Window:CreateTab("Combat", 4483362458)
CombatTab:CreateToggle({Name = "Kill Aura (Multi-Target)", Callback = function(v) Config.KillAura = v end})
CombatTab:CreateToggle({Name = "Auto Bring All Small Trees", CurrentValue = false, Callback = function(v) Config.AutoBringTrees = v; toggleTreeBring(v) end})
CombatTab:CreateSlider({
    Name = "Aura Range",
    Range = {10, 1000},
    Increment = 10,
    Suffix = " Studs",
    CurrentValue = 500,
    Flag = "RangeSlider", 
    Callback = function(v) Config.Range = v end
})

-- TAB 2: ITEM HUB (Gộp Survival + Gear + Material)
local ItemHub = Window:CreateTab("Item Hub", 4483362458)

ItemHub:CreateSection("Wood Section")
ItemHub:CreateButton({Name = "BRING ALL Woods", Callback = function() bringItems({"Log", "Chair"}) end})
ItemHub:CreateButton({Name = "BRING Sapling", Callback = function() bringItems({"Sapling"}) end})

ItemHub:CreateSection("Automations")
ItemHub:CreateToggle({Name = "Auto Eat", Callback = function(v) Config.AutoEat = v end})
ItemHub:CreateToggle({Name = "Auto Feed Campfire", Callback = function(v) Config.AutoFire = v end})

ItemHub:CreateSection("Survival & Food")
ItemHub:CreateButton({Name = "Bring Medical", Callback = function() bringItems(Brackets.Medical) end})
ItemHub:CreateButton({Name = "Bring Food", Callback = function() bringItems(Brackets.Food) end})
ItemHub:CreateButton({Name = "Bring Meat", Callback = function() bringItems(Brackets.Meat) end})

ItemHub:CreateSection("Gear & Equipment")
ItemHub:CreateButton({Name = "Bring Weapons & Armor", Callback = function() bringItems(Brackets.Weapons); bringItems(Brackets.Armor); bringItems(Brackets.GunsAmmo) end})
ItemHub:CreateButton({Name = "Bring Misc Tools (Sacks/Flashlights)", Callback = function() bringItems(Brackets.MiscTools) end})

ItemHub:CreateSection("Materials & Fuel")
ItemHub:CreateButton({Name = "Bring All Fuels", Callback = function() bringItems(Brackets.Fuel) end})
ItemHub:CreateButton({Name = "Bring Crafting Materials", Callback = function() bringItems(Brackets.Materials); bringItems(Brackets.Pelts) end})
ItemHub:CreateButton({Name = "Bring All Chests", Callback = function() bringItems({"Alien Chest", "Stronghold Diamond Chest"}) end})

-- TAB 3: VISUALS (ESP PHÂN LOẠI)
local ESPTab = Window:CreateTab("Visuals", 4483362458)
local ESP_Tags = { Mobs = {}, Food = {}, Mats = {}, Rare = {} }
local function ClearESP(g) for _,t in pairs(ESP_Tags[g]) do pcall(function() t:Destroy() end) end; ESP_Tags[g] = {} end
local function CreateESP(i, col, g)
    if i:FindFirstChild("BillboardGui") then return end
    local b = Instance.new("BillboardGui", i); b.AlwaysOnTop = true; b.Size = UDim2.new(0,80,0,30)
    local l = Instance.new("TextLabel", b); l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1; l.Text = i.Name; l.TextColor3 = col; l.TextScaled = true
    table.insert(ESP_Tags[g], b)
end

ESPTab:CreateToggle({Name = "ESP Mobs (Red)", Callback = function(v) ClearESP("Mobs") if v then for _,m in pairs(workspace.Characters:GetChildren()) do if m ~= LocalPlayer.Character then CreateESP(m, Color3.new(1,0,0), "Mobs") end end end end})
ESPTab:CreateToggle({Name = "ESP Food & Medical (Green)", Callback = function(v) ClearESP("Food") if v then for _,i in pairs(itemsFolder:GetChildren()) do if table.find(Brackets.Food, i.Name) or table.find(Brackets.Medical, i.Name) then CreateESP(i, Color3.new(0,1,0), "Food") end end end end})
ESPTab:CreateToggle({Name = "ESP Wood & Materials (Cyan)", Callback = function(v) ClearESP("Mats") if v then for _,i in pairs(itemsFolder:GetChildren()) do if table.find(Brackets.Materials, i.Name) or table.find(Brackets.Fuel, i.Name) or i.Name == "Log" then CreateESP(i, Color3.new(0,1,1), "Mats") end end end end})
ESPTab:CreateToggle({Name = "ESP Rare & Weapons (Gold)", Callback = function(v) ClearESP("Rare") if v then for _,i in pairs(itemsFolder:GetChildren()) do if table.find(Brackets.Weapons, i.Name) or i.Name:find("Chest") then CreateESP(i, Color3.new(1,0.8,0), "Rare") end end end end})

-- TAB 4: MISC (Bao gồm Teleport)
local MiscTab = Window:CreateTab("Misc", 4483362458)
MiscTab:CreateSection("Teleport Locations")
MiscTab:CreateButton({Name = "TP Campsite", Callback = function() LocalPlayer.Character:PivotTo(CFrame.new(0, 8, 0)) end})
MiscTab:CreateButton({Name = "TP Safe Zone Sky", Callback = function() LocalPlayer.Character:PivotTo(CFrame.new(0, 110, 0)) end})
MiscTab:CreateSection("Player TP")
local SelP = ""
local PDrop = MiscTab:CreateDropdown({Name = "Select Player", Options = {}, Callback = function(v) SelP = v end})
task.spawn(function() while _G.ScriptRunning do local p = {}; for _,v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then table.insert(p, v.Name) end end; PDrop:Set(p); task.wait(5) end end)
MiscTab:CreateButton({Name = "TP to Player", Callback = function() local t = Players:FindFirstChild(SelP) if t and t.Character then LocalPlayer.Character:PivotTo(t.Character:GetPivot()) end end})
MiscTab:CreateSection("Settings")
MiscTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 250},
    Increment = 1,
    Suffix = " Speed",
    CurrentValue = 16,
    Flag = "WSSlider",
    Callback = function(Value)
        Config.WalkSpeed = Value
        -- Cập nhật ngay lập tức cho nhân vật
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = Value
            end
        end)
    end,
})
MiscTab:CreateButton({Name = "Anti-AFK", Callback = function() LocalPlayer.Idled:Connect(function() game:GetService("VirtualUser"):CaptureController(); game:GetService("VirtualUser"):ClickButton2(Vector2.new()) end) end})

-- [[ 5. LOGIC LOOPS (COPY TỪ SCRIPT GỐC) ]] --

-- Loop WalkSpeed
task.spawn(function()
    while _G.ScriptRunning do
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= Config.WalkSpeed then hum.WalkSpeed = Config.WalkSpeed end
        end)
        task.wait(0.5)
    end
end)

-- Loop Auto Eat (Source GUI Path)
task.spawn(function()
    while _G.ScriptRunning do
        if Config.AutoEat then
            pcall(function()
                local hungerBar = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface"):WaitForChild("StatBars"):WaitForChild("HungerBar"):WaitForChild("Bar")
                if hungerBar.Size.X.Scale <= 0.5 then
                    for _, item in ipairs(itemsFolder:GetChildren()) do
                        if table.find(Brackets.Food, item.Name) then
                            RS.RemoteEvents.RequestConsumeItem:InvokeServer(item)
                            task.wait(1.2)
                            if hungerBar.Size.X.Scale >= 0.95 or not Config.AutoEat then break end
                        end
                    end
                end
            end)
        end
        task.wait(3)
    end
end)

-- Loop Auto Fire (Source Logic)
task.spawn(function()
    while _G.ScriptRunning do
        if Config.AutoFire then
            pcall(function()
                local fire = Workspace.Map.Campground.MainFire
                local fill = fire.Center.BillboardGui.Frame.Background.Fill
                if fill.Size.X.Scale < 0.7 then
                    local count = 0
                    for _, item in ipairs(itemsFolder:GetChildren()) do
                        if item.Name == "Log" or table.find(Brackets.Fuel, item.Name) then
                            moveItem(item, campfireDropPos, count) -- FIX 2: Đổi tên thành moveItem
                            count = count + 1; task.wait(0.2)
                        end
                    end
                end
            end)
        end
        task.wait(4)
    end
end)

-- Combat & Multi-Target aura Farm
-- [[ 5. TỐI ƯU HÓA KILL AURA (FAST & MULTI-TARGET) ]] --
task.spawn(function()
    while _G.ScriptRunning do
        if Config.KillAura then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                -- Tìm vũ khí có trong danh sách
                local tool, dmgID = nil, nil
                for tN, id in pairs(toolsDamageIDs) do
                    local t = LocalPlayer.Inventory:FindFirstChild(tN) or char:FindFirstChild(tN)
                    if t then tool = t; dmgID = id; break end
                end

                if tool then
                    -- Quét tất cả các con trong Workspace.Characters
                    for _, m in pairs(Workspace.Characters:GetChildren()) do
                        if m ~= char and m:IsA("Model") then
                            -- Kiểm tra nếu là Mob (có Humanoid và còn máu)
                            local hum = m:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then 
                                local mPart = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                                
                                -- Kiểm tra khoảng cách
                                if mPart and (mPart.Position - hrp.Position).Magnitude <= Config.Range then
                                    -- FIX TỐC ĐỘ: Sử dụng task.spawn để gửi lệnh đánh đồng thời 
                                    -- không cần đợi Server phản hồi, giúp đánh nhiều mục tiêu cùng 1 lúc cực nhanh
                                    task.spawn(function()
                                        RS.RemoteEvents.ToolDamageObject:InvokeServer(m, tool, dmgID, mPart.CFrame)
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
        end
        -- TỐC ĐỘ: Để task.wait cực nhỏ để vòng lặp quét liên tục
        task.wait(0.01) 
    end
end)

Rayfield:Notify({Title = "V7 Multi-Aura", Content = "Kill Aura."})
