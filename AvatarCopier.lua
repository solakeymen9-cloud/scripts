local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local AvatarEvent = ReplicatedStorage.Events.CatalogGuiRemote
local SettingsEvent = ReplicatedStorage.Events.SettingsRemoteFunction
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local running = true
local copiedDisplayName = nil
local originalDisplayName = LocalPlayer.DisplayName
local accentColor = Color3.fromRGB(80, 120, 255)
local copyNameEnabled = true
local activeTab = "Players"

-- Character cache
local characterCache = {}

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer and p.Character then
        characterCache[p.Character] = p
        p.CharacterAdded:Connect(function(c) characterCache[c] = p end)
        p.CharacterRemoving:Connect(function(c) characterCache[c] = nil end)
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c) characterCache[c] = p end)
    p.CharacterRemoving:Connect(function(c) characterCache[c] = nil end)
    if p.Character then characterCache[p.Character] = p end
end)

Players.PlayerRemoving:Connect(function(p)
    if p.Character then characterCache[p.Character] = nil end
end)

local MY_AVATAR = {
    Properties = {
        WalkAnimation = 0, MoodAnimation = 10647852134, Face = 0,
        ProportionScale = 0, ClimbAnimation = 0, Shirt = 91210415719805,
        FaceAccessory = "",
        RightArmColor = {r=180.00000447034836, IsRGBTable=true, g=58.000000342726707, b=52.000000700354576},
        HairAccessory = "114322982861944", RightArm = 86500036, Head = 10638267973,
        FallAnimation = 0,
        TorsoColor = {r=180.00000447034836, IsRGBTable=true, g=58.000000342726707, b=52.000000700354576},
        DepthScale = 1, LeftArm = 86500054, HeightScale = 1, LeftLeg = 86500064,
        RightLegColor = {r=180.00000447034836, IsRGBTable=true, g=58.000000342726707, b=52.000000700354576},
        LeftLegColor = {r=180.00000447034836, IsRGBTable=true, g=58.000000342726707, b=52.000000700354576},
        WidthScale = 1, BodyTypeScale = 0, RunAnimation = 0,
        LeftArmColor = {r=180.00000447034836, IsRGBTable=true, g=58.000000342726707, b=52.000000700354576},
        Pants = 14285822913, MakeupItems = {}, StaticFacialAnimation = false,
        RightLeg = 86500078, GraphicTShirt = 0, AccessoryRefinements = {},
        JumpAnimation = 0, FrontAccessory = "", Torso = 86500008, SwimAnimation = 0,
        BackAccessory = "",
        HeadColor = {r=180.00000447034836, IsRGBTable=true, g=58.000000342726707, b=52.000000700354576},
        NeckAccessory = "", IdleAnimation = 0, HatAccessory = "", HeadScale = 1,
        ShouldersAccessory = "", LayeredAccessories = {}, WaistAccessory = ""
    },
    Action = "CreateAndWearHumanoidDescription",
    RigType = Enum.HumanoidRigType.R15
}

local function toRGBTable(c)
    if typeof(c) ~= "Color3" then return {r=255, g=255, b=255, IsRGBTable=true} end
    return {r=c.R*255, g=c.G*255, b=c.B*255, IsRGBTable=true}
end

local function getRigType(character)
    if character:FindFirstChild("UpperTorso") then
        return Enum.HumanoidRigType.R15
    end
    return Enum.HumanoidRigType.R6
end

local function getLayeredAccessories(desc)
    local result = {}
    pcall(function()
        local accessories = desc:GetAccessories(true)
        if type(accessories) ~= "table" then return end
        for _, x in ipairs(accessories) do
            if type(x) == "table" then
                if x.AssetId then
                    result[#result+1] = {
                        AssetId = x.AssetId,
                        AccessoryType = tostring(x.AccessoryType or ""),
                        Order = x.Order,
                        Puffiness = x.Puffiness,
                    }
                end
            end
        end
    end)
    return result
end

