local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local ballServiceRemote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BallService"):WaitForChild("RE"):WaitForChild("Shoot")
local slideRemote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BallService"):WaitForChild("RE"):WaitForChild("Slide")
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local FootballESPEnabled = false
local Lines = {}
local Quads = {}
local homeGoalPosition = Vector3.new(325, 20, -49)
local awayGoalPosition = Vector3.new(-247, 18, -50)
local autofarmEnabled = false
local autoGoalEnabled = false
local autoStealEnabled = false
local autoTPBallEnabled = false
local autoJoinRandomTeamEnabled = false
local autoJoinHomeEnabled = false
local autoJoinAwayEnabled = false
local autoGoalKeeperEnabled = false
local autoBringEnabled = false
local aimlockEnabled = false
local predictionDistance = 1
local MAX_DISTANCE = 3
local tracer = nil
local distanceText = nil
local highlight = nil
local roles = {"CF", "CM", "LW", "RW", "GK"}
local teams = {"Home", "Away"}
local selectedTeam = "Home"
local selectedRole = "CF"
local PlayerESPEnabled = false
local TeamESPEnabled = false
local antiRagdoll = false
local cframespeed = 1
local playerEspObjects = {}
local teamEspObjects = {}
local enemyEspObjects = {}

local currentTheme = "cherry"
local roundingEnabled = false
local smoothDraggingEnabled = true

local function ClearESP()
    for _, line in pairs(Lines) do
        if line then line:Remove() end
    end
    Lines = {}

    for _, quad in pairs(Quads) do
        if quad then quad:Remove() end
    end
    Quads = {}
end

local function DrawLine(From, To)
    local FromScreen, FromVisible = Camera:WorldToViewportPoint(From)
    local ToScreen, ToVisible = Camera:WorldToViewportPoint(To)

    if not (FromVisible or ToVisible) then return end

    local FromPos = Vector2.new(FromScreen.X, FromScreen.Y)
    local ToPos = Vector2.new(ToScreen.X, ToScreen.Y)

    local Line = Drawing.new("Line")
    Line.Thickness = 1
    Line.From = FromPos
    Line.To = ToPos
    Line.Color = Color3.fromRGB(255, 255, 255)
    Line.Transparency = 1
    Line.Visible = true

    table.insert(Lines, Line)
end

local function DrawQuad(PosA, PosB, PosC, PosD)
    local PosAScreen, PosAVisible = Camera:WorldToViewportPoint(PosA)
    local PosBScreen, PosBVisible = Camera:WorldToViewportPoint(PosB)
    local PosCScreen, PosCVisible = Camera:WorldToViewportPoint(PosC)
    local PosDScreen, PosDVisible = Camera:WorldToViewportPoint(PosD)

    if not (PosAVisible or PosBVisible or PosCVisible or PosDVisible) then return end

    local Quad = Drawing.new("Quad")
    Quad.PointA = Vector2.new(PosAScreen.X, PosAScreen.Y)
    Quad.PointB = Vector2.new(PosBScreen.X, PosBScreen.Y)
    Quad.PointC = Vector2.new(PosCScreen.X, PosCScreen.Y)
    Quad.PointD = Vector2.new(PosDScreen.X, PosDScreen.Y)
    Quad.Color = Color3.fromRGB(255, 255, 255)
    Quad.Thickness = 0.5
    Quad.Filled = true
    Quad.Transparency = 0.25
    Quad.Visible = true

    table.insert(Quads, Quad)
end

local function GetCorners(Part)
    local CF, Size = Part.CFrame, Part.Size / 2
    local Corners = {}

    for X = -1, 1, 2 do
        for Y = -1, 1, 2 do
            for Z = -1, 1, 2 do
                table.insert(Corners, (CF * CFrame.new(Size * Vector3.new(X, Y, Z))).Position)
            end
        end
    end

    return Corners
end

