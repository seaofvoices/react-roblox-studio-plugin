local React = require('@pkg/@jsdotlua/react')
local Signal = require('@pkg/luau-signal')

type Signal<T...> = Signal.Signal<T...>

export type WidgetInput = {
    onKeyDown: Signal<Enum.KeyCode>,
    focused: Signal<()>,
    focusLost: Signal<()>,
}

local WidgetInputContext: React.Context<WidgetInput> = React.createContext(nil :: any)
WidgetInputContext.displayName = 'WidgetInputContext'

return WidgetInputContext
