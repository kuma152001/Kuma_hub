--==============================================================
--  KUMA HUB V174 - OPTIMIZED SETTINGS + WHITE SCREEN
--  Update: Moved Optimization to Settings + Added AFK White Screen
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
    InstantFarm = false,  
    FarmAll = false,     
    HoldDelay = 0.2,     
    SyncDelay = 0.6,      
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
    WhiteScreen = false, -- New Config
    -- Craft Config
    CraftEnabled = false,
    CraftRecipe = "Lesser Qi Condensation Pill",
    CraftYear = "100000 Year",
    CraftAmount = 1,
    CraftLevel = 10
}

local LocationCache = {} 
local IsReturning = false 
local SecureFolder = Instance.new("Folder", CG); SecureFolder.Name = "KumaSecure_V174"
local CollectRemote = RE:FindFirstChild("CollectHerb", true)

-- === WHITE SCREEN GUI ===
local WhiteScreenGUI = Instance.new("ScreenGui")
WhiteScreenGUI.Name = "KumaWhiteScreen"
WhiteScreenGUI.Parent = CG
WhiteScreenGUI.Enabled = false
WhiteScreenGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local WhiteFrame = Instance.new("Frame", WhiteScreenGUI)
WhiteFrame.Size = UDim2.new(1, 0, 1, 0)
WhiteFrame.BackgroundColor3 = Color3.new(1, 1, 1) -- Màu trắng
WhiteFrame.ZIndex = 99999

local AFKText = Instance.new("TextLabel", WhiteFrame)
AFKText.Size = UDim2.new(1, 0, 1, 0)
AFKText.BackgroundTransparency = 1
AFKText.Text = "KUMA HUB - AFK MODE (SAVING GPU)"
AFKText.TextColor3 = Color3.new(0, 0, 0)
AFKText.TextSize = 24
AFKText.Font = Enum.Font.GothamBold

