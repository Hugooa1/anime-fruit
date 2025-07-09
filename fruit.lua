local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

repeat task.wait() until LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- ✅ โหลด WindUI
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not success or not WindUI then
    warn("❌ โหลด WindUI ไม่สำเร็จ")
    return
end

-- ✅ UI Window
local Window = WindUI:CreateWindow({
    Title = "Anime Fruit",
    Icon = "door-open",
    Author = "By Poomipad Chaisanan",
    Size = UDim2.fromOffset(500, 400),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    Background = "", 
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function() end,
    },
})

local Tabs = {
    MainTab = Window:Tab({ Title = "Main", Icon = "crown" }),
}
Tabs.MainTab:Section({ Title = "Main" })

-- ✅ ฟังก์ชันหาศัตรูใกล้ที่สุด
local function getClosestEnemy()
    local closest, shortest = nil, math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            if obj.Humanoid.Health > 0 then
                local dist = (myPos - obj.HumanoidRootPart.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = obj
                end
            end
        end
    end

    return closest
end

-- ✅ TP ไปมอนสเตอร์
local floatConnection
Tabs.MainTab:Toggle({
    Title = "TP to Monster",
    Icon = "crosshair",
    Value = false,
    Callback = function(Value)
        if floatConnection then
            floatConnection:Disconnect()
            floatConnection = nil
        end

        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        if Value then
            floatConnection = RunService.RenderStepped:Connect(function()
                local enemy = getClosestEnemy()
                if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                    root.Anchored = true
                    root.CFrame = enemy.HumanoidRootPart.CFrame + Vector3.new(0, 30, 0)
                end
            end)
        else
            root.Anchored = false
        end
    end
})

-- ✅ โหลด buffer
local buffer
pcall(function()
    buffer = getrenv().buffer or require(ReplicatedStorage:WaitForChild("buffer"))
end)
if not buffer then
    warn("❌ ไม่พบ buffer module")
    return
end

-- ✅ โหลด Remote
local remote
pcall(function()
    remote = ReplicatedStorage:WaitForChild("EventConfiguration"):WaitForChild("Your")
end)
if not remote then
    warn("❌ ไม่พบ Remote Event")
    return
end

-- ✅ สกิลที่เตรียมไว้
local skillArgs = {
    {
        buffer.fromstring("u"),
        buffer.fromstring("\254\a\000\006\0045098\006\00550981\006\004cast\v>\211\139...") -- ใส่ args เต็มของคุณตรงนี้
    },
    -- 🔁 เพิ่มสกิลทั้งหมดของคุณที่นี่
}

-- ✅ Auto Skill + UI Slider
local casting = false
local connection
local currentIndex = 1
local lastCast = 0
local cooldown = 0.3 -- default

Tabs.MainTab:Slider({
    Title = "ปรับความเร็วการยิงสกิล (วินาที)",
    Min = 0.01,
    Max = 1.0,
    Default = 0.3,
    Rounding = 2,
    Callback = function(value)
        cooldown = value
    end
})

Tabs.MainTab:Toggle({
    Title = "Auto Skill",
    Icon = "zap",
    Value = false,
    Callback = function(Value)
        casting = Value

        if connection then
            connection:Disconnect()
            connection = nil
        end

        if casting then
            lastCast = 0
            connection = RunService.RenderStepped:Connect(function()
                local currentTime = tick()
                if currentTime - lastCast >= cooldown then
                    if skillArgs[currentIndex] then
                        remote:FireServer(unpack(skillArgs[currentIndex]))
                        currentIndex = (currentIndex % #skillArgs) + 1
                        lastCast = currentTime
                    end
                end
            end)
        end
    end
})
