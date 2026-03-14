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

print("按 O 開啟/關閉 AUTO KILL 已載入")
print("瞬移到敵人身上 + 鎖頭 + 自動開槍")
print("⚠️ 極高風險！Byfron 會立刻偵測異常位移、視角、射擊，ban 機率極高")
print("只適合小號測試，開 1 局就關")
