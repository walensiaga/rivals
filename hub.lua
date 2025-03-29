local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ballServiceRemote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BallService"):WaitForChild("RE"):WaitForChild("Shoot")
local slideRemote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BallService"):WaitForChild("RE"):WaitForChild("Slide")
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Змінні за замовчуванням
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
local autoJoinEnabled
local autoGoalKeeperEnabled = false
local autoBringEnabled = false
local aimlockEnabled = false
local predictionDistance = 1
local MAX_DISTANCE = 3
local tracer = nil
local distanceText = nil
local highlight = nil
local roles = {"CF", "LW", "RW", "CM", "GK"}
local teams = {"Home", "Away"}
local selectedTeam = "Home"
local selectedRole = "CF"
local PlayerESPEnabled = false
local TeamESPEnabled = false
local antiRagdoll = false
local cframespeed = 1
local flyEnabled = false
local playerEspObjects = {}
local teamEspObjects = {}
local enemyEspObjects = {}
local aimCircle = nil
local silentAimGoalEnabled = false
local aimRadius = 5
local wheelCords = Vector3.new(117.8, -443.9, -258.9)
local valentineCords = Vector3.new(-23.66, -493.26, -129.15)
local defaultCords = Vector3.new(5.9, 11.2, -40.8)
local MAX_INTERCEPT_DISTANCE = 10
local BLOCK_DISTANCE = 3
local PREDICTION_TIME = 0.5
local currentTheme = "Dark"
local roundingEnabled = false
local smoothDraggingEnabled = true

local autoJoinConnection = nil
local function autoJoinTeam()
    while autoJoinEnabled do
        if player.Team and player.Team.Name == "Visitor" then
            local args = {selectedTeam, selectedRole or "CF"}
            game:GetService("ReplicatedStorage").Packages.Knit.Services.TeamService.RE.Select:FireServer(unpack(args))
        end
        task.wait(0.01)
    end
end

-- Функції для ESP
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
    if not FootballESPEnabled then return end
    ClearESP()

    local Football = Workspace:FindFirstChild("Football")
    if Football and Football:IsA("BasePart") then
        DrawFootballESP(Football)
    end
end

local function DrawPlayerESP(otherPlayer)
    if not PlayerESPEnabled then return end
    local char = otherPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local root = char.HumanoidRootPart
    local head = char:FindFirstChild("Head")
    if not head then return end

    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not onScreen then return end

    local esp = Drawing.new("Text")
    esp.Text = otherPlayer.Name
    esp.Size = 16
    esp.Center = true
    esp.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
    esp.Color = Color3.fromRGB(255, 255, 255)
    esp.Outline = true
    esp.Visible = true

    playerEspObjects[otherPlayer] = {esp = esp}
end

local function DrawTeamESP(otherPlayer)
    if not TeamESPEnabled or otherPlayer.Team ~= player.Team then return end
    local char = otherPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local root = char.HumanoidRootPart
    local head = char:FindFirstChild("Head")
    if not head then return end

    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not onScreen then return end

    local esp = Drawing.new("Text")
    esp.Text = otherPlayer.Name .. " [" .. (otherPlayer:FindFirstChild("PlayerStats") and otherPlayer.PlayerStats.Role.Value or "N/A") .. "]"
    esp.Size = 16
    esp.Center = true
    esp.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
    esp.Color = Color3.fromRGB(0, 255, 0)
    esp.Outline = true
    esp.Visible = true

    teamEspObjects[otherPlayer] = {esp = esp}
end

local function UpdateESP()
    if PlayerESPEnabled then
        ClearPlayerESP()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                DrawPlayerESP(p)
            end
        end
    end

    if TeamESPEnabled then
        ClearTeamESP()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                DrawTeamESP(p)
            end
        end
    end
end

local function ClearPlayerESP()
    for _, objects in pairs(playerEspObjects) do
        if objects.esp then objects.esp:Remove() end
    end
    playerEspObjects = {}
end

