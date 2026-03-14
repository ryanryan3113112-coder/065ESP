local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local MAX_DISTANCE = 50 -- 定義有效範圍

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.T then
        local character = localPlayer.Character
        if not character then return end
        
        -- 尋找最近或隨機的目標（此處為邏輯示意）
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                local myRoot = character:FindFirstChild("HumanoidRootPart")
                
                if targetRoot and myRoot then
                    local distance = (targetRoot.Position - myRoot.Position).Magnitude
                    if distance <= MAX_DISTANCE then
                        -- 執行傳送（實務上建議透過 RemoteEvent 由伺服器執行）
                        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2) 
                        break
                    end
                end
            end
        end
    end
end)
