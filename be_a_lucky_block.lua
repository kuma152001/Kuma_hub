-- ╔══════════════════════════════════════════════════════╗
-- ║           KUMA HUB v2 — Be a Lucky Block             ║
-- ║     Auto Event + Auto Farm + Per-Rarity Sell GUI     ║
-- ╚══════════════════════════════════════════════════════╝

pcall(function() _G.ScriptRunning = false end)
task.wait(0.5)
pcall(function()
    for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
        if gui.Name == "KumaHub" or gui.Name == "Fluent" or gui.Name == "Rayfield" then
            pcall(function() gui:Destroy() end)
        end
    end
end)
task.wait(0.3)
_G.ScriptRunning = true

-- ════════════════════════════════════════════════════════
--  SERVICES & LOCALS
-- ════════════════════════════════════════════════════════
local Players      = game:GetService("Players")
local RS           = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local VirtualUser  = game:GetService("VirtualUser")
local player       = Players.LocalPlayer
local mouse        = player:GetMouse()

local knit = RS
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.7.0")
    :WaitForChild("knit")
    :WaitForChild("Services")

-- ════════════════════════════════════════════════════════
--  REMOTES
-- ════════════════════════════════════════════════════════
local claimGift    = knit:WaitForChild("PlaytimeRewardService"):WaitForChild("RF"):WaitForChild("ClaimGift")
local rebirth      = knit:WaitForChild("RebirthService"):WaitForChild("RF"):WaitForChild("Rebirth")
local claimPass    = knit:WaitForChild("SeasonPassService"):WaitForChild("RF"):WaitForChild("ClaimPassReward")
local redeemCode   = knit:WaitForChild("CodesService"):WaitForChild("RF"):WaitForChild("RedeemCode")
local buySkin      = knit:WaitForChild("SkinService"):WaitForChild("RF"):WaitForChild("BuySkin")
local sellRemote   = knit:WaitForChild("InventoryService"):WaitForChild("RF"):WaitForChild("SellBrainrot")
local pickupRemote = knit:WaitForChild("ContainerService"):WaitForChild("RF"):WaitForChild("PickupBrainrot")
local upgradeSpd   = knit:WaitForChild("UpgradesService"):WaitForChild("RF"):WaitForChild("Upgrade")
local upgradeBR    = knit:WaitForChild("ContainerService"):WaitForChild("RF"):WaitForChild("UpgradeBrainrot")

local runningRF  = knit:WaitForChild("RunningService"):WaitForChild("RF")
local startRun   = runningRF:WaitForChild("StartRun")
local startMove  = runningRF:WaitForChild("StartMove")
local endMove    = runningRF:WaitForChild("EndMove")
local updateCF   = runningRF:WaitForChild("UpdateCFrame")
local openBlock  = runningRF:WaitForChild("OpenLuckyBlock")
local caughtRF   = runningRF:WaitForChild("Caught")
local reloadChar = knit:WaitForChild("PlayerService"):WaitForChild("RF"):WaitForChild("ReloadCharacter")

-- ════════════════════════════════════════════════════════
--  BRAINROT DATA
-- ════════════════════════════════════════════════════════
local RARITY_ORDER = {"Normal","Candy","Gold","Diamond","Void"}
local RARITY_COLOR = {
    Normal  = Color3.fromRGB(156,163,175),
    Candy   = Color3.fromRGB(236,72,153),
    Gold    = Color3.fromRGB(245,158,11),
    Diamond = Color3.fromRGB(59,130,246),
    Void    = Color3.fromRGB(139,92,246),
}
local keepState = {}
local BRAINROT_LIST = {
    {name="La Vacca Saturno Saturnita",  section="Special", rarity="Void"},
    {name="Las Vaquitas Saturnitas",      section="Special", rarity="Diamond"},
    {name="Agarrini Lapalini",            section="Special", rarity="Diamond"},
    {name="Pipi Potato",                  section="Special", rarity="Gold"},
    {name="Graipus Medus",               section="Special", rarity="Gold"},
    {name="Tigrullini Watermellini",      section="Special", rarity="Gold"},
    {name="Dragoni Cannelloni",           section="Special", rarity="Gold"},
    {name="Boneca Ambalabu",             section="Special", rarity="Gold"},
    {name="Karkirkur",                   section="Special", rarity="Candy"},
    {name="Luminous Yoni",               section="Special", rarity="Diamond"},
    {name="67",                          section="Special", rarity="Normal"},
    {name="Meow!",                       section="Special", rarity="Candy"},
    {name="Chachechi",                   section="Special", rarity="Gold"},
    {name="Strawberry Elephant",         section="Special", rarity="Gold"},
    {name="To To To Sahur",             section="Cyber",   rarity="Void"},
    {name="Angelzini Bananini",         section="Angelic", rarity="Diamond"},
    {name="Angela Larila",              section="Angelic", rarity="Diamond"},
    {name="Angel Bisonte Giuppitere",   section="Angelic", rarity="Diamond"},
    {name="Angel Job Job Sahur",        section="Angelic", rarity="Gold"},
    {name="Angelinni Octossini",        section="Angelic", rarity="Gold"},
    {name="Devilcino Assassino",        section="Demonic", rarity="Void"},
    {name="Devupat Kepat Prekupat",     section="Demonic", rarity="Diamond"},
    {name="Diavolero Tralala",          section="Demonic", rarity="Diamond"},
    {name="Malamevil",                  section="Demonic", rarity="Diamond"},
    {name="Devilivion",                 section="Demonic", rarity="Void"},
}
for _, b in ipairs(BRAINROT_LIST) do
    keepState[b.name] = {keepAll=true, rarities={Normal=true,Candy=true,Gold=true,Diamond=true,Void=true}}
end

-- ════════════════════════════════════════════════════════
--  SHARED FLAGS
-- ════════════════════════════════════════════════════════
_G.EventRunning = false
_G.FarmRunning  = false

-- ════════════════════════════════════════════════════════
--  HELPERS
-- ════════════════════════════════════════════════════════
local suffix = {K=1e3,M=1e6,B=1e9,T=1e12,Qa=1e15,Qi=1e18,Sx=1e21,Sp=1e24,Oc=1e27,No=1e30,Dc=1e33}
local function parseCash(text)
    text = text:gsub("%$",""):gsub(",",""):gsub("%s+","")
    local num = tonumber(text:match("[%d%.]+"))
    local suf = text:match("%a+")
    if not num then return 0 end
    if suf and suffix[suf] then return num*suffix[suf] end
    return num
end

local skins = {
    "prestige_mogging_luckyblock","mogging_luckyblock","colossus_luckyblock",
    "inferno_luckyblock","divine_luckyblock","spirit_luckyblock",
    "cyborg_luckyblock","void_luckyblock","gliched_luckyblock",
    "lava_luckyblock","freezy_luckyblock","fairy_luckyblock"
}

local function findMyPlot()
    local pf = workspace:FindFirstChild("Plots"); if not pf then return nil end
    for _, outer in pairs(pf:GetChildren()) do
        local inner = outer:FindFirstChild(outer.Name)
        if inner then
            for _, v in pairs(inner:GetDescendants()) do
                if v:IsA("BillboardGui") and v.Name:find(player.Name) then return inner end
            end
        end
    end
    return nil
end

