--==============================================================
--  KUMA HUB V165 - FIXED (TELEPORT MODE + FULL FEATURES + NPC ESP)
--==============================================================

local ScriptID = tick()
_G.KumaInstanceID = ScriptID
local function IsAlive() return _G.KumaInstanceID == ScriptID end

-- CLEANUP (Xóa GUI cũ và các Folder ESP cũ)
pcall(function()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name:find("Kuma") or v.Name:find("Secure") or v.Name:find("ESP") then v:Destroy() end
    end
end)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local HttpService = game:GetService("HttpService")

-- Services
local LP = game:GetService("Players").LocalPlayer
local CG = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")
local WS = game:GetService("Workspace")
local RS = game:GetService("RunService")
local PLRS = game:GetService("Players")
local LGT = game:GetService("Lighting")

-- === CONFIG ===
local PRESET_LIST = {
    "Ginseng", "Spirit Rose", "Qi Flower", "Qi Berries", "Moon Flower", "Death Flower",
    "Verdant Vitality Gu", "Crimson Bloodflame Gu", "Amethyst Golden-Ring Gu", "Radiant Seraphwing Gu", "Obsidian Bloodwing Gu",
    "Blue Lily", "Red Lily", "Spider Lily", "Giyuu's Soul", "Herb", "Mushroom", "Flower"
}

_G.Config = { 
    Tracking = {},       
    AutoLoot = false,    
    FarmAll = false,     
    HoldDelay = 0.2,     
    SyncDelay = 0.6,     
    ScanInterval = 1000, 
    AutoReturn = false,   
    SavedPosition = nil,
    KeySequence = {},    
    SequenceDelay = 1.0, 
    TempKey = "Z",
    ExtraKeys = {},    
    ExtraKeyDelay = 1.0,
    Waypoints = {},
    WaypointDelay = 2,
    AutoWaypoint = false, 
    AutoClean = true,
    FPSBoost = false
}

local LocationCache = {} -- Cache Tọa độ (Fix farm xa)
local FailedList = {} 
local IsReturning = false -- Cờ kiểm soát Return
local SecureFolder = Instance.new("Folder", CG); SecureFolder.Name = "KumaSecure_V165"

-- === SAVE SYSTEM ===
local FileName = "KumaHub_V165_Data.json"
local function SaveCustomData()
    local data = { Waypoints = {}, ExtraKeys = _G.Config.ExtraKeys }
    for _, cf in ipairs(_G.Config.Waypoints) do table.insert(data.Waypoints, {cf:GetComponents()}) end
    if writefile then writefile(FileName, HttpService:JSONEncode(data)); Rayfield:Notify({Title = "Saved", Content = "All Data Saved", Duration = 1}) end
end

local function LoadCustomData()
    if isfile and isfile(FileName) then
        local content = readfile(FileName); local decoded = HttpService:JSONDecode(content)
        if decoded.ExtraKeys then _G.Config.ExtraKeys = decoded.ExtraKeys end
        if decoded.Waypoints then
            _G.Config.Waypoints = {}
            for _, comp in ipairs(decoded.Waypoints) do table.insert(_G.Config.Waypoints, CFrame.new(unpack(comp))) end
        end
        Rayfield:Notify({Title = "Loaded", Content = "Data Restored", Duration = 1})
    else Rayfield:Notify({Title = "Error", Content = "No Save File", Duration = 1}) end
end

-- === OPTIMIZATION ===
local function BoostFPS()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Texture") or v:IsA("Decal") then v.Texture = "" end
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
    end
    LGT.GlobalShadows = false
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end

local function SmartGC()
    FailedList = {}
    SecureFolder:ClearAllChildren()
end

-- === GUI ===
local Window = Rayfield:CreateWindow({
   Name = "🦗 KUMA HUB V165 | Teleport & ESP",
   LoadingTitle = "Restoring Functions...",
   LoadingSubtitle = "Full Map Scan Integrated",
   ConfigurationSaving = { Enabled = true, FolderName = "KumaHubConfig", FileName = "SettingsV165" },
   KeySystem = false,
})

