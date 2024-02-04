local React = require('@pkg/@jsdotlua/react')

local MenuContext = require('./contexts/MenuContext')
local PluginContext = require('./contexts/PluginContext')

export type Props = {
    triggered: () -> (),
    id: string,
    label: string,
    description: string,
    icon: string?,
    allowBinding: boolean?,
}

local function Action(props: Props)
    local triggered = props.triggered
    local id = props.id
    local label = props.label
    local description = props.description
    local icon = props.icon or ''
    local allowBinding = if props.allowBinding == nil then true else props.allowBinding

    local plugin = React.useContext(PluginContext)
    local menu = React.useContext(MenuContext)

    local createAction = React.useCallback(
        function(
            id: string,
            label: string,
            description: string,
            icon: string,
            allowBinding: boolean
        )
            if menu then
                if allowBinding then
                    local action =
                        plugin:CreatePluginAction(id, label, description, icon, allowBinding)
                    menu:AddAction(action)
                    return action
                else
                    return menu:AddNewAction(id, label)
                end
            else
                -- if not in a menu, allowBinding must be true in order to use the action
                return plugin:CreatePluginAction(id, label, description, icon, true)
            end
        end,
        { plugin :: any, menu or false }
    )

    local action, setAction = React.useState(nil :: PluginAction?)

    React.useEffect(function()
        local newAction = createAction(id, label, description, icon, allowBinding)
        setAction(newAction)

        return function()
            newAction:Destroy()
        end
    end, { createAction :: any, id, label, description, icon, allowBinding })

    React.useEffect(function(): (() -> ())?
        if action then
            local connection = action.Triggered:Connect(triggered)
            return function()
                connection:Disconnect()
            end
        end
        return
    end, { triggered :: any, action or false })

    return nil
end

return Action
