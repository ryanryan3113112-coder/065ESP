-- fly.lua - 按 Z 起飛（Fly）腳本
-- 按 Z 開/關飛行 | WASD 前後左右 | Space 上 | Ctrl 下

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local flyEnabled = true -- 預設開啟
local flySpeed = 50

local bv = nil
local bg = nil
local flyConnection = nil

local function stopFlying()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
end

local function startFlying()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local root = LocalPlayer.Character.HumanoidRootPart
    
    -- 清除舊的動力防止疊加
    stopFlying()
    
    -- 建立飛行動力
    bv = Instance.new("BodyVelocity")
    bv.Name = "FlyVelocity"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root
    
    bg = Instance.new("BodyGyro")
    bg.Name = "FlyGyro"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 90000
    bg.Parent = root
    
    -- 飛行更新迴圈
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flyEnabled or not root or not root.Parent then 
            stopFlying()
            return 
        end
        
        local camera = workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * flySpeed
        end
        
        bv.Velocity = moveDirection
        bg.CFrame = camera.CFrame
    end)
end

local function toggleFly()
    flyEnabled = not flyEnabled
    print("飛行模式：" .. (flyEnabled and "✅ 開啟" or "❌ 關閉"))
    
    if flyEnabled then
        startFlying()
    else
        stopFlying()
    end
end

-- 監聽按鍵 Z
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Z then
        toggleFly()
    end
end)

-- 角色重生時保持狀態
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.6)
    if flyEnabled then
        startFlying()
    end
end)

-- 初始執行：預設開啟
if flyEnabled then
    startFlying()
end

print("按 Z 起飛腳本已載入 (預設開啟)")
print("WASD 移動 | Space 上昇 | Ctrl 下降")
