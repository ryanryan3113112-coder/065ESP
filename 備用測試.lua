-- ==================== 作者顯示 (載入時中央跳出 3 秒) ====================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local sg = Instance.new("ScreenGui")
sg.Name = "AuthorSplash"
sg.ResetOnSpawn = false
sg.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 100)
frame.Position = UDim2.new(0.5, -140, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
frame.Parent = sg

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local text = Instance.new("TextLabel")
text.Size = UDim2.new(1, 0, 1, 0)
text.BackgroundTransparency = 1
text.Text = "作者 065"
text.TextColor3 = Color3.fromRGB(255, 215, 0)  -- 金色
text.TextStrokeTransparency = 0.4
text.TextStrokeColor3 = Color3.new(0, 0, 0)
text.Font = Enum.Font.GothamBold
text.TextSize = 42
text.Parent = frame

-- 淡入
frame.BackgroundTransparency = 1
text.TextTransparency = 1

TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {BackgroundTransparency = 0.3}):Play()
TweenService:Create(text, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {TextTransparency = 0}):Play()

-- 3秒後淡出消失
task.delay(3, function()
    TweenService:Create(frame, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {BackgroundTransparency = 1}):Play()
    TweenService:Create(text, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {TextTransparency = 1}):Play()
    
    task.wait(0.9)
    sg:Destroy()
end)

-- ==================== 功能控制 UI 面板 ====================
-- 按 Insert 開啟/關閉面板
-- 點擊按鈕觸發對應快捷鍵：E N K Q H Z O
-- 半透明、可拖動、傳送改 K、新增「自動急殺」、飛行改 Z、面板移到左邊

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ControlPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 主框架（半透明黑底，移到左邊）
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 450)
mainFrame.Position = UDim2.new(0, 20, 0.5, -225)  -- 左邊 20 像素，垂直置中
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BackgroundTransparency = 0.4
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 80, 255)
stroke.Transparency = 0.6
stroke.Thickness = 1.5
stroke.Parent = mainFrame

-- 標題
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "功能控制面板"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

-- 按鈕列表（飛行改成 Z）
local buttons = {
    {name = "ESP",        key = Enum.KeyCode.E},
    {name = "穿牆",       key = Enum.KeyCode.N},
    {name = "傳送",       key = Enum.KeyCode.K},
    {name = "鎖頭",       key = Enum.KeyCode.Q},
    {name = "鎖血",       key = Enum.KeyCode.H},
    {name = "飛行",       key = Enum.KeyCode.Z},   -- ← 改成 Z
    {name = "自動擊殺",   key = Enum.KeyCode.O},
}

local btnList = {}

for i, btnInfo in ipairs(buttons) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 50)
    btn.Position = UDim2.new(0.05, 0, 0, 45 + (i-1)*55)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BackgroundTransparency = 0.5
    btn.Text = btnInfo.name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 16
    btn.TextWrapped = true
    btn.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn
    
    -- 點擊 = 模擬按下對應快捷鍵
    btn.MouseButton1Click:Connect(function()
        local virtualInput = game:GetService("VirtualInputManager")
        virtualInput:SendKeyEvent(true, btnInfo.key, false, game)
        task.wait(0.05)
        virtualInput:SendKeyEvent(false, btnInfo.key, false, game)
        
        print(btnInfo.name .. " 已觸發")
    end)
    
    btnList[btnInfo.name] = btn
end

-- 面板開關（Insert）
local panelEnabled = false
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        panelEnabled = not panelEnabled
        mainFrame.Visible = panelEnabled
    end
end)


-- Rivals 按 K 瞬移到最近敵人腳下（視角不變）
-- 每次按 K 傳送到距離最近的活著敵人腳下

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local function teleportToClosestEnemy()
    local closestRoot = nil
    local minDistance = math.huge
    
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then
        print("自己角色或 HumanoidRootPart 未載入")
        return
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local enemyRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChild("Humanoid")
            
            if enemyRoot and hum and hum.Health > 0 then
                local distance = (myRoot.Position - enemyRoot.Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    closestRoot = enemyRoot
                end
            end
        end
    end
    
    if not closestRoot then
        print("沒有找到活著的敵人")
        return
    end
    
    -- 傳送到敵人腳下（Y軸 +3 避免卡地）
    myRoot.CFrame = closestRoot.CFrame * CFrame.new(0, 3, 0)
    print("已瞬移到最近敵人腳下！（距離：" .. math.floor(minDistance) .. " studs）")
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.K then
        teleportToClosestEnemy()
    end
end)


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





-- fly.lua - 按 Z 起飛（Fly）腳本
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
    if input.KeyCode == Enum.KeyCode.Z then
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



-- 按 O 鍵：自動瞬移到最近敵人身上 + 鎖頭 + 自動開槍 (AUTO KILL)
-- 按一次 O 開啟/關閉

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local autoKillEnabled = false
local connection = nil

