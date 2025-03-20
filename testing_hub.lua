local v0 = game:GetService("Players")
local v1 = game:GetService("ReplicatedStorage")
local v2 = v0.LocalPlayer
local LocalPlayer = v0.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local v3 = game:GetService("TweenService");
local UserInputService = game:GetService("UserInputService");
local v4 = v1:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BallService"):WaitForChild("RE"):WaitForChild("Shoot");
local v5 = v1:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BallService"):WaitForChild("RE"):WaitForChild("Slide");
local v6 = v2.Character or v2.CharacterAdded:Wait();
local v7 = v6:WaitForChild("HumanoidRootPart");
local RootPart = v7
local v8 = v6:WaitForChild("Humanoid");
local v9 = game:GetService("RunService");
local v10 = game:GetService("Workspace");
local v11 = v10.CurrentCamera;
local Camera = workspace.CurrentCamera
local v12 = false;
local v13 = {};
local v14 = {};
local v15 = Vector3.new(579 - (163 + 91), 20, -49);
local v16 = Vector3.new(-247, 1948 - (1869 + 61), -50);
local v17 = false;
local v18 = false;
local v19 = false;
local v20 = false;
local v21 = false;
local v22 = false;
local v23 = false;
local v24 = {"CF","GK","LW","RW","CM"};
local v25 = {"Home","Away"};
local v26 = "Home";
local v27 = "CF";
local Ball = workspace:WaitForChild("Football", 10)
if not Ball then
    warn("No Ball Found!")
    return
end
local controlling = false
local ascending = false
local speed = 70
local angle = 0
local radius = 6
local dragging = false

local gui = Instance.new("ScreenGui")
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
gui.Enabled = false

