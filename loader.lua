-- loader.lua：一次載入 ESP + Noclip
-- 使用者只要執行這一行：
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/ryanryan3113112-coder/065ESP/main/loader.lua"))()

local HttpService = game:GetService("HttpService")
local base = "https://raw.githubusercontent.com/ryanryan3113112-coder/065ESP/main/"

-- 先載入 ESP.lua
local success1, err1 = pcall(function()
    local code = HttpService:GetAsync(base .. "ESP.lua")
    loadstring(code)()
end)
if not success1 then
    warn("ESP 載入失敗: " .. tostring(err1))
end

-- 再載入 Noclip.lua
local success2, err2 = pcall(function()
    local code = HttpService:GetAsync(base .. "Noclip.lua")
    loadstring(code)()
end)
if not success2 then
    warn("Noclip 載入失敗: " .. tostring(err2))
end

print("=== 載入完成 ===")
print("按 E → 開/關透視（骨架 + 血量/距離）")
print("按 N → 開/關穿牆")
print("如果沒反應，檢查 raw 連結是否能正常開啟")
