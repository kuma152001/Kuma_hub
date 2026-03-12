-- ============================================================
--   Kuma_Hub MegaScript v3.2  |  Base Tycoon + Lobby
--   Đã sửa lỗi Treo Script (Infinite Yield) & Auto Reconnect
-- ============================================================

local MyLink = "https://raw.githubusercontent.com/kuma152001/Kuma_hub/refs/heads/main/defend_your_base_from_67.lua"

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService  = game:GetService("HttpService")
local RS           = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local lp           = Players.LocalPlayer
-- Lưu ý: CoreGui thật của Roblox luôn nằm trong game:GetService("CoreGui")
if not game:IsLoaded() then game.Loaded:Wait() end -- Đợi game load xong

local MyGuiHolder = nil
pcall(function()
    -- Ưu tiên gethui (chống bị game quét), nếu không có thì dùng CoreGui
    MyGuiHolder = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not MyGuiHolder then MyGuiHolder = lp:WaitForChild("PlayerGui") end -- Dự phòng cuối
local ActualCoreGui = game:GetService("CoreGui")
local LOBBY_ID = 102669100769936
local GAME_ID  = 97689234675651

-- ============================================================
-- HỆ THỐNG CHẠY NGẦM (ANTI-AFK, RECONNECT, AUTO-CLOSE)
-- Tách riêng luồng để không làm treo logic chính
-- ============================================================

task.spawn(function()
    -- 1. Anti-AFK
    local VirtualUser = game:GetService("VirtualUser")
    lp.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    -- 2. Auto Reconnect & Auto Close Robux (Kiểm tra an toàn)
    while true do
        task.wait(2)
        pcall(function()
            -- Kiểm tra bảng thông báo lỗi Roblox (Reconnect)
            local robloxPrompt = ActualCoreGui:FindFirstChild("RobloxPromptGui")
            if robloxPrompt then
                local promptOverlay = robloxPrompt:FindFirstChild("promptOverlay")
                if promptOverlay then
                    local errorPrompt = promptOverlay:FindFirstChild("ErrorPrompt")
                    if errorPrompt and errorPrompt.Visible then
                        warn("[Kuma_Hub] Phát hiện ngắt kết nối, đang thử lại...")
                        task.wait(2)
                        TeleportService:Teleport(game.PlaceId, lp)
                    end
                end
            end

            -- Kiểm tra bảng mua Robux (Auto Close)
            local purchasePrompt = ActualCoreGui:FindFirstChild("PurchasePrompt")
            if purchasePrompt then
                local frame = purchasePrompt:FindFirstChild("ProductPurchaseContainer") or purchasePrompt:FindFirstChild("PurchasePromptFrame")
                if frame and frame.Visible then
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Escape, false, game)
                    task.wait(0.1)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Escape, false, game)
                end
            end
        end)
    end
end)

-- ============================================================
-- HỖ TRỢ QOT (Tự động chạy lại khi đổi server)
-- ============================================================
local function registerQOT()
    local qot = nil
    pcall(function()
        qot = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
        local genv = getgenv and getgenv()
        if not qot and genv then qot = genv.queue_on_teleport end
    end)
    if qot then
        qot('repeat task.wait() until game:IsLoaded(); loadstring(game:HttpGet("' .. MyLink .. '"))()')
    end
end
registerQOT()

-- ============================================================
-- HỆ THỐNG LƯU TRỮ (SAVE DATA)
-- ============================================================
local FILE = "KUMAHUB_SaveData.json"
local Save = {
    TotalTime=0, TotalGold=0,
    SelectedMap="Map1", SelectedDiff="Medium",
    IsBestMap=false, IsBestDiff=false, AutoStartQueue=false,
}
pcall(function()
    if isfile and isfile(FILE) then
        local d = HttpService:JSONDecode(readfile(FILE))
        for k,v in pairs(d) do Save[k]=v end
    end
end)
local function saveData()
    pcall(function() if writefile then writefile(FILE,HttpService:JSONEncode(Save)) end end)
end

