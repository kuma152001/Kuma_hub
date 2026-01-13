--==============================================================
--  KUMA HUB V168 - INTEGRATED CRAFT V20
--  Features: Farm + Tele + Misc + Settings + AUTO CRAFT (Fixed)
--==============================================================

local ScriptID = tick()
_G.KumaInstanceID = ScriptID
local function IsAlive() return _G.KumaInstanceID == ScriptID end

-- CLEANUP OLD GUI
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
local RE = game:GetService("ReplicatedStorage")

-- === CONFIG DEFAULT ===
local PRESET_LIST = {
    "Ginseng", "Spirit Rose", "Qi Flower", "Qi Berries", "Moon Flower", "Death Flower", "Star Grass", "Soul Root"
}

_G.Config = { 
    Tracking = {},       
    AutoLoot = false,    
    FarmAll = false,     
    HoldDelay = 0.2,     
    SyncDelay = 0.6,     
    ScanInterval = 1000, 
    AutoReturnDeath = false, 
    SavedPosition = nil,
    TempKey = "Z",
    ExtraKeys = {},    
    ExtraKeyDelay = 1.0,
    Waypoints = {},
    WaypointDelay = 2,
    AutoWaypoint = false, 
    AutoClean = true,
    FPSBoost = false,
    -- Craft Config
    CraftEnabled = false,
    CraftRecipe = "Lesser Qi Condensation Pill",
    CraftYear = "100000 Year",
    CraftAmount = 1,
    CraftLevel = 10
}

local LocationCache = {} 
local IsReturning = false 
local SecureFolder = Instance.new("Folder", CG); SecureFolder.Name = "KumaSecure_V168"

-- === CRAFT DATA (V20 Logic) ===
local YearToGrade = {
    ["100000 Year"] = 6, -- GR6
    ["10000 Year"]  = 5, -- GR5
    ["1000 Year"]   = 4, -- GR4
    ["100 Year"]    = 3, -- GR3
    ["10 Year"]     = 2, -- GR2
    ["1 Year"]      = 1  -- GR1
}

local CraftRecipes = {
    {Name = "Lesser Qi Condensation Pill", Items = {"Qi Berries", "Qi Berries", "Spirit Rose", "Qi Flower"}},
    {Name = "Refined Qi Flow Pill",        Items = {"Ginseng", "Ginseng", "Spirit Rose", "Qi Flower"}},
    {Name = "Body Tempering Pill",         Items = {"Qi Berries", "Ginseng", "Qi Flower", "Moon Flower"}},
    {Name = "Blood Moon Fury Pill",        Items = {"Qi Berries", "Spirit Rose", "Moon Flower", "Death Flower"}},
    {Name = "Serene Fortune Pill",         Items = {"Spirit Rose", "Spirit Rose", "Death Flower", "Death Flower"}},
    {Name = "Harvester's Insight Pill",    Items = {"Qi Berries", "Ginseng", "Spirit Rose", "Qi Flower"}},
    {Name = "Spirit Shield Pill",          Items = {"Ginseng", "Ginseng", "Spirit Rose", "Moon Flower"}},
    {Name = "Moonlit Destruction Pill",    Items = {"Spirit Rose", "Qi Flower", "Moon Flower", "Death Flower"}}
}

-- === HELPER FUNCTIONS ===
local function PressKey(keyName)
    local key = Enum.KeyCode[keyName]
    if key then
        VIM:SendKeyEvent(true, key, false, game)
        task.wait(0.05) 
        VIM:SendKeyEvent(false, key, false, game)
    end
end

-- === SAVE/LOAD SYSTEM ===
local FileName = "KumaHub_V168_Data.json"
local function SaveCustomData()
    local data = { 
        Waypoints = {}, 
        ExtraKeys = _G.Config.ExtraKeys, 
        SavedPos = nil,
        CraftConfig = {
            Year = _G.Config.CraftYear,
            Recipe = _G.Config.CraftRecipe,
            Level = _G.Config.CraftLevel
        }
    }
    if _G.Config.SavedPosition then
        data.SavedPos = {_G.Config.SavedPosition:GetComponents()}
    end
    for _, cf in ipairs(_G.Config.Waypoints) do table.insert(data.Waypoints, {cf:GetComponents()}) end
    if writefile then writefile(FileName, HttpService:JSONEncode(data)); Rayfield:Notify({Title = "Saved", Content = "Data Saved", Duration = 1}) end
end

