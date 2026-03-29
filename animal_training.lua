-- CLEANUP AN TOAN
pcall(function() _G.ScriptRunning2 = false end)
task.wait(0.5)

pcall(function()
    for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
        if gui.Name == "Fluent" or gui.Name == "Rayfield" then
            pcall(function() gui:Destroy() end)
        end
    end
end)

task.wait(0.3)
_G.ScriptRunning2 = true

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Training Game Hub",
    LoadingTitle = "Kuma_Hub",
    LoadingSubtitle = "by Kuma_Hub",
    Theme = "Default",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local ChinhTab = Window:CreateTab("Chính", "zap")
local ChienDauTab = Window:CreateTab("Chiến Đấu", "sword")

do
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local knit = RS.Packages._Index
    :FindFirstChild("sleitnick_knit@1.5.1")
    .knit.Services

local runTrain = knit.TrainService.RE.RunTrain
local claimChest = knit.ChestService.RF.ClaimDailyChest

local remote = RS
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.5.1")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("FightService")
    :WaitForChild("RE")
    :WaitForChild("GetWinsEvent")

-- ============================================================
-- FARM POWER
-- ============================================================
ChinhTab:CreateSection("Farm Power")

local runningFarm = false
local farmDelay = 0.05
local startMap = 2
local startMachine = 2

local treadmills = {}
local function buildTreadmills()
    treadmills = {}
    for machine = startMachine, 7 do
        table.insert(treadmills, "Treadmill_" .. startMap .. "_" .. machine)
    end
    for map = startMap + 1, 10 do
        for machine = 1, 7 do
            table.insert(treadmills, "Treadmill_" .. map .. "_" .. machine)
        end
    end
end
buildTreadmills()

ChinhTab:CreateSlider({
    Name = "Bắt Đầu Từ Map",
    Range = {1, 10}, Increment = 1, CurrentValue = 2, Flag = "StartMap",
    Callback = function(Value) startMap = Value buildTreadmills() end,
})

ChinhTab:CreateSlider({
    Name = "Bắt Đầu Từ Máy",
    Range = {1, 7}, Increment = 1, CurrentValue = 2, Flag = "StartMachine",
    Callback = function(Value) startMachine = Value buildTreadmills() end,
})

ChinhTab:CreateSlider({
    Name = "Chu Kỳ Spam (giây)",
    Range = {0, 1}, Increment = 0.01, CurrentValue = 0.05, Flag = "FarmDelay",
    Callback = function(Value) farmDelay = Value end,
})

