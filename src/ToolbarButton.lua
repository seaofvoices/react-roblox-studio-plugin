local React = require('@pkg/@jsdotlua/react')

local PluginToolbarContext = require('./contexts/ToolbarContext')

export type Props = {
    onClick: (() -> ())?,
    id: string,
    toolTip: string?,
    iconAsset: string?,
    text: string?,
    active: boolean?,
}

local function ToolbarButton(props: Props)
    local id = props.id
    local toolTip = props.toolTip or ''
    local iconAsset = props.iconAsset or ''
    local text = props.text
    local active = if props.active == nil then false else props.active
    local onClick = props.onClick
    local enabled = props.onClick ~= nil

    local toolbar = React.useContext(PluginToolbarContext)

    local button = React.useRef(nil :: PluginToolbarButton?)

    React.useEffect(function()
        if button.current ~= nil then
            button.current:Destroy()
        end
        local newButton = toolbar:CreateButton(id, toolTip, iconAsset, text)
        newButton.ClickableWhenViewportHidden = true
        newButton.Enabled = enabled
        newButton:SetActive(active)
        button.current = newButton
    end, { id } :: { any }) -- the button cannot be created again, so just depend on `id`

    React.useEffect(function(): (() -> ())?
        if button.current ~= nil and onClick ~= nil then
            local connection = button.current.Click:Connect(onClick)
            return function()
                connection:Disconnect()
            end
        end
        return nil
    end, { onClick, button.current or false } :: { any })

    React.useEffect(function()
        if button.current then
            button.current:SetActive(active)
        end
    end, { active, button.current or false } :: { any })

    React.useEffect(function()
        if button.current and iconAsset ~= '' then
            button.current.Icon = iconAsset
        end
    end, { iconAsset, button.current or false } :: { any })

    React.useEffect(function()
        if button.current then
            button.current.Enabled = enabled
        end
    end, { enabled, button.current or false } :: { any })

    return nil
end

return ToolbarButton