local function LoadCustomData()
    if isfile and isfile(FileName) then
        local content = readfile(FileName); local decoded = HttpService:JSONDecode(content)
        if decoded.ExtraKeys then _G.Config.ExtraKeys = decoded.ExtraKeys end
        if decoded.Waypoints then
            _G.Config.Waypoints = {}
            for _, comp in ipairs(decoded.Waypoints) do table.insert(_G.Config.Waypoints, CFrame.new(unpack(comp))) end
        end
        if decoded.SavedPos then
            _G.Config.SavedPosition = CFrame.new(unpack(decoded.SavedPos))
        end
        if decoded.CraftConfig then
            _G.Config.CraftYear = decoded.CraftConfig.Year or "100000 Year"
            _G.Config.CraftRecipe = decoded.CraftConfig.Recipe or "Lesser Qi Condensation Pill"
            _G.Config.CraftLevel = decoded.CraftConfig.Level or 10
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
    Rayfield:Notify({Title = "Boost FPS", Content = "Graphics Reduced", Duration = 2})
end

local function SmartGC()
    SecureFolder:ClearAllChildren()
end

-- === GUI CREATION ===
local Window = Rayfield:CreateWindow({
   Name = "🦗 KUMA HUB V168 | CRAFT FIXED",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "With Auto Craft V20",
   ConfigurationSaving = { Enabled = true, FolderName = "KumaHubConfig", FileName = "SettingsV168" },
   KeySystem = false,
})

-- =============================================================
-- TAB 1: FARM 
-- =============================================================
local TabFarm = Window:CreateTab("🌿 Farm", 4483362458)
local StatusLabel = TabFarm:CreateLabel("Status: Idle")

local function ScanMapToCache()
    if IsReturning then return end
    StatusLabel:Set("Status: Scanning Map...")
    Rayfield:Notify({Title = "System", Content = "Scanning Map...", Duration = 1})
    table.clear(LocationCache)
    local count = 0
    local processed = 0
    
    for _, v in ipairs(WS:GetDescendants()) do
        processed = processed + 1
        if processed % _G.Config.ScanInterval == 0 then task.wait() end
        if v:IsA("Model") or v:IsA("BasePart") then
            local rawName = v.Name
            local bb = v:FindFirstChildWhichIsA("BillboardGui", true)
            if bb then
                local lbl = bb:FindFirstChildWhichIsA("TextLabel", true)
                if lbl and lbl.Text ~= "" then rawName = lbl.Text end
            end
            local isTarget = false
            for _, preset in ipairs(PRESET_LIST) do
                if rawName:find(preset) then isTarget = true; break end
            end
            if isTarget then
                local pos = (v:IsA("Model") and v:GetPivot().Position) or v.Position
                table.insert(LocationCache, {Name = rawName, Position = pos})
                count = count + 1
            end
        end
    end
    StatusLabel:Set("Found: " .. count .. " items")
    Rayfield:Notify({Title = "Scan Done", Content = "Saved " .. count .. " locations.", Duration = 2})
end

TabFarm:CreateSection("Main Controls")
TabFarm:CreateButton({ Name = "📡 SCAN MAP (Click First)", Callback = function() ScanMapToCache() end })
TabFarm:CreateToggle({
   Name = "▶ START AUTO FARM",
   CurrentValue = false,
   Flag = "AutoLoot", 
   Callback = function(Value)
        _G.Config.AutoLoot = Value
        if Value and #LocationCache == 0 then Rayfield:Notify({Title = "Warning", Content = "Click 'SCAN MAP' first!", Duration = 3}) end
        if not Value then StatusLabel:Set("Status: Idle") end
   end,
})
TabFarm:CreateToggle({ Name = "🌍 FARM ALL (Ignore List)", CurrentValue = false, Flag = "FarmAll", Callback = function(Value) _G.Config.FarmAll = Value end })

TabFarm:CreateSection("Item Filter List")
TabFarm:CreateButton({ Name = "Select All", Callback = function() _G.Config.Tracking={}; for _,v in ipairs(PRESET_LIST) do table.insert(_G.Config.Tracking,v) end; Rayfield:Notify({Title="Filter", Content="Selected All"}) end})
TabFarm:CreateButton({ Name = "Deselect All", Callback = function() _G.Config.Tracking={}; Rayfield:Notify({Title="Filter", Content="Cleared"}) end })
for _, item in ipairs(PRESET_LIST) do 
    TabFarm:CreateToggle({ Name = item, CurrentValue = false, Flag = "Filter_" .. item, Callback = function(V) 
        if V then table.insert(_G.Config.Tracking, item) 
        else for i,v in ipairs(_G.Config.Tracking) do if v==item then table.remove(_G.Config.Tracking, i) end end end 
    end}) 
