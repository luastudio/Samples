-- Switch.lua

Switch = {}

function Switch.new(inLabel, inLabelColor, inWidth, inHeight, inState, inStatusFunction)
    local self = {}

    local state = inState

	local Events = Lib.Media.Events
	local Display = Lib.Media.Display
	local Sprite = Display.Sprite
	local BitmapData = Display.BitmapData
	local Bitmap = Display.Bitmap
	local Geom = Lib.Media.Geom
    local Text = Lib.Media.Text
	local stage = Display.stage 

	local text = Text.TextField.new()
    local fmt = Text.TextFormat.new('_sans', inHeight / 2, inLabelColor, nil, nil, nil)
    text.defaultTextFormat = fmt
    text.autoSize = Text.TextFieldAutoSize.LEFT
    text.selectable = false
	text.x = inWidth + 5
	text.text = inLabel
	text.y = (inHeight - text.textHeight) / 2

    local radius = inHeight / 2

	local sprite = Sprite.new()
    sprite.cacheAsBitmap = true
    sprite.buttonMode = true
	local thumb = Sprite.new()
    thumb.cacheAsBitmap = true
    thumb.buttonMode = true

    sprite.addChild(text)

    function updateState()
      if(state)then
        thumb.x = inWidth - radius

    	local gfx = sprite.graphics
        gfx.clear() 
    	gfx.lineStyle(1, 0x404040, 1.0, false, nil, nil, nil, 3)
    	gfx.beginFill(0x00FF00, 1.0)
    	gfx.drawRoundRect(0,0,inWidth,inHeight, inHeight, inHeight)
        gfx.endFill()

    	gfx = thumb.graphics
        gfx.clear()  
	    gfx.lineStyle(1, 0xFFFFFF, 0.0, false, nil, nil, nil, 3)
    	gfx.beginFill(0x808080, 1.0)
    	gfx.drawCircle(0,0,radius - 2)
        gfx.endFill()
      else
    	local gfx = sprite.graphics
        gfx.clear()  
    	gfx.lineStyle(1, 0x404040, 1.0, false, nil, nil, nil, 3)
    	gfx.beginFill(0xFFFFFF, 1.0)
    	gfx.drawRoundRect(0,0,inWidth,inHeight, inHeight, inHeight)
        gfx.endFill()

    	gfx = thumb.graphics
        gfx.clear() 
	    gfx.lineStyle(1, 0xFFFFFF, 0.0, false, nil, nil, nil, 3)
    	gfx.beginFill(0x808080, 1.0)
    	gfx.drawCircle(0,0,radius - 2)
        gfx.endFill()

        thumb.x = radius
      end
    end

	sprite.addChild(thumb)
    updateState()
    thumb.y = radius
	local mThumb = thumb

	function self.getSprite()
		return sprite
	end

    function stopPropagation(e)
      e.stopPropagation()
    end

	function thumbStart(e)
      state = not state
      updateState()
      if inStatusFunction ~= nil then inStatusFunction(state) end
      stopPropagation(e)
	end

	sprite.addEventListener(Events.MouseEvent.CLICK, thumbStart, false, 0, false)
	sprite.addEventListener(Events.MouseEvent.MOUSE_DOWN, stopPropagation, false, 0, false)
	sprite.addEventListener(Events.MouseEvent.MOUSE_UP, stopPropagation, false, 0, false)
	sprite.addEventListener(Events.MouseEvent.MOUSE_MOVE, stopPropagation, false, 0, false)

	return self
end