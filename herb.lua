--==============================================================
--  KUMA HUB V155 - HYBRID (V154 UI + V139 INTERACT)
--==============================================================

local ScriptID = tick()
_G.KumaInstanceID = ScriptID
local function IsAlive() return _G.KumaInstanceID == ScriptID end

-- Dọn dẹp UI cũ
pcall(function()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name:find("Kuma") or v.Name:find("Secure") then v:Destroy() end
    end
end)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local LP = game:GetService("Players").LocalPlayer
local CG = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")
local WS = game:GetService("Workspace")

-- === CONFIG & DATA ===
local PRESET_LIST = {
    "Ginseng", "Spirit Rose", "Qi Flower", "Qi Berries", "Moon Flower", "Death Flower",
    "Verdant Vitality Gu", "Crimson Bloodflame Gu", "Amethyst Golden-Ring Gu", "Radiant Seraphwing Gu", "Obsidian Bloodwing Gu"
}

_G.Config = { 
    Tracking = {},       
    AutoLoot = false,
    FarmAll = false,     
    HoldDelay = 0.2,     -- Theo V139
    SyncDelay = 0.6,     -- Theo V139
    ScanInterval = 5,
    AutoReturn = false,   
    SavedPosition = nil,
    
    -- Config Sequence (V154)
    KeySequence = {},    
    SequenceDelay = 1.0, 
    TempKey = "Z",
    ExtraKeys = {},    
    ExtraKeyDelay = 1.0
}

local GlobalCache = {} 
local FailedList = {} -- Dùng kiểu V139: FailedList[Instance] = true
local SecureFolder = Instance.new("Folder", CG); SecureFolder.Name = "KumaSecure_Hybrid"