local function DrawFootballESP(Football)
    local Corners = GetCorners(Football)

    DrawLine(Corners[1], Corners[2])
    DrawLine(Corners[2], Corners[4])
    DrawLine(Corners[4], Corners[3])
    DrawLine(Corners[3], Corners[1])

    DrawLine(Corners[5], Corners[6])
    DrawLine(Corners[6], Corners[8])
    DrawLine(Corners[8], Corners[7])
    DrawLine(Corners[7], Corners[5])

    DrawLine(Corners[1], Corners[5])
    DrawLine(Corners[2], Corners[6])
    DrawLine(Corners[3], Corners[7])
    DrawLine(Corners[4], Corners[8])

    DrawQuad(Corners[1], Corners[2], Corners[6], Corners[5])
    DrawQuad(Corners[3], Corners[4], Corners[8], Corners[7])
    DrawQuad(Corners[1], Corners[3], Corners[7], Corners[5])
    DrawQuad(Corners[2], Corners[4], Corners[8], Corners[6])
end

local function FootballESP()
    ClearESP()

    local Football = Workspace:FindFirstChild("Football")
    if Football and Football:IsA("BasePart") and FootballESPEnabled then
        DrawFootballESP(Football)
    end
end

local function ClearTracer()
    if tracer then
        tracer:Remove()
        tracer = nil
    end
end

local function ClearDistance()
    if distanceText then
        distanceText:Remove()
        distanceText = nil
    end
end

local function ClearFootballChams()
    if highlight then
        highlight:Destroy()
        highlight = nil
    end
end

local function ClearTeamESP()
    for _, objects in pairs(teamEspObjects or {}) do
        if objects.esp then objects.esp:Remove() end
        if objects.highlight then objects.highlight:Destroy() end
        if objects.nameTag then objects.nameTag:Remove() end
    end
    teamEspObjects = {}
end

local function ClearEnemyESP()
    for _, objects in pairs(enemyEspObjects or {}) do
        if objects.esp then objects.esp:Remove() end
        if objects.highlight then objects.highlight:Destroy() end
        if objects.nameTag then objects.nameTag:Remove() end
    end
    enemyEspObjects = {}
end

local function ClearPlayerESP()
    for _, objects in pairs(playerEspObjects or {}) do
        if objects.esp then objects.esp:Remove() end
        if objects.highlight then objects.highlight:Destroy() end
        if objects.nameTag then objects.nameTag:Remove() end
    end
    playerEspObjects = {}
end

-- Функції для гри
local function hasBall()
    return character:FindFirstChild("Football") ~= nil
end

local function checkTeam()
    local team = player.Team
    return team and team.Name ~= "Visitor"
end

local function autoGoal()
    while autoGoalEnabled do
        if not checkTeam() or not hasBall() then
            task.wait()
            continue
        end

        local team = player.Team
        local goalPosition = team.Name == "Home" and awayGoalPosition or homeGoalPosition
        
        rootPart:PivotTo(CFrame.new(goalPosition))
        task.wait(0.1)
        
        ballServiceRemote:FireServer(1, nil, nil, Vector3.new(-0.8986, -0.3108, 0.3097))
        task.wait()
    end
end