local function fmtTime(s)
    return string.format("%02d:%02d:%02d",math.floor(s/3600),math.floor(s%3600/60),s%60)
end
-- ============================================================
-- GIAO DIỆN NGƯỜI DÙNG (GUI) - PHIÊN BẢN COMPACT
-- ============================================================
pcall(function()
    for _,v in ipairs(MyGuiHolder:GetChildren()) do -- Dùng MyGuiHolder thay vì CoreGui
        if v.Name=="KumaHub_Main" then v:Destroy() end
    end
end)

-- Biến điều khiển tính năng (Thêm vào để các vòng lặp phía dưới check)
_G.AutoUpgrade = true
_G.AutoRepair = true

local SG = Instance.new("ScreenGui")
SG.Name = "KumaHub_Main"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = MyGuiHolder -- SỬA TẠI ĐÂY: Dùng MyGuiHolder thay vì CoreGui

-- Khung chính của Menu
local MainFrame = Instance.new("Frame", SG)
MainFrame.Size = UDim2.new(0, 220, 0, 280)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 10, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Hỗ trợ kéo thả đơn giản

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(110, 40, 200)
Stroke.Thickness = 2

-- Tiêu đề (Header)
local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(45, 15, 80)
Header.Text = "KUMA HUB V3.1"
Header.TextColor3 = Color3.new(1, 1, 1)
Header.Font = Enum.Font.GothamBlack
Header.TextSize = 14
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

-- Status Label (Hiển thị trạng thái đang làm gì)
local MiniStatus = Instance.new("TextLabel", MainFrame)
MiniStatus.Size = UDim2.new(1, -20, 0, 20)
MiniStatus.Position = UDim2.new(0, 10, 0, 40)
MiniStatus.BackgroundTransparency = 1
MiniStatus.Text = "Sẵn sàng"
MiniStatus.TextColor3 = Color3.fromRGB(180, 255, 180)
MiniStatus.Font = Enum.Font.GothamBold
MiniStatus.TextSize = 11
MiniStatus.TextXAlignment = Enum.TextXAlignment.Left

local function setStatus(txt) MiniStatus.Text = "@: " .. txt end

-- Hàm tạo nút Toggle (Bật/Tắt)
local function createToggle(name, default, yPos, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local enabled = default
    local function update()
        btn.Text = name .. ": " .. (enabled and "BẬT" or "TẮT")
        btn.BackgroundColor3 = enabled and Color3.fromRGB(40, 140, 40) or Color3.fromRGB(140, 30, 30)
        callback(enabled)
    end
    
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        update()
    end)
    update()
end

-- Danh sách các nút chức năng
createToggle("Tự Động Hàng Chờ", Save.AutoStartQueue, 70, function(v)
    Save.AutoStartQueue = v
    saveData()
end)

createToggle("Tự Động Nâng Cấp", _G.AutoUpgrade, 115, function(v)
    _G.AutoUpgrade = v
end)

createToggle("Tự Động Sửa Nhà", _G.AutoRepair, 160, function(v)
    _G.AutoRepair = v
end)

-- Hiển thị thông tin tiền/vàng gọn nhẹ ở dưới cùng
local InfoLbl = Instance.new("TextLabel", MainFrame)
InfoLbl.Size = UDim2.new(1, -20, 0, 60)
InfoLbl.Position = UDim2.new(0, 10, 0, 210)
InfoLbl.BackgroundTransparency = 1
InfoLbl.Text = "Vàng: 0\nTiền: 0"
InfoLbl.TextColor3 = Color3.new(0.8, 0.8, 0.8)
InfoLbl.Font = Enum.Font.Gotham
InfoLbl.TextSize = 12
InfoLbl.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            -- Sử dụng FindFirstChild để không bị treo nếu Hud chưa hiện
            local hud = lp.PlayerGui:FindFirstChild("Hud")
            local cash = "0"
            if hud and hud:FindFirstChild("Currency") and hud.Currency:FindFirstChild("Amount") then
                cash = hud.Currency.Amount.Text
            end
            
            InfoLbl.Text = "Vàng: " .. (Save.TotalGold or 0) .. 
                           "\nTiền: " .. cash .. 
                           "\nThời gian: " .. fmtTime(Save.TotalTime or 0)
        end)
    end
