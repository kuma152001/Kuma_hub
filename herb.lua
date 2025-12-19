--==============================================================
--  KUMA HUB V81 - PURE ITEM EDITION (NO MOB CODE - ANTI BAN)
--==============================================================

-- [1] HỆ THỐNG TỰ ĐỘNG DỌN DẸP
local ScriptID = tick()
_G.KumaInstanceID = ScriptID

local function IsAlive()
    return _G.KumaInstanceID == ScriptID
end

pcall(function()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name:find("Kuma") or v.Name:find("Secure") then v:Destroy() end
    end
end)

-- [2] SERVICES
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")
local TS = game:GetService("TweenService")

-- DANH SÁCH VẬT PHẨM ĐẶC BIỆT
local flameList = {"Karmic Dao Flame", "Poison Death Flame", "Great River Flame", "Disaster Rose Flame", "Ice Devil Flame", "Azure Moon Flame", "Ruinous Flame", "Earth Flame", "Heaven Flame", "Obsidian Flame", "Bone Chill Flame", "Green Lotus Flame", "Sea Heart Flame", "Volcanic Flame", "Purifying Lotus Demon Flame", "Gold Emperor Burning Sky Flame"}
local manualList = {"Qi Condensation Sutra", "Six Yin Scripture", "Nine Yang Scripture", "Maniac's Cultivation Tips", "Verdant Wind Scripture", "Copper Body Formula", "LotusSutra", "Mother Earth Technique", "Pure Heart Skill", "Heavenly Demon Scripture", "Extreme Sword Sutra", "Principle of Motion", "Shadowless Canon", "Principle of Stillness", "Earth Flame Method", "Steel Body Formula", "Rising Dragon Art", "Soul Shedding Manual", "Star Reaving Scripture", "Return to Basic", "Taotie's Blood Devouring", "Tower Forging", "BeastSoul", "Journey To The West", "Book of Life and Death"}

_G.Config = {
    Enabled = false,
    Selected = {},
    Speed = 118,
    MaxDist = 3500,
    ESP = {Flames = false, Manuals = false, Herbs = false}
}

local ItemCache = {Items = {}}
local SecureFolder = Instance.new("Folder", CG)
SecureFolder.Name = "SafeVisuals_" .. math.random(100, 999)

-- Hàm kiểm tra vật phẩm hiếm
local function isSpecial(name)
    local n = name:lower()
    for _, v in pairs(flameList) do if n == v:lower() then return "Flame" end end
    for _, v in pairs(manualList) do if n == v:lower() then return "Manual" end end
    return nil
end

-- [3] GIAO DIỆN V81 (CHỈ HIỂN THỊ ĐỒ)
local sg = Instance.new("ScreenGui", CG); sg.Name = "KumaV81"
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 260, 0, 420); main.Position = UDim2.new(0.05, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BorderSizePixel = 0; main.Active = true; main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -35, 0, 35); title.Text = " 🌿 KUMA HUB V81 - ITEM ONLY"; title.BackgroundColor3 = Color3.fromRGB(30, 30, 30); title.TextColor3 = Color3.new(1, 1, 1); title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 35, 0, 35); minBtn.Position = UDim2.new(1, -35, 0, 0); minBtn.Text = "-"; minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); minBtn.TextColor3 = Color3.new(1, 1, 1)

local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, 0, 1, -40); content.Position = UDim2.new(0, 0, 0, 40); content.BackgroundTransparency = 1; content.CanvasSize = UDim2.new(0, 0, 2, 0)
Instance.new("UIListLayout", content).Padding = UDim.new(0, 7); Instance.new("UIPadding", content).PaddingLeft = UDim.new(0, 10)

local function createBtn(txt, color, parent)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.95, 0, 0, 35); b.Text = txt; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1, 1, 1); b.BorderSizePixel = 0; return b
end

local toggleFarm = createBtn("START AUTO COLLECT: OFF", Color3.fromRGB(120, 30, 30), content)
local scanBtn = createBtn("🔄 QUÉT VẬT PHẨM (SCAN)", Color3.fromRGB(30, 100, 200), content)

local scroll = Instance.new("ScrollingFrame", content)
scroll.Size = UDim2.new(0.95, 0, 0, 180); scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 25); scroll.BorderSizePixel = 0
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 3)

----------------------------------------------------------------
-- [4] DI CHUYỂN "GHOST" (MƯỢT & KHÔNG GIẬT)
----------------------------------------------------------------
local function StealthMove(targetPart)
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetPart or not targetPart.Parent then return end

    local targetPos = targetPart.Position + Vector3.new(0, 2.5, 0)
    local reached = false
    local bv = Instance.new("BodyVelocity", hrp); bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)

    local connection
    connection = RS.Heartbeat:Connect(function(dt)
        if not IsAlive() or not _G.Config.Enabled or not targetPart.Parent then 
            connection:Disconnect(); return 
        end
        
        local diff = targetPos - hrp.Position
        if diff.Magnitude < 1.5 then
            reached = true; connection:Disconnect()
        else
            -- Tốc độ biến thiên ngẫu nhiên cực nhỏ để giả lập người thật
            local s = (_G.Config.Speed + math.random(-4, 7)) * dt
            hrp.CFrame = CFrame.lookAt(hrp.Position + (diff.Unit * math.min(s, diff.Magnitude)), targetPart.Position)
            -- Noclip bảo vệ
            for _, p in pairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end
    end)

    repeat task.wait() until reached or not IsAlive() or not _G.Config.Enabled
    if bv then bv:Destroy() end
end

