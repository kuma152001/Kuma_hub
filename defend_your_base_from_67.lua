-- ============================================================
--   Kuma_Hub MegaScript v3.2  |  Base Tycoon + Lobby
--   Giữ nguyên 100% tính năng gốc | Giao diện Tiếng Việt
--   Sửa lỗi: Bán Farm khởi đầu để tránh kẹt nâng cấp
--   Thêm: Nút Bật/Tắt Auto Tổng (Master Toggle)
-- ============================================================

local MyLink = "https://raw.githubusercontent.com/kuma152001/Kuma_hub/refs/heads/main/defend_your_base_from_67.lua"

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService  = game:GetService("HttpService")
local RS           = game:GetService("RunService")
local lp           = Players.LocalPlayer
local CoreGui      = (gethui and gethui()) or game:GetService("CoreGui")

local LOBBY_ID = 102669100769936
local GAME_ID  = 97689234675651

-- BIẾN ĐIỀU KHIỂN AUTO TỔNG
_G.KumaAutoEnabled = _G.KumaAutoEnabled or true

-- ============================================================
-- SAVE DATA
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
-- QOT HELPER
-- ============================================================
local function registerQOT()
    local qot = nil
    pcall(function()
        if queue_on_teleport then qot = queue_on_teleport; return end
        if queue_on_teleports then qot = queue_on_teleports; return end
        if syn and syn.queue_on_teleport then qot = syn.queue_on_teleport; return end
        if fluxus and fluxus.queue_on_teleport then qot = fluxus.queue_on_teleport; return end
        if solara and solara.queue_on_teleport then qot = solara.queue_on_teleport; return end
        if wave and wave.queue_on_teleport then qot = wave.queue_on_teleport; return end
        if oxy and oxy.queue_on_teleport then qot = oxy.queue_on_teleport; return end
        if Hydrogen and Hydrogen.queue_on_teleport then qot = Hydrogen.queue_on_teleport; return end
    end)
    if qot then
        qot('repeat task.wait() until game:IsLoaded(); loadstring(game:HttpGet("' .. MyLink .. '"))()')
        print("[KumaHub] QOT registered")
    end
end
registerQOT()

-- ============================================================
-- GIAO DIỆN (GUI) - GIỮ NGUYÊN STYLE GỐC
-- ============================================================
pcall(function()
    for _,v in ipairs(CoreGui:GetChildren()) do
        if v.Name=="KumaHub_Main" then v:Destroy() end
    end
end)

local SG = Instance.new("ScreenGui", CoreGui)
SG.Name="KumaHub_Main"; SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

-- NÚT BẬT/TẮT AUTO NHANH
local MasterToggle = Instance.new("TextButton", SG)
MasterToggle.Size = UDim2.new(0, 160, 0, 40)
MasterToggle.Position = UDim2.new(0.5, -80, 0, 60)
MasterToggle.BackgroundColor3 = _G.KumaAutoEnabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
MasterToggle.Text = "AUTO: " .. (_G.KumaAutoEnabled and "ĐANG BẬT" or "ĐANG TẮT")
MasterToggle.TextColor3 = Color3.new(1, 1, 1); MasterToggle.Font = Enum.Font.GothamBlack; MasterToggle.TextSize = 14; MasterToggle.ZIndex = 50
Instance.new("UICorner", MasterToggle).CornerRadius = UDim.new(0, 8)
local MStroke = Instance.new("UIStroke", MasterToggle); MStroke.Thickness = 2; MStroke.Color = Color3.new(1,1,1); MStroke.Transparency = 0.6

MasterToggle.MouseButton1Click:Connect(function()
    _G.KumaAutoEnabled = not _G.KumaAutoEnabled
    MasterToggle.Text = "AUTO: " .. (_G.KumaAutoEnabled and "ĐANG BẬT" or "ĐANG TẮT")
    MasterToggle.BackgroundColor3 = _G.KumaAutoEnabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
end)

local Overlay = Instance.new("Frame", SG)
Overlay.Size=UDim2.fromScale(1,1); Overlay.BackgroundColor3=Color3.fromRGB(40,0,70); Overlay.BackgroundTransparency=0.5; Overlay.BorderSizePixel=0; Overlay.ZIndex=1
local OG=Instance.new("UIGradient",Overlay)
OG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(60,0,100)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(20,0,50)),ColorSequenceKeypoint.new(1,Color3.fromRGB(80,10,120))}; OG.Rotation=135

