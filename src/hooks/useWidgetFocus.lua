local React = require('@pkg/@jsdotlua/react')

local WidgetInputContext = require('../contexts/WidgetInputContext')

local function useWidgetFocused(onFocused: () -> ())
    local widgetInput = React.useContext(WidgetInputContext)

    React.useEffect(function()
        return widgetInput.focused:connect(onFocused):disconnectFn()
    end, { widgetInput :: any, onFocused })
end

return useWidgetFocused