local function ClearTeamESP()
    for _, objects in pairs(teamEspObjects) do
        if objects.esp then objects.esp:Remove() end
    end
    teamEspObjects = {}
end

local function drawAimCircle(targetPosition)
    if aimCircle then
        aimCircle:Remove()
        aimCircle = nil
    end

    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPosition)
    if not onScreen then return end

    local radiusInPixels = (aimRadius / (rootPart.Position - Camera.CFrame.Position).Magnitude) * Camera.ViewportSize.Y

    aimCircle = Drawing.new("Circle")
    aimCircle.Position = Vector2.new(screenPos.X, screenPos.Y)
    aimCircle.Radius = radiusInPixels
    aimCircle.Color = Color3.fromRGB(255, 0, 0)
    aimCircle.Thickness = 2
    aimCircle.Filled = false
    aimCircle.Transparency = 0.7
    aimCircle.Visible = true
end

local function clearAimCircle()
    if aimCircle then
        aimCircle:Remove()
        aimCircle = nil
    end
end

local function findSafeGoalPosition(team)
    local goalPosition = team.Name == "Home" and awayGoalPosition or homeGoalPosition
    local goalkeeper = nil
    
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Team ~= player.Team then
            local role = otherPlayer:FindFirstChild("PlayerStats") and otherPlayer.PlayerStats:FindFirstChild("Role")
            if role and role.Value == "GK" then
                goalkeeper = otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                break
            end
        end
    end

    local randomAngle = math.random() * 2 * math.pi
    local randomRadius = math.random() * aimRadius
    local offsetX = math.cos(randomAngle) * randomRadius
    local offsetZ = math.sin(randomAngle) * randomRadius
    
    local targetPosition = goalPosition + Vector3.new(offsetX, 0, offsetZ)
    
    if goalkeeper then
        local distanceToGK = (targetPosition - goalkeeper.Position).Magnitude
        if distanceToGK < 10 then
            return findSafeGoalPosition(team)
        end
    end
    
    return targetPosition
end

local function silentAimGoal()
    while silentAimGoalEnabled do
        joinSelectedTeam()
        if not checkTeam() or not hasBall() then
            task.wait()
            continue
        end

        local team = player.Team
        local targetPosition = findSafeGoalPosition(team)
        
        local direction = (targetPosition - rootPart.Position).Unit
        
        ballServiceRemote:FireServer(1, nil, nil, direction)
        
        local ball = workspace:FindFirstChild("Football")
        if ball then
            ball.CanCollide = false
            task.wait(3.5)
            ball.CanCollide = true
        end
        
        task.wait(0.1)
    end
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
        joinSelectedTeam()
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
        joinSelectedTeam()
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
        joinSelectedTeam()
        ball = workspace:FindFirstChild("Football")
        if ball then
            rootPart:PivotTo(ball:GetPivot())
        end
        task.wait()
    end
end

local function isBallMovingTowardsGK(ball, goalPosition)
    local ballVelocity = ball.AssemblyLinearVelocity
    local ballToGoal = (goalPosition - ball.Position).Unit
    local dotProduct = ballVelocity.Unit:Dot(ballToGoal)
    return dotProduct > 0 and ballVelocity.Magnitude > 5
end

local function predictBallPosition(ball)
    local ballVelocity = ball.AssemblyLinearVelocity
    return ball.Position + ballVelocity * PREDICTION_TIME
end

local function getBallDirection(ball, goalkeeperRoot)
    local ballVelocity = ball.AssemblyLinearVelocity
    local rightVector = goalkeeperRoot.CFrame.RightVector
    local ballDir = ballVelocity.Unit
    local dotRight = rightVector:Dot(ballDir)
    
    if dotRight > 0.5 then
        return "right"
    elseif dotRight < -0.5 then
        return "left"
    else
        return "forward"
    end
end