local TopBar=Instance.new("Frame",SG)
TopBar.Size=UDim2.new(1,0,0,44); TopBar.BackgroundColor3=Color3.fromRGB(25,0,45); TopBar.BackgroundTransparency=0.15; TopBar.BorderSizePixel=0; TopBar.ZIndex=10
local TBG=Instance.new("UIGradient",TopBar)
TBG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(90,20,180)),ColorSequenceKeypoint.new(1,Color3.fromRGB(30,5,80))}

local Logo=Instance.new("TextLabel",TopBar)
Logo.Size=UDim2.new(0,220,1,0); Logo.Position=UDim2.fromOffset(16,0); Logo.BackgroundTransparency=1; Logo.Text="K U M A  H U B"; Logo.TextColor3=Color3.fromRGB(220,160,255); Logo.Font=Enum.Font.GothamBlack; Logo.TextSize=20; Logo.TextXAlignment=Enum.TextXAlignment.Left; Logo.ZIndex=11

local StatusLbl=Instance.new("TextLabel",TopBar)
StatusLbl.Size=UDim2.new(0,500,1,0); StatusLbl.Position=UDim2.new(1,-505,0,0); StatusLbl.BackgroundTransparency=1; StatusLbl.Text="Khởi tạo..."; StatusLbl.TextColor3=Color3.fromRGB(180,255,180); StatusLbl.Font=Enum.Font.GothamBold; StatusLbl.TextSize=13; StatusLbl.TextXAlignment=Enum.TextXAlignment.Right; StatusLbl.ZIndex=11
local function setStatus(txt) StatusLbl.Text="@ "..txt end

local BotBar=Instance.new("Frame",SG)
BotBar.Size=UDim2.new(1,0,0,36); BotBar.Position=UDim2.new(0,0,1,-36); BotBar.BackgroundColor3=Color3.fromRGB(20,0,40); BotBar.BackgroundTransparency=0.2; BotBar.BorderSizePixel=0; BotBar.ZIndex=10
local function mkBotLbl(xScale,color)
    local l=Instance.new("TextLabel",BotBar); l.Size=UDim2.new(0.33,0,1,0); l.Position=UDim2.fromScale(xScale,0); l.BackgroundTransparency=1; l.Font=Enum.Font.GothamBold; l.TextSize=14; l.ZIndex=11; l.TextColor3=color; return l
end
local TimeLbl=mkBotLbl(0,Color3.fromRGB(200,160,255))
local GoldLbl=mkBotLbl(0.33,Color3.fromRGB(255,220,100))
local CashLbl=mkBotLbl(0.66,Color3.fromRGB(100,255,160))

task.spawn(function()
    while true do
        task.wait(1)
        Save.TotalTime=Save.TotalTime+1
        if Save.TotalTime%10==0 then saveData() end
        TimeLbl.Text="Thời gian: "..fmtTime(Save.TotalTime); GoldLbl.Text="Vàng: "..Save.TotalGold
        pcall(function() CashLbl.Text="Tiền: "..lp.PlayerGui.Hud.Currency.Amount.Text end)
    end
end)