local function autoSteal()
    while autoStealEnabled do
        local targetPlayer, closestDistance = nil, math.huge
        
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer == player then continue end
            
            local otherCharacter = otherPlayer.Character
            if not otherCharacter or not otherCharacter:FindFirstChild("Football") then continue end
            
            local distance = (rootPart.Position - otherCharacter.HumanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                targetPlayer = otherPlayer
            end
        end
        
        if targetPlayer then
            rootPart:PivotTo(targetPlayer.Character.HumanoidRootPart.CFrame)
            slideRemote:FireServer(targetPlayer)
        end
        
        task.wait()
    end
end

local function autoTPBall()
    local ball
    while autoTPBallEnabled do
        ball = workspace:FindFirstChild("Football")
        if ball then
            rootPart:PivotTo(ball:GetPivot())
        end
        task.wait()
    end
end

local function isBallMovingTowardsGK(ball)
    local ballVelocity = ball.AssemblyLinearVelocity
    local ballToGK = (rootPart.Position - ball.Position).Unit
    local dotProduct = ballVelocity.Unit:Dot(ballToGK)
    
    return dotProduct > 0
end

local function autoGoalKeeper()
    while autoGoalKeeperEnabled do
        local ball = workspace:FindFirstChild("Football")
        if ball and ball:IsA("BasePart") then
            if isBallMovingTowardsGK(ball) then
                local distance = (ball.Position - rootPart.Position).Magnitude
                aimAtBall(ball)
                if distance <= MAX_DISTANCE then
                    UserInputService:SendKeyEvent(true, Enum.KeyCode.Q, false, nil)
                    task.wait(0.1)
                    UserInputService:SendKeyEvent(false, Enum.KeyCode.Q, false, nil)
                end
            end
        end
        task.wait()
    end
end

local function autoBring()
    while autoBringEnabled do
        local ball = workspace:FindFirstChild("Football")
        if ball then
            local args = {[1] = ball}
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BallService"):WaitForChild("RE"):WaitForChild("Grab"):FireServer(unpack(args))
        end
        task.wait(0.1)
    end
end

local function fly()
    local flying = false
    local flySpeed = 100
    local maxFlySpeed = 1000
    local speedIncrement = 0.4
    local originalGravity = workspace.Gravity

    player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        humanoid = character:WaitForChild("Humanoid")
        rootPart = character:WaitForChild("HumanoidRootPart")
    end)

    local function randomizeValue(value, range)
        return value + (value * (math.random(-range, range) / 100))
    end

    if not flying then
        flying = true
        workspace.Gravity = 0
        task.spawn(function()
            while flying do
                local MoveDirection = Vector3.new()
                local cameraCFrame = workspace.CurrentCamera.CFrame

                MoveDirection = MoveDirection + (UserInputService:IsKeyDown(Enum.KeyCode.W) and cameraCFrame.LookVector or Vector3.new())
                MoveDirection = MoveDirection - (UserInputService:IsKeyDown(Enum.KeyCode.S) and cameraCFrame.LookVector or Vector3.new())
                MoveDirection = MoveDirection - (UserInputService:IsKeyDown(Enum.KeyCode.A) and cameraCFrame.RightVector or Vector3.new())
                MoveDirection = MoveDirection + (UserInputService:IsKeyDown(Enum.KeyCode.D) and cameraCFrame.RightVector or Vector3.new())
                MoveDirection = MoveDirection + (UserInputService:IsKeyDown(Enum.KeyCode.Space) and Vector3.new(0, 1, 0) or Vector3.new())
                MoveDirection = MoveDirection - (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and Vector3.new(0, 1, 0) or Vector3.new())

                if MoveDirection.Magnitude > 0 then
                    flySpeed = math.min(flySpeed + speedIncrement, maxFlySpeed)
                    MoveDirection = MoveDirection.Unit * math.min(randomizeValue(flySpeed, 10), maxFlySpeed)
                    rootPart.Velocity = MoveDirection * 0.5
                else
                    rootPart.Velocity = Vector3.new(0, 0, 0)
                end

                RunService.RenderStepped:Wait()
            end
        end)
    else
        flying = false
        flySpeed = 100
        rootPart.Velocity = Vector3.new(0, 0, 0)
        workspace.Gravity = originalGravity
    end
end

local function aimlock()
    while aimlockEnabled do
        local ball = workspace:FindFirstChild("Football")
        if ball then
            local camera = workspace.CurrentCamera
            if player.Character then
                camera.CFrame = CFrame.new(camera.CFrame.Position, ball.Position)
            end
        end
        task.wait()
    end
end

local function aimAtBall(ball)
    if not ball or not rootPart then return end

    if ball.Velocity.Magnitude == 0 then
        return
    end

    local ballPosition = ball.Position + (ball.Velocity * predictionDistance)
    local direction = (ballPosition - rootPart.Position).Unit
    local newCFrame = CFrame.new(rootPart.Position, rootPart.Position + direction * Vector3.new(1, 0, 1))
    local _, y, _ = newCFrame:ToOrientation()
    rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, y, 0)
end

-- Функції для стилів і Flow
local selectedStyle = player.PlayerStats and player.PlayerStats.Style and player.PlayerStats.Style.Value or "Default"
local selectedFlow = player.PlayerStats and player.PlayerStats.Flow and player.PlayerStats.Flow.Value or "Default"