local function getMyModel()
    local f = workspace:FindFirstChild("RunningModels"); if not f then return nil end
    for _, m in ipairs(f:GetChildren()) do
        if m:GetAttribute("OwnerId") == player.UserId then return m end
    end
    return nil
end

-- Safe wait với timeout cứng — KHÔNG BAO GIỜ kẹt vĩnh viễn
local function safeWait(condFn, timeout, interval)
    interval = interval or 0.2
    local t0 = tick()
    while tick()-t0 < timeout and _G.ScriptRunning do
        if condFn() then return true end
        task.wait(interval)
    end
    return false
end

local function getCharParts()
    local char = player.Character; if not char then return nil,nil,nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return nil,nil,nil end
    return char,root,hum
end

-- Reset character + chờ respawn (timeout cứng 12s)
local function doReset()
    local oldChar = player.Character
    pcall(function()
        local hum = oldChar and oldChar:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end)
    task.wait(0.3)
    pcall(function() reloadChar:InvokeServer() end)
    safeWait(function()
        local c = player.Character
        return c~=nil and c~=oldChar and c:FindFirstChild("HumanoidRootPart")~=nil
    end, 12, 0.2)
    task.wait(0.5)
end

local function teleModel(model, cf)
    for _=1,3 do
        if not model or not model.Parent then break end
        pcall(function()
            if model.PrimaryPart then model:SetPrimaryPartCFrame(cf)
            else local p = model:FindFirstChildWhichIsA("BasePart"); if p then p.CFrame=cf end end
        end)
        task.wait(0.15)
    end
end

-- ════════════════════════════════════════════════════════
--  SELL LOGIC
-- ════════════════════════════════════════════════════════
local function getBrainrotInfo(item)
    local rarity,name = "Normal",""
    local rl = item:FindFirstChild("Rarity",true)
    if rl and rl:IsA("TextLabel") then rarity=rl.Text end
    local tf = item:FindFirstChild("Title",true)
    if tf then local tl=tf:FindFirstChild("TextLabel"); if tl then name=tl.Text end end
    if name=="" then
        for _,c in pairs(item:GetDescendants()) do
            if c:IsA("TextLabel") and c.Name=="TextLabel" then
                local t=c.Text; if t~="" and not t:find("%$") and t~="Sell $" then name=t; break end
            end
        end
    end
    return name,rarity
end

local function shouldSell(name,rarity)
    local s=keepState[name]; if not s then return true end
    if s.keepAll then return false end
    return not (s.rarities[rarity]==true)
end

local function sellBrainrots()
    local count=0
    pcall(function()
        local sf=player.PlayerGui.Windows.SellBrainrots.ShopContainer.ScrollingFrame
        for _,item in pairs(sf:GetChildren()) do
            local eid=item:GetAttribute("EntityId"); if not eid then continue end
            local name,rarity=getBrainrotInfo(item)
            if shouldSell(name,rarity) then
                pcall(function() sellRemote:InvokeServer(eid) end)
                count+=1; task.wait(0.1)
            end
        end
    end)
    return count
end

-- ════════════════════════════════════════════════════════
--  GUI SETUP
-- ════════════════════════════════════════════════════════
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KumaHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local C = {
    bg        = Color3.fromRGB(13,13,18),
    surface   = Color3.fromRGB(20,20,28),
    surface2  = Color3.fromRGB(28,28,38),
    surface3  = Color3.fromRGB(35,35,48),
    border    = Color3.fromRGB(45,45,62),
    accent    = Color3.fromRGB(99,102,241),
    accentHov = Color3.fromRGB(129,140,248),
    accentDim = Color3.fromRGB(55,58,160),
    text      = Color3.fromRGB(235,235,255),
    textMuted = Color3.fromRGB(120,120,155),
    textDim   = Color3.fromRGB(65,65,95),
    success   = Color3.fromRGB(52,211,153),
    warn      = Color3.fromRGB(251,191,36),
    danger    = Color3.fromRGB(239,68,68),
    event     = Color3.fromRGB(245,158,11),
    white     = Color3.fromRGB(255,255,255),
}

local function tw(obj,props,t,style,dir)
    TweenService:Create(obj,TweenInfo.new(t or 0.15,style or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out),props):Play()
end
local function mk(cls,props,parent)
    local i=Instance.new(cls); for k,v in pairs(props or {}) do i[k]=v end
    if parent then i.Parent=parent end; return i
end
local function frame(props,parent)
    props.BackgroundTransparency=props.BackgroundTransparency~=nil and props.BackgroundTransparency or 1
    props.BorderSizePixel=0; props.BackgroundColor3=props.BackgroundColor3 or Color3.new()
    return mk("Frame",props,parent)
end
local function label(props,parent)
    props.BackgroundTransparency=1; props.BorderSizePixel=0
    props.Font=props.Font or Enum.Font.GothamMedium
    props.TextColor3=props.TextColor3 or C.text
    props.TextXAlignment=props.TextXAlignment or Enum.TextXAlignment.Left
    return mk("TextLabel",props,parent)
end
local function btn(props,parent)
    local orig=props.BackgroundColor3 or C.surface2
    props.BackgroundColor3=orig; props.BorderSizePixel=0
    props.Font=props.Font or Enum.Font.GothamMedium
    props.TextColor3=props.TextColor3 or C.text; props.AutoButtonColor=false
    local b=mk("TextButton",props,parent)
    mk("UICorner",{CornerRadius=UDim.new(0,6)},b)
    b.MouseEnter:Connect(function() tw(b,{BackgroundColor3=orig:Lerp(C.white,0.09)}) end)
    b.MouseLeave:Connect(function() tw(b,{BackgroundColor3=orig}) end)
    b.MouseButton1Down:Connect(function() tw(b,{BackgroundColor3=orig:Lerp(C.white,0.2)},0.07) end)
    b.MouseButton1Up:Connect(function() tw(b,{BackgroundColor3=orig}) end)
    return b
end
local function corner(r,p) return mk("UICorner",{CornerRadius=UDim.new(0,r)},p) end
local function stroke(t,c,p) return mk("UIStroke",{Thickness=t,Color=c or C.border,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},p) end
local function pad(a,b2,c,d2,p) return mk("UIPadding",{PaddingTop=UDim.new(0,a),PaddingRight=UDim.new(0,b2),PaddingBottom=UDim.new(0,c),PaddingLeft=UDim.new(0,d2)},p) end
local function vlist(gap,p) return mk("UIListLayout",{Padding=UDim.new(0,gap),SortOrder=Enum.SortOrder.LayoutOrder,FillDirection=Enum.FillDirection.Vertical},p) end

-- ════════════════════════════════════════════════════════
--  MAIN WINDOW
-- ════════════════════════════════════════════════════════
local Main=frame({Size=UDim2.new(0,520,0,600),Position=UDim2.new(0.5,-260,0.5,-300),BackgroundColor3=C.bg,BackgroundTransparency=0,ClipsDescendants=true},ScreenGui)
corner(12,Main); stroke(1,C.border,Main)

do -- Drag (title bar only)
    local dragging,dragStart,startPos
    Main.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            if (inp.Position.Y-Main.AbsolutePosition.Y)<=44 then
                dragging=true; dragStart=inp.Position; startPos=Main.Position
            end
        end
    end)
    Main.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
            local d=inp.Position-dragStart
            Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

