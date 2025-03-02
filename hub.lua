local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

local function autoGoalKeeper()
    local ball
    while autoGoalKeeperEnabled do
        ball = workspace:FindFirstChild("Football")
        if ball and ball.AssemblyLinearVelocity.Magnitude > 5 then
            rootPart:PivotTo(CFrame.new(
                ball.Position + (ball.AssemblyLinearVelocity * 0.1)
            ))
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
    local flying = true
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

    if flying then
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
                if not flying then break end
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

RunService.RenderStepped:Connect(FootballESP)

local playerEspObjects = {}
local teamEspObjects = {}
local enemyEspObjects = {}
local tracer = nil
local distanceText = nil
local highlight = nil

local Luna = loadstring(game:HttpGet("https://paste.ee/r/WSCKThwW", true))()


local Window = Luna:CreateWindow({
    Name = "The MoonShine Hub (Blue Lock Rivals)",
    Subtitle = "by qzwtrp",
    LogoID = "75237883871377",
    LoadingEnabled = true,
    LoadingTitle = "TheMoonShineHub (Blue Lock Rivals)",
    LoadingSubtitle = "by qzwtrp",
    ConfigSettings = {
        RootFolder = "qzwtrp", -- Added root folder for better organization
        ConfigFolder = "Configs", -- Changed to a dedicated configs folder
        AutoLoadConfig = true -- Enable auto-loading of saved configurations
    },
})

Window:CreateHomeTab({
    SupportedExecutors = {"Delta", "Fluxus", "Codex", "Cryptic", "Vegax", "Trigon", "Synapse X", "Script-Ware", "KRNL", "Seliware", "Solara", "Xeno", "ZORARA", "Luna", "Nihon", "JJsploit", "AWP", "Wave", "Ronix", "JJSploit"},
    DiscordInvite = "http://dsc.gg/mshine",
    Icon = 75237883871377,
})
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "home_filled",
    ImageSource = "Material",
    ShowTitle = true
})

local CharacterTab = Window:CreateTab({
    Name = "Local Player",
    Icon = "account_circle",
    ImageSource = "Material",
    ShowTitle = true
})

local ESPTab = Window:CreateTab({
    Name = "ESP",
    Icon = "visibility",
    ImageSource = "Material",
    ShowTitle = true
})

local TeamTab = Window:CreateTab({
    Name = "Team",
    Icon = "group_work",
    ImageSource = "Material",
    ShowTitle = true
})

local StyleTab = Window:CreateTab({
    Name = "Styles",
    Icon = "brush",
    ImageSource = "Material",
    ShowTitle = true
})

local FlowTab = Window:CreateTab({
    Name = "Flow",
    Icon = "waves",
    ImageSource = "Material",
    ShowTitle = true
})

local CosmeticTab = Window:CreateTab({
    Name = "Cosmetics",
    Icon = "stars",
    ImageSource = "Material",
    ShowTitle = true
})

local UITab = Window:CreateTab({
    Name = "UI Settings",
    Icon = "settings_applications",
    ImageSource = "Material",
    ShowTitle = true
})

MainTab:CreateSection("Autofarm Features")

