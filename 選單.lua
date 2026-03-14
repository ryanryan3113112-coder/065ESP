-- 狀態面板：預設全紅色，按下快捷鍵變綠色，再按恢復紅色
-- 黑底、可拖動

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ToggleStatus"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 40)
frame.Position = UDim2.new(0.02, 0, 0.18, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = false
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "功能狀態"
title.TextColor3 = Color3.fromRGB(200, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Visible = false
title.Parent = frame

local statusRows = {}
local rowHeight = 26
local currentRows = 0

-- 快捷鍵對應顯示文字（全預設紅色）
local keyConfig = {
    [Enum.KeyCode.E] = "E 透視",
    [Enum.KeyCode.N] = "N 穿牆",
    [Enum.KeyCode.F] = "F 起飛",
    [Enum.KeyCode.Q] = "Q 自瞄",
    [Enum.KeyCode.H] = "H 鎖血",
}

-- 建立一行
local function createRow(key, displayText)
    if statusRows[key] then return end
    
    currentRows = currentRows + 1
    frame.Size = UDim2.new(0, 220, 0, 30 + currentRows * rowHeight)
    title.Visible = true
    frame.Visible = true
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, rowHeight)
    lbl.Position = UDim2.new(0, 10, 0, 35 + (currentRows-1)*rowHeight)
    lbl.BackgroundTransparency = 1
    lbl.Text = displayText .. " : 關閉"
    lbl.TextColor3 = Color3.fromRGB(255, 80, 80)  -- 預設紅色
    lbl.Font = Enum.Font.SourceSansSemibold
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    statusRows[key] = {label = lbl, isGreen = false}
end

-- 按鍵處理
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    local display = keyConfig[input.KeyCode]
    if display then
        local key = input.KeyCode
        
        -- 還沒出現就建立（預設紅色）
        if not statusRows[key] then
            createRow(key, display)
        end
        
        -- 切換顏色
        local row = statusRows[key]
        row.isGreen = not row.isGreen
        
        row.label.Text = display .. " : " .. (row.isGreen and "開啟" or "關閉")
        row.label.TextColor3 = row.isGreen and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    end
end)

print("狀態面板已載入")
print("所有功能預設紅色，按 E/N/F/Q/H 後變綠色，再按恢復紅色")
