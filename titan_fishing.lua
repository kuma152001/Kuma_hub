-- Titan Fisch | Optimized & Fixed 2026 by JICEO + Grok fixes
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield', true))()
end)

if not success or not Rayfield then
    -- Fallback link nếu Sirius down
    Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source', true))()
end

local Window = Rayfield:CreateWindow({
    Name = "Titan Fisch | Optimized 2026",
    LoadingTitle = "Loading Titan Fisch",
    LoadingSubtitle = "by Kuma_Hub",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TitanFisching",
        FileName = "MainConfig"
    },
    KeySystem = false
})

-- Services
local VirtualInput = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Flags
local flags = {
    autoZ = false, autoX = false, autoC = false, autoV = false,
    autoCast = false, autoSell = false, autoEquip = false,
    autoReturn = false, speedEnabled = false, infJumpEnabled = false,
    remoteSell = false
}

local sellPosition = Vector3.new(170.08, 23.4, 72.58)
local farmPosition = nil
_G.IsSelling = false
local isCurrentlyFishing = false
local shouldSellWhenFishingEnds = false

-- Speed hack variables
local speedValue = 50
local vectorForce = nil
local originalProps = {}

local function saveOriginalProps(character)
    originalProps = {}
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            originalProps[part] = part.CustomPhysicalProperties
        end
    end
end

local function restoreOriginalProps(character)
    for part, props in pairs(originalProps) do
        if part and part.Parent and props then
            pcall(function() part.CustomPhysicalProperties = props end)
        end
    end
end

local function setupSpeedForce(enable)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if vectorForce then
        vectorForce:Destroy()
        vectorForce = nil
    end

    if enable then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.1, 0.5, 0.5, 1)
            end
        end

        vectorForce = Instance.new("VectorForce")
        vectorForce.Force = Vector3.zero
        vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
        vectorForce.ApplyAtCenterOfMass = true

        local attachment = hrp:FindFirstChild("RootRigAttachment") or Instance.new("Attachment", hrp)
        vectorForce.Attachment0 = attachment
        vectorForce.Parent = hrp
    end
end

player.CharacterAdded:Connect(function(char)
    task.wait(1.2)
    saveOriginalProps(char)
    if flags.speedEnabled then
        setupSpeedForce(true)
    end
end)

if player.Character then
    task.wait(1)
    saveOriginalProps(player.Character)
end

-- Make all proximity prompts instant
local function makePromptsInstant()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0
            v.RequiresLineOfSight = false
        end
    end
    game.DescendantAdded:Connect(function(obj)
        if obj:IsA("ProximityPrompt") then
            obj.HoldDuration = 0
            obj.RequiresLineOfSight = false
        end
    end)
end
makePromptsInstant()

-- Check if fishing minigame is active
local function isFishing()
    local gui = player.PlayerGui
    local names = {"ReelGUI", "FishingGui", "Reeling", "MinigameGUI", "ReelBar", "FishingMinigame", "ReelInterface", "Reel", "ProgressGUI", "ReelMinigame"}
    for _, name in ipairs(names) do
        local found = gui:FindFirstChild(name, true)
        if found and (found.Enabled or found.Visible) then
            return true
        end
    end
    return false
end

-- Fishing state loop
task.spawn(function()
    local last = false
    while true do
        local now = isFishing()
        if now ~= last then
            isCurrentlyFishing = now
        end
        last = now
        task.wait(0.15)
    end
end)

-- Force click any button
local function forceClick(button)
    if not button then return end
    pcall(function()
        local pos = button.AbsolutePosition + button.AbsoluteSize / 2
        VirtualInput:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
        task.wait(0.04)
        VirtualInput:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
    end)
end

-- Instant TP
local function instantTeleport(pos)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = (typeof(pos) == "CFrame" and pos) or CFrame.new(pos)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end

-- Sell function (improved)
local function performSell()
    if _G.IsSelling then return end
    _G.IsSelling = true

    instantTeleport(sellPosition)
    task.wait(2.2)  -- chờ ổn định hơn

    local sellGui
    local attempts = 0
    while attempts < 12 and flags.autoSell do
        VirtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.08)
        VirtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(0.5)

        sellGui = player.PlayerGui:FindFirstChild("SellGUI") or player.PlayerGui:FindFirstChildWhichIsA("ScreenGui", true)
        if sellGui and sellGui.Enabled then break end
        attempts = attempts + 1
    end

    if sellGui and sellGui.Enabled then
        task.wait(0.8)

        -- Tìm button "All" linh hoạt
        local allBtn
        for _, btn in pairs(sellGui:GetDescendants()) do
            if btn:IsA("TextButton") and (btn.Text:lower():find("all") or btn.Name:lower():find("all")) then
                allBtn = btn
                break
            end
        end
        if allBtn then forceClick(allBtn) end

        task.wait(1.3)

        -- Tìm button Close / Đóng
        local closeBtn
        for _, btn in pairs(sellGui:GetDescendants()) do
            if btn:IsA("TextButton") and (btn.Text:lower():find("close") or btn.Text == "Đóng" or btn.Name:lower():find("close")) then
                closeBtn = btn
                break
            end
        end
        if closeBtn then forceClick(closeBtn) end

        task.wait(0.9)
    end

    if farmPosition then
        instantTeleport(farmPosition)
    end

    _G.IsSelling = false
    Rayfield:Notify({Title = "Sell Complete", Content = "Đã bán xong!", Duration = 3})