local function applyStyle(style)
    if player:FindFirstChild("PlayerStats") and player.PlayerStats:FindFirstChild("Style") then
        player.PlayerStats.Style.Value = style
    end
end

local function applyFlow(flow)
    if player:FindFirstChild("PlayerStats") and player.PlayerStats:FindFirstChild("Flow") then
        player.PlayerStats.Flow.Value = flow
    end
end

RunService.RenderStepped:Connect(FootballESP)

local playerEspObjects = {}
local teamEspObjects = {}
local enemyEspObjects = {}
local tracer = nil
local distanceText = nil
local highlight = nil

local ui = loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/dollarware/main/library.lua'))
if not ui then
    warn("Failed to load Dollarware UI Library")
    return
end

-- Ініціалізуємо UI з налаштуваннями
local UI = ui({
    rounding = roundingEnabled,
    theme = currentTheme,
    smoothDragging = smoothDraggingEnabled
})

local windowSettings = {
    text = "MoonShine (Blue Lock Rivals)",
    resize = true,
    size = Vector2.new(600, 500),
    position = UDim2.fromScale(0.5, 0.5),
    icon = "rbxassetid://9651932657"
}

local window = UI.newWindow(windowSettings)

-- Вкладка 1: Main (Autofarm Features)
local mainMenu = window:newMenu("Main", "rbxassetid://9651932657")
local mainSection = mainMenu:newSection("Autofarm Features")

mainSection:addToggle({
    text = "Autofarm All",
    callback = function(Value)
        autofarmEnabled = Value
        autoGoalEnabled = Value
        autoStealEnabled = Value
        autoTPBallEnabled = Value
        autoBringEnabled = Value
        autoGoalKeeperEnabled = Value
        
        if Value then
            task.spawn(autoGoal)
            task.spawn(autoSteal)
            task.spawn(autoTPBall)
            task.spawn(autoBring)
            task.spawn(autoGoalKeeper)
        end
    end
})

mainSection:addToggle({
    text = "Auto Steal",
    callback = function(Value)
        autoStealEnabled = Value
        if Value then
            task.spawn(autoSteal)
        end
    end
})

mainSection:addToggle({
    text = "Auto Goal",
    callback = function(Value)
        autoGoalEnabled = Value
        if Value then
            task.spawn(autoGoal)
        end
    end
})

mainSection:addToggle({
    text = "Auto TP Ball",
    callback = function(Value)
        autoTPBallEnabled = Value
        if Value then
            task.spawn(autoTPBall)
        end
    end
})

mainSection:addToggle({
    text = "Auto Goal Keeper",
    callback = function(Value)
        autoGoalKeeperEnabled = Value
        if Value then
            task.spawn(autoGoalKeeper)
        end
    end
})

mainSection:addSlider({
    text = "Goal Keeper Prediction Distance",
    min = 0,
    max = 10,
    default = 1,
    callback = function(Value)
        predictionDistance = Value
    end
})

mainSection:addButton({
    text = "Bring Football",
    callback = function()
        local ball = workspace:FindFirstChild("Football")
        if ball then
            local args = {[1] = ball}
            game:GetService("ReplicatedStorage").Packages.Knit.Services.BallService.RE.Grab:FireServer(unpack(args))
        end
    end
})

-- Вкладка 2: ESP
local espMenu = window:newMenu("ESP", "rbxassetid://9651932657")
local espSection = espMenu:newSection("ESP Options")

espSection:addToggle({
    text = "Football ESP",
    callback = function(Value)
        FootballESPEnabled = Value
        if not Value then
            ClearESP()
        end
    end
})

espSection:addToggle({
    text = "Player ESP",
    callback = function(Value)
        PlayerESPEnabled = Value
        if not Value then
            ClearPlayerESP()
        end
    end
})

espSection:addToggle({
    text = "Team ESP",
    callback = function(Value)
        TeamESPEnabled = Value
        if not Value then
            ClearTeamESP()
        end
    end
})

-- Вкладка 3: Team
local teamMenu = window:newMenu("Team", "rbxassetid://9651932657")
local teamSection = teamMenu:newSection("Team Selection")

