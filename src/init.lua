local Action = require('./Action')
local Menu = require('./Menu')
local RobloxPlugin = require('./RobloxPlugin')
local Toolbar = require('./Toolbar')
local ToolbarButton = require('./ToolbarButton')
local Widget = require('./Widget')

export type ActionProps = Action.Props
export type MenuProps = Menu.Props
export type RobloxPluginProps = RobloxPlugin.Props
export type ToolbarProps = Toolbar.Props
export type ToolbarButtonProps = ToolbarButton.Props
export type WidgetProps = Widget.Props

local RobloxStudioPlugin = {
    Action = Action,
    Menu = Menu,
    RobloxPlugin = RobloxPlugin,
    Toolbar = Toolbar,
    ToolbarButton = ToolbarButton,
    Widget = Widget,
    usePlugin = require('./hooks/usePlugin'),
    useWidgetKeyDown = require('./hooks/useWidgetKeyDown'),
    useWidgetFocus = require('./hooks/useWidgetFocus'),
    useWidgetFocusLost = require('./hooks/useWidgetFocusLost'),
}

return RobloxStudioPlugin