-- Title Bar
local TBar=frame({Size=UDim2.new(1,0,0,44),BackgroundColor3=C.surface,BackgroundTransparency=0},Main)
corner(12,TBar)
frame({Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-12),BackgroundColor3=C.surface,BackgroundTransparency=0},TBar)
stroke(1,C.border,TBar)
local ld=frame({Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,14,0.5,-4),BackgroundColor3=C.accent,BackgroundTransparency=0},TBar)
corner(4,ld)
label({Size=UDim2.new(1,-110,1,0),Position=UDim2.new(0,28,0,0),Text="Kuma Hub  v2",TextSize=14,Font=Enum.Font.GothamBold,TextColor3=C.text},TBar)

local function winBtn(xOff,col,txt)
    local b=btn({Size=UDim2.new(0,26,0,26),Position=UDim2.new(1,xOff,0.5,-13),Text=txt,TextSize=11,BackgroundColor3=col,TextColor3=C.white,Font=Enum.Font.GothamBold},TBar)
    corner(6,b); return b
end
local CloseBtn=winBtn(-36,C.danger,"✕")
local MinBtn=winBtn(-68,Color3.fromRGB(55,55,80),"—")
CloseBtn.MouseButton1Click:Connect(function()
    _G.ScriptRunning=false; _G.EventRunning=false; _G.FarmRunning=false
    tw(Main,{Size=UDim2.new(0,520,0,0),BackgroundTransparency=1},0.2)
    task.wait(0.22); ScreenGui:Destroy()
end)
local minimized=false
MinBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    tw(Main,{Size=minimized and UDim2.new(0,520,0,44) or UDim2.new(0,520,0,600)},0.2)
end)

-- Status Bar
local SBar=frame({Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,0,44),BackgroundColor3=C.surface2,BackgroundTransparency=0},Main)
local sLbl=label({Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,10,0,0),Text="● Sẵn sàng",TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.success},SBar)
local function setStatus(txt,col) sLbl.Text="● "..txt; sLbl.TextColor3=col or C.success end

-- Notify holder
local NHolder=frame({Size=UDim2.new(0,300,0,0),Position=UDim2.new(1,-310,1,-10),AnchorPoint=Vector2.new(0,1),ClipsDescendants=false,ZIndex=200},ScreenGui)
mk("UIListLayout",{Padding=UDim.new(0,4),FillDirection=Enum.FillDirection.Vertical,VerticalAlignment=Enum.VerticalAlignment.Bottom,SortOrder=Enum.SortOrder.LayoutOrder},NHolder)
local nCnt=0
local function notify(msg,col)
    col=col or C.accent; nCnt+=1
    local n=frame({Size=UDim2.new(1,0,0,0),BackgroundColor3=C.surface,BackgroundTransparency=0,ClipsDescendants=true,LayoutOrder=nCnt,ZIndex=200},NHolder)
    corner(8,n); stroke(1,col,n)
    frame({Size=UDim2.new(0,3,1,0),BackgroundColor3=col,BackgroundTransparency=0,ZIndex=201},n)
    label({Size=UDim2.new(1,-14,1,0),Position=UDim2.new(0,10,0,0),Text=msg,TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.text,TextWrapped=true,ZIndex=201},n)
    tw(n,{Size=UDim2.new(1,0,0,36)},0.2,Enum.EasingStyle.Back)
    task.delay(3.5,function() tw(n,{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0)},0.25); task.wait(0.3); pcall(function() n:Destroy() end) end)
end

-- Tab Bar
local TabBar=frame({Size=UDim2.new(1,0,0,38),Position=UDim2.new(0,0,0,66),BackgroundColor3=C.surface,BackgroundTransparency=0},Main)
stroke(1,C.border,TabBar); pad(0,6,0,6,TabBar)
mk("UIListLayout",{Padding=UDim.new(0,3),FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder},TabBar)

-- Content area
local Content=frame({Size=UDim2.new(1,0,1,-104),Position=UDim2.new(0,0,0,104),ClipsDescendants=true},Main)

local function makeScrollPage()
    local sf=mk("ScrollingFrame",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=3,ScrollBarImageColor3=C.accentDim,
        CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
        Visible=false,ElasticBehavior=Enum.ElasticBehavior.Never,
    },Content)
    pad(8,8,8,8,sf); vlist(5,sf)
    return sf
end

-- ════════════════════════════════════════════════════════
--  COMPONENTS
-- ════════════════════════════════════════════════════════
local function mkSection(txt,parent)
    local h=frame({Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},parent)
    frame({Size=UDim2.new(1,-92,0,1),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=C.border,BackgroundTransparency=0},h)
    label({Size=UDim2.new(0,88,1,0),Position=UDim2.new(1,-88,0,0),Text=txt:upper(),TextSize=10,Font=Enum.Font.GothamBold,TextColor3=C.textDim,TextXAlignment=Enum.TextXAlignment.Right},h)
    return h
end

local function mkToggle(txt,defVal,cb,parent)
    local row=frame({Size=UDim2.new(1,0,0,38),BackgroundColor3=C.surface,BackgroundTransparency=0},parent)
    corner(8,row); stroke(1,C.border,row); pad(0,10,0,12,row)
    label({Size=UDim2.new(1,-50,1,0),Text=txt,TextSize=12,TextColor3=C.text,TextWrapped=true},row)
    local track=frame({Size=UDim2.new(0,36,0,20),Position=UDim2.new(1,-36,0.5,-10),BackgroundColor3=defVal and C.accent or C.border,BackgroundTransparency=0},row)
    corner(10,track)
    local thumb=frame({Size=UDim2.new(0,14,0,14),Position=defVal and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),BackgroundColor3=C.white,BackgroundTransparency=0},track)
    corner(7,thumb)
    local state=defVal
    local hit=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=2},row)
    hit.MouseButton1Click:Connect(function()
        state=not state
        tw(track,{BackgroundColor3=state and C.accent or C.border})
        tw(thumb,{Position=state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)})
        cb(state)
    end)
    return {frame=row,set=function(v) state=v; tw(track,{BackgroundColor3=v and C.accent or C.border}); tw(thumb,{Position=v and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}) end,get=function() return state end}
end

local function mkButton(txt,col,cb,parent)
    col=col or C.accent
    local b=btn({Size=UDim2.new(1,0,0,34),Text=txt,TextSize=12,BackgroundColor3=col,TextColor3=C.white,Font=Enum.Font.GothamMedium},parent)
    corner(8,b); b.MouseButton1Click:Connect(cb); return b
end

