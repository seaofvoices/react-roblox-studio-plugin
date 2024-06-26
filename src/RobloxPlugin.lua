local React = require('@pkg/@jsdotlua/react')

local PluginContext = require('./contexts/PluginContext')

export type Props = {
    plugin: Plugin,
    children: React.ReactNode,
}

local function RobloxPlugin(props: Props)
    return React.createElement(PluginContext.Provider, { value = props.plugin }, props.children)
end

return RobloxPlugin