local function jumpInDirection(direction, ball)
    if direction == "right" then
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, -math.pi/2, 0)
    elseif direction == "left" then
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.pi/2, 0)
    elseif direction == "forward" then
        aimAtBall(ball)
    end
    
    UserInputService:SendKeyEvent(true, Enum.KeyCode.Q, false, nil)
    task.wait(0.1)
    UserInputService:SendKeyEvent(false, Enum.KeyCode.Q, false, nil)
end

local function autoGoalKeeper()
    while autoGoalKeeperEnabled do
        joinSelectedTeam()
        local ball = workspace:FindFirstChild("Football")
        if not ball or not ball:IsA("BasePart") or not player.Team then
            task.wait()
            continue
        end

        local goalPosition = player.Team.Name == "Home" and homeGoalPosition or awayGoalPosition

        if isBallMovingTowardsGK(ball, goalPosition) then
            local predictedPos = predictBallPosition(ball)
            local distanceToBall = (predictedPos - rootPart.Position).Magnitude

            if distanceToBall <= MAX_INTERCEPT_DISTANCE then
                local direction = (predictedPos - rootPart.Position).Unit
                rootPart.CFrame = CFrame.new(rootPart.Position + direction * 2) * CFrame.lookAt(rootPart.Position, predictedPos)

                if distanceToBall <= BLOCK_DISTANCE then
                    local ballDirection = getBallDirection(ball, rootPart)
                    jumpInDirection(ballDirection, ball)
                end
            end
        end
        task.wait(0.05)
    end
end

local function autoBring()
    while autoBringEnabled do
        joinSelectedTeam()
        local ball = workspace:FindFirstChild("Football")
        if ball then
            local args = {[1] = ball}
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BallService"):WaitForChild("RE"):WaitForChild("Grab"):FireServer(unpack(args))
        end
        task.wait(0.1)
    end
end

local function fly()
    if not flyEnabled then return end

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
            while flying and flyEnabled do
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
            workspace.Gravity = originalGravity
            rootPart.Velocity = Vector3.new(0, 0, 0)
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

local espConnection
local function StartFootballESP()
    if espConnection then
        espConnection:Disconnect()
    end
    if FootballESPEnabled then
        espConnection = RunService.RenderStepped:Connect(FootballESP)
    end
end

local playerEspConnection
local function StartPlayerESP()
    if playerEspConnection then
        playerEspConnection:Disconnect()
    end
    if PlayerESPEnabled or TeamESPEnabled then
        playerEspConnection = RunService.RenderStepped:Connect(UpdateESP)
    end
end

-- Завантаження Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
if not Fluent then
    warn("Failed to load UI Library")
    return
end

local Window = Fluent:CreateWindow({
    Title = "Redux Hub",
    SubTitle = "by qzwtrp",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 500),
    Theme = currentTheme,
    Acrylic = true,
    MinimizeKey = Enum.KeyCode.RightShift
})

local MainTab = Window:AddTab({ Title = "Main", Icon = "home" })
local TeleportsTab = Window:AddTab({ Title = "Teleports", Icon = "plane" })
local ESPTab = Window:AddTab({ Title = "ESP", Icon = "eye" })
local TeamTab = Window:AddTab({ Title = "Team", Icon = "users" })
local ModsTab = Window:AddTab({ Title = "Modifications", Icon = "wrench" })
local StylesTab = Window:AddTab({ Title = "Styles", Icon = "palette" })
local FlowTab = Window:AddTab({ Title = "Flow", Icon = "grape" })
local CosmeticsTab = Window:AddTab({ Title = "Cosmetics", Icon = "gift" })
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })

-- Main Tab
MainTab:AddSection("Autofarm Features")

MainTab:AddToggle("AutofarmAll", {
    Title = "Autofarm All",
    Default = false,
    Callback = function(Value)
        autofarmEnabled = Value
        autoGoalEnabled = Value
        autoStealEnabled = Value
        autoTPBallEnabled = Value
        autoBringEnabled = Value
        autoGoalKeeperEnabled = Value
        
        if Value then
            joinSelectedTeam()
            task.spawn(autoGoal)
            task.spawn(autoSteal)
            task.spawn(autoTPBall)
            task.spawn(autoBring)
            task.spawn(autoGoalKeeper)
        end
    end
})