local function mkSlider(txt,min_,max_,def,cb,parent)
    local wrap=frame({Size=UDim2.new(1,0,0,54),BackgroundColor3=C.surface,BackgroundTransparency=0},parent)
    corner(8,wrap); stroke(1,C.border,wrap); pad(6,10,6,12,wrap)
    local top=frame({Size=UDim2.new(1,0,0,18)},wrap)
    label({Size=UDim2.new(0.75,0,1,0),Text=txt,TextSize=12,TextColor3=C.text},top)
    local vl=label({Size=UDim2.new(0.25,0,1,0),Position=UDim2.new(0.75,0,0,0),Text=tostring(def),TextSize=12,Font=Enum.Font.GothamBold,TextColor3=C.accentHov,TextXAlignment=Enum.TextXAlignment.Right},top)
    local bg=frame({Size=UDim2.new(1,0,0,4),Position=UDim2.new(0,0,1,-2),BackgroundColor3=C.border,BackgroundTransparency=0},wrap)
    corner(2,bg)
    local fill=frame({Size=UDim2.new((def-min_)/(max_-min_),0,1,0),BackgroundColor3=C.accent,BackgroundTransparency=0},bg)
    corner(2,fill)
    local value=def; local drag=false
    local hit=mk("TextButton",{Size=UDim2.new(1,0,0,26),Position=UDim2.new(0,0,1,-14),BackgroundTransparency=1,Text="",ZIndex=5},wrap)
    local function upd(x)
        local pct=math.clamp((x-hit.AbsolutePosition.X)/hit.AbsoluteSize.X,0,1)
        value=math.floor(min_+pct*(max_-min_)); fill.Size=UDim2.new(pct,0,1,0); vl.Text=tostring(value); cb(value)
    end
    hit.MouseButton1Down:Connect(function() drag=true; upd(mouse.X) end)
    hit.MouseButton1Up:Connect(function() drag=false end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    UIS.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then upd(mouse.X) end end)
    return wrap
end

local function mkInput(txt,def,cb,parent)
    local wrap=frame({Size=UDim2.new(1,0,0,54),BackgroundColor3=C.surface,BackgroundTransparency=0},parent)
    corner(8,wrap); stroke(1,C.border,wrap); pad(6,10,6,12,wrap)
    label({Size=UDim2.new(1,0,0,18),Text=txt,TextSize=12,TextColor3=C.text},wrap)
    local box=mk("TextBox",{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,1,-26),BackgroundColor3=C.bg,BackgroundTransparency=0,BorderSizePixel=0,Text=tostring(def),TextSize=12,Font=Enum.Font.Gotham,TextColor3=C.text,PlaceholderColor3=C.textDim,ClearTextOnFocus=false},wrap)
    corner(4,box); stroke(1,C.border,box); pad(0,4,0,4,box)
    box.FocusLost:Connect(function() cb(box.Text) end)
    return wrap
end

-- ════════════════════════════════════════════════════════
--  RARITY POPUP
-- ════════════════════════════════════════════════════════
local Overlay=frame({Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.55,Visible=false,ZIndex=500},ScreenGui)
mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=500},Overlay)

local PopBox=frame({Size=UDim2.new(0,320,0,0),Position=UDim2.new(0.5,-160,0.5,-110),BackgroundColor3=C.surface,BackgroundTransparency=0,ClipsDescendants=true,ZIndex=501,Visible=false},ScreenGui)
corner(12,PopBox); stroke(1,C.border,PopBox)

local PopTitle=label({Size=UDim2.new(1,-42,0,38),Position=UDim2.new(0,14,0,0),Text="Rarity Settings",TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.text,ZIndex=502},PopBox)
local PopX=btn({Size=UDim2.new(0,24,0,24),Position=UDim2.new(1,-32,0,7),Text="✕",TextSize=11,BackgroundColor3=C.danger,TextColor3=C.white,Font=Enum.Font.GothamBold,ZIndex=502},PopBox)
corner(6,PopX)

local PopSf=mk("ScrollingFrame",{Size=UDim2.new(1,-16,0,200),Position=UDim2.new(0,8,0,44),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.accentDim,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ZIndex=502},PopBox)
vlist(4,PopSf)

local function closePopup()
    tw(PopBox,{Size=UDim2.new(0,320,0,0)},0.15)
    task.wait(0.16)
    Overlay.Visible=false; PopBox.Visible=false
    for _,c in pairs(PopSf:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
end
PopX.MouseButton1Click:Connect(closePopup)
Overlay:FindFirstChildOfClass("TextButton").MouseButton1Click:Connect(closePopup)

local function openRarityPopup(bname, rarRef)
    for _,c in pairs(PopSf:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
    PopTitle.Text=bname

    for _,rar in ipairs(RARITY_ORDER) do
        local row=frame({Size=UDim2.new(1,0,0,38),BackgroundColor3=C.surface2,BackgroundTransparency=0,ZIndex=503},PopSf)
        corner(8,row)
        local rd=frame({Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,10,0.5,-4),BackgroundColor3=RARITY_COLOR[rar],BackgroundTransparency=0,ZIndex=504},row)
        corner(4,rd)
        label({Size=UDim2.new(1,-70,1,0),Position=UDim2.new(0,26,0,0),Text=rar,TextSize=12,Font=Enum.Font.GothamMedium,TextColor3=C.text,ZIndex=504},row)
        local cur=rarRef[rar]
        local rt=frame({Size=UDim2.new(0,36,0,20),Position=UDim2.new(1,-46,0.5,-10),BackgroundColor3=cur and C.accent or C.border,BackgroundTransparency=0,ZIndex=504},row)
        corner(10,rt)
        local th=frame({Size=UDim2.new(0,14,0,14),Position=cur and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),BackgroundColor3=C.white,BackgroundTransparency=0,ZIndex=505},rt)
        corner(7,th)
        local hit=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=506},row)
        local _rar=rar
        hit.MouseButton1Click:Connect(function()
            local nv=not rarRef[_rar]; rarRef[_rar]=nv; keepState[bname].rarities[_rar]=nv
            tw(rt,{BackgroundColor3=nv and C.accent or C.border})
            tw(th,{Position=nv and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)})
        end)
    end

    local totalH=44+#RARITY_ORDER*42+8
    PopSf.Size=UDim2.new(1,-16,0,totalH-52)
    PopBox.Visible=true; Overlay.Visible=true
    tw(PopBox,{Size=UDim2.new(0,320,0,totalH)},0.2,Enum.EasingStyle.Back)
end

-- ════════════════════════════════════════════════════════
--  TAB SYSTEM
-- ════════════════════════════════════════════════════════
local tabs={}; local activeTab=nil
local function makeTab(name,icon,acCol)
    local page=makeScrollPage(); acCol=acCol or C.accent
    local tb=btn({Size=UDim2.new(0,0,0,28),AutomaticSize=Enum.AutomaticSize.X,Text=icon.."  "..name,TextSize=11,Font=Enum.Font.GothamMedium,BackgroundColor3=C.surface2,TextColor3=C.textMuted},TabBar)
    corner(7,tb); pad(0,10,0,10,tb)
    local t={name=name,page=page,btn=tb,accent=acCol}
    tb.MouseButton1Click:Connect(function()
        if activeTab then tw(activeTab.btn,{BackgroundColor3=C.surface2,TextColor3=C.textMuted}); activeTab.page.Visible=false end
        activeTab=t; page.Visible=true; tw(tb,{BackgroundColor3=acCol,TextColor3=C.white})
    end)
    table.insert(tabs,t); return page
end

local ChinhPage    = makeTab("Chính",   "⚙", C.accent)
local EventPage    = makeTab("Event",   "⚡", Color3.fromRGB(245,158,11))
local NangCapPage  = makeTab("Nâng Cấp","⬆", Color3.fromRGB(52,211,153))
local BrainrotPage = makeTab("Brainrot","🤖", Color3.fromRGB(139,92,246))
local BanPage      = makeTab("Bán",     "💰", Color3.fromRGB(239,68,68))
local ChiSoPage    = makeTab("Chỉ Số", "📊", Color3.fromRGB(59,130,246))