local function getDescriptionData(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    local desc = humanoid:GetAppliedDescription()
    if not desc then return nil end
    return {
        Properties = {
            HatAccessory = desc.HatAccessory or "",
            MoodAnimation = desc.MoodAnimation or 0,
            Face = desc.Face or 0,
            ProportionScale = desc.ProportionScale or 0,
            ClimbAnimation = desc.ClimbAnimation or 0,
            Shirt = desc.Shirt or 0,
            FaceAccessory = desc.FaceAccessory or "",
            RightArmColor = toRGBTable(desc.RightArmColor),
            HairAccessory = desc.HairAccessory or "",
            RightArm = desc.RightArm or 0,
            Head = desc.Head or 0,
            FallAnimation = desc.FallAnimation or 0,
            TorsoColor = toRGBTable(desc.TorsoColor),
            DepthScale = desc.DepthScale or 1,
            LeftArm = desc.LeftArm or 0,
            HeightScale = desc.HeightScale or 1,
            LeftLeg = desc.LeftLeg or 0,
            RightLegColor = toRGBTable(desc.RightLegColor),
            LeftLegColor = toRGBTable(desc.LeftLegColor),
            WidthScale = desc.WidthScale or 1,
            BodyTypeScale = desc.BodyTypeScale or 0,
            RunAnimation = desc.RunAnimation or 0,
            LeftArmColor = toRGBTable(desc.LeftArmColor),
            Pants = desc.Pants or 0,
            MakeupItems = {},
            StaticFacialAnimation = false,
            RightLeg = desc.RightLeg or 0,
            GraphicTShirt = desc.GraphicTShirt or 0,
            AccessoryRefinements = {},
            JumpAnimation = desc.JumpAnimation or 0,
            WalkAnimation = desc.WalkAnimation or 0,
            Torso = desc.Torso or 0,
            SwimAnimation = desc.SwimAnimation or 0,
            BackAccessory = desc.BackAccessory or "",
            NeckAccessory = desc.NeckAccessory or "",
            HeadColor = toRGBTable(desc.HeadColor),
            IdleAnimation = desc.IdleAnimation or 0,
            FrontAccessory = desc.FrontAccessory or "",
            HeadScale = desc.HeadScale or 1,
            ShouldersAccessory = desc.ShouldersAccessory or "",
            LayeredAccessories = getLayeredAccessories(desc),
            WaistAccessory = desc.WaistAccessory or ""
        },
        Action = "CreateAndWearHumanoidDescription",
        RigType = getRigType(character)
    }
end

local function setDisplayName(name)
    SettingsEvent:InvokeServer({Action = "SetDisplayName", DisplayName = name})
end

local function copyFromPlayer(player)
    local char = player.Character
    if not char then return end
    local data = getDescriptionData(char)
    if not data then
        warn("Failed to get description for " .. player.Name)
        return
    end
    AvatarEvent:InvokeServer(data)
    if copyNameEnabled then
        copiedDisplayName = player.DisplayName
        setDisplayName(copiedDisplayName)
    end
    print("Copied: " .. player.Name .. " (" .. player.DisplayName .. ") | Layered: " .. #data.Properties.LayeredAccessories)
end

local function wearMyAvatar()
    AvatarEvent:InvokeServer(MY_AVATAR)
    setDisplayName(originalDisplayName)
    copiedDisplayName = nil
    print("Switched back to own avatar.")
end

-- Display name loop
task.spawn(function()
    while running do
        task.wait(2)
        if copyNameEnabled then
            if copiedDisplayName then
                if LocalPlayer.DisplayName ~= copiedDisplayName then
                    setDisplayName(copiedDisplayName)
                end
            end
        end
    end
end)

-- GUI helpers
local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
end

local function makeStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(50, 50, 50)
    s.Thickness = thickness or 1
    s.Parent = parent
end

-- Screen GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AvatarCopierGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 460, 0, 340)
mainFrame.Position = UDim2.new(0.5, -230, 0.5, -170)
mainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui
makeCorner(mainFrame, 10)
makeStroke(mainFrame, Color3.fromRGB(40, 40, 40), 1)

-- Top bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 38)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
makeCorner(topBar, 10)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 140, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "Avatar Copier"
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

local serverLabel = Instance.new("TextLabel")
serverLabel.Size = UDim2.new(0, 220, 1, 0)
serverLabel.Position = UDim2.new(0, 150, 0, 0)
serverLabel.BackgroundTransparency = 1
serverLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
serverLabel.Text = ""
serverLabel.TextSize = 11
serverLabel.Font = Enum.Font.Gotham
serverLabel.TextXAlignment = Enum.TextXAlignment.Left
serverLabel.Parent = topBar

local function updateServerLabel()
    serverLabel.Text = "ID: " .. tostring(game.JobId):sub(1,8) .. "  |  " .. #Players:GetPlayers() .. " players"
