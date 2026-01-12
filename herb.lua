--==============================================================
--  KUMA HUB V162 - SMART IDLE (PURE TELEPORT MODE)
--==============================================================

local ScriptID = tick()
_G.KumaInstanceID = ScriptID
local function IsAlive() return _G.KumaInstanceID == ScriptID end

-- CLEANUP
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
    "Verdant Vitality Gu", "Crimson Bloodflame Gu", "Amethyst Golden-Ring Gu", "Radiant Seraphwing Gu", "Obsidian Bloodwing Gu"
}

_G.Config = { 
    Tracking = {},       
    AutoLoot = false,    -- Nếu cái này tắt -> KHÔNG QUÉT MAP
    FarmAll = false,     
    HoldDelay = 0.2,     
    SyncDelay = 0.6,     
    ScanInterval = 5,
    AutoReturn = false,   
    SavedPosition = nil,
    KeySequence = {},    
    SequenceDelay = 1.0, 
    TempKey = "Z",
    ExtraKeys = {},    
    ExtraKeyDelay = 1.0,
    Waypoints = {},
    WaypointDelay = 2,
    AutoWaypoint = false, -- Chế độ bay thuần túy
    AutoClean = true,
    FPSBoost = false
}

local GlobalCache = {} 
local FailedList = {} 
local SecureFolder = Instance.new("Folder", CG); SecureFolder.Name = "KumaSecure_V162"

-- === SAVE SYSTEM ===
local FileName = "KumaHub_V162_Data.json"
local function SaveCustomData()
    local data = { Waypoints = {}, ExtraKeys = _G.Config.ExtraKeys }
    for _, cf in ipairs(_G.Config.Waypoints) do table.insert(data.Waypoints, {cf:GetComponents()}) end
    if writefile then writefile(FileName, HttpService:JSONEncode(data)); Rayfield:Notify({Title = "Saved", Content = "Waypoints Saved", Duration = 1}) end
end

local function LoadCustomData()
    if isfile and isfile(FileName) then
        local content = readfile(FileName); local decoded = HttpService:JSONDecode(content)
        if decoded.ExtraKeys then _G.Config.ExtraKeys = decoded.ExtraKeys end
        if decoded.Waypoints then
            _G.Config.Waypoints = {}
            for _, comp in ipairs(decoded.Waypoints) do table.insert(_G.Config.Waypoints, CFrame.new(unpack(comp))) end
        end
        Rayfield:Notify({Title = "Loaded", Content = "Waypoints Restored", Duration = 1})
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
    if not _G.Config.AutoLoot then GlobalCache = {} end -- Xóa cache nếu không farm
    SecureFolder:ClearAllChildren()
end

-- === GUI ===
local Window = Rayfield:CreateWindow({
   Name = "🦗 KUMA HUB V162 | Smart Teleport",
   LoadingTitle = "Loading V162...",
   LoadingSubtitle = "Zero Lag Mode",
   ConfigurationSaving = { Enabled = true, FolderName = "KumaHubConfig", FileName = "SettingsV162" },
   KeySystem = false,
})

-- === TAB 1: MAIN FARM ===
local TabMain = Window:CreateTab("🏠 Main Farming", 4483362458)
local StatusLabel = TabMain:CreateLabel("Status: Idle")

TabMain:CreateToggle({
   Name = "▶ START AUTO FARM",
   CurrentValue = false,
   Flag = "AutoLoot", 
   Callback = function(Value)
        _G.Config.AutoLoot = Value
        if not Value then
            StatusLabel:Set("Status: IDLE (Scanning Stopped)")
            GlobalCache = {} -- Xóa ngay lập tức để nhẹ máy
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.Anchored = false
            end
        else
            StatusLabel:Set("Status: STARTING FARM...")
        end
   end,
})

TabMain:CreateToggle({ Name = "🌍 FARM ALL (Ignore List)", CurrentValue = false, Flag = "FarmAll", Callback = function(Value) _G.Config.FarmAll = Value end })
TabMain:CreateSection("Utils")
TabMain:CreateButton({ Name = "⚡ BOOST FPS", Callback = function() BoostFPS() end })
TabMain:CreateToggle({ Name = "🧹 Auto Clean RAM", CurrentValue = true, Flag = "AutoClean", Callback = function(V) _G.Config.AutoClean = V end })
TabMain:CreateSection("Auto Return")
TabMain:CreateButton({ Name = "📍 Save Current Position", Callback = function() if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then _G.Config.SavedPosition = LP.Character.HumanoidRootPart.CFrame; Rayfield:Notify({Title="Success", Content="Position Saved"}) end end })
TabMain:CreateToggle({ Name = "🔄 Auto Return (On Farm)", CurrentValue = false, Flag = "AutoReturn", Callback = function(Value) _G.Config.AutoReturn = Value end })

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

