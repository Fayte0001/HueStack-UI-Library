local UICornerStrokeLib = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DraggableObject = require(ReplicatedStorage:WaitForChild("DraggableObject"))

--[[
    ===========================================
    THEME CONFIGURATION
    ===========================================
--]]

local defaultTheme = {
	-- Color scheme
	BackgroundColor = Color3.fromRGB(25, 25, 25),
	PrimaryColor = Color3.fromRGB(45, 45, 45),
	SecondaryColor = Color3.fromRGB(35, 35, 35),
	TextColor = Color3.fromRGB(240, 240, 240),
	AccentColor = Color3.fromRGB(100, 180, 255),
	SuccessColor = Color3.fromRGB(85, 200, 100),
	WarningColor = Color3.fromRGB(255, 175, 75),
	ErrorColor = Color3.fromRGB(255, 100, 100),
	DisabledColor = Color3.fromRGB(100, 100, 100),

	-- Visual effects
	HoverModifier = 0.1,
	CornerRadius = UDim.new(0, 8),
	StrokeThickness = 1,

	-- Typography
	FontTitle = Enum.Font.GothamBold,
	FontButton = Enum.Font.GothamMedium,
	FontContent = Enum.Font.Gotham,
	TitleTextSize = 18,
	ButtonTextSize = 14,
	ContentTextSize = 13,

	-- Animation
	TransitionSpeed = 0.15,

	-- Shadows
	ShadowColor = Color3.new(0, 0, 0),
	ShadowTransparency = 0.7,

	-- Transparency settings
	Transparency = {
		Background = 0.1,
		Stroke = 0.3,
		ButtonHover = 0.8,
		Dropdown = 0.15,
		SliderTrack = 0.25,
		Window = 0.05,
		Section = 0.2
	},

	-- Spacing and layout
	Spacing = {
		Padding = 12,
		ElementMargin = 8,
		SidePanelPadding = 15,
		InnerPadding = 6,
		SectionSpacing = 12
	},

	-- Z-index management
	ZIndex = {
		Base = 5,
		Container = 10,
		Content = 15,
		Interactive = 20,
		Dropdown = 25,
		Overlay = 30,
		Tooltip = 40,
		Section = 12
	},

	-- Advanced customization
	AnimationEasing = Enum.EasingStyle.Quad,
	AnimationDirection = Enum.EasingDirection.Out,
	EnableAnimations = true,
	EnableShadows = true,
	EnableAutoLayout = true,
	EnableResponsiveScaling = true,
	MinWindowWidth = 300,
	MaxWindowWidth = 800,
	DefaultWindowSize = UDim2.new(0, 650, 0, 450),
	SectionBackgroundColor = Color3.fromRGB(40, 40, 40)
}


local theme = table.clone(defaultTheme)

--[[
    ===========================================
    UTILITY FUNCTIONS
    ===========================================
--]]
local themeListeners = {}

local function notifyThemeChange()
	for _, listener in pairs(themeListeners) do
		if listener then
			pcall(listener, theme) 
		end
	end
end

function UICornerStrokeLib.RegisterThemeListener(callback)
	table.insert(themeListeners, callback)
	return #themeListeners 
end

function UICornerStrokeLib.UnregisterThemeListener(id)
	themeListeners[id] = nil
end

local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

local function applyCornerRadius(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius or theme.CornerRadius
	corner.Parent = instance
	return corner
end

local function addShadow(element, transparency, offset)
	if not theme.EnableShadows then return nil end

	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Image = "rbxassetid://1316045217"
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	shadow.ImageColor3 = theme.ShadowColor
	shadow.ImageTransparency = transparency or theme.ShadowTransparency
	shadow.BackgroundTransparency = 1
	shadow.Size = UDim2.new(1, offset or 12, 1, offset or 12)
	shadow.Position = UDim2.new(0, -(offset or 6), 0, -(offset or 6))
	shadow.ZIndex = element.ZIndex - 1
	shadow.Parent = element.Parent
	return shadow
end

local function createGradient(color, rotation, transparency)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(1, color:Lerp(Color3.new(0,0,0), 0.1))
	})
	gradient.Rotation = rotation or 90
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, transparency or 0),
		NumberSequenceKeypoint.new(1, transparency or 0)
	})
	return gradient
end

local function calculateResponsiveSize(baseSize, minWidth, maxWidth)
	if not theme.EnableResponsiveScaling then return baseSize end

	local viewportSize = workspace.CurrentCamera.ViewportSize
	local screenWidth = viewportSize.X
	local scaleFactor = math.clamp((screenWidth - minWidth) / (maxWidth - minWidth), 0, 1)

	return UDim2.new(
		baseSize.X.Scale, 
		math.floor(baseSize.X.Offset * (0.8 + 0.2 * scaleFactor)),
		baseSize.Y.Scale,
		math.floor(baseSize.Y.Offset * (0.8 + 0.2 * scaleFactor)))
end

--[[
    ===========================================
    CORE ELEMENT CREATION
    ===========================================
--]]

function UICornerStrokeLib.CreateElement(className, props)
	local element = Instance.new(className)

	local nonVisualElements = {
		UIPadding = true,
		UIListLayout = true,
		UIGridLayout = true,
		UIStroke = true,
		UICorner = true,
		UIGradient = true
	}

	local internalProps = {
		AutoLayout = true
	}

	for property, value in pairs(props) do
		if not internalProps[property] then
			if not (property == "ZIndex" and nonVisualElements[className]) then
				if property == "Size" and className == "Frame" and theme.EnableResponsiveScaling then
					element[property] = calculateResponsiveSize(value, theme.MinWindowWidth, theme.MaxWindowWidth)
				else
					element[property] = value
				end
			end
		end
	end

	if not nonVisualElements[className] and not props.ZIndex then
		if className == "TextButton" or className == "TextBox" then
			element.ZIndex = theme.ZIndex.Interactive
		elseif className == "Frame" then
			element.ZIndex = theme.ZIndex.Content
		end
	end

	if className == "Frame" and props.AutoLayout then
		local layout = Instance.new("UIListLayout")
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, theme.Spacing.ElementMargin)
		
		layout.Parent = element

		if not props.Size or props.Size.Y.Offset == 0 then
			element.AutomaticSize = Enum.AutomaticSize.Y
		end
	end

	return element
end

