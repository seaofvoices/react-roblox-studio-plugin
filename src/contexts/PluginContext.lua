local React = require('@pkg/@jsdotlua/react')

local PluginContext: React.Context<Plugin> = React.createContext(nil) :: any
PluginContext.displayName = 'PluginContext'

return PluginContext
