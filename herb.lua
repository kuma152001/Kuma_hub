--==============================================================
--  KUMA HUB V76 - THE FINAL STEALTH (ALL-IN-ONE)
--==============================================================

-- [1] HỆ THỐNG TỰ ĐỘNG DỌN DẸP (CLEANUP)
local ScriptID = tick()
_G.KumaInstanceID = ScriptID

local function IsAlive()
    return _G.KumaInstanceID == ScriptID
end

-- Xóa UI và ESP cũ
for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name:find("KumaV") or v.Name:find("Secure_") or v.Name:find("KumaSecure") then
        v:Destroy()
    end
end

-- [2] SERVICES & BIẾN HỆ THỐNG
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")
local TS = game:GetService("TweenService")

local flameList = {"Karmic Dao Flame", "Poison Death Flame", "Great River Flame", "Disaster Rose Flame", "Ice Devil Flame", "Azure Moon Flame", "Ruinous Flame", "Earth Flame", "Heaven Flame", "Obsidian Flame", "Bone Chill Flame", "Green Lotus Flame", "Sea Heart Flame", "Volcanic Flame", "Purifying Lotus Demon Flame", "Gold Emperor Burning Sky Flame"}
local manualList = {"Qi Condensation Sutra", "Six Yin Scripture", "Nine Yang Scripture", "Maniac's Cultivation Tips", "Verdant Wind Scripture", "Copper Body Formula", "LotusSutra", "Mother Earth Technique", "Pure Heart Skill", "Heavenly Demon Scripture", "Extreme Sword Sutra", "Principle of Motion", "Shadowless Canon", "Principle of Stillness", "Earth Flame Method", "Steel Body Formula", "Rising Dragon Art", "Soul Shedding Manual", "Star Reaving Scripture", "Return to Basic", "Taotie's Blood Devouring", "Tower Forging", "BeastSoul", "Journey To The West", "Book of Life and Death"}

local ItemCache = {Items = {}, Mobs = {}}
local SecureFolder = Instance.new("Folder", CG)
SecureFolder.Name = "Secure_" .. math.random(1000, 9999)

_G.Config = {
    FarmItem = false,
    FarmMob = false,
    SelectedItems = {},
    SelectedMobs = {},
    Speed = 120,
    MaxDist = 3500,
    ESP = {Flames = false, Manuals = false, Herbs = false, Mobs = false}
}

-- [HÀM HỖ TRỢ]
local function isTarget(name, list)
    for _, v in pairs(list) do if name:lower() == v:lower() then return true end end
    return false
end

----------------------------------------------------------------
-- [3] GIAO DIỆN V76 (TỐI ƯU & THU NHỎ)
----------------------------------------------------------------
local sg = Instance.new("ScreenGui", CG); sg.Name = "KumaV76"
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 300, 0, 520); main.Position = UDim2.new(0.05, 0, 0.15, 0)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); main.BorderSizePixel = 0; main.Active = true; main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -35, 0, 35); title.Text = " 🐉 KUMA HUB V76 - FINAL"; title.BackgroundColor3 = Color3.fromRGB(25, 25, 25); title.TextColor3 = Color3.new(1, 1, 1); title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 35, 0, 35); minBtn.Position = UDim2.new(1, -35, 0, 0); minBtn.Text = "-"; minBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); minBtn.TextColor3 = Color3.new(1, 1, 1)

local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, 0, 1, -40); content.Position = UDim2.new(0, 0, 0, 40); content.BackgroundTransparency = 1; content.CanvasSize = UDim2.new(0, 0, 2.5, 0)
local layout = Instance.new("UIListLayout", content); layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createBtn(txt, color, parent, sizeY)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.92, 0, 0, sizeY or 35); b.Text = txt; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1, 1, 1); b.BorderSizePixel = 0; return b
end

local toggleItem = createBtn("AUTO NHẶT ĐỒ: OFF", Color3.fromRGB(120, 30, 30), content, 40)
local toggleMob = createBtn("AUTO FARM QUÁI: OFF", Color3.fromRGB(120, 30, 30), content, 40)
local scanBtn = createBtn("🔄 QUÉT TOÀN KHU VỰC", Color3.fromRGB(30, 100, 200), content, 40)

Instance.new("TextLabel", content).Text = "--- CHỌN ĐỒ (Herb/Flame/Manual) ---"; content.TextLabel.Size = UDim2.new(0.9, 0, 0, 20); content.TextLabel.TextColor3 = Color3.new(0.6,0.6,0.6); content.TextLabel.BackgroundTransparency = 1

local scrollItems = Instance.new("ScrollingFrame", content)
scrollItems.Size = UDim2.new(0.92, 0, 0, 110); scrollItems.BackgroundColor3 = Color3.fromRGB(25, 25, 25); scrollItems.BorderSizePixel = 0
Instance.new("UIListLayout", scrollItems).Padding = UDim.new(0, 3)