end

-- =============================================================
-- TAB 2: TELE 
-- =============================================================
local TabTele = Window:CreateTab("🚀 Tele", 4483362458)

local function PerformAutoReturn(useKeys)
    if not _G.Config.SavedPosition then 
        Rayfield:Notify({Title = "Error", Content = "No Saved Position!", Duration = 2})
        return 
    end
    IsReturning = true 
    StatusLabel:Set("Status: Returning...")
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        hrp.Anchored = false
        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        hrp.CFrame = _G.Config.SavedPosition
    end
    task.wait(0.5) 
    if useKeys and #_G.Config.ExtraKeys > 0 then
        StatusLabel:Set("Casting Skills...")
        for _, keyName in ipairs(_G.Config.ExtraKeys) do
            task.wait(_G.Config.ExtraKeyDelay)
            PressKey(keyName)
        end
    end
    IsReturning = false 
    StatusLabel:Set("Status: Returned")
end

LP.CharacterAdded:Connect(function(newChar)
    if not IsAlive() then return end
    if _G.Config.AutoReturnDeath and _G.Config.SavedPosition then
        local hrp = newChar:WaitForChild("HumanoidRootPart", 10)
        local hum = newChar:WaitForChild("Humanoid", 10)
        if hrp and hum then
            StatusLabel:Set("Respawned! Returning...")
            task.wait(1.5)
            hrp.CFrame = _G.Config.SavedPosition
            hrp.AssemblyLinearVelocity = Vector3.zero
            if #_G.Config.ExtraKeys > 0 then
                task.wait(0.8)
                Rayfield:Notify({Title = "Auto Return", Content = "Using Extra Keys...", Duration = 2})
                for _, keyName in ipairs(_G.Config.ExtraKeys) do
                    if hum.Health > 0 then
                        PressKey(keyName)
                        task.wait(_G.Config.ExtraKeyDelay)
                    end
                end
            end
            StatusLabel:Set("Auto Return Complete")
        end
    end
end)

TabTele:CreateSection("Auto Return System")
TabTele:CreateButton({ Name = "📍 Save Current Position (Return Point)", Callback = function() if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then _G.Config.SavedPosition = LP.Character.HumanoidRootPart.CFrame; Rayfield:Notify({Title="Success", Content="Position Saved"}) end end })
TabTele:CreateButton({ Name = "🚨 FORCE RETURN (No Skill)", Callback = function() PerformAutoReturn(false) end })
TabTele:CreateToggle({ Name = "💀 Auto Return On Death (+ Use Keys)", CurrentValue = false, Flag = "AutoReturnDeath", Callback = function(Value) _G.Config.AutoReturnDeath = Value end })

TabTele:CreateSection("Waypoints Loop")
local WaypointLabel = TabTele:CreateLabel("Saved Points: 0")
local function UpdateWaypointLabel() WaypointLabel:Set("Saved Points: " .. #_G.Config.Waypoints) end
TabTele:CreateButton({ Name = "➕ Add Current Position", Callback = function() if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then table.insert(_G.Config.Waypoints, LP.Character.HumanoidRootPart.CFrame); UpdateWaypointLabel() end end})
TabTele:CreateButton({ Name = "🗑 Clear All Points", Callback = function() _G.Config.Waypoints = {}; UpdateWaypointLabel() end})
TabTele:CreateToggle({ Name = "▶ Start Loop Teleport", CurrentValue = false, Flag = "AutoWaypoint", Callback = function(Value) _G.Config.AutoWaypoint = Value end})

-- =============================================================
-- TAB 3: MISC 
-- =============================================================
local TabMisc = Window:CreateTab("🧩 Misc", 4483362458)
local ESP_Config = { Enabled = false, Holder = nil, Conn = nil }
local NPC_ESP_Config = { Enabled = false, Holder = nil, AddedConn = nil }
_G.Kuma_NPC_Loop = false 

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
                if head then
                    local bg = ESP_Config.Holder:FindFirstChild("ESP_"..plr.Name)
                    if not bg then
                        bg = Instance.new("BillboardGui", ESP_Config.Holder); bg.Name = "ESP_"..plr.Name
                        bg.Size = UDim2.new(0, 200, 0, 50); bg.AlwaysOnTop = true; bg.Adornee = head
                        bg.StudsOffset = Vector3.new(0, 3, 0)
                        local lbl = Instance.new("TextLabel", bg); lbl.Size = UDim2.new(1,0,1,0)
                        lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(0, 255, 0); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 14
                    end
                    local myPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    local dist = myPos and (myPos.Position - head.Position).Magnitude or 0
                    bg.TextLabel.Text = plr.Name .. "\n[" .. math.floor(dist) .. "m]"
                end
            end
        end
    end)