----------------------------------------------------------------
-- [5] QUÉT CHỈ ĐỊNH (TUYỆT ĐỐI KHÔNG QUÉT MOB)
----------------------------------------------------------------
local function ScanArea()
    ItemCache.Items = {}
    for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    
    local all = workspace:GetDescendants()
    local foundNames = {}

    for i, v in ipairs(all) do
        if not IsAlive() then break end
        
        -- CHỈ QUÉT NHỮNG THỨ CÓ NÚT BẤM (PROXIMITYPROMPT)
        -- VÀ BỎ QUA NẾU NÓ LÀ MỘT PHẦN CỦA NHÂN VẬT/QUÁI (HUMANOID)
        local prompt = v:FindFirstChildWhichIsA("ProximityPrompt", true)
        local hasHum = v:FindFirstChild("Humanoid") or (v.Parent and v.Parent:FindFirstChild("Humanoid"))
        
        if prompt and not hasHum then
            table.insert(ItemCache.Items, {o = v, p = prompt})
            if not foundNames[v.Name] then
                foundNames[v.Name] = true
                local b = createBtn(v.Name, Color3.fromRGB(45, 45, 45), scroll)
                b.Size = UDim2.new(1, -10, 0, 30)
                b.MouseButton1Click:Connect(function()
                    local idx = table.find(_G.Config.Selected, v.Name)
                    if not idx then
                        table.insert(_G.Config.Selected, v.Name); b.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                    else
                        for i2, n in pairs(_G.Config.Selected) do if n == v.Name then table.remove(_G.Config.Selected, i2) end end
                        b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    end
                end)
            end
        end
        if i % 1000 == 0 then task.wait() end
    end
end
scanBtn.MouseButton1Click:Connect(ScanArea)

----------------------------------------------------------------
-- [6] VÒNG LẶP FARM AN TOÀN
----------------------------------------------------------------
task.spawn(function()
    while IsAlive() do
        if _G.Config.Enabled and #_G.Config.Selected > 0 then
            pcall(function()
                local hrp = LP.Character.HumanoidRootPart
                local target, prompt
                local dist = _G.Config.MaxDist

                for _, item in pairs(ItemCache.Items) do
                    if table.find(_G.Config.Selected, item.o.Name) then
                        local part = item.o:IsA("BasePart") and item.o or item.o:FindFirstChildWhichIsA("BasePart", true)
                        if part and part.Parent then
                            local d = (part.Position - hrp.Position).Magnitude
                            if d < dist then dist = d; target = part; prompt = item.p end
                        end
                    end
                end

                if target then
                    StealthMove(target)
                    task.wait(0.2 + math.random()*0.3) -- Độ trễ ngẫu nhiên
                    if prompt then fireproximityprompt(prompt) end
                    task.wait(0.4)
                end
            end)
        end
        task.wait(0.5)
    end
end)

----------------------------------------------------------------
-- [7] ESP BẢO MẬT (CHỈ HIỆN ĐỒ)
----------------------------------------------------------------
local function CreateESP(obj, text, color)
    local t = Instance.new("Folder", SecureFolder)
    local hl = Instance.new("Highlight", t); hl.Adornee = obj; hl.FillColor = color; hl.FillTransparency = 0.7
    local bg = Instance.new("BillboardGui", t); bg.Adornee = obj; bg.Size = UDim2.new(0, 100, 0, 20); bg.AlwaysOnTop = true; bg.StudsOffset = Vector3.new(0, 3, 0)
    local tl = Instance.new("TextLabel", bg); tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1; tl.Text = text; tl.TextColor3 = color; tl.Font = Enum.Font.GothamBold; tl.TextSize = 10
end

task.spawn(function()
    while IsAlive() do
        task.wait(2.5); SecureFolder:ClearAllChildren()
        if not _G.Config.ESP.Flames and not _G.Config.ESP.Herbs then continue end
        for _, item in pairs(ItemCache.Items) do
            local o = item.o
            local specType = isSpecial(o.Name)
            if specType == "Flame" and _G.Config.ESP.Flames then CreateESP(o, "🔥 "..o.Name, Color3.new(1, 0.5, 0))
            elseif specType == "Manual" and _G.Config.ESP.Manuals then CreateESP(o, "📖 "..o.Name, Color3.new(1, 1, 0))
            elseif o.Parent and o.Parent.Name == "Herbs" and _G.Config.ESP.Herbs then CreateESP(o, "🌿 "..o.Name, Color3.new(0, 1, 0)) end
        end
    end
end)

----------------------------------------------------------------
-- [8] UI CONTROL
----------------------------------------------------------------
toggleFarm.MouseButton1Click:Connect(function()
    _G.Config.Enabled = not _G.Config.Enabled
    toggleFarm.Text = "AUTO COLLECT: " .. (_G.Config.Enabled and "ON" or "OFF")
    toggleFarm.BackgroundColor3 = _G.Config.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(120, 30, 30)
end)

local function addEsp(txt, key)
    local b = createBtn(txt..": OFF", Color3.fromRGB(45, 45, 45), content)
    b.MouseButton1Click:Connect(function()
        _G.Config.ESP[key] = not _G.Config.ESP[key]
        b.Text = txt .. (_G.Config.ESP[key] and ": ON" or ": OFF")
        b.BackgroundColor3 = _G.Config.ESP[key] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45)
    end)
end
addEsp("ESP Flames", "Flames"); addEsp("ESP Manuals", "Manuals"); addEsp("ESP Herbs", "Herbs")

minBtn.MouseButton1Click:Connect(function()
    local isMin = (main.Size.Y.Offset < 100)
    content.Visible = isMin
    main:TweenSize(isMin and UDim2.new(0, 260, 0, 420) or UDim2.new(0, 260, 0, 35), "Out", "Quad", 0.3, true)
    minBtn.Text = isMin and "-" or "+"
end)

print("✅ KUMA HUB V81 LOADED - ITEM ONLY EDITION")
