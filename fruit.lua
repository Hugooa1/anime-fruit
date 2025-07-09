local autoTP = false
local tpConnection

-- ฟังก์ชันค้นหาศัตรูที่ใกล้ที่สุด
local function getNearestEnemy()
    local root = getHumanoidRootPart()
    if not root then return nil end

    local closestEnemy = nil
    local shortestDistance = math.huge

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if v ~= player.Character and v.Humanoid.Health > 0 then
                local distance = (v.HumanoidRootPart.Position - root.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestEnemy = v
                end
            end
        end
    end

    return closestEnemy
end

-- Toggle สำหรับ Auto TP
Tabs.MainTab:Toggle({
    Title = "Auto TP to Enemy",
    Icon = "crosshair",
    Value = false,
    Callback = function(Value)
        autoTP = Value

        if tpConnection then
            tpConnection:Disconnect()
            tpConnection = nil
        end

        if autoTP then
            tpConnection = RunService.RenderStepped:Connect(function()
                local root = getHumanoidRootPart()
                if not root then return end

                local enemy = getNearestEnemy()
                if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                    local offset = Vector3.new(0, 0, -5) -- อยู่ห่างจากศัตรู 5 studs
                    root.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(offset)
                end
            end)
        else
            -- หยุดวาร์ป
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Anchored = false
            end
        end
    end
})