end
updateServerLabel()
Players.PlayerAdded:Connect(updateServerLabel)
Players.PlayerRemoving:Connect(updateServerLabel)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 22)
closeBtn.Position = UDim2.new(1, -34, 0.5, -11)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = topBar
makeCorner(closeBtn, 5)
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

local minimized = false
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 22)
minBtn.Position = UDim2.new(1, -66, 0.5, -11)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 15
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = topBar
makeCorner(minBtn, 5)
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        mainFrame.Size = UDim2.new(0, 460, 0, 38)
    else
        mainFrame.Size = UDim2.new(0, 460, 0, 340)
    end
end)

-- Tab bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -16, 0, 28)
tabBar.Position = UDim2.new(0, 8, 0, 44)
tabBar.BackgroundTransparency = 1
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame

local tabBarLayout = Instance.new("UIListLayout")
tabBarLayout.FillDirection = Enum.FillDirection.Horizontal
tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabBarLayout.Padding = UDim.new(0, 4)
tabBarLayout.Parent = tabBar

-- Content area
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -16, 1, -84)
contentArea.Position = UDim2.new(0, 8, 0, 78)
contentArea.BackgroundTransparency = 1
contentArea.BorderSizePixel = 0
contentArea.Parent = mainFrame

local tabs = {}
local tabBtns = {}

local function switchTab(name)
    for n, content in pairs(tabs) do
        content.Visible = false
        tabBtns[n].BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        tabBtns[n].TextColor3 = Color3.fromRGB(140, 140, 140)
    end
    tabs[name].Visible = true
    tabBtns[name].BackgroundColor3 = accentColor
    tabBtns[name].TextColor3 = Color3.fromRGB(255, 255, 255)
    activeTab = name
end

local function createTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 86, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    btn.TextColor3 = Color3.fromRGB(140, 140, 140)
    btn.Text = name
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.Parent = tabBar
    makeCorner(btn, 6)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = accentColor
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = false
    scroll.Parent = contentArea

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.Parent = scroll

    tabs[name] = scroll
    tabBtns[name] = btn

    btn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)

    return scroll
end

local playersTab = createTab("Players", 1)
local settingsTab = createTab("Settings", 2)

switchTab("Players")

-- Players tab
local playerButtons = {}

local function removePlayerButton(player)
    if playerButtons[player] then
        playerButtons[player]:Destroy()
        playerButtons[player] = nil
    end
end

local function addPlayerButton(player)
    if player == LocalPlayer then return end
    removePlayerButton(player)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = playersTab
    makeCorner(btn, 6)
    makeStroke(btn, Color3.fromRGB(38, 38, 38), 1)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -12, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 10, 0, 4)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    nameLabel.Text = player.DisplayName
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = btn

    local userLabel = Instance.new("TextLabel")
    userLabel.Size = UDim2.new(1, -12, 0.5, 0)
    userLabel.Position = UDim2.new(0, 10, 0.5, -2)
    userLabel.BackgroundTransparency = 1
    userLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    userLabel.Text = "@" .. player.Name
    userLabel.TextSize = 11
    userLabel.Font = Enum.Font.Gotham
    userLabel.TextXAlignment = Enum.TextXAlignment.Left
    userLabel.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    end)

    btn.MouseButton1Click:Connect(function()
        if not running then return end
        copyFromPlayer(player)
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 60)
        task.wait(0.8)
        if playerButtons[player] == btn then
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        end
    end)

    player:GetPropertyChangedSignal("DisplayName"):Connect(function()
        if playerButtons[player] == btn then
            nameLabel.Text = player.DisplayName
        end
    end)

    playerButtons[player] = btn
end

for _, p in ipairs(Players:GetPlayers()) do
    addPlayerButton(p)
end
Players.PlayerAdded:Connect(addPlayerButton)
Players.PlayerRemoving:Connect(removePlayerButton)

-- Settings helpers
local allAccentElements = {}

