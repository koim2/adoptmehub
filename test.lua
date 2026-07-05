-- Bin's Clean Premium Inspired Spawner v4.1
print("========================================")
print("Bin's Clean Premium Spawner v4.1")
print("========================================")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game.Players.LocalPlayer

-- Кэш remotes
local remotes = {}
for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") and (v.Name:find("Pet") or v.Name:find("Give") or v.Name:find("Spawn")) then
        table.insert(remotes, v)
    end
end

local function spawnPet(name, amount, tier)
    amount = math.min(tonumber(amount) or 1, 1)
    tier = tier or "Legendary"
    
    for i = 1, amount do
        for _, remote in ipairs(remotes) do
            pcall(function()
                remote:FireServer({
                    PetName = name,
                    Tier = tier,
                    Action = "Give",
                    Bypass = true,
                    Amount = 1
                })
            end)
            pcall(function()
                remote:FireServer(name, tier, true)
            end)
        end
        wait(2.8)
    end
    print("Спавн " .. name .. " завершён.")
end

-- GUI
local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.Parent = LocalPlayer.PlayerGui

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 430, 0, 360)
f.Position = UDim2.new(0.5, -215, 0.5, -180)
f.BackgroundColor3 = Color3.fromRGB(25,25,25)
f.Parent = sg

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,60)
title.Text = "Bin's v4.1 Premium"
title.BackgroundColor3 = Color3.fromRGB(150,0,0)
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = f

local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(0.9,0,0,50)
nameBox.Position = UDim2.new(0.05,0,0.22,0)
nameBox.PlaceholderText = "Shadow Dragon"
nameBox.Parent = f

local amtBox = Instance.new("TextBox")
amtBox.Size = UDim2.new(0.9,0,0,50)
amtBox.Position = UDim2.new(0.05,0,0.4,0)
amtBox.Text = "1"
nameBox.Parent = f

local tierBox = Instance.new("TextBox")
tierBox.Size = UDim2.new(0.9,0,0,50)
tierBox.Position = UDim2.new(0.05,0,0.58,0)
tierBox.Text = "Legendary"
tierBox.Parent = f

local spawnBtn = Instance.new("TextButton")
spawnBtn.Size = UDim2.new(0.9,0,0,60)
spawnBtn.Position = UDim2.new(0.05,0,0.78,0)
spawnBtn.Text = "SPAWN"
spawnBtn.BackgroundColor3 = Color3.fromRGB(170,20,20)
spawnBtn.Parent = f

spawnBtn.MouseButton1Click:Connect(function()
    spawnPet(nameBox.Text, amtBox.Text, tierBox.Text)
end)

print("v4.1 ready. Use carefully.")
