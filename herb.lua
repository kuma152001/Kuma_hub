--==============================================================
--  HERB COLLECTOR V71 (ULTIMATE STEALTH - ANTI BAN - NO LAG)
--==============================================================

local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")

-- [HỆ THỐNG BẢO MẬT & CACHE]
local ScriptID = tick()
_G.KumaInstanceID = ScriptID

local function IsAlive()
    return _G.KumaInstanceID == ScriptID
end

-- Xóa các bản cũ
pcall(function()
    for _, v in pairs(CG:GetChildren()) do
        if v.Name:find("Kuma") or v.Name:find("Secure") then v:Destroy() end
    end
end)

local ItemCache = {}
local SecureFolder = Instance.new("Folder", CG)
SecureFolder.Name = tostring(math.random(1e5, 9e5))

-- [CẤU HÌNH]
_G.AutoEnabled = false
_G.SelectedHerbs = {} 
_G.BaseSpeed = 120
_G.ESP_Enabled = { Flames = false, Manuals = false, Age10 = false, Age100 = false, Age1000 = false }

local flameLookup = {["karmic dao flame"]=true,["poison death flame"]=true,["great river flame"]=true,["disaster rose flame"]=true,["ice devil flame"]=true,["azure moon flame"]=true,["ruinous flame"]=true,["earth flame"]=true,["heaven flame"]=true,["obsidian flame"]=true,["bone chill flame"]=true,["green lotus flame"]=true,["sea heart flame"]=true,["volcanic flame"]=true,["purifying lotus demon flame"]=true,["gold emperor burning sky flame"]=true}
local manualLookup = {["qi condensation sutra"]=true,["six yin scripture"]=true,["nine yang scripture"]=true,["maniac's cultivation tips"]=true,["verdant wind scripture"]=true,["copper body formula"]=true,["lotussutra"]=true,["mother earth technique"]=true,["pure heart skill"]=true,["heavenly demon scripture"]=true,["extreme sword sutra"]=true,["principle of motion"]=true,["shadowless canon"]=true,["principle of stillness"]=true,["earth flame method"]=true,["steel body formula"]=true,["rising dragon art"]=true,["soul shedding manual"]=true,["star reaving scripture"]=true,["return to basic"]=true,["taotie's blood devouring"]=true,["tower forging"]=true,["beastsoul"]=true,["journey to the west"]=true,["book of life and death"]=true}

-- [1] UI MINIMALIST V71
local sg = Instance.new("ScreenGui", CG); sg.Name = "KumaV71"
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 260, 0, 480); main.Position = UDim2.new(0.1, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); main.BorderSizePixel = 0; main.Active = true; main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -30, 0, 35); title.Text = " 🥷 KUMA V71 - STEALTH"; title.BackgroundColor3 = Color3.fromRGB(25, 25, 25); title.TextColor3 = Color3.new(1, 1, 1); title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 30, 0, 35); minBtn.Position = UDim2.new(1, -30, 0, 0); minBtn.Text = "-"; minBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); minBtn.TextColor3 = Color3.new(1, 1, 1)

local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, 0, 1, -40); content.Position = UDim2.new(0, 0, 0, 40); content.BackgroundTransparency = 1; content.CanvasSize = UDim2.new(0, 0, 1.8, 0)
Instance.new("UIListLayout", content).Padding = UDim.new(0, 5)

local function createBtn(txt, color, parent)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.94, 0, 0, 35); b.Text = txt; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1, 1, 1); b.BorderSizePixel = 0
    return b
end

local toggleFarm = createBtn("AUTO FARM: OFF", Color3.fromRGB(120, 30, 30), content)
local refreshBtn = createBtn("🔄 SCAN AREA (LẤY DANH SÁCH)", Color3.fromRGB(30, 80, 150), content)
local scroll = Instance.new("ScrollingFrame", content)
scroll.Size = UDim2.new(0.94, 0, 0, 150); scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20); scroll.BorderSizePixel = 0
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 3)

