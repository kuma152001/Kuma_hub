--==============================================================
--  HERB COLLECTOR V68 (STEALTH ESP + ANTI-BAN + SMOOTH FARM)
--==============================================================

local LP = game:GetService("Players").LocalPlayer
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")

-- [HỆ THỐNG BẢO MẬT ESP]
local SecureFolder = CG:FindFirstChild("KumaSecureESP")
if SecureFolder then SecureFolder:Destroy() end
SecureFolder = Instance.new("Folder", CG)
SecureFolder.Name = tostring(math.random(100000, 999999)) -- Tên ngẫu nhiên

-- [CẤU HÌNH HỆ THỐNG]
_G.AutoEnabled = false
_G.SelectedHerbs = {} 
_G.Speed = 120
_G.ESP_Enabled = {
    Flames = false,
    Manuals = false,
    Age10 = false,
    Age100 = false,
    Age1000 = false
}

local flameList = {"Karmic Dao Flame", "Poison Death Flame", "Great River Flame", "Disaster Rose Flame", "Ice Devil Flame", "Azure Moon Flame", "Ruinous Flame", "Earth Flame", "Heaven Flame", "Obsidian Flame", "Bone Chill Flame", "Green Lotus Flame", "Sea Heart Flame", "Volcanic Flame", "Purifying Lotus Demon Flame", "Gold Emperor Burning Sky Flame"}
local manualList = {"Qi Condensation Sutra", "Six Yin Scripture", "Nine Yang Scripture", "Maniac's Cultivation Tips", "Verdant Wind Scripture", "Copper Body Formula", "LotusSutra", "Mother Earth Technique", "Pure Heart Skill", "Heavenly Demon Scripture", "Extreme Sword Sutra", "Principle of Motion", "Shadowless Canon", "Principle of Stillness", "Earth Flame Method", "Steel Body Formula", "Rising Dragon Art", "Soul Shedding Manual", "Star Reaving Scripture", "Return to Basic", "Taotie's Blood Devouring", "Tower Forging", "BeastSoul", "Journey To The West", "Book of Life and Death"}

local function isTarget(name, list)
    for _, v in pairs(list) do if name:lower() == v:lower() then return true end end
    return false
end

-- [1] GIAO DIỆN V68
if CG:FindFirstChild("KumaV68") then CG.KumaV68:Destroy() end
local sg = Instance.new("ScreenGui", CG); sg.Name = "KumaV68"

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 260, 0, 480); main.Position = UDim2.new(0.1, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20); main.BorderSizePixel = 0; main.Active = true; main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -30, 0, 30); title.Text = " KUMA HUB V68 - STEALTH"; title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.TextColor3 = Color3.new(1, 1, 1); title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(1, -30, 0, 0)
minBtn.Text = "-"; minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); minBtn.TextColor3 = Color3.new(1, 1, 1)

local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, 0, 1, -35); content.Position = UDim2.new(0, 0, 0, 35)
content.BackgroundTransparency = 1; content.CanvasSize = UDim2.new(0, 0, 1.5, 0)

local uiList = Instance.new("UIListLayout", content)
uiList.Padding = UDim.new(0, 5); uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createBtn(txt, color, parent)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.9, 0, 0, 35); b.Text = txt; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1, 1, 1); b.BorderSizePixel = 0
    return b
end

local toggleFarm = createBtn("AUTO FARM: OFF", Color3.fromRGB(150, 0, 0), content)
local refreshBtn = createBtn("🔄 QUÉT DANH SÁCH CỎ", Color3.fromRGB(0, 100, 200), content)

local scroll = Instance.new("ScrollingFrame", content)
scroll.Size = UDim2.new(0.9, 0, 0, 120); scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30); scroll.BorderSizePixel = 0
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 3)

local espTitle = Instance.new("TextLabel", content)
espTitle.Size = UDim2.new(0.9, 0, 0, 25); espTitle.Text = "--- STEALTH ESP ---"; espTitle.BackgroundTransparency = 1; espTitle.TextColor3 = Color3.new(0.6, 0.6, 0.6)

local espFlame = createBtn("ESP Flames: OFF", Color3.fromRGB(50, 50, 50), content)
local espManual = createBtn("ESP Manuals: OFF", Color3.fromRGB(50, 50, 50), content)
local esp10 = createBtn("ESP Herb 10Y: OFF", Color3.fromRGB(50, 50, 50), content)
local esp100 = createBtn("ESP Herb 100Y: OFF", Color3.fromRGB(50, 50, 50), content)
local esp1000 = createBtn("ESP Herb 1000Y: OFF", Color3.fromRGB(50, 50, 50), content)

----------------------------------------------------------------
-- LOGIC ESP BẢO MẬT (ANTI-BAN)
----------------------------------------------------------------
local function CreateSecureESP(target, text, color)
    -- Tạo container trong CoreGui thay vì trong Target
    local espTag = Instance.new("Folder", SecureFolder)
    espTag.Name = "Tag_" .. tostring(target:GetDebugId())
    
    -- Highlight (Adornee trỏ tới target)
    local hl = Instance.new("Highlight", espTag)
    hl.Adornee = target
    hl.FillColor = color; hl.OutlineColor = color; hl.FillTransparency = 0.6
    
    -- BillboardGui (Adornee trỏ tới target)
    local bg = Instance.new("BillboardGui", espTag)
    bg.Adornee = target
    bg.Size = UDim2.new(0, 150, 0, 30); bg.AlwaysOnTop = true; bg.StudsOffset = Vector3.new(0, 3, 0)
    
    local tl = Instance.new("TextLabel", bg)
    tl.Size = UDim2.new(1, 0, 1, 0); tl.BackgroundTransparency = 1; tl.Text = text
    tl.TextColor3 = color; tl.Font = Enum.Font.GothamBold; tl.TextSize = 11