function UICornerStrokeLib.ApplyStyle(frame, custom)
	custom = custom or {}
	if frame:FindFirstChild("UICorner") then
		frame.UICorner:Destroy()
	end
	applyCornerRadius(frame, custom.CornerRadius)

	local stroke = UICornerStrokeLib.CreateElement("UIStroke", {
		Thickness = custom.StrokeThickness or theme.StrokeThickness,
		Color = custom.StrokeColor or theme.PrimaryColor:Lerp(Color3.new(1,1,1), 0.2),
		Transparency = custom.StrokeTransparency or theme.Transparency.Stroke,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		LineJoinMode = Enum.LineJoinMode.Round,
		AutoLayout = false
	})
	stroke.Parent = frame

	
	if frame:IsA("TextButton") or frame:IsA("Frame") then
		frame.BackgroundTransparency = custom.BackgroundTransparency or theme.Transparency.Background

		if custom.Gradient then
			createGradient(
				frame.BackgroundColor3, 
				custom.GradientRotation, 
				custom.BackgroundTransparency or theme.Transparency.Background
			).Parent = frame
		end
	end

	if custom.Shadow then
		addShadow(frame, custom.ShadowTransparency, custom.ShadowOffset)
	end

	return frame
end

--[[
    ===========================================
    SECTION CREATION (Background Frames)
    ===========================================
--]]

function UICornerStrokeLib.CreateSection(parent, settings)
	settings = settings or {}

	local section = UICornerStrokeLib.CreateElement("Frame", {
		Size = settings.Size or UDim2.new(1, -24, 0, 100),
		BackgroundColor3 = settings.BackgroundColor3 or theme.SectionBackgroundColor,
		LayoutOrder = settings.LayoutOrder or 1,
		ZIndex = settings.ZIndex or theme.ZIndex.Section,
		ClipsDescendants = true,
		AutoLayout = true 
	})

	UICornerStrokeLib.ApplyStyle(section, {
		BackgroundTransparency = settings.Transparency or theme.Transparency.Section,
		StrokeColor = theme.SecondaryColor,
		Shadow = settings.Shadow
	})

	if not settings.NoPadding then
		local padding = UICornerStrokeLib.CreateElement("UIPadding", {
			PaddingTop = UDim.new(0, theme.Spacing.InnerPadding),
			PaddingLeft = UDim.new(0, theme.Spacing.InnerPadding),
			PaddingRight = UDim.new(0, theme.Spacing.InnerPadding),
			PaddingBottom = UDim.new(0, theme.Spacing.InnerPadding),
			AutoLayout = false
		})
		padding.Parent = section
	end

	if settings.Title then
		local titleBar = UICornerStrokeLib.CreateElement("Frame", {
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundColor3 = theme.SecondaryColor,
			ZIndex = section.ZIndex + 1,
			AutoLayout = false
		})

		UICornerStrokeLib.ApplyStyle(titleBar, {
			BackgroundTransparency = 0.15,
			StrokeColor = theme.AccentColor,
			CornerRadius = UDim.new(0, 0)
		})

		local titleText = UICornerStrokeLib.CreateElement("TextLabel", {
			Size = UDim2.new(1, -16, 1, 0),
			Position = UDim2.new(0, 8, 0, 0),
			Text = settings.Title,
			TextColor3 = theme.TextColor,
			Font = theme.FontButton,
			TextSize = theme.ButtonTextSize,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			ZIndex = titleBar.ZIndex + 1,
			AutoLayout = false
		})

		titleText.Parent = titleBar
		titleBar.Parent = section

		if not settings.NoContentPadding then
			local contentPadding = UICornerStrokeLib.CreateElement("UIPadding", {
				PaddingTop = UDim.new(0, 36),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8),
				AutoLayout = false
			})
			contentPadding.Parent = section
		end
	elseif not settings.NoContentPadding then
		local contentPadding = UICornerStrokeLib.CreateElement("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			AutoLayout = false
		})
		contentPadding.Parent = section
	end

	if not settings.NoLayout then
		local layout = UICornerStrokeLib.CreateElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, theme.Spacing.ElementMargin),
			AutoLayout = false
		})
		layout.Parent = section

		if not settings.FixedSize then
			section.AutomaticSize = Enum.AutomaticSize.Y
		end
	end

	section.Parent = parent

	local sectionObj = {
		Frame = section,
		AddElement = function(self, elementType, elementSettings)
			return UICornerStrokeLib["Create"..elementType](section, elementSettings)
		end
	}

	return sectionObj
end

--[[
    ===========================================
    WINDOW CREATION
    ===========================================
--]]