end

local function performRemoteSell()
    if _G.IsSellingRemote then return end
    _G.IsSellingRemote = true
    
    local success = false
    
    -- 1. Tìm NPC Merchant trong Map để lấy lệnh bán chính xác
    local merchant = nil
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and (v.Name:find("Merchant") or v.Name:find("Sell")) then
            merchant = v
            break
        end
    end

    -- 2. Thử kích hoạt lệnh bán qua RemoteEvent (Cách mạnh nhất)
    local remotes = {
        game:GetService("ReplicatedStorage"):FindFirstChild("events") and game:GetService("ReplicatedStorage").events:FindFirstChild("sellevents"),
        game:GetService("ReplicatedStorage"):FindFirstChild("events") and game:GetService("ReplicatedStorage").events:FindFirstChild("SellAll"),
        game:GetService("ReplicatedStorage"):FindFirstChild("CloudEvents") and game:GetService("ReplicatedStorage").CloudEvents:FindFirstChild("SellAll")
    }

    for _, r in ipairs(remotes) do
        if r and r:IsA("RemoteEvent") then
            r:FireServer(merchant) -- Gửi kèm NPC Merchant nếu game yêu cầu
            success = true
        end
    end

    -- 3. Cách dự phòng: Quét toàn bộ Remote có chữ Sell và ép chạy
    if not success then
        for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("sellall") or v.Name:lower():find("sellevents")) then
                v:FireServer()
                success = true
            end
        end
    end

    -- 4. Thông báo kết quả
    if success then
        Rayfield:Notify({Title = "Success", Content = "Đã ép gửi lệnh bán cá!", Duration = 2})
    else
        -- Nếu tất cả đều hụt, dùng chiêu cuối: Giả lập nhấn nút trên UI
        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui then
            for _, g in pairs(playerGui:GetDescendants()) do
                if g:IsA("TextButton") and (g.Text:lower():find("sell all") or g.Name:lower():find("sellall")) then
                    local pos = g.AbsolutePosition + g.AbsoluteSize / 2
                    VirtualInput:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                    task.wait(0.05)
                    VirtualInput:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                    success = true
                end
            end
        end
    end

    task.wait(1.5)
    _G.IsSellingRemote = false
end

-- Auto Skill Tab
local AutoTab = Window:CreateTab("Auto Skill", 4483345998)

local keyToggles = {
    [Enum.KeyCode.Z] = "autoZ",
    [Enum.KeyCode.X] = "autoX",
    [Enum.KeyCode.C] = "autoC",
    [Enum.KeyCode.V] = "autoV",
}

local lastSpam = 0
local spamDelay = 0.03  -- an toàn hơn, tránh kick

RunService.Heartbeat:Connect(function()
    if tick() - lastSpam < spamDelay then return end
    lastSpam = tick()

    for key, flag in pairs(keyToggles) do
        if flags[flag] then
            VirtualInput:SendKeyEvent(true, key, false, game)
            task.wait(0.018)
            VirtualInput:SendKeyEvent(false, key, false, game)
        end
    end
end)

AutoTab:CreateToggle({Name = "Auto Z", Callback = function(v) flags.autoZ = v end})
AutoTab:CreateToggle({Name = "Auto X", Callback = function(v) flags.autoX = v end})
AutoTab:CreateToggle({Name = "Auto C", Callback = function(v) flags.autoC = v end})
AutoTab:CreateToggle({Name = "Auto V", Callback = function(v) flags.autoV = v end})

-- Player Tab
local PlayerTab = Window:CreateTab("Player", 4483362458)

PlayerTab:CreateToggle({
    Name = "Speed Hack",
    Callback = function(v)
        flags.speedEnabled = v
        if player.Character then
            setupSpeedForce(v)
            if not v then restoreOriginalProps(player.Character) end
        end
    end
})

RunService.Heartbeat:Connect(function()
    if not flags.speedEnabled or not player.Character then return end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if humanoid and hrp and vectorForce then
        local dir = humanoid.MoveDirection
        vectorForce.Force = dir * (speedValue * 520)
    end
end)

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    Callback = function(v) flags.infJumpEnabled = v end
})

UserInputService.JumpRequest:Connect(function()
    if flags.infJumpEnabled and player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

PlayerTab:CreateInput({
    Name = "Speed Value (min 16)",
    PlaceholderText = "50",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local n = tonumber(text)
        if n and n >= 16 then speedValue = n end
    end
})

-- Titan Fisch Tab
local FischTab = Window:CreateTab("Titan Fisch", 7072742186)

FischTab:CreateButton({
    Name = "Set Farm Position (Current Location)",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            farmPosition = player.Character.HumanoidRootPart.CFrame
            Rayfield:Notify({Title = "Done", Content = "Farm position đã lưu!", Duration = 3})
        end
    end
})

FischTab:CreateToggle({
    Name = "Auto Return to Farm",
    Callback = function(v)
        flags.autoReturn = v
        task.spawn(function()
            while flags.autoReturn do
                task.wait(1.8)
                if not _G.IsSelling and farmPosition and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - farmPosition.Position).Magnitude > 10 then
                        instantTeleport(farmPosition)
                    end
                end
            end
        end)
    end
})

