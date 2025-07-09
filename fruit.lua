local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

repeat task.wait() until LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- โหลด WindUI
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not success or not WindUI then
    warn("❌ โหลด WindUI ไม่สำเร็จ")
    return
end

-- UI
local Window = WindUI:CreateWindow({
    Title = "Anime Fruit Auto All Skills",
    Icon = "zap",
    Author = "By Poomipad Chaisanan",
    Size = UDim2.fromOffset(500, 400),
    Theme = "Dark",
})
local Tab = Window:Tab({ Title = "Main", Icon = "swords" })
Tab:Section({ Title = "Auto Farm Settings" })

-- หา Remote (เปลี่ยนให้ตรงกับในเกม)
local remote = ReplicatedStorage:WaitForChild("EventConfiguration"):WaitForChild("SkillRemote") -- ⚠️ เปลี่ยนชื่อให้ตรง

-- หาศัตรูใกล้สุด
local function getClosestEnemy()
    local myChar = LocalPlayer.Character
    local myPos = myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position
    if not myPos then return end
    local closest, dist = nil, math.huge

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            if obj.Humanoid.Health > 0 then
                local d = (myPos - obj.HumanoidRootPart.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = obj
                end
            end
        end
    end
    return closest
end

-- ค้นหาชื่อสกิลทั้งหมด
local function getAllSkills()
    local skillList = {}
    local skillFolder = LocalPlayer:FindFirstChild("Skills") or LocalPlayer:FindFirstChild("Backpack") -- ลองเช็คหลายที่
    if not skillFolder then return skillList end

    for _, skill in pairs(skillFolder:GetChildren()) do
        if skill:IsA("RemoteEvent") or skill:IsA("Tool") then
            table.insert(skillList, skill.Name)
        end
    end
    return skillList
end

-- ตัวแปรควบคุม
local currentSkill = 1
local skillDelay = 0.3
local skillList = {}
local farming = false
local connection = nil

-- UI Slider ปรับความเร็ว
Tab:Slider({
    Title = "ดีเลย์ระหว่างใช้สกิล (วินาที)",
    Min = 0.05,
    Max = 1,
    Default = 0.3,
    Callback = function(v)
        skillDelay = v
    end
})

-- ปุ่มเปิด/ปิด
Tab:Toggle({
    Title = "Auto TP + All Skills",
    Icon = "magic",
    Value = false,
    Callback = function(enabled)
        farming = enabled
        if connection then
            connection:Disconnect()
            connection = nil
        end

        if not enabled then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then root.Anchored = false end
            return
        end

        -- โหลดสกิลทั้งหมด
        skillList = getAllSkills()
        currentSkill = 1

        -- เริ่มลูป
        connection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            local target = getClosestEnemy()
            if target and target:FindFirstChild("HumanoidRootPart") then
                root.Anchored = true
                root.CFrame = target.HumanoidRootPart.CFrame + Vector3.new(0, 30, 0)

                if tick() - (connection._lastCast or 0) >= skillDelay then
                    local skillName = skillList[currentSkill]
                    if skillName then
                        -- ยิงสกิล (เปลี่ยนรูปแบบตามระบบ Remote จริงของเกม)
                        remote:FireServer("cast", skillName)

                        currentSkill = (currentSkill % #skillList) + 1
                    end
                    connection._lastCast = tick()
                end
            end
        end)
    end
})