local espFlame = createBtn("ESP Flames: OFF", Color3.fromRGB(45, 45, 45), content)
local espManual = createBtn("ESP Manuals: OFF", Color3.fromRGB(45, 45, 45), content)
local esp10 = createBtn("ESP 10Y: OFF", Color3.fromRGB(45, 45, 45), content)
local esp100 = createBtn("ESP 100Y: OFF", Color3.fromRGB(45, 45, 45), content)
local esp1000 = createBtn("ESP 1000Y: OFF", Color3.fromRGB(45, 45, 45), content)

----------------------------------------------------------------
-- HỆ THỐNG DI CHUYỂN GIẢ LẬP NGƯỜI (STEALTH MOVE)
----------------------------------------------------------------
local function StealthMove(targetPart)
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetPart or not targetPart.Parent then return end

    local currentSpeed = _G.BaseSpeed + math.random(-5, 8)
    local targetPos = targetPart.Position + Vector3.new(0, 2.5, 0)
    local reached = false
    
    local bv = Instance.new("BodyVelocity", hrp)
    bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)

    local connection
    connection = RS.Heartbeat:Connect(function(dt)
        if not IsAlive() or not _G.AutoEnabled or not targetPart.Parent then
            connection:Disconnect(); return
        end
        
        local diff = targetPos - hrp.Position
        local dist = diff.Magnitude
        
        if dist < 1.5 then
            reached = true; connection:Disconnect()
        else
            -- Di chuyển mượt + quay mặt về hướng mục tiêu (Quan trọng để Anti-Ban)
            local moveStep = currentSpeed * dt
            hrp.CFrame = CFrame.lookAt(hrp.Position + (diff.Unit * math.min(moveStep, dist)), targetPart.Position)
            -- Noclip
            for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end
    end)

    repeat task.wait() until reached or not IsAlive() or not _G.AutoEnabled
    if bv then bv:Destroy() end
end

----------------------------------------------------------------
-- SMART CACHE & SCAN
----------------------------------------------------------------
local function UpdateCache()
    local temp = {}
    local all = workspace:GetDescendants()
    for i = 1, #all do
        if not IsAlive() then break end
        local v = all[i]
        -- Lấy item có ProximityPrompt HOẶC có Humanoid (Mob)
        local prompt = v:FindFirstChildWhichIsA("ProximityPrompt", true)
        local hum = v:IsA("Humanoid") and v or nil
        
        if prompt then
            table.insert(temp, {p = prompt, o = v, type = "Item"})
        elseif hum and v.Parent ~= LP.Character then
            table.insert(temp, {o = v.Parent, type = "Mob"})
        end
        if i % 1000 == 0 then task.wait() end 
    end
    ItemCache = temp
end

refreshBtn.MouseButton1Click:Connect(function()
    UpdateCache()
    for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local found = {}
    for _, item in pairs(ItemCache) do
        local name = item.o.Name
        if not found[name] then
            found[name] = true
            local b = createBtn(name, Color3.fromRGB(35,35,35), scroll); b.Size = UDim2.new(1, -10, 0, 30)
            b.MouseButton1Click:Connect(function()
                local idx = table.find(_G.SelectedHerbs, name)
                if not idx then table.insert(_G.SelectedHerbs, name); b.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
                else table.remove(_G.SelectedHerbs, idx); b.BackgroundColor3 = Color3.fromRGB(35,35,35) end
            end)
        end
    end
end)

