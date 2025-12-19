--==============================================================
--  KUMA HUB V88 - HYPER OPTIMIZED (ANTI-LAG + PERSISTENT ESP)
--==============================================================

-- [1] HỆ THỐNG DỌN DẸP
local ScriptID = tick()
_G.KumaInstanceID = ScriptID
local function IsAlive() return _G.KumaInstanceID == ScriptID end

pcall(function()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name:find("Kuma") or v.Name:find("Secure") then v:Destroy() end
    end
end)

-- [2] SERVICES & DATA
local LP = game:GetService("Players").LocalPlayer
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")

local function toLookup(list)
    local t = {}
    for _, v in pairs(list) do t[v] = true end
    return t
end

local flames = toLookup({"Karmic Dao Flame", "Poison Death Flame", "Great River Flame", "Disaster Rose Flame", "Ice Devil Flame", "Azure Moon Flame", "Ruinous Flame", "Earth Flame", "Heaven Flame", "Obsidian Flame", "Bone Chill Flame", "Green Lotus Flame", "Sea Heart Flame", "Volcanic Flame", "Purifying Lotus Demon Flame", "Gold Emperor Burning Sky Flame"})
local manuals = toLookup({"Qi Condensation Sutra", "Six Yin Scripture", "Nine Yang Scripture", "Maniac's Cultivation Tips", "Verdant Wind Scripture", "Copper Body Formula", "LotusSutra", "Mother Earth Technique", "Pure Heart Skill", "Heavenly Demon Scripture", "Extreme Sword Sutra", "Principle of Motion", "Shadowless Canon", "Principle of Stillness", "Earth Flame Method", "Steel Body Formula", "Rising Dragon Art", "Soul Shedding Manual", "Star Reaving Scripture", "Return to Basic", "Taotie's Blood Devouring", "Tower Forging", "BeastSoul", "Journey To The West", "Book of Life and Death"})

_G.Config = {
    Enabled = false,
    Selected = {},
    Speed = 125,
    ESP = { Flames = false, Manuals = false, Age10 = false, Age100 = false, Age1000 = false }
}

local ItemCache = {} 
local SecureFolder = CG:FindFirstChild("KumaSecure_V88") or Instance.new("Folder", CG)
SecureFolder.Name = "KumaSecure_V88"

----------------------------------------------------------------
-- [3] HÀM MOVE V69 (SIÊU MƯỢT)
----------------------------------------------------------------
local function MoveV69(targetPart)
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetPart or not targetPart.Parent then return end
    
    local targetPos = targetPart.Position + Vector3.new(0, 3, 0)
    if (hrp.Position - targetPos).Magnitude < 2 then return end -- Đã ở gần thì không Move nữa

    local bv = Instance.new("BodyVelocity", hrp)
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)

    -- Noclip 
    local nc = RS.Stepped:Connect(function()
        if LP.Character then
            for _, v in pairs(LP.Character:GetDescendants()) do 
                if v:IsA("BasePart") then v.CanCollide = false end 
            end
        end
    end)

    local dist = (hrp.Position - targetPos).Magnitude
    local tween = TS:Create(hrp, TweenInfo.new(dist/_G.Config.Speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
    tween:Play()
    tween.Completed:Wait()
    
    nc:Disconnect()
    bv:Destroy()
end

----------------------------------------------------------------
-- [4] GIAO DIỆN (CHIA NHÓM ĐỒ)
----------------------------------------------------------------
local sg = Instance.new("ScreenGui", CG); sg.Name = "KumaV88"
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 260, 0, 420); main.Position = UDim2.new(0.05, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BorderSizePixel = 0; main.Active = true; main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -35, 0, 35); title.Text = " 🐉 KUMA V88 - HYPER SMOOTH"; title.BackgroundColor3 = Color3.fromRGB(30, 30, 30); title.TextColor3 = Color3.new(1, 1, 1); title.TextXAlignment = Enum.TextXAlignment.Left

local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, 0, 1, -40); content.Position = UDim2.new(0, 0, 0, 40); content.BackgroundTransparency = 1; content.CanvasSize = UDim2.new(0, 0, 3, 0)
Instance.new("UIListLayout", content).Padding = UDim.new(0, 5); Instance.new("UIPadding", content).PaddingLeft = UDim.new(0, 10)