teamSection:addDropdown({
    text = "Select Team",
    options = {"Home", "Away"},
    default = "Home",
    callback = function(Option)
        selectedTeam = Option
    end
})

teamSection:addDropdown({
    text = "Select Role",
    options = {"CF", "GK", "LW", "RW", "CM"},
    default = "CF",
    callback = function(Option)
        selectedRole = Option
    end
})

teamSection:addToggle({
    text = "Auto Join Home",
    callback = function(Value)
        autoJoinHomeEnabled = Value
        if Value then
            while autoJoinHomeEnabled do
                if player.Team and player.Team.Name == "Visitor" then
                    local args = {"Home", selectedRole or "CF"}
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.TeamService.RE.Select:FireServer(unpack(args))
                end
                task.wait(20)
            end
        end
    end
})

teamSection:addToggle({
    text = "Auto Join Away",
    callback = function(Value)
        autoJoinAwayEnabled = Value
        if Value then
            while autoJoinAwayEnabled do
                if player.Team and player.Team.Name == "Visitor" then
                    local args = {"Away", selectedRole or "CF"}
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.TeamService.RE.Select:FireServer(unpack(args))
                end
                task.wait(20)
            end
        end
    end
})

-- Вкладка 4: Modifications
local modsMenu = window:newMenu("Modifications", "rbxassetid://9651932657")
local modsSection = modsMenu:newSection("Character Modifications")

modsSection:addToggle({
    text = "Infinite Stamina",
    callback = function(Value)
        if player:FindFirstChild("PlayerStats") and player.PlayerStats:FindFirstChild("Stamina") then
            if Value then
                player.PlayerStats.Stamina.Value = math.huge
                local args = {[1] = 0/0}
                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("StaminaService"):WaitForChild("RE"):WaitForChild("DecreaseStamina"):FireServer(unpack(args))
            else
                player.PlayerStats.Stamina.Value = 100
            end
        else
            warn("PlayerStats or Stamina not found!")
        end
    end
})

modsSection:addToggle({
    text = "No Ability Cooldown",
    callback = function(Value)
        local success, C = pcall(function()
            return require(game:GetService("ReplicatedStorage").Controllers.AbilityController)
        end)

        if not success then
            warn("AbilityController not found!")
            return
        end

        if not C or not C.AbilityCooldown or type(C.AbilityCooldown) ~= "function" then
            warn("AbilityCooldown is not a valid function!")
            return
        end

        if not C.OriginalAbilityCooldown then
            C.OriginalAbilityCooldown = C.AbilityCooldown
        end

        if Value then
            C.AbilityCooldown = function(self, abilityName, ...)
                return C.OriginalAbilityCooldown(self, abilityName, 0, ...)
            end
        else
            C.AbilityCooldown = C.OriginalAbilityCooldown
        end
    end
})

modsSection:addToggle({
    text = "Fly",
    callback = function(Value)
        fly()
    end
})

modsSection:addSlider({
    text = "CFrame Speed",
    min = 1,
    max = 500,
    default = 1,
    callback = function(Value)
        getgenv().cframespeed = Value
    end
})

modsSection:addButton({
    text = "Reset Character",
    callback = function()
        if player.Character then
            player.Character:BreakJoints()
        end
    end
})

modsSection:addToggle({
    text = "Anti Ragdoll",
    callback = function(Value)
        antiRagdoll = Value
        if Value then
            task.spawn(function()
                while antiRagdoll do
                    if player.Character and player.Character:FindFirstChild("Ragdolled") then
                        player.Character.Ragdolled:Destroy()
                    end
                    task.wait()
                end
            end)
        end
    end
})

-- Вкладка 5: Styles
local stylesMenu = window:newMenu("Styles", "rbxassetid://9651932657")
local stylesSection = stylesMenu:newSection("Style Selection")

stylesSection:addDropdown({
    text = "Select Style",
    options = {"Don Lorenzo", "Shidou", "Yukimiya", "Sae", "Kunigami", "Aiku", "Rin",
               "Karasu", "Nagi", "Reo", "King", "Hiori", "Otoya", "Bachira", "Gagamaru",
               "Isagi", "Chigiri"},
    default = selectedStyle,
    callback = function(Option)
        selectedStyle = Option
    end
})