-- === CRAFT DATA (V20 Logic) ===
local YearToGrade = {
    ["100000 Year"] = 6, ["10000 Year"] = 5, ["1000 Year"] = 4, 
    ["100 Year"] = 3, ["10 Year"] = 2, ["1 Year"] = 1
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
local FileName = "KumaHub_V174_Data.json"
local function SaveCustomData()
    local data = { 
        Waypoints = {}, ExtraKeys = _G.Config.ExtraKeys, SavedPos = nil,
        CraftConfig = { Year = _G.Config.CraftYear, Recipe = _G.Config.CraftRecipe, Level = _G.Config.CraftLevel }
    }
    if _G.Config.SavedPosition then data.SavedPos = {_G.Config.SavedPosition:GetComponents()} end
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
        if decoded.SavedPos then _G.Config.SavedPosition = CFrame.new(unpack(decoded.SavedPos)) end
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
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    LGT.GlobalShadows = false
    LGT.FogEnd = 9e9
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Texture") or v:IsA("Decal") then v.Texture = "" end
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
    end
    Rayfield:Notify({Title = "Boost FPS", Content = "Max FPS Optimized", Duration = 2})
end

local function SmartGC() SecureFolder:ClearAllChildren() end

-- === GUI CREATION ===
local Window = Rayfield:CreateWindow({
   Name = "🦗 KUMA HUB V174 | OPTIMIZED",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "With White Screen & Anti-Lag",
   ConfigurationSaving = { Enabled = true, FolderName = "KumaHubConfig", FileName = "SettingsV174" },
   KeySystem = false,
})

-- =============================================================
-- TAB 1: FARM 
-- =============================================================
local TabFarm = Window:CreateTab("🌿 Farm", 4483362458)
local StatusLabel = TabFarm:CreateLabel("Status: Idle")

-- === SCANNER ENGINE (CODE 2) ===
task.spawn(function()
    while IsAlive() do
        -- Chỉ cập nhật cache nếu danh sách đang RỖNG hoặc gần rỗng
        if #LocationCache < 2 then 
            local plantFolder = WS:FindFirstChild("Plants")
            local scanTarget = plantFolder and plantFolder:GetChildren() or WS:GetDescendants()
            
            local tempCache = {}
            local count = 0
            
            for _, v in ipairs(scanTarget) do
                if v:IsA("Model") or v:IsA("BasePart") then
                    local rawName = v.Name
                    local bb = v:FindFirstChildWhichIsA("BillboardGui", true)
                    if bb then
                        local lbl = bb:FindFirstChildWhichIsA("TextLabel", true)
                        if lbl and lbl.Text ~= "" then rawName = lbl.Text end
                    end

                    local isTarget = false
                    if _G.Config.FarmAll then
                        isTarget = true
                    else
                        for _, track in ipairs(_G.Config.Tracking) do
                            if rawName:find(track) then isTarget = true; break end
                        end
                        if #_G.Config.Tracking == 0 then
                             for _, preset in ipairs(PRESET_LIST) do
                                 if rawName:find(preset) then isTarget = true; break end
                             end
                        end
                    end

                    if isTarget and v.Parent then
                        local pos = (v:IsA("Model") and v:GetPivot().Position) or v.Position
                        table.insert(tempCache, {Name = rawName, Position = pos, Instance = v})
                        count = count + 1
                    end
                end
            end
            
            if count > 0 then
                LocationCache = tempCache
            end
            
            if _G.Config.AutoLoot or _G.Config.InstantFarm then
                StatusLabel:Set("Scanner: Found " .. count .. " items")
            end
        end
        task.wait(1.5) 
    end
end)

TabFarm:CreateSection("Farm Controls")
TabFarm:CreateToggle({
   Name = "⚡ INSTANT REMOTE FARM (Safe Logic)",
   CurrentValue = false,
   Flag = "InstantFarm", 
   Callback = function(Value)
        _G.Config.InstantFarm = Value
        if Value then 
            _G.Config.AutoLoot = false 
            if not CollectRemote then Rayfield:Notify({Title="Error", Content="Remote not found! Fallback to Legit."}) end
        end
   end,
})

TabFarm:CreateToggle({
   Name = "▶ LEGIT FARM (Hold E)",
   CurrentValue = false,
   Flag = "AutoLoot", 
   Callback = function(Value)
        _G.Config.AutoLoot = Value
        if Value then _G.Config.InstantFarm = false end
   end,
})

TabFarm:CreateToggle({ Name = "🌍 FARM ALL (Ignore List)", CurrentValue = false, Flag = "FarmAll", Callback = function(Value) _G.Config.FarmAll = Value end })

TabFarm:CreateSection("Filter Configuration")
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
    if not _G.Config.SavedPosition then Rayfield:Notify({Title = "Error", Content = "No Saved Position!", Duration = 2}); return end
    IsReturning = true; StatusLabel:Set("Status: Returning...")
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart; hrp.Anchored = false; hrp.AssemblyLinearVelocity = Vector3.zero; hrp.CFrame = _G.Config.SavedPosition
    end
    task.wait(0.5) 
    if useKeys and #_G.Config.ExtraKeys > 0 then
        StatusLabel:Set("Casting Skills..."); for _, k in ipairs(_G.Config.ExtraKeys) do task.wait(_G.Config.ExtraKeyDelay); PressKey(k) end
    end
    IsReturning = false; StatusLabel:Set("Status: Returned")
end
LP.CharacterAdded:Connect(function(newChar)
    if not IsAlive() then return end
    if _G.Config.AutoReturnDeath and _G.Config.SavedPosition then
        local hrp = newChar:WaitForChild("HumanoidRootPart", 10); local hum = newChar:WaitForChild("Humanoid", 10)
        if hrp and hum then
            StatusLabel:Set("Respawned! Returning..."); task.wait(1.5); hrp.CFrame = _G.Config.SavedPosition; hrp.AssemblyLinearVelocity = Vector3.zero
            if #_G.Config.ExtraKeys > 0 then task.wait(0.8); for _, k in ipairs(_G.Config.ExtraKeys) do if hum.Health > 0 then PressKey(k); task.wait(_G.Config.ExtraKeyDelay) end end end
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
-- TAB 3: MISC (Moved Items to Settings)
-- =============================================================
local TabMisc = Window:CreateTab("🧩 Misc", 4483362458)
local ESP_Config = { Enabled = false, Holder = nil, Conn = nil }
local NPC_ESP_Config = { Enabled = false, Holder = nil, AddedConn = nil }
_G.Kuma_NPC_Loop = false 
local function InitESP()
    if ESP_Config.Holder then ESP_Config.Holder:Destroy() end; if ESP_Config.Conn then ESP_Config.Conn:Disconnect() end; if not ESP_Config.Enabled then return end
    ESP_Config.Holder = Instance.new("Folder", CG); ESP_Config.Holder.Name = "KumaESP_Players"
    ESP_Config.Conn = RS.RenderStepped:Connect(function()
        if not ESP_Config.Enabled then return end
        for _, plr in ipairs(PLRS:GetPlayers()) do
            if plr ~= LP and plr.Character and plr.Character:FindFirstChild("Head") then
                local bg = ESP_Config.Holder:FindFirstChild("ESP_"..plr.Name)
                if not bg then
                    bg = Instance.new("BillboardGui", ESP_Config.Holder); bg.Name = "ESP_"..plr.Name; bg.Size = UDim2.new(0, 200, 0, 50); bg.AlwaysOnTop = true; bg.Adornee = plr.Character.Head; bg.StudsOffset = Vector3.new(0, 3, 0)
                    local lbl = Instance.new("TextLabel", bg); lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(0, 255, 0); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 14
                end
                local myPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); local dist = myPos and (myPos.Position - plr.Character.Head.Position).Magnitude or 0
                bg.TextLabel.Text = plr.Name .. "\n[" .. math.floor(dist) .. "m]"
            end
        end
    end)
end
local function CreateNPC_Billboard(m, f)
    if not m or not m:IsA("Model") or PLRS:GetPlayerFromCharacter(m) or not m:FindFirstChild("Head") or not m:FindFirstChild("Humanoid") or m:FindFirstChild("Kuma_NPC_Tag") then return end
    Instance.new("BoolValue", m).Name = "Kuma_NPC_Tag"; local bg = Instance.new("BillboardGui", f); bg.Name = "ESP_NPC_"..m.Name; bg.Size = UDim2.new(0, 200, 0, 50); bg.AlwaysOnTop = true; bg.Adornee = m.Head; bg.StudsOffset = Vector3.new(0, 4, 0)
    local lbl = Instance.new("TextLabel", bg); lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(255, 50, 50); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12; lbl.Text = m.Name
end
local function InitNPC_ESP()
    if NPC_ESP_Config.Holder then NPC_ESP_Config.Holder:Destroy() end; if NPC_ESP_Config.AddedConn then NPC_ESP_Config.AddedConn:Disconnect() end; _G.Kuma_NPC_Loop = false; task.wait(0.1); if not NPC_ESP_Config.Enabled then return end; _G.Kuma_NPC_Loop = true
    NPC_ESP_Config.Holder = Instance.new("Folder", CG); NPC_ESP_Config.Holder.Name = "KumaESP_NPC"
    for _, obj in ipairs(WS:GetDescendants()) do CreateNPC_Billboard(obj, NPC_ESP_Config.Holder) end
    NPC_ESP_Config.AddedConn = WS.DescendantAdded:Connect(function(obj) task.wait(0.5); CreateNPC_Billboard(obj, NPC_ESP_Config.Holder) end)
    task.spawn(function()
        while _G.Kuma_NPC_Loop and IsAlive() do if NPC_ESP_Config.Holder then local myPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); for _, bg in ipairs(NPC_ESP_Config.Holder:GetChildren()) do if bg.Adornee then local dist = myPos and (myPos.Position - bg.Adornee.Position).Magnitude or 0; bg.TextLabel.Text = bg.Name:gsub("ESP_NPC_","") .. "\n[" .. math.floor(dist) .. "m]" else bg:Destroy() end end end; task.wait(0.5) end
    end)
