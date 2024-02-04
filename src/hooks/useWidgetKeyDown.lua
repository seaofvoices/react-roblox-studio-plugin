local React = require('@pkg/@jsdotlua/react')

local WidgetInputContext = require('../contexts/WidgetInputContext')

local function useWidgetKeyDown(onKeyDown: (Enum.KeyCode) -> ())
    local widgetInput = React.useContext(WidgetInputContext)

    React.useEffect(function()
        return widgetInput.onKeyDown:connect(onKeyDown):disconnectFn()
    end, { widgetInput :: any, onKeyDown })
end

return useWidgetKeyDown