function UICornerStrokeLib.CreateWindow(settings)
	settings = settings or {}

	-- Main GUI container
	local gui = UICornerStrokeLib.CreateElement("ScreenGui", {
		Name = settings.Name or "ModernUI",
		ResetOnSpawn = false,
		DisplayOrder = settings.DisplayOrder or 10,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		AutoLayout = false
	})
	gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

	local mainFrame = UICornerStrokeLib.CreateElement("Frame", {
		Size = settings.Size or theme.DefaultWindowSize,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.BackgroundColor,
		Active = true,
		Draggable = false,
		ZIndex = theme.ZIndex.Base,
		ClipsDescendants = true,
		AutoLayout = false
	})

	UICornerStrokeLib.ApplyStyle(mainFrame, {
		BackgroundTransparency = theme.Transparency.Window,
		Shadow = true,
		ShadowOffset = 16
	})
	mainFrame.Parent = gui

	local draggable = DraggableObject.new(mainFrame)
	draggable:Enable()

	local titleBar = UICornerStrokeLib.CreateElement("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = theme.PrimaryColor,
		ZIndex = theme.ZIndex.Container + 1,
		AutoLayout = false
	})
	UICornerStrokeLib.ApplyStyle(titleBar, {
		StrokeColor = theme.SecondaryColor,
		BackgroundTransparency = 0.1,

	})
	titleBar.Parent = mainFrame

	local titleText = UICornerStrokeLib.CreateElement("TextLabel", {
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.new(0, 15, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Text = settings.Title or "Modern UI Window",
		TextColor3 = theme.TextColor,
		BackgroundTransparency = 1,
		Font = theme.FontTitle,
		TextSize = theme.TitleTextSize,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = theme.ZIndex.Container + 2,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AutoLayout = false
	})
	titleText.Parent = titleBar

	local closeButton = UICornerStrokeLib.CreateElement("TextButton", {
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, -14, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = theme.ErrorColor,
		Text = "×",
		TextColor3 = Color3.new(1,1,1),
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		AutoButtonColor = false,
		ZIndex = theme.ZIndex.Container + 2,
		AutoLayout = true
	})

	UICornerStrokeLib.ApplyStyle(closeButton, {
		CornerRadius = UDim.new(1, 0),
		BackgroundTransparency = 0.2,
		StrokeColor = Color3.new(1,1,1)
	})

	closeButton.MouseEnter:Connect(function()
		UICornerStrokeLib.CreateTween(closeButton, {
			BackgroundColor3 = theme.ErrorColor:Lerp(Color3.new(1,1,1), 0.3),
			TextColor3 = theme.ErrorColor
		}, 0.15)
	end)

	closeButton.MouseLeave:Connect(function()
		UICornerStrokeLib.CreateTween(closeButton, {
			BackgroundColor3 = theme.ErrorColor,
			TextColor3 = Color3.new(1,1,1)
		}, 0.15)
	end)

	closeButton.MouseButton1Click:Connect(function()
		UICornerStrokeLib.CreateTween(mainFrame, {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}, 0.2).Completed:Wait()
		gui:Destroy()
	end)
	closeButton.Parent = titleBar
	local minimizeButton = UICornerStrokeLib.CreateElement("TextButton", {
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, -50, 0.5, 0), 
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = theme.PrimaryColor, 
		Text = "–", 
		TextColor3 = Color3.new(1,1,1),
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		AutoButtonColor = false,
		ZIndex = theme.ZIndex.Container + 2,
		AutoLayout = true
	})

	UICornerStrokeLib.ApplyStyle(minimizeButton, {
		CornerRadius = UDim.new(1, 0),
		BackgroundTransparency = 0.2,
		StrokeColor = Color3.new(1,1,1)
	})

	-- Minimize button animations
	minimizeButton.MouseEnter:Connect(function()
		UICornerStrokeLib.CreateTween(minimizeButton, {
			BackgroundColor3 = theme.PrimaryColor:Lerp(Color3.new(1,1,1), 0.3),
			TextColor3 = theme.PrimaryColor
		}, 0.15)
	end)

	minimizeButton.MouseLeave:Connect(function()
		UICornerStrokeLib.CreateTween(minimizeButton, {
			BackgroundColor3 = theme.PrimaryColor,
			TextColor3 = Color3.new(1,1,1)
		}, 0.15)
	end)

	local originalSize
	local originalPosition
	local isMinimized = false

	minimizeButton.MouseButton1Click:Connect(function()
		if not isMinimized then
			originalSize = mainFrame.Size
			originalPosition = mainFrame.Position

			local titleBarHeight = titleBar.Size.Y.Offset
			local titleBarWidth = mainFrame.Size.X.Offset

			UICornerStrokeLib.CreateTween(mainFrame, {
				Size = UDim2.new(0, titleBarWidth, 0, titleBarHeight)
			}, 0.2)

			minimizeButton.Text = "□"
		else
			UICornerStrokeLib.CreateTween(mainFrame, {
				Size = originalSize
			}, 0.2)

			minimizeButton.Text = "–"
		end

		isMinimized = not isMinimized
	end)

	minimizeButton.Parent = titleBar

	local sidePanel = UICornerStrokeLib.CreateElement("Frame", {
		Size = UDim2.new(0, 160, 1, -42),
		Position = UDim2.new(0, 0, 0, 42),
		BackgroundColor3 = theme.PrimaryColor,
		ZIndex = theme.ZIndex.Container,
		ClipsDescendants = true,
		AutoLayout = false
	})

	UICornerStrokeLib.ApplyStyle(sidePanel, {
		StrokeColor = theme.SecondaryColor,
		BackgroundTransparency = 0.1,
	
	})
	sidePanel.Parent = mainFrame


	local tabButtons = UICornerStrokeLib.CreateElement("ScrollingFrame", {
		Size = UDim2.new(1, -theme.Spacing.SidePanelPadding * 2, 1, -theme.Spacing.SidePanelPadding * 2),
		Position = UDim2.new(0, theme.Spacing.SidePanelPadding, 0, theme.Spacing.SidePanelPadding),
		BackgroundTransparency = 1,
		ScrollBarThickness = 4,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = theme.ZIndex.Container + 1,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarImageColor3 = theme.AccentColor,
		ScrollBarImageTransparency = 0.7,
		AutoLayout = true
	})

	local tabLayout = UICornerStrokeLib.CreateElement("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		AutoLayout = false
	})

	tabLayout.Parent = tabButtons
	tabButtons.Parent = sidePanel

	local tabContainer = UICornerStrokeLib.CreateElement("Frame", {
		Size = UDim2.new(1, -170, 1, -52),
		Position = UDim2.new(0, 160, 0, 42),
		BackgroundTransparency = 1,
		ZIndex = theme.ZIndex.Container,
		ClipsDescendants = true,
		AutoLayout = false
	})
	tabContainer.Parent = mainFrame

	local window = {
		Gui = gui,
		Tabs = {},
		CurrentTab = nil,
		MainFrame = mainFrame,
		Theme = deepCopy(theme)
	}

	function window:AddTab(tabName, tabIcon)
		local btn = UICornerStrokeLib.CreateElement("TextButton", {
			Size = UDim2.new(1, -12, 0, 38),
			BackgroundColor3 = theme.PrimaryColor,
			Text = "",
			TextColor3 = theme.TextColor,
			Font = theme.FontButton,
			TextSize = theme.ButtonTextSize,
			LayoutOrder = #self.Tabs + 1,
			AutoButtonColor = false,
			ZIndex = theme.ZIndex.Container + 2,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoLayout = false
		})

		UICornerStrokeLib.ApplyStyle(btn, {
			StrokeColor = theme.SecondaryColor,
			BackgroundTransparency = 0.2
		})

		local content = UICornerStrokeLib.CreateElement("Frame", {
			Size = UDim2.new(1, -20, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			ZIndex = btn.ZIndex + 1,
			AutoLayout = false
		})

		local layout = UICornerStrokeLib.CreateElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			AutoLayout = false
		})
		layout.Parent = content

		if tabIcon then
			local icon = UICornerStrokeLib.CreateElement("ImageLabel", {
				Size = UDim2.new(0, 20, 0, 20),
				BackgroundTransparency = 1,
				Image = tabIcon,
				LayoutOrder = 1,
				ZIndex = content.ZIndex + 1,
				AutoLayout = false
			})
			icon.Parent = content
		end

		local textLabel = UICornerStrokeLib.CreateElement("TextLabel", {
			Size = UDim2.new(1, -28, 1, 0), 
			Text = tabName,
			TextWrapped = true,
			TextColor3 = theme.TextColor,
			Font = theme.FontButton,
			TextSize = theme.ButtonTextSize,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 2,
			ZIndex = content.ZIndex + 1,
			AutoLayout = false
		})
		textLabel.Parent = content

		content.Parent = btn
		local originalBg = btn.BackgroundColor3
		local originalText = btn.TextColor3

		btn.MouseEnter:Connect(function()
			UICornerStrokeLib.CreateTween(btn, {
				BackgroundColor3 = originalBg:lerp(theme.AccentColor, 0.15),
				TextColor3 = theme.TextColor:lerp(Color3.new(1,1,1), 0.15)
			}, 0.15)
		end)

		btn.MouseLeave:Connect(function()
			if window.CurrentTab and window.CurrentTab.Button ~= btn then
				UICornerStrokeLib.CreateTween(btn, {
					BackgroundColor3 = originalBg,
					TextColor3 = originalText
				}, 0.15)
			end
		end)

		local content = UICornerStrokeLib.CreateElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible = false,
			ScrollBarThickness = 6,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ZIndex = theme.ZIndex.Content,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarImageColor3 = theme.AccentColor,
			ScrollBarImageTransparency = 0.7,
			AutoLayout = true
		})

		local contentLayout = UICornerStrokeLib.CreateElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, theme.Spacing.Padding),
			AutoLayout = false
		})

		local contentPadding = UICornerStrokeLib.CreateElement("UIPadding", {
			PaddingLeft = UDim.new(0, theme.Spacing.Padding),
			PaddingRight = UDim.new(0, theme.Spacing.Padding),
			PaddingTop = UDim.new(0, theme.Spacing.Padding),
			PaddingBottom = UDim.new(0, theme.Spacing.Padding),
			AutoLayout = false
		})

		contentLayout.Parent = content
		contentPadding.Parent = content
		content.Parent = tabContainer
		local tabContent = UICornerStrokeLib.CreateElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible = false,
			ScrollBarThickness = 6,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ZIndex = theme.ZIndex.Content,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarImageColor3 = theme.AccentColor,
			ScrollBarImageTransparency = 0.7,
			AutoLayout = true
		})
		local defaultSection = UICornerStrokeLib.CreateSection(content, {
			Size = UDim2.new(1, -24, 0, 0),
			Title = tabName.." Settings",
			NoLayout = true
		})

		local tab = { 
			Button = btn, 
			Content = content,
			Name = tabName,
			Elements = {},
			DefaultSection = defaultSection
		}
		table.insert(self.Tabs, tab)

		btn.MouseButton1Click:Connect(function()
			if window.CurrentTab then
				window.CurrentTab.Content.Visible = false
				UICornerStrokeLib.CreateTween(window.CurrentTab.Button, {
					BackgroundColor3 = originalBg,
					TextColor3 = originalText
				}, 0.15)
			end

			window.CurrentTab = tab
			UICornerStrokeLib.CreateTween(btn, {
				BackgroundColor3 = theme.AccentColor,
				TextColor3 = Color3.new(1,1,1)
			}, 0.15)
			content.Visible = true
		end)

		if #self.Tabs == 1 then
			window.CurrentTab = tab
			content.Visible = true
			btn.BackgroundColor3 = theme.AccentColor
			btn.TextColor3 = Color3.new(1,1,1)
		end

		btn.Parent = tabButtons

		function tab:AddSection(settings)
			return UICornerStrokeLib.CreateSection(content, settings)
		end

		function tab:AddElement(elementType, elementSettings)
			return self.DefaultSection:AddElement(elementType, elementSettings)
		end

		return tab
	end


	function UICornerStrokeLib.SetTheme(newTheme)
		for k, v in pairs(newTheme) do
			if type(v) == "table" then
				theme[k] = theme[k] or {}
				for k2, v2 in pairs(v) do
					theme[k][k2] = v2
				end
			else
				theme[k] = v
			end
		end

		notifyThemeChange() 
	end

	function window:Resize(newSize)
		UICornerStrokeLib.CreateTween(self.MainFrame, {
			Size = newSize
		}, 0.2)
	end
	if settings.IncludeThemeEditor then
		UICornerStrokeLib.CreateThemeEditor(window)
	end
	return window
