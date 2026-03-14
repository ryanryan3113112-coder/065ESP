-- Godmode / HP 鎖定腳本（按 H 開關）
-- 開啟後：血量永遠鎖在最大值（近似無敵）
-- 注意：這是客戶端假無敵，容易被伺服器偵測/踢掉/封禁
-- 適合小號測試，某些遊戲完全無效

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local godmodeEnabled = false
local godConnection = nil

local MAX_HEALTH = 999  -- 預設最大血量，某些遊戲會不同，可改

local function lockHealth()
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- 鎖定血量為最大
    humanoid.Health = humanoid.MaxHealth
    humanoid.MaxHealth = MAX_HEALTH  -- 強制設最大值（可防某些降低MaxHealth的機制）
    
    -- 防止掉血（某些遊戲會強制減血，這裡每幀補回）
    humanoid.HealthChanged:Connect(function(health)
        if godmodeEnabled and health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end

local function toggleGodmode()
    godmodeEnabled = not godmodeEnabled
    print("Godmode / HP 鎖定：" .. (godmodeEnabled and "開啟" or "關閉"))
    
    if godmodeEnabled then
        if godConnection then godConnection:Disconnect() end
        
        -- 每幀強制補血 + 鎖 MaxHealth（防遊戲重設）
        godConnection = RunService.Heartbeat:Connect(function()
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.MaxHealth = MAX_HEALTH
                    humanoid.Health = humanoid.MaxHealth
                end
            end
        end)
        
        -- 立即執行一次
        lockHealth()
    else
        if godConnection then
            godConnection:Disconnect()
            godConnection = nil
        end
        -- 關閉時不強制恢復，讓遊戲自然處理
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.H then
        toggleGodmode()
    end
end)

-- 角色重生時自動套用狀態
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)  -- 等 Humanoid 載入
    if godmodeEnabled then
        lockHealth()
        -- 重啟迴圈（如果需要）
        if godConnection then godConnection:Disconnect() end
        godConnection = RunService.Heartbeat:Connect(function()
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.MaxHealth = MAX_HEALTH
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end
end)

print("Godmode / HP 鎖定 已載入")
print("按 H 開/關 | 開啟後血量鎖最大（客戶端假無敵）")
print("⚠️ 高風險！很多遊戲會偵測異常血量變化 → 容易被踢或 ban")
print("建議：只在私人伺服器或小號短暫測試")