-- === SETTINGS ===
local TabSettings = Window:CreateTab("⚙ Settings", 4483362458)
TabSettings:CreateButton({ Name = "💾 Save Custom Data", Callback = function() SaveCustomData() end})
TabSettings:CreateButton({ Name = "📂 Load Custom Data", Callback = function() LoadCustomData(); UpdateWaypointLabel(); UpdateDisplay() end})
TabSettings:CreateSlider({ Name = "TP Wait Time", Range = {0.1, 5}, Increment = 0.1, Suffix = "s", CurrentValue = 0.6, Flag = "SyncDelay", Callback = function(V) _G.Config.SyncDelay = V end})
TabSettings:CreateSlider({ Name = "Hold Extra Time", Range = {0, 4}, Increment = 0.1, Suffix = "s", CurrentValue = 3.0, Flag = "HoldDelay", Callback = function(V) _G.Config.HoldDelay = V end})

local TabFilter = Window:CreateTab("📜 Item Filter", 4483362458)
TabFilter:CreateButton({ Name = "Select All", Callback = function() _G.Config.Tracking={}; for _,v in ipairs(PRESET_LIST) do table.insert(_G.Config.Tracking,v) end; _G.ForceUpdate=true end})
TabFilter:CreateButton({ Name = "Deselect All", Callback = function() _G.Config.Tracking={}; _G.ForceUpdate=true end })
for _, item in ipairs(PRESET_LIST) do TabFilter:CreateToggle({ Name = item, CurrentValue = false, Flag = "Filter_" .. item, Callback = function(V) if V then table.insert(_G.Config.Tracking, item) else for i,v in ipairs(_G.Config.Tracking) do if v==item then table.remove(_G.Config.Tracking, i) end end end _G.ForceUpdate=true end}) end

--==============================================================
-- SMART LOGIC V162
--==============================================================

local function IsValidTarget(name)
    for _, target in ipairs(PRESET_LIST) do if name:lower():find(target:lower()) then return target end end
    return nil
end

local function FindInteractable(model)
    local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then return prompt, "Prompt" end
    local click = model:FindFirstChildWhichIsA("ClickDetector", true)
    if click then return click, "Click" end
    return nil, nil
end

local function PerformAutoReturn()
    if not _G.Config.AutoReturn or not _G.Config.SavedPosition then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    StatusLabel:Set("Status: Returning...")
    hrp.CFrame = _G.Config.SavedPosition
    task.wait(0.5)

    VIM:SendKeyEvent(true, Enum.KeyCode.C, false, game)
    task.wait(0.1)
    VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
    
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
end