end

task.spawn(function()
    while true do
        task.wait(1.5) -- Quét mỗi 1.5s
        SecureFolder:ClearAllChildren() -- Dọn dẹp sạch để quét mới
        
        if not (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")) then continue end

        -- Quét vật phẩm đặc biệt
        for _, obj in pairs(workspace:GetChildren()) do
            if _G.ESP_Enabled.Flames and isTarget(obj.Name, flameList) then
                CreateSecureESP(obj, "🔥 "..obj.Name, Color3.fromRGB(255, 80, 0))
            end
            if _G.ESP_Enabled.Manuals and isTarget(obj.Name, manualList) then
                CreateSecureESP(obj, "📖 "..obj.Name, Color3.fromRGB(255, 215, 0))
            end
        end

        -- Quét Cỏ
        local herbFolder = workspace:FindFirstChild("Herbs")
        if herbFolder then
            for _, herb in pairs(herbFolder:GetChildren()) do
                local age = herb:GetAttribute("Age") or 0
                if _G.ESP_Enabled.Age1000 and age >= 1000 then
                    CreateSecureESP(herb, herb.Name.." [1000Y]", Color3.fromRGB(255, 0, 255))
                elseif _G.ESP_Enabled.Age100 and age >= 100 then
                    CreateSecureESP(herb, herb.Name.." [100Y]", Color3.fromRGB(0, 200, 255))
                elseif _G.ESP_Enabled.Age10 and age >= 10 then
                    CreateSecureESP(herb, herb.Name.." [10Y]", Color3.new(1, 1, 1))
                end
            end
        end
    end
end)

----------------------------------------------------------------
-- ĐIỀU KHIỂN & DI CHUYỂN (SMOOTH)
----------------------------------------------------------------
local function setupToggle(btn, key, label)
    btn.MouseButton1Click:Connect(function()
        _G.ESP_Enabled[key] = not _G.ESP_Enabled[key]
        btn.Text = label .. (_G.ESP_Enabled[key] and ": ON" or ": OFF")
        btn.BackgroundColor3 = _G.ESP_Enabled[key] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    end)
end

setupToggle(espFlame, "Flames", "ESP Flames")
setupToggle(espManual, "Manuals", "ESP Manuals")
setupToggle(esp10, "Age10", "ESP Herb 10Y")
setupToggle(esp100, "Age100", "ESP Herb 100Y")
setupToggle(esp1000, "Age1000", "ESP Herb 1000Y")

minBtn.MouseButton1Click:Connect(function()
    local isMin = (main.Size.Y.Offset < 100)
    content.Visible = isMin
    main:TweenSize(isMin and UDim2.new(0, 260, 0, 480) or UDim2.new(0, 260, 0, 30), "Out", "Quad", 0.3, true)
    minBtn.Text = isMin and "-" or "+"
end)

toggleFarm.MouseButton1Click:Connect(function()
    _G.AutoEnabled = not _G.AutoEnabled
    toggleFarm.Text = "AUTO FARM: " .. (_G.AutoEnabled and "ON" or "OFF")
    toggleFarm.BackgroundColor3 = _G.AutoEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

refreshBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local src = workspace:FindFirstChild("Herbs") and workspace.Herbs:GetChildren() or workspace:GetChildren()
    local found = {}
    for _, o in ipairs(src) do
        local p = o:FindFirstChildWhichIsA("ProximityPrompt", true)
        if p and not table.find(found, o.Name) then
            table.insert(found, o.Name)
            local b = createBtn(o.Name, Color3.fromRGB(45,45,45), scroll)
            b.Size = UDim2.new(1, -10, 0, 30)
            b.MouseButton1Click:Connect(function()
                if not table.find(_G.SelectedHerbs, o.Name) then
                    table.insert(_G.SelectedHerbs, o.Name); b.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
                else
                    for i, v in pairs(_G.SelectedHerbs) do if v == o.Name then table.remove(_G.SelectedHerbs, i) end end
                    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
                end
            end)
        end
    end
end)

local function Move(targetPart)
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, v in pairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    local bv = Instance.new("BodyVelocity", hrp); bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    local tween = TS:Create(hrp, TweenInfo.new((hrp.Position - targetPart.Position).Magnitude/_G.Speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 3, 0))})
    tween:Play(); tween.Completed:Wait(); bv:Destroy()
end

task.spawn(function()
    while true do
        if _G.AutoEnabled and #_G.SelectedHerbs > 0 then
            pcall(function()
                local cp, co; local d = 2000
                for _, name in pairs(_G.SelectedHerbs) do
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj.Name == name then
                            local p = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                            local o = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                            if p and o then
                                local dist = (o.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                                if dist < d then d = dist; cp = p; co = o end
                            end
                        end
                    end
                end
                if cp and co then Move(co); task.wait(0.2); fireproximityprompt(cp); task.wait(0.5) end
            end)
        end
        task.wait(1)
    end
end)
