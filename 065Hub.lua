

-- 低偵測 ESP：Highlight 骨架 + Billboard 血量/距離
-- 按 E 開/關 | 2026 安全版

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESP_ENABLED = true
local ESP_OBJECTS = {}  -- 每個玩家的資料

local MAX_DISTANCE = 1000       -- 太遠不顯示
local TEAM_CHECK = true         -- true = 不顯示隊友

local function isTeammate(player)
    if not TEAM_CHECK then return false end
    if not LocalPlayer.Team then return false end
    return player.Team == LocalPlayer.Team
end

local function createESP(player)
    if player == LocalPlayer or isTeammate(player) then return end
    
    local function onCharacterAdded(char)
        task.wait(0.3)  -- 等角色載入
        
        local root = char:WaitForChild("HumanoidRootPart", 8)
        local humanoid = char:WaitForChild("Humanoid", 8)
        if not (root and humanoid) then return end
        
        -- Highlight 做骨架/輪廓 (低偵測)
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.Adornee = char
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded  -- 牆後也看得到
        highlight.FillColor = Color3.fromRGB(0, 255, 100)
        highlight.FillTransparency = 0.6
        highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
        highlight.OutlineTransparency = 0.1
        highlight.Enabled = ESP_ENABLED
        highlight.Parent = char
        
        -- BillboardGui 放頭頂 (血量 + 距離)
        local bb = Instance.new("BillboardGui")
        bb.Name = "ESPInfo"
        bb.Adornee = char:WaitForChild("Head")
        bb.Size = UDim2.new(0, 180, 0, 50)
        bb.StudsOffset = Vector3.new(0, 3.2, 0)
        bb.AlwaysOnTop = true
        bb.LightInfluence = 0
        bb.MaxDistance = MAX_DISTANCE
        bb.Enabled = ESP_ENABLED
        bb.Parent = char.Head
        
        -- 名字
        local nameLabel = Instance.new("TextLabel", bb)
        nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0.6
        nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextSize = 16
        nameLabel.Text = player.Name
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        
        -- 資訊 (血量 + 距離)
        local infoLabel = Instance.new("TextLabel", bb)
        infoLabel.Size = UDim2.new(1, 0, 0.4, 0)
        infoLabel.Position = UDim2.new(0, 0, 0.45, 0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
        infoLabel.TextStrokeTransparency = 0.7
        infoLabel.TextStrokeColor3 = Color3.new(0,0,0)
        infoLabel.Font = Enum.Font.SourceSans
        infoLabel.TextSize = 14
        infoLabel.TextXAlignment = Enum.TextXAlignment.Center
        
        -- 血條背景
        local barBG = Instance.new("Frame", bb)
        barBG.Size = UDim2.new(0.9, 0, 0.12, 0)
        barBG.Position = UDim2.new(0.05, 0, 0.88, 0)
        barBG.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
        barBG.BorderSizePixel = 0
        
        local bar = Instance.new("Frame", barBG)
        bar.Size = UDim2.new(1, 0, 1, 0)
        bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        bar.BorderSizePixel = 0
        
        ESP_OBJECTS[player] = {
            highlight = highlight,
            bb = bb,
            info = infoLabel,
            bar = bar,
            charConn = nil
        }
        
        -- 更新迴圈 (用 Heartbeat 降低頻率)
        ESP_OBJECTS[player].charConn = RunService.Heartbeat:Connect(function()
            if not ESP_ENABLED or not char.Parent or humanoid.Health <= 0 then
                highlight.Enabled = false
                bb.Enabled = false
                return
            end
            
            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            if dist > MAX_DISTANCE then
                highlight.Enabled = false
                bb.Enabled = false
                return
            end
            
            highlight.Enabled = true
            bb.Enabled = true
            
            -- 距離 + 血量文字
            infoLabel.Text = string.format("HP: %.0f/%.0f   |   %.0f studs", humanoid.Health, humanoid.MaxHealth, dist)
            
            -- 血條
            local hpRatio = humanoid.Health / humanoid.MaxHealth
            bar.Size = UDim2.new(hpRatio, 0, 1, 0)
            
            if hpRatio > 0.6 then
                bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            elseif hpRatio > 0.3 then
                bar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            else
                bar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            end
        end)
    end
    
    -- 初次角色 + 重生
    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end

local function removeESP(player)
    if ESP_OBJECTS[player] then
        if ESP_OBJECTS[player].charConn then
            ESP_OBJECTS[player].charConn:Disconnect()
        end
        if ESP_OBJECTS[player].highlight then
            ESP_OBJECTS[player].highlight:Destroy()
        end
        if ESP_OBJECTS[player].bb then
            ESP_OBJECTS[player].bb:Destroy()
        end
        ESP_OBJECTS[player] = nil
    end
end

-- 初始化所有玩家
for _, plr in ipairs(Players:GetPlayers()) do
    task.spawn(createESP, plr)
end

Players.PlayerAdded:Connect(function(plr)
    task.spawn(createESP, plr)
end)

Players.PlayerRemoving:Connect(removeESP)

-- 按 E 切換
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        ESP_ENABLED = not ESP_ENABLED
        print("ESP 現在：" .. (ESP_ENABLED and "開啟" or "關閉"))
        
        for _, data in pairs(ESP_OBJECTS) do
            if data.highlight then data.highlight.Enabled = ESP_ENABLED end
            if data.bb then data.bb.Enabled = ESP_ENABLED end
        end
    end
end)

-- 自己重生時重新更新
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1.5)
    for _, plr in ipairs(Players:GetPlayers()) do
        removeESP(plr)
        task.spawn(createESP, plr)
    end
end)

print("Highlight 骨架 + 血量距離 ESP 已載入 | 按 E 開/關 | 相對安全版")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local noclipEnabled = false
local noclipConnection = nil

local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    print("穿牆模式：" .. (noclipEnabled and "開啟" or "關閉"))
    
    if noclipEnabled then
        if noclipConnection then noclipConnection:Disconnect() end
        
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                -- 防止掉落或卡地（可選，關掉如果想掉下去）
                -- local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                -- if hrp then hrp.Velocity = hrp.Velocity * Vector3.new(1, 0.98, 1) end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        -- 恢復正常碰撞
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.N then
        toggleNoclip()
    end
end)

-- 角色重生時自動重新套用狀態
LocalPlayer.CharacterAdded:Connect(function(char)
    wait(0.5)  -- 等載入
    if noclipEnabled then
        toggleNoclip()  -- 先關
        toggleNoclip()  -- 再開，重新連線
    end
end)

print("按 N 穿牆（強化版）已載入")



-- fly.lua - 按 F 起飛（Fly）腳本
-- 按 F 開/關飛行 | WASD 前後左右 | Space 上 | Ctrl 下

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local flyEnabled = false
local flySpeed = 50

local bv = nil
local bg = nil
local flyConnection = nil

local function startFlying()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local root = LocalPlayer.Character.HumanoidRootPart
    
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
        if not flyEnabled or not root then return end
        
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

local function stopFlying()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
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

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    end
end)

-- 角色重生時保持狀態
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.6)
    if flyEnabled then
        stopFlying()
        startFlying()
    end
end)

print("按 F 起飛腳本已載入")
print("WASD 移動 | Space 上昇 | Ctrl 下降")


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