end
TabMisc:CreateSection("ESP Visuals")
TabMisc:CreateToggle({ Name = "Enable Player ESP", CurrentValue = false, Flag = "ESPEnabled", Callback = function(V) ESP_Config.Enabled = V; InitESP() end})
TabMisc:CreateToggle({ Name = "Enable NPC ESP (Full Map)", CurrentValue = false, Flag = "NPCESPEnabled", Callback = function(V) NPC_ESP_Config.Enabled = V; InitNPC_ESP() end})
TabMisc:CreateSection("Extra Keys (Run AFTER Death Return)")
local SequenceDisplay = TabMisc:CreateLabel("Current Keys: [ None ]")
local function UpdateDisplay() if #_G.Config.ExtraKeys == 0 then SequenceDisplay:Set("Current Keys: [ None ]") else SequenceDisplay:Set("Keys: " .. table.concat(_G.Config.ExtraKeys, " -> ")) end end
TabMisc:CreateDropdown({ Name = "Select Key To Add", Options = {"Z", "X", "V", "C", "Q", "E", "R", "T", "Y", "U", "Space", "G", "H", "B"}, CurrentOption = "Z", Flag = "KeyDropdown", Callback = function(O) _G.Config.TempKey = O[1] end})
TabMisc:CreateButton({ Name = "➕ Add Selected Key", Callback = function() table.insert(_G.Config.ExtraKeys, _G.Config.TempKey); UpdateDisplay() end})
TabMisc:CreateButton({ Name = "🗑 Clear All Keys", Callback = function() _G.Config.ExtraKeys = {}; UpdateDisplay() end})