MainTab:AddToggle("AutoSteal", {
    Title = "Auto Steal",
    Default = false,
    Callback = function(Value)
        autoStealEnabled = Value
        if Value then
            task.spawn(autoSteal)
        end
    end
})

MainTab:AddToggle("AutoGoal", {
    Title = "Auto Goal",
    Default = false,
    Callback = function(Value)
        autoGoalEnabled = Value
        if Value then
            task.spawn(autoGoal)
        end
    end
})

MainTab:AddToggle("AutoTPBall", {
    Title = "Auto TP Ball",
    Default = false,
    Callback = function(Value)
        autoTPBallEnabled = Value
        if Value then
            task.spawn(autoTPBall)
        end
    end
})

MainTab:AddToggle("AutoGoalKeeper", {
    Title = "Auto Goal Keeper",
    Default = false,
    Callback = function(Value)
        autoGoalKeeperEnabled = Value
        if Value then
            task.spawn(autoGoalKeeper)
        end
    end
})

MainTab:AddSlider("InterceptDistance", {
    Title = "Intercept Distance",
    Description = "Distance to start intercepting the ball",
    Default = 10,
    Min = 5,
    Max = 20,
    Rounding = 1,
    Callback = function(Value)
        MAX_INTERCEPT_DISTANCE = Value
    end
})

MainTab:AddSlider("BlockDistance", {
    Title = "Defend Distance",
    Description = "Distance to jump towards the ball",
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        BLOCK_DISTANCE = Value
    end
})

MainTab:AddSlider("PredictionTime", {
    Title = "Prediction Time",
    Description = "Time to predict ball position (seconds)",
    Default = 0.5,
    Min = 0.1,
    Max = 1,
    Rounding = 1,
    Callback = function(Value)
        PREDICTION_TIME = Value
    end
})

MainTab:AddButton({
    Title = "Bring Football",
    Callback = function()
        local ball = workspace:FindFirstChild("Football")
        if ball then
            local args = {[1] = ball}
            game:GetService("ReplicatedStorage").Packages.Knit.Services.BallService.RE.Grab:FireServer(unpack(args))
        end
    end
})

MainTab:AddToggle("SilentAimGoal", {
    Title = "Silent Aim Goal",
    Default = false,
    Callback = function(Value)
        silentAimGoalEnabled = Value
        if Value then
            task.spawn(silentAimGoal)
        else
            clearAimCircle()
        end
    end
})

MainTab:AddSlider("AimRadius", {
    Title = "Aim Radius",
    Description = "Adjust aiming circle radius",
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Callback = function(Value)
        aimRadius = Value
        if silentAimGoalEnabled and hasBall() then
            local team = player.Team
            local targetPosition = findSafeGoalPosition(team)
            drawAimCircle(targetPosition)
        end
    end
})

-- Teleports Tab
TeleportsTab:AddSection("Teleport Options")

TeleportsTab:AddButton({
    Title = "Golden Wheel TP",
    Callback = function()
        if player.Character and rootPart then
            local originalPosition = rootPart.Position
            rootPart.CFrame = CFrame.new(wheelCords)
            Fluent:Notify({Title = "Teleport", Content = "Teleported to Golden Wheel!", Duration = 3})
            task.wait(0.0000001)
            rootPart.CFrame = CFrame.new(originalPosition)
            Fluent:Notify({Title = "Teleport", Content = "Returned to original position!", Duration = 3})
        else
            Fluent:Notify({Title = "Error", Content = "Character or root part not found!", Duration = 3})
        end
    end
})