local function findClosestEnemy()
    local closest = nil
    local minDist = math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local enemyRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChild("Humanoid")
            if enemyRoot and hum and hum.Health > 0 then
                local dist = (myRoot.Position - enemyRoot.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = plr.Character
                end
            end
        end
    end
    return closest
end

local function autoKillLoop()
    if not autoKillEnabled then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local targetChar = findClosestEnemy()
    if not targetChar then return end
    
    local targetHead = targetChar:FindFirstChild("Head")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHead or not targetRoot then return end
    
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    -- 1. 瞬移到敵人身上（腳下）
    myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 0)  -- 直接疊在敵人身上
    
    -- 2. 鎖頭（瞬間轉視角到敵人頭）
    local cam = workspace.CurrentCamera
    cam.CFrame = CFrame.new(cam.CFrame.Position, targetHead.Position)
    
    -- 3. 自動開槍（模擬左鍵按下）
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        -- 強制射擊（如果有 Fire remote 就 FireServer）
        local fireRemote = tool:FindFirstChild("Fire") or tool:FindFirstChild("Shoot")
        if fireRemote and fireRemote:IsA("RemoteEvent") then
            fireRemote:FireServer(targetHead.Position)  -- 瞄準頭部射擊
        else
            -- 沒有 remote 就模擬左鍵
            mouse1press()
            task.wait(0.01)
            mouse1release()
        end
    end
end

-- 每幀執行（當開啟時）
connection = RunService.RenderStepped:Connect(function()
    if autoKillEnabled then
        pcall(autoKillLoop)
    end
end)

-- 按 O 切換
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.O then
        autoKillEnabled = not autoKillEnabled
        print("AUTO KILL（瞬移+鎖頭+自動開槍）：" .. (autoKillEnabled and "開啟" or "關閉"))
    end
end)

-- 角色重生時保持狀態
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if autoKillEnabled then
        -- 重新啟動
    end
end)


-- 按 Insert 顯示/隱藏 小型座標 + FPS UI
-- 左上角小條，半透明、可拖動

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoordFPS"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 主框架（小條）
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 50)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = false
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 100, 255)
stroke.Transparency = 0.7
stroke.Thickness = 1
stroke.Parent = frame

-- 顯示文字
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -10, 1, -10)
label.Position = UDim2.new(0, 5, 0, 5)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(220, 220, 255)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 14
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Center
label.Text = "座標：--- | FPS：---"
label.Parent = frame

-- 更新座標 + FPS
local lastTime = tick()
local frameCount = 0

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    
    local now = tick()
    if now - lastTime >= 1 then
        local fps = math.floor(frameCount / (now - lastTime))
        frameCount = 0
        lastTime = now
        
        local char = LocalPlayer.Character
        local pos = char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position or Vector3.new(0,0,0)
        
        label.Text = string.format("座標：%.0f, %.0f, %.0f | FPS：%d", pos.X, pos.Y, pos.Z, fps)
    end
end)

-- 按 Insert 開關
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        frame.Visible = not frame.Visible
    end
end)


-- Rivals F3 風格 Debug 面板（附近敵人 500 studs + 剩餘敵人 + 經過時間 + 智能 AI）
-- 按 F3 開啟/關閉

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Teams = game:GetService("Teams")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local DETECTION_RANGE = 500  -- ← 已改為 500 studs

local panelEnabled = false
local startTime = tick()  -- 用來計算遊戲開始經過的時間

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "F3Panel"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 280)
mainFrame.Position = UDim2.new(0.5, -210, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.BackgroundTransparency = 0.4
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- 標題
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "F3 Debug 面板 - Rivals"
title.TextColor3 = Color3.fromRGB(100, 255, 100)
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.Parent = mainFrame

-- 資訊文字
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0, 95)
infoLabel.Position = UDim2.new(0, 10, 0, 35)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
infoLabel.Font = Enum.Font.SourceSans
infoLabel.TextSize = 15
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.TextWrapped = true
infoLabel.Parent = mainFrame

-- 敵人列表
local enemiesFrame = Instance.new("Frame")
enemiesFrame.Size = UDim2.new(1, -20, 0, 115)
enemiesFrame.Position = UDim2.new(0, 10, 0, 135)
enemiesFrame.BackgroundTransparency = 1
enemiesFrame.Parent = mainFrame

local enemiesList = Instance.new("TextLabel")
enemiesList.Size = UDim2.new(1, 0, 1, 0)
enemiesList.BackgroundTransparency = 1
enemiesList.TextColor3 = Color3.fromRGB(255, 255, 255)
enemiesList.Font = Enum.Font.SourceSans
enemiesList.TextSize = 14
enemiesList.TextXAlignment = Enum.TextXAlignment.Left
enemiesList.TextYAlignment = Enum.TextYAlignment.Top
enemiesList.TextWrapped = true
enemiesList.Parent = enemiesFrame

-- AI 策略建議
local strategyLabel = Instance.new("TextLabel")
strategyLabel.Size = UDim2.new(1, -20, 0, 40)
strategyLabel.Position = UDim2.new(0, 10, 1, -50)
strategyLabel.BackgroundTransparency = 1
strategyLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
strategyLabel.Font = Enum.Font.GothamSemibold
strategyLabel.TextSize = 15
strategyLabel.Text = "AI 建議：掃描中..."
strategyLabel.Parent = mainFrame