stylesSection:addButton({
    text = "Confirm Style",
    callback = function()
        applyStyle(selectedStyle)
    end
})

-- Вкладка 6: Flow
local flowMenu = window:newMenu("Flow", "rbxassetid://9651932657")
local flowSection = flowMenu:newSection("Flow Selection")

flowSection:addDropdown({
    text = "Select Flow",
    options = {
        "Soul Harvester", "Awakened Genius", "Dribbler",
        "Prodigy", "Snake", "Crow", "Chameleon", "Trap",
        "Demon Wings", "Wild Card", "Gale Burst", "Genius",
        "Monster", "King's Instinct", "Puzzle", "Ice",
        "Lightning"
    },
    default = selectedFlow,
    callback = function(Option)
        selectedFlow = Option
    end
})

flowSection:addButton({
    text = "Confirm Flow",
    callback = function()
        applyFlow(selectedFlow)
    end
})

-- Вкладка 7: Cosmetics
local cosmeticsMenu = window:newMenu("Cosmetics", "rbxassetid://9651932657")
local cosmeticsSection = cosmeticsMenu:newSection("Cosmetic Selection")

cosmeticsSection:addDropdown({
    text = "Select Cosmetic",
    options = {"Feature unavailable"},
    default = "Feature unavailable",
    callback = function(Option)
        print("Feature unavailable")
    end
})

cosmeticsSection:addButton({
    text = "Confirm Cosmetic",
    callback = function()
        print("Feature unavailable")
    end
})

-- Вкладка 8: Settings (UI Settings + Customization + Configs)
local settingsMenu = window:newMenu("Settings", "rbxassetid://9651932657")
local settingsSection = settingsMenu:newSection("UI Controls")

settingsSection:addButton({
    text = "Destroy GUI",
    callback = function()
        window:destroy()
    end
})

settingsSection:addButton({
    text = "Rejoin Game",
    callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
})

-- Секція для кастомізації UI
local customizationSection = settingsMenu:newSection("UI Customization")

customizationSection:addDropdown({
    text = "Select Theme",
    options = {"cherry", "orange", "lime", "blueberry", "grape", "dark"},
    default = currentTheme,
    callback = function(Option)
        currentTheme = Option
        UI.notify({text = "Theme changed to " .. Option .. ". Restart UI to apply!", duration = 5})
    end
})

customizationSection:addToggle({
    text = "Enable Rounding",
    callback = function(Value)
        roundingEnabled = Value
        UI.notify({text = "Rounding " .. (Value and "enabled" or "disabled") .. ". Restart UI to apply!", duration = 5})
    end
})

customizationSection:addToggle({
    text = "Smooth Dragging",
    callback = function(Value)
        smoothDraggingEnabled = Value
        UI.notify({text = "Smooth Dragging " .. (Value and "enabled" or "disabled") .. ". Restart UI to apply!", duration = 5})
    end
})

-- Секція для конфігів
local configSection = settingsMenu:newSection("Config Management")

local configName = "default"
local configs = {"default"}

configSection:addTextbox({
    text = "Config Name",
    placeholder = "Enter config name...",
    callback = function(text)
        configName = text
    end
})

configSection:addButton({
    text = "Save Config",
    callback = function()
        local configData = {
            autofarmEnabled = autofarmEnabled,
            autoGoalEnabled = autoGoalEnabled,
            autoStealEnabled = autoStealEnabled,
            autoTPBallEnabled = autoTPBallEnabled,
            autoJoinHomeEnabled = autoJoinHomeEnabled,
            autoJoinAwayEnabled = autoJoinAwayEnabled,
            autoGoalKeeperEnabled = autoGoalKeeperEnabled,
            autoBringEnabled = autoBringEnabled,
            aimlockEnabled = aimlockEnabled,
            predictionDistance = predictionDistance,
            FootballESPEnabled = FootballESPEnabled,
            PlayerESPEnabled = PlayerESPEnabled,
            TeamESPEnabled = TeamESPEnabled,
            selectedTeam = selectedTeam,
            selectedRole = selectedRole,
            antiRagdoll = antiRagdoll,
            cframespeed = cframespeed,
            selectedStyle = selectedStyle,
            selectedFlow = selectedFlow,
            currentTheme = currentTheme,
            roundingEnabled = roundingEnabled,
            smoothDraggingEnabled = smoothDraggingEnabled
        }
        local success, encoded = pcall(HttpService.JSONEncode, HttpService, configData)
        if success then
            writefile("Redux_" .. configName .. ".json", encoded)
            if not table.find(configs, configName) then
                table.insert(configs, configName)
            end
            UI.notify({text = "Config '" .. configName .. "' saved!", duration = 5})
        else
            UI.notify({text = "Failed to save config!", duration = 5})
        end
    end
})

