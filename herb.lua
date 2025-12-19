--==============================================================
--  KUMA HUB V79 - GHOST EDITION (ITEM ONLY - NO COMBAT CODE)
--==============================================================

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

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")
local TS = game:GetService("TweenService")

local flameList = {"Karmic Dao Flame", "Poison Death Flame", "Great River Flame", "Disaster Rose Flame", "Ice Devil Flame", "Azure Moon Flame", "Ruinous Flame", "Earth Flame", "Heaven Flame", "Obsidian Flame", "Bone Chill Flame", "Green Lotus Flame", "Sea Heart Flame", "Volcanic Flame", "Purifying Lotus Demon Flame", "Gold Emperor Burning Sky Flame"}
local manualList = {"Qi Condensation Sutra", "Six Yin Scripture", "Nine Yang Scripture", "Maniac's Cultivation Tips", "Verdant Wind Scripture", "Copper Body Formula", "LotusSutra", "Mother Earth Technique", "Pure Heart Skill", "Heavenly Demon Scripture", "Extreme Sword Sutra", "Principle of Motion", "Shadowless Canon", "Principle of Stillness", "Earth Flame Method", "Steel Body Formula", "Rising Dragon Art", "Soul Shedding Manual", "Star Reaving Scripture", "Return to Basic", "Taotie's Blood Devouring", "Tower Forging", "BeastSoul", "Journey To The West", "Book of Life and Death"}

_G.Config = {
    Enabled = false,
    Selected = {},
    Speed = 115,
    MaxDist = 3000,
    ESP = {Flames = false, Manuals = false, Herbs = false}
}

local ItemCache = {Items = {}}
local SecureFolder = Instance.new("Folder", CG)
SecureFolder.Name = "SafeVisuals_" .. math.random(100, 999)

local function isTarget(name, list)
    local n = name:lower()
    for _, v in pairs(list) do if n == v:lower() then return true end end
    return false
end

local sg = Instance.new("ScreenGui", CG); sg.Name = "KumaV79"
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 260, 0, 420); main.Position = UDim2.new(0.05, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BorderSizePixel = 0; main.Active = true; main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -35, 0, 35); title.Text = " 👻 KUMA HUB V79 - GHOST"; title.BackgroundColor3 = Color3.fromRGB(30, 30, 30); title.TextColor3 = Color3.new(1, 1, 1); title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 35, 0, 35); minBtn.Position = UDim2.new(1, -35, 0, 0); minBtn.Text = "-"; minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); minBtn.TextColor3 = Color3.new(1, 1, 1)

local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, 0, 1, -40); content.Position = UDim2.new(0, 0, 0, 40); content.BackgroundTransparency = 1; content.CanvasSize = UDim2.new(0, 0, 2, 0)
Instance.new("UIListLayout", content).Padding = UDim.new(0, 7); Instance.new("UIPadding", content).PaddingLeft = UDim.new(0, 10)

local function createBtn(txt, color, parent)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.95, 0, 0, 35); b.Text = txt; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1, 1, 1); b.BorderSizePixel = 0; return b
end

local toggleFarm = createBtn("START GHOST FARM: OFF", Color3.fromRGB(120, 30, 30), content)
local scanBtn = createBtn("🔄 SCAN ITEMS ONLY", Color3.fromRGB(30, 100, 200), content)

local scroll = Instance.new("ScrollingFrame", content)
scroll.Size = UDim2.new(0.95, 0, 0, 150); scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 25); scroll.BorderSizePixel = 0
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 3)

local function GhostMove(targetPart)
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetPart or not targetPart.Parent then return end
    local targetPos = targetPart.Position + Vector3.new(0, 2.8, 0)
    local reached = false
    local bv = Instance.new("BodyVelocity", hrp); bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    local conn
    conn = RS.Heartbeat:Connect(function(dt)
        if not IsAlive() or not _G.Config.Enabled or not targetPart.Parent then conn:Disconnect(); return end
        local diff = targetPos - hrp.Position
        if diff.Magnitude < 1.5 then reached = true; conn:Disconnect()
        else
            local s = (_G.Config.Speed + math.random(-3, 6)) * dt
            hrp.CFrame = CFrame.lookAt(hrp.Position + (diff.Unit * math.min(s, diff.Magnitude)), targetPart.Position)
            for _, p in pairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end
    end)
    repeat task.wait() until reached or not IsAlive() or not _G.Config.Enabled
    if bv then bv:Destroy() end
end

local function ScanArea()
    ItemCache.Items = {}
    for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local all = workspace:GetDescendants()
    local foundNames = {}
    for i, v in ipairs(all) do
        if not IsAlive() then break end
        local prompt = v:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            table.insert(ItemCache.Items, {o = v, p = prompt})
            if not foundNames[v.Name] then
                foundNames[v.Name] = true
                local b = createBtn(v.Name, Color3.fromRGB(45, 45, 45), scroll)
                b.Size = UDim2.new(1, -10, 0, 30)
                b.MouseButton1Click:Connect(function()
                    local idx = table.find(_G.Config.Selected, v.Name)
                    if not idx then table.insert(_G.Config.Selected, v.Name); b.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                    else for i2, n in pairs(_G.Config.Selected) do if n == v.Name then table.remove(_G.Config.Selected, i2) end end b.BackgroundColor3 = Color3.fromRGB(45, 45, 45) end
                end)
            end
        end
        if i % 1000 == 0 then task.wait() end
    end
end
scanBtn.MouseButton1Click:Connect(ScanArea)

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
                if target then GhostMove(target); task.wait(0.2 + math.random()*0.3); if prompt then fireproximityprompt(prompt) end; task.wait(0.4) end
            end)
        end
        task.wait(0.6)
    end
end)

local function CreateESP(obj, text, color)
    local t = Instance.new("Folder", SecureFolder)
    local hl = Instance.new("Highlight", t); hl.Adornee = obj; hl.FillColor = color; hl.FillTransparency = 0.7
    local bg = Instance.new("BillboardGui", t); bg.Adornee = obj; bg.Size = UDim2.new(0, 100, 0, 20); bg.AlwaysOnTop = true; bg.StudsOffset = Vector3.new(0, 3, 0)
    local tl = Instance.new("TextLabel", bg); tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1; tl.Text = text; tl.TextColor3 = color; tl.Font = Enum.Font.GothamBold; tl.TextSize = 10
end

task.spawn(function()
    while IsAlive() do
        task.wait(2); SecureFolder:ClearAllChildren()
        if not _G.Config.ESP.Flames and not _G.Config.ESP.Herbs then continue end
        for _, item in pairs(ItemCache.Items) do
            local o = item.o
            if isTarget(o.Name, flameList) and _G.Config.ESP.Flames then CreateESP(o, "🔥 "..o.Name, Color3.new(1, 0.5, 0))
            elseif isTarget(o.Name, manualList) and _G.Config.ESP.Manuals then CreateESP(o, "📖 "..o.Name, Color3.new(1, 1, 0))
            elseif o.Parent and o.Parent.Name == "Herbs" and _G.Config.ESP.Herbs then CreateESP(o, "🌿 "..o.Name, Color3.new(0, 1, 0)) end
        end
    end
end)

toggleFarm.MouseButton1Click:Connect(function()
    _G.Config.Enabled = not _G.Config.Enabled
    toggleFarm.Text = "START GHOST FARM: " .. (_G.Config.Enabled and "ON" or "OFF")
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

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    main:TweenSize(minimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 420), "Out", "Quad", 0.3, true)
    minBtn.Text = minimized and "+" or "-"
end)

print("✅ KUMA HUB V79 LOADED")