end

--[[
    ===========================================
    UI COMPONENTS (Updated to work with sections)
    ===========================================
--]]

function UICornerStrokeLib.CreateSlider(parent, settings)
    settings = settings or {}


    local sliderFrame = UICornerStrokeLib.CreateElement("Frame", {
        Size = UDim2.new(1, -24, 0, 60),
        BackgroundColor3 = theme.PrimaryColor,
        BackgroundTransparency = 0.95,
        LayoutOrder = settings.LayoutOrder,
        ZIndex = theme.ZIndex.Content,
        AutoLayout = false
    })
    UICornerStrokeLib.ApplyStyle(sliderFrame, {
        CornerRadius = theme.CornerRadius,
        StrokeColor = theme.SecondaryColor,
        StrokeTransparency = 0.8
    })


    local padding = UICornerStrokeLib.CreateElement("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        AutoLayout = false
    })
    padding.Parent = sliderFrame

    local topRow = UICornerStrokeLib.CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        ZIndex = sliderFrame.ZIndex + 1,
        AutoLayout = false
    })

    local rowLayout = UICornerStrokeLib.CreateElement("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        AutoLayout = false
    })
    rowLayout.Parent = topRow

    local label = UICornerStrokeLib.CreateElement("TextLabel", {
        Size = UDim2.new(0.6, -10, 1, 0),
        Text = settings.Text or "Slider",
        TextColor3 = theme.TextColor,
        Font = theme.FontContent,
        TextSize = theme.ContentTextSize,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = topRow.ZIndex + 1,
        AutoLayout = false
    })
    label.Parent = topRow

    local valueLabel = UICornerStrokeLib.CreateElement("TextLabel", {
        Size = UDim2.new(0.4, -10, 1, 0),
        Text = tostring(settings.Default or 0),
        TextColor3 = theme.TextColor,
        Font = theme.FontContent,
        TextSize = theme.ContentTextSize,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = topRow.ZIndex + 1,
        AutoLayout = false
    })
    valueLabel.Parent = topRow
    topRow.Parent = sliderFrame

    local track = UICornerStrokeLib.CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = theme.SecondaryColor,
        ZIndex = sliderFrame.ZIndex + 1,
        AutoLayout = false
    })
    UICornerStrokeLib.ApplyStyle(track, {
        CornerRadius = UDim.new(1, 0),
        BackgroundTransparency = theme.Transparency.SliderTrack
    })
    track.Parent = sliderFrame

    local fill = UICornerStrokeLib.CreateElement("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = theme.AccentColor,
        ZIndex = track.ZIndex + 1,
        AutoLayout = false
    })
    UICornerStrokeLib.ApplyStyle(fill, {
        CornerRadius = UDim.new(1, 0)
    })
    fill.Parent = track

    local thumb = UICornerStrokeLib.CreateElement("TextButton", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, -10, 0, -7),
        BackgroundColor3 = Color3.new(1,1,1),
        Text = "",
        AutoButtonColor = false,
        ZIndex = fill.ZIndex + 1,
        AutoLayout = false
    })
    UICornerStrokeLib.ApplyStyle(thumb, {
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        StrokeColor = theme.AccentColor
    })
    thumb.Parent = track

    local min = settings.Min or 0
    local max = settings.Max or 100
    local step = settings.Step or 1
    local currentValue = settings.Default or min
    local dragging = false

    local function updateValue(newValue)
        local steppedValue = math.floor((newValue - min)/step + 0.5)*step + min
        currentValue = math.clamp(steppedValue, min, max)
        local ratio = (currentValue - min)/(max - min)

        fill.Size = UDim2.new(ratio, 0, 1, 0)
        thumb.Position = UDim2.new(ratio, -10, 0, -7)
        valueLabel.Text = tostring(math.floor(currentValue))

        if settings.OnChange then
            settings.OnChange(currentValue)
        end
    end

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local mousePos = UserInputService:GetMouseLocation()
            local trackPos = track.AbsolutePosition
            local xOffset = math.clamp(mousePos.X - trackPos.X, 0, track.AbsoluteSize.X)
            local ratio = xOffset/track.AbsoluteSize.X
            updateValue(min + (max - min)*ratio)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local trackPos = track.AbsolutePosition
            local xOffset = math.clamp(mousePos.X - trackPos.X, 0, track.AbsoluteSize.X)
            local ratio = xOffset/track.AbsoluteSize.X
            updateValue(min + (max - min)*ratio)
        end
    end)

    sliderFrame.Parent = parent
    updateValue(currentValue)

    return {
        Frame = sliderFrame,
        SetValue = updateValue,
        GetValue = function() return currentValue end
    }