local function makeSectionLabel(parent, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = accentColor
    lbl.Text = text
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.Parent = parent
    return lbl
end

local function makeToggle(parent, labelText, default, order, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = parent
    makeCorner(row, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    lbl.Text = labelText
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local state = default

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 38, 0, 18)
    toggleBg.Position = UDim2.new(1, -48, 0.5, -9)
    toggleBg.BackgroundColor3 = state and accentColor or Color3.fromRGB(45, 45, 45)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = row
    makeCorner(toggleBg, 9)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = toggleBg
    makeCorner(knob, 6)

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Parent = toggleBg

    hitbox.MouseButton1Click:Connect(function()
        state = not state
        toggleBg.BackgroundColor3 = state and accentColor or Color3.fromRGB(45, 45, 45)
        knob.Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        if callback then callback(state) end
    end)

    table.insert(allAccentElements, {bg = toggleBg, getState = function() return state end})
    return row
end

-- Settings content
makeSectionLabel(settingsTab, "GENERAL", 1)

makeToggle(settingsTab, "Copy Display Name", true, 2, function(state)
    copyNameEnabled = state
    if not state then
        copiedDisplayName = nil
    end
end)

makeSectionLabel(settingsTab, "ACCENT COLOR", 3)

local colorRow = Instance.new("Frame")
colorRow.Size = UDim2.new(1, 0, 0, 36)
colorRow.BackgroundTransparency = 1
colorRow.BorderSizePixel = 0
colorRow.LayoutOrder = 4
colorRow.Parent = settingsTab

local colorLayout = Instance.new("UIListLayout")
colorLayout.FillDirection = Enum.FillDirection.Horizontal
colorLayout.SortOrder = Enum.SortOrder.LayoutOrder
colorLayout.Padding = UDim.new(0, 6)
colorLayout.Parent = colorRow

local colorChoices = {
    Color3.fromRGB(80, 120, 255),
    Color3.fromRGB(140, 80, 255),
    Color3.fromRGB(50, 200, 100),
    Color3.fromRGB(220, 60, 60),
    Color3.fromRGB(255, 140, 40),
    Color3.fromRGB(255, 80, 160),
    Color3.fromRGB(200, 200, 200),
}

local function applyAccent(color)
    accentColor = color
    tabBtns[activeTab].BackgroundColor3 = accentColor
    for _, tab in pairs(tabs) do
        tab.ScrollBarImageColor3 = accentColor
    end
    for _, child in ipairs(settingsTab:GetChildren()) do
        if child:IsA("TextLabel") then
            child.TextColor3 = accentColor
        end
    end
    for _, el in ipairs(allAccentElements) do
        if el.getState() then
            el.bg.BackgroundColor3 = accentColor
        end
    end
end

for i, color in ipairs(colorChoices) do
    local swatch = Instance.new("TextButton")
    swatch.Size = UDim2.new(0, 32, 0, 32)
    swatch.BackgroundColor3 = color
    swatch.Text = ""
    swatch.BorderSizePixel = 0
    swatch.LayoutOrder = i
    swatch.Parent = colorRow
    makeCorner(swatch, 6)
    makeStroke(swatch, Color3.fromRGB(55, 55, 55), 1)
    local c = color
    swatch.MouseButton1Click:Connect(function()
        applyAccent(c)
    end)
end

makeSectionLabel(settingsTab, "KEYBINDS", 5)

local keybindBox = Instance.new("Frame")
keybindBox.Size = UDim2.new(1, 0, 0, 58)
keybindBox.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
keybindBox.BorderSizePixel = 0
keybindBox.LayoutOrder = 6
keybindBox.Parent = settingsTab
makeCorner(keybindBox, 6)

local keybindLabel = Instance.new("TextLabel")
keybindLabel.Size = UDim2.new(1, -16, 1, 0)
keybindLabel.Position = UDim2.new(0, 10, 0, 0)
keybindLabel.BackgroundTransparency = 1
keybindLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
keybindLabel.Text = "L  —  Toggle GUI\nCTRL + R  —  Wear own avatar\nCTRL + P  —  Stop script"
keybindLabel.TextSize = 11
keybindLabel.Font = Enum.Font.Gotham
keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
keybindLabel.TextYAlignment = Enum.TextYAlignment.Center
keybindLabel.Parent = keybindBox

-- Click on character
local clickConn = Mouse.Button1Down:Connect(function()
    if not running then return end
    local target = Mouse.Target
    if not target then return end
    local model = target
    while model do
        if characterCache[model] then break end
        model = model.Parent
    end
    local player = model and characterCache[model]
    if not player then return end
    copyFromPlayer(player)
end)

-- Keybinds
local inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.L then
        mainFrame.Visible = not mainFrame.Visible
    end
    if not running then return end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if input.KeyCode == Enum.KeyCode.P then
            running = false
            clickConn:Disconnect()
            inputConn:Disconnect()
            screenGui:Destroy()
            print("Avatar copier stopped.")
        elseif input.KeyCode == Enum.KeyCode.R then
            wearMyAvatar()
        end
    end
end)

print("Avatar copier running. L = toggle GUI | CTRL+P = stop | CTRL+R = own avatar.")