TeleportsTab:AddButton({
    Title = "Valentines Quests TP",
    Callback = function()
        if player.Character and rootPart then
            local originalPosition = rootPart.Position
            rootPart.CFrame = CFrame.new(valentineCords)
            Fluent:Notify({Title = "Teleport", Content = "Teleported to Valentines Quests!", Duration = 3})
            task.wait(0.0000001)
            rootPart.CFrame = CFrame.new(originalPosition)
            Fluent:Notify({Title = "Teleport", Content = "Returned to original position!", Duration = 3})
        else
            Fluent:Notify({Title = "Error", Content = "Character or root part not found!", Duration = 3})
        end
    end
})

-- ESP Tab
ESPTab:AddSection("ESP Options")

ESPTab:AddToggle("FootballESP", {
    Title = "Football ESP",
    Default = false,
    Callback = function(Value)
        FootballESPEnabled = Value
        StartFootballESP()
        if not Value then
            ClearESP()
        end
    end
})

ESPTab:AddToggle("PlayerESP", {
    Title = "Player ESP",
    Default = false,
    Callback = function(Value)
        PlayerESPEnabled = Value
        StartPlayerESP()
        if not Value then
            ClearPlayerESP()
        end
    end
})

ESPTab:AddToggle("TeamESP", {
    Title = "Team ESP",
    Default = false,
    Callback = function(Value)
        TeamESPEnabled = Value
        StartPlayerESP()
        if not Value then
            ClearTeamESP()
        end
    end
})

-- Team Tab
TeamTab:AddSection("Team Selection")

TeamTab:AddDropdown("SelectTeam", {
    Title = "Select Team",
    Values = {"Home", "Away"},
    Default = "Home",
    Callback = function(Option)
        selectedTeam = Option
    end
})

TeamTab:AddDropdown("SelectRole", {
    Title = "Select Role",
    Values = {"CF", "LW", "RW", "CM", "GK"},
    Default = "CF",
    Callback = function(Option)
        selectedRole = Option
    end
})

TeamTab:AddToggle("AutoJoin", {
    Title = "Auto Join Team",
    Default = false,
    Callback = function(Value)
        autoJoinEnabled = Value
        if Value then
            if autoJoinConnection then
                autoJoinConnection:Disconnect()
            end
            autoJoinConnection = task.spawn(autoJoinTeam)
        else
            if autoJoinConnection then
                autoJoinConnection:Disconnect()
                autoJoinConnection = nil
            end
        end
    end
})

-- Modifications Tab
ModsTab:AddSection("Character Modifications")