end



function UICornerStrokeLib.CreateDropdown(parent, settings)
	settings = settings or {}

	local dropdownContainer = UICornerStrokeLib.CreateElement("Frame", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 1,
		LayoutOrder = settings.LayoutOrder or 1,
		ZIndex = theme.ZIndex.Content,
		ClipsDescendants = true,
		AutoLayout = false
	})

	local dropdownButton = UICornerStrokeLib.CreateElement("TextButton", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = theme.PrimaryColor,
		Text = settings.Default or "Select an option",
		TextColor3 = theme.TextColor,
		Font = theme.FontContent,
		TextSize = theme.ContentTextSize,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
		ZIndex = theme.ZIndex.Content + 1,
		AutoLayout = false
	})

	UICornerStrokeLib.ApplyStyle(dropdownButton, {
		BackgroundTransparency = 0.2,
		StrokeColor = theme.SecondaryColor
	})

	local buttonPadding = UICornerStrokeLib.CreateElement("UIPadding", {
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		AutoLayout = false
	})
	buttonPadding.Parent = dropdownButton

	local chevron = UICornerStrokeLib.CreateElement("ImageLabel", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(1, -24, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3926305904",
		ImageRectOffset = Vector2.new(284, 4),
		ImageRectSize = Vector2.new(24, 24),
		ImageColor3 = theme.TextColor,
		ZIndex = dropdownButton.ZIndex + 1,
		AutoLayout = false
	})
	chevron.Parent = dropdownButton

	local optionsFrame = UICornerStrokeLib.CreateElement("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = theme.PrimaryColor,
		Visible = false,
		ZIndex = theme.ZIndex.Dropdown + 10, 
		ClipsDescendants = true,
		AutoLayout = false
	})

	UICornerStrokeLib.ApplyStyle(optionsFrame, {
		BackgroundTransparency = theme.Transparency.Dropdown,
		StrokeColor = theme.SecondaryColor
	})

	local scrollFrame = UICornerStrokeLib.CreateElement("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarImageColor3 = theme.AccentColor,
		ScrollBarImageTransparency = 0.7,
		ZIndex = optionsFrame.ZIndex + 1,
		AutoLayout = false
	})

	local optionsLayout = UICornerStrokeLib.CreateElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		AutoLayout = false
	})
	optionsLayout.Parent = scrollFrame

	local optionsPadding = UICornerStrokeLib.CreateElement("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		AutoLayout = false
	})
	optionsPadding.Parent = scrollFrame

	scrollFrame.Parent = optionsFrame
	optionsFrame.Parent = dropdownContainer
	dropdownButton.Parent = dropdownContainer

	local isOpen = false
	local selectedOption = settings.Default
	local options = settings.Options or {}
	local optionButtons = {}

	local function toggleDropdown()
		isOpen = not isOpen

		if isOpen then
			dropdownContainer.ZIndex = theme.ZIndex.Dropdown + 200
			optionsFrame.Visible = true
			UICornerStrokeLib.CreateTween(chevron, {Rotation = 180}, 0.15)
			UICornerStrokeLib.CreateTween(optionsFrame, {
				Size = UDim2.new(1, 0, 0, math.min(#options * 32 + 8, 200))
			}, 0.2)
		else
			UICornerStrokeLib.CreateTween(chevron, {Rotation = 0}, 0.15)
			UICornerStrokeLib.CreateTween(optionsFrame, {
				Size = UDim2.new(1, 0, 0, 0)
			}, 0.2).Completed:Connect(function()
				optionsFrame.Visible = false
				dropdownContainer.ZIndex = theme.ZIndex.Content
			end)
		end
	end

	local function selectOption(option)
		selectedOption = option
		dropdownButton.Text = option

		for _, btn in pairs(optionButtons) do
			if btn.Text == option then
				UICornerStrokeLib.CreateTween(btn, {
					BackgroundColor3 = theme.AccentColor,
					TextColor3 = Color3.new(1, 1, 1)
				}, 0.1)
			else
				UICornerStrokeLib.CreateTween(btn, {
					BackgroundColor3 = theme.PrimaryColor,
					TextColor3 = theme.TextColor
				}, 0.1)
			end
		end

		if settings.OnSelect then
			settings.OnSelect(option)
		end

		toggleDropdown()
	end

	local function createOptions()
		for _, btn in pairs(optionButtons) do
			btn:Destroy()
		end
		optionButtons = {}

		for i, option in ipairs(options) do
			local optionButton = UICornerStrokeLib.CreateElement("TextButton", {
				Size = UDim2.new(1, -8, 0, 30),
				BackgroundColor3 = theme.PrimaryColor,
				Text = option,
				TextColor3 = theme.TextColor,
				Font = theme.FontContent,
				TextSize = theme.ContentTextSize - 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutoButtonColor = false,
				LayoutOrder = i,
				ZIndex = scrollFrame.ZIndex + 1,
				AutoLayout = false
			})

			UICornerStrokeLib.ApplyStyle(optionButton, {
				BackgroundTransparency = 0.2,
				StrokeColor = theme.SecondaryColor
			})

			local optionPadding = UICornerStrokeLib.CreateElement("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				AutoLayout = false
			})
			optionPadding.Parent = optionButton

			if option == selectedOption then
				optionButton.BackgroundColor3 = theme.AccentColor
				optionButton.TextColor3 = Color3.new(1, 1, 1)
			end

			optionButton.MouseEnter:Connect(function()
				if optionButton.Text ~= selectedOption then
					UICornerStrokeLib.CreateTween(optionButton, {
						BackgroundColor3 = theme.PrimaryColor:lerp(theme.AccentColor, 0.3),
						TextColor3 = theme.TextColor:lerp(Color3.new(1, 1, 1), 0.3)
					}, 0.1)
				end
			end)

			optionButton.MouseLeave:Connect(function()
				if optionButton.Text ~= selectedOption then
					UICornerStrokeLib.CreateTween(optionButton, {
						BackgroundColor3 = theme.PrimaryColor,
						TextColor3 = theme.TextColor
					}, 0.1)
				end
			end)

			optionButton.MouseButton1Click:Connect(function()
				selectOption(option)
			end)

			optionButton.Parent = scrollFrame
			table.insert(optionButtons, optionButton)
		end
	end

	createOptions()

	dropdownButton.MouseButton1Click:Connect(toggleDropdown)

	dropdownButton.MouseEnter:Connect(function()
		UICornerStrokeLib.CreateTween(dropdownButton, {
			BackgroundColor3 = theme.PrimaryColor:lerp(theme.AccentColor, 0.1)
		}, 0.15)
	end)

	dropdownButton.MouseLeave:Connect(function()
		UICornerStrokeLib.CreateTween(dropdownButton, {
			BackgroundColor3 = theme.PrimaryColor
		}, 0.15)
	end)

	local function handleClickOutside(input)
		if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mousePos = input.Position
			local absolutePos = dropdownContainer.AbsolutePosition
			local absoluteSize = dropdownContainer.AbsoluteSize

			if not (mousePos.X >= absolutePos.X and mousePos.X <= absolutePos.X + absoluteSize.X and
				mousePos.Y >= absolutePos.Y and mousePos.Y <= absolutePos.Y + absoluteSize.Y + (isOpen and optionsFrame.AbsoluteSize.Y or 0)) then
				toggleDropdown()
			end
		end
	end

	UserInputService.InputBegan:Connect(handleClickOutside)

	local listenerId = UICornerStrokeLib.RegisterThemeListener(function(newTheme)
		dropdownButton.BackgroundColor3 = newTheme.PrimaryColor
		dropdownButton.TextColor3 = newTheme.TextColor
		optionsFrame.BackgroundColor3 = newTheme.PrimaryColor

		for _, btn in pairs(optionButtons) do
			if btn.Text == selectedOption then
				btn.BackgroundColor3 = newTheme.AccentColor
				btn.TextColor3 = Color3.new(1, 1, 1)
			else
				btn.BackgroundColor3 = newTheme.PrimaryColor
				btn.TextColor3 = newTheme.TextColor
			end
		end
	end)

	dropdownContainer.AncestryChanged:Connect(function()
		if not dropdownContainer:IsDescendantOf(game) then
			UICornerStrokeLib.UnregisterThemeListener(listenerId)
		end
	end)

	dropdownContainer.Parent = parent

	return {
		Container = dropdownContainer,
		Button = dropdownButton,
		OptionsFrame = optionsFrame,

		SetOptions = function(self, newOptions)
			options = newOptions or {}
			createOptions()
			if not table.find(options, selectedOption) then
				selectedOption = #options > 0 and options[1] or "Select an option"
				dropdownButton.Text = selectedOption
			end
		end,

		GetSelected = function(self)
			return selectedOption
		end,

		SetSelected = function(self, option)
			if table.find(options, option) then
				selectOption(option)
			end
		end,

		IsOpen = function(self)
			return isOpen
		end,

		Close = function(self)
			if isOpen then
				toggleDropdown()
			end
		end,

		Open = function(self)
			if not isOpen then
				toggleDropdown()
			end
		end
	}
end

function UICornerStrokeLib.CreateToggle(parent, settings)
	settings = settings or {}

	local container = UICornerStrokeLib.CreateElement("Frame", {
		Size = UDim2.new(1, -24, 0, 38), 
		BackgroundColor3 = theme.PrimaryColor,
		BackgroundTransparency = 0.95,
		LayoutOrder = settings.LayoutOrder,
		ZIndex = theme.ZIndex.Content,
		AutoLayout = false
	})
	UICornerStrokeLib.ApplyStyle(container, {
		CornerRadius = theme.CornerRadius,
		StrokeColor = theme.SecondaryColor,
		StrokeTransparency = 0.8
	})

	local layout = UICornerStrokeLib.CreateElement("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
		AutoLayout = false
	})
	layout.Parent = container

	local padding = UICornerStrokeLib.CreateElement("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		AutoLayout = false
	})
	padding.Parent = container

	-- Label (now appears first in the horizontal flow)
	local label = UICornerStrokeLib.CreateElement("TextButton", {
		Size = UDim2.new(0, 0, 1, 0),  
		AutomaticSize = Enum.AutomaticSize.X,  
		Text = settings.Text or "Toggle",
		TextColor3 = theme.TextColor,
		Font = theme.FontContent,
		TextSize = theme.ContentTextSize,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
		ZIndex = container.ZIndex + 1,
		AutoLayout = false
	})
	label.Parent = container

	local switchFrame = UICornerStrokeLib.CreateElement("TextButton", {
		Size = UDim2.new(0, 50, 0, 26),
		BackgroundColor3 = theme.SecondaryColor,
		Text = "",
		AutoButtonColor = false,
		ZIndex = container.ZIndex + 1,
		AutoLayout = false
	})
	UICornerStrokeLib.ApplyStyle(switchFrame, {
		CornerRadius = UDim.new(1, 0),
		BackgroundTransparency = theme.Transparency.SliderTrack
	})

	local switchButton = UICornerStrokeLib.CreateElement("TextButton", {
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(0, 3, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.new(1,1,1),
		Text = "",
		AutoButtonColor = false,
		ZIndex = switchFrame.ZIndex + 1,
		AutoLayout = false
	})
	UICornerStrokeLib.ApplyStyle(switchButton, {
		CornerRadius = UDim.new(1, 0),
		StrokeThickness = 2,
		StrokeColor = theme.SecondaryColor
	})
	switchButton.Parent = switchFrame

	local state = settings.Default or false

	local function updateToggle()
		state = not state
		local targetPos = state and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
		local targetColor = state and theme.SuccessColor or Color3.new(1,1,1)
		local frameColor = state and theme.SuccessColor:Lerp(theme.SecondaryColor, 0.3) or theme.SecondaryColor

		UICornerStrokeLib.CreateTween(switchButton, {
			Position = targetPos,
			BackgroundColor3 = targetColor
		}, 0.15)

		UICornerStrokeLib.CreateTween(switchFrame, {
			BackgroundColor3 = frameColor
		}, 0.15)

		if settings.OnToggle then
			settings.OnToggle(state)
		end
	end

	if state then
		switchButton.Position = UDim2.new(1, -23, 0.5, 0)
		switchButton.BackgroundColor3 = theme.SuccessColor
		switchFrame.BackgroundColor3 = theme.SuccessColor:Lerp(theme.SecondaryColor, 0.3)
	end


	label.MouseButton1Click:Connect(updateToggle)
	switchFrame.MouseButton1Click:Connect(updateToggle)
	switchButton.MouseButton1Click:Connect(updateToggle)

	switchFrame.Parent = container
	container.Parent = parent

	return {
		Frame = container,
		SetState = function(self, newState)
			if state ~= newState then updateToggle() end
		end,
		GetState = function() return state end
	}
end
function UICornerStrokeLib.CreateButton(parent, settings)
	settings = settings or {}

	local btn = UICornerStrokeLib.CreateElement("TextButton", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = theme.PrimaryColor,
		Text = settings.Text or "Button",
		TextColor3 = theme.TextColor,
		Font = theme.FontButton,
		TextSize = theme.ButtonTextSize,
		LayoutOrder = settings.LayoutOrder or 1,
		AutoButtonColor = false,
		ZIndex = theme.ZIndex.Content + 1,
		AutoLayout = false
	})

	UICornerStrokeLib.ApplyStyle(btn, {
		StrokeColor = theme.SecondaryColor,
		BackgroundTransparency = 0.2
	})

	local originalBg = btn.BackgroundColor3
	local originalText = btn.TextColor3
	
	local function updateButtonAppearance()
		btn.BackgroundColor3 = originalBg
		btn.TextColor3 = originalText
		UICornerStrokeLib.ApplyStyle(btn, {
			StrokeColor = theme.SecondaryColor,
			BackgroundTransparency = 0.2
		})
	end
	local listenerId = UICornerStrokeLib.RegisterThemeListener(function(newTheme)
		updateButtonAppearance()
	end)
	
	btn.AncestryChanged:Connect(function()
		if not btn:IsDescendantOf(game) then
			UICornerStrokeLib.UnregisterThemeListener(listenerId)
		end
	end)
	

	btn.MouseEnter:Connect(function()
		UICornerStrokeLib.CreateTween(btn, {
			BackgroundColor3 = originalBg:lerp(theme.AccentColor, 0.2),
			TextColor3 = theme.TextColor:lerp(Color3.new(1,1,1), 0.2)
		}, 0.15)
	end)

	btn.MouseLeave:Connect(function()
		UICornerStrokeLib.CreateTween(btn, {
			BackgroundColor3 = originalBg,
			TextColor3 = theme.TextColor
		}, 0.15)
	end)

	btn.MouseButton1Down:Connect(function()
		UICornerStrokeLib.CreateTween(btn, {
			BackgroundColor3 = originalBg:lerp(theme.AccentColor, 0.4),
			TextColor3 = Color3.new(1,1,1)
		}, 0.1)
	end)

	btn.MouseButton1Up:Connect(function()
		UICornerStrokeLib.CreateTween(btn, {
			BackgroundColor3 = originalBg:lerp(theme.AccentColor, 0.2),
			TextColor3 = theme.TextColor:lerp(Color3.new(1,1,1), 0.2)
		}, 0.1)
	end)

	if settings.OnClick then 
		btn.MouseButton1Click:Connect(function()
			settings.OnClick()
		end) 
	end

	btn.Parent = parent

	local buttonObj = {
		Button = btn,
		SetText = function(self, text)
			btn.Text = text
		end,
		SetDisabled = function(self, disabled)
			btn.Active = not disabled
			btn.TextTransparency = disabled and 0.5 or 0
			btn.BackgroundTransparency = disabled and 0.5 or 0.2
		end
	}

	return buttonObj