end

local function CreateNPC_Billboard(model, folder)
    if not model or not model:IsA("Model") then return end
    if PLRS:GetPlayerFromCharacter(model) then return end
    local head = model:FindFirstChild("Head")
    if head and model:FindFirstChild("Humanoid") then
        if model:FindFirstChild("Kuma_NPC_Tag") then return end
        local tag = Instance.new("BoolValue", model); tag.Name = "Kuma_NPC_Tag"
        local bg = Instance.new("BillboardGui", folder); bg.Name = "ESP_NPC_"..model.Name
        bg.Size = UDim2.new(0, 200, 0, 50); bg.AlwaysOnTop = true; bg.Adornee = head; bg.StudsOffset = Vector3.new(0, 4, 0)
        local lbl = Instance.new("TextLabel", bg); lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1; 
        lbl.TextColor3 = Color3.fromRGB(255, 50, 50); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12; lbl.Text = model.Name
    end
end

local function InitNPC_ESP()
    if NPC_ESP_Config.Holder then NPC_ESP_Config.Holder:Destroy() end
    if NPC_ESP_Config.AddedConn then NPC_ESP_Config.AddedConn:Disconnect() end
    _G.Kuma_NPC_Loop = false; task.wait(0.1)
    if not NPC_ESP_Config.Enabled then return end
    _G.Kuma_NPC_Loop = true
    NPC_ESP_Config.Holder = Instance.new("Folder", CG); NPC_ESP_Config.Holder.Name = "KumaESP_NPC"
    for _, obj in ipairs(WS:GetDescendants()) do 
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then CreateNPC_Billboard(obj, NPC_ESP_Config.Holder) end 
    end
    NPC_ESP_Config.AddedConn = WS.DescendantAdded:Connect(function(obj) 
        task.wait(0.5); if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then CreateNPC_Billboard(obj, NPC_ESP_Config.Holder) end 
    end)
    task.spawn(function()
        while _G.Kuma_NPC_Loop and IsAlive() do
            if NPC_ESP_Config.Holder then
                local myPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                for _, bg in ipairs(NPC_ESP_Config.Holder:GetChildren()) do
                    if bg.Adornee then
                        local dist = myPos and (myPos.Position - bg.Adornee.Position).Magnitude or 0
                        bg.TextLabel.Text = bg.Name:gsub("ESP_NPC_","") .. "\n[" .. math.floor(dist) .. "m]"
                    else bg:Destroy() end
                end
            end
            task.wait(0.5)
        end
    end)
end

TabMisc:CreateSection("ESP Visuals")
TabMisc:CreateToggle({ Name = "Enable Player ESP", CurrentValue = false, Flag = "ESPEnabled", Callback = function(V) ESP_Config.Enabled = V; InitESP() end})
TabMisc:CreateToggle({ Name = "Enable NPC ESP (Full Map)", CurrentValue = false, Flag = "NPCESPEnabled", Callback = function(V) NPC_ESP_Config.Enabled = V; InitNPC_ESP() end})

TabMisc:CreateSection("Extra Keys (Run AFTER Death Return)")
local SequenceDisplay = TabMisc:CreateLabel("Current Keys: [ None ]")
local function UpdateDisplay() if #_G.Config.ExtraKeys == 0 then SequenceDisplay:Set("Current Keys: [ None ]") else SequenceDisplay:Set("Keys: " .. table.concat(_G.Config.ExtraKeys, " -> ")) end end
local AvailableKeys = {"Z", "X", "V", "C", "Q", "E", "R", "T", "Y", "U", "Space", "G", "H", "B"}
TabMisc:CreateDropdown({ Name = "Select Key To Add", Options = AvailableKeys, CurrentOption = "Z", Flag = "KeyDropdown", Callback = function(Option) _G.Config.TempKey = Option[1] end})
TabMisc:CreateButton({ Name = "➕ Add Selected Key", Callback = function() table.insert(_G.Config.ExtraKeys, _G.Config.TempKey); UpdateDisplay() end})
TabMisc:CreateButton({ Name = "🗑 Clear All Keys", Callback = function() _G.Config.ExtraKeys = {}; UpdateDisplay() end})
TabMisc:CreateToggle({ Name = "🧹 Auto Clean RAM", CurrentValue = true, Flag = "AutoClean", Callback = function(V) _G.Config.AutoClean = V end })
TabMisc:CreateButton({ Name = "⚡ BOOST FPS", Callback = function() BoostFPS() end })

