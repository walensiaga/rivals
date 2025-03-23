local KeyGuardLibrary = loadstring(game:HttpGet("https://cdn.keyguardian.org/library/v1.0.0.lua"))()
local trueData = "8c7b3f3ad46247d3b51fc3df69a6cd2a"
local falseData = "7813cffbc1654d60b00b72019dcce9ab"

KeyGuardLibrary.Set({
	publicToken = "eabe7a96a6d84c3b94a46766e3d70d8a",
	privateToken = "b56392ebadb2421aa90bd311fe37beab",
	trueData = trueData,
	falseData = falseData,
})

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local key = ""

local Window = Fluent:CreateWindow({
		Title = "Key System",
		SubTitle = "Redux Hub",
		TabWidth = 160,
		Size = UDim2.fromOffset(580, 340),
		Acrylic = false,
		Theme = "Dark",
		MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
		KeySys = Window:AddTab({ Title = "Key System", Icon = "key" }),
}

local Entkey = Tabs.KeySys:AddInput("Input", {
		Title = "Enter Key",
		Description = "Enter Key Here",
		Default = "",
		Placeholder = "Enter key…",
		Numeric = false,
		Finished = false,
		Callback = function(Value)
				key = Value
		end
})

local Checkkey = Tabs.KeySys:AddButton({
		Title = "Check Key",
		Description = "Enter Key before pressing this button",
		Callback = function()
				local response = KeyGuardLibrary.validateDefaultKey(key)
				if response == trueData then
						print("Key is valid")
						loadstring(game:HttpGet("https://raw.githubusercontent.com/walensiaga/rivals/refs/heads/main/hub.lua"))()
				else
						print("Key is invalid")
				end
		end
})

local Getkey = Tabs.KeySys:AddButton({
		Title = "Get Key",
		Description = "Get Key here",
		Callback = function()
				setclipboard(KeyGuardLibrary.getLink())
		end
})

Window:SelectTab(1)