local toggleFarm = Instance.new("TextButton", content)
toggleFarm.Size = UDim2.new(0.92, 0, 0, 40); toggleFarm.Text = "AUTO FARM: OFF"; toggleFarm.BackgroundColor3 = Color3.fromRGB(120, 30, 30); toggleFarm.TextColor3 = Color3.new(1,1,1); toggleFarm.BorderSizePixel = 0

local function createGroup(label, height)
    Instance.new("TextLabel", content).Text = "--- " .. label .. " ---"; content.TextLabel.Size = UDim2.new(0.9, 0, 0, 20); content.TextLabel.BackgroundTransparency = 1; content.TextLabel.TextColor3 = Color3.new(0.6,0.6,0.6)
    local sc = Instance.new("ScrollingFrame", content); sc.Size = UDim2.new(0.92, 0, 0, height); sc.BackgroundColor3 = Color3.fromRGB(25, 25, 25); sc.BorderSizePixel = 0
    Instance.new("UIListLayout", sc).Padding = UDim.new(0, 2); return sc
end

local gFlame = createGroup("CHỌN LỬA", 80); local gManual = createGroup("CHỌN SÁCH", 80); local gHerb = createGroup("CHỌN CỎ", 80)

local function fillList(list, parent, color)
    local sorted = {} for n in pairs(list) do table.insert(sorted, n) end
    table.sort(sorted)
    for _, name in pairs(sorted) do
        local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1, -10, 0, 28); b.Text = name; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1,1,1); b.BorderSizePixel = 0
        b.MouseButton1Click:Connect(function()
            local idx = table.find(_G.Config.Selected, name)
            if not idx then table.insert(_G.Config.Selected, name); b.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
            else table.remove(_G.Config.Selected, idx); b.BackgroundColor3 = color end
        end)
    end
end

fillList(flames, gFlame, Color3.fromRGB(60, 30, 15))
fillList(manuals, gManual, Color3.fromRGB(60, 50, 15))

task.spawn(function()
    local rep = game.ReplicatedStorage:WaitForChild("Herbs", 5)
    if rep then
        local names = {} for _, v in pairs(rep:GetChildren()) do names[v.Name] = true end
        fillList(names, gHerb, Color3.fromRGB(35, 35, 35))
    end
end)

----------------------------------------------------------------
-- [5] SMART CENTRAL SCANNER (TỐI ƯU HÓA QUÉT)
----------------------------------------------------------------
task.spawn(function()
    while IsAlive() do
        local tempCache = {}
        -- Quét thông minh: Ưu tiên Folder Herbs nếu có để giảm tải
        local herbFolder = workspace:FindFirstChild("Herbs")
        local scanTargets = herbFolder and {herbFolder, workspace} or {workspace}
        
        for _, folder in pairs(scanTargets) do
            local children = folder:GetChildren()
            for i = 1, #children do
                if not IsAlive() then break end
                local v = children[i]
                local prompt = v:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    table.insert(tempCache, {o = v, p = prompt, n = v.Name})
                end
                if i % 200 == 0 then task.wait() end -- Nghỉ ngơi cho CPU
            end
        end
        ItemCache = tempCache
        task.wait(4) 
    end
end)

----------------------------------------------------------------
-- [6] FARM LOOP
----------------------------------------------------------------
task.spawn(function()
    while IsAlive() do
        if _G.Config.Enabled and #_G.Config.Selected > 0 then
            pcall(function()
                local hrp = LP.Character.HumanoidRootPart
                local target, prompt; local d = 4000
                for i = 1, #ItemCache do
                    local item = ItemCache[i]
                    if table.find(_G.Config.Selected, item.n) and item.o.Parent then
                        local o = item.o:IsA("BasePart") and item.o or item.o:FindFirstChildWhichIsA("BasePart", true)
                        if o then
                            local dist = (o.Position - hrp.Position).Magnitude
                            if dist < d then d = dist; target = o; prompt = item.p end
                        end
                    end
                end
                if target then MoveV69(target); fireproximityprompt(prompt); task.wait(0.2) end
            end)
        end
        task.wait(0.5)
    end
end)

