--==============================================================
--  HERB COLLECTOR V69 (OPTIMIZED - SIÊU MƯỢT - ANTI LAG)
--==============================================================

local LP = game:GetService("Players").LocalPlayer
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")

-- [HỆ THỐNG BẢO MẬT ESP]
local SecureFolder = CG:FindFirstChild("KumaSecureESP") or Instance.new("Folder", CG)
SecureFolder.Name = tostring(math.random(100000, 999999))

-- [CẤU HÌNH HỆ THỐNG]
_G.AutoEnabled = false
_G.SelectedHerbs = {} 
_G.Speed = 120
_G.ESP_Enabled = { Flames = false, Manuals = false, Age10 = false, Age100 = false, Age1000 = false }

-- [TỐI ƯU TABLE LOOKUP] (Tăng tốc độ tìm kiếm gấp 100 lần)
local function toLookup(list)
    local t = {}
    for _, v in pairs(list) do t[v:lower()] = true end
    return t
end

local flameLookup = toLookup({"Karmic Dao Flame", "Poison Death Flame", "Great River Flame", "Disaster Rose Flame", "Ice Devil Flame", "Azure Moon Flame", "Ruinous Flame", "Earth Flame", "Heaven Flame", "Obsidian Flame", "Bone Chill Flame", "Green Lotus Flame", "Sea Heart Flame", "Volcanic Flame", "Purifying Lotus Demon Flame", "Gold Emperor Burning Sky Flame"})
local manualLookup = toLookup({"Qi Condensation Sutra", "Six Yin Scripture", "Nine Yang Scripture", "Maniac's Cultivation Tips", "Verdant Wind Scripture", "Copper Body Formula", "LotusSutra", "Mother Earth Technique", "Pure Heart Skill", "Heavenly Demon Scripture", "Extreme Sword Sutra", "Principle of Motion", "Shadowless Canon", "Principle of Stillness", "Earth Flame Method", "Steel Body Formula", "Rising Dragon Art", "Soul Shedding Manual", "Star Reaving Scripture", "Return to Basic", "Taotie's Blood Devouring", "Tower Forging", "BeastSoul", "Journey To The West", "Book of Life and Death"})

-- [1] GIAO DIỆN V69 (COMPACT)
if CG:FindFirstChild("KumaV69") then CG.KumaV69:Destroy() end
local sg = Instance.new("ScreenGui", CG); sg.Name = "KumaV69"

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 260, 0, 480); main.Position = UDim2.new(0.1, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BorderSizePixel = 0; main.Active = true; main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -30, 0, 30); title.Text = " 🌿 KUMA OPTIMIZED V69"; title.BackgroundColor3 = Color3.fromRGB(30, 30, 30); title.TextColor3 = Color3.new(1, 1, 1); title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(1, -30, 0, 0); minBtn.Text = "-"; minBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); minBtn.TextColor3 = Color3.new(1, 1, 1)

local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, 0, 1, -35); content.Position = UDim2.new(0, 0, 0, 35); content.BackgroundTransparency = 1; content.CanvasSize = UDim2.new(0, 0, 1.4, 0)
Instance.new("UIListLayout", content).Padding = UDim.new(0, 5)

local function createBtn(txt, color, parent)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.94, 0, 0, 35); b.Text = txt; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1, 1, 1); b.BorderSizePixel = 0
    b.AutoButtonColor = true; return b
end

local toggleFarm = createBtn("AUTO FARM: OFF", Color3.fromRGB(130, 20, 20), content)
local refreshBtn = createBtn("🔄 QUÉT DANH SÁCH CỎ", Color3.fromRGB(20, 80, 150), content)

local scroll = Instance.new("ScrollingFrame", content)
scroll.Size = UDim2.new(0.94, 0, 0, 120); scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 25); scroll.BorderSizePixel = 0
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 3)

local espFlame = createBtn("ESP Flames: OFF", Color3.fromRGB(40, 40, 40), content)
local espManual = createBtn("ESP Manuals: OFF", Color3.fromRGB(40, 40, 40), content)
local esp10 = createBtn("ESP 10Y: OFF", Color3.fromRGB(40, 40, 40), content)
local esp100 = createBtn("ESP 100Y: OFF", Color3.fromRGB(40, 40, 40), content)
local esp1000 = createBtn("ESP 1000Y: OFF", Color3.fromRGB(40, 40, 40), content)

----------------------------------------------------------------
-- LOGIC ESP SIÊU NHẸ (LIGHTWEIGHT ESP)
----------------------------------------------------------------
local function CreateSecureESP(target, text, color)
    local espTag = Instance.new("Folder", SecureFolder)
    espTag.Name = "ESP"
    
    local hl = Instance.new("Highlight", espTag)
    hl.Adornee = target; hl.FillColor = color; hl.OutlineColor = Color3.new(1,1,1); hl.FillTransparency = 0.6
    
    local bg = Instance.new("BillboardGui", espTag)
    bg.Adornee = target; bg.Size = UDim2.new(0, 120, 0, 25); bg.AlwaysOnTop = true; bg.StudsOffset = Vector3.new(0, 3, 0)
    
    local tl = Instance.new("TextLabel", bg)
    tl.Size = UDim2.new(1, 0, 1, 0); tl.BackgroundTransparency = 1; tl.Text = text
    tl.TextColor3 = color; tl.Font = Enum.Font.GothamBold; tl.TextSize = 10
end

