-- ---@diagnostic disable-next-line: undefined-global
-- local hs = hs
-- -- APP WATCHERS

-- -- Create a table to hold our app-specific functions.
-- -- It's a good practice to put this inside a module or a global scope to prevent
-- -- it from being garbage collected.
-- appWatchers = {}

-- -- The single, global application watcher.
-- -- Assign it to a global variable to ensure it's not garbage collected.
-- appWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
--     -- Check if we have a handler for this app and event type.
--     if appWatchers[appName] and appWatchers[appName][eventType] then
--         -- Call the specific handler function with the application object.
--         appWatchers[appName][eventType](appObject)
--     end
-- end):start()

-- -- Reusable function to register a new app watcher.
-- function registerAppWatcher(appName, eventType, fn)
--     -- Initialize the table for the app if it doesn't exist.
--     appWatchers[appName] = appWatchers[appName] or {}
--     -- Store the function for the specific event type.
--     appWatchers[appName][eventType] = fn
-- end