configSection:addDropdown({
    text = "Select Config",
    options = configs,
    default = "default",
    callback = function(Option)
        configName = Option
    end
})

configSection:addButton({
    text = "Load Config",
    callback = function()
        if not isfile("Redux_" .. configName .. ".json") then
            UI.notify({text = "Config '" .. configName .. "' not found!", duration = 5})
            return
        end
        local success, data = pcall(readfile, "Redux_" .. configName .. ".json")
        if success then
            local successDecode, decoded = pcall(HttpService.JSONDecode, HttpService, data)
            if successDecode then
                autofarmEnabled = decoded.autofarmEnabled or false
                autoGoalEnabled = decoded.autoGoalEnabled or false
                autoStealEnabled = decoded.autoStealEnabled or false
                autoTPBallEnabled = decoded.autoTPBallEnabled or false
                autoJoinHomeEnabled = decoded.autoJoinHomeEnabled or false
                autoJoinAwayEnabled = decoded.autoJoinAwayEnabled or false
                autoGoalKeeperEnabled = decoded.autoGoalKeeperEnabled or false
                autoBringEnabled = decoded.autoBringEnabled or false
                aimlockEnabled = decoded.aimlockEnabled or false
                predictionDistance = decoded.predictionDistance or 1
                FootballESPEnabled = decoded.FootballESPEnabled or false
                PlayerESPEnabled = decoded.PlayerESPEnabled or false
                TeamESPEnabled = decoded.TeamESPEnabled or false
                selectedTeam = decoded.selectedTeam or "Home"
                selectedRole = decoded.selectedRole or "CF"
                antiRagdoll = decoded.antiRagdoll or false
                cframespeed = decoded.cframespeed or 1
                selectedStyle = decoded.selectedStyle or "Default"
                selectedFlow = decoded.selectedFlow or "Default"
                currentTheme = decoded.currentTheme or "cherry"
                roundingEnabled = decoded.roundingEnabled or false
                smoothDraggingEnabled = decoded.smoothDraggingEnabled or true
                UI.notify({text = "Config '" .. configName .. "' loaded! Restart UI to apply theme changes.", duration = 5})
            else
                UI.notify({text = "Failed to decode config!", duration = 5})
            end
        else
            UI.notify({text = "Failed to load config!", duration = 5})
        end
    end
})

-- Додаємо аватар і нікнейм
local UserId = player.UserId
local PlayerName = player.Name
local AvatarImageUrl = Players:GetUserThumbnailAsync(UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Redux_Avatar"
ScreenGui.Parent = game:GetService("CoreGui")

local AvatarFrame = Instance.new("ImageLabel")
AvatarFrame.Image = AvatarImageUrl
AvatarFrame.Size = UDim2.new(0, 48, 0, 48)
AvatarFrame.Position = UDim2.new(0, 5, 1, -53)
AvatarFrame.AnchorPoint = Vector2.new(0, 1)
AvatarFrame.BackgroundTransparency = 1
AvatarFrame.Parent = ScreenGui

local NameLabel = Instance.new("TextLabel")
NameLabel.Text = PlayerName
NameLabel.Size = UDim2.new(0, 100, 0, 20)
NameLabel.Position = UDim2.new(0, 58, 1, -20)
NameLabel.AnchorPoint = Vector2.new(0, 1)
NameLabel.BackgroundTransparency = 1
NameLabel.TextColor3 = Color3.new(1, 1, 1)
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.Parent = ScreenGui

print("UI loaded successfully!")