function UpdateCache()
    -- [QUAN TRỌNG] Nếu không bật Auto Loot, thoát ngay lập tức!
    if not _G.Config.AutoLoot then return end

    StatusLabel:Set("Scanning (Farming Active)...")
    local tempCache = {}
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") or (v:IsA("BasePart") and v.Parent == workspace) then
                local rawName = v.Name
                local bb = v:FindFirstChildWhichIsA("BillboardGui", true)
                if bb then
                    local lbl = bb:FindFirstChildWhichIsA("TextLabel", true)
                    if lbl and lbl.Text ~= "" then rawName = lbl.Text end
                end
                
                local validName = IsValidTarget(rawName)
                if validName then 
                    local interactObj, type = FindInteractable(v)
                    if interactObj then
                        table.insert(tempCache, { Name = validName, Obj = v, Instance = interactObj, Type = type })
                    end
                end
            end
        end
    end)
    GlobalCache = tempCache
    StatusLabel:Set("Found: " .. #GlobalCache)
end

local function Interact(item)
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    StatusLabel:Set("Target: " .. item.Name)
    hrp.AssemblyLinearVelocity = Vector3.zero
    
    local targetPos = item.Obj.GetPivot and item.Obj:GetPivot().Position or item.Obj.CFrame.Position
    hrp.CFrame = CFrame.new(targetPos) * CFrame.new(0, 3, 0)
    task.wait(_G.Config.SyncDelay)
    
    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
    hrp.Anchored = true
    
    local attempts = 0
    while attempts < 3 and item.Instance.Parent and IsAlive() and _G.Config.AutoLoot do
        attempts = attempts + 1
        if item.Type == "Prompt" then
            pcall(function() item.Instance:InputHoldBegin(); task.wait(item.Instance.HoldDuration + _G.Config.HoldDelay); item.Instance:InputHoldEnd() end)
        elseif item.Type == "Click" then
            fireclickdetector(item.Instance); task.wait(0.5)
        end
        if not item.Instance.Parent then break else task.wait(0.2) end
    end
    
    hrp.Anchored = false
    if item.Instance.Parent then FailedList[item.Instance] = tick() end
    PerformAutoReturn()
end

-- MAIN LOOP (Logic thông minh)
task.spawn(function()
    while IsAlive() do
        if _G.Config.AutoLoot then
            -- Chỉ chạy đoạn này khi đang Farm
            local myPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character.HumanoidRootPart.Position
            if myPos then
                if #GlobalCache == 0 then UpdateCache() end
                
                local bestItem, minDst = nil, 999999
                for _, item in ipairs(GlobalCache) do
                    if item.Instance and item.Instance.Parent then
                        local failTime = FailedList[item.Instance]
                        if not failTime or (tick() - failTime > 30) then
                            local isSelected = table.find(_G.Config.Tracking, item.Name)
                            local isFarmAll = _G.Config.FarmAll
                            local itemPos = item.Obj.GetPivot and item.Obj:GetPivot().Position or item.Obj.Position
                            local dist = (itemPos - myPos).Magnitude
                            if isSelected or isFarmAll then
                                if dist < minDst then minDst = dist; bestItem = item end
                            end
                        end
                    end
                end
                if bestItem then Interact(bestItem) else task.wait(1); UpdateCache() end
            end
            task.wait(0.5)
        else
            -- Nếu KHÔNG farm -> Ngủ (Tiết kiệm CPU cho Teleport)
            task.wait(2) 
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

-- WAYPOINTS LOOP (Chạy độc lập)
task.spawn(function()
    while IsAlive() do
        if _G.Config.AutoWaypoint and #_G.Config.Waypoints > 0 then
            -- Nếu AutoFarm đang tắt, vòng lặp này sẽ chạy siêu mượt vì CPU rảnh rỗi
            for i, cf in ipairs(_G.Config.Waypoints) do
                if not _G.Config.AutoWaypoint or not IsAlive() then break end
                local char = LP.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                    char.HumanoidRootPart.CFrame = cf
                    StatusLabel:Set("Waypoint: " .. i .. "/" .. #_G.Config.Waypoints)
                end
                task.wait(_G.Config.WaypointDelay)
            end
        else
            task.wait(1)
        end
    end
end)

LP.CharacterAdded:Connect(function(newChar)
    if not IsAlive() then return end
    if _G.Config.AutoReturn and _G.Config.SavedPosition and _G.Config.AutoLoot then
        task.spawn(function()
            local hrp = newChar:WaitForChild("HumanoidRootPart", 20)
            if hrp then task.wait(1.5); PerformAutoReturn() end
        end)
    end
end)

-- ESP
local TabESP = Window:CreateTab("👁 ESP Player", 4483362458)
local ESP_Config = { Enabled = false, Holder = nil, Conn = nil }
local function InitESP()
    if ESP_Config.Holder then ESP_Config.Holder:Destroy() end
    if ESP_Config.Conn then ESP_Config.Conn:Disconnect() end
    if not ESP_Config.Enabled then return end
    ESP_Config.Holder = Instance.new("Folder", CG); ESP_Config.Holder.Name = "KumaESP_V162"
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
                        local lbl = Instance.new("TextLabel", bg); lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(0, 255, 0); lbl.TextStrokeTransparency = 0; lbl.Font = Enum.Font.GothamBlack; lbl.TextSize = 14
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
TabESP:CreateToggle({ Name = "Enable Infinite ESP", CurrentValue = false, Flag = "ESPEnabled", Callback = function(Value) ESP_Config.Enabled = Value; InitESP() end})

Rayfield:LoadConfiguration()
Rayfield:Notify({Title = "KUMA HUB V162", Content = "Smart Mode Loaded", Duration = 5})
