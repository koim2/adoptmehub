-- Adopt Me Pet Spawner GUI by Bin
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Создаём GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BinPetSpawner"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "Adopt Me Pet Spawner - Bin Edition"
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextScaled = true
Title.Parent = MainFrame

local PetNameBox = Instance.new("TextBox")
PetNameBox.Size = UDim2.new(0.8, 0, 0, 40)
PetNameBox.Position = UDim2.new(0.1, 0, 0.3, 0)
PetNameBox.PlaceholderText = "Название пета (Dragon, Frost Fury...)"
PetNameBox.Text = ""
PetNameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PetNameBox.TextColor3 = Color3.new(1,1,1)
PetNameBox.TextScaled = true
PetNameBox.Parent = MainFrame

local AmountBox = Instance.new("TextBox")
AmountBox.Size = UDim2.new(0.8, 0, 0, 40)
AmountBox.Position = UDim2.new(0.1, 0, 0.5, 0)
AmountBox.PlaceholderText = "Количество (1-50)"
AmountBox.Text = "1"
AmountBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AmountBox.TextColor3 = Color3.new(1,1,1)
AmountBox.TextScaled = true
AmountBox.Parent = MainFrame

local SpawnButton = Instance.new("TextButton")
SpawnButton.Size = UDim2.new(0.8, 0, 0, 50)
SpawnButton.Position = UDim2.new(0.1, 0, 0.7, 0)
SpawnButton.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
SpawnButton.Text = "СПАВНИТЬ ПЕТОВ"
SpawnButton.TextColor3 = Color3.new(1,1,1)
SpawnButton.TextScaled = true
SpawnButton.Parent = MainFrame

-- Drag
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Spawn function
local function SpawnPets()
    local petName = PetNameBox.Text
    local amount = tonumber(AmountBox.Text) or 1
    
    if petName == "" then 
        print("Введи название пета, сука!")
        return 
    end
    
    print("Спавним " .. amount .. "x " .. petName)
    
    for i = 1, math.min(amount, 20) do  -- лимит чтобы не кикнуло
        local args = {
            [1] = petName,
            [2] = "Legendary",
            [3] = true  -- neon/mega flags
        }
        
        pcall(function()
            -- Основные remotes Adopt Me
            local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
            for _, v in pairs(remotesFolder:GetDescendants()) do
                if v:IsA("RemoteEvent") and (v.Name:find("Pet") or v.Name:find("Spawn") or v.Name:find("Give")) then
                    v:FireServer(unpack(args))
                end
            end
        end)
        
        wait(0.35)
    end
    
    print("Готово!")
end

SpawnButton.MouseButton1Click:Connect(SpawnPets)

print("GUI Pet Spawner загружен. Перетаскивай окно.")