-- === GIAO DIỆN RAYFIELD (V154) ===
local Window = Rayfield:CreateWindow({
   Name = "🦗 KUMA HUB V155 | Hybrid Logic",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "V139 Interact + V154 Return",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

-- === TAB 1: MAIN FARMING ===
local TabMain = Window:CreateTab("🏠 Main Farming", 4483362458)

local SectionStatus = TabMain:CreateSection("Status")
local StatusLabel = TabMain:CreateLabel("Status: Idle")

TabMain:CreateToggle({
   Name = "▶ START AUTO FARM",
   CurrentValue = false,
   Flag = "AutoLoot", 
   Callback = function(Value)
        _G.Config.AutoLoot = Value
        if not Value and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.Anchored = false
            StatusLabel:Set("Status: STOPPED")
        end
   end,
})

TabMain:CreateToggle({
   Name = "🌍 FARM ALL (Ignore List)",
   CurrentValue = false,
   Flag = "FarmAll", 
   Callback = function(Value) _G.Config.FarmAll = Value end,
})

local SectionReturn = TabMain:CreateSection("Auto Return")

TabMain:CreateButton({
   Name = "📍 Save Current Position",
   Callback = function()
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            _G.Config.SavedPosition = LP.Character.HumanoidRootPart.CFrame
            Rayfield:Notify({Title = "Success", Content = "Position Saved!", Duration = 2})
        end
   end,
})

TabMain:CreateToggle({
   Name = "🔄 Auto Return (Press C + Extras)",
   CurrentValue = false,
   Flag = "AutoReturn", 
   Callback = function(Value) _G.Config.AutoReturn = Value end,
})

-- === TAB 2: EXTRA KEYS (V154) ===
local TabKeys = Window:CreateTab("🎹 Extra Keys", 4483362458)
TabKeys:CreateSection("Add Skills (Press AFTER 'C')")

local SequenceDisplay = TabKeys:CreateLabel("Extra Keys: [ None ]")

local function UpdateDisplay()
    if #_G.Config.ExtraKeys == 0 then
        SequenceDisplay:Set("Extra Keys: [ None ]")
    else
        SequenceDisplay:Set("Extra Keys: " .. table.concat(_G.Config.ExtraKeys, " -> "))
    end
end

TabKeys:CreateSlider({
   Name = "Delay Between Keys",
   Range = {0.1, 3}, Increment = 0.1, Suffix = "s", CurrentValue = 1.0,
   Callback = function(Value) _G.Config.ExtraKeyDelay = Value end,
})

local AvailableKeys = {"Z", "X", "V", "Q", "E", "R", "T", "Y", "U", "Space"}
TabKeys:CreateDropdown({
   Name = "Select Key",
   Options = AvailableKeys,
   CurrentOption = "Z",
   Callback = function(Option) _G.Config.TempKey = Option[1] end,
})

TabKeys:CreateButton({
   Name = "➕ Add Key",
   Callback = function()
        table.insert(_G.Config.ExtraKeys, _G.Config.TempKey)
        UpdateDisplay()
    end,
})

TabKeys:CreateButton({
   Name = "🗑 Clear Extra Keys",
   Callback = function() _G.Config.ExtraKeys = {}; UpdateDisplay() end,
})

-- === SETTINGS (V154) ===
local TabSettings = Window:CreateTab("⚙ Settings", 4483362458)
TabSettings:CreateSlider({ Name = "TP Wait Time", Range = {0.1, 5}, Increment = 0.1, Suffix = "s", CurrentValue = 0.6, Callback = function(V) _G.Config.SyncDelay = V end})
TabSettings:CreateSlider({ Name = "Hold Extra Time", Range = {0, 4}, Increment = 0.1, Suffix = "s", CurrentValue = 3.0, Callback = function(V) _G.Config.HoldDelay = V end})
TabSettings:CreateButton({ Name = "🛠 Force Re-Scan", Callback = function() _G.ForceUpdate = true end })

local TabFilter = Window:CreateTab("📜 Item Filter", 4483362458)
TabFilter:CreateButton({ Name = "Select All", Callback = function() _G.Config.Tracking={}; for _,v in ipairs(PRESET_LIST) do table.insert(_G.Config.Tracking,v) end; _G.ForceUpdate=true end})
TabFilter:CreateButton({ Name = "Deselect All", Callback = function() _G.Config.Tracking={}; _G.ForceUpdate=true end })
for _, item in ipairs(PRESET_LIST) do TabFilter:CreateToggle({ Name = item, CurrentValue = false, Callback = function(V) if V then table.insert(_G.Config.Tracking, item) else for i,v in ipairs(_G.Config.Tracking) do if v==item then table.remove(_G.Config.Tracking, i) end end end _G.ForceUpdate=true end}) end

--==============================================================
-- CORE LOGIC (HYBRID: SCAN/INTERACT OF V139 + RETURN OF V154)
--==============================================================

local function IsValidTarget(name)
    for _, target in ipairs(PRESET_LIST) do if name:lower():find(target:lower()) then return target end end
    return nil
end

-- [LOGIC V139] Tìm Prompt/Click ngay từ lúc Scan
local function FindInteractable(model)
    local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then return prompt, "Prompt" end
    local click = model:FindFirstChildWhichIsA("ClickDetector", true)
    if click then return click, "Click" end
    return nil, nil
end

-- [LOGIC V154] Hàm Return giữ nguyên
local function PerformAutoReturn()
    if not _G.Config.AutoReturn or not _G.Config.SavedPosition then return end
    
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    StatusLabel:Set("Status: Returning...")
    
    -- TP Về
    hrp.CFrame = _G.Config.SavedPosition
    task.wait(0.5)

    -- Bấm C
    StatusLabel:Set("Status: Pressing 'C'...")
    VIM:SendKeyEvent(true, Enum.KeyCode.C, false, game)
    task.wait(0.1)
    VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
    
    -- Bấm phím phụ
    if #_G.Config.ExtraKeys > 0 then
        for _, keyName in ipairs(_G.Config.ExtraKeys) do
            task.wait(_G.Config.ExtraKeyDelay)
            StatusLabel:Set("Status: Pressing " .. keyName)
            local keyEnum = Enum.KeyCode[keyName]
            if keyEnum then
                VIM:SendKeyEvent(true, keyEnum, false, game)
                task.wait(0.1)
                VIM:SendKeyEvent(false, keyEnum, false, game)
            end
        end
    end
    
    StatusLabel:Set("Status: Cultivating...")
end

-- [LOGIC V139] Hàm Scan cải tiến
function UpdateCache()
    if not _G.Config.AutoLoot then return end
    StatusLabel:Set("Status: Scanning Models...")
    local tempCache = {}
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
                -- V139: Lưu luôn Instance (Prompt/Click) vào cache
                local interactObj, type = FindInteractable(v)
                if interactObj then
                    table.insert(tempCache, { Name = validName, Obj = v, Instance = interactObj, Type = type })
                end
            end
        end
    end
    GlobalCache = tempCache
    StatusLabel:Set("Status: Found " .. #GlobalCache .. " targets.")
end

-- [LOGIC V139] Hàm Ổn định nhân vật
local function Stabilize(hrp)
    if not hrp then return end
    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
    hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
end

task.spawn(function()
    while IsAlive() do
        UpdateCache()
        for i = _G.Config.ScanInterval, 1, -1 do
            if not IsAlive() then break end
            if _G.ForceUpdate then _G.ForceUpdate = false; break end
            task.wait(1)
        end
    end
end)

-- [LOGIC V139 + V154 Return] Hàm Nhặt đồ thay thế
local function Interact(item)
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    StatusLabel:Set("Target: " .. item.Name)
    
    -- V139: Zero Velocity trước khi TP
    hrp.AssemblyLinearVelocity = Vector3.zero
    
    local targetPos = item.Obj.GetPivot and item.Obj:GetPivot().Position or item.Obj.CFrame.Position
    hrp.CFrame = CFrame.new(targetPos) * CFrame.new(0, 3, 0)
    
    task.wait(_G.Config.SyncDelay)
    
    -- V139: Stabilize + Anchor
    Stabilize(hrp)
    hrp.Anchored = true
    
    -- V139: Check khoảng cách sau khi TP (Chống lag)
    if (hrp.Position - targetPos).Magnitude > 15 then
        StatusLabel:Set("Status: Too far (Lag), Retrying...")
        hrp.Anchored = false
        task.wait(0.2)
        return -- Thoát để thử lại sau
    end

    local holdTime = 0
    if item.Type == "Prompt" then 
        holdTime = item.Instance.HoldDuration + _G.Config.HoldDelay 
    end
    
    local attempts = 0
    -- V139: Check item.Instance.Parent trong vòng lặp
    while attempts < 3 and item.Instance.Parent and IsAlive() and _G.Config.AutoLoot do
        attempts = attempts + 1
        if item.Type == "Prompt" then
            pcall(function() item.Instance:InputHoldBegin(); task.wait(holdTime); item.Instance:InputHoldEnd() end)
        elseif item.Type == "Click" then
            fireclickdetector(item.Instance); task.wait(0.5)
        end
        if not item.Instance.Parent then break else task.wait(0.2) end
    end
    
    hrp.Anchored = false
    
    -- V139: Đưa vào FailedList nếu nhặt không thành công (mà item vẫn còn)
    if item.Instance.Parent then FailedList[item.Instance] = true end
    
    -- Xóa khỏi Cache hiện tại
    for i, v in ipairs(GlobalCache) do if v.Instance == item.Instance then table.remove(GlobalCache, i); break end end
    
    -- GỌI AUTO RETURN (Của V154)
    PerformAutoReturn()
    task.wait(0.1)
end

-- Main Loop
task.spawn(function()
    while IsAlive() do
        local myPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character.HumanoidRootPart.Position
        if myPos then
            SecureFolder:ClearAllChildren()
            local bestItem, minDst = nil, 999999
            
            for _, item in ipairs(GlobalCache) do
                if item.Instance and item.Instance.Parent then
                    -- Check FailedList kiểu V139
                    if not FailedList[item.Instance] then
                        local isSelected = table.find(_G.Config.Tracking, item.Name)
                        local isFarmAll = _G.Config.FarmAll
                        local itemPos = item.Obj.GetPivot and item.Obj:GetPivot().Position or item.Obj.Position
                        local dist = (itemPos - myPos).Magnitude
                        
                        -- ESP (Giản lược)
                        
                        if _G.Config.AutoLoot and (isSelected or isFarmAll) then
                            if dist < minDst then minDst = dist; bestItem = item end
                        end
                    end
                end
            end
            if bestItem then Interact(bestItem) end
        end
        task.wait(0.5)
    end
end)

LP.CharacterAdded:Connect(function(newChar)
    if not IsAlive() then return end
    if _G.Config.AutoReturn and _G.Config.SavedPosition then
        task.spawn(function()
            local hrp = newChar:WaitForChild("HumanoidRootPart", 20)
            if hrp then
                task.wait(1.5)
                PerformAutoReturn()
            end
        end)
    end
end)

Rayfield:Notify({
   Title = "KUMA HUB V155",
   Content = "V139 Interact + V154 Return",
   Duration = 5,
})
