--==============================================================
--  KUMA HUB V82 - PURE V71 LOGIC (ITEM ONLY - STEALTH)
--==============================================================

-- [1] HỆ THỐNG TỰ ĐỘNG DỌN DẸP PHIÊN BẢN CŨ
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

-- [2] SERVICES & SETTINGS
local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")
local TS = game:GetService("TweenService")

local flameList = {"Karmic Dao Flame", "Poison Death Flame", "Great River Flame", "Disaster Rose Flame", "Ice Devil Flame", "Azure Moon Flame", "Ruinous Flame", "Earth Flame", "Heaven Flame", "Obsidian Flame", "Bone Chill Flame", "Green Lotus Flame", "Sea Heart Flame", "Volcanic Flame", "Purifying Lotus Demon Flame", "Gold Emperor Burning Sky Flame"}
local manualList = {"Qi Condensation Sutra", "Six Yin Scripture", "Nine Yang Scripture", "Maniac's Cultivation Tips", "Verdant Wind Scripture", "Copper Body Formula", "LotusSutra", "Mother Earth Technique", "Pure Heart Skill", "Heavenly Demon Scripture", "Extreme Sword Sutra", "Principle of Motion", "Shadowless Canon", "Principle of Stillness", "Earth Flame Method", "Steel Body Formula", "Rising Dragon Art", "Soul Shedding Manual", "Star Reaving Scripture", "Return to Basic", "Taotie's Blood Devouring", "Tower Forging", "BeastSoul", "Journey To The West", "Book of Life and Death"}

_G.Config = {
    Enabled = false,
    Selected = {},
    BaseSpeed = 120, -- Tốc độ gốc của V71
    MaxDist = 3500,
    ESP = {Flames = false, Manuals = false, Herbs = false}
}

local ItemCache = {}
local SecureFolder = Instance.new("Folder", CG)
SecureFolder.Name = "SafeVisuals_" .. math.random(100, 999)

local function isSpecial(name)
    local n = name:lower()
    for _, v in pairs(flameList) do if n == v:lower() then return "Flame" end end
    for _, v in pairs(manualList) do if n == v:lower() then return "Manual" end end
    return nil
end

----------------------------------------------------------------
-- [3] GIAO DIỆN NATIVE (MƯỢT & NHẸ)
----------------------------------------------------------------
local sg = Instance.new("ScreenGui", CG); sg.Name = "KumaV82"
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 260, 0, 420); main.Position = UDim2.new(0.05, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); main.BorderSizePixel = 0; main.Active = true; main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -35, 0, 35); title.Text = " 🥷 KUMA V82 - PURE V71"; title.BackgroundColor3 = Color3.fromRGB(25, 25, 25); title.TextColor3 = Color3.new(1, 1, 1); title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 35, 0, 35); minBtn.Position = UDim2.new(1, -35, 0, 0); minBtn.Text = "-"; minBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); minBtn.TextColor3 = Color3.new(1, 1, 1)

local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, 0, 1, -40); content.Position = UDim2.new(0, 0, 0, 40); content.BackgroundTransparency = 1; content.CanvasSize = UDim2.new(0, 0, 2, 0)
Instance.new("UIListLayout", content).Padding = UDim.new(0, 7); Instance.new("UIPadding", content).PaddingLeft = UDim.new(0, 10)

local function createBtn(txt, color, parent)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.95, 0, 0, 35); b.Text = txt; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1, 1, 1); b.BorderSizePixel = 0; return b
end

local toggleFarm = createBtn("START V71 COLLECT: OFF", Color3.fromRGB(120, 30, 30), content)
local scanBtn = createBtn("🔄 SCAN ALL ITEMS", Color3.fromRGB(30, 80, 150), content)

local scroll = Instance.new("ScrollingFrame", content)
scroll.Size = UDim2.new(0.95, 0, 0, 150); scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20); scroll.BorderSizePixel = 0
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 3)

----------------------------------------------------------------
-- [4] DI CHUYỂN V71 LOGIC (STEALTH LERP + LOOKAT)
----------------------------------------------------------------
local function StealthMove(targetPart)
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetPart or not targetPart.Parent then return end

    -- Tốc độ biến thiên ngẫu nhiên (V71 Logic)
    local currentSpeed = _G.Config.BaseSpeed + math.random(-5, 8)
    local targetPos = targetPart.Position + Vector3.new(0, 2.6, 0)
    local reached = false
    
    local bv = Instance.new("BodyVelocity", hrp)
    bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)

    local connection
    connection = RS.Heartbeat:Connect(function(dt)
        if not IsAlive() or not _G.Config.Enabled or not targetPart.Parent then
            connection:Disconnect(); return
        end
        
        local diff = targetPos - hrp.Position
        local dist = diff.Magnitude
        
        if dist < 1.5 then
            reached = true; connection:Disconnect()
        else
            -- Quay mặt về hướng mục tiêu (Anti-Ban quan trọng)
            local moveStep = currentSpeed * dt
            hrp.CFrame = CFrame.lookAt(hrp.Position + (diff.Unit * math.min(moveStep, dist)), targetPart.Position)
            -- Noclip bảo vệ
            for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end
    end)

    repeat task.wait() until reached or not IsAlive() or not _G.Config.Enabled
    if bv then bv:Destroy() end
end