-- ============================================================
-- LOBBY
-- ============================================================
if game.PlaceId == LOBBY_ID then
    setStatus("Sảnh Chờ")
    local MapData={["Rừng"]="Map1",["Sa Mạc"]="Map2",["Băng Giá"]="Map3",["Núi Lửa"]="Map4",["Thiên Hà"]="Map5",["Giới Hạn"]="Map6",["Tốt nhất"]="Best"}
    local MapOrder={"Map5","Map4","Map3","Map2","Map1"}
    local DiffList={"Dễ","Trung Bình","Khó","Vô Tận","Tốt nhất"}
    local DiffMap={["Dễ"]="Easy",["Trung Bình"]="Medium",["Khó"]="Hard",["Vô Tận"]="Endless",["Tốt nhất"]="Best difficulty"}

    local F=Instance.new("Frame",SG)
    F.Size=UDim2.new(0,420,0,520); F.Position=UDim2.new(0.5,-210,0.5,-260); F.BackgroundColor3=Color3.fromRGB(18,5,32); F.BackgroundTransparency=0.08; F.ZIndex=20; Instance.new("UICorner",F).CornerRadius=UDim.new(0,16)
    local FG=Instance.new("UIGradient",F); FG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(35,8,65)),ColorSequenceKeypoint.new(1,Color3.fromRGB(12,2,28))}; FG.Rotation=45

    local function mkSection(title,yOff,items,onSelect,isActive)
        local lbl=Instance.new("TextLabel",F); lbl.Size=UDim2.new(1,-32,0,18); lbl.Position=UDim2.fromOffset(16,yOff); lbl.BackgroundTransparency=1; lbl.Text=title; lbl.TextColor3=Color3.fromRGB(150,100,220); lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=21
        local sf=Instance.new("ScrollingFrame",F); sf.Size=UDim2.new(1,-32,0,110); sf.Position=UDim2.fromOffset(16,yOff+20); sf.BackgroundColor3=Color3.fromRGB(10,2,22); sf.BackgroundTransparency=0.3; sf.BorderSizePixel=0; sf.CanvasSize=UDim2.new(0,0,0,#items*38); sf.ZIndex=21; Instance.new("UICorner",sf).CornerRadius=UDim.new(0,10)
        local ll=Instance.new("UIListLayout",sf); ll.Padding=UDim.new(0,4); local pad=Instance.new("UIPadding",sf); pad.PaddingTop=UDim.new(0,6); pad.PaddingLeft=UDim.new(0,6)
        local btns={}
        for _,name in ipairs(items) do
            local btn=Instance.new("TextButton",sf); btn.Size=UDim2.new(1,-12,0,30); btn.Font=Enum.Font.GothamBold; btn.TextSize=13; btn.Text=name; btn.ZIndex=22; Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
            local act=isActive(name); btn.BackgroundColor3=act and Color3.fromRGB(110,40,200) or Color3.fromRGB(35,15,60); btn.TextColor3=act and Color3.new(1,1,1) or Color3.fromRGB(180,140,220)
            btn.MouseButton1Click:Connect(function() for _,b in pairs(btns) do b.BackgroundColor3=Color3.fromRGB(35,15,60); b.TextColor3=Color3.fromRGB(180,140,220) end btn.BackgroundColor3=Color3.fromRGB(110,40,200); btn.TextColor3=Color3.new(1,1,1); onSelect(name) end)
            btns[name]=btn
        end
    end

    mkSection("CHỌN BẢN ĐỒ", 48, {"Rừng","Sa Mạc","Băng Giá","Núi Lửa","Thiên Hà","Giới Hạn","Tốt nhất"}, function(v)
        if v=="Tốt nhất" then Save.IsBestMap=true else Save.IsBestMap=false; Save.SelectedMap=MapData[v] end saveData()
    end, function(n) return (MapData[n]==Save.SelectedMap and not Save.IsBestMap) or (n=="Tốt nhất" and Save.IsBestMap) end)

    mkSection("CHỌN ĐỘ KHÓ", 195, DiffList, function(v)
        local rv=DiffMap[v]; if rv=="Best difficulty" then Save.IsBestDiff=true else Save.IsBestDiff=false; Save.SelectedDiff=rv end saveData()
    end, function(n) return (DiffMap[n]==Save.SelectedDiff and not Save.IsBestDiff) or (DiffMap[n]=="Best difficulty" and Save.IsBestDiff) end)

    local function mkBtn(txt,color,xOff,w,cb)
        local btn=Instance.new("TextButton",F); btn.Size=UDim2.new(0,w,0,44); btn.Position=UDim2.fromOffset(xOff,460); btn.BackgroundColor3=color; btn.Text=txt; btn.TextColor3=Color3.new(1,1,1); btn.Font=Enum.Font.GothamBlack; btn.TextSize=14; btn.ZIndex=22; Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
        btn.MouseButton1Click:Connect(cb); return btn
    end

    local autoBtn=mkBtn("AUTO JOIN: "..(Save.AutoStartQueue and "BẬT" or "TẮT"), Save.AutoStartQueue and Color3.fromRGB(40,140,40) or Color3.fromRGB(140,30,30),16,180,function() end)
    local startBtn=mkBtn("VÀO HÀNG CHỜ",Color3.fromRGB(110,40,200),208,196,function() end)

    local function fireQueue()
        if not _G.KumaAutoEnabled then return end
        setStatus("Tham gia hàng chờ...")
        pcall(function()
            local qf = workspace:FindFirstChild("Queues")
            if qf then for _, q in ipairs(qf:GetChildren()) do local hb = q:FindFirstChild("Hitbox")
                if hb then lp.Character.HumanoidRootPart.CFrame = hb.CFrame; break end end end
        end)
        task.wait(0.5)
        local Remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Queue")
        local maps = Save.IsBestMap and MapOrder or {Save.SelectedMap}
        local diffs = Save.IsBestDiff and {"Endless","Hard","Medium","Easy"} or {Save.SelectedDiff}
        for _,m in ipairs(maps) do for _,d in ipairs(diffs) do Remote:FireServer("create", m, 4, d) task.wait(0.1) end end
    end

    startBtn.MouseButton1Click:Connect(fireQueue)
    autoBtn.MouseButton1Click:Connect(function() Save.AutoStartQueue=not Save.AutoStartQueue; autoBtn.Text="AUTO JOIN: "..(Save.AutoStartQueue and "BẬT" or "TẮT"); autoBtn.BackgroundColor3=Save.AutoStartQueue and Color3.fromRGB(40,140,40) or Color3.fromRGB(140,30,30); saveData() end)
    
    local dragging,dragStart,startPos
    F.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; dragStart=inp.Position; startPos=F.Position end end)
    game:GetService("UserInputService").InputChanged:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseMovement and dragging then
        local d=inp.Position-dragStart; F.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)
    game:GetService("UserInputService").InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)

    if Save.AutoStartQueue then task.spawn(function() for i=5,1,-1 do startBtn.Text="AUTO TRONG "..i.."s"; task.wait(1) end fireQueue() end) end

