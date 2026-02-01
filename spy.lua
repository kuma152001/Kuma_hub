--[[ 
    🐻 KUMA PASSIVE REMOTE SPY (NON-INTRUSIVE) 🐻
    ---------------------------------------------------
    - CƠ CHẾ: Chỉ thăm dò (Probing), không chặn lệnh (Non-blocking).
    - HIỆU NĂNG: Cực cao, không gây delay lệnh của game.
    - HIỂN THỊ: Console (F9).
]]

local game = game
local typeof = typeof
local tostring = tostring
local table_insert = table.insert
local table_concat = table.concat

-- 1. HÀM ĐỊNH DẠNG DỮ LIỆU (CHẠY NGẦM)
local function ParseArgs(...)
    local args = {...}
    local formatted = {}
    
    for i, v in ipairs(args) do
        local t = typeof(v)
        if t == "table" then
            local s = "{"
            local count = 0
            for k, val in pairs(v) do
                count = count + 1
                if count > 15 then s = s .. "..."; break end
                s = s .. tostring(k) .. "=" .. tostring(val) .. ","
            end
            table_insert(formatted, "["..i.."] (Table): " .. s .. "}")
        elseif t == "Instance" then
            table_insert(formatted, "["..i.."] (Instance): " .. (v.Parent and v:GetFullName() or v.Name))
        elseif t == "CFrame" then
            table_insert(formatted, "["..i.."] (CFrame): " .. tostring(v))
        elseif t == "Vector3" then
            table_insert(formatted, "["..i.."] (Vector3): " .. tostring(v))
        else
            table_insert(formatted, "["..i.."] ("..t.."): " .. tostring(v))
        end
    end
    return table_concat(formatted, " | ")
end

-- 2. HỆ THỐNG THĂM DÒ (PASSIVE HOOK)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...} -- Sao chép tham số ngay lập tức
    
    -- Lệnh này được đẩy đi TRƯỚC khi xử lý log để đảm bảo game không bị delay
    if (method == "FireServer" or method == "InvokeServer") and self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
        local remoteName = self.Name
        local remotePath = self:GetFullName()
        local caller = getcallingscript()
        
        -- Xử lý việc in Log trong một luồng riêng (không làm nghẽn luồng chính của game)
        task.spawn(function()
            local timestamp = os.date("%H:%M:%S")
            print("--------------------------------------------------")
            print("🛰️ [" .. timestamp .. "] REMOTE DETECTED: " .. remoteName)
            print("📁 Path: " .. remotePath)
            print("📜 Script: " .. (caller and caller:GetFullName() or "Unknown"))
            print("📦 Data: " .. ParseArgs(unpack(args)))
            print("--------------------------------------------------")
        end)
    end
    
    -- Luôn trả về kết quả gốc của game ngay lập tức
    return oldNamecall(self, ...)
end)

-- 3. THÔNG BÁO
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Kuma Spy Active",
    Text = "Thăm dò Remote thành công. Check F9.",
    Duration = 3
})

print("🚀 [KUMA SPY]: Chế độ thăm dò thụ động đã kích hoạt. Không can thiệp lệnh game.")