MainTab:CreateToggle({
    Name = "Autofarm All",
    Description = "Enable all autofarm features",
    CurrentValue = false,
    Callback = function(Value)
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
MainTab :CreateToggle({
    Name = "Auto Steal",
    Description = "Enable auto steal",
    CurrentValue = false,
    Callback = function(Value)
        autoStealEnabled = Value
        if Value then
            task.spawn(autoSteal)
        else
            task.cancel(autoSteal)
        end
    end
})

MainTab:CreateToggle({
    Name = "Auto Goal",
    Description = "Automatically score goals when you have the ball",
    CurrentValue = false,
    Callback = function(Value)
        autoGoalEnabled = Value
        if Value then
            task.spawn(autoGoal)
        end
    end
})

MainTab:CreateToggle({
    Name = "Auto TP Ball",
    Description = "Automatically teleport to the ball",
    CurrentValue = false,
    Callback = function(Value)
        autoTPBallEnabled = Value
        if Value then
            task.spawn(autoTPBall)
        end
    end
})

MainTab:CreateToggle({
    Name = "Auto Goal Keeper",
    Description = "Automatically move to block incoming balls",
    CurrentValue = false,
    Callback = function(Value)
        autoGoalKeeperEnabled = Value
        if Value then
            task.spawn(autoGoalKeeper)
        end
    end
})

MainTab:CreateSlider({
    Name = "Goal Keeper Prediction Distance",
    Description = "Adjust the goal keeper prediction distance",
    Range = {0, 100},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 50,
    Callback = function(Value)
        predictionDistance = Value
    end,
})

MainTab:CreateButton({
    Name = "Bring Football",
    Description = "Bring the football to you",
    Callback = function()
        local ball = workspace:FindFirstChild("Football")
        if ball then
            local args = {[1] = ball}
            game:GetService("ReplicatedStorage").Packages.Knit.Services.BallService.RE.Grab:FireServer(unpack(args))
        end
    end
})

ESPTab:CreateSection("ESP Options")

ESPTab:CreateToggle({
    Name = "Football ESP",
    Description = "Show football ESP overlay",
    CurrentValue = false,
    Callback = function(Value)
        FootballESPEnabled = Value
        if not Value then
            ClearESP()
        end
    end
})

ESPTab:CreateToggle({
    Name = "Player ESP",
    Description = "Show player ESP overlay",
    CurrentValue = false,
    Callback = function(Value)
        PlayerESPEnabled = Value
        if not Value then
            ClearPlayerESP()
        end
    end
})

ESPTab:CreateToggle({
    Name = "Team ESP",
    Description = "Show team ESP overlay",
    CurrentValue = false,
    Callback = function(Value)
        TeamESPEnabled = Value
        if not Value then
            ClearTeamESP()
        end
    end
})

TeamTab:CreateSection("Team Selection")

TeamTab:CreateDropdown({
    Name = "Select Team",
    Description = "Choose your team",
    Options = {"Home", "Away"},
    CurrentOption = {"Home"},
    MultipleOptions = false,
    Callback = function(Option)
        selectedTeam = Option
    end
})

TeamTab:CreateDropdown({
    Name = "Select Role",
    Description = "Choose your role",
    Options = {"CF", "GK", "LW", "RW", "CM"},
    CurrentOption = {"CF"},
    MultipleOptions = false,
    Callback = function(Option)
        selectedRole = Option
    end
})

TeamTab:CreateToggle({
    Name = "Auto Join Home",
    Description = "Automatically join home team",
    CurrentValue = false,
    Callback = function(Value)
        autoJoinHomeEnabled = Value
        if Value then
            task.spawn(function()
                while autoJoinHomeEnabled do
                    if player.Team and player.Team.Name == "Visitor" then
                        local args = {"Home", selectedRole or "CF"}
                        game:GetService("ReplicatedStorage").Packages.Knit.Services.TeamService.RE.Select:FireServer(unpack(args))
                    end
                    task.wait(20)
                end
            end)
        end
    end
})

TeamTab:CreateToggle({
    Name = "Auto Join Away",
    Description = "Automatically join away team",
    CurrentValue = false,
    Callback = function(Value)
        autoJoinAwayEnabled = Value
        if Value then
            task.spawn(function()
                while autoJoinAwayEnabled do
                    if player.Team and player.Team.Name == "Visitor" then
                        local args = {"Away", selectedRole or "CF"}
                        game:GetService("ReplicatedStorage").Packages.Knit.Services.TeamService.RE.Select:FireServer(unpack(args))
                    end
                    task.wait(20)
                end
            end)
        end
    end
})

CharacterTab:CreateSection("Character Modifications")

CharacterTab:CreateToggle({
    Name = "Infinite Stamina",
    Description = "Never run out of stamina",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            player.PlayerStats.Stamina.Value = math.huge
        else
            player.PlayerStats.Stamina.Value = 100
        end
    end
})

CharacterTab:CreateToggle({
    Name = "Noclip",
    Description = "Walk through walls",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().noclip = Value
    end
})

CharacterTab:CreateToggle({
    Name = "Fly",
    Description = "Enable flying",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            fly()
        else
            workspace.Gravity = 196.2
        end
    end
})

CharacterTab:CreateSlider({
    Name = "CFrame Speed",
    Description = "Adjust movement speed",
    Range = {1, 500},
    Increment = 1,
    CurrentValue = 1,
    Callback = function(Value)
        getgenv().cframespeed = Value
    end
})

CharacterTab:CreateButton({
    Name = "Reset Character",
    Description = "Reset your character",
    Callback = function()
        if player.Character then
            player.Character:BreakJoints()
        end
    end
})

CharacterTab:CreateToggle({
    Name = "Anti Ragdoll",
    Description = "Prevent ragdolling",
    CurrentValue = false,
    Callback = function(Value)
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

StyleTab:CreateSection("Style Selection")

StyleTab:CreateDropdown({
    Name = "Select Style",
    Description = "Choose your player style, need Reo",
    Options = {"Don Lorenzo", "Shidou", "Yukimiya", "Sae", "Kunigami", "Aiku", "Rin",
              "Karasu", "Nagi", "Reo", "King", "Hiori", "Otoya", "Bachira", "Gagamaru",
              "Isagi", "Chigiri"
},
    CurrentOption = {"Yukimiya"},
    MultipleOptions = false,
    Callback = function(Option)
        player.PlayerStats.Style.Value = Option
    end
})

FlowTab:CreateSection("Flow Selection")

FlowTab:CreateDropdown({
    Name = "Select Flow",
    Description = "Choose your flow ability, HAVE BUGS!",
    Options = {
        "Soul Harvester", "Awakened Genius", "Dribbler",
        "Prodigy", "Snake", "Crow", "Chameleon", "Trap",
        "Demon Wings", "Wild Card", "Gale Burst", "Genius",
        "Monster", "King's Instinct", "Puzzle", "Ice",
        "Lightning"
    },
    CurrentOption = {"Dribbler"},
    MultipleOptions = false,
    Callback = function(Option)
        if player and player:FindFirstChild("PlayerStats") and player.PlayerStats:FindFirstChild("Flow") then
            player.PlayerStats.Flow.Value = Option
        end
    end
})

CosmeticTab:CreateSection("Cosmetic Selection")

CosmeticTab:CreateLabel({
    Name = "Cosmetics Soon Next Update"
})

UITab:CreateButton({
    Name = "Destroy GUI",
    Description = "Close the GUI",
    Callback = function()
        for _, connection in pairs(getconnections(game:GetService("CoreGui").ChildAdded)) do
            connection:Disable()
        end
        game:GetService("CoreGui").Luna:Destroy()
    end
})

UITab:CreateButton({
    Name = "Rejoin Game",
    Description = "Rejoin the current game",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
})
UITab:BuildThemeSection()


UITab:BuildConfigSection()
Luna:Notification({
    Title = "Config Loaded",
    Content = "Your saved configuration has been automatically loaded.",
    Icon = "check_circle",
    ImageSource = "Material"
})