end

function UICornerStrokeLib.CreateLabel(parent, settings)
	settings = settings or {}

	local label = UICornerStrokeLib.CreateElement("TextLabel", {
		Size = UDim2.new(1, 0, 0, settings.Height or 20),
		Text = settings.Text or "Label",
		TextColor3 = theme.TextColor,
		Font = theme.FontContent,
		TextSize = theme.ContentTextSize,
		BackgroundTransparency = 1,
		TextXAlignment = settings.Alignment or Enum.TextXAlignment.Left,
		TextYAlignment = settings.VerticalAlignment or Enum.TextYAlignment.Center,
		LayoutOrder = settings.LayoutOrder or 1,
		ZIndex = theme.ZIndex.Content + 1,
		AutoLayout = false
	})

	if settings.RichText then
		label.RichText = true
	end

	if settings.TextWrapped then
		label.TextWrapped = true
		label.AutomaticSize = Enum.AutomaticSize.Y
	end

	label.Parent = parent

	local labelObj = {
		Label = label,
		SetText = function(self, text)
			label.Text = text
		end,
		SetColor = function(self, color)
			label.TextColor3 = color
		end
	}

	return labelObj
end

function UICornerStrokeLib.CreateThemeEditor(window)
	local editorTab = window:AddTab("Theme Editor")
	local section = editorTab:AddSection({Title = "Color Customization", Size = UDim2.new(1, -24, 0, 800)})

	local colorProperties = {
		"BackgroundColor", "PrimaryColor", "SecondaryColor", "TextColor", 
		"AccentColor", "SuccessColor", "WarningColor", "ErrorColor"
	}


	local previewFrames = {}

	for i, colorName in ipairs(colorProperties) do
		section:AddElement("Label", {
			Text = colorName,
			LayoutOrder = i * 4 - 3
		})

		local defaultColor = theme[colorName] or Color3.new(1, 1, 1)
		local r, g, b = math.floor(defaultColor.R * 255), math.floor(defaultColor.G * 255), math.floor(defaultColor.B * 255)

		local preview = UICornerStrokeLib.CreateElement("Frame", {
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundColor3 = defaultColor,
			LayoutOrder = i * 4 - 2,
			ZIndex = theme.ZIndex.Content + 1
		})
		UICornerStrokeLib.ApplyStyle(preview, {
			CornerRadius = theme.CornerRadius
		})
		preview.Parent = section.Frame
		previewFrames[colorName] = preview

		local function updateColor()
			local newColor = Color3.fromRGB(r, g, b)
			preview.BackgroundColor3 = newColor

			local update = {}
			update[colorName] = newColor

			for k, v in pairs(update) do
				if type(v) == "table" then
					theme[k] = theme[k] or {}
					for k2, v2 in pairs(v) do
						theme[k][k2] = v2
					end
				else
					theme[k] = v
				end
			end

			notifyThemeChange()
		end

		local rSlider = UICornerStrokeLib.CreateSlider(section.Frame, {
			Text = "R",
			Min = 0, 
			Max = 255, 
			Step = 1, 
			Default = r,
			LayoutOrder = i * 4 - 1,
			OnChange = function(value)
				r = value
				updateColor()
			end
		})

		local gSlider = UICornerStrokeLib.CreateSlider(section.Frame, {
			Text = "G",
			Min = 0, 
			Max = 255, 
			Step = 1, 
			Default = g,
			LayoutOrder = i * 4,
			OnChange = function(value)
				g = value
				updateColor()
			end
		})

		local bSlider = UICornerStrokeLib.CreateSlider(section.Frame, {
			Text = "B",
			Min = 0, 
			Max = 255, 
			Step = 1, 
			Default = b,
			LayoutOrder = i * 4 + 1,
			OnChange = function(value)
				b = value
				updateColor()
			end
		})
	end

	local numericSection = editorTab:AddSection({Title = "Numeric Values", Size = UDim2.new(1, -24, 0, 200)})

	numericSection:AddElement("Slider", {
		Text = "Corner Radius",
		Min = 0,
		Max = 20,
		Step = 1,
		Default = theme.CornerRadius.Offset,
		OnChange = function(value)
			UICornerStrokeLib.SetTheme({
				CornerRadius = UDim.new(0, value)
			})
		end
	})

	numericSection:AddElement("Slider", {
		Text = "Stroke Thickness",
		Min = 0,
		Max = 5,
		Step = 0.1,
		Default = theme.StrokeThickness,
		OnChange = function(value)
			UICornerStrokeLib.SetTheme({
				StrokeThickness = value
			})
		end
	})

	local actionsSection = editorTab:AddSection({Title = "Actions", Size = UDim2.new(1, -24, 0, 60)})

	actionsSection:AddElement("Button", {
		Text = "Reset to Default Theme",
		OnClick = function()
			UICornerStrokeLib.ResetTheme()
			for colorName, preview in pairs(previewFrames) do
				preview.BackgroundColor3 = defaultTheme[colorName]
			end
		end
	})
