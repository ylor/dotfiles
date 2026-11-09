---@diagnostic disable-next-line: undefined-global
local hs = hs

-- Focus follows mouse. Polls instead of using an eventtap so a stalled
-- Hammerspoon main thread delays focus rather than freezing the cursor.

local DELAY = 0.05 -- seconds the mouse must rest before focusing
local INTERVAL = 0.025

local function windowUnderMouse(pos)
	local el = hs.axuielement.systemElementAtPosition(pos)
	if not el then return end
	local role = el:attributeValue("AXRole") or ""
	-- Leave open menus, menu bar items and popovers alone.
	if role:find("Menu") or role == "AXPopover" then return end
	local axwin = role == "AXWindow" and el or el:attributeValue("AXWindow")
	if not axwin then return end -- desktop, Dock, menu bar
	local win = axwin:asHSWindow()
	if win and win:isStandard() then
		return win
	end
end

local lastPos, stableSince

local function tick()
	if next(hs.mouse.getButtons()) then
		stableSince = nil -- ignore drags
		return
	end
	local pos = hs.mouse.absolutePosition()
	if not lastPos or pos.x ~= lastPos.x or pos.y ~= lastPos.y then
		lastPos, stableSince = pos, hs.timer.secondsSinceEpoch()
		return
	end
	if stableSince and hs.timer.secondsSinceEpoch() - stableSince >= DELAY then
		stableSince = nil -- one lookup per rest
		local win = windowUnderMouse(pos)
		if win and win ~= hs.window.focusedWindow() then
			win:focus()
		end
	end
end

_G.FocusFollowsMouseTimer = hs.timer.doEvery(INTERVAL, tick)

function FocusFollowsMouseToggle()
	if FocusFollowsMouseTimer:running() then
		FocusFollowsMouseTimer:stop()
		hs.alert.show("Focus follows mouse: off")
	else
		lastPos, stableSince = nil, nil
		FocusFollowsMouseTimer:start()
		hs.alert.show("Focus follows mouse: on")
	end
end