-- =============================================================
-- TAB 4: SETTINGS 
-- =============================================================
local TabSettings = Window:CreateTab("⚙ Settings", 4483362458)
TabSettings:CreateSection("Data Management")
TabSettings:CreateButton({ Name = "💾 Save Settings & Position", Callback = function() SaveCustomData() end})
TabSettings:CreateButton({ Name = "📂 Load Settings & Position", Callback = function() LoadCustomData(); UpdateWaypointLabel(); UpdateDisplay() end})
TabSettings:CreateSection("Delays & Speed")
TabSettings:CreateSlider({ Name = "TP Wait Time", Range = {0.1, 5}, Increment = 0.1, Suffix = "s", CurrentValue = 0.6, Flag = "SyncDelay", Callback = function(V) _G.Config.SyncDelay = V end})
TabSettings:CreateSlider({ Name = "Hold Interaction Time", Range = {0, 4}, Increment = 0.1, Suffix = "s", CurrentValue = 0.2, Flag = "HoldDelay", Callback = function(V) _G.Config.HoldDelay = V end})
TabSettings:CreateSlider({ Name = "Extra Key Delay", Range = {0.1, 3}, Increment = 0.1, Suffix = "s", CurrentValue = 1.0, Flag = "ExtraKeyDelay", Callback = function(V) _G.Config.ExtraKeyDelay = V end})
TabSettings:CreateSlider({ Name = "Waypoint Loop Delay", Range = {0, 60}, Increment = 0.5, Suffix = "s", CurrentValue = 2.0, Flag = "WaypointDelay", Callback = function(V) _G.Config.WaypointDelay = V end})

-- =============================================================
-- TAB 5: CRAFT (NEW FEATURE - FIXED V3 Logic)
-- =============================================================
local TabCraft = Window:CreateTab("⚗ Craft", 4483362458)
local CraftStatus = TabCraft:CreateLabel("Status: Idle")

-- Craft UI Helpers
local RecipeNames = {}
for _, v in ipairs(CraftRecipes) do table.insert(RecipeNames, v.Name) end
local YearKeys = {"100000 Year", "10000 Year", "1000 Year", "100 Year", "10 Year", "1 Year"}

TabCraft:CreateSection("Crafting Configuration")

TabCraft:CreateDropdown({
    Name = "Select Recipe",
    Options = RecipeNames,
    CurrentOption = RecipeNames[1],
    Flag = "CraftRecipe",
    Callback = function(Option)
        _G.Config.CraftRecipe = Option[1]
    end
})

TabCraft:CreateDropdown({
    Name = "Select Year (Auto Grade)",
    Options = YearKeys,
    CurrentOption = "100000 Year",
    Flag = "CraftYear",
    Callback = function(Option)
        _G.Config.CraftYear = Option[1]
    end
})

TabCraft:CreateInput({
    Name = "Cauldron Level",
    PlaceholderText = "10",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        _G.Config.CraftLevel = tonumber(Text) or 10
    end
})

TabCraft:CreateInput({
    Name = "Amount To Craft",
    PlaceholderText = "1",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        _G.Config.CraftAmount = tonumber(Text) or 1
    end
})

