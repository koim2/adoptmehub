--[[
    NURSERY INJECTION PET SPAWNER
    Reliable method: teleport to Pet Shop, fire prompt, hijack GUI, confirm.
    Works on standard executors with teleport, firetouchinterest, fireproximityprompt.
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- GUI (same as before, but only one method)
local gui = Instance.new("ScreenGui")
gui.Name = "AxiomSpawner"
gui.ResetOnSpawn = false
if gethui then gui.Parent = gethui() else gui.Parent = LocalPlayer.PlayerGui end

-- Build GUI quickly with basic layout
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 180)
main.Position = UDim2.new(0.5, -150, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(30,30,30)
main.BorderSizePixel = 0
main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Text = "Pet Spawner"
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(45,45,45)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local nameBox = Instance.new("TextBox", main)
nameBox.Size = UDim2.new(1,-20,0,30)
nameBox.Position = UDim2.new(0,10,0,40)
nameBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
nameBox.TextColor3 = Color3.new(1,1,1)
nameBox.PlaceholderText = "Pet Name"
nameBox.Text = ""

local variantLabel = Instance.new("TextLabel", main)
variantLabel.Text = "Variant:"
variantLabel.Size = UDim2.new(0,80,0,20)
variantLabel.Position = UDim2.new(0,10,0,80)
variantLabel.BackgroundTransparency = 1
variantLabel.TextColor3 = Color3.new(1,1,1)

local variantBox = Instance.new("TextBox", main)
variantBox.Size = UDim2.new(1,-100,0,25)
variantBox.Position = UDim2.new(0,90,0,78)
variantBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
variantBox.TextColor3 = Color3.new(1,1,1)
variantBox.Text = "Normal"   -- Normal, FR, NFR, MFR

local spawnBtn = Instance.new("TextButton", main)
spawnBtn.Size = UDim2.new(1,-20,0,35)
spawnBtn.Position = UDim2.new(0,10,0,130)
spawnBtn.Text = "SPAWN PET"
spawnBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
spawnBtn.TextColor3 = Color3.new(1,1,1)
spawnBtn.Font = Enum.Font.GothamBold
spawnBtn.TextSize = 18

local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1,-20,0,20)
status.Position = UDim2.new(0,10,0,110)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(1,1,0.5)
status.Text = ""
status.Font = Enum.Font.Gotham
status.TextSize = 12

-- SPAWN LOGIC
spawnBtn.MouseButton1Click:Connect(function()
    local petName = nameBox.Text:match("^%s*(.-)%s*$")
    if petName == "" then status.Text = "Enter a pet name"; return end
    local variant = variantBox.Text:match("^%s*(.-)%s*$") or "Normal"
    status.Text = "Spawning "..petName.." ("..variant..")..."

    -- Find nursery part
    local nursery = workspace:FindFirstChild("Pet Shop", true) or workspace:FindFirstChild("Nursery", true)
    if not nursery then
        -- fallback to any part named "TouchInterest" with a prompt parent
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Parent and v.Parent:FindFirstChildWhichIsA("ProximityPrompt") then
                nursery = v
                break
            end
        end
    end
    if not nursery then
        status.Text = "Nursery/Pet Shop not found"
        return
    end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        status.Text = "Character missing"
        return
    end
    local root = char.HumanoidRootPart
    local oldPos = root.CFrame

    -- Teleport to nursery part
    root.CFrame = nursery.CFrame * CFrame.new(0, 3, 0)
    wait(0.2)

    -- Fire touch to trigger prompt
    firetouchinterest(root, nursery, 0)
    wait(0.1)
    firetouchinterest(root, nursery, 1)
    wait(0.3)

    -- Now look for the purchase GUI
    local purchaseGui = LocalPlayer.PlayerGui:FindFirstChild("PurchasePet", true) or 
                        LocalPlayer.PlayerGui:FindFirstChild("PetAdoption", true) or
                        LocalPlayer.PlayerGui:FindFirstChild("PetShopGUI", true)
    if not purchaseGui then
        -- attempt to fire proximity prompt again
        local prompt = nursery.Parent:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
            wait(0.5)
        end
        -- rescan
        purchaseGui = LocalPlayer.PlayerGui:FindFirstChild("PurchasePet", true) or 
                      LocalPlayer.PlayerGui:FindFirstChild("PetAdoption", true)
    end

    if purchaseGui then
        -- Fill pet name field
        local nameField = purchaseGui:FindFirstChild("PetName", true) or purchaseGui:FindFirstChild("NameBox", true)
        if nameField and nameField:IsA("TextBox") then
            nameField.Text = petName
            wait(0.1)
        end
        -- Select variant if possible (radio buttons)
        local variantBtn = purchaseGui:FindFirstChild(variant, true) or purchaseGui:FindFirstChild("MFR", true) 
        if variantBtn and variantBtn:IsA("TextButton") then
            firesignal(variantBtn.MouseButton1Click)
            wait(0.1)
        end
        -- Press confirm/buy
        local confirm = purchaseGui:FindFirstChild("Buy", true) or purchaseGui:FindFirstChild("Confirm", true)
        if confirm and confirm:IsA("TextButton") then
            firesignal(confirm.MouseButton1Click)
            wait(0.3)
            status.Text = "Pet spawned! Check inventory."
        else
            status.Text = "Confirm button missing"
        end
    else
        status.Text = "Purchase GUI did not appear"
    end

    -- Return to original position
    wait(0.5)
    root.CFrame = oldPos
end)

print("Nursery Pet Spawner ready.")