ModsTab:AddToggle("InfiniteStamina", {
    Title = "Infinite Stamina",
    Default = false,
    Callback = function(Value)
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

ModsTab:AddToggle("NoAbilityCooldown", {
    Title = "No Ability Cooldown",
    Default = false,
    Callback = function(Value)
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

ModsTab:AddToggle("Fly", {
    Title = "Fly",
    Default = false,
    Callback = function(Value)
        flyEnabled = Value
        fly()
    end
})

ModsTab:AddSlider("CFrameSpeed", {
    Title = "CFrame Speed",
    Description = "Adjust CFrame speed",
    Default = 1,
    Min = 1,
    Max = 500,
    Rounding = 1,
    Callback = function(Value)
        getgenv().cframespeed = Value
    end
})

ModsTab:AddButton({
    Title = "Reset Character",
    Callback = function()
        if player.Character then
            player.Character:BreakJoints()
        end
    end
})

ModsTab:AddToggle("AntiRagdoll", {
    Title = "Anti Ragdoll",
    Default = false,
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

-- Styles Tab
StylesTab:AddSection("Style Selection")

StylesTab:AddDropdown("SelectStyle", {
    Title = "Select Style",
    Values = {"Sae", "NEL Isagi", "Don Lorenzo", "Shidou", "Yukimiya", "Kunigami", "Aiku", "Rin",
              "Karasu", "Nagi", "Reo", "King", "Kurona", "Hiori", "Otoya", "Bachira", "Gagamaru",
              "Isagi", "Chigiri"},
    Default = selectedStyle,
    Callback = function(Option)
        selectedStyle = Option
    end
})

StylesTab:AddButton({
    Title = "Confirm Style",
    Callback = function()
        applyStyle(selectedStyle)
    end
})

-- Flow Tab
FlowTab:AddSection("Flow Selection")

FlowTab:AddDropdown("SelectFlow", {
    Title = "Select Flow",
    Values = {
        "Soul Harvester", "Awakened Genius", "Dribbler",
        "Prodigy", "Snake", "Crow", "Chameleon", "Trap",
        "Demon Wings", "Wild Card", "Gale Burst", "Genius",
        "Monster", "King's Instinct", "Puzzle", "Ice",
        "Lightning"
    },
    Default = selectedFlow,
    Callback = function(Option)
        selectedFlow = Option
    end
})

FlowTab:AddButton({
    Title = "Confirm Flow",
    Callback = function()
        applyFlow(selectedFlow)
    end
})

-- Cosmetics Tab
CosmeticsTab:AddSection("Cosmetic Selection")

CosmeticsTab:AddDropdown("SelectCosmetic", {
    Title = "Select Cosmetic",
    Values = {"Feature unavailable"},
    Default = "Feature unavailable",
    Callback = function(Option)
        Fluent:Notify({Title = "Error", Content = "Feature unavailable!", Duration = 3})
    end
})

CosmeticsTab:AddButton({
    Title = "Confirm Cosmetic",
    Callback = function()
        Fluent:Notify({Title = "Error", Content = "Feature unavailable!", Duration = 3})
    end
})

-- Settings Tab
SettingsTab:AddSection("UI Controls")

SettingsTab:AddButton({
    Title = "Destroy GUI",
    Callback = function()
        Fluent:Destroy()
    end
})

SettingsTab:AddButton({
    Title = "Rejoin Game",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
})

SettingsTab:AddSection("UI Customization")

SettingsTab:AddDropdown("SelectTheme", {
    Title = "Select Theme",
    Values = {"Dark", "Light", "Aqua", "Jester"},
    Default = currentTheme,
    Callback = function(Option)
        currentTheme = Option
        Fluent:Notify({Title = "Theme Changed", Content = "Theme changed to " .. Option .. ". Restart UI to apply!", Duration = 5})
    end
})

SettingsTab:AddSection("Config Management")

local configName = "default"
local configs = {"default"}

SettingsTab:AddInput("ConfigName", {
    Title = "Config Name",
    Placeholder = "Enter config name...",
    Callback = function(text)
        configName = text
    end
})

SettingsTab:AddButton({
    Title = "Save Config",
    Callback = function()
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
            currentTheme = currentTheme
        }
        local success, encoded = pcall(HttpService.JSONEncode, HttpService, configData)
        if success then
            writefile("Redux_" .. configName .. ".json", encoded)
            if not table.find(configs, configName) then
                table.insert(configs, configName)
            end
            Fluent:Notify({Title = "Config Saved", Content = "Config '" .. configName .. "' saved!", Duration = 5})
        else
            Fluent:Notify({Title = "Error", Content = "Failed to save config!", Duration = 5})
        end
    end
})

SettingsTab:AddDropdown("SelectConfig", {
    Title = "Select Config",
    Values = configs,
    Default = "default",
    Callback = function(Option)
        configName = Option
    end
})

SettingsTab:AddButton({
    Title = "Load Config",
    Callback = function()
        if not isfile("Redux_" .. configName .. ".json") then
            Fluent:Notify({Title = "Error", Content = "Config '" .. configName .. "' not found!", Duration = 5})
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
                currentTheme = decoded.currentTheme or "Dark"
                Fluent:Notify({Title = "Config Loaded", Content = "Config '" .. configName .. "' loaded! Restart UI to apply theme changes.", Duration = 5})
            else
                Fluent:Notify({Title = "Error", Content = "Failed to decode config!", Duration = 5})
            end
        else
            Fluent:Notify({Title = "Error", Content = "Failed to load config!", Duration = 5})
        end
    end
})

Window:SelectTab(1)
print("UI loaded successfully!")