-- ============================================================
-- TYCOON
-- ============================================================
elseif game.PlaceId == GAME_ID then
    local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
    local UnitEvent, UpgradeEvent, BaseEvent, ResultRemote = Remotes.Unit, Remotes.Upgrade, Remotes.Base, Remotes.Result
    local MAX_TURRETS, MAIN_FARM_LIMIT, myBase, priceCache = 10, 4, nil, {}

    local function cleanNumber(text) return tonumber(tostring(text):gsub("<[^>]+>",""):gsub("[^%d]","")) or 0 end
    local function getBalance() return cleanNumber(lp.PlayerGui.Hud.Currency.Amount.Text) end
    local function tp(cf) lp.Character.HumanoidRootPart.CFrame = typeof(cf)=="CFrame" and cf or (cf:IsA("Model") and cf:GetPivot() or cf.CFrame) end

    local function getUIData()
        local h = lp.PlayerGui.Hud.Upgrade.Holder; if not h.Visible then return nil end
        return {cost=cleanNumber(h.Stats.Cost.AmountHolder.Amount.Text), level=cleanNumber(h.Info.Level.Before.Text), isMax=h.Info.Level.After.Text:find("MAX")~=nil or h.Info.Level.After.Text:find("Макс")~=nil}
    end

    local function updateObjectData(obj)
        if not obj or not obj.Parent then return nil end
        tp(obj); for i=1,10 do task.wait(0.2); local d = getUIData(); if d and d.level > 0 then priceCache[obj] = d return d end end return nil
    end

    task.spawn(function() while true do if lp.PlayerGui.Menus.GameResult.Visible and _G.KumaAutoEnabled then
        pcall(function() Save.TotalGold = Save.TotalGold + cleanNumber(lp.PlayerGui.Hud.Reward.GoldAmount.Text) saveData() end)
        ResultRemote:FireServer("teleport"); task.wait(5) end task.wait(1) end 
    end)

    while not myBase do for _,b in pairs(workspace.Bases:GetChildren()) do
        local o = b:GetAttribute("owner") or (b:FindFirstChild("Owner") and b.Owner.Value)
        if o==lp.Name or o=="" or o==nil or o=="None" then myBase=b break end
    end task.wait(1) end
    task.spawn(function() while true do if _G.KumaAutoEnabled then BaseEvent:FireServer("repair") end task.wait(0.5) end end)

    -- GIAI ĐOẠN 1: Cửa lv2
    setStatus("Nâng Cửa lv2...")
    tp(myBase.Door)
    repeat if not _G.KumaAutoEnabled then task.wait(1) continue end
        task.wait(0.5); local d=getUIData() if d then if d.level>=2 then break end if getBalance()>=d.cost then UpgradeEvent:FireServer("upgrade",myBase.Door) end end 
    until false

    -- GIAI ĐOẠN 1b: BÁN FARM KHỞI ĐẦU (ĐÃ SỬA THEO YÊU CẦU)
    setStatus("BÁN Farm chính để giải phóng...")
    local mainFarm = nil
    repeat mainFarm=myBase.Tiles.Starter:FindFirstChild("Farm3") task.wait(0.5) until mainFarm
    tp(mainFarm); task.wait(0.5)
    pcall(function() UpgradeEvent:FireServer("sell", mainFarm) end)
    task.wait(1)

    -- GIAI ĐOẠN 2: Build hệ thống
    setStatus("Đang sắp xếp vị trí...")
    local allTiles = {}
    for _,t in pairs(myBase.Tiles:GetChildren()) do if t.Name=="Tile" or t:IsA("BasePart") then table.insert(allTiles,t) end end
    table.sort(allTiles, function(a,b) return (a:GetPivot().Position-myBase.Door:GetPivot().Position).Magnitude < (b:GetPivot().Position-myBase.Door:GetPivot().Position).Magnitude end)
    local turretTiles, farmTiles = {}, {}
    for i,t in ipairs(allTiles) do if i<=MAX_TURRETS then table.insert(turretTiles,t) else table.insert(farmTiles,t) end end

    local function buyUnit(tile, prefix)
        local n,pr,m = prefix.."1",100,0
        pcall(function() for _,item in pairs(lp.PlayerGui.Hud.Build.Holder.Scroller:GetChildren()) do
            if item.Name:sub(1,#prefix)==prefix then local id=tonumber(item.Name:match("%d+")) or 0
            if id>m then m,n,pr=id,item.Name,cleanNumber(item.Buy.Amount.Text) end end end
        end)
        while getBalance()<pr do if not _G.KumaAutoEnabled then task.wait(1) else task.wait(0.5) end end
        tp(tile); task.wait(0.5); UnitEvent:FireServer("buy",n,tile); task.wait(1)
        return tile:FindFirstChildOfClass("Model")
    end

    local buildList = {}
    setStatus("Xây Nông trại...")
    for _,t in ipairs(farmTiles) do local m=buyUnit(t,"Farm") if m then table.insert(buildList,m) end end
    setStatus("Xây Trụ...")
    for _,t in ipairs(turretTiles) do local m=buyUnit(t,"Turret") if m then table.insert(buildList,m) end end

    -- BOSS WATCHER & SMART UPGRADE
    local defenseMode, farmsSold = false, false
    local function getBossLevel()
        local ok,text=pcall(function() return lp.PlayerGui.Hud.Boss.Title.Lvl.Text end); if not ok or not text then return nil,nil end
        local cur,max=text:gsub("<[^>]+>",""):match("(%d+)%s*/%s*(%d+)") return tonumber(cur), tonumber(max)
    end
    local function getNilObj(n,id) for _,o in pairs(getnilinstances()) do if o.Name==n and o:GetDebugId()==id then return o end end return nil end

    task.spawn(function()
        while true do task.wait(1)
            local cur,max=getBossLevel()
            if cur and max then local danger=(cur>=max-2)
                if danger and not defenseMode then
                    defenseMode=true; farmsSold=true; setStatus("THỦ NHÀ - Bán Farm...")
                    for _,o in ipairs(buildList) do if o.Name:find("Farm") then 
                        local t=getNilObj(o.Name, o:GetDebugId()) or o; pcall(function() UpgradeEvent:FireServer("sell", t) end) task.wait(0.2) priceCache[o]=nil
                    end end
                elseif not danger and defenseMode then
                    defenseMode=false; farmsSold=false; setStatus("Khôi phục kinh tế...")
                    for _,t in ipairs(farmTiles) do local m=buyUnit(t,"Farm") if m then table.insert(buildList,m); updateObjectData(m) end end
                end
            end
        end
    end)

    for _,o in ipairs(buildList) do updateObjectData(o) end updateObjectData(myBase.Door)
    
    while true do
        if not _G.KumaAutoEnabled then setStatus("Auto đang TẮT"); task.wait(1); continue end
        local best, low, maxLvl = nil, math.huge, 0
        for obj, data in pairs(priceCache) do
            if obj and obj.Parent and not data.isMax then
                if data.level > maxLvl then maxLvl = data.level end
                if not (defenseMode and obj.Name:find("Farm")) then
                    if obj ~= myBase.Door and data.cost < low then low, best = data.cost, obj end
                end
            end
        end
        local dData = priceCache[myBase.Door]
        if dData and not dData.isMax then
            if best and priceCache[best].level >= 4 and dData.level < 6 then best, low = myBase.Door, dData.cost end
            if dData.level < (maxLvl + 1) and dData.cost < low then low, best = dData.cost, myBase.Door end
        end
        if best and getBalance()>=low then 
            setStatus((defenseMode and "[THỦ] " or "").."Nâng "..best.Name.." ($"..low..")")
            UpgradeEvent:FireServer("upgrade", best); task.wait(0.5); updateObjectData(best)
        else
            for _,o in ipairs(buildList) do updateObjectData(o) end updateObjectData(myBase.Door)
        end
        task.wait(1)
    end
end