tabs[1].page.Visible=true; tw(tabs[1].btn,{BackgroundColor3=tabs[1].accent,TextColor3=C.white}); activeTab=tabs[1]

-- ════════════════════════════════════════════════════════
--  TAB: CHÍNH
-- ════════════════════════════════════════════════════════
do
    local p=ChinhPage
    mkSection("Phần thưởng",p)
    local aPR=false
    mkToggle("Tự Động Nhận Thưởng Thời Gian Chơi",false,function(s)
        aPR=s; if not s then return end
        task.spawn(function()
            while aPR and _G.ScriptRunning do
                for i=1,12 do if not aPR or not _G.ScriptRunning then break end; pcall(function() claimGift:InvokeServer(i) end); task.wait(0.25) end
                task.wait(1)
            end
        end)
    end,p)

    local aRB=false
    mkToggle("Tự Động Rebirth",false,function(s)
        aRB=s; if not s then return end
        task.spawn(function() while aRB and _G.ScriptRunning do pcall(function() rebirth:InvokeServer() end); task.wait(1) end end)
    end,p)

    local aEPR=false
    mkToggle("Tự Động Nhận Thưởng Season Pass",false,function(s)
        aEPR=s; if not s then return end
        task.spawn(function()
            while aEPR and _G.ScriptRunning do
                pcall(function()
                    local w=player.PlayerGui:FindFirstChild("Windows"); if not w then return end
                    local e=w:FindFirstChild("Event"); if not e then return end
                    local f=e:FindFirstChild("Frame"); if not f then return end
                    local f2=f:FindFirstChild("Frame"); if not f2 then return end
                    local pw=f2:FindFirstChild("Windows"); if not pw then return end
                    local pa=pw:FindFirstChild("Pass"); if not pa then return end
                    local m=pa:FindFirstChild("Main"); if not m then return end
                    local sf=m:FindFirstChild("ScrollingFrame"); if not sf then return end
                    for i=1,10 do
                        if not aEPR or not _G.ScriptRunning then break end
                        local item=sf:FindFirstChild(tostring(i))
                        if item and item:FindFirstChild("Frame") and item.Frame:FindFirstChild("Free") then
                            local free=item.Frame.Free
                            local locked=free:FindFirstChild("Locked"); local claimed=free:FindFirstChild("Claimed")
                            if claimed and claimed.Visible then continue end
                            if locked and not locked.Visible then pcall(function() claimPass:InvokeServer("Free",i) end) end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end,p)

    mkSection("Shop & Code",p)
    mkButton("Nhập Tất Cả Code",C.accent,function()
        for _,code in ipairs({"release"}) do pcall(function() redeemCode:InvokeServer(code) end); task.wait(1) end
        notify("✅ Đã nhập tất cả code!",C.success)
    end,p)

    local aABL=false
    mkToggle("Tự Động Mua Luckyblock Tốt Nhất",false,function(s)
        aABL=s; if not s then return end
        task.spawn(function()
            while aABL and _G.ScriptRunning do
                pcall(function()
                    local gui=player.PlayerGui:FindFirstChild("Windows"); if not gui then return end
                    local ps=gui:FindFirstChild("PickaxeShop"); if not ps then return end
                    local sf=ps:FindFirstChild("ShopContainer") and ps.ShopContainer:FindFirstChild("ScrollingFrame"); if not sf then return end
                    local cash=player.leaderstats.Cash.Value; local bestSkin,bestPrice=nil,0
                    for _,name in ipairs(skins) do
                        local item=sf:FindFirstChild(name)
                        if item then
                            local b2=item:FindFirstChild("Main") and item.Main:FindFirstChild("Buy") and item.Main.Buy:FindFirstChild("BuyButton")
                            if b2 and b2.Visible then
                                local cl=b2:FindFirstChild("Cash")
                                if cl then local price=parseCash(cl.Text); if cash>=price and price>bestPrice then bestSkin=name; bestPrice=price end end
                            end
                        end
                    end
                    if bestSkin then pcall(function() buySkin:InvokeServer(bestSkin) end) end
                end)
                task.wait(0.5)
            end
        end)
    end,p)

    mkSection("Inventory",p)
    mkButton("Bán Brainrot Đang Cầm",C.danger,function()
        local char=player.Character or player.CharacterAdded:Wait()
        local tool=char:FindFirstChildOfClass("Tool")
        if not tool then notify("⚠ Hãy cầm Brainrot muốn bán!",C.warn); return end
        local eid=tool:GetAttribute("EntityId"); if not eid then return end
        knit:WaitForChild("InventoryService"):WaitForChild("RF"):WaitForChild("SellBrainrot"):InvokeServer(eid)
        notify("💸 Đã bán: "..tool.Name,C.success)
    end,p)
    mkButton("Thu Gom Tất Cả Brainrot",C.success,function()
        task.spawn(function()
            local myPlot=findMyPlot(); if not myPlot then notify("⚠ Không tìm thấy plot!",C.warn); return end
            local containers=myPlot:FindFirstChild("Containers"); if not containers then return end
            for i=1,30 do
                local cf=containers:FindFirstChild(tostring(i))
                if cf and cf:FindFirstChild(tostring(i)) then
                    local inner=cf[tostring(i)]:FindFirstChild("InnerModel")
                    if inner and #inner:GetChildren()>0 then pcall(function() pickupRemote:InvokeServer(tostring(i)) end); task.wait(0.1) end
                end
            end
            notify("✅ Đã thu gom toàn bộ Brainrot!",C.success)
        end)
    end,p)

    mkSection("Thu Tiền Tự Động",p)
    local collectInterval=1
    mkSlider("Chu Kỳ Thu Tiền (giây)",1,50,10,function(v) collectInterval=v/10 end,p)
    local sethidden=getgenv().sethiddenproperty
    local function collectCash()
        if not sethidden then return end
        local _,root=getCharParts(); if not root then return end
        local myPlot=findMyPlot(); if not myPlot then return end
        local containers=myPlot:FindFirstChild("Containers"); if not containers then return end
        for i=1,30 do
            pcall(function()
                local cf=containers:FindFirstChild(tostring(i)); if not cf then return end
                local inner=cf:FindFirstChild(tostring(i)); if not inner then return end
                local col=inner:FindFirstChild("Collection"); if not col then return end
                local p2=col:FindFirstChild("CollectionPad"); if not p2 then return end
                local orig=p2.CFrame
                sethidden(p2,"CFrame",root.CFrame+Vector3.new(0,-3,0)); task.wait(0.1); sethidden(p2,"CFrame",orig)
            end)
            task.wait(0.05)
        end
    end
    local aColl=false
    mkToggle("Tự Động Thu Tiền",false,function(s)
        aColl=s; if not s then return end
        task.spawn(function() while aColl and _G.ScriptRunning do collectCash(); task.wait(collectInterval) end end)
    end,p)
    mkButton("Thu Tiền 1 Lần",C.accent,function() task.spawn(function() collectCash(); notify("✅ Đã thu toàn bộ tiền!",C.success) end) end,p)

    mkSection("Tiện Ích",p)
    mkButton("Reset Nhân Vật",Color3.fromRGB(75,75,105),function() local _,_,h=getCharParts(); if h then h.Health=0 end end,p)
    mkButton("Ẩn / Hiện GUI",Color3.fromRGB(55,55,85),function() Main.Visible=not Main.Visible end,p)
end

-- ════════════════════════════════════════════════════════
--  TAB: EVENT  ⚡
--  Cơ chế y hệt farm, chỉ khác tọa độ đứng chờ model
--  Điểm đứng: 707.2, 38.86, -2115.5
--  Ưu tiên hơn farm — farm tự nhường khi event đang chạy
-- ════════════════════════════════════════════════════════
do
    local p=EventPage

    -- Cơ chế y hệt farm, chỉ khác tọa độ đứng chờ model
    local EVENT_STAND_POS = Vector3.new(707.205810546875, 38.86445236206055, -2115.524658203125)
    local COLLECT_BASE    = workspace:WaitForChild("CollectZones"):WaitForChild("base14")

    -- Status card
    local statCard=frame({Size=UDim2.new(1,0,0,54),BackgroundColor3=C.surface2,BackgroundTransparency=0},p)
    corner(10,statCard); stroke(1,C.event,statCard); pad(0,12,0,12,statCard)
    local eDot=frame({Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,0,0.5,-4),BackgroundColor3=C.textDim,BackgroundTransparency=0},statCard)
    corner(4,eDot)
    local eStatLbl=label({Size=UDim2.new(1,-16,0.5,0),Position=UDim2.new(0,14,0,6),Text="Chưa kích hoạt",TextSize=12,Font=Enum.Font.GothamBold,TextColor3=C.textMuted},statCard)
    local eCycleLbl=label({Size=UDim2.new(1,-16,0.5,0),Position=UDim2.new(0,14,0.5,0),Text="Vòng: 0",TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.textDim},statCard)
    local function setEvStat(txt,col) eStatLbl.Text=txt; eStatLbl.TextColor3=col or C.text; eDot.BackgroundColor3=col or C.textDim end

    mkSection("Điều Khiển",p)
    local eOn=false; local eCyc=0

    mkToggle("Tự Động Auto Event",false,function(s)
        eOn=s; _G.EventRunning=s
        if not s then setEvStat("Đã dừng",C.textMuted); setStatus("Sẵn sàng",C.success); return end
        setEvStat("Đang chạy...",C.event); setStatus("⚡ Auto Event",C.event)

        task.spawn(function()
            while eOn and _G.ScriptRunning do
                eCyc+=1; eCycleLbl.Text="Vòng: "..eCyc

                -- Step 1: Lấy char
                local _,root,hum=getCharParts()
                if not root then setEvStat("⚠ Chờ nhân vật...",C.warn); task.wait(1); continue end

                -- Step 2: Tele đến điểm event + StartRun + StartMove
                setEvStat("🏃 Đang vào event...",C.event)
                root.CFrame=CFrame.new(EVENT_STAND_POS); task.wait(0.3)
                hum:MoveTo(EVENT_STAND_POS)
                pcall(function() startRun:InvokeServer() end); task.wait(0.2)
                pcall(function() startMove:InvokeServer() end); task.wait(0.2)

                -- Step 3: Chờ model xuất hiện (timeout cứng 14s)
                setEvStat("🎯 Chờ model...",C.accent)
                local model=nil
                local gotModel=safeWait(function()
                    model=getMyModel(); return model~=nil
                end,14,0.25)

                if not eOn or not _G.ScriptRunning then break end
                if not gotModel then
                    setEvStat("⚠ Timeout, tự reset...",C.warn)
                    doReset(); task.wait(0.5); continue
                end

                -- Step 4: Tele model đến collect zone (y hệt farm)
                setEvStat("📦 Đang thu...",C.success)
                teleModel(model,COLLECT_BASE.CFrame); task.wait(0.6)
                teleModel(model,COLLECT_BASE.CFrame*CFrame.new(0,-5,0))

                -- Step 5: Chờ model biến mất (timeout cứng 14s)
                local modelGone=safeWait(function()
                    return getMyModel()==nil
                end,14,0.3)

                if not eOn or not _G.ScriptRunning then break end
                if not modelGone then
                    local m2=getMyModel()
                    if m2 then teleModel(m2,COLLECT_BASE.CFrame*CFrame.new(0,-10,0)) end
                    task.wait(1)
                end

                -- Step 6: Chờ respawn (timeout cứng 14s)
                setEvStat("♻ Đang respawn...",C.accentHov)
                notify("⚡ Event vòng "..eCyc.." xong!",C.success)
                local oldChar=player.Character
                local spawned=safeWait(function()
                    local c=player.Character
                    return c~=nil and c~=oldChar and c:FindFirstChild("HumanoidRootPart")~=nil
                end,14,0.2)

                if not eOn or not _G.ScriptRunning then break end
                if not spawned then
                    setEvStat("⚠ Không respawn, tự reset...",C.warn)
                    doReset(); task.wait(0.5); continue
                end

                -- Step 7: Tele về điểm chờ (y hệt farm)
                task.wait(0.4)
                local _,newRoot=getCharParts()
                if newRoot then newRoot.CFrame=CFrame.new(EVENT_STAND_POS) end

                setEvStat("✅ Vòng "..eCyc.." xong!",C.success)
                task.wait(2)
            end

            eOn=false; _G.EventRunning=false
            setEvStat("Đã dừng",C.textMuted); setStatus("Sẵn sàng",C.success)
        end)
    end,p)

    mkButton("Reset Thống Kê",Color3.fromRGB(55,55,80),function()
        eCyc=0; eCycleLbl.Text="Vòng: 0"
        notify("🔄 Đã reset thống kê",C.accent)
    end,p)

    mkSection("Lưu Ý",p)
    local nc=frame({Size=UDim2.new(1,0,0,76),BackgroundColor3=Color3.fromRGB(38,32,12),BackgroundTransparency=0},p)
    corner(8,nc); stroke(1,C.warn,nc); pad(8,10,8,10,nc)
    label({Size=UDim2.new(1,0,1,0),Text="⚡ Cơ chế event y hệt farm:\n• Tele đến (707.2, 38.86, -2115.5)\n• StartRun + StartMove → chờ model spawn (14s)\n• Model xuất hiện → tele về base14 → chờ biến mất\n• Chờ respawn → lặp lại (ưu tiên hơn farm)",TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.warn,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top},nc)
end

-- ════════════════════════════════════════════════════════
--  TAB: NÂNG CẤP
-- ════════════════════════════════════════════════════════
do
    local p=NangCapPage
    mkSection("Tốc Độ Di Chuyển",p)
    local upAmt=1; local upDelay=0.5; local rSpd=false
    mkInput("Số Lượng Mỗi Lần Nâng Cấp","1",function(v) upAmt=tonumber(v) or 1 end,p)
    mkSlider("Chu Kỳ (giây ×0.1)",0,50,5,function(v) upDelay=v/10 end,p)
    mkToggle("Tự Động Nâng Cấp Tốc Độ",false,function(s)
        rSpd=s; if not s then return end
        task.spawn(function() while rSpd and _G.ScriptRunning do pcall(function() upgradeSpd:InvokeServer("MovementSpeed",upAmt) end); task.wait(upDelay) end end)
    end,p)
    mkSection("Nâng Cấp Container",p)
    local brDelay=0.5; local rBR1,rBR2,rBR3=false,false,false
    mkSlider("Chu Kỳ Nâng Cấp (giây ×0.1)",1,50,5,function(v) brDelay=v/10 end,p)
    mkToggle("Tự Động Nâng Cấp Tầng 1 (1–10)",false,function(s)
        rBR1=s; if not s then return end
        task.spawn(function() while rBR1 and _G.ScriptRunning do for i=1,10 do if not rBR1 or not _G.ScriptRunning then break end; pcall(function() upgradeBR:InvokeServer(tostring(i)) end); task.wait(brDelay) end end end)
    end,p)
    mkToggle("Tự Động Nâng Cấp Tầng 2 (11–20)",false,function(s)
        rBR2=s; if not s then return end
        task.spawn(function() while rBR2 and _G.ScriptRunning do for i=11,20 do if not rBR2 or not _G.ScriptRunning then break end; pcall(function() upgradeBR:InvokeServer(tostring(i)) end); task.wait(brDelay) end end end)
    end,p)
    mkToggle("Tự Động Nâng Cấp Tầng 3 (21–30)",false,function(s)
        rBR3=s; if not s then return end
        task.spawn(function() while rBR3 and _G.ScriptRunning do for i=21,30 do if not rBR3 or not _G.ScriptRunning then break end; pcall(function() upgradeBR:InvokeServer(tostring(i)) end); task.wait(brDelay) end end end)
    end,p)
    mkButton("Nâng Cấp Tất Cả 1 Lần (1–30)",C.success,function()
        task.spawn(function()
            for i=1,30 do pcall(function() upgradeBR:InvokeServer(tostring(i)) end); task.wait(brDelay) end
            notify("✅ Đã nâng cấp 30 container!",C.success)
        end)
    end,p)
end

-- ════════════════════════════════════════════════════════
--  TAB: BRAINROT — Farm Loop
-- ════════════════════════════════════════════════════════
do
    local p=BrainrotPage
    local COLLECT_BASE=workspace:WaitForChild("CollectZones"):WaitForChild("base14")

    mkSection("Điều Khiển Boss",p)
    local storedParts={}; local bossFolder=workspace:WaitForChild("BossTouchDetectors")
    mkToggle("Xóa Cạm Bẫy Boss Xấu",false,function(s)
        if s then
            storedParts={}
            for _,obj in ipairs(bossFolder:GetChildren()) do
                if obj.Name~="base14" then table.insert(storedParts,obj); obj.Parent=nil end
            end
        else
            for _,obj in ipairs(storedParts) do if obj then obj.Parent=bossFolder end end; storedParts={}
        end
    end,p)
    mkButton("Dịch Chuyển Tất Cả Đến Cuối",Color3.fromRGB(139,92,246),function()
        local mf=workspace:WaitForChild("RunningModels")
        for _,obj in ipairs(mf:GetChildren()) do
            if obj:IsA("Model") then
                if obj.PrimaryPart then obj:SetPrimaryPartCFrame(COLLECT_BASE.CFrame)
                else local part=obj:FindFirstChildWhichIsA("BasePart"); if part then part.CFrame=COLLECT_BASE.CFrame end end
            elseif obj:IsA("BasePart") then obj.CFrame=COLLECT_BASE.CFrame end
        end
        notify("✅ Đã dịch chuyển tất cả model!",C.success)
    end,p)

    mkSection("Farm Brainrot",p)
    local farmCard=frame({Size=UDim2.new(1,0,0,36),BackgroundColor3=C.surface2,BackgroundTransparency=0},p)
    corner(8,farmCard); stroke(1,C.border,farmCard); pad(0,10,0,12,farmCard)
    local farmLbl=label({Size=UDim2.new(1,0,1,0),Text="⏸ Chưa kích hoạt",TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.textMuted},farmCard)
    local function setFarmLbl(txt,col) farmLbl.Text=txt; farmLbl.TextColor3=col or C.text end

    local farmOn=false
    mkToggle("Tự Động Farm Brainrot Tốt Nhất",false,function(s)
        farmOn=s; _G.FarmRunning=s
        if not s then setFarmLbl("⏸ Đã dừng",C.textMuted); setStatus("Sẵn sàng",C.success); return end
        setFarmLbl("🔄 Đang farm...",C.success); setStatus("🤖 Auto Farm",C.success)

        task.spawn(function()
            while farmOn and _G.ScriptRunning do

                -- ── Ưu tiên Event: chỉ nhường khi event đang thực sự chạy ──
                if _G.EventRunning then
                    setFarmLbl("⚡ Đang có Event, chờ xong...",C.event)
                    while _G.EventRunning and farmOn and _G.ScriptRunning do task.wait(0.3) end
                    if not farmOn or not _G.ScriptRunning then break end
                    setFarmLbl("🔄 Event xong, tiếp tục farm...",C.success)
                    task.wait(0.5)
                end

                -- Step 1: Lấy char
                local _,root,hum=getCharParts()
                if not root then setFarmLbl("⚠ Chờ nhân vật...",C.warn); task.wait(1); continue end

                -- Step 2: Tele về vị trí start
                root.CFrame=CFrame.new(715,39,-2122); task.wait(0.3)
                hum:MoveTo(Vector3.new(710,39,-2122))

                -- Step 3: Chờ model xuất hiện (timeout cứng 12s)
                setFarmLbl("🎯 Chờ model...",C.accent)
                local model=nil
                local gotModel=safeWait(function()
                    model=getMyModel(); return model~=nil
                end,12,0.25)

                if not farmOn or not _G.ScriptRunning then break end
                if not gotModel then
                    setFarmLbl("⚠ Timeout, tự reset...",C.warn)
                    doReset(); task.wait(0.5); continue
                end

                -- Step 4: Tele model đến collect zone
                setFarmLbl("📦 Đang thu...",C.success)
                teleModel(model,COLLECT_BASE.CFrame); task.wait(0.6)
                teleModel(model,COLLECT_BASE.CFrame*CFrame.new(0,-5,0))

                -- Step 5: Chờ model biến mất (timeout cứng 12s)
                local modelGone=safeWait(function()
                    return getMyModel()==nil
                end,12,0.3)

                if not farmOn or not _G.ScriptRunning then break end
                if not modelGone then
                    local m2=getMyModel()
                    if m2 then teleModel(m2,COLLECT_BASE.CFrame*CFrame.new(0,-10,0)) end
                    task.wait(1)
                end

                -- Step 6: Chờ respawn (timeout cứng 12s)
                setFarmLbl("♻ Đang respawn...",C.accentHov)
                local oldChar=player.Character
                local spawned=safeWait(function()
                    local c=player.Character
                    return c~=nil and c~=oldChar and c:FindFirstChild("HumanoidRootPart")~=nil
                end,12,0.2)

                if not farmOn or not _G.ScriptRunning then break end
                if not spawned then
                    setFarmLbl("⚠ Không respawn, tự reset...",C.warn)
                    doReset(); task.wait(0.5); continue
                end

                -- Step 7: Tele về vị trí chờ
                task.wait(0.4)
                local _,newRoot=getCharParts()
                if newRoot then newRoot.CFrame=CFrame.new(737,39,-2118) end

                setFarmLbl("✅ Vòng xong!",C.success)
                task.wait(2)
            end
            farmOn=false; _G.FarmRunning=false
            setFarmLbl("⏸ Đã dừng",C.textMuted); setStatus("Sẵn sàng",C.success)
        end)
    end,p)
end

-- ════════════════════════════════════════════════════════
--  TAB: BÁN (Popup Rarity)
-- ════════════════════════════════════════════════════════
do
    local p=BanPage
    mkSection("Cài Đặt Tổng",p)
    mkToggle("Giữ Tất Cả (bật = không bán gì)",true,function(s)
        for _,b in ipairs(BRAINROT_LIST) do keepState[b.name].keepAll=s end
    end,p)

    local lastSec=""; local secIcons={Special="★ ",Cyber="◈ ",Angelic="✦ ",Demonic="◆ "}
    local badgeColors={
        Normal ={bg=Color3.fromRGB(38,38,50), tx=Color3.fromRGB(175,175,200)},
        Candy  ={bg=Color3.fromRGB(75,18,55), tx=Color3.fromRGB(249,168,212)},
        Gold   ={bg=Color3.fromRGB(75,50,8),  tx=Color3.fromRGB(253,230,138)},
        Diamond={bg=Color3.fromRGB(18,38,75), tx=Color3.fromRGB(147,197,253)},
        Void   ={bg=Color3.fromRGB(45,18,75), tx=Color3.fromRGB(196,181,253)},
    }

    for _,b in ipairs(BRAINROT_LIST) do
        local bname=b.name
        local rarToggles={Normal=true,Candy=true,Gold=true,Diamond=true,Void=true}

        if b.section~=lastSec then
            lastSec=b.section; mkSection((secIcons[b.section] or "")..b.section,p)
        end

        local bc=badgeColors[b.rarity] or badgeColors.Normal

        local card=frame({Size=UDim2.new(1,0,0,40),BackgroundColor3=C.surface,BackgroundTransparency=0},p)
        corner(8,card); stroke(1,C.border,card)

        local dot=frame({Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,10,0.5,-3),BackgroundColor3=RARITY_COLOR[b.rarity] or C.textDim,BackgroundTransparency=0},card)
        corner(3,dot)
        label({Size=UDim2.new(1,-200,1,0),Position=UDim2.new(0,22,0,0),Text=bname,TextSize=11,Font=Enum.Font.GothamMedium,TextColor3=C.text,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd},card)
        local badge=frame({Size=UDim2.new(0,54,0,18),Position=UDim2.new(1,-148,0.5,-9),BackgroundColor3=bc.bg,BackgroundTransparency=0},card)
        corner(9,badge)
        label({Size=UDim2.new(1,0,1,0),Text=b.rarity,TextSize=10,Font=Enum.Font.GothamBold,TextColor3=bc.tx,TextXAlignment=Enum.TextXAlignment.Center},badge)

        local gBtn=btn({Size=UDim2.new(0,26,0,26),Position=UDim2.new(1,-90,0.5,-13),Text="⚙",TextSize=11,BackgroundColor3=C.surface3,TextColor3=C.textMuted},card)
        corner(6,gBtn)
        local _bn,_rt=bname,rarToggles
        gBtn.MouseButton1Click:Connect(function()
            if keepState[_bn].keepAll then notify("⚠ Tắt 'Giữ Tất Cả' trước!",C.warn)
            else openRarityPopup(_bn,_rt) end
        end)

        local ks=keepState[bname]
        local track=frame({Size=UDim2.new(0,32,0,17),Position=UDim2.new(1,-44,0.5,-8.5),BackgroundColor3=ks.keepAll and C.accent or C.border,BackgroundTransparency=0},card)
        corner(9,track)
        local thumb=frame({Size=UDim2.new(0,11,0,11),Position=ks.keepAll and UDim2.new(1,-14,0.5,-5.5) or UDim2.new(0,3,0.5,-5.5),BackgroundColor3=C.white,BackgroundTransparency=0},track)
        corner(6,thumb)
        local kHit=mk("TextButton",{Size=UDim2.new(0,40,0,28),Position=UDim2.new(1,-48,0.5,-14),BackgroundTransparency=1,Text="",ZIndex=3},card)
        local _bn2=bname
        kHit.MouseButton1Click:Connect(function()
            local ks2=keepState[_bn2]; ks2.keepAll=not ks2.keepAll
            tw(track,{BackgroundColor3=ks2.keepAll and C.accent or C.border})
            tw(thumb,{Position=ks2.keepAll and UDim2.new(1,-14,0.5,-5.5) or UDim2.new(0,3,0.5,-5.5)})
        end)
    end

    mkSection("Thực Hiện",p)
    mkButton("Bán Brainrot 1 Lần",C.danger,function()
        local count=sellBrainrots()
        notify("💸 Đã bán "..count.." brainrot!",count>0 and C.success or C.textMuted)
    end,p)
    local autoSell=false
    mkToggle("Tự Động Bán Brainrot",false,function(s)
        autoSell=s; if not s then return end
        task.spawn(function()
            while autoSell and _G.ScriptRunning do
                local count=sellBrainrots()
                if count>0 then notify("💸 Đã bán "..count.." brainrot!",C.success) end
                task.wait(2)
            end
        end)
    end,p)