-- 更新面板
local lastStrategyUpdate = 0

RunService.Heartbeat:Connect(function()
    if not panelEnabled then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    local myHP = math.floor(hum.Health)
    local myTeam = LocalPlayer.Team
    
    -- 判斷是否為隊友（支援 5v5 與 FFA）
    local function isAlly(plr)
        if not myTeam then return plr == LocalPlayer end
        return plr.Team == myTeam
    end
    
    -- 收集資料
    local nearbyEnemies = {}
    local ourAlive = 0
    local enemyAlive = 0
    local ourTotalHP = 0
    local enemyTotalHP = 0
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local targetHum = plr.Character:FindFirstChild("Humanoid")
            if targetHum and targetHum.Health > 0 then
                if isAlly(plr) then
                    ourAlive += 1
                    ourTotalHP += targetHum.Health
                else
                    enemyAlive += 1
                    enemyTotalHP += targetHum.Health
                    
                    -- 附近敵人（500 studs 內 + 視野內）
                    local head = plr.Character:FindFirstChild("Head")
                    if head then
                        local dist = (root.Position - head.Position).Magnitude
                        if dist <= DETECTION_RANGE then
                            local _, onScreen = Camera:WorldToViewportPoint(head.Position)
                            if onScreen then
                                table.insert(nearbyEnemies, {
                                    name = plr.Name,
                                    hp = math.floor(targetHum.Health),
                                    dist = math.floor(dist)
                                })
                            end
                        end
                    end
                end
            end
        end
    end
    
    table.sort(nearbyEnemies, function(a, b) return a.dist < b.dist end)
    
    -- 經過時間
    local elapsed = tick() - startTime
    local minutes = math.floor(elapsed / 60)
    local seconds = math.floor(elapsed % 60)
    local timeStr = string.format("%02d:%02d", minutes, seconds)
    
    -- 資訊顯示
    infoLabel.Text = string.format(
        "經過時間: %s\n自己血量: %d\n我方: %d人 | 敵方: %d人\n剩餘敵人: %d\n附近敵人: %d (≤%d studs)\nFPS: %d",
        timeStr, myHP, ourAlive, enemyAlive, enemyAlive, #nearbyEnemies, DETECTION_RANGE, math.floor(1 / RunService.Heartbeat:Wait())
    )
    
    -- 敵人列表
    local enemyText = string.format("附近敵人 (≤ %d studs):\n", DETECTION_RANGE)
    if #nearbyEnemies == 0 then
        enemyText = enemyText .. "  目前 500 studs 內無敵人"
    else
        for _, e in ipairs(nearbyEnemies) do
            enemyText = enemyText .. string.format("  %s | HP: %d | %d studs\n", e.name, e.hp, e.dist)
        end
    end
    enemiesList.Text = enemyText
    
    -- AI 建議（每 2 秒更新，調整距離門檻以適應 500 studs 範圍）
    if tick() - lastStrategyUpdate >= 2 then
        lastStrategyUpdate = tick()
        
        local nearbyCount = #nearbyEnemies
        local minDist = nearbyCount > 0 and nearbyEnemies[1].dist or 999
        local playerGap = ourAlive - enemyAlive
        local hpGap = math.floor(ourTotalHP - enemyTotalHP)
        
        local suggestion = "AI 建議："
        
        if enemyAlive == 0 then
            suggestion = suggestion .. "敵方全滅！推進或守勝"
        elseif nearbyCount > 0 and minDist <= 70 then   -- 近距離調整
            local closestHP = nearbyEnemies[1].hp
            if closestHP <= 50 then
                suggestion = suggestion .. "近身低血敵！使用Auto kill"
            else
                suggestion = suggestion .. "近距離高血 → 傳送鎖頭"
            end
        elseif playerGap >= 3 and hpGap > 200 then
            suggestion = suggestion .. "我方大優勢 → 開啟鎖頭追擊"
        elseif playerGap <= -3 or hpGap < -250 then
            suggestion = suggestion .. "我方劣勢 → 開啟鎖血鎖頭穿牆"
        elseif nearbyCount >= 4 then
            suggestion = suggestion .. "附近多人 → 開啟飛行穿牆"
        elseif minDist <= 180 then   -- 中距離調整（500 範圍內）
            suggestion = suggestion .. "中距離接觸 → 掩體移動戰"
        elseif enemyAlive >= 5 then
            suggestion = suggestion .. "敵人仍多 → 鎖頭穿牆逐個擊破"
        else
            suggestion = suggestion .. "遠距離敵人 → 開啟鎖頭傳送"
        end
        
        strategyLabel.Text = suggestion
    end
end)

-- 按 F3 開關
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F3 then
        panelEnabled = not panelEnabled
        mainFrame.Visible = panelEnabled
    end
end)