Instance.new("TextLabel", content).Text = "--- CHỌN QUÁI (Mobs) ---"; content.TextLabel.Size = UDim2.new(0.9, 0, 0, 20); content.TextLabel.TextColor3 = Color3.new(0.6,0.6,0.6); content.TextLabel.BackgroundTransparency = 1

local scrollMobs = Instance.new("ScrollingFrame", content)
scrollMobs.Size = UDim2.new(0.92, 0, 0, 110); scrollMobs.BackgroundColor3 = Color3.fromRGB(25, 25, 25); scrollMobs.BorderSizePixel = 0
Instance.new("UIListLayout", scrollMobs).Padding = UDim.new(0, 3)

----------------------------------------------------------------
-- [4] HỆ THỐNG DI CHUYỂN MƯỢT (STEALTH MOVE)
----------------------------------------------------------------
local function SmoothMove(targetPart, isMob)
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetPart or not targetPart.Parent then return end
    
    local targetPos = targetPart.Position + (isMob and Vector3.new(0, 0, 4) or Vector3.new(0, 2.5, 0))
    local reached = false
    local bv = Instance.new("BodyVelocity", hrp); bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    
    local conn
    conn = RS.Heartbeat:Connect(function(dt)
        if not IsAlive() or not (_G.Config.FarmItem or _G.Config.FarmMob) or not targetPart.Parent then conn:Disconnect(); return end
        local diff = targetPos - hrp.Position
        if diff.Magnitude < 1.8 then reached = true; conn:Disconnect()
        else
            local s = (_G.Config.Speed + math.random(-5, 8)) * dt
            hrp.CFrame = CFrame.lookAt(hrp.Position + (diff.Unit * math.min(s, diff.Magnitude)), targetPart.Position)
            -- Noclip khi bay
            for _, p in pairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end
    end)
    repeat task.wait() until reached or not IsAlive() or not (_G.Config.FarmItem or _G.Config.FarmMob)
    if bv then bv:Destroy() end
end

