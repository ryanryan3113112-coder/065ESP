-- [[ 完整修正版：Anti-AFK 狀態燈腳本 ]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- 1. 建立 UI 容器 (優先使用 gethui 避免被遊戲偵測或清除)
local sg = Instance.new("ScreenGui")
sg.Name = "AntiAFK_Status_Fixed"
sg.ResetOnSpawn = false

local success_parent, err_parent = pcall(function()
    if gethui then
        sg.Parent = gethui()
    else
        sg.Parent = CoreGui
    end
end)

-- 2. 建立主背景框
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 60, 0, 30)
frame.Position = UDim2.new(0, 30, 0, 30) -- 畫面左上角
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true -- 允許手動拖動位置
frame.Parent = sg

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8) -- 修正：使用 UDim
frameCorner.Parent = frame

-- 3. 狀態指示燈 (圓點)
local light = Instance.new("Frame")
light.Name = "Indicator"
light.Size = UDim2.new(0, 12, 0, 12)
light.Position = UDim2.new(0, 10, 0.5, -6)
light.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- 預設紅色 (未執行)
light.BorderSizePixel = 0
light.Parent = frame

local lightCorner = Instance.new("UICorner")
lightCorner.CornerRadius = UDim.new(1, 0) -- 修正：使用 UDim 設為正圓
lightCorner.Parent = light

-- 4. 關閉按鈕 (叉叉)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 1, 0)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Parent = frame

closeBtn.MouseButton1Click:Connect(function()
    sg:Destroy()
end)

-- 5. 防踢出邏輯核心
local function RunAntiAFK()
    -- 確保本地玩家加載完成
    local lp = Players.LocalPlayer
    if not lp then return end

    if getconnections then
        local isExecuted = false
        -- 遍歷所有 Idled 事件連接並停用它們
        for _, v in pairs(getconnections(lp.Idled)) do
            if v.Disable then
                v:Disable()
                isExecuted = true
            elseif v.Disconnect then
                v:Disconnect()
                isExecuted = true
            end
        end
        
        if isExecuted then
            light.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- 🟢 執行成功
        else
            light.BackgroundColor3 = Color3.fromRGB(255, 200, 0) -- 🟡 找不到連接 (可能已停用)
        end
    else
        light.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- 🔴 執行器不支援
    end
end

-- 執行
task.spawn(RunAntiAFK)
