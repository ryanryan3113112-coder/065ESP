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
