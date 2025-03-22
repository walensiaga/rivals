local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
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
local roles = {"CF", "GK", "LW", "RW", "CM"}
local teams = {"Home", "Away"}
local selectedTeam = "Home"
local selectedRole = "CF"

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

RunService.RenderStepped:Connect(FootballESP)

local playerEspObjects = {}
local teamEspObjects = {}
local enemyEspObjects = {}
local tracer = nil
local distanceText = nil
local highlight = nil

local ui = loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/dollarware/main/library.lua'))
if not ui then
    warn("Failed to load Dollarware UI Library from URL")
    return
end

local UI = ui({
    rounding = true,      -- Без закруглень
    theme = 'lime',      -- Тема (можна змінити на orange, lime тощо)
    smoothDragging = true -- Без плавного перетягування
})

-- Створюємо екземпляр UI через метод new
local Window = UILib.new("Redux", game.Players.LocalPlayer.UserId, "by qzwtrp")

-- Категорія Main
local MainCategory = Window:Category("Main", "http://www.roblox.com/asset/?id=4483345998")
local MainButton = MainCategory:Button("Main", "http://www.roblox.com/asset/?id=4483345998")
local MainSection = MainButton:Section("Autofarm Features", "Left")

MainSection:Toggle({
    Title = "Autofarm All",
    Description = "Enable all autofarm features",
    Default = false
}, function(Value)
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
})

MainSection:Toggle({
    Title = "Auto Steal",
    Description = "Enable auto steal",
    Default = false
}, function(Value)
    autoStealEnabled = Value
    if Value then
        task.spawn(autoSteal)
    end
})

MainSection:Toggle({
    Title = "Auto Goal",
    Description = "Automatically score goals when you have the ball",
    Default = false
}, function(Value)
    autoGoalEnabled = Value
    if Value then
        task.spawn(autoGoal)
    end
})

MainSection:Toggle({
    Title = "Auto TP Ball",
    Description = "Automatically teleport to the ball",
    Default = false
}, function(Value)
    autoTPBallEnabled = Value
    if Value then
        task.spawn(autoTPBall)
    end
})

MainSection:Toggle({
    Title = "Auto Goal Keeper",
    Description = "Automatically move to block incoming balls",
    Default = false
}, function(Value)
    autoGoalKeeperEnabled = Value
    if Value then
        task.spawn(autoGoalKeeper)
    end
})

MainSection:Slider({
    Title = "Goal Keeper Prediction Distance",
    Description = "Adjust the goal keeper prediction distance",
    Default = 1,
    Min = 0,
    Max = 10
}, function(Value)
    predictionDistance = Value
end)

MainSection:Button({
    Title = "Bring Football",
    ButtonName = "Bring",
    Description = "Bring the football to you",
}, function()
    local ball = workspace:FindFirstChild("Football")
    if ball then
        local args = {[1] = ball}
        game:GetService("ReplicatedStorage").Packages.Knit.Services.BallService.RE.Grab:FireServer(unpack(args))
    end
})

local player = game.Players.LocalPlayer

-- Категорія ESP
local ESPCategory = Window:Category("ESP", "http://www.roblox.com/asset/?id=4483345998")
local ESPButton = ESPCategory:Button("ESP", "http://www.roblox.com/asset/?id=4483345998")
local ESPSection = ESPButton:Section("ESP Options", "Left")

ESPSection:Toggle({
    Title = "Football ESP",
    Description = "Show football ESP overlay",
    Default = false
}, function(Value)
    FootballESPEnabled = Value
    if not Value then
        ClearESP()
    end
})

ESPSection:Toggle({
    Title = "Player ESP",
    Description = "Show player ESP overlay",
    Default = false
}, function(Value)
    PlayerESPEnabled = Value
    if not Value then
        ClearPlayerESP()
    end
})

ESPSection:Toggle({
    Title = "Team ESP",
    Description = "Show team ESP overlay",
    Default = false
}, function(Value)
    TeamESPEnabled = Value
    if not Value then
        ClearTeamESP()
    end
})

-- Категорія Team
local TeamCategory = Window:Category("Team", "http://www.roblox.com/asset/?id=4483345998")
local TeamButton = TeamCategory:Button("Team", "http://www.roblox.com/asset/?id=4483345998")
local TeamSection = TeamButton:Section("Team Selection", "Left")

TeamSection:Dropdown({
    Title = "Select Team",
    Description = "Choose your team",
    Options = {"Home", "Away"},
    Default = "Home"
}, function(Option)
    selectedTeam = Option
end)

TeamSection:Dropdown({
    Title = "Select Role",
    Description = "Choose your role",
    Options = {"CF", "GK", "LW", "RW", "CM"},
    Default = "CF"
}, function(Option)
    selectedRole = Option
end)

TeamSection:Toggle({
    Title = "Auto Join Home",
    Description = "Automatically join home team",
    Default = false
}, function(Value)
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
})

TeamSection:Toggle({
    Title = "Auto Join Away",
    Description = "Automatically join away team",
    Default = false
}, function(Value)
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
})

-- Категорія Modifications
local CharacterCategory = Window:Category("Modifications", "http://www.roblox.com/asset/?id=4483345998")
local CharacterButton = CharacterCategory:Button("Modifications", "http://www.roblox.com/asset/?id=4483345998")
local CharacterSection = CharacterButton:Section("Character Modifications", "Left")

CharacterSection:Toggle({
    Title = "Infinite Stamina",
    Description = "Never run out of stamina",
    Default = false
}, function(Value)
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
})