end)

-- ============================================================
-- LOGIC PHÒNG CHỜ (LOBBY)
-- ============================================================
if game.PlaceId == LOBBY_ID then
    setStatus("Sảnh Chờ")

    local MapData={["Rừng"]="Map1",["Sa Mạc"]="Map2",["Băng Giá"]="Map3",
        ["Núi Lửa"]="Map4",["Thiên Hà"]="Map5",["Giới Hạn"]="Map6",["Bản đồ tốt nhất"]="Best"}
    local MapOrder={"Map5","Map4","Map3","Map2","Map1"}
    local DiffList={"Dễ","Trung Bình","Khó","Vô Tận","Độ khó tốt nhất"}
    local DiffMap={["Dễ"]="Easy",["Trung Bình"]="Medium",["Khó"]="Hard",["Vô Tận"]="Endless",["Độ khó tốt nhất"]="Best difficulty"}

    local F=Instance.new("Frame",SG)
    F.Size=UDim2.new(0,420,0,520); F.Position=UDim2.new(0.5,-210,0.5,-260)
    F.BackgroundColor3=Color3.fromRGB(18,5,32); F.BackgroundTransparency=0.08
    F.BorderSizePixel=0; F.ZIndex=20
    Instance.new("UICorner",F).CornerRadius=UDim.new(0,16)
    local FG=Instance.new("UIGradient",F)
    FG.Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color3.fromRGB(35,8,65)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(12,2,28)),
    }; FG.Rotation=45
    local FAcc=Instance.new("Frame",F)
    FAcc.Size=UDim2.new(1,0,0,3); FAcc.BackgroundColor3=Color3.fromRGB(130,50,255)
    FAcc.BorderSizePixel=0; FAcc.ZIndex=21
    Instance.new("UICorner",FAcc).CornerRadius=UDim.new(0,4)
    local FT=Instance.new("TextLabel",F)
    FT.Size=UDim2.new(1,0,0,40); FT.Position=UDim2.fromOffset(0,6)
    FT.BackgroundTransparency=1; FT.Text="QUẢN LÝ HÀNG CHỜ"
    FT.TextColor3=Color3.fromRGB(210,150,255)
    FT.Font=Enum.Font.GothamBlack; FT.TextSize=18; FT.ZIndex=21

    local function mkSection(title,yOff,items,onSelect,isActive)
        local lbl=Instance.new("TextLabel",F)
        lbl.Size=UDim2.new(1,-32,0,18); lbl.Position=UDim2.fromOffset(16,yOff)
        lbl.BackgroundTransparency=1; lbl.Text=title
        lbl.TextColor3=Color3.fromRGB(150,100,220); lbl.Font=Enum.Font.GothamBold
        lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=21
        local sf=Instance.new("ScrollingFrame",F)
        sf.Size=UDim2.new(1,-32,0,110); sf.Position=UDim2.fromOffset(16,yOff+20)
        sf.BackgroundColor3=Color3.fromRGB(10,2,22); sf.BackgroundTransparency=0.3
        sf.BorderSizePixel=0; sf.ScrollBarThickness=3
        sf.ScrollBarImageColor3=Color3.fromRGB(110,40,200)
        sf.CanvasSize=UDim2.new(0,0,0,#items*38); sf.ZIndex=21
        Instance.new("UICorner",sf).CornerRadius=UDim.new(0,10)
        local ll=Instance.new("UIListLayout",sf); ll.Padding=UDim.new(0,4)
        local pad=Instance.new("UIPadding",sf)
        pad.PaddingTop=UDim.new(0,6); pad.PaddingLeft=UDim.new(0,6); pad.PaddingRight=UDim.new(0,6)
        local btns={}
        for _,name in ipairs(items) do
            local btn=Instance.new("TextButton",sf)
            btn.Size=UDim2.new(1,0,0,30); btn.Font=Enum.Font.GothamBold
            btn.TextSize=13; btn.Text=name; btn.BorderSizePixel=0; btn.ZIndex=22
            Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
            local act=isActive(name)
            btn.BackgroundColor3=act and Color3.fromRGB(110,40,200) or Color3.fromRGB(35,15,60)
            btn.TextColor3=act and Color3.new(1,1,1) or Color3.fromRGB(180,140,220)
            btn.MouseEnter:Connect(function()
                if not isActive(name) then TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(60,25,100)}):Play() end
            end)
            btn.MouseLeave:Connect(function()
                if not isActive(name) then TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(35,15,60)}):Play() end
            end)
            btn.MouseButton1Click:Connect(function()
                for _,b in pairs(btns) do
                    TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(35,15,60)}):Play()
                    b.TextColor3=Color3.fromRGB(180,140,220)
                end
                TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(110,40,200)}):Play()
                btn.TextColor3=Color3.new(1,1,1)
                onSelect(name)
            end)
            btns[name]=btn
        end
    end

    mkSection("CHỌN BẢN ĐỒ",48,{"Rừng","Sa Mạc","Băng Giá","Núi Lửa","Thiên Hà","Giới Hạn","Bản đồ tốt nhất"},
        function(v)
            if v=="Bản đồ tốt nhất" then Save.IsBestMap=true
            else Save.IsBestMap=false; Save.SelectedMap=MapData[v] end
            saveData()
        end,
        function(n) return (MapData[n]==Save.SelectedMap and not Save.IsBestMap) or (n=="Bản đồ tốt nhất" and Save.IsBestMap) end)

    mkSection("CHỌN ĐỘ KHÓ",195,DiffList,
        function(v)
            local realVal = DiffMap[v]
            if realVal=="Best difficulty" then Save.IsBestDiff=true
            else Save.IsBestDiff=false; Save.SelectedDiff=realVal end
            saveData()
        end,
        function(n) return (DiffMap[n]==Save.SelectedDiff and not Save.IsBestDiff) or (DiffMap[n]=="Best difficulty" and Save.IsBestDiff) end)

    local function mkBtn(txt,color,xOff,w,cb)
        local btn=Instance.new("TextButton",F)
        btn.Size=UDim2.new(0,w,0,44); btn.Position=UDim2.fromOffset(xOff,460)
        btn.BackgroundColor3=color; btn.Text=txt; btn.TextColor3=Color3.new(1,1,1)
        btn.Font=Enum.Font.GothamBlack; btn.TextSize=14; btn.BorderSizePixel=0; btn.ZIndex=22
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
        local st=Instance.new("UIStroke",btn)
        st.Color=color; st.Thickness=1.5; st.Transparency=0.5
        btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0.15}):Play(); st.Transparency=0 end)
        btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0}):Play(); st.Transparency=0.5 end)
        btn.MouseButton1Click:Connect(cb)
        return btn
    end

    local autoBtn=mkBtn("TỰ ĐỘNG: "..(Save.AutoStartQueue and "BẬT" or "TẮT"),
        Save.AutoStartQueue and Color3.fromRGB(40,140,40) or Color3.fromRGB(140,30,30),16,180,function()end)
    local startBtn=mkBtn("BẮT ĐẦU HÀNG CHỜ",Color3.fromRGB(110,40,200),208,196,function()end)

    local function fireQueue()
        setStatus("Đang tham gia hàng chờ...")
        pcall(function()
            local queuesFolder = workspace:FindFirstChild("Queues")
            if queuesFolder then
                for _, q in ipairs(queuesFolder:GetChildren()) do
                    local hb = q:FindFirstChild("Hitbox")
                    if hb then
                        lp.Character.HumanoidRootPart.CFrame = hb.CFrame
                        break
                    end
                end
            end
        end)
        task.wait(0.5)

        local Remote = nil
        pcall(function()
            Remote = game:GetService("ReplicatedStorage")
                :WaitForChild("Remotes", 5)
                :WaitForChild("Queue", 5)
        end)

        if not Remote then
            setStatus("LỖI: Không tìm thấy Remote Hàng chờ!")
            return
        end

        local maps  = Save.IsBestMap  and MapOrder                          or {Save.SelectedMap}
        local diffs = Save.IsBestDiff and {"Endless","Hard","Medium","Easy"} or {Save.SelectedDiff}

        for _,map in ipairs(maps) do
            for _,diff in ipairs(diffs) do
                pcall(function() Remote:FireServer("create", map, 4, diff) end)
                task.wait(0.1)
            end
        end
        setStatus("Đang chờ dịch chuyển...")
    end

    startBtn.MouseButton1Click:Connect(fireQueue)
    autoBtn.MouseButton1Click:Connect(function()
        Save.AutoStartQueue=not Save.AutoStartQueue
        autoBtn.Text="TỰ ĐỘNG: "..(Save.AutoStartQueue and "BẬT" or "TẮT")
        autoBtn.BackgroundColor3=Save.AutoStartQueue and Color3.fromRGB(40,140,40) or Color3.fromRGB(140,30,30)
        saveData()
    end)

    local dragging,dragStart,startPos
    F.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=inp.Position; startPos=F.Position
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseMovement and dragging then
            local d=inp.Position-dragStart
            F.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)

    if Save.AutoStartQueue then
        task.spawn(function()
            for i=5,1,-1 do
                startBtn.Text="TỰ ĐỘNG SAU "..i.."s"
                setStatus("Tự động bắt đầu sau "..i.."s...")
                task.wait(1)
            end
            startBtn.Text="BẮT ĐẦU HÀNG CHỜ"; fireQueue()
        end)
    end

