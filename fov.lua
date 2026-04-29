-- // 服務
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- // 變數
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local targetFOV = 200

-- // 核心功能：強制設定 FOV
local function applyFOV()
    if camera then
        camera.FieldOfView = targetFOV
    end
end

-- // 初始執行
applyFOV()

-- // 角色重生時重新套用 (防止某些遊戲在重生時重設相機)
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5) -- 稍微等待確保相機已加載
    applyFOV()
end)

-- // 強制鎖定循環：防止被遊戲腳本覆蓋
RunService.RenderStepped:Connect(function()
    if camera.FieldOfView ~= targetFOV then
        camera.FieldOfView = targetFOV
    end
end)
