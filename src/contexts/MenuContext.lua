local React = require('@pkg/@jsdotlua/react')

local PluginMenuContext: React.Context<PluginMenu?> = React.createContext(nil :: any)
PluginMenuContext.displayName = 'PluginMenuContext'

return PluginMenuContext