-- =============================================================
-- TAB 4: SETTINGS (MOVED ITEMS + WHITE SCREEN)
-- =============================================================
local TabSettings = Window:CreateTab("⚙ Settings", 4483362458)

TabSettings:CreateSection("Optimization & AFK (Moved Here)")
TabSettings:CreateButton({ Name = "⚡ BOOST FPS", Callback = function() BoostFPS() end })
TabSettings:CreateToggle({ Name = "🧹 Auto Clean RAM", CurrentValue = true, Flag = "AutoClean", Callback = function(V) _G.Config.AutoClean = V end })
TabSettings:CreateToggle({ 
    Name = "📺 White Screen (AFK/Low CPU)", 
    CurrentValue = false, 
    Flag = "WhiteScreen", 
    Callback = function(Value) 
        _G.Config.WhiteScreen = Value 
        -- Logic: Bật GUI Trắng + Tắt Render 3D
        WhiteScreenGUI.Enabled = Value
        RS:Set3dRenderingEnabled(not Value)
    end 
})

TabSettings:CreateSection("Data Management")
TabSettings:CreateButton({ Name = "💾 Save Settings & Position", Callback = function() SaveCustomData() end})
TabSettings:CreateButton({ Name = "📂 Load Settings & Position", Callback = function() LoadCustomData(); UpdateWaypointLabel(); UpdateDisplay() end})
TabSettings:CreateSection("Delays & Speed")
TabSettings:CreateSlider({ Name = "Sync/Remote Delay (Safe=0.6)", Range = {0.1, 5}, Increment = 0.1, Suffix = "s", CurrentValue = 0.6, Flag = "SyncDelay", Callback = function(V) _G.Config.SyncDelay = V end})
TabSettings:CreateSlider({ Name = "Hold Interaction Time", Range = {0, 4}, Increment = 0.1, Suffix = "s", CurrentValue = 0.2, Flag = "HoldDelay", Callback = function(V) _G.Config.HoldDelay = V end})
TabSettings:CreateSlider({ Name = "Extra Key Delay", Range = {0.1, 3}, Increment = 0.1, Suffix = "s", CurrentValue = 1.0, Flag = "ExtraKeyDelay", Callback = function(V) _G.Config.ExtraKeyDelay = V end})
TabSettings:CreateSlider({ Name = "Waypoint Loop Delay", Range = {0, 60}, Increment = 0.5, Suffix = "s", CurrentValue = 2.0, Flag = "WaypointDelay", Callback = function(V) _G.Config.WaypointDelay = V end})

