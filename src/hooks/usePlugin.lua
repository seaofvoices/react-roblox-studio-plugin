local React = require('@pkg/@jsdotlua/react')

local PluginContext = require('../contexts/PluginContext')

local function usePlugin(): Plugin
    return React.useContext(PluginContext)
end

return usePlugin