----------------------------------------------------------------
-- [7] HỆ THỐNG ESP (PERSISTENT - KHÔNG LAG)
----------------------------------------------------------------
local function UpdateESP(obj, text, color)
    local id = tostring(obj:GetDebugId())
    local tag = SecureFolder:FindFirstChild(id)
    
    if not tag then
        tag = Instance.new("Folder", SecureFolder); tag.Name = id
        local hl = Instance.new("Highlight", tag); hl.Adornee = obj; hl.FillColor = color; hl.FillTransparency = 0.7
        local bg = Instance.new("BillboardGui", tag); bg.Adornee = obj; bg.Size = UDim2.new(0, 100, 0, 20); bg.AlwaysOnTop = true; bg.StudsOffset = Vector3.new(0, 3, 0)
        local tl = Instance.new("TextLabel", bg); tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1; tl.Text = text; tl.TextColor3 = color; tl.Font = Enum.Font.GothamBold; tl.TextSize = 10
    end
end

task.spawn(function()
    while IsAlive() do
        -- Xóa ESP của các vật phẩm không còn tồn tại hoặc bị tắt nút
        for _, tag in pairs(SecureFolder:GetChildren()) do
            local found = false
            for _, item in pairs(ItemCache) do
                if tostring(item.o:GetDebugId()) == tag.Name then found = true; break end
            end
            if not found then tag:Destroy() end
        end

        -- Cập nhật ESP mới
        for i = 1, #ItemCache do
            local v = ItemCache[i].o
            if not v.Parent then continue end
            local age = v:GetAttribute("Age") or 0
            
            if flames[v.Name] and _G.Config.ESP.Flames then 
                UpdateESP(v, "🔥 "..v.Name, Color3.new(1, 0.4, 0))
            elseif manuals[v.Name] and _G.Config.ESP.Manuals then 
                UpdateESP(v, "📖 "..v.Name, Color3.new(1, 1, 0))
            elseif v.Parent.Name == "Herbs" or herbFolder then
                if _G.Config.ESP.Age1000 and age >= 1000 then UpdateESP(v, v.Name.." [1000Y]", Color3.new(1, 0, 1))
                elseif _G.Config.ESP.Age100 and age >= 100 then UpdateESP(v, v.Name.." [100Y]", Color3.new(0, 0.8, 1))
                elseif _G.Config.ESP.Age10 and age >= 10 then UpdateESP(v, v.Name.." [10Y]", Color3.new(1, 1, 1)) end
            end
            if i % 100 == 0 then task.wait() end
        end
        task.wait(1.5)
    end
end)

----------------------------------------------------------------
-- [8] UI TOGGLES
----------------------------------------------------------------
local function addEspBtn(txt, key)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.new(0.92, 0, 0, 30); b.Text = txt .. ": OFF"; b.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b.TextColor3 = Color3.new(1,1,1); b.BorderSizePixel = 0
    b.MouseButton1Click:Connect(function()
        _G.Config.ESP[key] = not _G.Config.ESP[key]
        b.Text = txt .. (_G.Config.ESP[key] and ": ON" or ": OFF")
        b.BackgroundColor3 = _G.Config.ESP[key] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45)
        if not _G.Config.ESP[key] then SecureFolder:ClearAllChildren() end -- Dọn dẹp khi tắt
    end)
end

toggleFarm.MouseButton1Click:Connect(function()
    _G.Config.Enabled = not _G.Config.Enabled
    toggleFarm.Text = "AUTO FARM: " .. (_G.Config.Enabled and "ON" or "OFF")
    toggleFarm.BackgroundColor3 = _G.Config.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(120, 30, 30)
end)

Instance.new("TextLabel", content).Text = "--- THIẾT LẬP ESP ---"; content.TextLabel.Size = UDim2.new(0.9, 0, 0, 20); content.TextLabel.BackgroundTransparency = 1; content.TextLabel.TextColor3 = Color3.new(0.6,0.6,0.6)
addEspBtn("ESP Flames", "Flames"); addEspBtn("ESP Manuals", "Manuals"); addEspBtn("ESP 10Y", "Age10"); addEspBtn("ESP 100Y", "Age100"); addEspBtn("ESP 1000Y", "Age1000")

print("✅ KUMA HUB V88 - HYPER OPTIMIZED LOADED")