-- AUTO CRAFT LOGIC (Based on V20 Fixed Grade)
TabCraft:CreateToggle({
    Name = "▶ START AUTO CRAFT",
    CurrentValue = false,
    Flag = "AutoCraft",
    Callback = function(Value)
        _G.Config.CraftEnabled = Value
        
        if Value then
            task.spawn(function()
                local Remote_Add = RE:WaitForChild("Events"):WaitForChild("UseHerbAlchemy")
                local Remote_Craft = RE:WaitForChild("Events"):WaitForChild("CraftPill")
                local Remote_Reset = RE:FindFirstChild("ReturnHerbalAlchemy", true)
                
                local loops = _G.Config.CraftAmount or 1
                local count = 0
                
                while _G.Config.CraftEnabled and count < loops and IsAlive() do
                    count = count + 1
                    -- Calculate Grade
                    local targetGrade = YearToGrade[_G.Config.CraftYear] or 1
                    CraftStatus:Set("Crafting: " .. count .. "/" .. loops .. " (GR" .. targetGrade .. ")")
                    
                    -- 1. Reset
                    pcall(function() if Remote_Reset then Remote_Reset:FireServer() end end)
                    task.wait(0.8)
                    if not _G.Config.CraftEnabled then break end
                    
                    -- 2. Add Herbs (Find correct ingredients from Recipe)
                    local recipeData = nil
                    for _, r in ipairs(CraftRecipes) do 
                        if r.Name == _G.Config.CraftRecipe then recipeData = r; break end 
                    end
                    
                    if recipeData then
                        local loaded = 0
                        -- recipeData.Items has {Item1, Item2, Item3, Item4} -> Slot 1, 2, 3, 4
                        for slot, herbName in ipairs(recipeData.Items) do
                            if not _G.Config.CraftEnabled then break end
                            -- Note: The game uses the STRING year for Adding Herbs
                            Remote_Add:FireServer(herbName, _G.Config.CraftYear, slot)
                            loaded = loaded + 1
                            task.wait(0.4)
                        end
                        
                        task.wait(0.5)
                        
                        -- 3. Craft (Use Grade Number)
                        if _G.Config.CraftEnabled and loaded == 4 then
                            -- CraftPill(Name, Grade, Level, 1) -> Based on Spy Log
                            local args = {
                                _G.Config.CraftRecipe,
                                targetGrade,
                                _G.Config.CraftLevel,
                                1
                            }
                            Remote_Craft:FireServer(unpack(args))
                            CraftStatus:Set("Sent Craft Request...")
                        end
                    else
                        Rayfield:Notify({Title="Error", Content="Recipe not found!"})
                        _G.Config.CraftEnabled = false
                        break
                    end
                    
                    -- 4. Wait for Cooldown
                    for i=1, 30 do if not _G.Config.CraftEnabled then break end task.wait(0.1) end
                end
                
                _G.Config.CraftEnabled = false
                CraftStatus:Set("Status: Finished / Stopped")
                -- Turn off toggle visually if possible (Rayfield doesn't always support set state easily externally)
                Rayfield:Notify({Title="Craft", Content="Job Complete"})
            end)
        else
            CraftStatus:Set("Status: Idle")
        end
    end
})

-- =============================================================
-- LOGIC
-- =============================================================
local function FindInteractableLocal(pos, range)
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
    if IsReturning then return end
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    StatusLabel:Set("Teleporting: " .. data.Name)
    local targetCF = CFrame.new(data.Position) * CFrame.new(0, 4, 0)
    hrp.CFrame = targetCF
    hrp.AssemblyLinearVelocity = Vector3.zero
    
    task.wait(_G.Config.SyncDelay)
    hrp.Anchored = true
    
    local instance, type, obj = FindInteractableLocal(data.Position, 20)
    if instance and instance.Parent then
        StatusLabel:Set("Collecting: " .. data.Name)
        local attempts = 0
        while attempts < 3 and instance.Parent and IsAlive() and _G.Config.AutoLoot and not IsReturning do
            attempts = attempts + 1
            if type == "Prompt" then
                pcall(function() 
                    instance:InputHoldBegin()
                    task.wait(instance.HoldDuration + _G.Config.HoldDelay) 
                    instance:InputHoldEnd()
                end)
            elseif type == "Click" then
                fireclickdetector(instance)
                task.wait(0.5)
            end
            if not instance.Parent then break end
            task.wait(0.1)
        end
    end
    hrp.Anchored = false
end

-- MAIN LOOPS
task.spawn(function()
    while IsAlive() do
        if _G.Config.AutoLoot and not IsReturning then
            if #LocationCache > 0 then
                for i, data in ipairs(LocationCache) do
                    if not _G.Config.AutoLoot or IsReturning then break end
                    local shouldFarm = false
                    if _G.Config.FarmAll then shouldFarm = true 
                    else
                        for _, track in ipairs(_G.Config.Tracking) do
                            if data.Name:find(track) then shouldFarm = true; break end
                        end
                    end
                    if shouldFarm then
                        ProcessItem(data)
                        task.wait(0.2)
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

task.spawn(function()
    while IsAlive() do
        if _G.Config.AutoWaypoint and #_G.Config.Waypoints > 0 and not _G.Config.AutoLoot then
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

task.spawn(function() while IsAlive() do task.wait(60); if _G.Config.AutoClean then SmartGC() end end end)

Rayfield:LoadConfiguration()
Rayfield:Notify({Title = "KUMA HUB", Content = "Script Loaded (Craft Added)", Duration = 5})