end

-- ════════════════════════════════════════════════════════
--  TAB: CHỈ SỐ
-- ════════════════════════════════════════════════════════
do
    local p=ChiSoPage
    mkSection("Tốc Độ Luckyblock",p)
    local sliderVal=1000; local cSpd=false; local origSpd,curModel=nil,nil
    mkToggle("Bật Tốc Độ Tùy Chỉnh",false,function(s)
        cSpd=s
        if not s then local m=getMyModel(); if m and origSpd~=nil then m:SetAttribute("MovementSpeed",origSpd) end; origSpd=nil; curModel=nil end
    end,p)
    mkSlider("Tốc Độ Luckyblock",50,3000,1000,function(v) sliderVal=v end,p)
    task.spawn(function()
        while _G.ScriptRunning do
            if cSpd then
                local m=getMyModel()
                if m then if m~=curModel then curModel=m; origSpd=m:GetAttribute("MovementSpeed") end; m:SetAttribute("MovementSpeed",sliderVal)
                else curModel=nil end
            end
            task.wait(0.2)
        end
    end)
end

-- ════════════════════════════════════════════════════════
--  ANTI AFK — 4 lớp độc lập
-- ════════════════════════════════════════════════════════
-- Lớp 1: VirtualUser Button2 mỗi 60s
task.spawn(function()
    while _G.ScriptRunning do
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            task.wait(0.1)
            VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end)
        task.wait(60)
    end
end)
-- Lớp 2: Humanoid Jump mỗi 55s
task.spawn(function()
    while _G.ScriptRunning do
        task.wait(55)
        pcall(function() local _,_,h=getCharParts(); if h then h.Jump=true end end)
    end
end)
-- Lớp 3: ClickButton2 mỗi 80s
task.spawn(function()
    while _G.ScriptRunning do
        task.wait(80)
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end)
    end
end)
-- Lớp 4: Idled event — reset ngay khi bị detect
player.Idled:Connect(function()
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        task.wait(0.5)
        VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
    pcall(function() local _,_,h=getCharParts(); if h then h.Jump=true end end)
end)

-- ════════════════════════════════════════════════════════
task.wait(0.5)
notify("✅ Kuma Hub v2 loaded!",C.accent)
notify("⚡ Anti-AFK 4 lớp + Event mới!",C.success)