-- =============================================================
-- TAB 5: CRAFT (FIXED V20)
-- =============================================================
local TabCraft = Window:CreateTab("⚗ Craft", 4483362458)
local CraftStatus = TabCraft:CreateLabel("Status: Idle")
local RecipeNames = {}; for _, v in ipairs(CraftRecipes) do table.insert(RecipeNames, v.Name) end
local YearKeys = {"100000 Year", "10000 Year", "1000 Year", "100 Year", "10 Year", "1 Year"}
TabCraft:CreateSection("Crafting Configuration")
TabCraft:CreateDropdown({ Name = "Select Recipe", Options = RecipeNames, CurrentOption = RecipeNames[1], Flag = "CraftRecipe", Callback = function(Option) _G.Config.CraftRecipe = Option[1] end})
TabCraft:CreateDropdown({ Name = "Select Year (Auto Grade)", Options = YearKeys, CurrentOption = "100000 Year", Flag = "CraftYear", Callback = function(Option) _G.Config.CraftYear = Option[1] end})
TabCraft:CreateInput({ Name = "Cauldron Level", PlaceholderText = "10", RemoveTextAfterFocusLost = false, Callback = function(Text) _G.Config.CraftLevel = tonumber(Text) or 10 end})
TabCraft:CreateInput({ Name = "Amount To Craft", PlaceholderText = "1", RemoveTextAfterFocusLost = false, Callback = function(Text) _G.Config.CraftAmount = tonumber(Text) or 1 end})
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
                local loops = _G.Config.CraftAmount or 1; local count = 0
                while _G.Config.CraftEnabled and count < loops and IsAlive() do
                    count = count + 1; local targetGrade = YearToGrade[_G.Config.CraftYear] or 1
                    CraftStatus:Set("Crafting: " .. count .. "/" .. loops .. " (GR" .. targetGrade .. ")")
                    pcall(function() if Remote_Reset then Remote_Reset:FireServer() end end); task.wait(0.8)
                    if not _G.Config.CraftEnabled then break end
                    local recipeData = nil; for _, r in ipairs(CraftRecipes) do if r.Name == _G.Config.CraftRecipe then recipeData = r; break end end
                    if recipeData then
                        local loaded = 0
                        for slot, herbName in ipairs(recipeData.Items) do
                            if not _G.Config.CraftEnabled then break end
                            Remote_Add:FireServer(herbName, _G.Config.CraftYear, slot); loaded = loaded + 1; task.wait(0.4)
                        end
                        task.wait(0.5)
                        if _G.Config.CraftEnabled and loaded == 4 then
                            Remote_Craft:FireServer(_G.Config.CraftRecipe, targetGrade, _G.Config.CraftLevel, 1); CraftStatus:Set("Sent Craft Request...")
                        end
                    else Rayfield:Notify({Title="Error", Content="Recipe not found!"}); _G.Config.CraftEnabled = false; break end
                    for i=1, 30 do if not _G.Config.CraftEnabled then break end task.wait(0.1) end
                end
                _G.Config.CraftEnabled = false; CraftStatus:Set("Status: Finished / Stopped"); Rayfield:Notify({Title="Craft", Content="Job Complete"})
            end)
        else CraftStatus:Set("Status: Idle") end
    end
})

-- =============================================================
-- LOGIC (PROCESS ITEM + FORCE REMOVE CACHE)
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
    
    if _G.Config.InstantFarm then
        -- === INSTANT MODE ===
        if data.Instance and data.Instance.Parent then
            hrp.CFrame = CFrame.new(data.Position)
            hrp.AssemblyLinearVelocity = Vector3.zero
            
            task.wait(_G.Config.SyncDelay) 
            
            if data.Instance.Parent and (hrp.Position - data.Position).Magnitude <= 20 then
                StatusLabel:Set("Instant Collect: " .. data.Name)
                if CollectRemote then
                    CollectRemote:FireServer(data.Instance)
                    local s = tick()
                    repeat task.wait(0.1) until (not data.Instance.Parent) or (tick()-s > 3)
                end
            end
        end
    else
        -- === LEGIT MODE ===
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
                    pcall(function() instance:InputHoldBegin(); task.wait(instance.HoldDuration + _G.Config.HoldDelay); instance:InputHoldEnd() end)
                elseif type == "Click" then
                    fireclickdetector(instance); task.wait(0.5)
                end
                if not instance.Parent then break end
                task.wait(0.1)
            end
        end
        hrp.Anchored = false
    end
end

-- MAIN FARM LOOP
task.spawn(function()
    while IsAlive() do
        if (_G.Config.AutoLoot or _G.Config.InstantFarm) and not IsReturning then
            if #LocationCache > 0 then
                local myPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character.HumanoidRootPart.Position
                local bestTarget = nil
                local bestIndex = -1
                local minDst = 9999999
                
                for i, data in ipairs(LocationCache) do
                    if data.Instance and data.Instance.Parent then
                        local dst = myPos and (data.Position - myPos).Magnitude or 99999
                        if dst < minDst then
                            minDst = dst
                            bestTarget = data
                            bestIndex = i
                        end
                    end
                end

                if bestTarget and bestIndex ~= -1 then
                    ProcessItem(bestTarget)
                    -- FIX STUCK: XÓA NGAY KHỎI CACHE
                    if bestIndex <= #LocationCache then
                        table.remove(LocationCache, bestIndex)
                    end
                else
                    StatusLabel:Set("Finding new items...")
                    table.remove(LocationCache, 1)
                    task.wait(0.2)
                end
            else
                StatusLabel:Set("Waiting for scanner...")
                task.wait(1)
            end
        else
            task.wait(1)
        end
    end
end)

task.spawn(function()
    while IsAlive() do
        if _G.Config.AutoWaypoint and #_G.Config.Waypoints > 0 and not _G.Config.AutoLoot and not _G.Config.InstantFarm then
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
Rayfield:Notify({Title = "KUMA HUB V174", Content = "Optimization & White Screen Added", Duration = 5})
