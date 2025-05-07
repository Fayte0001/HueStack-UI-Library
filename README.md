<p align="center">
  <h1 align="center">HueStack UI Library</h1>
  <p align="center">A modern, customizable UI component library for Roblox experiences</p>
  <p align="center">
    <img src="https://img.shields.io/badge/Roblox-Compatible-brightgreen" alt="Roblox Compatible">
    <img src="https://img.shields.io/badge/License-MIT-blue" alt="License">
    <img src="https://img.shields.io/badge/Version-1.0.0-orange" alt="Version">
  </p>
</p>

## ✨ Features

- **🎨 Fully Customizable** - Comprehensive theming system with a live preview editor
- **⚡ High Performance** - Optimized animations and rendering for smooth experience
- **📱 Responsive Design** - Adapts seamlessly to different screen sizes and orientations
- **🧩 Clean, Intuitive API** - Well-documented and easy to integrate components
- **🔄 Live Theming** - Real-time theme changes without reloading
- **📦 Modular Architecture** - Use only what you need

## 📋 Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Components](#components)
  - [Window](#window)
  - [Button](#button)
  - [Toggle](#toggle)
  - [Slider](#slider)
  - [Dropdown](#dropdown)
  - [Input](#input)
- [Theming](#theming)
- [API Reference](#api-reference)
- [Examples](#examples)
  - [Settings Panel](#settings-panel)
  - [Inventory UI](#inventory-ui)

## 🚀 Installation

Place the HueStack module in ReplicatedStorage:

```lua
-- Place the module in ReplicatedStorage
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HueStack = require(ReplicatedStorage:WaitForChild("HueStack"))
```

## 🏁 Quick Start

Create a simple UI with a window, tab, and toggle component:

```lua
-- Create a window
local window = HueStack.CreateWindow({
    Title = "My App",
    Size = UDim2.new(0, 500, 0, 400),
    IncludeThemeEditor = true
})

-- Add a tab
local mainTab = window:AddTab("Main")

-- Add a section to the tab
local settingsSection = mainTab:AddSection({
    Title = "Settings",
    Size = UDim2.new(1, -24, 0, 200)
})

-- Add components to the section
settingsSection:AddElement("Toggle", {
    Text = "Enable Feature",
    Default = true,
    OnToggle = function(state)
        print("Feature toggled:", state)
    end
})
```

## 🧩 Components

### Window

The main container for your UI with draggable, resizable, and minimizable capabilities.

```lua
local window = HueStack.CreateWindow({
    Title = "Window Title",
    Size = UDim2.new(0, 600, 0, 450),
    IncludeThemeEditor = true -- Optional
})
```

### Button

Interactive button with hover and click effects.

```lua
section:AddElement("Button", {
    Text = "Click Me",
    OnClick = function()
        print("Button clicked!")
    end
})
```

### Toggle

Switch component for boolean options.

```lua
section:AddElement("Toggle", {
    Text = "Enable Feature",
    Default = false,
    OnToggle = function(state)
        print("Toggle state:", state)
    end
})
```

### Slider

Range input for numeric values.

```lua
section:AddElement("Slider", {
    Text = "Volume",
    Min = 0,
    Max = 100,
    Step = 1,
    Default = 50,
    OnChange = function(value)
        print("Volume set to:", value)
    end
})
```

### Dropdown

Select component for choosing from multiple options.

```lua
section:AddElement("Dropdown", {
    Text = "Select Option",
    Default = "Option 1",
    Options = {"Option 1", "Option 2", "Option 3"},
    OnSelect = function(option)
        print("Selected:", option)
    end
})
```

### Input

Text input field for user text entry.

```lua
section:AddElement("Input", {
    Text = "Username",
    Placeholder = "Enter text...",
    OnFocusLost = function(text)
        print("User entered:", text)
    end
})
```

## 🎨 Theming

HueStack provides comprehensive theming capabilities with a built-in theme editor.

### Default Theme Structure

```lua
local defaultTheme = {
    -- Color scheme
    BackgroundColor = Color3.fromRGB(25, 25, 25),
    PrimaryColor = Color3.fromRGB(45, 45, 45),
    SecondaryColor = Color3.fromRGB(35, 35, 35),
    TextColor = Color3.fromRGB(240, 240, 240),
    AccentColor = Color3.fromRGB(100, 180, 255),
    
    -- Visual effects
    CornerRadius = UDim.new(0, 8),
    StrokeThickness = 1,
    
    -- Typography
    FontTitle = Enum.Font.GothamBold,
    FontButton = Enum.Font.GothamMedium,
    FontContent = Enum.Font.Gotham,
    
    -- Animation
    TransitionSpeed = 0.15
}
```

### Customizing the Theme

```lua
-- Change specific theme properties
HueStack.SetTheme({
    AccentColor = Color3.fromRGB(255, 120, 200),
    CornerRadius = UDim.new(0, 12)
})

-- Reset to default theme
HueStack.ResetTheme()

-- Get current theme
local currentTheme = HueStack.GetTheme()
```

### Theme Editor

When creating a window, you can include the theme editor:

```lua
local window = HueStack.CreateWindow({
    Title = "My App",
    IncludeThemeEditor = true
})
```

## 📘 API Reference

### Core Functions

| Function | Description | Parameters | Returns |
|----------|-------------|------------|---------|
| `CreateWindow(settings)` | Creates a new draggable window container | Table with window settings (Title, Size, etc.) | Window object |
| `SetTheme(newTheme)` | Updates the current theme with new properties | Table with theme overrides | None |
| `GetTheme()` | Returns the current theme | None | Theme table |
| `ResetTheme()` | Resets theme to default | None | None |

### Window Methods

| Method | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `window:AddTab(name, icon)` | Adds a new tab to the window | Tab name (string), icon (optional) | Tab object |
| `window:Minimize()` | Minimizes the window | None | None |
| `window:Maximize()` | Maximizes the window | None | None |
| `window:Close()` | Closes the window | None | None |

### Tab Methods

| Method | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `tab:AddSection(settings)` | Adds a section to the tab | Table with section settings | Section object |
| `tab:Select()` | Selects this tab | None | None |

### Section Methods

| Method | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `section:AddElement(type, settings)` | Adds a UI element to the section | Element type ("Button", "Toggle", etc.) and settings | Element object |
| `section:Clear()` | Removes all elements from the section | None | None |

## 💡 Examples

### Settings Panel

```lua
local window = HueStack.CreateWindow({
    Title = "Game Settings",
    Size = UDim2.new(0, 500, 0, 400)
})

local settingsTab = window:AddTab("Settings")

-- Graphics Section
local graphicsSection = settingsTab:AddSection({
    Title = "Graphics",
    Size = UDim2.new(1, -24, 0, 180)
})

graphicsSection:AddElement("Dropdown", {
    Text = "Quality Preset",
    Options = {"Low", "Medium", "High", "Ultra"},
    Default = "Medium",
    OnSelect = function(option)
        -- Set graphics quality
    end
})

graphicsSection:AddElement("Slider", {
    Text = "Render Distance",
    Min = 100,
    Max = 1000,
    Step = 50,
    Default = 500,
    OnChange = function(value)
        -- Update render distance
    end
})

-- Audio Section
local audioSection = settingsTab:AddSection({
    Title = "Audio",
    Size = UDim2.new(1, -24, 0, 120)
})

audioSection:AddElement("Slider", {
    Text = "Master Volume",
    Min = 0,
    Max = 100,
    Default = 80,
    OnChange = function(value)
        -- Update volume
    end
})
```

### Inventory UI

```lua
local window = HueStack.CreateWindow({
    Title = "Inventory",
    Size = UDim2.new(0, 600, 0, 450)
})

local inventoryTab = window:AddTab("Items")
local statsTab = window:AddTab("Stats")

-- Items grid
local itemsSection = inventoryTab:AddSection({
    Title = "Your Items",
    Size = UDim2.new(1, -24, 1, -50)
})

-- Stats display
local statsSection = statsTab:AddSection({
    Title = "Character Stats",
    Size = UDim2.new(1, -24, 0, 200)
})

statsSection:AddElement("Label", {
    Text = "Strength: 15",
    TextSize = 16
})

statsSection:AddElement("Label", {
    Text = "Agility: 22",
    TextSize = 16
})
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

If you have any questions or issues, please open an issue in the GitHub repository.

---

<p align="center">Made with ❤️ by Your Name</p>
