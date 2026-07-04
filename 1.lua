-- AXIOM ADOPT ME v12.0 - DUAL GUI + REPLICATEDSTORAGE EXPLORER
-- Smart pet injector + full server file browser

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

local Config = {
    Enabled = true,
    NewPets = {"Huge Cat", "Titanic Dragon", "Shadow Dragon", "Frost Fury", "Mega Neon Bat Dragon"},
    Amount = 10
}

local Stats = {Added = 0}

-- === SMART PET INJECTOR ===
local function FindSnowCatParent()
    local gui = LocalPlayer.PlayerGui
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj.Name:find("Snow Cat") then
            return obj.Parent
        end
    end
    return nil
end

local function InjectToParent(parent, petName)
    if not parent then return false end
    local newPet = Instance.new("Model")
    newPet.Name = petName .. " [AXIOM v12]"
    
    local rarity = Instance.new("StringValue", newPet)
    rarity.Name = "Rarity"
    rarity.Value = "Legendary"
    
    local neon = Instance.new("BoolValue", newPet)
    neon.Name = "Neon"
    neon.Value = true
    
    newPet.Parent = parent
    Stats.Added += 1
    return true
end

local function RunPetInjector()
    spawn(function()
        while Config.Enabled do
            local parent = FindSnowCatParent()
            if parent then
                for i = 1, Config.Amount do
                    local pet = Config.NewPets[math.random(#Config.NewPets)]
                    InjectToParent(parent, pet)
                end
                StarterGui:SetCore("SendNotification", {Title = "AXIOM", Text = "Pets added to Snow Cat parent!", Duration = 3})
            end
            wait(1.5)
        end
    end)
end

-- === REPLICATEDSTORAGE EXPLORER GUI ===
local function CreateExplorerGUI()
    local explorer = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    explorer.Name = "AxiomReplicatedExplorer"
    
    local main = Instance.new("Frame", explorer)
    main.Size = UDim2.new(0, 420, 0, 500)
    main.Position = UDim2.new(0.3, 0, 0.1, 0)
    main.BackgroundColor3 = Color3.fromRGB(15,15,35)
    
    local title = Instance.new("TextLabel", main)
    title.Text = "🧪 AXIOM REPLICATEDSTORAGE EXPLORER"
    title.Size = UDim2.new(1,0,0,50)
    title.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
    title.TextColor3 = Color3.new(1,1,1)
    title.TextScaled = true
    
    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -20, 1, -80)
    scroll.Position = UDim2.new(0,10,0,60)
    scroll.BackgroundTransparency = 0.5
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder = Enum.SortOrder.Name
    
    local function RefreshExplorer()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        for _, item in ipairs(ReplicatedStorage:GetChildren()) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,0,30)
            btn.Text = "📁 " .. item.Name .. " (" .. item.ClassName .. ")"
            btn.BackgroundColor3 = Color3.fromRGB(40,40,70)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Parent = scroll
            scroll.CanvasSize = UDim2.new(0,0,0,scroll.CanvasSize.Y.Offset + 35)
            
            btn.MouseButton1Click:Connect(function()
                print("Axiom Explorer - " .. item.Name .. " selected")
                -- Could expand further in future versions
            end)
        end
    end
    
    local refreshBtn = Instance.new("TextButton", main)
    refreshBtn.Text = "REFRESH SERVER FILES"
    refreshBtn.Size = UDim2.new(0.5,0,0,40)
    refreshBtn.Position = UDim2.new(0.25,0,1,-50)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
    refreshBtn.MouseButton1Click:Connect(RefreshExplorer)
    
    RefreshExplorer()
end

-- === PET INJECTOR GUI ===
local function CreateInjectorGUI()
    local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    sg.Name = "AxiomPetInjector"
    
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 380, 0, 320)
    f.Position = UDim2.new(0.02, 0, 0.1, 0)
    f.BackgroundColor3 = Color3.fromRGB(10,10,30)
    
    local title = Instance.new("TextLabel", f)
    title.Text = "🦍 AXIOM PET INJECTOR v12"
    title.Size = UDim2.new(1,0,0,55)
    title.BackgroundColor3 = Color3.fromRGB(200,0,110)
    title.TextColor3 = Color3.new(1,1,1)
    title.TextScaled = true
    
    local toggle = Instance.new("TextButton", f)
    toggle.Size = UDim2.new(0.9,0,0,50)
    toggle.Position = UDim2.new(0.05,0,0.3,0)
    toggle.Text = "STOP INJECTOR"
    toggle.BackgroundColor3 = Color3.fromRGB(180,20,20)
    toggle.TextColor3 = Color3.new(1,1,1)
    
    toggle.MouseButton1Click:Connect(function()
        Config.Enabled = not Config.Enabled
        toggle.Text = Config.Enabled and "STOP INJECTOR" or "START INJECTOR"
    end)
    
    local count = Instance.new("TextLabel", f)
    count.Size = UDim2.new(0.9,0,0,50)
    count.Position = UDim2.new(0.05,0,0.55,0)
    count.BackgroundTransparency = 1
    count.TextColor3 = Color3.fromRGB(0,255,160)
    count.TextScaled = true
    count.Text = "Pets Added: 0"
    
    RunService.Heartbeat:Connect(function()
        count.Text = "Pets Added: " .. Stats.Added
    end)
end

-- Launch Everything
print("Axiom v12.0 Dual GUI loaded boss man. ReplicatedStorage explorer + smart pet injector ready.")
CreateExplorerGUI()
CreateInjectorGUI()
RunPetInjector()
