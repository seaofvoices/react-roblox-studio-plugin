local React = require('@pkg/@jsdotlua/react')

local ToolbarContext: React.Context<PluginToolbar> = React.createContext(nil :: any)
ToolbarContext.displayName = 'PluginToolbarContext'

return ToolbarContext
