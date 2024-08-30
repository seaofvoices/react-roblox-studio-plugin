<div align="center">

[![checks](https://github.com/seaofvoices/react-roblox-studio-plugin/actions/workflows/test.yml/badge.svg)](https://github.com/seaofvoices/react-roblox-studio-plugin/actions/workflows/test.yml)
![version](https://img.shields.io/github/package-json/v/seaofvoices/react-roblox-studio-plugin)
[![GitHub top language](https://img.shields.io/github/languages/top/seaofvoices/react-roblox-studio-plugin)](https://github.com/luau-lang/luau)
![license](https://img.shields.io/npm/l/@seaofvoices/react-roblox-studio-plugin)
![npm](https://img.shields.io/npm/dt/@seaofvoices/react-roblox-studio-plugin)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/seaofvoices)

</div>

# react-roblox-studio-plugin

A component library to create Roblox Studio plugins using [react-lua](https://github.com/jsdotlua/react-lua).

- [Components](#components)
  - [Action](#action)
  - [Menu](#menu)
  - [RobloxPlugin](#robloxplugin)
  - [Toolbar](#toolbar)
  - [ToolbarButton](#toolbarbutton)
  - [Widget](#widget)
- [Hooks](#hooks)
  - [usePlugin](#useplugin)
  - [useWidgetKeyDown](#usewidgetkeydown)
  - [useWidgetFocus](#usewidgetfocus)
  - [useWidgetFocusLost](#usewidgetfocuslost)

## Installation

Add `@seaofvoices/react-roblox-studio-plugin` in your dependencies:

```bash
yarn add @seaofvoices/react-roblox-studio-plugin
```

Or if you are using `npm`:

```bash
npm install @seaofvoices/react-roblox-studio-plugin
```

## Components

- [Action](#action)
- [Menu](#menu)
- [RobloxPlugin](#robloxplugin)
- [Toolbar](#toolbar)
- [ToolbarButton](#toolbarbutton)
- [Widget](#widget)

### Action

The `Action` component creates and manages a [`PluginAction`](https://create.roblox.com/docs/reference/engine/classes/PluginAction). It can be used both under a [Menu](#menu) element and independently.

When used under a [Menu](#menu), the action will be attached to the managed [`PluginMenu`](https://create.roblox.com/docs/reference/engine/classes/PluginMenu).

#### Props

```lua
type Props = {
    triggered: () -> (),
    id: string,
    label: string,
    description: string,
    icon: string?,
    allowBinding: boolean?,
}
```

- `triggered`: Callback function to be called when the action is triggered.
- `id`: Unique identifier for the action.
- `label`: The text displayed for the action in menus or toolbars.
- `description`: A longer description of what the action does.
- `icon`: Optional asset ID for the action's icon.
- `allowBinding`: Optional boolean to allow key binding for the action (default: true).

#### Example

```lua
local React = require('@pkg/@jsdotlua/react')
local ReactRobloxStudioPlugin = require('@pkg/@seaofvoices/react-roblox-studio-plugin')
local Action = ReactRobloxStudioPlugin.Action

local function CustomAction()
    return React.createElement(Action, {
        id = "MyAction",
        label = "Action",
        description = "Performs action",
        triggered = function()
            print("Action triggered!")
        end
    })
end
```

### Menu

The `Menu` component creates and manages a [`PluginMenu`](https://create.roblox.com/docs/reference/engine/classes/PluginMenu). When `Action` elements are created under a menu, they automatically get attached to the closest `Menu`.

#### Props

```lua
type Props = {
    id: string,
    title: string,
    icon: string?,
    openMenu: Signal<()>,
}
```

- `id`: Unique identifier for the menu.
- `title`: The text displayed for the menu.
- `icon`: Optional asset ID for the menu's icon.
- `openMenu`: A Signal from [`luau-signal`](https://github.com/seaofvoices/luau-signal) that, when fired, will open the menu.

#### Example

This example creates a menu with one action. The menu can be opened manually by firing the `openMenuSignal`, which is connected to toggling a generated BoolValue.

```lua
local Signal = require('@pkg/luau-signal')
local useConstant = require('@pkg/@seaofvoices/react-lua-use-constant')
local ReactRobloxStudioPlugin = require('@pkg/@seaofvoices/react-roblox-studio-plugin')
local Menu = ReactRobloxStudioPlugin.Menu
local Action = ReactRobloxStudioPlugin.Action

local function MyPluginMenu()
    local openMenuSignal = useConstant(function()
        return Signal.new()
    end)

    React.useEffect(function()
        local toggle = Instance.new("BoolValue")
        toggle.Name = "TogglePluginMenu"
        toggle.Parent = workspace

        local connection = toggle.Changed:Connect(function()
            if toggle.Value then
                toggle.Value = false
                openMenuSignal:fire()
            end
        end)

        return function()
            connection:Disconnect()
            toggle.Parent = nil
        end
    end, {openMenuSignal})

    return React.createElement(
        Menu,
        {
            id = "MyPluginMenu",
            title = "My Plugin",
            icon = "rbxassetid://1234567",
            openMenu = openMenuSignal,
        },
        React.createElement(Action, {
            id = "Action",
            label = "Do Something",
            description = "Performs an action",
            triggered = function()
                print("Action triggered!")
            end
        })
    )
end
```

### RobloxPlugin

The `RobloxPlugin` component is a crucial wrapper component that provides the Roblox Studio plugin context to its children. It should be used at the root of your plugin's React element tree.

#### Props

```luau
type Props = {
    plugin: Plugin,
}
```

- `plugin`: The Roblox Studio [`Plugin`](https://create.roblox.com/docs/reference/engine/classes/Plugin) instance that your plugin code receives.

#### Example

```lua
local React = require('@pkg/@jsdotlua/react')
local ReactRobloxStudioPlugin = require('@pkg/@seaofvoices/react-roblox-studio-plugin')
local RobloxPlugin = ReactRobloxStudioPlugin.RobloxPlugin
local Toolbar = ReactRobloxStudioPlugin.Toolbar

local function MyPluginContent()
    return React.createElement(Toolbar, {
        name = "My Plugin Toolbar"
    }, {
        -- Toolbar buttons and other content
    })
end

local function InitializePlugin(plugin)
    return React.createElement(
        RobloxPlugin,
        { plugin = plugin },
        React.createElement(MyPluginContent)
    )
end

return InitializePlugin
```

### Toolbar

The `Toolbar` component creates and manages a [`PluginToolbar`](https://create.roblox.com/docs/reference/engine/classes/PluginToolbar). It provides a context for its children to access the toolbar instance.

#### Props

```lua
type Props = {
    name: string,
}
```

- `name`: The name of the toolbar to be created.

#### Example

In this example, `MyPluginToolbar` creates a toolbar named "My Custom Toolbar" and adds a button to it. The `ToolbarButton` component can access the toolbar instance through the context provided by `Toolbar`.

```lua
local React = require('@pkg/@jsdotlua/react')
local ReactRobloxStudioPlugin = require('@pkg/@seaofvoices/react-roblox-studio-plugin')
local Toolbar = ReactRobloxStudioPlugin.Toolbar
local ToolbarButton = ReactRobloxStudioPlugin.ToolbarButton

local function MyPluginToolbar()
    return React.createElement(
        Toolbar,
        { name = "My Custom Toolbar" },
        React.createElement(ToolbarButton, {
            icon = "rbxassetid://1234567",
            tooltip = "Click me!",
            onClick = function()
                print("Button clicked!")
            end
        })
    )
end
```

### ToolbarButton

The `ToolbarButton` component creates and manages a [`PluginToolbarButton`](https://create.roblox.com/docs/reference/engine/classes/PluginToolbarButton) within a Roblox Studio plugin toolbar.

#### Props

```lua
type Props = {
    onClick: (() -> ())?,
    id: string,
    toolTip: string?,
    iconAsset: string?,
    text: string?,
    active: boolean?,
}
```

- `onClick`: Optional callback function to be called when the button is clicked. If not provided, the button is automatically disabled.
- `id`: Unique identifier for the button.
- `toolTip`: Optional tooltip text to display when hovering over the button.
- `iconAsset`: Optional asset ID for the button's icon.
- `text`: Optional text to display on the button.
- `active`: Optional boolean to set the button's active state.

#### Example

In this example, `MyPluginToolbar` creates a toolbar with a toggle button. The button's active state is managed by React state and updated when clicked.

```lua
local React = require('@pkg/@jsdotlua/react')
local ReactRobloxStudioPlugin = require('@pkg/@seaofvoices/react-roblox-studio-plugin')
local Toolbar = ReactRobloxStudioPlugin.Toolbar
local ToolbarButton = ReactRobloxStudioPlugin.ToolbarButton

local function MyPluginToolbar()
    return React.createElement(
        Toolbar,
        { name = "My Custom Toolbar" },
        React.createElement(ToolbarButton, {
            id = "welcome-button",
            toolTip = "Welcome!",
            onClick = function()
                print("Hello!")
            end
        })
    )
end
```

### Widget

The `Widget` component creates and manages a [`DockWidgetPluginGui`](https://create.roblox.com/docs/reference/engine/classes/DockWidgetPluginGui). It provides a flexible way to create custom widget interfaces for your plugin.

#### Props

```lua
type Props = {
    id: string,
    title: string,
    enabled: boolean?,
    initialDockState: Enum.InitialDockState?,
    minSize: Vector2?,
    initialFloatSize: Vector2?,
    zIndexBehavior: Enum.ZIndexBehavior?,
    onClose: () -> ()?,
    onFocusLost: () -> ()?,
    onFocused: () -> ()?,
    onSizeChange: (size: Vector2) -> ()?,
}
```

- `id`: Unique identifier for the widget.
- `title`: The title displayed on the widget's title bar.
- `enabled`: Optional boolean to set the widget's visibility (default: `true`).
- `initialDockState`: Optional initial docking state (default: `Enum.InitialDockState.Float`).
- `minSize`: Optional minimum size of the widget.
- `initialFloatSize`: Optional initial size when floating.
- `zIndexBehavior`: Optional Z-index behavior (default: `Enum.ZIndexBehavior.Sibling`).
- `onClose`: Optional callback function when the widget is closed.
- `onFocusLost`: Optional callback function when the widget loses focus.
- `onFocused`: Optional callback function when the widget gains focus.
- `onSizeChange`: Optional callback function when the widget size changes.

#### Example

This example creates a widget that docks to the left side of the Studio window, with a minimum size and custom behavior for closing and focusing. The widget content is a simple text label.

```lua
local React = require('@pkg/@jsdotlua/react')
local ReactRobloxStudioPlugin = require('@pkg/@seaofvoices/react-roblox-studio-plugin')
local Widget = ReactRobloxStudioPlugin.Widget

local function MyPluginWidget()
    return React.createElement(
        Widget,
        {
            id = "MyPluginWidget",
            title = "My Plugin Widget",
            initialDockState = Enum.InitialDockState.Left,
            minSize = Vector2.new(200, 300),
            onFocused = function()
                print("Widget focused")
            end,
        },
        React.createElement("TextLabel", {
            Text = "Hello, Roblox Studio!",
            Size = UDim2.new(1, 0, 0, 30),
        })
    )
end
```

## Hooks

- [usePlugin](#useplugin)
- [useWidgetKeyDown](#usewidgetkeydown)
- [useWidgetFocus](#usewidgetfocus)
- [useWidgetFocusLost](#usewidgetfocuslost)

### usePlugin

```luau
function usePlugin(): Plugin
```

The `usePlugin` hook provides access to the current Roblox Studio `plugin` variable. It returns the `Plugin` object, allowing you to interact with the plugin API.

**Example:**

```luau
local plugin = usePlugin()

plugin:PromptSaveSelection()
```

### useWidgetKeyDown

```luau
function useWidgetKeyDown(onKeyDown: (Enum.KeyCode) -> ())
```

The `useWidgetKeyDown` hook sets up a listener for key press events in the widget. It takes a callback function as an argument, which is called with the `Enum.KeyCode` of the pressed key.

Note that this hook must be used under a Widget element.

### useWidgetFocus

```luau
function useWidgetFocused(onFocused: () -> ())
```

The `useWidgetFocus` hook sets up a listener for when the widget gains focus. It takes a callback function as an argument, which is called when the widget becomes focused.

Note that this hook must be used under a Widget element.

### useWidgetFocusLost

```luau
function useWidgetFocusLost(onFocusLost: () -> ())
```

The `useWidgetFocusLost` hook sets up a listener for when the widget loses focus. It takes a callback function as an argument, which is called when the widget loses focus.

Note that this hook must be used under a Widget element.

**Example:**

```luau
useWidgetFocusLost(function()
    print("Widget lost focus!")
end)
```

## License

This project is available under the MIT license. See [LICENSE.txt](LICENSE.txt) for details.