----------------------------------------------------------------
-- [5] SMART SCAN AREA
----------------------------------------------------------------
local function ScanArea()
    ItemCache = {Items = {}, Mobs = {}}
    for _, v in pairs(scrollItems:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, v in pairs(scrollMobs:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end

    local all = workspace:GetDescendants()
    local foundItems, foundMobs = {}, {}

    for i, v in ipairs(all) do
        if not IsAlive() then break end
        -- Phân loại Đồ
        local isItem = isTarget(v.Name, flameList) or isTarget(v.Name, manualList) or (v.Parent and v.Parent.Name == "Herbs")
        local prompt = v:FindFirstChildWhichIsA("ProximityPrompt", true)
        -- Phân loại Quái
        local hum = v:IsA("Humanoid") and v or v:FindFirstChild("Humanoid")
        local isMob = hum and v.Parent ~= LP.Character and v.Parent:FindFirstChild("HumanoidRootPart")

        if isItem and prompt then
            table.insert(ItemCache.Items, {o = v, p = prompt})
            if not foundItems[v.Name] then
                foundItems[v.Name] = true
                local b = createBtn(v.Name, Color3.fromRGB(40, 40, 40), scrollItems, 30)
                b.Size = UDim2.new(1, -10, 0, 30)
                b.MouseButton1Click:Connect(function()
                    local idx = table.find(_G.Config.SelectedItems, v.Name)
                    if not idx then table.insert(_G.Config.SelectedItems, v.Name); b.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                    else table.remove(_G.Config.SelectedItems, idx); b.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
                end)
            end
        elseif isMob and hum.Health > 0 then
            local model = v:IsA("Humanoid") and v.Parent or v
            table.insert(ItemCache.Mobs, model)
            if not foundMobs[model.Name] then
                foundMobs[model.Name] = true
                local b = createBtn(model.Name, Color3.fromRGB(60, 25, 25), scrollMobs, 30)
                b.Size = UDim2.new(1, -10, 0, 30)
                b.MouseButton1Click:Connect(function()
                    local idx = table.find(_G.Config.SelectedMobs, model.Name)
                    if not idx then table.insert(_G.Config.SelectedMobs, model.Name); b.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                    else table.remove(_G.Config.SelectedMobs, idx); b.BackgroundColor3 = Color3.fromRGB(60, 25, 25) end
                end)
            end
        end
        if i % 800 == 0 then task.wait() end
    end
end
scanBtn.MouseButton1Click:Connect(ScanArea)

----------------------------------------------------------------
-- [6] STEALTH ESP SYSTEM
----------------------------------------------------------------
local function CreateESP(obj, text, color)
    local t = Instance.new("Folder", SecureFolder)
    local hl = Instance.new("Highlight", t); hl.Adornee = obj; hl.FillColor = color; hl.FillTransparency = 0.7
    local bg = Instance.new("BillboardGui", t); bg.Adornee = obj; bg.Size = UDim2.new(0, 100, 0, 20); bg.AlwaysOnTop = true; bg.StudsOffset = Vector3.new(0, 3, 0)
    local tl = Instance.new("TextLabel", bg); tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1; tl.Text = text; tl.TextColor3 = color; tl.Font = Enum.Font.GothamBold; tl.TextSize = 10
end

task.spawn(function()
    while IsAlive() do
        task.wait(2); SecureFolder:ClearAllChildren()
        if not _G.Config.ESP.Flames and not _G.Config.ESP.Mobs then continue end
        for _, item in pairs(ItemCache.Items) do
            local o = item.o
            if isTarget(o.Name, flameList) and _G.Config.ESP.Flames then CreateESP(o, "🔥 "..o.Name, Color3.new(1, 0.5, 0))
            elseif isTarget(o.Name, manualList) and _G.Config.ESP.Manuals then CreateESP(o, "📖 "..o.Name, Color3.new(1, 1, 0)) end
        end
        if _G.Config.ESP.Mobs then
            for _, mob in pairs(ItemCache.Mobs) do if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then CreateESP(mob, "💀 "..mob.Name, Color3.new(1, 0, 0)) end end
        end
    end
end)

----------------------------------------------------------------
-- [7] VÒNG LẶP FARM CHÍNH (PRIORITY)
----------------------------------------------------------------
task.spawn(function()
    while IsAlive() do
        if _G.Config.FarmItem or _G.Config.FarmMob then
            pcall(function()
                local hrp = LP.Character.HumanoidRootPart
                local target, prompt, isM = nil, nil, false
                local d = _G.Config.MaxDist

                -- 1. ƯU TIÊN ĐỒ TRƯỚC
                if _G.Config.FarmItem then
                    for _, item in pairs(ItemCache.Items) do
                        if table.find(_G.Config.SelectedItems, item.o.Name) then
                            local part = item.o:IsA("BasePart") and item.o or item.o:FindFirstChildWhichIsA("BasePart", true)
                            if part and part.Parent then
                                local dist = (part.Position - hrp.Position).Magnitude
                                if dist < d then d = dist; target = part; prompt = item.p end
                            end
                        end
                    end
                end
                -- 2. SAU ĐÓ ĐẾN QUÁI
                if not target and _G.Config.FarmMob then
                    for _, mob in pairs(ItemCache.Mobs) do
                        if table.find(_G.Config.SelectedMobs, mob.Name) and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                            local dist = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
                            if dist < d then d = dist; target = mob.HumanoidRootPart; isM = true end
                        end
                    end
                end

                if target then
                    SmoothMove(target, isM)
                    if isM then
                        local tool = LP.Character:FindFirstChildWhichIsA("Tool") or LP.Backpack:FindFirstChildWhichIsA("Tool")
                        if tool then if tool.Parent == LP.Backpack then LP.Character.Humanoid:EquipTool(tool) end tool:Activate() end
                    else
                        task.wait(0.2); if prompt then fireproximityprompt(prompt) end; task.wait(0.3)
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

----------------------------------------------------------------
-- [8] ĐIỀU KHIỂN UI
----------------------------------------------------------------
toggleItem.MouseButton1Click:Connect(function()
    _G.Config.FarmItem = not _G.Config.FarmItem
    toggleItem.Text = "AUTO NHẶT ĐỒ: " .. (_G.Config.FarmItem and "ON" or "OFF")
    toggleItem.BackgroundColor3 = _G.Config.FarmItem and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(120, 30, 30)
end)

toggleMob.MouseButton1Click:Connect(function()
    _G.Config.FarmMob = not _G.Config.FarmMob
    toggleMob.Text = "AUTO FARM QUÁI: " .. (_G.Config.FarmMob and "ON" or "OFF")
    toggleMob.BackgroundColor3 = _G.Config.FarmMob and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(120, 30, 30)
end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    main:TweenSize(minimized and UDim2.new(0, 300, 0, 35) or UDim2.new(0, 300, 0, 520), "Out", "Quad", 0.3, true)
    minBtn.Text = minimized and "+" or "-"
end)

-- Tạo các nút ESP
local function addEspToggle(txt, key)
    local b = createBtn(txt..": OFF", Color3.fromRGB(45, 45, 45), content)
    b.MouseButton1Click:Connect(function()
        _G.Config.ESP[key] = not _G.Config.ESP[key]
        b.Text = txt .. (_G.Config.ESP[key] and ": ON" or ": OFF")
        b.BackgroundColor3 = _G.Config.ESP[key] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45)
    end)
end

addEspToggle("ESP Flames", "Flames")
addEspToggle("ESP Manuals", "Manuals")
addEspToggle("ESP Mobs", "Mobs")

print("✅ KUMA HUB V76 LOADED - CLEAN & STEALTH")
