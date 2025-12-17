---@diagnostic disable-next-line: undefined-global
local hs = hs

local em = "cm9seXJleWVzQG1lLmNvbQ=="
if Work then
    em = "cnJleWVzQHBhcGEuY29t"
end

keywords = {
    ["@@"] = hs.base64.decode(em),
    ["shrugg"] = "¯\\_(ツ)_/¯",
    ["tmm"] = "™",
    ["xx"] = "×"
}

local word = ""
local key = hs.keycodes.map
local DEBUG = false

-- create an "event listener" function that will run whenever the event happens
keywatcher = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    local kc = event:getKeyCode()
    local char = event:getCharacters()

    -- if "delete" key is pressed
    if kc == key["delete"] then
        if #word > 0 then
            -- remove the last char from a string with support to utf8 characters
            local t = {}
            for _, chars in utf8.codes(word) do table.insert(t, chars) end
            table.remove(t, #t)
            word = utf8.char(table.unpack(t))
            if DEBUG then print("Word after deleting:", word) end
        end
        return false -- pass the "delete" keystroke on to the application
    end

    -- append char to "word" buffer
    word = word .. char
    if DEBUG then print("Word after appending:", word) end

    -- if one of these "navigational" keys is pressed
    if kc == key["return"]
        or kc == key["delete"]
        or kc == key["space"]
        or kc == key["up"]
        or kc == key["down"]
        or kc == key["left"]
        or kc == key["right"] then
        word = "" -- clear the buffer
    end
    if DEBUG then print("Word to check if hotstring:", word) end

    -- finally, if "word" is a hotstring
    if keywords[word] then
        for i = 1, utf8.len(word), 1 do hs.eventtap.keyStroke({}, "delete", 0) end -- delete the abbreviation

        if type(keywords[word]) == "function" then
            hs.eventtap.keyStrokes(keywords[word]())
        else
            hs.eventtap.keyStrokes(keywords[word]) -- expand the word
        end
        word = ""                                  -- clear the buffer
    end

    return false -- pass the event on to the application
end):start()     -- start the eventtap

-- source: https://github.com/Hammerspoon/hammerspoon/issues/1042#issuecomment-1090748005