CharacterSection:Toggle({
    Title = "No Ability Cooldown",
    Description = "Remove cooldown from abilities",
    Default = false
}, function(Value)
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
})

CharacterSection:Toggle({
    Title = "Fly",
    Description = "Enable flying",
    Default = false
}, function(Value)
    fly()
end)

CharacterSection:Slider({
    Title = "CFrame Speed",
    Description = "Adjust movement speed",
    Default = 1,
    Min = 1,
    Max = 500
}, function(Value)
    getgenv().cframespeed = Value
end)

CharacterSection:Button({
    Title = "Reset Character",
    ButtonName = "Reset",
    Description = "Reset your character",
}, function()
    if player.Character then
        player.Character:BreakJoints()
    end
})

CharacterSection:Toggle({
    Title = "Anti Ragdoll",
    Description = "Prevent ragdolling",
    Default = false
}, function(Value)
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
})

-- Категорія Styles
local StyleCategory = Window:Category("Styles", "http://www.roblox.com/asset/?id=4483345998")
local StyleButton = StyleCategory:Button("Styles", "http://www.roblox.com/asset/?id=4483345998")
local StyleSection = StyleButton:Section("Style Selection", "Left")

local selectedStyle = player.PlayerStats and player.PlayerStats.Style and player.PlayerStats.Style.Value or "Default"

local function applyStyle(style)
    if player:FindFirstChild("PlayerStats") and player.PlayerStats:FindFirstChild("Style") then
        player.PlayerStats.Style.Value = style
    end
end

StyleSection:Dropdown({
    Title = "Select Style",
    Description = "Choose your player style, need Reo",
    Options = {"Don Lorenzo", "Shidou", "Yukimiya", "Sae", "Kunigami", "Aiku", "Rin",
              "Karasu", "Nagi", "Reo", "King", "Hiori", "Otoya", "Bachira", "Gagamaru",
              "Isagi", "Chigiri"},
    Default = selectedStyle
}, function(Option)
    selectedStyle = Option
end)

StyleSection:Button({
    Title = "Confirm Style",
    ButtonName = "Apply",
    Description = "Apply the selected style",
}, function()
    applyStyle(selectedStyle)
end)

-- Категорія Flow
local FlowCategory = Window:Category("Flow", "http://www.roblox.com/asset/?id=4483345998")
local FlowButton = FlowCategory:Button("Flow", "http://www.roblox.com/asset/?id=4483345998")
local FlowSection = FlowButton:Section("Flow Selection", "Left")

local selectedFlow = player.PlayerStats and player.PlayerStats.Flow and player.PlayerStats.Flow.Value or "Default"

local function applyFlow(flow)
    if player:FindFirstChild("PlayerStats") and player.PlayerStats:FindFirstChild("Flow") then
        player.PlayerStats.Flow.Value = flow
    end
end

FlowSection:Dropdown({
    Title = "Select Flow",
    Description = "Choose your flow ability, HAVE BUGS!",
    Options = {
        "Soul Harvester", "Awakened Genius", "Dribbler",
        "Prodigy", "Snake", "Crow", "Chameleon", "Trap",
        "Demon Wings", "Wild Card", "Gale Burst", "Genius",
        "Monster", "King's Instinct", "Puzzle", "Ice",
        "Lightning"
    },
    Default = selectedFlow
}, function(Option)
    selectedFlow = Option
end)

FlowSection:Button({
    Title = "Confirm Flow",
    ButtonName = "Apply",
    Description = "Apply the selected flow",
}, function()
    applyFlow(selectedFlow)
end)

-- Категорія Cosmetics
local CosmeticCategory = Window:Category("Cosmetics", "http://www.roblox.com/asset/?id=4483345998")
local CosmeticButton = CosmeticCategory:Button("Cosmetics", "http://www.roblox.com/asset/?id=4483345998")
local CosmeticSection = CosmeticButton:Section("Cosmetic Selection", "Left")

CosmeticSection:Dropdown({
    Title = "Select Cosmetic",
    Description = "Choose a cosmetic to equip",
    Options = {"Feature unavailable"},
    Default = "Feature unavailable"
}, function(Option)
    print("Feature unavailable")
end)

CosmeticSection:Button({
    Title = "Confirm Cosmetic",
    ButtonName = "Apply",
    Description = "Equip the selected cosmetic (ignores inventory)",
}, function()
    print("Feature unavailable")
end)

-- Категорія UI Settings
local UICategory = Window:Category("UI Settings", "http://www.roblox.com/asset/?id=4483345998")
local UIButton = UICategory:Button("UI Settings", "http://www.roblox.com/asset/?id=4483345998")
local UISection = UIButton:Section("UI Controls", "Left")

UISection:Button({
    Title = "Destroy GUI",
    ButtonName = "Destroy",
    Description = "Close the GUI",
}, function()
    -- ReduxHubUI не має методу Destroy, тому видаляємо вручну
    local gui = game:GetService("CoreGui"):FindFirstChild("ReduxHubUI")
    if gui then gui:Destroy() end
end)

UISection:Button({
    Title = "Rejoin Game",
    ButtonName = "Rejoin",
    Description = "Rejoin the current game",
}, function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
end)

-- Додаємо аватар і нікнейм вручну
local UserId = player.UserId
local PlayerName = player.Name
local AvatarImageUrl = Players:GetUserThumbnailAsync(UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ReduxHubUI_Avatar"
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