----------------------------------------------------------------
-- VÒNG LẶP FARM CHÍNH
----------------------------------------------------------------
task.spawn(function()
    while IsAlive() do
        if _G.AutoEnabled and #_G.SelectedHerbs > 0 then
            pcall(function()
                local hrp = LP.Character.HumanoidRootPart
                local targetObj, targetPrompt; local d = 3000
                
                for _, item in pairs(ItemCache) do
                    if table.find(_G.SelectedHerbs, item.o.Name) then
                        local part = item.o:FindFirstChild("HumanoidRootPart") or (item.o:IsA("BasePart") and item.o or item.o:FindFirstChildWhichIsA("BasePart", true))
                        if part and part.Parent then
                            local dist = (part.Position - hrp.Position).Magnitude
                            if dist < d then
                                d = dist; targetObj = part; targetPrompt = item.p
                            end
                        end
                    end
                end
                
                if targetObj then
                    StealthMove(targetObj)
                    if targetPrompt then
                        task.wait(0.1 + (math.random() * 0.2))
                        fireproximityprompt(targetPrompt)
                        task.wait(0.3)
                    else
                        -- Nếu là quái (không có prompt), giả lập đánh
                        local tool = LP.Character:FindFirstChildWhichIsA("Tool") or LP.Backpack:FindFirstChildWhichIsA("Tool")
                        if tool then
                            if tool.Parent == LP.Backpack then LP.Character.Humanoid:EquipTool(tool) end
                            tool:Activate()
                        end
                        task.wait(0.5)
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

----------------------------------------------------------------
-- ESP BẢO MẬT
----------------------------------------------------------------
local function CreateESP(obj, text, color)
    local container = Instance.new("Folder", SecureFolder)
    local hl = Instance.new("Highlight", container)
    hl.Adornee = obj; hl.FillColor = color; hl.FillTransparency = 0.7; hl.OutlineTransparency = 0.2
    
    local bg = Instance.new("BillboardGui", container)
    bg.Adornee = obj; bg.Size = UDim2.new(0, 100, 0, 20); bg.AlwaysOnTop = true; bg.StudsOffset = Vector3.new(0, 2.5, 0)
    local tl = Instance.new("TextLabel", bg)
    tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1; tl.Text = text; tl.TextColor3 = color; tl.Font = Enum.Font.GothamBold; tl.TextSize = 9
end

task.spawn(function()
    while IsAlive() do
        task.wait(2); SecureFolder:ClearAllChildren()
        if not _G.AutoEnabled and not _G.ESP_Enabled then continue end
        
        for _, item in pairs(ItemCache) do
            local obj = item.o
            if not obj or not obj.Parent then continue end
            local nameLow = obj.Name:lower()
            local age = obj:GetAttribute("Age") or 0
            local color, text = nil, ""

            if _G.ESP_Enabled.Flames and flameLookup[nameLow] then
                color = Color3.fromRGB(255, 60, 0); text = "🔥 "..obj.Name
            elseif _G.ESP_Enabled.Manuals and manualLookup[nameLow] then
                color = Color3.fromRGB(255, 200, 0); text = "📖 "..obj.Name
            elseif _G.ESP_Enabled.Age1000 and age >= 1000 then
                color = Color3.fromRGB(200, 0, 255); text = "[1000Y] "..obj.Name
            elseif _G.ESP_Enabled.Age100 and age >= 100 then
                color = Color3.fromRGB(0, 180, 255); text = "[100Y] "..obj.Name
            elseif _G.ESP_Enabled.Age10 and age >= 10 then
                color = Color3.new(0.9, 0.9, 0.9); text = "[10Y] "..obj.Name
            end

            if color then CreateESP(obj, text, color) end
        end
    end
end)

----------------------------------------------------------------
-- ĐIỀU KHIỂN UI
----------------------------------------------------------------
toggleFarm.MouseButton1Click:Connect(function()
    _G.AutoEnabled = not _G.AutoEnabled
    toggleFarm.Text = "AUTO FARM: " .. (_G.AutoEnabled and "ON" or "OFF")
    toggleFarm.BackgroundColor3 = _G.AutoEnabled and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(120, 30, 30)
end)

local function setupToggle(btn, key, label)
    btn.MouseButton1Click:Connect(function()
        _G.ESP_Enabled[key] = not _G.ESP_Enabled[key]
        btn.Text = label .. (_G.ESP_Enabled[key] and ": ON" or ": OFF")
        btn.BackgroundColor3 = _G.ESP_Enabled[key] and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(45, 45, 45)
    end)
end
setupToggle(espFlame, "Flames", "ESP Flames"); setupToggle(espManual, "Manuals", "ESP Manuals")
setupToggle(esp10, "Age10", "ESP 10Y"); setupToggle(esp100, "Age100", "ESP 100Y"); setupToggle(esp1000, "Age1000", "ESP 1000Y")

minBtn.MouseButton1Click:Connect(function()
    local isMin = (main.Size.Y.Offset < 100)
    content.Visible = isMin
    main:TweenSize(isMin and UDim2.new(0, 260, 0, 480) or UDim2.new(0, 260, 0, 35), "Out", "Quad", 0.3, true)
    minBtn.Text = isMin and "-" or "+"
end)

print("✅ KUMA HUB V71 - ULTIMATE STEALTH LOADED")
