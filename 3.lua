-- Bin's Adopt Me Pet Spawner v3.3 (Ultra Stealth)
print("========================================")
print("Bin's Private Spawner v3.3 ULTRA STEALTH")
print("========================================")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local function SpawnPetStealth(name, count, tier)
    count = math.min(tonumber(count) or 1, 1) -- только 1 за раз
    tier = tier or "Legendary"
    
    print("[v3.3] Stealth спавн 1x " .. name)
    
    for i = 1, count do
        pcall(function()
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    pcall(function()
                        remote:FireServer({PetName = name, Tier = tier, Action = "Give"})
                    end)
                    wait(0.7)
                end
            end
        end)
        
        wait(4) -- очень большая пауза
    end
    
    print("[v3.3] Отправлено. Подожди 30+ секунд и проверь инвентарь на новом сервере.")
end

-- GUI
local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.Parent = LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 430, 0, 360)
frame.Position = UDim2.new(0.5, -215, 0.5, -180)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
frame.Parent = sg

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,60)
title.Text = "v3.3 ULTRA STEALTH"
title.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = frame

local petBox = Instance.new("TextBox")
petBox.Size = UDim2.new(0.9,0,0,50)
petBox.Position = UDim2.new(0.05,0,0.23,0)
petBox.PlaceholderText = "Pet Name"
petBox.TextScaled = true
petBox.Parent = frame

local countBox = Instance.new("TextBox")
countBox.Size = UDim2.new(0.9,0,0,50)
countBox.Position = UDim2.new(0.05,0,0.42,0)
countBox.Text = "1"
countBox.TextScaled = true
countBox.Parent = frame

local tierBox = Instance.new("TextBox")
tierBox.Size = UDim2.new(0.9,0,0,50)
tierBox.Position = UDim2.new(0.05,0,0.61,0)
tierBox.Text = "Legendary"
tierBox.TextScaled = true
tierBox.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.9,0,0,55)
btn.Position = UDim2.new(0.05,0,0.8,0)
btn.Text = "SPAWN (1 PET)"
btn.BackgroundColor3 = Color3.fromRGB(130, 10, 10)
btn.TextColor3 = Color3.new(1,1,1)
btn.TextScaled = true
btn.Parent = frame

btn.MouseButton1Click:Connect(function()
    SpawnPetStealth(petBox.Text, countBox.Text, tierBox.Text)
end)

print("[v3.3] Готово. Спавнь по 1 пету с перерывами.")