-- ============================================================
-- LOGIC TRONG TRẬN ĐẤU (TYCOON)
-- ============================================================
elseif game.PlaceId == GAME_ID then

    local Remotes      = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
    local UnitEvent    = Remotes:WaitForChild("Unit")
    local UpgradeEvent = Remotes:WaitForChild("Upgrade")
    local BaseEvent    = Remotes:WaitForChild("Base")
    local ResultRemote = Remotes:WaitForChild("Result")

    local MAX_TURRETS     = 10
    local MAIN_FARM_LIMIT = 4
    local myBase          = nil
    local priceCache      = {}

    local function cleanNumber(text)
        if not text then return 0 end
        local s = tostring(text):gsub("<[^>]+>",""):gsub("[^%d]","")
        if s == "" then return 0 end
        return tonumber(s) or 0
    end

    local function getBalance()
        local val = 0
        pcall(function() 
            local amountObj = lp.PlayerGui:FindFirstChild("Hud")
            if amountObj then
                val = cleanNumber(amountObj.Currency.Amount.Text) 
            end
        end)
        return val
    end

    local function tp(cf)
        local char = lp.Character or lp.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        hrp.CFrame = typeof(cf)=="CFrame" and cf
            or (cf:IsA("Model") and cf:GetPivot() or cf.CFrame)
    end

    local function getUIData()
        local hud = lp.PlayerGui:FindFirstChild("Hud")
        if not hud then return nil end
        local holder = hud.Upgrade.Holder
        if not holder.Visible then return nil end
        return {
            cost  = cleanNumber(holder.Stats.Cost.AmountHolder.Amount.Text),
            level = cleanNumber(holder.Info.Level.Before.Text),
            isMax = holder.Info.Level.After.Text:find("MAX") ~= nil
                 or holder.Info.Level.After.Text:find("Макс") ~= nil,
        }
    end

    local function updateObjectData(obj)
        if not obj or not obj.Parent then return nil end
        tp(obj)
        for i=1,10 do
            task.wait(0.2)
            local d = getUIData()
            if d and d.level > 0 then
                priceCache[obj] = {cost=d.cost, level=d.level, isMax=d.isMax}
                return priceCache[obj]
            end
        end
        return nil
    end

    -- Theo dõi kết quả trận đấu
    task.spawn(function()
        while true do
            local ok,vis = pcall(function() return lp.PlayerGui.Menus.GameResult.Visible end)
            if ok and vis then
                setStatus("Kết thúc trận — Đang dịch chuyển...")
                pcall(function()
                    Save.TotalGold = Save.TotalGold + cleanNumber(lp.PlayerGui.Hud.Reward.GoldAmount.Text)
                    saveData()
                end)
                ResultRemote:FireServer("teleport")
                task.wait(5)
            end
            task.wait(1)
        end
    end)

    -- Tìm căn cứ
    setStatus("Đang tìm căn cứ...")
    while not myBase do
        for _,b in pairs(workspace.Bases:GetChildren()) do
            local owner = b:GetAttribute("owner") or (b:FindFirstChild("Owner") and b.Owner.Value)
            if owner==lp.Name or owner=="" or owner==nil or owner=="None" then
                myBase=b; break
            end
        end
        task.wait(1)
    end
    setStatus("Căn cứ: "..myBase.Name)

    task.spawn(function()
        while true do 
            if _G.AutoRepair then BaseEvent:FireServer("repair") end
            task.wait(0.5) 
        end
    end)

    -- GIAI ĐOẠN 1: Cửa lv2
    setStatus("Nâng cấp Cửa lv2...")
    tp(myBase.Door)
    repeat
        task.wait(0.5)
        local d = getUIData()
        if d then
            if d.level >= 2 then break end
            if getBalance() >= d.cost then UpgradeEvent:FireServer("upgrade",myBase.Door); task.wait(0.5) end
        end
    until false

    -- GIAI ĐOẠN 1b: Farm chính lv3
    setStatus("Nâng cấp Farm lv3...")
    local mainFarm = nil
    repeat mainFarm=myBase.Tiles.Starter:FindFirstChild("Farm3"); task.wait(0.5) until mainFarm
    tp(mainFarm)
    repeat
        task.wait(0.5)
        local d = getUIData()
        if d then
            if d.level >= 2 then break end
            if getBalance() >= d.cost then UpgradeEvent:FireServer("upgrade",mainFarm); task.wait(0.5) end
        end
    until false

    -- GIAI ĐOẠN 2: Sắp xếp vị trí
    setStatus("Đang phân loại vị trí...")
    local allTiles = {}
    for _,t in pairs(myBase.Tiles:GetChildren()) do
        if t.Name=="Tile" or t:IsA("BasePart") then table.insert(allTiles,t) end
    end
    table.sort(allTiles,function(a,b)
        return (a:GetPivot().Position-myBase.Door:GetPivot().Position).Magnitude
             < (b:GetPivot().Position-myBase.Door:GetPivot().Position).Magnitude
    end)
    local turretTiles,farmTiles={},{}
    for i,t in ipairs(allTiles) do
        if i<=MAX_TURRETS then table.insert(turretTiles,t) else table.insert(farmTiles,t) end
    end

    local function buyUnit(tile, prefix)
        local n,pr,m = prefix.."1",100,0
        pcall(function()
            for _,item in pairs(lp.PlayerGui.Hud.Build.Holder.Scroller:GetChildren()) do
                if item.Name:sub(1,#prefix)==prefix then
                    local id=tonumber(item.Name:match("%d+")) or 0
                    if id>m then m,n,pr=id,item.Name,cleanNumber(item.Buy.Amount.Text) end
                end
            end
        end)
        while getBalance()<pr do task.wait(1) end
        tp(tile); task.wait(0.5)
        UnitEvent:FireServer("buy",n,tile)
        task.wait(1)
        return tile:FindFirstChildOfClass("Model")
    end

    local buildList={mainFarm}
    setStatus("Đang xây Farm...")
    for _,t in ipairs(farmTiles) do
        local m=buyUnit(t,"Farm"); if m then table.insert(buildList,m) end
    end
    setStatus("Đang xây Trụ...")
    for _,t in ipairs(turretTiles) do
        local m=buyUnit(t,"Turret"); if m then table.insert(buildList,m) end
    end

    -- GIAI ĐOẠN 3: Tính toán giá
    setStatus("Đang quét dữ liệu giá...")
    for _,obj in ipairs(buildList) do updateObjectData(obj) end
    updateObjectData(myBase.Door)

    -- Theo dõi Boss
    local defenseMode=false
    local farmsSold=false

    local function getBossLevel()
        local ok,text=pcall(function() return lp.PlayerGui.Hud.Boss.Title.Lvl.Text end)
        if not ok or not text then return nil,nil end
        local stripped=text:gsub("<[^>]+>",""):gsub("</[^>]+>","")
        local cur,max=stripped:match("(%d+)%s*/%s*(%d+)")
        return tonumber(cur),tonumber(max)
    end

    local function getNilByDebugId(name,debugId)
        if getnilinstances then
            for _,obj in pairs(getnilinstances()) do
                if obj.Name==name and obj:GetDebugId()==debugId then return obj end
            end
        end
        return nil
    end

    local function sellAllFarms()
        if farmsSold then return end
        for _,obj in ipairs(buildList) do
            if obj~=mainFarm and obj.Name:find("Farm") then
                pcall(function()
                    local target=getNilByDebugId(obj.Name,obj:GetDebugId())
                    if not target then target=obj end
                    UpgradeEvent:FireServer("sell",target)
                    task.wait(0.3)
                    priceCache[obj]=nil
                end)
            end
        end
        farmsSold=true
    end

    local function restoreFarms()
        if not farmsSold then return end
        farmsSold=false
        for _,t in ipairs(farmTiles) do
            local m=buyUnit(t,"Farm")
            if m then table.insert(buildList,m); updateObjectData(m) end
        end
    end

    task.spawn(function()
        while true do
            task.wait(1)
            local cur,max=getBossLevel()
            if cur and max then
                local danger=(cur>=max-2)
                if danger and not defenseMode then defenseMode=true; sellAllFarms()
                elseif not danger and defenseMode then defenseMode=false; restoreFarms() end
            end
        end
    end)

    -- VÒNG LẶP NÂNG CẤP CHÍNH (FIX CÚ PHÁP VÀ KẸT CỬA)
    while true do
        if not _G.AutoUpgrade then task.wait(1); continue end -- Dừng nếu tắt Auto
        local bestTarget, lowestPrice, maxUnitLevel = nil, math.huge, 0
        local dData = priceCache[myBase.Door]

        for obj, data in pairs(priceCache) do
            if obj and obj.Parent and obj ~= myBase.Door then
                if data.level > maxUnitLevel then maxUnitLevel = data.level end
            end
        end

        if dData and dData.level < 3 and maxUnitLevel >= 2 then
            bestTarget = myBase.Door
            lowestPrice = dData.cost
        else
            for obj, data in pairs(priceCache) do
                if obj and obj.Parent and not data.isMax then
                    local isFarm = obj ~= mainFarm and obj.Name:find("Farm")
                    if not(defenseMode and isFarm) then
                        if obj == mainFarm and data.level >= MAIN_FARM_LIMIT then continue end
                        if data.cost > 0 and data.cost < lowestPrice then
                            lowestPrice, bestTarget = data.cost, obj
                        end
                    end
                end
            end
            if dData and not dData.isMax then
                if dData.level < (maxUnitLevel + 1) or (maxUnitLevel >= 4 and dData.level < 6) then
                    if dData.cost < lowestPrice then
                        lowestPrice, bestTarget = dData.cost, myBase.Door
                    end
                end
            end
        end

        if bestTarget then
            if getBalance() >= lowestPrice then
                tp(bestTarget)
                task.wait(0.1)
                UpgradeEvent:FireServer("upgrade", bestTarget)
                task.wait(0.5)
                updateObjectData(bestTarget)
            end
        else
            updateObjectData(myBase.Door)
            for _, obj in ipairs(buildList) do updateObjectData(obj) end
        end
        task.wait(0.8)
    end
end
