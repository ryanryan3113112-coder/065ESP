local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. 建立 UI 容器
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevOverlay"
screenGui.Parent = playerGui

-- 2. 建立帶有底色的框架 (增加層次感)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 70)
frame.Position = UDim2.new(0.5, -175, 0.45, -35)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- 3. 建立帶有霓虹效果的文字
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- 科技青色
textLabel.Text = "本外掛開發者: 065"
textLabel.Font = Enum.Font.Code
textLabel.TextScaled = true
textLabel.Parent = frame

-- 4. 帥氣的動畫邏輯
local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- 進場動畫
frame.Size = UDim2.new(0, 0, 0, 70) -- 從零開始展開
TweenService:Create(frame, tweenInfo, {Size = UDim2.new(0, 350, 0, 70)}):Play()

task.wait(2.5) -- 顯示時間

-- 出場動畫
local outInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
TweenService:Create(frame, outInfo, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 70)}):Play()
TweenService:Create(textLabel, outInfo, {TextTransparency = 1}):Play()

task.wait(0.5)
screenGui:Destroy()
