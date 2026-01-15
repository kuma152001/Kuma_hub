task.spawn(function()
    repeat task.wait() until game:IsLoaded()

    --==============================================================
    --  🐻 KUMA HUB V206 MOBILE (FIXED UI TOGGLE)
    --==============================================================

    local ScriptID = tick()
    _G.KumaInstanceID = ScriptID
    local function IsAlive() return _G.KumaInstanceID == ScriptID end

    -- === 1. DỌN DẸP GUI CŨ & SÀN CŨ ===
    pcall(function()
        for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
            if v.Name:find("Kuma") or v.Name:find("Secure") or v.Name:find("ESP") or v.Name == "KumaMobileButton" then 
                v:Destroy() 
            end
        end
        local oldPlat = workspace:FindFirstChild("Kuma_Platform")
        if oldPlat then oldPlat:Destroy() end
    end)

    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local HttpService = game:GetService("HttpService")

    -- === 2. KHAI BÁO DỊCH VỤ ===
    local LP = game:GetService("Players").LocalPlayer
    local CG = game:GetService("CoreGui")
    local VIM = game:GetService("VirtualInputManager")
    local WS = game:GetService("Workspace")
    local RS = game:GetService("RunService")
    local PLRS = game:GetService("Players")
    local LGT = game:GetService("Lighting")
    local RE = game:GetService("ReplicatedStorage")
    local VU = game:GetService("VirtualUser")
    local UIS = game:GetService("UserInputService") -- Thêm UIS cho Mobile

    -- === 3. CẤU HÌNH MẶC ĐỊNH ===
    local Default_Config = { 
        Tracking = {
            ["Ginseng"] = false, 
            ["Spirit Rose"] = false, 
            ["Qi Flower"] = false, 
            ["Qi Berries"] = false, 
            ["Moon Flower"] = false, 
            ["Death Flower"] = false
        },
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
        WhiteScreen = false,
        AntiAFK = true,
        DestroyMap = false,
        CraftEnabled = false,
        CraftRecipe = "Lesser Qi Condensation Pill",
        CraftYear = "100000 Year",
        CraftAmount = 1,
        CraftLevel = 10
    }

    _G.Config = HttpService:JSONDecode(HttpService:JSONEncode(Default_Config))

    local LocationCache = {} 
    local IsReturning = false 
    local SecureFolder = Instance.new("Folder", CG)
    SecureFolder.Name = "KumaSecure_V206"
    local CollectRemote = RE:FindFirstChild("CollectHerb", true)

    -- === 4. HỆ THỐNG QUẢN LÝ HỒ SƠ ===
    local ConfigFolder = "KumaHub_Profiles"
    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
    
    local SelectedProfile = ""
    local InputProfileName = ""

    local function GetMyProfiles()
        local files = listfiles(ConfigFolder)
        local myProfiles = {}
        local prefix = LP.UserId .. "_" 
        for _, file in ipairs(files) do
            local fileName = file:match("([^/]+)$") 
            if fileName:find("^" .. prefix) then
                local cleanName = fileName:sub(#prefix + 1):gsub("%.json$", "")
                table.insert(myProfiles, cleanName)
            end
        end
        return myProfiles
    end

    local function SaveUserProfile(name)
        if name == "" then 
            Rayfield:Notify({Title="Error", Content="Vui lòng nhập tên hồ sơ!"}) 
            return 
        end
        local data = HttpService:JSONDecode(HttpService:JSONEncode(_G.Config))
        data.Waypoints = {}
        for _, cf in ipairs(_G.Config.Waypoints) do
            table.insert(data.Waypoints, {cf:GetComponents()})
        end
        if _G.Config.SavedPosition then
            data.SavedPosition = {_G.Config.SavedPosition:GetComponents()}
        end
        local fileName = ConfigFolder .. "/" .. LP.UserId .. "_" .. name .. ".json"
        writefile(fileName, HttpService:JSONEncode(data))
        Rayfield:Notify({Title="Saved", Content="Đã lưu hồ sơ: " .. name})
    end

    local function LoadUserProfile(name)
        local fileName = ConfigFolder .. "/" .. LP.UserId .. "_" .. name .. ".json"
        if not isfile(fileName) then 
            Rayfield:Notify({Title="Error", Content="Không tìm thấy file!"}) 
            return 
        end
        local content = readfile(fileName)
        local decoded = HttpService:JSONDecode(content)
        for k, v in pairs(decoded) do
            if k ~= "Waypoints" and k ~= "SavedPosition" then
                _G.Config[k] = v
            end
        end
        _G.Config.Waypoints = {}
        if decoded.Waypoints then
            for _, comps in ipairs(decoded.Waypoints) do
                table.insert(_G.Config.Waypoints, CFrame.new(unpack(comps)))
            end
        end
        if decoded.SavedPosition then
            _G.Config.SavedPosition = CFrame.new(unpack(decoded.SavedPosition))
        end
        Rayfield:Notify({Title="Loaded", Content="Đã tải hồ sơ: " .. name})
    end

    local function DeleteUserProfile(name)
        local fileName = ConfigFolder .. "/" .. LP.UserId .. "_" .. name .. ".json"
        if isfile(fileName) then
            delfile(fileName)
            Rayfield:Notify({Title="Deleted", Content="Đã xóa: " .. name})
        end
    end

    -- === 5. CÁC HÀM CHỨC NĂNG ===
    local function EnsurePlatform()
        local p = workspace:FindFirstChild("Kuma_Platform")
        if not p then
            p = Instance.new("Part")
            p.Name = "Kuma_Platform"
            p.Size = Vector3.new(30, 1, 30)
            p.Anchored = true
            p.CanCollide = true
            p.Material = Enum.Material.Neon
            p.Color = Color3.fromRGB(0, 255, 100)
            p.Transparency = 0.5
            p.Parent = workspace
        end
        return p
    end

    local function NukeMap()
        if not _G.Config.DestroyMap then return end
        for _, v in ipairs(WS:GetChildren()) do
            if v.Name ~= "Players" and v.Name ~= "Plants" and v.Name ~= "Camera" and v.Name ~= "Terrain" and v.Name ~= "Kuma_Platform" then
                if v:IsA("Model") or v:IsA("Folder") or v:IsA("Part") or v:IsA("MeshPart") then
                    if v ~= LP.Character then 
                        v:Destroy() 
                    end
                end
            end
        end
        WS.Terrain:Clear()
    end

    local function GetCleanName(obj)
        local name = obj.Name
        local bb = obj:FindFirstChildWhichIsA("BillboardGui", true)
        if bb then
            local lbl = bb:FindFirstChildWhichIsA("TextLabel", true)
            if lbl and lbl.Text ~= "" then name = lbl.Text end
        end
        name = name:gsub("%[.-%]", ""):gsub("%d+ Year", ""):gsub("%d+Y", "")
        return name:match("^%s*(.-)%s*$")
    end

    local function PressKey(keyName)
        local key = Enum.KeyCode[keyName]
        if key then
            VIM:SendKeyEvent(true, key, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, key, false, game)
        end
    end

    local function BoostFPS()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        LGT.GlobalShadows = false
        LGT.FogEnd = 9e9
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("Texture") or v:IsA("Decal") or v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v:Destroy()
            end
        end
        Rayfield:Notify({Title = "FPS Boost", Content = "Đã xóa Texture & Effect!"})
    end

    LP.Idled:Connect(function()
        if _G.Config.AntiAFK then
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end
    end)

    -- === 6. TẠO GIAO DIỆN (UI) ===
    local Window = Rayfield:CreateWindow({
       Name = "🐻 KUMA HUB 🐻",
       LoadingTitle = "Mobile Optimized",
       LoadingSubtitle = "V206: Mobile Fix",
       ConfigurationSaving = { Enabled = false }, 
       KeySystem = false,
    })

    -- =============================================================
    -- TẠO NÚT BẬT TẮT CHO MOBILE (FIX MỚI)
    -- =============================================================
    task.spawn(function()
        -- Tạo ScreenGui riêng cho nút
        local MobileScreen = Instance.new("ScreenGui")
        MobileScreen.Name = "KumaMobileButton"
        MobileScreen.Parent = game:GetService("CoreGui")
        MobileScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        -- Tạo nút tròn
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Parent = MobileScreen
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Position = UDim2.new(0.85, 0, 0.2, 0) -- Vị trí mặc định bên phải
        ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
        ToggleBtn.Font = Enum.Font.FredokaOne
        ToggleBtn.Text = "🐻"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleBtn.TextSize = 25.000
        ToggleBtn.AutoButtonColor = true

        -- Bo tròn nút
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(1, 0)
        UICorner.Parent = ToggleBtn

        -- Viền nút
        local UIStroke = Instance.new("UIStroke")
        UIStroke.Parent = ToggleBtn
        UIStroke.Color = Color3.fromRGB(255, 170, 0) -- Màu cam
        UIStroke.Thickness = 2
        
        -- Chức năng kéo thả (Draggable) cho nút
        local dragging, dragInput, dragStart, startPos
        local function update(input)
            local delta = input.Position - dragStart
            ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        ToggleBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = ToggleBtn.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        ToggleBtn.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if input == dragInput and dragging then update(input) end
        end)

        -- Chức năng Bật/Tắt Rayfield khi bấm nút
        ToggleBtn.MouseButton1Click:Connect(function()
            local RayfieldUI = game:GetService("CoreGui"):FindFirstChild("Rayfield")
            if RayfieldUI then
                RayfieldUI.Enabled = not RayfieldUI.Enabled
            end
        end)
    end)
    -- =============================================================

    -- =============================================================
    -- TAB 1: FARM 
    -- =============================================================
    local TabFarm = Window:CreateTab("🌿 Farm", 4483362458)
    local StatusLabel = TabFarm:CreateLabel("Status: Idle")

    task.spawn(function()
        while IsAlive() do
            if _G.Config.AutoWaypoint then
                table.clear(LocationCache)
                task.wait(2) 
            elseif (_G.Config.AutoLoot or _G.Config.InstantFarm) then 
                if #LocationCache == 0 then
                    local plantFolder = WS:FindFirstChild("Plants")
                    local scanTarget = (plantFolder and plantFolder:GetChildren()) or WS:GetChildren() 
                    local tempCache = {}
                    local hasSelection = false
                    
                    for _, val in pairs(_G.Config.Tracking) do 
                        if val == true then hasSelection = true break end 
                    end

                    if hasSelection or _G.Config.FarmAll then
                        StatusLabel:Set("Status: Scanning...")
                        for _, v in ipairs(scanTarget) do
                            if (v:IsA("Model") or v:IsA("BasePart")) and v.Parent then
                                local cleanName = GetCleanName(v)
                                local isMatch = false
                                if _G.Config.FarmAll then 
                                    isMatch = true
                                else
                                    for herbName, enabled in pairs(_G.Config.Tracking) do
                                        if enabled and cleanName:find(herbName) then 
                                            isMatch = true
                                            break 
                                        end
                                    end
                                end
                                
                                if isMatch then
                                    if v:FindFirstChildWhichIsA("ProximityPrompt", true) or v:FindFirstChildWhichIsA("ClickDetector", true) or _G.Config.InstantFarm then
                                        local pos = (v:IsA("Model") and v:GetPivot().Position) or v.Position
                                        table.insert(tempCache, {Name = cleanName, Position = pos, Instance = v})
                                    end
                                end
                            end
                        end
                        
                        if #tempCache > 0 and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                            local myPos = LP.Character.HumanoidRootPart.Position
                            table.sort(tempCache, function(a, b) return (a.Position - myPos).Magnitude < (b.Position - myPos).Magnitude end)
                        end
                        LocationCache = tempCache
                        StatusLabel:Set("Scanner: Found " .. #LocationCache .. " plants")
                    else
                        LocationCache = {}
                        StatusLabel:Set("Status: Please select a plant!")
                    end
                end
                task.wait(1)
            else
                table.clear(LocationCache)
                task.wait(1)
            end
        end
    end)

    TabFarm:CreateSection("Farm Controls")
    TabFarm:CreateToggle({
        Name = "⚡ INSTANT REMOTE FARM",
        CurrentValue = false,
        Callback = function(V) _G.Config.InstantFarm = V; if V then _G.Config.AutoLoot = false end end
    })
    TabFarm:CreateToggle({
        Name = "▶ LEGIT FARM (Hold E)",
        CurrentValue = false,
        Callback = function(V) _G.Config.AutoLoot = V; if V then _G.Config.InstantFarm = false end end
    })
    TabFarm:CreateToggle({
        Name = "🌍 FARM ALL (Ignore Filter)",
        CurrentValue = false,
        Callback = function(V) _G.Config.FarmAll = V end
    })

    TabFarm:CreateSection("🌿 Filter Configuration")
    local PRESET_LIST = {"Ginseng", "Spirit Rose", "Qi Flower", "Qi Berries", "Moon Flower", "Death Flower"}
    for _, item in ipairs(PRESET_LIST) do 
        TabFarm:CreateToggle({
            Name = item,
            CurrentValue = false,
            Callback = function(V) _G.Config.Tracking[item] = V end
        }) 
    end

    -- =============================================================
    -- TAB 2: TELE 
    -- =============================================================
    local TabTele = Window:CreateTab("🚀 Tele", 4483362458)
    
    TabTele:CreateSection("Auto Return System")
    TabTele:CreateButton({ 
        Name = "📍 Save Current Position (Return Point)", 
        Callback = function() 
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then 
                _G.Config.SavedPosition = LP.Character.HumanoidRootPart.CFrame
                Rayfield:Notify({Title="Success", Content="Đã lưu điểm hồi sinh!"}) 
            end 
        end 
    })
    
    TabTele:CreateButton({ 
        Name = "🚨 FORCE RETURN", 
        Callback = function() 
            if _G.Config.SavedPosition and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then 
                LP.Character.HumanoidRootPart.CFrame = _G.Config.SavedPosition 
            end 
        end 
    })
    
    TabTele:CreateToggle({ 
        Name = "💀 Auto Return On Death (+ Keys)", 
        CurrentValue = false, 
        Callback = function(V) _G.Config.AutoReturnDeath = V end 
    })

    LP.CharacterAdded:Connect(function(newChar)
        if _G.Config.AutoReturnDeath and _G.Config.SavedPosition then
            local hrp = newChar:WaitForChild("HumanoidRootPart", 10)
            local hum = newChar:WaitForChild("Humanoid", 10)
            if hrp and hum then
                task.wait(1.5)
                hrp.CFrame = _G.Config.SavedPosition
                if #_G.Config.ExtraKeys > 0 then
                    task.wait(0.8)
                    for _, k in ipairs(_G.Config.ExtraKeys) do
                        if hum.Health > 0 then
                            PressKey(k)
                            task.wait(_G.Config.ExtraKeyDelay)
                        end
                    end
                end
            end
        end
    end)

    TabTele:CreateSection("Waypoints Loop")
    local WaypointLabel = TabTele:CreateLabel("Saved Points: 0")
    
    TabTele:CreateButton({ 
        Name = "➕ Add Position", 
        Callback = function() 
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then 
                table.insert(_G.Config.Waypoints, LP.Character.HumanoidRootPart.CFrame)
                WaypointLabel:Set("Saved: " .. #_G.Config.Waypoints) 
            end 
        end
    })
    
    TabTele:CreateButton({ 
        Name = "🗑 Clear All Points", 
        Callback = function() 
            _G.Config.Waypoints = {}
            WaypointLabel:Set("Saved: 0") 
        end
    })
    
    TabTele:CreateToggle({ 
        Name = "▶ Start Loop Teleport", 
        CurrentValue = false, 
        Callback = function(V) _G.Config.AutoWaypoint = V end
    })

    -- =============================================================
    -- TAB 3: MISC 
    -- =============================================================
    local TabMisc = Window:CreateTab("🧩 Misc", 4483362458)
    
    TabMisc:CreateSection("ESP Visuals (Fixed)")
    
    local ESP_NPC_Enabled = false
    local ESP_Player_Enabled = false
    local FolderNPCName = "Kuma_ESP_NPC"
    local FolderPlayerName = "Kuma_ESP_Player"
    local ESP_Cache = {}

    local function CreateESP_V7(model, holder, color, isPlayer)
        if not model or ESP_Cache[model] then return end
        pcall(function()
            if model == LP.Character then return end
            
            local hum = model:FindFirstChild("Humanoid")
            if not isPlayer then
                if not hum then return end 
                if PLRS:GetPlayerFromCharacter(model) then return end
            end
            
            local root = model:FindFirstChild("UpperTorso") or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("Head") or model:FindFirstChild("Đầu") or model.PrimaryPart
            
            if root then
                ESP_Cache[model] = true
                local hl = Instance.new("Highlight")
                hl.Adornee = model
                hl.FillColor = color
                hl.OutlineColor = Color3.new(1,1,1)
                hl.FillTransparency = 0.5
                hl.Parent = holder
                
                local bg = Instance.new("BillboardGui", hl)
                bg.Adornee = root
                bg.Size = UDim2.new(0,150,0,40)
                bg.StudsOffset = Vector3.new(0,3.5,0)
                bg.AlwaysOnTop = true
                
                local t = Instance.new("TextLabel", bg)
                t.BackgroundTransparency = 1
                t.Size = UDim2.new(1,0,1,0)
                local hp = hum and math.floor(hum.Health) or "?"
                t.Text = model.Name .. "\n[" .. hp .. "]"
                t.TextColor3 = color 
                t.TextStrokeTransparency = 0
                t.Font = Enum.Font.SourceSansBold
                t.TextSize = 12
                
                model.AncestryChanged:Connect(function(_, parent)
                    if not parent then hl:Destroy() ESP_Cache[model] = nil end
                end)
            end
        end)
    end

    local function StartSmartScan(targetType, folderName, color)
        local Holder = CG:FindFirstChild(folderName) or Instance.new("Folder", CG)
        Holder.Name = folderName
        task.spawn(function()
            while IsAlive() do
                if (targetType == "NPC" and not ESP_NPC_Enabled) or (targetType == "PLAYER" and not ESP_Player_Enabled) then Holder:ClearAllChildren() ESP_Cache = {} break end
                for i, obj in ipairs(WS:GetDescendants()) do
                    if i % 300 == 0 then task.wait() end 
                    if obj:IsA("Model") then
                        if targetType == "NPC" then CreateESP_V7(obj, Holder, color, false)
                        elseif targetType == "PLAYER" and PLRS:GetPlayerFromCharacter(obj) then CreateESP_V7(obj, Holder, color, true) end
                    end
                end
                task.wait(3)
            end
        end)
    end

    TabMisc:CreateToggle({Name = "🔥 ESP NPCs (Red)", CurrentValue = false, Callback = function(V) ESP_NPC_Enabled = V if V then StartSmartScan("NPC", FolderNPCName, Color3.fromRGB(255, 50, 50)) end end})
    TabMisc:CreateToggle({Name = "👤 ESP Players (Green)", CurrentValue = false, Callback = function(V) ESP_Player_Enabled = V if V then StartSmartScan("PLAYER", FolderPlayerName, Color3.fromRGB(0, 255, 100)) end end})

    TabMisc:CreateSection("🎲 Reroll System (Skip Anim)")
    
    TabMisc:CreateButton({
        Name = "🌀 Roll RACE (Skip)",
        Callback = function()
            local events = RE:FindFirstChild("Events")
            if events and events:FindFirstChild("RollRace") then
                events.RollRace:FireServer(1, true)
                Rayfield:Notify({Title="Success", Content="Sent Roll Race (Skip)!"})
            else
                Rayfield:Notify({Title="Error", Content="Remote Not Found!"})
            end
        end
    })

    TabMisc:CreateButton({
        Name = "🌀 Roll SPIRIT (Skip)",
        Callback = function()
            local events = RE:FindFirstChild("Events")
            if events and events:FindFirstChild("RollSpiritRoot") then
                events.RollSpiritRoot:FireServer(1, true)
                Rayfield:Notify({Title="Success", Content="Sent Roll Spirit (Skip)!"})
            else
                Rayfield:Notify({Title="Error", Content="Remote Not Found!"})
            end
        end
    })

    TabMisc:CreateSection("Extra Keys Sequence (For Auto Return)")
    TabMisc:CreateLabel("Note: Keys will be pressed after respawn")

    local SequenceDisplay = TabMisc:CreateLabel("Current Keys: [ None ]")
    local function UpdateKeys() 
        if #_G.Config.ExtraKeys == 0 then 
            SequenceDisplay:Set("Keys: [ None ]") 
        else 
            SequenceDisplay:Set("Keys: " .. table.concat(_G.Config.ExtraKeys, " -> ")) 
        end 
    end
    
    TabMisc:CreateDropdown({ 
        Name = "Select Key", 
        Options = {"C", "G", "V", "B", "H", "E", "R", "Z", "Space"}, 
        CurrentOption = "Z", 
        Callback = function(O) _G.Config.TempKey = O[1] end
    })
    
    TabMisc:CreateButton({ 
        Name = "➕ Add Key", 
        Callback = function() 
            table.insert(_G.Config.ExtraKeys, _G.Config.TempKey)
            UpdateKeys() 
        end
    })
    
    TabMisc:CreateButton({ 
        Name = "🗑 Clear All Keys", 
        Callback = function() 
            _G.Config.ExtraKeys = {}
            UpdateKeys() 
        end
    })
    
    -- =============================================================
    -- TAB 4: CONFIG 
    -- =============================================================
    local TabSettings = Window:CreateTab("⚙ Config", 4483362458)

    TabSettings:CreateSection("Delays & Speeds")
    TabSettings:CreateSlider({ 
        Name = "Farm Teleport Delay", 
        Range = {0.1, 5}, 
        Increment = 0.1, 
        CurrentValue = 0.6, 
        Callback = function(V) _G.Config.SyncDelay = V end
    })
    TabSettings:CreateSlider({ 
        Name = "Waypoint Loop Delay", 
        Range = {0, 60}, 
        Increment = 0.5, 
        CurrentValue = 2.0, 
        Callback = function(V) _G.Config.WaypointDelay = V end
    })
    TabSettings:CreateSlider({ 
        Name = "Hold Interaction Time", 
        Range = {0, 4}, 
        Increment = 0.1, 
        CurrentValue = 0.2, 
        Callback = function(V) _G.Config.HoldDelay = V end
    })

    TabSettings:CreateSection("💾 Profile Manager (Manual Save)")
    TabSettings:CreateInput({ 
        Name = "Profile Name", 
        PlaceholderText = "Ex: FarmGinseng", 
        RemoveTextAfterFocusLost = false, 
        Callback = function(Text) InputProfileName = Text end
    })
    
    TabSettings:CreateButton({ 
        Name = "💾 SAVE / CREATE PROFILE", 
        Callback = function() SaveUserProfile(InputProfileName) end
    })
    
    local ProfileDropdown = TabSettings:CreateDropdown({ 
        Name = "Select Profile", 
        Options = GetMyProfiles(), 
        CurrentOption = "", 
        Callback = function(Option) SelectedProfile = Option[1] end
    })
    
    TabSettings:CreateButton({ 
        Name = "📂 LOAD PROFILE", 
        Callback = function() 
            LoadUserProfile(SelectedProfile)
            UpdateKeys()
            WaypointLabel:Set("Saved: " .. #_G.Config.Waypoints) 
        end
    })
    
    TabSettings:CreateButton({ 
        Name = "🗑 DELETE PROFILE", 
        Callback = function() 
            DeleteUserProfile(SelectedProfile)
            ProfileDropdown:Refresh(GetMyProfiles(), true) 
        end
    })
    
    TabSettings:CreateButton({ 
        Name = "🔄 REFRESH LIST", 
        Callback = function() ProfileDropdown:Refresh(GetMyProfiles(), true) end
    })

    TabSettings:CreateSection("System")
    TabSettings:CreateToggle({ 
        Name = "💤 Anti-AFK", 
        CurrentValue = true, 
        Callback = function(V) _G.Config.AntiAFK = V end
    })

    TabSettings:CreateButton({ Name = "⚡ BOOST FPS", Callback = BoostFPS })
    
    TabSettings:CreateToggle({ 
        Name = "🔥 DESTROY MAP + PLATFORM", 
        CurrentValue = false, 
        Callback = function(V) 
            _G.Config.DestroyMap = V
            if V then NukeMap() end 
        end
    })
    
    TabSettings:CreateToggle({ 
        Name = "📺 White Screen (Disable 3D)", 
        CurrentValue = false, 
        Callback = function(V) RS:Set3dRenderingEnabled(not V) end
    })

    -- =============================================================
    -- TAB 5: CRAFT 
    -- =============================================================
    local TabCraft = Window:CreateTab("⚗ Craft", 4483362458)
    local CraftRecipes = {
        {Name = "Lesser Qi Condensation Pill", Items = {"Qi Berries", "Qi Berries", "Spirit Rose", "Qi Flower"}},
        {Name = "Refined Qi Flow Pill",        Items = {"Ginseng", "Ginseng", "Spirit Rose", "Qi Flower"}},
        {Name = "Body Tempering Pill",         Items = {"Qi Berries", "Ginseng", "Qi Flower", "Moon Flower"}},
        {Name = "Blood Moon Fury Pill",        Items = {"Qi Berries", "Spirit Rose", "Moon Flower", "Death Flower"}},
        {Name = "Serene Fortune Pill",         Items = {"Spirit Rose", "Spirit Rose", "Death Flower", "Death Flower"}},
        {Name = "Harvester's Insight Pill",    Items = {"Qi Berries", "Ginseng", "Spirit Rose", "Qi Flower"}},
        {Name = "Spirit Shield Pill",          Items = {"Ginseng", "Ginseng", "Spirit Rose", "Moon Flower"}},
        {Name = "Moonlit Destruction Pill",    Items = {"Spirit Rose", "Qi Flower", "Moon Flower", "Death Flower"}},
        {Name = "Heaven-Defying Rebirth Pill",    Items = {"Ginseng", "Death Flower", "Death Flower", "Death Flower"}}
    }
    local RecipeNames = {}
    for _, v in ipairs(CraftRecipes) do table.insert(RecipeNames, v.Name) end
    local YearToGrade = { ["100000 Year"] = 6, ["10000 Year"] = 5, ["1000 Year"] = 4, ["100 Year"] = 3, ["1000 Year"] = 2, ["1 Year"] = 1 }

    TabCraft:CreateDropdown({ Name = "Recipe", Options = RecipeNames, CurrentOption = RecipeNames[1], Callback = function(O) _G.Config.CraftRecipe = O[1] end})
    TabCraft:CreateDropdown({ Name = "Year", Options = {"100000 Year", "10000 Year", "1000 Year", "100 Year", "10 Year", "1 Year"}, CurrentOption = "100000 Year", Callback = function(O) _G.Config.CraftYear = O[1] end})
    TabCraft:CreateInput({ Name = "Cauldron Level", PlaceholderText = "10", Callback = function(Text) _G.Config.CraftLevel = tonumber(Text) or 10 end})
    TabCraft:CreateInput({ Name = "Amount", PlaceholderText = "1", Callback = function(Text) _G.Config.CraftAmount = tonumber(Text) or 1 end})
    
    TabCraft:CreateToggle({ 
        Name = "▶ START AUTO CRAFT", 
        CurrentValue = false, 
        Callback = function(V) 
            _G.Config.CraftEnabled = V 
            if V then
                task.spawn(function()
                    local count = 0
                    while _G.Config.CraftEnabled and count < (_G.Config.CraftAmount or 1) and IsAlive() do
                        count = count + 1
                        local recipe = nil
                        for _,r in ipairs(CraftRecipes) do 
                            if r.Name == _G.Config.CraftRecipe then recipe = r break end 
                        end
                        
                        if recipe then
                            local Remote_Craft = RE:WaitForChild("Events"):WaitForChild("CraftPill")
                            local Remote_Add = RE:WaitForChild("Events"):WaitForChild("UseHerbAlchemy")
                            local Remote_Reset = RE:FindFirstChild("ReturnHerbalAlchemy", true)
                            
                            if Remote_Reset then Remote_Reset:FireServer() end
                            task.wait(0.5)
                            
                            for s, h in ipairs(recipe.Items) do 
                                if not _G.Config.CraftEnabled then break end
                                Remote_Add:FireServer(h, _G.Config.CraftYear, s)
                                task.wait(0.3) 
                            end
                            
                            if _G.Config.CraftEnabled then 
                                Remote_Craft:FireServer(_G.Config.CraftRecipe, YearToGrade[_G.Config.CraftYear], _G.Config.CraftLevel or 10, 1) 
                            end
                        end
                        task.wait(3)
                    end
                    _G.Config.CraftEnabled = false
                end)
            end 
        end
    })

    -- =============================================================
    -- 7. LOGIC LOOPS
    -- =============================================================
    local function Interact(target)
        for _, v in ipairs(WS:GetDescendants()) do
            if (v:IsA("Model") or v:IsA("BasePart")) then
                local p = (v:IsA("Model") and v:GetPivot().Position) or v.Position
                if (p - target.Position).Magnitude < 15 then
                    local prompt = v:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then 
                        prompt:InputHoldBegin()
                        task.wait(prompt.HoldDuration + _G.Config.HoldDelay)
                        prompt:InputHoldEnd()
                        return true
                    end
                    local click = v:FindFirstChildWhichIsA("ClickDetector", true)
                    if click then 
                        fireclickdetector(click)
                        return true
                    end
                end
            end
        end
        return false
    end

    task.spawn(function()
        while IsAlive() do
            if (_G.Config.AutoLoot or _G.Config.InstantFarm) and not IsReturning and not _G.Config.AutoWaypoint then
                local targetData = LocationCache[1]
                if targetData and targetData.Instance and targetData.Instance.Parent then
                    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local targetPos = (targetData.Instance:IsA("Model") and targetData.Instance:GetPivot().Position) or targetData.Instance.Position
                        hrp.CFrame = CFrame.new(targetPos) + Vector3.new(0, 3, 0)
                        task.wait(_G.Config.SyncDelay)
                        if targetData.Instance.Parent then
                            if _G.Config.InstantFarm then 
                                CollectRemote:FireServer(targetData.Instance)
                            else 
                                hrp.Anchored = true
                                Interact(targetData.Instance)
                                hrp.Anchored = false
                            end
                        end
                    end
                    table.remove(LocationCache, 1)
                else 
                    if #LocationCache > 0 then table.remove(LocationCache, 1) end
                    task.wait(0.5) 
                end
            end
            task.wait(0.1)
        end
    end)

    task.spawn(function()
        while IsAlive() do
            if _G.Config.AutoWaypoint and #_G.Config.Waypoints > 0 and not _G.Config.AutoLoot and not _G.Config.InstantFarm then
                for i, cf in ipairs(_G.Config.Waypoints) do
                    if not _G.Config.AutoWaypoint then break end
                    local plat = EnsurePlatform()
                    plat.CFrame = cf - Vector3.new(0, 3.5, 0)
                    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                        LP.Character.HumanoidRootPart.CFrame = cf
                    end
                    local d = tonumber(_G.Config.WaypointDelay) or 1
                    if d < 0.1 then d = 0.1 end
                    task.wait(d)
                    if _G.Config.DestroyMap then NukeMap() end
                end
                if _G.Config.AutoClean then 
                    table.clear(LocationCache)
                    LocationCache = {} 
                end
            else
                local p = workspace:FindFirstChild("Kuma_Platform")
                if p then p:Destroy() end
                task.wait(1)
            end
        end
    end)

    task.spawn(function() 
        while IsAlive() do 
            task.wait(30)
            if _G.Config.AutoClean then 
                if _G.Config.DestroyMap then NukeMap() end 
            end 
        end 
    end)

    Rayfield:LoadConfiguration()
    Rayfield:Notify({Title = "🐻 KUMA HUB 🐻", Content = "Mobile Mode Activated!", Duration = 5})

end)
