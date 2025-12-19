--==============================================================
--  KUMA HUB V73 - FINAL FULL VERSION (STEALTH & OPTIMIZED)
--==============================================================

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")
local TS = game:GetService("TweenService")

-- [DANH SÁCH VẬT PHẨM ĐẶC BIỆT TỪ CODE GỐC]
local flameList = {"Karmic Dao Flame", "Poison Death Flame", "Great River Flame", "Disaster Rose Flame", "Ice Devil Flame", "Azure Moon Flame", "Ruinous Flame", "Earth Flame", "Heaven Flame", "Obsidian Flame", "Bone Chill Flame", "Green Lotus Flame", "Sea Heart Flame", "Volcanic Flame", "Purifying Lotus Demon Flame", "Gold Emperor Burning Sky Flame"}
local manualList = {"Qi Condensation Sutra", "Six Yin Scripture", "Nine Yang Scripture", "Maniac's Cultivation Tips", "Verdant Wind Scripture", "Copper Body Formula", "LotusSutra", "Mother Earth Technique", "Pure Heart Skill", "Heavenly Demon Scripture", "Extreme Sword Sutra", "Principle of Motion", "Shadowless Canon", "Principle of Stillness", "Earth Flame Method", "Steel Body Formula", "Rising Dragon Art", "Soul Shedding Manual", "Star Reaving Scripture", "Return to Basic", "Taotie's Blood Devouring", "Tower Forging", "BeastSoul", "Journey To The West", "Book of Life and Death"}

-- [HỆ THỐNG BẢO MẬT & BỘ NHỚ TẠM]
local ItemCache = {Items = {}}
local SecureFolder = CG:FindFirstChild("KumaSecure_Final") or Instance.new("Folder", CG)
SecureFolder.Name = "Secure_" .. math.random(1000, 9999)

_G.Config = {
    FarmEnabled = false,
    SelectedItems = {},
    Speed = 120,
    MaxDist = 3000, -- Phạm vi an toàn
    ESP = {Flames = false, Manuals = false, Herbs = false, Mobs = false}
}

-- [HÀM TIỆN ÍCH]
local function isTarget(name, list)
    for _, v in pairs(list) do if name:lower() == v:lower() then return true end end
    return false
end

----------------------------------------------------------------
-- HỆ THỐNG GIAO DIỆN (UI) - CÓ THỂ THU NHỎ
----------------------------------------------------------------
if CG:FindFirstChild("KumaV73Final") then CG.KumaV73Final:Destroy() end
local sg = Instance.new("ScreenGui", CG); sg.Name = "KumaV73Final"

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 280, 0, 480); main.Position = UDim2.new(0.1, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BorderSizePixel = 0; main.Active = true; main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -35, 0, 35); title.Text = " 🐉 KUMA HUB V73 - ULTIMATE"; title.BackgroundColor3 = Color3.fromRGB(30, 30, 30); title.TextColor3 = Color3.new(1, 1, 1); title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 35, 0, 35); minBtn.Position = UDim2.new(1, -35, 0, 0); minBtn.Text = "-"; minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); minBtn.TextColor3 = Color3.new(1, 1, 1)

local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, 0, 1, -40); content.Position = UDim2.new(0, 0, 0, 40); content.BackgroundTransparency = 1; content.CanvasSize = UDim2.new(0, 0, 1.8, 0)
Instance.new("UIListLayout", content).Padding = UDim.new(0, 5); Instance.new("UIPadding", content).PaddingLeft = UDim.new(0, 10)

local function createBtn(txt, color, parent)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.95, 0, 0, 35); b.Text = txt; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1, 1, 1); b.BorderSizePixel = 0
    return b
end

local toggleFarm = createBtn("AUTO FARM: OFF", Color3.fromRGB(120, 30, 30), content)
local scanBtn = createBtn("🔄 SCAN AREA (LẤY DANH SÁCH)", Color3.fromRGB(30, 100, 200), content)

local scroll = Instance.new("ScrollingFrame", content)
scroll.Size = UDim2.new(0.95, 0, 0, 150); scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 25); scroll.BorderSizePixel = 0
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 3)

local function createEspBtn(txt, key)
    local b = createBtn(txt .. ": OFF", Color3.fromRGB(50, 50, 50), content)
    b.MouseButton1Click:Connect(function()
        _G.Config.ESP[key] = not _G.Config.ESP[key]
        b.Text = txt .. (_G.Config.ESP[key] and ": ON" or ": OFF")
        b.BackgroundColor3 = _G.Config.ESP[key] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    end)