-- === TAB 1: MAIN FARM ===
local TabMain = Window:CreateTab("🏠 Main Farming", 4483362458)
local StatusLabel = TabMain:CreateLabel("Status: Idle")

-- HÀM QUÉT MAP (FIX LAG + LƯU TỌA ĐỘ)
local function ScanMapToCache()
    if IsReturning then return end
    StatusLabel:Set("Status: Scanning Map (Wait)...")
    Rayfield:Notify({Title = "System", Content = "Scanning Map...", Duration = 2})
    
    table.clear(LocationCache)
    local count = 0
    local processed = 0
    
    for _, v in ipairs(WS:GetDescendants()) do
        -- Anti-Lag: Nghỉ sau mỗi 1000 items
        processed = processed + 1
        if processed % _G.Config.ScanInterval == 0 then task.wait() end
        
        if v:IsA("Model") or v:IsA("BasePart") then
            local rawName = v.Name
            local bb = v:FindFirstChildWhichIsA("BillboardGui", true)
            if bb then
                local lbl = bb:FindFirstChildWhichIsA("TextLabel", true)
                if lbl and lbl.Text ~= "" then rawName = lbl.Text end
            end
            
            -- Kiểm tra xem có trong danh sách cần farm không
            local isTarget = false
            for _, preset in ipairs(PRESET_LIST) do
                if rawName:find(preset) then isTarget = true; break end
            end
            
            if isTarget then
                local pos = (v:IsA("Model") and v:GetPivot().Position) or v.Position
                -- Lưu tọa độ để Teleport (Fix lỗi xa không thấy)
                table.insert(LocationCache, {Name = rawName, Position = pos})
                count = count + 1
            end
        end
    end
    StatusLabel:Set("Found: " .. count .. " items")
    Rayfield:Notify({Title = "Scan Done", Content = "Saved " .. count .. " locations.", Duration = 3})
end

TabMain:CreateSection("1. Setup")
TabMain:CreateButton({ 
    Name = "📡 SCAN MAP (Click Once)", 
    Callback = function() ScanMapToCache() end 
})

TabMain:CreateSection("2. Farming")
TabMain:CreateToggle({
   Name = "▶ START AUTO FARM",
   CurrentValue = false,
   Flag = "AutoLoot", 
   Callback = function(Value)
        _G.Config.AutoLoot = Value
        if Value then
            if #LocationCache == 0 then
                Rayfield:Notify({Title = "Warning", Content = "Click 'SCAN MAP' first!", Duration = 3})
            end
        else
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.Anchored = false
            end
            StatusLabel:Set("Status: Idle")
        end
   end,
})

TabMain:CreateToggle({ Name = "🌍 FARM ALL (Ignore List)", CurrentValue = false, Flag = "FarmAll", Callback = function(Value) _G.Config.FarmAll = Value end })
TabMain:CreateSection("Utils")
TabMain:CreateButton({ Name = "⚡ BOOST FPS", Callback = function() BoostFPS() end })
TabMain:CreateToggle({ Name = "🧹 Auto Clean RAM", CurrentValue = true, Flag = "AutoClean", Callback = function(V) _G.Config.AutoClean = V end })

TabMain:CreateSection("Auto Return")
TabMain:CreateButton({ Name = "📍 Save Current Position", Callback = function() if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then _G.Config.SavedPosition = LP.Character.HumanoidRootPart.CFrame; Rayfield:Notify({Title="Success", Content="Position Saved"}) end end })

-- HÀM RETURN (DÙNG TELEPORT, KHÔNG TWEEN)
local function PerformAutoReturn()
    if not _G.Config.SavedPosition then return end
    
    IsReturning = true -- Khóa Farm
    StatusLabel:Set("Status: Returning...")
    
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        hrp.Anchored = false
        hrp.AssemblyLinearVelocity = Vector3.zero
        
        -- Teleport CFrame (Theo yêu cầu: Teleport chứ ko Tween)
        hrp.CFrame = _G.Config.SavedPosition
    end
    
    task.wait(0.5)

    -- Spam Skill C (Mặc định)
    VIM:SendKeyEvent(true, Enum.KeyCode.C, false, game)
    task.wait(0.1)
    VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
    
    -- Spam Extra Keys
    if #_G.Config.ExtraKeys > 0 then
        for _, keyName in ipairs(_G.Config.ExtraKeys) do
            task.wait(_G.Config.ExtraKeyDelay)
            local keyEnum = Enum.KeyCode[keyName]
            if keyEnum then
                VIM:SendKeyEvent(true, keyEnum, false, game)
                task.wait(0.05)
                VIM:SendKeyEvent(false, keyEnum, false, game)
            end
        end
    end
    
    IsReturning = false -- Mở khóa Farm
    StatusLabel:Set("Status: Returned")