end

function UICornerStrokeLib.CreateInput(parent, settings)
	settings = settings or {}

	local inputContainer = UICornerStrokeLib.CreateElement("Frame", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 1,
		LayoutOrder = settings.LayoutOrder or 1,
		ZIndex = theme.ZIndex.Content,
		AutoLayout = false
	})

	local inputFrame = UICornerStrokeLib.CreateElement("TextBox", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = theme.PrimaryColor,
		Text = settings.Text or "",
		TextColor3 = theme.TextColor,
		Font = theme.FontContent,
		TextSize = theme.ContentTextSize,
		PlaceholderText = settings.Placeholder or "",
		PlaceholderColor3 = theme.TextColor:lerp(theme.BackgroundColor, 0.5),
		ClearTextOnFocus = settings.ClearOnFocus or false,
		ZIndex = theme.ZIndex.Content + 1,
		AutoLayout = false
	})

	UICornerStrokeLib.ApplyStyle(inputFrame, {
		BackgroundTransparency = 0.2
	})

	local padding = UICornerStrokeLib.CreateElement("UIPadding", {
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		AutoLayout = false
	})
	padding.Parent = inputFrame

	inputFrame.Focused:Connect(function()
		UICornerStrokeLib.CreateTween(inputFrame, {
			BackgroundColor3 = theme.PrimaryColor:lerp(theme.AccentColor, 0.1)
		}, 0.1)
	end)

	inputFrame.FocusLost:Connect(function()
		UICornerStrokeLib.CreateTween(inputFrame, {
			BackgroundColor3 = theme.PrimaryColor
		}, 0.1)

		if settings.OnFocusLost then
			settings.OnFocusLost(inputFrame.Text)
		end
	end)

	if settings.OnTextChanged then
		inputFrame:GetPropertyChangedSignal("Text"):Connect(function()
			settings.OnTextChanged(inputFrame.Text)
		end)
	end

	inputFrame.Parent = inputContainer
	inputContainer.Parent = parent

	local inputObj = {
		Container = inputContainer,
		Input = inputFrame,
		SetText = function(self, text)
			inputFrame.Text = text
		end,
		GetText = function(self)
			return inputFrame.Text
		end
	}

	return inputObj
