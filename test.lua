-- adoptme_packet_interceptor_v2.1.lua
-- Strategy: Hook __namecall to intercept valid pet-spawn packets, cache them, and allow replay.
-- Version: 2.1 (Architecture switch to packet interception + UI version label + fixed parenting crash)
-- Usage: Run script. Interact with game (open pet menu, hatch egg). Click "REPLAY LAST PACKET" to fire captured args.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ===================== CONFIG =====================
local Config = {
    Debug = true,
    AutoReplay = false, -- Set true to auto-replay captured packets (use with caution)
    FilterKeywords = {"pet", "spawn", "hatch", "egg", "equip", "inventory"}
}

-- ===================== PACKET CACHE =====================
local PacketCache = {} -- Stores { RemoteInstance, Args... }

local function IsRelevantPacket(args)
    -- Check if any argument looks like a pet-related string/table
    for _, arg in ipairs(args) do
        if type(arg) == "string" then
            for _, keyword in ipairs(Config.FilterKeywords) do
                if arg:lower():find(keyword) then return true end
            end
        elseif type(arg) == "table" then
            -- Check table keys/values for keywords
            for k, v in pairs(arg) do
                if type(v) == "string" and v:lower():find("pet") then return true end
            end
        end
    end
    return false
end

-- ===================== UI SETUP =====================
local function CreateUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PacketInterceptor"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0, 20, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    -- TITLE WITH VERSION
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    title.Text = "Packet Interceptor v2.1"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame

    -- BUILD INFO FOOTER
    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, 0, 0, 15)
    footer.Position = UDim2.new(0, 0, 1, -15)
    footer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    footer.Text = "Build: 2026-07-10 | Arch: Intercept-Replay"
    footer.TextColor3 = Color3.fromRGB(100, 100, 100)
    footer.Font = Enum.Font.Gotham
    footer.TextSize = 9
    footer.Parent = frame

    local replayBtn = Instance.new("TextButton")
    replayBtn.Size = UDim2.new(1, -20, 0, 40)
    replayBtn.Position = UDim2.new(0, 10, 0, 50)
    replayBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
    replayBtn.Text = "REPLAY LAST PACKET"
    replayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    replayBtn.Font = Enum.Font.GothamBold
    replayBtn.TextSize = 16
    replayBtn.Parent = frame
    replayBtn.MouseButton1Click:Connect(function()
        ReplayLastPacket()
    end)

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Position = UDim2.new(0, 10, 0, 100)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Waiting for packets..."
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 14
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = frame

    return screenGui, statusLabel
end

-- ===================== REPLAY FUNCTION =====================
function ReplayLastPacket()
    if #PacketCache == 0 then
        warn("[!] No packets captured yet. Interact with the game to spawn a pet or open inventory.")
        return
    end

    local lastPacket = PacketCache[#PacketCache]
    local remote = lastPacket.Remote
    local args = lastPacket.Args

    if Config.Debug then
        print("[+] Replaying packet:", remote.Name)
        for i, arg in ipairs(args) do
            print("  Arg", i, ":", typeof(arg), tostring(arg))
        end
    end

    local success, err = pcall(function()
        remote:FireServer(unpack(args))
    end)

    if not success then
        warn("[!] Replay failed:", err)
    else
        print("[+] Replay sent successfully.")
    end
end

-- ===================== HOOKING =====================
local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(...)
    local args = {...}
    local self = args[1]
    local method = getnamecallmethod()

    if (method == "FireServer" or method == "InvokeServer") and typeof(self) == "Instance" and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
        -- Check if this packet is relevant
        if IsRelevantPacket(args) then
            -- Cache the packet
            table.insert(PacketCache, {
                Remote = self,
                Args = args
            })
            if Config.Debug then
                print("[INTERCEPT] Captured:", self.Name, "| Args:", #args)
            end
            -- Update UI status
            if _G.PacketInterceptorStatus then
                _G.PacketInterceptorStatus.Text = "Packet captured: " .. self.Name
            end
        end
    end

    return OriginalNamecall(...)
end)

-- ===================== INIT =====================
local function Init()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.CharacterAdded:Wait()
    end
    wait(1)
    local ui, statusLabel = CreateUI()
    _G.PacketInterceptorStatus = statusLabel
    print("[+] Packet Interceptor v2.1 initialized. Interact with pets/inventory to capture packets.")
end

Init()