----------------------------------------------------------------
-- [5] QUÉT VẬT PHẨM (TUYỆT ĐỐI KHÔNG QUÉT MOB)
----------------------------------------------------------------
local function UpdateCache()
    local temp = {}
    local all = workspace:GetDescendants()
    for i = 1, #all do
        if not IsAlive() then break end
        local v = all[i]
        -- CHỈ LẤY NHỮNG THỨ CÓ NÚT BẤM VÀ KHÔNG PHẢI QUÁI/NGƯỜI
        local prompt = v:FindFirstChildWhichIsA("ProximityPrompt", true)
        local hasHum = v:FindFirstChild("Humanoid") or (v.Parent and v.Parent:FindFirstChild("Humanoid"))
        
        if prompt and not hasHum then
            table.insert(temp, {p = prompt, o = v})
        end
        if i % 1000 == 0 then task.wait() end 
    end
    ItemCache = temp
end

scanBtn.MouseButton1Click:Connect(function()
    UpdateCache()
    for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local foundNames = {}
    for _, item in pairs(ItemCache) do
        local name = item.o.Name
        if not foundNames[name] then
            foundNames[name] = true
            local b = createBtn(name, Color3.fromRGB(35,35,35), scroll)
            b.Size = UDim2.new(1, -10, 0, 30)
            b.MouseButton1Click:Connect(function()
                local idx = table.find(_G.Config.Selected, name)
                if not idx then table.insert(_G.Config.Selected, name); b.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
                else table.remove(_G.Config.Selected, idx); b.BackgroundColor3 = Color3.fromRGB(35,35,35) end
            end)
        end
    end
end)

----------------------------------------------------------------
-- [6] VÒNG LẶP FARM V71 (RANDOM DELAY)
----------------------------------------------------------------
task.spawn(function()
    while IsAlive() do
        if _G.Config.Enabled and #_G.Config.Selected > 0 then
            pcall(function()
                local hrp = LP.Character.HumanoidRootPart
                local target, prompt; local d = _G.Config.MaxDist
                
                for _, item in pairs(ItemCache) do
                    if table.find(_G.Config.Selected, item.o.Name) then
                        local o = item.o:IsA("BasePart") and item.o or item.o:FindFirstChildWhichIsA("BasePart", true)
                        if o and o.Parent then
                            local dist = (o.Position - hrp.Position).Magnitude
                            if dist < d then d = dist; target = o; prompt = item.p end
                        end
                    end
                end
                
                if target then
                    StealthMove(target)
                    -- Delay ngẫu nhiên cực mượt của V71
                    task.wait(0.15 + (math.random() * 0.25))
                    fireproximityprompt(prompt)
                    task.wait(0.3 + (math.random() * 0.2))
                end
            end)
        end
        task.wait(0.5)
    end
end)

----------------------------------------------------------------
-- [7] ESP BẢO MẬT
----------------------------------------------------------------
local function CreateESP(obj, text, color)
    local t = Instance.new("Folder", SecureFolder)
    local hl = Instance.new("Highlight", t); hl.Adornee = obj; hl.FillColor = color; hl.FillTransparency = 0.7
    local bg = Instance.new("BillboardGui", t); bg.Adornee = obj; bg.Size = UDim2.new(0, 100, 0, 20); bg.AlwaysOnTop = true; bg.StudsOffset = Vector3.new(0, 3, 0)
    local tl = Instance.new("TextLabel", bg); tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1; tl.Text = text; tl.TextColor3 = color; tl.Font = Enum.Font.GothamBold; tl.TextSize = 9
end

task.spawn(function()
    while IsAlive() do
        task.wait(2); SecureFolder:ClearAllChildren()
        if not _G.Config.ESP.Flames and not _G.Config.ESP.Herbs then continue end
        for _, item in pairs(ItemCache) do
            local o = item.o
            if not o or not o.Parent then continue end
            local spec = isSpecial(o.Name)
            if spec == "Flame" and _G.Config.ESP.Flames then CreateESP(o, "🔥 "..o.Name, Color3.new(1, 0.4, 0))
            elseif spec == "Manual" and _G.Config.ESP.Manuals then CreateESP(o, "📖 "..o.Name, Color3.new(1, 0.9, 0))
            elseif o.Parent and o.Parent.Name == "Herbs" and _G.Config.ESP.Herbs then CreateESP(o, "🌿 "..o.Name, Color3.new(0, 1, 0)) end
        end
    end
end)

----------------------------------------------------------------
-- [8] UI CONTROL
----------------------------------------------------------------
toggleFarm.MouseButton1Click:Connect(function()
    _G.Config.Enabled = not _G.Config.Enabled
    toggleFarm.Text = "START V71 COLLECT: " .. (_G.Config.Enabled and "ON" or "OFF")
    toggleFarm.BackgroundColor3 = _G.Config.Enabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 30, 30)
end)

local function addEsp(txt, key)
    local b = createBtn(txt..": OFF", Color3.fromRGB(45, 45, 45), content)
    b.MouseButton1Click:Connect(function()
        _G.Config.ESP[key] = not _G.Config.ESP[key]
        b.Text = txt .. (_G.Config.ESP[key] and ": ON" or ": OFF")
        b.BackgroundColor3 = _G.Config.ESP[key] and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(45, 45, 45)
    end)
end
addEsp("ESP Flames", "Flames"); addEsp("ESP Manuals", "Manuals"); addEsp("ESP Herbs", "Herbs")

minBtn.MouseButton1Click:Connect(function()
    local isMin = (main.Size.Y.Offset < 100)
    content.Visible = isMin
    main:TweenSize(isMin and UDim2.new(0, 260, 0, 420) or UDim2.new(0, 260, 0, 35), "Out", "Quad", 0.3, true)
    minBtn.Text = isMin and "-" or "+"
end)

print("✅ KUMA HUB V82 - PURE V71 LOGIC LOADED")
