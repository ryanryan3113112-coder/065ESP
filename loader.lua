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