end

--[[
    ===========================================
    UTILITY FUNCTIONS
    ===========================================
--]]

function UICornerStrokeLib.CreateTween(target, properties, duration)
	if not theme.EnableAnimations then
		for prop, value in pairs(properties) do
			target[prop] = value
		end
		return {
			Completed = {
				Connect = function() end
			}
		}
	end

	local tweenInfo = TweenInfo.new(
		duration or theme.TransitionSpeed,
		theme.AnimationEasing,
		theme.AnimationDirection
	)
	local tween = TweenService:Create(target, tweenInfo, properties)
	tween:Play()
	return tween
end

--[[
    ===========================================
    THEME MANAGEMENT
    ===========================================
--]]

function UICornerStrokeLib.SetTheme(newTheme)
	for k, v in pairs(newTheme) do
		if type(v) == "table" then
			theme[k] = theme[k] or {}
			for k2, v2 in pairs(v) do
				theme[k][k2] = v2
			end
		else
			theme[k] = v
		end
	end

	notifyThemeChange()
end

function UICornerStrokeLib.GetTheme()
	return deepCopy(theme)
end

function UICornerStrokeLib.ResetTheme()
	theme = table.clone(defaultTheme)
end

--[[
    ===========================================
    MODULE EXPORTS
    ===========================================
--]]

UICornerStrokeLib.theme = theme
return UICornerStrokeLib
