local React = require('@pkg/@jsdotlua/react')
local Signal = require('@pkg/luau-signal')

local PluginContext = require('./contexts/PluginContext')

type Signal<T...> = Signal.Signal<T...>

export type Props = {
    id: string,
    title: string,
    icon: string?,
    openMenu: Signal<()>,
}

local function Menu(props: Props)
    local id = props.id
    local title = props.title
    local icon = props.icon or ''
    local openMenu = props.openMenu

    local plugin = React.useContext(PluginContext)

    local menu, setMenu = React.useState(nil :: PluginAction?)

    React.useEffect(function()
        local pluginMenu = plugin:CreatePluginMenu(id, title, icon)
        -- print('pluginMenu.Parent', pluginMenu.Parent)
        setMenu(pluginMenu)
        return function()
            pluginMenu:Destroy()
        end
    end, { id, title, icon })

    React.useEffect(function()
        return openMenu
            :connect(function()
                menu:ShowAsync()
            end)
            :disconnectFn()
    end, { menu :: any, openMenu })

    return nil
end

return Menu
