-- Bin's Adopt Me Pet Spawner v3.2
print("========================================")
print("Bin's Private Spawner v3.2 ЗАПУЩЕН")
print("========================================")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local function FireAllRemotes(petName, tier)
    tier = tier or "Legendary"
    
    local payloads = {
        {PetName = petName, Tier = tier, Action = "GivePet"},
        {[1] = petName, [2] = tier, [3] = true},
        {Pet = petName, Type = tier}
    }
    
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            for _, payload in ipairs(payloads) do
                pcall(function()
                    remote:FireServer(payload)
                end)
                pcall(function()
                    remote:FireServer(unpack(payload))
                end)
            end
        end
    end
end

local function SpawnPet(name, count, tier)
    count = math.min(tonumber(count) or 1, 2)
    print("[v3.2] Спавн " .. count .. "x " .. (name or "Unknown"))
    
    for i = 1, count do
        FireAllRemotes(name, tier)
        wait(1.8)
    end
    print("[v3.2] Завершено. Проверь инвентарь.")
end

-- GUI
local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 340)
frame.Position = UDim2.new(0.5, -210, 0.5, -170)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Parent = sg

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,55)
title.Text = "Bin's Spawner v3.2"
title.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = frame

local petBox = Instance.new("TextBox")
petBox.Size = UDim2.new(0.9,0,0,50)
petBox.Position = UDim2.new(0.05,0,0.22,0)
petBox.PlaceholderText = "Shadow Dragon"
petBox.TextScaled = true
petBox.Parent = frame

local countBox = Instance.new("TextBox")
countBox.Size = UDim2.new(0.9,0,0,50)
countBox.Position = UDim2.new(0.05,0,0.4,0)
countBox.Text = "1"
countBox.TextScaled = true
countBox.Parent = frame

local tierBox = Instance.new("TextBox")
tierBox.Size = UDim2.new(0.9,0,0,50)
tierBox.Position = UDim2.new(0.05,0,0.58,0)
tierBox.Text = "Legendary"
tierBox.TextScaled = true
tierBox.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.9,0,0,60)
btn.Position = UDim2.new(0.05,0,0.78,0)
btn.Text = "SPAWN PET"
btn.BackgroundColor3 = Color3.fromRGB(170, 20, 20)
btn.TextColor3 = Color3.new(1,1,1)
btn.TextScaled = true
btn.Parent = frame

btn.MouseButton1Click:Connect(function()
    SpawnPet(petBox.Text, countBox.Text, tierBox.Text)
end)

print("[v3.2] GUI загружена. Пробуй.")