ChinhTab:CreateToggle({
    Name = "Tự Động Farm Power",
    CurrentValue = false, Flag = "FarmToggle",
    Callback = function(state)
        runningFarm = state
        if not state then
            Rayfield:Notify({ Title="Đã Dừng", Content="Đã dừng farm power", Duration=2, Image=4483362458 })
            return
        end
        buildTreadmills()
        for _, treadmill in pairs(treadmills) do
            task.spawn(function()
                while runningFarm and _G.ScriptRunning2 do
                    pcall(function() runTrain:FireServer(treadmill) end)
                    task.wait(farmDelay)
                end
            end)
        end
        Rayfield:Notify({ Title="Bắt Đầu!", Content="Đang spam " .. #treadmills .. " máy!", Duration=3, Image=4483362458 })
    end,
})

-- ============================================================
-- RUNG HANG NGAY
-- ============================================================
ChinhTab:CreateSection("Rương Hàng Ngày")

local runningChest = false
ChinhTab:CreateToggle({
    Name = "Tự Động Nhận Rương",
    CurrentValue = false, Flag = "ChestToggle",
    Callback = function(state)
        runningChest = state
        if not state then return end
        task.spawn(function()
            while runningChest and _G.ScriptRunning2 do
                pcall(function() claimChest:InvokeServer() end)
                task.wait(1)
            end
        end)
    end,
})

ChinhTab:CreateButton({
    Name = "Nhận Rương 1 Lần",
    Callback = function()
        pcall(function() claimChest:InvokeServer() end)
        Rayfield:Notify({ Title="Xong!", Content="Đã nhận rương!", Duration=2, Image=4483362458 })
    end,
})

-- ============================================================
-- TIEN ICH
-- ============================================================
ChinhTab:CreateSection("Tiện Ích")

ChinhTab:CreateButton({
    Name = "Reset Nhân Vật",
    Callback = function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
    end,
})

ChinhTab:CreateButton({
    Name = "Ẩn GUI",
    Callback = function() Rayfield:Toggle() end,
})

-- ============================================================
-- INF WIN GATES
-- ============================================================
ChienDauTab:CreateSection("Inf Win Gates")

local runningWins = false
local threadCount = 3

local winGates = {
    {"WinGate_1",  vector.create(1817.11669921875, 780.9266357421875, -398.5226745605469)},
    {"WinGate_2",  vector.create(1827.684814453125, 780.9266357421875, -1401.242431640625)},
    {"WinGate_3",  vector.create(1830.3548583984375, 780.9266357421875, -3421.908447265625)},
    {"WinGate_4",  vector.create(1832.3458251953125, 780.9266357421875, -5410.6982421875)},
    {"WinGate_5",  vector.create(1834.8165283203125, 780.9266357421875, -8407.66796875)},
    {"WinGate_6",  vector.create(1836.9246826171875, 780.9266357421875, -11412.69140625)},
    {"WinGate_7",  vector.create(1836.0892333984375, 780.9266357421875, -16393.083984375)},
    {"WinGate_8",  vector.create(1821.4886474609375, 780.9266357421875, -21407.490234375)},
    {"WinGate_9",  vector.create(1807.41650390625, 780.9266357421875, -27398.37890625)},
    {"WinGate_10", vector.create(1798.7652587890625, 780.9266357421875, -34385.06640625)},
    {"WinGate_11", vector.create(1800.777587890625, 780.9266357421875, -43387.16015625)},
    {"WinGate_12", vector.create(1803.955810546875, 780.9266357421875, -55440.78125)},
    {"WinGate_13", vector.create(1812.9002685546875, 780.9266357421875, -70406.65625)},
    {"WinGate_14", vector.create(1812.9002685546875, 780.9266357421875, -91420.0625)},
    {"WinGate_15", vector.create(1812.9002685546875, 780.9266357421875, -113429.625)},
    {"WinGate_16", vector.create(1858.823974609375, 781.8848266601562, -170408.90625)},
}

ChienDauTab:CreateSlider({
    Name = "Số Thread Spam",
    Range = {1,50}, Increment = 1, CurrentValue = 10, Flag = "ThreadCount",
    Callback = function(Value) threadCount = Value end,
})

ChienDauTab:CreateToggle({
    Name = "Tự Động Farm Inf Wins",
    CurrentValue = false, Flag = "WinsToggle",
    Callback = function(state)
        runningWins = state
        if not state then
            Rayfield:Notify({ Title="Đã Dừng", Content="Đã dừng farm wins", Duration=2, Image=4483362458 })
            return
        end
        for t = 1, threadCount do
            task.spawn(function()
                while runningWins and _G.ScriptRunning2 do
                    for _, gate in pairs(winGates) do
                        if not runningWins or not _G.ScriptRunning2 then break end
                        pcall(function()
                            remote:FireServer(gate[1], gate[2])
                        end)
                        task.wait()
                    end
                end
            end)
        end
        Rayfield:Notify({ Title="Bắt Đầu!", Content="Đang farm x" .. threadCount .. " thread!", Duration=3, Image=4483362458 })
    end,
})

ChienDauTab:CreateButton({
    Name = "Fire Tất Cả Gates 1 Lần",
    Callback = function()
        for _, gate in pairs(winGates) do
            pcall(function() remote:FireServer(gate[1], gate[2]) end)
            task.wait()
        end
        Rayfield:Notify({ Title="Xong!", Content="Đã fire " .. #winGates .. " gates!", Duration=2, Image=4483362458 })
    end,
})

ChienDauTab:CreateButton({
    Name = "Ẩn GUI",
    Callback = function() Rayfield:Toggle() end,
})

-- ============================================================
-- ANTI AFK
-- ============================================================
local VirtualUser = game:GetService("VirtualUser")

player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

task.spawn(function()
    while _G.ScriptRunning2 do
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(0.1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
        task.wait(180)
    end
end)

task.spawn(function()
    while _G.ScriptRunning2 do
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
        task.wait(240)
    end
end)

end