local gui = Instance.new("ScreenGui")
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
gui.Enabled = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.2, 0, 0.3, 0)
frame.Position = UDim2.new(0, 10, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.Parent = gui

local ascendButton = Instance.new("TextButton")
ascendButton.Size = UDim2.new(1, 0, 0.3, 0)
ascendButton.Position = UDim2.new(0, 0, 0, 0)
ascendButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ascendButton.Text = "Ascend Ball"
ascendButton.Parent = frame
ascendButton.MouseButton1Click:Connect(function()
    ascending = not ascending
    if ascending then
        Ball.Anchored = true
    else
        Ball.Anchored = false
        Ball.Position = RootPart.Position
        Ball.Velocity = Vector3.new(0, 0, 0)
    end
end)

local controlButton = Instance.new("TextButton")
controlButton.Size = UDim2.new(1, 0, 0.3, 0)
controlButton.Position = UDim2.new(0, 0, 0.35, 0)
controlButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
controlButton.Text = "Ball Control"
controlButton.Parent = frame
controlButton.MouseButton1Click:Connect(function()
    controlling = not controlling
end)

local speedSlider = Instance.new("TextButton")
speedSlider.Size = UDim2.new(1, 0, 0.3, 0)
speedSlider.Position = UDim2.new(0, 0, 0.7, 0)
speedSlider.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
speedSlider.Text = "Speed: " .. speed
speedSlider.Parent = frame
speedSlider.MouseButton1Click:Connect(function()
    speed = speed + 10
    if speed > 200 then speed = 10 end
    speedSlider.Text = "Speed: " .. speed
end)

local function v28()
	local v69 = 0;
	while true do
		if (v69 == (0 - 0)) then
			for v199, v200 in pairs(v13) do
				if v200 then
					v200:Remove();
				end
			end
			v13 = {};
			v69 = 1 + 0;
		end
		if (v69 == (1475 - (1329 + 145))) then
			for v201, v202 in pairs(v14) do
				if v202 then
					v202:Remove();
				end
			end
			v14 = {};
			break;
		end
	end
end
local function v29(v70, v71)
	local v72 = 971 - (140 + 831);
	local v73;
	local v74;
	local v75;
	local v76;
	local v77;
	local v78;
	local v79;
	while true do
		if (v72 == 0) then
			v73, v74 = v11:WorldToViewportPoint(v70);
			v75, v76 = v11:WorldToViewportPoint(v71);
			if not (v74 or v76) then
				return;
			end
			v72 = 1;
		end
		if (v72 == (1853 - (1409 + 441))) then
			v79.Color = Color3.fromRGB(973 - (15 + 703), 255, 119 + 136);
			v79.Transparency = 439 - (262 + 176);
			v79.Visible = true;
			v72 = 1725 - (345 + 1376);
		end
		if (v72 == (689 - (198 + 490))) then
			v77 = Vector2.new(v73.X, v73.Y);
			v78 = Vector2.new(v75.X, v75.Y);
			v79 = Drawing.new("Line");
			v72 = 8 - 6;
		end
		if (v72 == (9 - 5)) then
			table.insert(v13, v79);
			break;
		end
		if (v72 == (1208 - (696 + 510))) then
			v79.Thickness = 1 - 0;
			v79.From = v77;
			v79.To = v78;
			v72 = 1265 - (1091 + 171);
		end
	end
end
local function v30(v80, v81, v82, v83)
	local v84 = 0 + 0;
	local v85;
	local v86;
	local v87;
	local v88;
	local v89;
	local v90;
	local v91;
	local v92;
	local v93;
	while true do
		if (v84 == 1) then
			if not (v86 or v88 or v90 or v92) then
				return;
			end
			v93 = Drawing.new("Quad");
			v93.PointA = Vector2.new(v85.X, v85.Y);
			v93.PointB = Vector2.new(v87.X, v87.Y);
			v84 = 2;
		end
		if (v84 == (9 - 6)) then
			v93.Filled = true;
			v93.Transparency = 0.25 - 0;
			v93.Visible = true;
			table.insert(v14, v93);
			break;
		end
		if (v84 == 0) then
			v85, v86 = v11:WorldToViewportPoint(v80);
			v87, v88 = v11:WorldToViewportPoint(v81);
			v89, v90 = v11:WorldToViewportPoint(v82);
			v91, v92 = v11:WorldToViewportPoint(v83);
			v84 = 1;
		end
		if (v84 == 2) then
			v93.PointC = Vector2.new(v89.X, v89.Y);
			v93.PointD = Vector2.new(v91.X, v91.Y);
			v93.Color = Color3.fromRGB(255, 629 - (123 + 251), 255);
			v93.Thickness = 0.5 - 0;
			v84 = 3;
		end
	end
end
local function v31(v94)
	local v95, v96 = v94.CFrame, v94.Size / (700 - (208 + 490));
	local v97 = {};
	for v153 = -(1 + 0), 1 + 0, 838 - (660 + 176) do
		for v167 = -(1 + 0), 203 - (14 + 188), 677 - (534 + 141) do
			for v197 = -(1 + 0), 1 + 0, 2 + 0 do
				table.insert(v97, (v95 * CFrame.new(v96 * Vector3.new(v153, v167, v197))).Position);
			end
		end
	end
	return v97;
end
local function v32(v98)
	local v99 = 0 - 0;
	local v100;
	while true do
		if (v99 == 3) then
			v29(v100[1 - 0], v100[5]);
			v29(v100[5 - 3], v100[4 + 2]);
			v29(v100[2 + 1], v100[403 - (115 + 281)]);
			v99 = 9 - 5;
		end
		if (v99 == 5) then
			v30(v100[1], v100[3 + 0], v100[16 - 9], v100[5]);
			v30(v100[2], v100[14 - 10], v100[875 - (550 + 317)], v100[8 - 2]);
			break;
		end
		if (v99 == (4 - 0)) then
			v29(v100[11 - 7], v100[293 - (134 + 151)]);
			v30(v100[1666 - (970 + 695)], v100[3 - 1], v100[1996 - (582 + 1408)], v100[5]);
			v30(v100[3], v100[13 - 9], v100[9 - 1], v100[7]);
			v99 = 18 - 13;
		end
		if (v99 == (1824 - (1195 + 629))) then
			v100 = v31(v98);
			v29(v100[1 - 0], v100[2]);
			v29(v100[243 - (187 + 54)], v100[784 - (162 + 618)]);
			v99 = 1;
		end
		if (v99 == 2) then
			v29(v100[6], v100[6 + 2]);
			v29(v100[6 + 2], v100[7]);
			v29(v100[14 - 7], v100[5]);
			v99 = 4 - 1;
		end
		if (v99 == (1 + 0)) then
			v29(v100[1640 - (1373 + 263)], v100[1003 - (451 + 549)]);
			v29(v100[3], v100[1 + 0]);
			v29(v100[7 - 2], v100[6]);
			v99 = 2 - 0;
		end
	end
end
local function v33()
	v28();
	local v101 = v10:FindFirstChild("Football");
	if (v101 and v101:IsA("BasePart") and v12) then
		v32(v101);
	end
end
local function v34()
	return v6:FindFirstChild("Football") ~= nil;
end
local function v35()
	local v102 = v2.Team;
	return v102 and (v102.Name ~= "Visitor");
end
local function v36()
	while v18 do
		local v154 = 1384 - (746 + 638);
		local v155;
		local v156;
		while true do
			if (v154 == (1 + 0)) then
				v156 = ((v155.Name == "Home") and v16) or v15;
				v7:PivotTo(CFrame.new(v156));
				v154 = 2;
			end
			if (v154 == (4 - 1)) then
				task.wait();
				break;
			end
			if (0 == v154) then
				if (not v35() or not v34()) then
					local v227 = 341 - (218 + 123);
					while true do
						if (v227 == (1581 - (1535 + 46))) then
							task.wait();
							continue;
							break;
						end
					end
				end
				v155 = v2.Team;
				v154 = 1 + 0;
			end
			if (v154 == (1 + 1)) then
				task.wait(0.1);
				v4:FireServer(561 - (306 + 254), nil, nil, Vector3.new(-(0.8986 + 0), -(0.3108 - 0), 1467.3097 - (899 + 568)));
				v154 = 2 + 1;
			end
		end
	end
end
local function v37()
	while v19 do
		local v157, v158 = nil, math.huge;
		for v168, v169 in ipairs(v0:GetPlayers()) do
			if (v169 == v2) then
				continue;
			end
			local v170 = v169.Character;
			if (not v170 or not v170:FindFirstChild("Football")) then
				continue;
			end
			local v171 = (v7.Position - v170.HumanoidRootPart.Position).Magnitude;
			if (v171 < v158) then
				v158 = v171;
				v157 = v169;
			end
		end
		if v157 then
			local v198 = 0 - 0;
			while true do
				if (v198 == (603 - (268 + 335))) then
					v7:PivotTo(v157.Character.HumanoidRootPart.CFrame);
					v5:FireServer(v157);
					break;
				end
			end
		end
		task.wait();
	end
end
local function v38()
	local v103 = 290 - (60 + 230);
	local v104;
	while true do
		if (v103 == (572 - (426 + 146))) then
			v104 = nil;
			while v20 do
				local v204 = 0;
				while true do
					if (v204 == (1 + 0)) then
						task.wait();
						break;
					end
					if ((1456 - (282 + 1174)) == v204) then
						v104 = workspace:FindFirstChild("Football");
						if v104 then
							v7:PivotTo(v104:GetPivot());
						end
						v204 = 812 - (569 + 242);
					end
				end
			end
			break;
		end
	end
end
local function v39()
	local v105;
	while autoGoalKeeperEnabled do
		v105 = workspace:FindFirstChild("Football");
		if (v105 and (v105.AssemblyLinearVelocity.Magnitude > 5)) then
			v7:PivotTo(CFrame.new(v105.Position + (v105.AssemblyLinearVelocity * (0.1 - 0))));
		end
		task.wait();
	end
end
local function v40()
	while autoBringEnabled do
		local v159 = 0 + 0;
		local v160;
		while true do
			if (v159 == (1024 - (706 + 318))) then
				v160 = workspace:FindFirstChild("Football");
				if v160 then
					local v228 = 1251 - (721 + 530);
					local v229;
					while true do
						if (v228 == (1271 - (945 + 326))) then
							v229 = {[1]=v160};
							game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BallService"):WaitForChild("RE"):WaitForChild("Grab"):FireServer(unpack(v229));
							break;
						end
					end
				end
				v159 = 1;
			end
			if (v159 == 1) then
				task.wait(0.1 - 0);
				break;
			end
		end
	end
end
local function v41()
	local v106 = true;
	local v107 = 100;
	local v108 = 890 + 110;
	local v109 = 700.4 - (271 + 429);
	local v110 = workspace.Gravity;
	v2.CharacterAdded:Connect(function(v161)
		local v162 = 0 + 0;
		while true do
			if (v162 == (1501 - (1408 + 92))) then
				v7 = v6:WaitForChild("HumanoidRootPart");
				break;
			end
			if (v162 == 0) then
				v6 = v161;
				v8 = v6:WaitForChild("Humanoid");
				v162 = 1087 - (461 + 625);
			end
		end
	end);
	local function v111(v163, v164)
		return v163 + (v163 * (math.random(-v164, v164) / 100));
	end
	if v106 then
		workspace.Gravity = 1288 - (993 + 295);
		task.spawn(function()
			while v106 do
				local v205 = Vector3.new();
				local v206 = workspace.CurrentCamera.CFrame;
				v205 = v205 + ((UserInputService:IsKeyDown(Enum.KeyCode.W) and v206.LookVector) or Vector3.new());
				v205 = v205 - ((UserInputService:IsKeyDown(Enum.KeyCode.S) and v206.LookVector) or Vector3.new());
				v205 = v205 - ((UserInputService:IsKeyDown(Enum.KeyCode.A) and v206.RightVector) or Vector3.new());
				v205 = v205 + ((UserInputService:IsKeyDown(Enum.KeyCode.D) and v206.RightVector) or Vector3.new());
				v205 = v205 + ((UserInputService:IsKeyDown(Enum.KeyCode.Space) and Vector3.new(0, 1 + 0, 0)) or Vector3.new());
				v205 = v205 - ((UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and Vector3.new(0, 1, 1171 - (418 + 753))) or Vector3.new());
				if (v205.Magnitude > (0 + 0)) then
					local v230 = 0 + 0;
					while true do
						if (v230 == 1) then
							v7.Velocity = v205 * 0.5;
							break;
						end
						if (v230 == 0) then
							v107 = math.min(v107 + v109, v108);
							v205 = v205.Unit * math.min(v111(v107, 3 + 7), v108);
							v230 = 1 + 0;
						end
					end
				else
					v7.Velocity = Vector3.new(529 - (406 + 123), 1769 - (1749 + 20), 0 + 0);
				end
				v9.RenderStepped:Wait();
				if not v106 then
					break;
				end
			end
		end);
	else
		local v173 = 1322 - (1249 + 73);
		while true do
			if (v173 == (1 + 0)) then
				v7.Velocity = Vector3.new(0, 0, 0);
				workspace.Gravity = v110;
				break;
			end
			if (v173 == (1145 - (466 + 679))) then
				v106 = false;
				v107 = 240 - 140;
				v173 = 2 - 1;
			end
		end
	end
end
local function v42()
	if tracer then
		tracer:Remove();
		tracer = nil;
	end
end
local function v43()
	if distanceText then
		local v174 = 1900 - (106 + 1794);
		while true do
			if (v174 == 0) then
				distanceText:Remove();
				distanceText = nil;
				break;
			end
		end
	end
end
local function v44()
	if highlight then
		local v175 = 0 + 0;
		while true do
			if (v175 == (0 + 0)) then
				highlight:Destroy();
				highlight = nil;
				break;
			end
		end
	end
end
local function v45()
	local v112 = 0 - 0;
	while true do
		if (v112 == (0 - 0)) then
			for v207, v208 in pairs(teamEspObjects or {}) do
				if v208.esp then
					v208.esp:Remove();
				end
				if v208.highlight then
					v208.highlight:Destroy();
				end
				if v208.nameTag then
					v208.nameTag:Remove();
				end
			end
			teamEspObjects = {};
			break;
		end
	end
end
local function v46()
	local v113 = 114 - (4 + 110);
	while true do
		if (v113 == (584 - (57 + 527))) then
			for v209, v210 in pairs(enemyEspObjects or {}) do
				local v211 = 0;
				while true do
					if (v211 == 1) then
						if v210.nameTag then
							v210.nameTag:Remove();
						end
						break;
					end
					if (v211 == (1427 - (41 + 1386))) then
						if v210.esp then
							v210.esp:Remove();
						end
						if v210.highlight then
							v210.highlight:Destroy();
						end
						v211 = 104 - (17 + 86);
					end
				end
			end
			enemyEspObjects = {};
			break;
		end
	end
end
local function v47()
	local v114 = 0 + 0;
	while true do
		if (v114 == (0 - 0)) then
			for v212, v213 in pairs(playerEspObjects or {}) do
				if v213.esp then
					v213.esp:Remove();
				end
				if v213.highlight then
					v213.highlight:Destroy();
				end
				if v213.nameTag then
					v213.nameTag:Remove();
				end
			end
			playerEspObjects = {};
			break;
		end
	end
end
local function v48()
	while aimlockEnabled do
		local v165 = 0 - 0;
		local v166;
		while true do
			if ((166 - (122 + 44)) == v165) then
				v166 = workspace:FindFirstChild("Football");
				if v166 then
					local v232 = workspace.CurrentCamera;
					if v2.Character then
						v232.CFrame = CFrame.new(v232.CFrame.Position, v166.Position);
					end
				end
				v165 = 1 - 0;
			end
			if (v165 == (3 - 2)) then
				task.wait();
				break;
			end
		end
	end
end
v9.RenderStepped:Connect(v33);
local v49 = {};
local v50 = {};
local v51 = {};
local v52 = nil;
local v53 = nil;
local v54 = nil;
local v55 = loadstring(game:HttpGet("https://paste.ee/r/WSCKThwW", true))();
local v56 = v55:CreateWindow({Name="MoonShine (Blue Lock Rivals)",Subtitle="by qzwtrp",LogoID="87459248805004",LoadingEnabled=true,LoadingTitle="TheMoonShineHub",LoadingSubtitle="by qzwtrp",ConfigSettings={RootFolder="qzwtrp",ConfigFolder="Configs",AutoLoadConfig=true}});
v56:CreateHomeTab({SupportedExecutors={"Delta","Fluxus","Codex","Cryptic","Vegax","Trigon","Synapse X","Script-Ware","KRNL","Seliware","Solara","Xeno","ZORARA","Luna","Nihon","JJsploit","AWP","Wave","Ronix","JJSploit"},DiscordInvite="http://dsc.gg/mshine",Icon=(87459248805004 - 0)});
local v57 = v56:CreateTab({Name="Main",Icon="home_filled",ImageSource="Material",ShowTitle=true});
local v58 = v56:CreateTab({Name="Local Player",Icon="account_circle",ImageSource="Material",ShowTitle=true});
local v59 = v56:CreateTab({Name="ESP",Icon="visibility",ImageSource="Material",ShowTitle=true});
local v60 = v56:CreateTab({Name="Team",Icon="group_work",ImageSource="Material",ShowTitle=true});
local v61 = v56:CreateTab({Name="Styles",Icon="brush",ImageSource="Material",ShowTitle=true});
local v62 = v56:CreateTab({Name="Flow",Icon="waves",ImageSource="Material",ShowTitle=true});
local v63 = v56:CreateTab({Name="Cosmetics",Icon="stars",ImageSource="Material",ShowTitle=true});
local v64 = v56:CreateTab({Name="UI Settings",Icon="settings_applications",ImageSource="Material",ShowTitle=true});
v57:CreateSection("Autofarm Features");
v57:CreateToggle({Name="Autofarm All",Description="Enable all autofarm features",CurrentValue=false,Callback=function(v115)
	local v116 = 982 - (18 + 964);
	while true do
		if (v116 == 0) then
			v18 = v115;
			v19 = v115;
			v116 = 3 - 2;
		end
		if (v116 == (1 + 0)) then
			v20 = v115;
			autoBringEnabled = v115;
			v116 = 2 + 0;
		end
		if ((852 - (20 + 830)) == v116) then
			autoGoalKeeperEnabled = v115;
			if v115 then
				task.spawn(v36);
				task.spawn(v37);
				task.spawn(v38);
				task.spawn(v40);
				task.spawn(v39);
			end
			break;
		end
	end
end});
v57:CreateToggle({Name="Auto Steal",Description="Enable auto steal",CurrentValue=false,Callback=function(v117)
	v19 = v117;
	if v117 then
		task.spawn(v37);
	else
		task.cancel(v37);
	end
end});
v57:CreateToggle({Name="Auto Goal",Description="Automatically score goals when you have the ball",CurrentValue=false,Callback=function(v118)
	local v119 = 0;
	while true do
		if ((0 + 0) == v119) then
			v18 = v118;
			if v118 then
				task.spawn(v36);
			end
			break;
		end
	end
end});
v57:CreateToggle({Name="Auto TP Ball",Description="Automatically teleport to the ball",CurrentValue=false,Callback=function(v120)
	v20 = v120;
	if v120 then
		task.spawn(v38);
	end
end});
v57:CreateToggle({Name="Auto Goal Keeper",Description="Automatically move to block incoming balls",CurrentValue=false,Callback=function(v121)
	local v122 = 0;
	while true do
		if (v122 == (126 - (116 + 10))) then
			autoGoalKeeperEnabled = v121;
			if v121 then
				task.spawn(v39);
			end
			break;
		end
	end
end});
v57:CreateSlider({Name="Goal Keeper Prediction Distance",Description="Adjust the goal keeper prediction distance",Range={(738 - (542 + 196)),(30 + 70)},Increment=(1 + 0),Suffix="Studs",CurrentValue=(18 + 32),Callback=function(v123)
	predictionDistance = v123;
end});
v57:CreateButton({Name="Bring Football",Description="Bring the football to you",Callback=function()
	local v124 = 0 - 0;
	local v125;
	while true do
		if (v124 == (0 - 0)) then
			v125 = workspace:FindFirstChild("Football");
			if v125 then
				local v218 = 1551 - (1126 + 425);
				local v219;
				while true do
					if (v218 == (405 - (118 + 287))) then
						v219 = {[3 - 2]=v125};
						game:GetService("ReplicatedStorage").Packages.Knit.Services.BallService.RE.Grab:FireServer(unpack(v219));
						break;
					end
				end
			end
			break;
		end
	end
end});
v59:CreateSection("ESP Options");
v59:CreateToggle({Name="Football ESP",Description="Show football ESP overlay",CurrentValue=false,Callback=function(v126)
	local v127 = 1121 - (118 + 1003);
	while true do
		if (v127 == (0 - 0)) then
			v12 = v126;
			if not v126 then
				v28();
			end
			break;
		end
	end
end});
v59:CreateToggle({Name="Player ESP",Description="Show player ESP overlay",CurrentValue=false,Callback=function(v128)
	PlayerESPEnabled = v128;
	if not v128 then
		v47();
	end
end});
v59:CreateToggle({Name="Team ESP",Description="Show team ESP overlay",CurrentValue=false,Callback=function(v129)
	TeamESPEnabled = v129;
	if not v129 then
		v45();
	end
end});
local v2 = game.Players.LocalPlayer;
v60:CreateSection("Team Selection");
v60:CreateDropdown({Name="Select Team",Description="Choose your team",Options={"Home","Away"},CurrentOption="Home",MultipleOptions=false,Callback=function(v130)
	v26 = v130;
end});
v60:CreateDropdown({Name="Select Role",Description="Choose your role",Options={"CF","GK","LW","RW","CM"},CurrentOption="CF",MultipleOptions=false,Callback=function(v131)
	v27 = v131;
end});
v60:CreateToggle({Name="Auto Join Home",Description="Automatically join home team",CurrentValue=false,Callback=function(v132)
	local v133 = 0;
	while true do
		if (v133 == 0) then
			v22 = v132;
			if v132 then
				while v22 do
					local v233 = 0 - 0;
					while true do
						if (0 == v233) then
							if (v2.Team and (v2.Team.Name == "Visitor")) then
								local v241 = {"Home",(v27 or "CF")};
								game:GetService("ReplicatedStorage").Packages.Knit.Services.TeamService.RE.Select:FireServer(unpack(v241));
							end
							task.wait(18 + 2);
							break;
						end
					end
				end
			end
			break;
		end
	end
end});
v60:CreateToggle({Name="Auto Join Away",Description="Automatically join away team",CurrentValue=false,Callback=function(v134)
	local v135 = 0 + 0;
	while true do
		if (v135 == (0 + 0)) then
			v23 = v134;
			if v134 then
				while v23 do
					if (v2.Team and (v2.Team.Name == "Visitor")) then
						local v238 = 0 + 0;
						local v239;
						while true do
							if (v238 == 0) then
								v239 = {"Away",(v27 or "CF")};
								game:GetService("ReplicatedStorage").Packages.Knit.Services.TeamService.RE.Select:FireServer(unpack(v239));
								break;
							end
						end
					end
					task.wait(43 - 23);
				end
			end
			break;
		end
	end
end});
v58:CreateSection("Character Modifications");
v58:CreateToggle({Name="Infinite Stamina",Description="Never run out of stamina",CurrentValue=false,Callback=function(v136)
	if v136 then
		local v176 = 0 - 0;
		local v177;
		while true do
			if (v176 == (2 - 1)) then
				game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("StaminaService"):WaitForChild("RE"):WaitForChild("DecreaseStamina"):FireServer(unpack(v177));
				break;
			end
			if (v176 == 0) then
				v2.PlayerStats.Stamina.Value = math.huge;
				v177 = {[1]=NaN};
				v176 = 1 + 0;
			end
		end
	else
		v2.PlayerStats.Stamina.Value = 100;
	end
end});
v58:CreateToggle({
    Name = "Ball Control",Description = "Show or Hide the Ball Control GUI",
    CurrentValue = false,
    Callback = function(state)
        guiEnabled = state
        gui.Enabled = state
    end
})

RunService.Heartbeat:Connect(function()
    if ascending then
        angle = angle + 0.05
        Ball.Position = RootPart.Position + Vector3.new(math.cos(angle) * radius, 3, math.sin(angle) * radius)
    end
end)

RunService.Heartbeat:Connect(function()
    if controlling then
        local moveDirection = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + Camera.CFrame.RightVector
        end
        if moveDirection.Magnitude > 0 then
            Ball.Velocity = moveDirection.Unit * speed
        else
          Ball.Velocity = Vector3.new(0,0,0)
        end
    end
end)

v58:CreateToggle({Name="No Ability Cooldown",Description="Remove cooldown from abilities",CurrentValue=false,Callback=function(v137)
	local v138 = 0 - 0;
	local v139;
	while true do
		if (v138 == (753 - (239 + 514))) then
			v139 = require(game:GetService("ReplicatedStorage").Controllers.AbilityController);
			if v137 then
				local v222 = v139.AbilityCooldown;
				v139.AbilityCooldown = function(v234, v235, ...)
					return v222(v234, v235, 0 + 0, ...);
				end;
			else
				v139.AbilityCooldown = require(game:GetService("ReplicatedStorage").Controllers.AbilityController).AbilityCooldown;
			end
			break;
		end
	end
end});
v58:CreateToggle({Name="Noclip",Description="Walk through walls",CurrentValue=false,Callback=function(v140)
	getgenv().noclip = v140;
end});
v58:CreateToggle({Name="Fly",Description="Enable flying",CurrentValue=false,Callback=function(v142)
	if v142 then
		v41();
	else
		workspace.Gravity = 196.2;
	end
end});
v58:CreateSlider({Name="CFrame Speed",Description="Adjust movement speed",Range={1,500},Increment=(1 + 0),CurrentValue=1,Callback=function(v143)
	getgenv().cframespeed = v143;
end});
v58:CreateButton({Name="Reset Character",Description="Reset your character",Callback=function()
	if v2.Character then
		v2.Character:BreakJoints();
	end
end});
v58:CreateToggle({Name="Anti Ragdoll",Description="Prevent ragdolling",CurrentValue=false,Callback=function(v145)
	local v146 = 0 - 0;
	while true do
		if (v146 == (1202 - (373 + 829))) then
			antiRagdoll = v145;
			if v145 then
				task.spawn(function()
					while antiRagdoll do
						local v236 = 0;
						while true do
							if (v236 == (731 - (476 + 255))) then
								if (v2.Character and v2.Character:FindFirstChild("Ragdolled")) then
									v2.Character.Ragdolled:Destroy();
								end
								task.wait();
								break;
							end
						end
					end
				end);
			end
			break;
		end
	end
end});
v61:CreateSection("Style Selection");
local v65 = v2.PlayerStats.Style.Value;
local function v66(v147)
	if (v2 and v2:FindFirstChild("PlayerStats") and v2.PlayerStats:FindFirstChild("Style")) then
		local v180 = 1130 - (369 + 761);
		while true do
			if (v180 == (0 + 0)) then
				v2.PlayerStats.Style.Value = v147;
				v55:Notification({Title="Style Applied",Content=("Style has been set to: " .. v147),Icon="check_circle",ImageSource="Material"});
				break;
			end
		end
	end
end
v61:CreateDropdown({Name="Select Style",Description="Choose your player style, need Reo",Options={"Don Lorenzo","Shidou","Yukimiya","Sae","Kunigami","Aiku","Rin","Karasu","Nagi","Reo","King","Hiori","Otoya","Bachira","Gagamaru","Isagi","Chigiri"},CurrentOption={v65},MultipleOptions=false,Callback=function(v148)
	v65 = v148;
end});
v61:CreateButton({Name="Confirm Style",Description="Apply the selected style",Callback=function()
	v66(v65);
end});
v62:CreateSection("Flow Selection");
local v67 = v2.PlayerStats.Flow.Value;
local function v68(v149)
	if (v2 and v2:FindFirstChild("PlayerStats") and v2.PlayerStats:FindFirstChild("Flow")) then
		v2.PlayerStats.Flow.Value = v149;
		v55:Notification({Title="Flow Applied",Content=("Flow has been set to: " .. v149),Icon="check_circle",ImageSource="Material"});
	end
end
v62:CreateDropdown({Name="Select Flow",Description="Choose your flow ability, HAVE BUGS!",Options={"Soul Harvester","Awakened Genius","Dribbler","Prodigy","Snake","Crow","Chameleon","Trap","Demon Wings","Wild Card","Gale Burst","Genius","Monster","King's Instinct","Puzzle","Ice","Lightning"},CurrentOption={v67},MultipleOptions=false,Callback=function(v150)
	v67 = v150;
end});
v62:CreateButton({Name="Confirm Flow",Description="Apply the selected flow",Callback=function()
	v68(v67);
end});
v63:CreateSection("Cosmetic Selection");
v63:CreateDropdown({Name="Select Cosmetic",Description="Choose a cosmetic to equip",Options={"Feature unavailable"},CurrentOption={"Feature unavailable"},MultipleOptions=false,Callback=function(v151)
	print("Feature unavailable");
end});
v63:CreateButton({Name="Confirm Cosmetic",Description="Equip the selected cosmetic (ignores inventory)",Callback=function()
	v55:Notification({Title="Feature Unavailable",Content="Will be added in the next update",Icon="info",ImageSource="Material"});
end});
v64:CreateButton({Name="Destroy GUI",Description="Close the GUI",Callback=function()
	local v152 = 0 + 0;
	while true do
		if (v152 == (476 - (41 + 435))) then
			for v214, v215 in pairs(getconnections(game:GetService("CoreGui").ChildAdded)) do
				v215:Disable();
			end
			game:GetService("CoreGui").Luna:Destroy();
			break;
		end
	end
end});
v64:CreateButton({Name="Rejoin Game",Description="Rejoin the current game",Callback=function()
	game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId);
end});
v64:BuildThemeSection();
v64:BuildConfigSection();
v55:Notification({Title="Config Loaded",Content="Your saved configuration has been automatically loaded.",Icon="check_circle",ImageSource="Material"});