end

TabMain:CreateToggle({ Name = "🔄 Auto Return (Manual/Auto)", CurrentValue = false, Flag = "AutoReturn", Callback = function(Value) _G.Config.AutoReturn = Value end })
TabMain:CreateButton({ Name = "🚨 FORCE RETURN NOW", Callback = function() PerformAutoReturn() end })

-- === TAB: WAYPOINTS (PURE TELEPORT) ===
local TabWaypoints = Window:CreateTab("🚩 Waypoints", 4483362458)
local WaypointLabel = TabWaypoints:CreateLabel("Saved Points: 0")
local function UpdateWaypointLabel() WaypointLabel:Set("Saved Points: " .. #_G.Config.Waypoints) end

TabWaypoints:CreateButton({ Name = "➕ Add Current Position", Callback = function() if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then table.insert(_G.Config.Waypoints, LP.Character.HumanoidRootPart.CFrame); UpdateWaypointLabel() end end})
TabWaypoints:CreateButton({ Name = "🗑 Clear All Points", Callback = function() _G.Config.Waypoints = {}; UpdateWaypointLabel() end})
TabWaypoints:CreateSlider({ Name = "⏳ Delay Per Teleport", Range = {0, 60}, Increment = 0.5, Suffix = "s", CurrentValue = 2.0, Flag = "WaypointDelay", Callback = function(V) _G.Config.WaypointDelay = V end})
TabWaypoints:CreateToggle({ Name = "▶ Start Loop Teleport", CurrentValue = false, Flag = "AutoWaypoint", Callback = function(Value) _G.Config.AutoWaypoint = Value end})

-- === TAB: EXTRA KEYS ===
local TabKeys = Window:CreateTab("🎹 Extra Keys", 4483362458)
local SequenceDisplay = TabKeys:CreateLabel("Extra Keys: [ None ]")
local function UpdateDisplay() if #_G.Config.ExtraKeys == 0 then SequenceDisplay:Set("Extra Keys: [ None ]") else SequenceDisplay:Set("Extra Keys: " .. table.concat(_G.Config.ExtraKeys, " -> ")) end end

TabKeys:CreateSlider({ Name = "Delay Between Keys", Range = {0.1, 3}, Increment = 0.1, Suffix = "s", CurrentValue = 1.0, Flag = "ExtraKeyDelay", Callback = function(V) _G.Config.ExtraKeyDelay = V end})
local AvailableKeys = {"Z", "X", "V", "Q", "E", "R", "T", "Y", "U", "Space"}
TabKeys:CreateDropdown({ Name = "Select Key", Options = AvailableKeys, CurrentOption = "Z", Flag = "KeyDropdown", Callback = function(Option) _G.Config.TempKey = Option[1] end})
TabKeys:CreateButton({ Name = "➕ Add Key", Callback = function() table.insert(_G.Config.ExtraKeys, _G.Config.TempKey); UpdateDisplay() end})
TabKeys:CreateButton({ Name = "🗑 Clear Extra Keys", Callback = function() _G.Config.ExtraKeys = {}; UpdateDisplay() end})

-- === SETTINGS (RESTORED ALL OPTIONS) ===
local TabSettings = Window:CreateTab("⚙ Settings", 4483362458)
TabSettings:CreateButton({ Name = "💾 Save Custom Data", Callback = function() SaveCustomData() end})
TabSettings:CreateButton({ Name = "📂 Load Custom Data", Callback = function() LoadCustomData(); UpdateWaypointLabel(); UpdateDisplay() end})
TabSettings:CreateSlider({ Name = "TP Wait Time", Range = {0.1, 5}, Increment = 0.1, Suffix = "s", CurrentValue = 0.6, Flag = "SyncDelay", Callback = function(V) _G.Config.SyncDelay = V end})
TabSettings:CreateSlider({ Name = "Hold Extra Time (HoldDelay)", Range = {0, 4}, Increment = 0.1, Suffix = "s", CurrentValue = 0.2, Flag = "HoldDelay", Callback = function(V) _G.Config.HoldDelay = V end})

local TabFilter = Window:CreateTab("📜 Item Filter", 4483362458)
TabFilter:CreateButton({ Name = "Select All", Callback = function() _G.Config.Tracking={}; for _,v in ipairs(PRESET_LIST) do table.insert(_G.Config.Tracking,v) end; _G.ForceUpdate=true end})
TabFilter:CreateButton({ Name = "Deselect All", Callback = function() _G.Config.Tracking={}; _G.ForceUpdate=true end })
for _, item in ipairs(PRESET_LIST) do TabFilter:CreateToggle({ Name = item, CurrentValue = false, Flag = "Filter_" .. item, Callback = function(V) if V then table.insert(_G.Config.Tracking, item) else for i,v in ipairs(_G.Config.Tracking) do if v==item then table.remove(_G.Config.Tracking, i) end end end _G.ForceUpdate=true end}) end

--==============================================================
-- SMART LOGIC (TELEPORT + HOLD DELAY RESTORED)
--==============================================================

local function FindInteractableLocal(pos, range)
    -- Tìm object thật sự sau khi đã teleport tới nơi
    for _, v in ipairs(WS:GetDescendants()) do
        if v:IsA("Model") or v:IsA("BasePart") then
            local objPos = (v:IsA("Model") and v:GetPivot().Position) or v.Position
            if (objPos - pos).Magnitude < range then
                local prompt = v:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then return prompt, "Prompt", v end
                local click = v:FindFirstChildWhichIsA("ClickDetector", true)
                if click then return click, "Click", v end
            end
        end
    end
    return nil, nil, nil
end

local function ProcessItem(data)
    if IsReturning then return end -- Ngắt nếu đang Return
    
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    StatusLabel:Set("Teleporting: " .. data.Name)
    
    -- 1. TELEPORT CFrame (INSTANT - NO TWEEN)
    local targetCF = CFrame.new(data.Position) * CFrame.new(0, 4, 0)
    hrp.CFrame = targetCF
    hrp.AssemblyLinearVelocity = Vector3.zero -- Chống trượt
    
    -- 2. Đợi Sync (Quan trọng để game load object)
    task.wait(_G.Config.SyncDelay)
    hrp.Anchored = true
    
    -- 3. Tìm object và Tương tác (GIỮ NGUYÊN LOGIC CŨ)
    local instance, type, obj = FindInteractableLocal(data.Position, 20)
    
    if instance and instance.Parent then
        StatusLabel:Set("Collecting: " .. data.Name)
        local attempts = 0
        while attempts < 3 and instance.Parent and IsAlive() and _G.Config.AutoLoot and not IsReturning do
            attempts = attempts + 1
            
            if type == "Prompt" then
                -- [[ LOGIC HOLD DELAY GỐC ]]
                pcall(function() 
                    instance:InputHoldBegin()
                    -- Giữ phím theo thời gian yêu cầu của game + Thời gian delay bạn cài
                    task.wait(instance.HoldDuration + _G.Config.HoldDelay) 
                    instance:InputHoldEnd()
                end)
            elseif type == "Click" then
                fireclickdetector(instance)
                task.wait(0.5)
            end
            
            if not instance.Parent then break end -- Đã nhặt xong
            task.wait(0.1)
        end
    end
    
    hrp.Anchored = false
end

-- MAIN FARM LOOP
task.spawn(function()
    while IsAlive() do
        if _G.Config.AutoLoot and not IsReturning then
            if #LocationCache > 0 then
                for i, data in ipairs(LocationCache) do
                    if not _G.Config.AutoLoot or IsReturning then break end
                    
                    -- Check Filter Logic
                    local shouldFarm = false
                    if _G.Config.FarmAll then 
                        shouldFarm = true 
                    else
                        for _, track in ipairs(_G.Config.Tracking) do
                            if data.Name:find(track) then shouldFarm = true; break end
                        end
                    end
                    
                    if shouldFarm then
                        ProcessItem(data)
                        task.wait(0.2) -- Nghỉ nhẹ giữa các lần TP
                    end
                end
            else
                StatusLabel:Set("Cache Empty. Scan Map First!")
                task.wait(2)
            end
        else
            task.wait(1)
        end
    end
end)

-- AUTO CLEAN
task.spawn(function()
    while IsAlive() do
        task.wait(60)
        if _G.Config.AutoClean then SmartGC() end
    end
end)

-- WAYPOINTS LOOP (Pure Teleport)
task.spawn(function()
    while IsAlive() do
        if _G.Config.AutoWaypoint and #_G.Config.Waypoints > 0 and not _G.Config.AutoLoot then
            for i, cf in ipairs(_G.Config.Waypoints) do
                if not _G.Config.AutoWaypoint or not IsAlive() then break end
                local char = LP.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                    char.HumanoidRootPart.CFrame = cf -- Teleport tức thì
                    StatusLabel:Set("Waypoint: " .. i .. "/" .. #_G.Config.Waypoints)
                end
                task.wait(_G.Config.WaypointDelay)
            end
        else
            task.wait(1)
        end
    end
end)

-- =============================================================
-- TAB: VISUALS (ESP PLAYER & NPC FULL MAP)
-- =============================================================
local TabESP = Window:CreateTab("👁 Visuals (ESP)", 4483362458)

-- 1. ESP PLAYER CONFIG
local ESP_Config = { Enabled = false, Holder = nil, Conn = nil }
local function InitESP()
    if ESP_Config.Holder then ESP_Config.Holder:Destroy() end
    if ESP_Config.Conn then ESP_Config.Conn:Disconnect() end
    if not ESP_Config.Enabled then return end
    
    ESP_Config.Holder = Instance.new("Folder", CG); ESP_Config.Holder.Name = "KumaESP_Players"
    
    ESP_Config.Conn = RS.RenderStepped:Connect(function()
        if not ESP_Config.Enabled then return end
        for _, plr in ipairs(PLRS:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local head = plr.Character:FindFirstChild("Head")
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if head and hrp then
                    local bgName = "ESP_" .. plr.Name
                    local bg = ESP_Config.Holder:FindFirstChild(bgName)
                    if not bg then
                        bg = Instance.new("BillboardGui", ESP_Config.Holder)
                        bg.Name = bgName; bg.Size = UDim2.new(0, 200, 0, 50); bg.AlwaysOnTop = true 
                        bg.StudsOffset = Vector3.new(0, 3, 0); bg.MaxDistance = math.huge 
                        local lbl = Instance.new("TextLabel", bg); lbl.Size = UDim2.new(1,0,1,0); 
                        lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(0, 255, 0); 
                        lbl.TextStrokeTransparency = 0; lbl.Font = Enum.Font.GothamBlack; lbl.TextSize = 14
                    end
                    bg.Adornee = head
                    local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    local dist = myHrp and math.floor((myHrp.Position - hrp.Position).Magnitude) or 0
                    local lbl = bg:FindFirstChild("TextLabel")
                    if lbl then lbl.Text = plr.Name .. "\n[" .. dist .. "m]" end
                end
            end
        end
    end)
end

TabESP:CreateSection("Player ESP")
TabESP:CreateToggle({ Name = "Enable Player ESP", CurrentValue = false, Flag = "ESPEnabled", Callback = function(Value) ESP_Config.Enabled = Value; InitESP() end})

-- 2. NPC ESP CONFIG (FULL MAP SCAN - RED COLOR)
local NPC_ESP_Config = { Enabled = false, Holder = nil, UpdateLoop = nil, AddedConn = nil }

local function CreateNPC_Billboard(model, folder)
    if not model or not model:IsA("Model") then return end
    if PLRS:GetPlayerFromCharacter(model) then return end -- Bỏ qua Player thật
    
    local head = model:FindFirstChild("Head")
    local humanoid = model:FindFirstChild("Humanoid")
    if head and humanoid then
        -- Kiểm tra trùng lặp
        if model:FindFirstChild("Kuma_NPC_Tag") then return end
        
        -- Tạo Tag để đánh dấu đã add ESP
        local tag = Instance.new("BoolValue", model)
        tag.Name = "Kuma_NPC_Tag"

        local bg = Instance.new("BillboardGui", folder)
        bg.Name = "ESP_NPC_" .. model.Name
        bg.Adornee = head
        bg.Size = UDim2.new(0, 200, 0, 50)
        bg.StudsOffset = Vector3.new(0, 4, 0)
        bg.AlwaysOnTop = true -- QUAN TRỌNG: Nhìn xuyên tường
        
        local lbl = Instance.new("TextLabel", bg)
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(255, 50, 50) -- Màu đỏ cho NPC
        lbl.TextStrokeTransparency = 0 
        lbl.TextSize = 12
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = model.Name
    end
end

local function InitNPC_ESP()
    -- Dọn dẹp cũ
    if NPC_ESP_Config.Holder then NPC_ESP_Config.Holder:Destroy() end
    if NPC_ESP_Config.AddedConn then NPC_ESP_Config.AddedConn:Disconnect() end
    
    -- Tắt loop cũ nếu có bằng cờ kiểm soát
    _G.Kuma_NPC_Loop = false 
    task.wait(0.1)

    if not NPC_ESP_Config.Enabled then return end
    
    _G.Kuma_NPC_Loop = true
    NPC_ESP_Config.Holder = Instance.new("Folder", CG)
    NPC_ESP_Config.Holder.Name = "KumaESP_NPC_FullMap"

    -- 1. Quét toàn bộ Map ngay lập tức (Deep Scan)
    for _, obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            CreateNPC_Billboard(obj, NPC_ESP_Config.Holder)
        end
    end

    -- 2. Lắng nghe NPC mới spawn (Tự động thêm)
    NPC_ESP_Config.AddedConn = WS.DescendantAdded:Connect(function(obj)
        if NPC_ESP_Config.Enabled and obj:IsA("Model") then
            task.wait(0.5) -- Đợi load
            if obj:FindFirstChild("Humanoid") then
                CreateNPC_Billboard(obj, NPC_ESP_Config.Holder)
            end
        end
    end)

    -- 3. Loop cập nhật khoảng cách (Chạy nhẹ hơn RenderStepped)
    task.spawn(function()
        while _G.Kuma_NPC_Loop and IsAlive() do
            if NPC_ESP_Config.Holder then
                local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if myHrp then
                    for _, bg in ipairs(NPC_ESP_Config.Holder:GetChildren()) do
                        if bg:IsA("BillboardGui") and bg.Adornee then
                            local dist = (myHrp.Position - bg.Adornee.Position).Magnitude
                            local lbl = bg:FindFirstChild("TextLabel")
                            if lbl then
                                -- Lấy tên gốc từ tên BillboardGui (bỏ prefix ESP_NPC_)
                                local cleanName = bg.Name:gsub("ESP_NPC_", "")
                                lbl.Text = cleanName .. "\n[" .. math.floor(dist) .. "m]"
                            end
                        else
                            bg:Destroy() -- Xóa nếu NPC mất
                        end
                    end
                end
            end
            task.wait(0.5) -- Cập nhật 0.5s/lần để đỡ lag
        end
    end)
end

TabESP:CreateSection("NPC ESP (Full Map)")
TabESP:CreateToggle({ Name = "Enable NPC ESP", CurrentValue = false, Flag = "NPCESPEnabled", Callback = function(Value) NPC_ESP_Config.Enabled = Value; InitNPC_ESP() end})

Rayfield:LoadConfiguration()
Rayfield:Notify({Title = "KUMA V165", Content = "Full Features + NPC ESP Ready!", Duration = 5})
