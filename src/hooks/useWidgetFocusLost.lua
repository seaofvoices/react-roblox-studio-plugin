local React = require('@pkg/@jsdotlua/react')

local WidgetInputContext = require('../contexts/WidgetInputContext')

local function useWidgetFocusLost(onFocusLost: () -> ())
    local widgetInput = React.useContext(WidgetInputContext)

    React.useEffect(function()
        return widgetInput.focusLost:connect(onFocusLost):disconnectFn()
    end, { widgetInput :: any, onFocusLost })
end

return useWidgetFocusLost
