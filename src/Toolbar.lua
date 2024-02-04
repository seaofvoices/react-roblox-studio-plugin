local React = require('@pkg/@jsdotlua/react')

local PluginContext = require('./contexts/PluginContext')
local ToolbarContext = require('./contexts/ToolbarContext')

export type Props = {
    name: string,
    children: React.React_Node,
}

local function Toolbar(props: Props)
    local plugin = React.useContext(PluginContext)

    local name = props.name

    local toolbar: PluginToolbar?, setToolbar = React.useState(nil :: PluginToolbar?)

    React.useEffect(function()
        local newToolbar = plugin:CreateToolbar(name)
        setToolbar(newToolbar)
        return function()
            newToolbar:Destroy()
        end
    end, {})

    React.useEffect(function()
        if toolbar ~= nil and toolbar.Name ~= name then
            toolbar.Name = name
        end
    end, { toolbar :: any, name })

    return React.createElement(ToolbarContext.Provider, { value = toolbar }, props.children)
end

return Toolbar
