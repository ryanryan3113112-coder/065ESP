-- 白圓框 FOV 自瞄鎖定（玩家進入圓框就鎖視角）
-- 按 Q 開/關 | 白圓框在畫面中央 | 自動鎖最近進入框的敵人頭部
-- 開啟後只要敵人在白圓內，視角就會自動轉向他（rage 級鎖定）

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local AIM_ENABLED = false
local FOV_RADIUS = 180          -- 白圓大小（像素），可改大/小
local LOCK_PART = "Head"        -- 鎖定部位（Head 或 HumanoidRootPart）

-- 白圓框（Drawing API）
local whiteCircle = Drawing.new("Circle")
whiteCircle.Thickness = 2
whiteCircle.NumSides = 100
whiteCircle.Radius = FOV_RADIUS
whiteCircle.Color = Color3.fromRGB(255, 255, 255)  -- 白色
whiteCircle.Filled = false
whiteCircle.Transparency = 0.8
whiteCircle.Visible = false

-- 找框內最近的敵人頭
local function getClosestInFOV()
    local closest = nil
    local minDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetPart = player.Character:FindFirstChild(LOCK_PART)
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if targetPart and humanoid and humanoid.Health > 0 then
                local screenPos, visible = Camera:WorldToViewportPoint(targetPart.Position)
                if visible then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist <= FOV_RADIUS and dist < minDist then
                        minDist = dist
                        closest = targetPart
                    end
                end
            end
        end
    end
    return closest
end

local aimConn = nil

local function toggleAimbot()
    AIM_ENABLED = not AIM_ENABLED
    whiteCircle.Visible = AIM_ENABLED
    print("白圓 FOV 自瞄鎖定：" .. (AIM_ENABLED and "開啟" or "關閉"))
    
    if AIM_ENABLED then
        if aimConn then aimConn:Disconnect() end
        aimConn = RunService.RenderStepped:Connect(function()
            -- 圓框跟隨畫面中央
            whiteCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            
            local target = getClosestInFOV()
            if target then
                -- 直接鎖定視角（rage lock）
                local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                Camera.CFrame = targetCFrame  -- 瞬間鎖定（可改成 Lerp 平滑）
            end
        end)
    else
        if aimConn then
            aimConn:Disconnect()
            aimConn = nil
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Q then
        toggleAimbot()
    end
end)

-- 重生時保持狀態
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.6)
    if AIM_ENABLED then
        toggleAimbot()
        toggleAimbot()
    end
end)

print("白圓框 FOV 自瞄已載入")
print("按 Q 開/關 | 敵人進入白圓就自動鎖頭")
print("⚠️ 極高風險功能，Byfron 很容易偵測，建議小號短時間測試")
