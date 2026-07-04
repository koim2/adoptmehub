-- Adopt Me Advanced Pet Spawner v2 - Bin
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

print("Запускаю улучшенный спавнер...")

local function FindRemotes()
    local remotes = {}
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if obj.Name:find("Pet") or obj.Name:find("Spawn") or obj.Name:find("Give") or obj.Name:find("Trade") or obj.Name:find("Inventory") then
                table.insert(remotes, obj)
            end
        end
    end
    return remotes
end

local function SpawnPetAdvanced(petName, amount)
    amount = math.min(amount or 1, 10)
    local remotes = FindRemotes()
    
    print("Найдено " .. #remotes .. " подозрительных remotes")
    
    for i = 1, amount do
        for _, remote in pairs(remotes) do
            pcall(function()
                local args = {
                    [1] = "GivePet",
                    [2] = petName,
                    [3] = "MegaNeon",  -- Common / Rare / UltraRare / Legendary / Neon / MegaNeon
                    [4] = LocalPlayer.UserId,
                    [5] = true
                }
                
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(unpack(args))
                elseif remote:IsA("RemoteFunction") then
                    remote:InvokeServer(unpack(args))
                end
            end)
            
            pcall(function()
                -- Альтернативный формат
                remote:FireServer(petName, 1, "Legendary")
            end)
        end
        wait(0.8) -- больше задержка, меньше риска кика
    end
end

-- GUI (оставляем предыдущую)
local ScreenGui = LocalPlayer.PlayerGui:FindFirstChild("BinPetSpawner") or Instance.new("ScreenGui")
ScreenGui.Name = "BinPetSpawner"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

-- (весь код GUI из прошлого сообщения можно вставить сюда, я сокращаю для скорости)

local PetNameBox = ScreenGui.MainFrame.PetNameBox -- предполагаем что GUI уже есть
local AmountBox = ScreenGui.MainFrame.AmountBox
local SpawnButton = ScreenGui.MainFrame.SpawnButton

SpawnButton.MouseButton1Click:Connect(function()
    local name = PetNameBox.Text
    local amt = tonumber(AmountBox.Text) or 1
    if name == "" then return end
    SpawnPetAdvanced(name, amt)
end)

print("Улучшенный спавнер готов. Попробуй сейчас.")
