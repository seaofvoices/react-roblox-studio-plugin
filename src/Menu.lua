local React = require('@pkg/@jsdotlua/react')
local Signal = require('@pkg/luau-signal')

local MenuContext = require('./contexts/MenuContext')
local PluginContext = require('./contexts/PluginContext')

type Signal<T...> = Signal.Signal<T...>

export type Props = {
    id: string,
    title: string,
    icon: string?,
    openMenu: Signal<()>,
    children: React.ReactNode,
}

local function Menu(props: Props)
    local id = props.id
    local title = props.title
    local icon = props.icon or ''
    local openMenu = props.openMenu

    local plugin = React.useContext(PluginContext)

    local menu, setMenu = React.useState(nil :: PluginMenu?)

    React.useEffect(function()
        local pluginMenu = plugin:CreatePluginMenu(id, title, icon)
        setMenu(pluginMenu)
        return function()
            pluginMenu:Destroy()
        end
    end, { id }) -- only re-created the menu if the id changes
    -- update the title and icon in other useEffects

    React.useEffect(function()
        if menu then
            menu.Title = title
        end
    end, { title :: any, menu or false })

    React.useEffect(function()
        if menu then
            menu.Icon = icon
        end
    end, { icon :: any, menu or false })

    React.useEffect(function()
        return openMenu
            :connect(function()
                menu:ShowAsync()
            end)
            :disconnectFn()
    end, { openMenu :: any, menu or false })

    return React.createElement(
        MenuContext.Provider,
        { value = menu },
        if menu then props.children else nil
    )
end

return Menu
