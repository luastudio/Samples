-- TraceBox.lua

TraceBox = {}

function TraceBox.new()
    local self = {}

	local Sprite = Lib.Media.Display.Sprite
	local Text = Lib.Media.Text
	local Events = Lib.Media.Events
	local Thread = Lib.Sys.VM.Thread
    local Capabilities = Lib.Media.Capabilities

	local stage = Lib.Media.Display.stage
	local SCALE = 1.0

	local toPixels = function(size)
		return SCALE * Capabilities.screenDPI * (size / 25.4)
	end

	local screenWidth = stage.stageWidth
	local screenHeight = stage.stageHeight

	local consoleWidth = 0
	local consoleHeight = 0

	local preferableX = nil
	local preferableY = nil
	local preferableWidth = nil
	local preferableHeight = nil

	local visibleMessaegIndex = -1

	local messages = {} -- table of TextFields

	local consoleSprite = Sprite.new()
	local consoleLogSprite = Sprite.new()
	consoleLogSprite.y = toPixels(9)
	consoleSprite.addChild(consoleLogSprite)
    stage.addChild(consoleSprite)

	local textFormat = Text.TextFormat.new('_sans', toPixels(4), 0x000000, nil, nil, nil)

	local txtCounter = Text.TextField.new()
	txtCounter.autoSize = Text.TextFieldAutoSize.LEFT
	txtCounter.wordWrap = false
	txtCounter.defaultTextFormat = textFormat
	txtCounter.y = toPixels(2)
	txtCounter.mouseEnabled = false
	txtCounter.visible = false
	txtCounter.text = "0"
	consoleSprite.addChild(txtCounter)

	local menuExit = Text.TextField.new()
	menuExit.autoSize = Text.TextFieldAutoSize.LEFT
	menuExit.defaultTextFormat = textFormat
    menuExit.x = toPixels(1)
    menuExit.y = toPixels(2)
	menuExit.selectable = false
	menuExit.border = false
	menuExit.mouseEnabled = true
	menuExit.htmlText = "<b><a href='event:menuExit'>EXIT</a></b>"
	menuExit.addEventListener(Events.TextEvent.LINK, function(e)
		Lib.Media.System.exit(0) 
	end, false, 0, false)
	consoleSprite.addChild(menuExit)

	local menuClear = Text.TextField.new()
	menuClear.x = menuExit.x + menuExit.width + toPixels(3)
	menuClear.autoSize = Text.TextFieldAutoSize.LEFT
	menuClear.defaultTextFormat = textFormat
    menuClear.y = toPixels(2)
	menuClear.selectable = false
	menuClear.border = false
	menuClear.mouseEnabled = true
	menuClear.htmlText = "<b><a href='event:menuClear'>CLEAR</a></b>"
	menuClear.addEventListener(Events.TextEvent.LINK, function(e)
		while #messages > 0 do
		    local consoleLog = messages[1]
			table.remove (messages, 1)
	        if consoleLog.parent ~= nil then
	        	consoleLog.parent.removeChild(consoleLog)
	        end
	        consoleLog.text = nil
	    end
	    visibleMessaegIndex = -1
	    consoleLogSize = 0
	    menuClear.alpha = 0.5
	    txtCounter.text = "0"
	    txtCounter.visible = false
	end, false, 0, false)
	consoleSprite.addChild(menuClear)

    local drawConsole = function()
		consoleSprite.graphics.clear()

		consoleSprite.graphics.lineStyle(0, 0x000000, 0.0, false, nil, nil, nil, 3)
	    consoleSprite.graphics.beginFill(0xDEDEDE, 0.8)
	    consoleSprite.graphics.drawRect(0,0,consoleWidth, toPixels(9))
	    consoleSprite.graphics.endFill()
	    consoleSprite.graphics.beginFill(0xDEDEDE, 0.8)
	    consoleSprite.graphics.drawRect(0,consoleHeight - toPixels(3),consoleWidth, toPixels(3))
	    consoleSprite.graphics.endFill()
	    consoleSprite.graphics.beginFill(0xFFFFFF, 0.7)
	    consoleSprite.graphics.drawRect(0,toPixels(9),consoleWidth, consoleHeight - toPixels(9 + 3))
	    consoleSprite.graphics.endFill()
	    --border
	    consoleSprite.graphics.lineStyle(2, 0x0000FF, 1.0, false, nil, nil, nil, 3)
	    consoleSprite.graphics.drawRect(0, 0, consoleWidth, consoleHeight)
	    consoleSprite.graphics.endFill()
	    --Resizer
	    consoleSprite.graphics.moveTo(consoleWidth, consoleHeight - toPixels(3))
	    consoleSprite.graphics.lineStyle(0, 0x0000FF, 1.0, false, nil, nil, nil, 3)
	    consoleSprite.graphics.beginFill(0x0000FF, 1)
	    consoleSprite.graphics.lineTo(consoleWidth - toPixels(3), consoleHeight)
	    consoleSprite.graphics.lineTo(consoleWidth, consoleHeight)
	    consoleSprite.graphics.lineTo(consoleWidth, consoleHeight - toPixels(3))
	    consoleSprite.graphics.endFill()
	end

	local scrollConsoleLog = function (deltaY)
		if visibleMessaegIndex < 0 or #messages <= 0 then
			return
	    end

	    if visibleMessaegIndex == 0 and messages[1].y + deltaY > 0 then
		    deltaY = -messages[1].y
	    end

	    local logH = messages[visibleMessaegIndex+1].y + deltaY
	    local logHeight = consoleHeight - toPixels(9 + 3)
	    for j = visibleMessaegIndex, #messages-1, 1 do
			local consoleLog = messages[j+1]
	        consoleLog.width = consoleWidth
			if consoleLog.parent ~= nil then
	        	consoleLog.y = logH
	            logH = consoleLog.y + consoleLog.height
	            if consoleLog.y < 0 and logH < 0 then
		            if j == #messages - 1 then
		                consoleLog.y = - consoleLog.height
	                else
	                    consoleLog.parent.removeChild(consoleLog)
	                    visibleMessaegIndex = j + 1
	                end
	            elseif consoleLog.y > logHeight then
		             consoleLog.parent.removeChild(consoleLog)
    	        end
			else
	             if logH < logHeight then
		             consoleLog.y = logH
	                 logH = consoleLog.y + consoleLog.height
	                 consoleLogSprite.addChild(consoleLog)
    	         else
        	         break
            	 end
			end
	    end

	    if visibleMessaegIndex > 0 and messages[visibleMessaegIndex+1].y > 0 then
		    local j = visibleMessaegIndex - 1;
	        messages[j+1].width = consoleWidth
	        logH = messages[visibleMessaegIndex+1].y - messages[j+1].height
	        while j >= 0 do
		        local consoleLog = messages[j+1]
	            consoleLog.y = logH
	            if consoleLog.parent == nil then
		            consoleLogSprite.addChild(consoleLog)
	            end
    	        visibleMessaegIndex = j
	            j = j - 1
	            if j >= 0 and consoleLog.y > 0 then
		            messages[j+1].width = consoleWidth
	                logH = consoleLog.y - messages[j+1].height
	            else
	            	break
	            end
			end
		end
	end

	local processResize = function()
		consoleLogSprite.scrollRect = Lib.Media.Geom.Rectangle.new(0,0,consoleWidth,consoleHeight-toPixels(9 + 3))
		drawConsole()
		txtCounter.x = consoleWidth - txtCounter.textWidth - toPixels(2)
		scrollConsoleLog(0)
	end

	resizeFn = function (e)
		local screenWidthDelta = screenWidth - stage.stageWidth
	    local screenHeightDelta = screenHeight - stage.stageHeight
	    if screenWidthDelta == 0 and screenHeightDelta == 0 and e ~= nil then
	    	return --nothing to resize yet
	    end

	    screenWidth = stage.stageWidth
	    screenHeight = stage.stageHeight
	    consoleSprite.y = screenHeight - screenHeight / 3
	    consoleSprite.x = screenWidth / 10

	    consoleWidth = screenWidth - screenWidth / 5
	    consoleHeight = math.max(screenHeight / 5, toPixels(9 + 3 + 7))

		--preferable
	    if preferableX ~= nil then
		    consoleSprite.x = preferableX
	    end
	    if preferableY ~= nil then
	        consoleSprite.y = preferableY
	    end
	    if preferableWidth ~= nil then
	        consoleWidth = preferableWidth
	    end
	    if preferableHeight ~= nil then
	        consoleHeight = preferableHeight
	    end

	    consoleSprite.x = consoleSprite.x + consoleWidth - toPixels(9) < 0 and 
			toPixels(9) - consoleWidth or consoleSprite.x
	    consoleSprite.x = consoleSprite.x + menuClear.x + menuClear.width + toPixels(2) > screenWidth and
		    screenWidth - (menuClear.x + menuClear.width + toPixels(2)) or consoleSprite.x
	    consoleSprite.y = consoleSprite.y < 0 and 0 or consoleSprite.y
	    consoleSprite.y = consoleSprite.y > screenHeight - toPixels(9) and screenHeight - toPixels(9) or consoleSprite.y

	    consoleHeight = (consoleHeight > screenHeight) and consoleHeight - (consoleHeight - screenHeight) or consoleHeight

	    processResize()
	end

	consoleSprite.addEventListener(Events.MouseEvent.MOUSE_WHEEL, function (e)
		if e.stageX >= consoleSprite.x and e.stageX <= consoleSprite.x + consoleWidth and
	    	e.stageY >= consoleSprite.y + toPixels(9) and e.stageY <= consoleSprite.y + consoleHeight - toPixels(3) then
	    	scrollConsoleLog(e.delta * 7 * Capabilities.screenDPI / 72)
	    end
	    e.stopImmediatePropagation()
	end, false, 0, false)

	local consoleSpriteIsMouseDown = false
	local consoleSpriteIsMouseDownForResize = false
	local consoleLogIsMouseDown = false
	local consoleSpriteOldStageX = 0.0
	local consoleSpriteOldStageY = 0.0

	stage.addEventListener(Events.MouseEvent.CLICK, function (e)
		if e.target == consoleSprite then
		    e.stopImmediatePropagation()
		end
	end, false, 0, false)

	stage.addEventListener(Events.MouseEvent.MOUSE_DOWN, function (e)
		consoleSpriteIsMouseDown = e.target == consoleSprite
	    consoleSpriteIsMouseDownForResize = false
	    if consoleSpriteIsMouseDown and e.stageX >= consoleSprite.x and e.stageX <= consoleSprite.x + consoleWidth and
		    e.stageY >= consoleSprite.y + toPixels(9) then
		    if e.stageY <= consoleSprite.y +consoleHeight - toPixels(3) then
		        consoleSpriteIsMouseDown = false
	            consoleLogIsMouseDown = true
	         else
	            consoleSpriteIsMouseDownForResize = true
	         end
	    end
	    if consoleSpriteIsMouseDown or consoleLogIsMouseDown then
		    e.stopImmediatePropagation()
	    end
	    consoleSpriteOldStageX = e.stageX
	    consoleSpriteOldStageY = e.stageY
	end, false, 0, false)

	stage.addEventListener(Events.MouseEvent.MOUSE_UP, function (e)
		if consoleSpriteIsMouseDown then
		    consoleSpriteIsMouseDown = false
	        e.stopImmediatePropagation()
	    elseif consoleLogIsMouseDown then
	        consoleLogIsMouseDown = false
	        e.stopImmediatePropagation()
	    end
	end, false, 0, false)

	stage.addEventListener(Events.MouseEvent.MOUSE_MOVE, function (e)
		if e.stageX >= consoleSprite.x and e.stageX <= consoleSprite.x + consoleWidth and
		    e.stageY >= consoleSprite.y and e.stageY <= consoleSprite.y + consoleHeight then
		    e.stopImmediatePropagation()
	    end

	    if not e.buttonDown or (not consoleSpriteIsMouseDown and not consoleLogIsMouseDown) then
		    return
	    end

	    local deltaX = e.stageX - consoleSpriteOldStageX
	    local deltaY = e.stageY - consoleSpriteOldStageY
	    if consoleSpriteIsMouseDown then
		    if consoleSpriteIsMouseDownForResize then
	    	    if consoleWidth + deltaX > menuClear.x + menuClear.width + toPixels(2) then
	        	    consoleWidth = consoleWidth + deltaX
	            	consoleWidth = (consoleSprite.x + consoleWidth < toPixels(9)) and
		                consoleWidth - deltaX or consoleWidth
	                preferableWidth = consoleWidth
	            end
	            if consoleHeight + deltaY > toPixels(9 + 3) then
	            	consoleHeight = consoleHeight + deltaY
	                consoleHeight = (consoleHeight > screenHeight) and
		                consoleHeight - (consoleHeight - screenHeight) or consoleHeight
	                 preferableHeight = consoleHeight
	            end
	            processResize()
	        else
		        consoleSprite.x = consoleSprite.x + deltaX
	            consoleSprite.y = consoleSprite.y + deltaY
	            consoleSprite.x = consoleSprite.x + consoleWidth - toPixels(9) < 0 and  consoleSprite.x - deltaX or consoleSprite.x
	            consoleSprite.x = consoleSprite.x + menuClear.x + menuClear.width + toPixels(2) > screenWidth and  consoleSprite.x - deltaX or consoleSprite.x
	            consoleSprite.y = consoleSprite.y < 0 and 0 or consoleSprite.y
	            consoleSprite.y = consoleSprite.y > screenHeight - toPixels(9) and screenHeight - toPixels(9) or consoleSprite.y
	            preferableX = consoleSprite.x
	            preferableY = consoleSprite.y
	    	end
		elseif consoleLogIsMouseDown then
			scrollConsoleLog(deltaY)
		end

	    consoleSpriteOldStageX = e.stageX
	    consoleSpriteOldStageY = e.stageY
	end, false, 0, false)

	stage.addEventListener(Events.FocusEvent.MOUSE_FOCUS_CHANGE, function(e)
		if e.relatedObject ~= nil and (e.relatedObject == consoleSprite or e.relatedObject == menuExit or
		    e.relatedObject == menuClear) then
		    e.stopImmediatePropagation()
	    end
	end, false, 0, false)

	consoleSprite.addEventListener(Events.Event.ENTER_FRAME, function (e)
		if consoleLogIsMouseDown then --wait when not scrolling
		    return
		end

		local msg = Thread.readMessage(false)

	    if msg == nil or msg.message == nil then
		    return
		end

	    local message = msg.message

	    local consoleLog = Text.TextField.new()
	    consoleLog.autoSize = Text.TextFieldAutoSize.LEFT
	    consoleLog.defaultTextFormat = textFormat
	    consoleLog.selectable = false
	    consoleLog.border = false
	    consoleLog.wordWrap = true
	    consoleLog.multiline = true
	    consoleLog.width = consoleWidth
	    consoleLog.mouseEnabled = false
	    consoleLog.height = consoleHeight - toPixels(9 + 3)
        if msg.type == 1 then
		    consoleLog.text = message
        elseif msg.type == 2 then
		    consoleLog.htmlText = message
        end
	    messages[#messages + 1] = consoleLog
	    txtCounter.text = ""..#messages
	    txtCounter.x = consoleWidth - txtCounter.textWidth - toPixels(2)

	    if #messages == 1 then
		    consoleLog.y = 0
	        visibleMessaegIndex = 0
	        menuClear.alpha = 1
	        consoleLogSprite.addChild(consoleLog)
	        txtCounter.visible = true
	    else 
	        --clear
	        while consoleLogSprite.numChildren > 0 do
		        consoleLogSprite.removeChildAt(0)
	        end
	        --add
	        local logY = consoleHeight - toPixels(9 + 3)
	        local i = #messages - 1
	        while i >= 0 do
		        consoleLog = messages[i+1]
	            consoleLog.width = consoleWidth
	            consoleLog.y = logY - consoleLog.height
	            if consoleLog.y < 0 and consoleLog.y + consoleLog.height < 0 then --out of screen on top
		            visibleMessaegIndex = i + 1
	                break
	            else 
	                visibleMessaegIndex = i
	                consoleLogSprite.addChild(consoleLog)
	            end
	            logY = consoleLog.y
	            if visibleMessaegIndex == 0 and logY > 0 then --allign to top line
		            logY = 0
	                for i = 0, #messages-1, 1 do
		                consoleLog = messages[i+1]
	                    consoleLog.width = consoleWidth
	                    consoleLog.y = logY
	                    logY = logY + consoleLog.height
	                end
	                break
	            end
	            i = i - 1
	        end
		end
	end, false, 0, false)

	stage.addEventListener(Events.Event.RESIZE, resizeFn, false, 0, false)

	resizeFn()

	return self
end