end

createEspBtn("ESP Flames", "Flames")
createEspBtn("ESP Manuals", "Manuals")
createEspBtn("ESP Herbs", "Herbs")
createEspBtn("ESP Mobs", "Mobs")

----------------------------------------------------------------
-- HỆ THỐNG DI CHUYỂN MƯỢT (SMOOTH STEALTH MOVE)
----------------------------------------------------------------
local function SmoothMove(targetPart, isMob)
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetPart or not targetPart.Parent then return end

    local offset = isMob and Vector3.new(0, 0, 4) or Vector3.new(0, 2.5, 0)
    local targetPos = targetPart.Position + offset
    local reached = false
    
    local bv = Instance.new("BodyVelocity", hrp)
    bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)

    -- Noclip
    local nc = RS.Stepped:Connect(function()
        for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end)

    local connection
    connection = RS.Heartbeat:Connect(function(dt)
        if not _G.Config.FarmEnabled or not targetPart.Parent then connection:Disconnect(); return end
        local diff = targetPos - hrp.Position
        if diff.Magnitude < 1.5 then
            reached = true; connection:Disconnect()
        else
            -- Vận tốc ngẫu nhiên để chống Bot-check
            local s = (_G.Config.Speed + math.random(-5, 8)) * dt
            hrp.CFrame = CFrame.lookAt(hrp.Position + (diff.Unit * math.min(s, diff.Magnitude)), targetPart.Position)
        end
    end)

    repeat task.wait() until reached or not _G.Config.FarmEnabled
    nc:Disconnect(); bv:Destroy()
end

----------------------------------------------------------------
-- SMART SCAN AREA (QUÉT PHÂN LOẠI)
----------------------------------------------------------------
local function ScanArea()
    ItemCache.Items = {}
    for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end

    local all = workspace:GetDescendants()
    local foundNames = {}

    for i, v in ipairs(all) do
        local isSpecial = isTarget(v.Name, flameList) or isTarget(v.Name, manualList)
        local isHerb = v.Parent and v.Parent.Name == "Herbs"
        local isMob = v:IsA("Humanoid") and v.Parent ~= LP.Character

        if (isSpecial or isHerb) and v:FindFirstChildWhichIsA("ProximityPrompt", true) then
            local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart", true)
            if part then
                table.insert(ItemCache.Items, {o = v, p = v:FindFirstChildWhichIsA("ProximityPrompt", true), type = "Item"})
                if not foundNames[v.Name] then
                    foundNames[v.Name] = true
                    local b = createBtn(v.Name, Color3.fromRGB(40,40,40), scroll)
                    b.Size = UDim2.new(1, -10, 0, 30)
                    b.MouseButton1Click:Connect(function()
                        if not table.find(_G.Config.SelectedItems, v.Name) then
                            table.insert(_G.Config.SelectedItems, v.Name); b.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
                        else
                            for idx, n in pairs(_G.Config.SelectedItems) do if n == v.Name then table.remove(_G.Config.SelectedItems, idx) end end
                            b.BackgroundColor3 = Color3.fromRGB(40,40,40)
                        end
                    end)
                end
            end
        elseif isMob and v.Health > 0 then
            table.insert(ItemCache.Items, {o = v.Parent, type = "Mob"})
            if not foundNames[v.Parent.Name] then
                foundNames[v.Parent.Name] = true
                local b = createBtn(v.Parent.Name, Color3.fromRGB(60,20,20), scroll)
                b.Size = UDim2.new(1, -10, 0, 30)
                b.MouseButton1Click:Connect(function()
                    if not table.find(_G.Config.SelectedItems, v.Parent.Name) then
                        table.insert(_G.Config.SelectedItems, v.Parent.Name); b.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
                    else
                        for idx, n in pairs(_G.Config.SelectedItems) do if n == v.Parent.Name then table.remove(_G.Config.SelectedItems, idx) end end
                        b.BackgroundColor3 = Color3.fromRGB(60,20,20)
                    end
                end)
            end
        end
        if i % 1000 == 0 then task.wait() end
    end
end

scanBtn.MouseButton1Click:Connect(ScanArea)

