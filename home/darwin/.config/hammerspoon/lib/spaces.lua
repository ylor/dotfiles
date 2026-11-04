local hs = hs ---@diagnostic disable-line: undefined-global

function SpaceInfo()
	local spaces = hs.spaces.spacesForScreen("Primary")
	if not spaces then
		return nil
	end
	local active = hs.spaces.activeSpaceOnScreen("Primary")
	return hs.fnutils.indexOf(spaces, active), #spaces
end

-- macOS has no working API for moving another app's window between spaces
-- (hs.spaces.moveWindowToSpace silently does nothing since 14.5), but it does
-- carry a window you're dragging into the space you switch to.
local moving = false
function MoveWindowToSpaceByDrag(index)
	local win = hs.window.focusedWindow()
	if moving or not win or not win:isStandard() or win:isFullScreen() then
		return
	end
	local screen = win:screen()
	local target = (hs.spaces.spacesForScreen(screen) or {})[index]
	local zoom = win:zoomButtonRect()
	if not target or not zoom or target == hs.spaces.activeSpaceOnScreen(screen) then
		return
	end

	-- Unified toolbars (Safari, Finder, Chrome tabs) put controls right next to
	-- the traffic lights.
	local grab = { x = zoom.x + zoom.w + 5, y = zoom.y + zoom.h / 2 }
	local frame, pid = win:frame(), win:application():pid()
	for x = grab.x, frame.x + frame.w - 20, 15 do
		local el = hs.axuielement.systemElementAtPosition(x, grab.y)
		local role = el and el:pid() == pid and el.AXRole
		if role == "AXWindow" or role == "AXToolbar" or role == "AXUnknown" then
			grab.x = x
			break
		end
	end
	local mouse = hs.mouse.absolutePosition()

	-- The press can land on app content (Rex's titlebar is its tab sidebar),
	-- which moves keyboard focus inside the app.
	local axApp = hs.axuielement.applicationElement(win:application())
	local focused = axApp.AXFocusedUIElement
	local observer = hs.axuielement.observer.new(pid)
	observer:callback(function(_, el)
		if focused and el ~= focused then
			focused:setAttributeValue("AXFocused", true)
		end
	end)
	observer:addWatcher(axApp, "AXFocusedUIElementChanged")
	observer:start()

	local mouseEvent = hs.eventtap.event.newMouseEvent
	local types = hs.eventtap.event.types
	moving = true
	-- Without a nudge the drag sometimes doesn't register. The window keeps the
	-- nudge's offset, and moving back mid-drag is ignored.
	win:setTopLeft({ x = frame.x - 1, y = frame.y })
	hs.mouse.absolutePosition(grab)
	mouseEvent(types.leftMouseDown, grab):post()
	mouseEvent(types.leftMouseDragged, { x = grab.x + 1, y = grab.y }):post()

	-- Switching before the drag is picked up leaves the window behind.
	hs.timer.doAfter(0.05, function()
		hs.eventtap.keyStroke({ "ctrl" }, tostring(index), 0)
		-- The drag follows the posted events, not the cursor, so it can go home now.
		hs.mouse.absolutePosition(mouse)
		local deadline = hs.timer.secondsSinceEpoch() + 1.5
		hs.timer.waitUntil(function()
			return hs.spaces.activeSpaceOnScreen(screen) == target or hs.timer.secondsSinceEpoch() > deadline
		end, function()
			-- Releasing mid-animation can drop the window on the old space.
			hs.timer.doAfter(0.1, function()
				-- Releasing at the grab point would pull the cursor back to it.
				mouseEvent(types.leftMouseUp, mouse):post()
				win:focus()
				moving = false
				hs.timer.doAfter(0.5, function()
					observer:stop()
					-- In case the nudge didn't register.
					win:setTopLeft(frame)
				end)
			end)
		end, 0.01)
	end)
end
