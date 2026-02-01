--[[
    🐻 KUMA REMOTE SPY - ELITE EDITION 🐻
    ---------------------------------------------------
    - Tính năng: Theo dõi tất cả RemoteEvent và RemoteFunction.
    - Hiển thị: Console (Bấm F9 để xem).
    - Tối ưu: Chỉ in dữ liệu cần thiết, hỗ trợ phân tích Table sâu.
]]

local game = game
local Players = game:GetService("Players")
local LogService = game:GetService("LogService")

-- 0. TIỆN ÍCH PHÂN TÍCH DỮ LIỆU (DEEP SCAN)
local function FormatArguments(args)
    local result = ""
    for i, v in pairs(args) do
        local typeV = typeof(v)
        local strV = tostring(v)
        
        if typeV == "table" then
            -- Phân tích table đơn giản
            local inner = "{"
            local count = 0
            for k, val in pairs(v) do
                count = count + 1
                if count > 10 then inner = inner .. " ... (too long)"; break end
                inner = inner .. tostring(k) .. "=" .. tostring(val) .. ", "
            end
            strV = inner .. "}"
        elseif typeV == "Instance" then
            strV = v:GetFullName()
        elseif typeV == "string" then
            strV = '"' .. v .. '"'
        end
        
        result = result .. "[" .. i .. "]: (" .. typeV .. ") " .. strV .. " | "
    end
    return result
end

-- 1. HỆ THỐNG HOOK (THEO DÕI NGẦM)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    local script = getcallingscript() -- Script nào đang gọi Remote này
    
    -- Chỉ bắt các lệnh gửi lên Server
    if method == "FireServer" or method == "InvokeServer" then
        local remoteName = self.Name
        local remotePath = self:GetFullName()
        local scriptPath = script and script:GetFullName() or "Unknown Script"
        
        -- In ra Console với định dạng chuyên nghiệp
        print("--------------------------------------------------")
        print("🛰️ REMOTE CALLED: " .. remoteName)
        print("📁 Path: " .. remotePath)
        print("📜 Caller: " .. scriptPath)
        print("🛠️ Method: " .. method)
        print("📦 Args: " .. FormatArguments(args))
        print("--------------------------------------------------")
    end
    
    return oldNamecall(self, ...)
end)

-- 2. THÔNG BÁO KHỞI CHẠY
local function Notify(txt)
    print("🚀 [KUMA SPY]: " .. txt)
    -- Nếu muốn hiện thông báo góc màn hình (tùy chọn)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Kuma Remote Spy",
        Text = txt,
        Duration = 5
    })
end

Notify("Remote Spy is ACTIVE. Press F9 to view logs.")

-- 3. CHỐNG SPAM LOG (TÙY CHỌN)
-- Nếu game spam quá nhiều, code này sẽ lọc bớt các Remote trùng lặp trong 1 giây
local LastCalls = {}
local function IsSpam(name)
    local now = tick()
    if LastCalls[name] and (now - LastCalls[name]) < 0.5 then
        return true
    end
    LastCalls[name] = now
    return false
end

-- Lưu ý: Nếu muốn dùng IsSpam, hãy thêm điều kiện 'if not IsSpam(remoteName)' vào trong Hook.