----------------------------------------------------------------
-- STEALTH ESP (ANTI-BAN VISUALS)
----------------------------------------------------------------
local function CreateESP(obj, text, color)
    local tag = Instance.new("Folder", SecureFolder)
    local hl = Instance.new("Highlight", tag); hl.Adornee = obj; hl.FillColor = color; hl.FillTransparency = 0.7
    local bg = Instance.new("BillboardGui", tag); bg.Adornee = obj; bg.Size = UDim2.new(0, 100, 0, 20); bg.AlwaysOnTop = true; bg.StudsOffset = Vector3.new(0, 3, 0)
    local tl = Instance.new("TextLabel", bg); tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1; tl.Text = text; tl.TextColor3 = color; tl.Font = Enum.Font.GothamBold; tl.TextSize = 10
end

task.spawn(function()
    while true do
        task.wait(2)
        SecureFolder:ClearAllChildren()
        if not _G.Config.FarmEnabled and not _G.Config.ESP.Flames and not _G.Config.ESP.Mobs then continue end

        for _, item in pairs(ItemCache.Items) do
            local obj = item.o
            if not obj or not obj.Parent then continue end
            
            if item.type == "Item" then
                if _G.Config.ESP.Flames and isTarget(obj.Name, flameList) then
                    CreateESP(obj, "🔥 "..obj.Name, Color3.new(1, 0.5, 0))
                elseif _G.Config.ESP.Manuals and isTarget(obj.Name, manualList) then
                    CreateESP(obj, "📖 "..obj.Name, Color3.new(1, 0.9, 0))
                elseif _G.Config.ESP.Herbs and obj.Parent.Name == "Herbs" then
                    CreateESP(obj, "🌿 "..obj.Name, Color3.new(0, 1, 0))
                end
            elseif item.type == "Mob" and _G.Config.ESP.Mobs then
                if obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                    CreateESP(obj, "💀 "..obj.Name, Color3.new(1, 0, 0))
                end
            end
        end
    end
end)

----------------------------------------------------------------
-- VÒNG LẶP FARM (PRIORITY SYSTEM)
----------------------------------------------------------------
task.spawn(function()
    while true do
        if _G.Config.FarmEnabled and #_G.Config.SelectedItems > 0 then
            pcall(function()
                local hrp = LP.Character.HumanoidRootPart
                local target, prompt, isMob = nil, nil, false
                local dist = _G.Config.MaxDist

                -- [LOGIC ƯU TIÊN]
                -- 1. Tìm Lửa/Sách/Cỏ trước
                for _, item in pairs(ItemCache.Items) do
                    if item.type == "Item" and table.find(_G.Config.SelectedItems, item.o.Name) then
                        local part = item.o:IsA("BasePart") and item.o or item.o:FindFirstChildWhichIsA("BasePart", true)
                        if part and part.Parent then
                            local d = (part.Position - hrp.Position).Magnitude
                            if d < dist then dist = d; target = part; prompt = item.p end
                        end
                    end
                end

                -- 2. Nếu không thấy đồ, tìm Quái
                if not target then
                    for _, item in pairs(ItemCache.Items) do
                        if item.type == "Mob" and table.find(_G.Config.SelectedItems, item.o.Name) then
                            local mob = item.o
                            if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                                local d = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
                                if d < dist then dist = d; target = mob.HumanoidRootPart; isMob = true end
                            end
                        end
                    end
                end

                -- [DI CHUYỂN]
                if target then
                    SmoothMove(target, isMob)
                    if isMob then
                        local tool = LP.Character:FindFirstChildWhichIsA("Tool") or LP.Backpack:FindFirstChildWhichIsA("Tool")
                        if tool then 
                            if tool.Parent == LP.Backpack then LP.Character.Humanoid:EquipTool(tool) end
                            tool:Activate() 
                        end
                    else
                        task.wait(0.1 + math.random()*0.2)
                        if prompt then fireproximityprompt(prompt) end
                        task.wait(0.2)
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- Nút Thu nhỏ UI
local isMin = false
minBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    content.Visible = not isMin
    main:TweenSize(isMin and UDim2.new(0, 280, 0, 35) or UDim2.new(0, 280, 0, 480), "Out", "Quad", 0.3, true)
    minBtn.Text = isMin and "+" or "-"
end)

toggleFarm.MouseButton1Click:Connect(function()
    _G.Config.FarmEnabled = not _G.Config.FarmEnabled
    toggleFarm.Text = "AUTO FARM: " .. (_G.Config.FarmEnabled and "ON" or "OFF")
    toggleFarm.BackgroundColor3 = _G.Config.FarmEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(120, 30, 30)
end)

print("✅ KUMA HUB V73 LOADED!")