task.spawn(function()
    while true do
        task.wait(2) -- Tăng thời gian chờ để giảm lag CPU
        SecureFolder:ClearAllChildren()
        
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then continue end

        local allChildren = workspace:GetChildren()
        for i = 1, #allChildren do
            local obj = allChildren[i]
            local nameLow = obj.Name:lower()
            
            if _G.ESP_Enabled.Flames and flameLookup[nameLow] then
                CreateSecureESP(obj, "🔥 "..obj.Name, Color3.fromRGB(255, 80, 0))
            elseif _G.ESP_Enabled.Manuals and manualLookup[nameLow] then
                CreateSecureESP(obj, "📖 "..obj.Name, Color3.fromRGB(255, 215, 0))
            end
            -- Giảm tải mỗi 50 object
            if i % 50 == 0 then task.wait() end 
        end

        local herbFolder = workspace:FindFirstChild("Herbs")
        if herbFolder then
            local herbs = herbFolder:GetChildren()
            for i = 1, #herbs do
                local herb = herbs[i]
                local age = herb:GetAttribute("Age") or 0
                if _G.ESP_Enabled.Age1000 and age >= 1000 then
                    CreateSecureESP(herb, herb.Name.." [1000Y]", Color3.fromRGB(255, 0, 255))
                elseif _G.ESP_Enabled.Age100 and age >= 100 then
                    CreateSecureESP(herb, herb.Name.." [100Y]", Color3.fromRGB(0, 200, 255))
                elseif _G.ESP_Enabled.Age10 and age >= 10 then
                    CreateSecureESP(herb, herb.Name.." [10Y]", Color3.new(1, 1, 1))
                end
                if i % 50 == 0 then task.wait() end
            end
        end
    end
end)

----------------------------------------------------------------
-- HÀM DI CHUYỂN MƯỢT (OPTIMIZED MOVE)
----------------------------------------------------------------
local function Move(targetPart)
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetPart then return end
    
    -- Noclip nhẹ
    for _, v in pairs(LP.Character:GetDescendants()) do 
        if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end 
    end

    local bv = Instance.new("BodyVelocity", hrp)
    bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)

    local targetPos = targetPart.Position + Vector3.new(0, 3, 0)
    local dist = (hrp.Position - targetPos).Magnitude
    local tween = TS:Create(hrp, TweenInfo.new(dist/_G.Speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
    
    tween:Play()
    tween.Completed:Wait()
    bv:Destroy()
end

----------------------------------------------------------------
-- ĐIỀU KHIỂN UI
----------------------------------------------------------------
local function setupToggle(btn, key, label)
    btn.MouseButton1Click:Connect(function()
        _G.ESP_Enabled[key] = not _G.ESP_Enabled[key]
        btn.Text = label .. (_G.ESP_Enabled[key] and ": ON" or ": OFF")
        btn.BackgroundColor3 = _G.ESP_Enabled[key] and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(40, 40, 40)
    end)
end

setupToggle(espFlame, "Flames", "ESP Flames")
setupToggle(espManual, "Manuals", "ESP Manuals")
setupToggle(esp10, "Age10", "ESP 10Y")
setupToggle(esp100, "Age100", "ESP 100Y")
setupToggle(esp1000, "Age1000", "ESP 1000Y")

minBtn.MouseButton1Click:Connect(function()
    local isMin = (main.Size.Y.Offset < 100)
    content.Visible = isMin
    main:TweenSize(isMin and UDim2.new(0, 260, 0, 480) or UDim2.new(0, 260, 0, 30), "Out", "Quad", 0.3, true)
    minBtn.Text = isMin and "-" or "+"
end)

toggleFarm.MouseButton1Click:Connect(function()
    _G.AutoEnabled = not _G.AutoEnabled
    toggleFarm.Text = _G.AutoEnabled and "AUTO FARM: ON" or "AUTO FARM: OFF"
    toggleFarm.BackgroundColor3 = _G.AutoEnabled and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(130, 20, 20)
end)

refreshBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local src = workspace:FindFirstChild("Herbs") and workspace.Herbs:GetChildren() or workspace:GetChildren()
    local found = {}
    for _, o in ipairs(src) do
        if o:FindFirstChildWhichIsA("ProximityPrompt", true) and not found[o.Name] then
            found[o.Name] = true
            local b = createBtn(o.Name, Color3.fromRGB(35,35,35), scroll)
            b.Size = UDim2.new(1, -10, 0, 30)
            b.MouseButton1Click:Connect(function()
                local idx = table.find(_G.SelectedHerbs, o.Name)
                if not idx then
                    table.insert(_G.SelectedHerbs, o.Name); b.BackgroundColor3 = Color3.fromRGB(20, 100, 20)
                else
                    table.remove(_G.SelectedHerbs, idx); b.BackgroundColor3 = Color3.fromRGB(35,35,35)
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        if _G.AutoEnabled and #_G.SelectedHerbs > 0 then
            pcall(function()
                local hrpPos = LP.Character.HumanoidRootPart.Position
                local targetP, targetO; local d = 2000
                
                -- Ưu tiên quét trong thư mục Herbs trước để tránh lag
                local searchArea = workspace:FindFirstChild("Herbs") and workspace.Herbs:GetDescendants() or workspace:GetDescendants()
                
                for _, obj in pairs(searchArea) do
                    for _, name in pairs(_G.SelectedHerbs) do
                        if obj.Name == name then
                            local p = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                            local o = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                            if p and o then
                                local dist = (o.Position - hrpPos).Magnitude
                                if dist < d then d = dist; targetP = p; targetO = o end
                            end
                        end
                    end
                end
                if targetP and targetO then 
                    Move(targetO)
                    task.wait(0.2)
                    fireproximityprompt(targetP)
                    task.wait(0.3) 
                end
            end)
        end
        task.wait(1)
    end
end)