FischTab:CreateToggle({
    Name = "Auto Equip Best Rod",
    Callback = function(v)
        flags.autoEquip = v
        task.spawn(function()
            while flags.autoEquip do
                task.wait(1.4)
                if not _G.IsSelling and player.Character then
                    local char = player.Character
                    if not char:FindFirstChildWhichIsA("Tool") then
                        local rod = player.Backpack:FindFirstChildWhichIsA("Tool")
                        if rod then char.Humanoid:EquipTool(rod) end
                    end
                end
            end
        end)
    end
})

local sellInterval = 300
local currentTimer = sellInterval
local timerLabel = FischTab:CreateLabel("Next auto sell: calculating...")

FischTab:CreateInput({
    Name = "Sell every X seconds (min 30)",
    PlaceholderText = "300",
    Callback = function(text)
        local n = tonumber(text)
        if n and n >= 30 then
            sellInterval = n
            currentTimer = n
        end
    end
})

FischTab:CreateToggle({
    Name = "Periodic Auto Sell",
    Callback = function(enabled)
        flags.autoSell = enabled
        if enabled then
            currentTimer = sellInterval
            task.spawn(function()
                local wasFishing = false
                while flags.autoSell do
                    local nowFishing = isFishing()
                    if wasFishing and not nowFishing and shouldSellWhenFishingEnds then
                        performSell()
                        currentTimer = sellInterval
                        shouldSellWhenFishingEnds = false
                    end
                    wasFishing = nowFishing

                    if currentTimer <= 0 then
                        if nowFishing then
                            shouldSellWhenFishingEnds = true
                            timerLabel:Set("Waiting for current fish...")
                        else
                            performSell()
                            currentTimer = sellInterval
                        end
                    else
                        currentTimer = currentTimer - 1
                        local m = math.floor(currentTimer / 60)
                        local s = currentTimer % 60
                        timerLabel:Set("Next sell: " .. m .. "m " .. s .. "s")
                    end
                    task.wait(1)
                end
                timerLabel:Set("Auto Sell: OFF")
            end)
        end
    end
})

FischTab:CreateToggle({
    Name = "Auto Remote Sell (No Teleport)",
    Callback = function(enabled)
        flags.remoteSell = enabled
        if enabled then
            task.spawn(function()
                while flags.remoteSell do
                    -- Tự động bán mỗi 60 giây (hoặc tùy bạn chỉnh)
                    task.wait(60) 
                    if not isFishing() then
                        performRemoteSell()
                    end
                end
            end)
        end
    end
})

FischTab:CreateButton({
    Name = "Force Sell Now (Tại chỗ)",
    Callback = function()
        performRemoteSell()
    end
})

FischTab:CreateToggle({
    Name = "Auto Cast Rod (Fixed 2026)",
    Callback = function(v)
        flags.autoCast = v
        task.spawn(function()
            while flags.autoCast do
                task.wait(1.0) -- Chờ ổn định giữa các lần quăng
                
                -- Điều kiện: Không đang bán, không đang trong minigame, và nhân vật còn sống
                if not _G.IsSelling and not isFishing() and player.Character then
                    local tool = player.Character:FindFirstChildWhichIsA("Tool")
                    
                    -- Nếu chưa cầm cần trên tay, tự động lấy từ Backpack
                    if not tool then
                        local rod = player.Backpack:FindFirstChildWhichIsA("Tool")
                        if rod and player.Character:FindFirstChild("Humanoid") then
                            player.Character.Humanoid:EquipTool(rod)
                            task.wait(0.5)
                            tool = player.Character:FindFirstChildWhichIsA("Tool")
                        end
                    end

                    -- Thực hiện quăng cần bằng cách giả lập nhấn giữ chuột
                    if tool then
                        -- Lấy tọa độ tâm màn hình để click cho chuẩn
                        local centerX = game.Workspace.CurrentCamera.ViewportSize.X / 2
                        local centerY = game.Workspace.CurrentCamera.ViewportSize.Y / 2
                        
                        -- Nhấn chuột xuống (Bắt đầu gồng lực)
                        VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                        
                        -- Gồng lực trong 1.2 giây (Bạn có thể chỉnh số này từ 0.5 - 2.0 tùy ý)
                        task.wait(0.2) 
                        
                        -- Thả chuột (Quăng cần)
                        VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
                        
                        -- Chờ một chút để tránh spam lệnh quá nhanh
                        task.wait(0.5)
                    end
                end
            end
        end)
    end
})

Rayfield:LoadConfiguration()
Rayfield:Notify({Title = "Loaded!", Content = "Titan Fisch script ready! Enjoy farming 🎣", Duration = 5})
