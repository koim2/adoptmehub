-- Advanced Local Inventory Visual Simulation Engine
-- Optimized for localized UI rendering and mock data population without network state modification

local VisualSimulator = {
    _VERSION = "1.0.0",
    ActiveMockPets = {},
    Config = {
        DebugMode = true
    }
}

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Internal Representation of Modifier Definitions
local ModifierTemplates = {
    ["MFR"] = { IsMega = true, IsNeon = false, Flyable = true, Rideable = true },
    ["NFR"] = { IsMega = false, IsNeon = true, Flyable = true, Rideable = true },
    ["FR"]  = { IsMega = false, IsNeon = false, Flyable = true, Rideable = true },
    ["REG"] = { IsMega = false, IsNeon = false, Flyable = false, Rideable = false }
}

-- Simulates the local generation structure for a visual asset configuration
local function GenerateMockPetData(petName, modifierType)
    local modifiers = ModifierTemplates[string.upper(modifierType)] or ModifierTemplates["REG"]
    
    -- Generate a unique mock identifier for tracking the local instance
    local mockId = "mock_" .. string.lower(petName) .. "_" .. tostring(os.clock())
    
    local petStructure = {
        Id = mockId,
        AssetId = petName,
        Properties = {
            Name = petName,
            IsNeon = modifiers.IsNeon,
            IsMega = modifiers.IsMega,
            Flyable = modifiers.Flyable,
            Rideable = modifiers.Rideable,
            Age = "Full Grown"
        },
        IsVisualOnly = true
    }
    
    return petStructure
end

-- Simulates pushing the mock data into a local tracking system or UI boundary
function VisualSimulator:SimulateLocalAddition(petName, modifierType)
    if not petName or petName == "" then 
        if self.Config.DebugMode then
            warn("[Visual Simulator]: Invalid pet name provided.")
        end
        return nil 
    end
    
    local mockPet = GenerateMockPetData(petName, modifierType)
    table.insert(self.ActiveMockPets, mockPet)
    
    -- In a real localized interface, this structure would be passed to a client-side layout generator
    if self.Config.DebugMode then
        print(string.format("[Visual Simulator]: Successfully instantiated visual instance for '%s' with modifiers '%s'.", petName, modifierType))
        print(string.format("[Visual Simulator]: Assigned Local Tracking ID: %s", mockPet.Id))
    end
    
    return mockPet
end

-- Clears all local visual mock data from the execution cache
function VisualSimulator:ClearSimulatedInventory()
    table.clear(self.ActiveMockPets)
    if self.Config.DebugMode then
        print("[Visual Simulator]: Client-side visual cache cleared.")
    end
end

-- Execution Example:
-- VisualSimulator:SimulateLocalAddition("Shadow Dragon", "MFR")
-- VisualSimulator:SimulateLocalAddition("Frost Dragon", "FR")

return VisualSimulator
