-- AXIOM ADOPT ME v11.0 - SMART PETS GUI INJECTOR
-- Finds Pets GUI + positions near Snow Cat

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

local Config = {
    Enabled = true,
    NewPets = {"Huge Cat", "Titanic Dragon", "Shadow Dragon", "Frost Fury", "Mega Neon Bat Dragon", "Diamond Unicorn"},
    Amount = 12
}

local Stats = {Added = 0}

local function FindPetsGUI()
    local gui = LocalPlayer.PlayerGui
    for _, obj in ipairs(gui:GetDescendants()) do
        if (obj.Name:lower():find("pet") or obj.Name:lower():find("inventory")) and (obj:IsA("Frame") or obj:IsA("ScrollingFrame")) then
            return obj
        end
    end
    return nil
end

local function FindSnowCatAnchor()
    local gui = LocalPlayer.PlayerGui
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj.Name == "Snow Cat" or obj.Name:find("Snow Cat") then
            return obj
        end
    end
    return nil
end

local function InjectNearAnchor(anchor, petName)
    if not anchor or not anchor.Parent then return false end
    
    local container = anchor.Parent
    
    local newPet = anchor:Clone()
    newPet.Name = petName .. " [AXIOM v11]"
    
    -- Modify properties to make it unique
    if newPet:FindFirstChild("Rarity") then
        newPet.Rarity.Value = "Legendary"
    else
        local r = Instance.new("StringValue")
        r.Name = "Rarity"
        r.Value = "Legendary"
        r.Parent = newPet
    end
    
    newPet.Parent = container
    
    -- Random slight offset for natural look
    if newPet:IsA("Frame") or newPet:IsA("ImageLabel") then
        newPet.Position = UDim2.new(
            newPet.Position.X.Scale + math.random(-20,20)/100,
            0,
            newPet.Position.Y.Scale + math.random(-10,10)/100,
            0
        )
    end
    
    Stats.Added += 1
    return true
end

local function StartSmartInjector()
    spawn(function()
        while Config.Enabled do
            local petsGUI = FindPetsGUI()
            local snowCat = FindSnowCatAnchor()
            
            if petsGUI and snowCat then
                for i = 1, Config.Amount do
                    local petName = Config.NewPets[math.random(#Config.NewPets)]
                    local success = InjectNearAnchor(snowCat, petName)
                    if success then
                        print("Axiom placed " .. petName .. " near your Snow Cat!")
                    end
                end
                
                StarterGui:SetCore("SendNotification", {
                    Title = "AXIOM v11",
                    Text = Config.Amount .. " pets added near Snow Cat!",
                    Duration = 4
                })
            else
                print("Looking for Pets GUI and Snow Cat...")
            end
            wait(2)
        end
    end)
end

-- GUI Panel
local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
sg.Name = "AxiomSmart"

local f = Instance.new("Frame", sg)
f.Size = UDim2.new(0, 400, 0, 340)
f.Position = UDim2.new(0.02, 0, 0.05, 0)
f.BackgroundColor3 = Color3.fromRGB(8, 8, 25)

local title = Instance.new("TextLabel", f)
title.Text = "🦍 AXIOM v11.0 SMART PETS GUI"
title.Size = UDim2.new(1,0,0,60)
title.BackgroundColor3 = Color3.fromRGB(220, 0, 130)
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

local toggle = Instance.new("TextButton", f)
toggle.Size = UDim2.new(0.9,0,0,50)
toggle.Position = UDim2.new(0.05,0,0.28,0)
toggle.Text = "STOP SMART INJECT"
toggle.BackgroundColor3 = Color3.fromRGB(190, 20, 20)

toggle.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    toggle.Text = Config.Enabled and "STOP SMART INJECT" or "START SMART INJECT"
end)

local count = Instance.new("TextLabel", f)
count.Size = UDim2.new(0.9,0,0,45)
count.Position = UDim2.new(0.05,0,0.5,0)
count.BackgroundTransparency = 1
count.TextColor3 = Color3.fromRGB(0, 255, 150)
count.TextScaled = true
count.Text = "Pets Added Near Snow Cat: 0"

RunService.Heartbeat:Connect(function()
    count.Text = "Pets Added Near Snow Cat: " .. Stats.Added
end)

print("Axiom v11.0 Smart Injector loaded boss man. It will find your Pets GUI and Snow Cat then place new pets right beside them.")
StartSmartInjector()
