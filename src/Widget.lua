local React = require('@pkg/@jsdotlua/react')
local ReactRoblox = require('@pkg/@jsdotlua/react-roblox')
local Signal = require('@pkg/luau-signal')

local PluginContext = require('./contexts/PluginContext')
local WidgetInputContext = require('./contexts/WidgetInputContext')

export type Props = {
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
    children: React.ReactNode,
}

local function Widget(props: Props)
    local plugin = React.useContext(PluginContext)

    local id = props.id
    local title = props.title
    local enabled = if props.enabled == nil then true else props.enabled
    local initialDockState = props.initialDockState or Enum.InitialDockState.Float
    local minSize = props.minSize or Vector2.new(10, 10)
    local initialFloatSize = props.initialFloatSize or Vector2.new(100, 100)
    local zIndexBehavior = props.zIndexBehavior or Enum.ZIndexBehavior.Sibling
    local onClose = props.onClose
    local onFocusLost = props.onFocusLost
    local onFocused = props.onFocused
    local onSizeChange = props.onSizeChange

    local dockWidget: DockWidgetPluginGui?, setDockWidget =
        React.useState(nil :: DockWidgetPluginGui?)

    local initialEnabled = true
    local overrideEnabledRestore = false

    local dockWidgetInfo = React.useMemo(function()
        return DockWidgetPluginGuiInfo.new(
            initialDockState,
            initialEnabled,
            overrideEnabledRestore,
            initialFloatSize.X,
            initialFloatSize.Y,
            minSize.X,
            minSize.Y
        )
    end, {})

    React.useEffect(function()
        local newWidget = plugin:CreateDockWidgetPluginGui(id, dockWidgetInfo)
        newWidget.Name = title
        newWidget.Title = title
        newWidget.ResetOnSpawn = false
        newWidget.Enabled = enabled
        newWidget.ZIndexBehavior = zIndexBehavior
        setDockWidget(newWidget)
        return function()
            newWidget:Destroy()
        end
    end, { id :: any, dockWidgetInfo })

    React.useEffect(function(): (() -> ())?
        if dockWidget ~= nil and onClose then
            dockWidget:BindToClose(onClose)
            return function()
                dockWidget:BindToClose()
            end
        end
        return
    end, { dockWidget or false, onClose or false } :: { any })

    React.useEffect(function()
        if dockWidget ~= nil and dockWidget.Title ~= title then
            dockWidget.Title = title
            dockWidget.Name = title
        end
    end, { dockWidget or false, title } :: { any })

    React.useEffect(function()
        if dockWidget ~= nil and dockWidget.Enabled ~= enabled then
            dockWidget.Enabled = enabled
        end
    end, { dockWidget or false, enabled } :: { any })

    React.useEffect(function()
        if dockWidget ~= nil and dockWidget.ZIndexBehavior ~= zIndexBehavior then
            dockWidget.ZIndexBehavior = zIndexBehavior
        end
    end, { dockWidget or false, zIndexBehavior } :: { any })

    React.useEffect(function(): (() -> ())?
        if dockWidget ~= nil and onSizeChange ~= nil then
            local connection = dockWidget
                :GetPropertyChangedSignal('AbsoluteSize')
                :Connect(function()
                    onSizeChange(dockWidget.AbsoluteSize)
                end)
            return function()
                connection:Disconnect()
            end
        end
        return
    end, { dockWidget or false, onSizeChange or false } :: { any })

    local widgetInput: WidgetInputContext.WidgetInput = React.useMemo(function()
        return {
            onKeyDown = Signal.new(),
            focused = Signal.new(),
            focusLost = Signal.new(),
        }
    end, {})

    React.useEffect(function(): (() -> ())?
        if onFocusLost then
            return widgetInput.focusLost:connect(onFocusLost):disconnectFn()
        end
        return
    end, { widgetInput.focusLost :: any, onFocusLost or false })

    React.useEffect(function(): (() -> ())?
        if onFocused then
            return widgetInput.focused:connect(onFocused):disconnectFn()
        end
        return
    end, { widgetInput.focused :: any, onFocused or false })

    React.useEffect(function(): (() -> ())?
        if dockWidget ~= nil then
            local connection = dockWidget.WindowFocused:Connect(function()
                widgetInput.focused:fire()
            end)
            return function()
                connection:Disconnect()
            end
        end
        return
    end, { dockWidget or false, widgetInput } :: { any })

    React.useEffect(function(): (() -> ())?
        if dockWidget ~= nil then
            local connection = dockWidget.WindowFocusReleased:Connect(function()
                widgetInput.focusLost:fire()
            end)
            return function()
                connection:Disconnect()
            end
        end
        return
    end, { dockWidget or false, widgetInput } :: { any })

    local onInputBegan = React.useCallback(function(_: Frame, input: InputObject)
        if
            input.UserInputType == Enum.UserInputType.Keyboard
            and input.KeyCode ~= Enum.KeyCode.Unknown
        then
            widgetInput.onKeyDown:fire(input.KeyCode)
        end
    end, { widgetInput })

    local widgetChildren = React.createElement('Frame', {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        [React.Event.InputBegan] = onInputBegan,
    }, React.createElement(WidgetInputContext.Provider, { value = widgetInput }, props.children))

    return if dockWidget then ReactRoblox.createPortal(widgetChildren, dockWidget) else nil
end

return Widget
