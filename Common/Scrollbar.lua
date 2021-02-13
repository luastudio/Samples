-- Scrollbar.lua

Scrollbar = {}

function Scrollbar.new(inWidth, inHeight, inRange, inPage)
    local self = {}

	local Events = Lib.Media.Events
	local Display = Lib.Media.Display
	local Sprite = Display.Sprite
	local BitmapData = Display.BitmapData
	local Bitmap = Display.Bitmap
	local Geom = Lib.Media.Geom
	local stage = Display.stage 

	local sprite = Sprite.new()
	local gfx = sprite.graphics

	gfx.lineStyle(1, 0x404040, 1.0, false, nil, nil, nil, 3)
	gfx.beginFill(0xeeeeee, 1.0)
	gfx.drawRect(0,0,inWidth,inHeight)

	local mThumbHeight = inHeight * inPage / inRange
	local mRange = inRange
	local mHeight = inHeight
	local mPage = inPage
	local mRemoveFrom

	local thumb = Sprite.new()
	gfx = thumb.graphics
	gfx.lineStyle(1, 0x000000, 1.0, false, nil, nil, nil, 3)
	gfx.beginFill(0xffffff, 1.0)
	gfx.drawRect(0,0,inWidth,mThumbHeight)
	sprite.addChild(thumb)
	local mThumb = thumb

	function self.getSprite()
		return sprite
	end

	function self.scrolled(inTo)
	end

	function onScroll(e)
		local denom = mHeight - mThumbHeight
		if denom > 0 then
			local ratio = mThumb.y/denom
			self.scrolled(ratio * mRange)
		end
	end

	function thumbStop(e)
		mThumb.stopDrag()
		mThumb.removeEventListener(Events.MouseEvent.MOUSE_UP, thumbStop, false)
		mRemoveFrom.removeEventListener(Events.MouseEvent.MOUSE_UP, thumbStop, false)
		mRemoveFrom.removeEventListener(Events.MouseEvent.MOUSE_MOVE, onScroll, false)
	end

	function thumbStart(e)
		mRemoveFrom = stage
		mThumb.addEventListener(Events.MouseEvent.MOUSE_UP, thumbStop, false, 0, false)
		mRemoveFrom.addEventListener(Events.MouseEvent.MOUSE_UP, thumbStop, false, 0, false)
		mRemoveFrom.addEventListener(Events.MouseEvent.MOUSE_MOVE, onScroll, false, 0, false)
		mThumb.startDrag(false, Geom.Rectangle.new(0, 0, 0, mHeight - mThumbHeight))
	end

	mThumb.addEventListener(Events.MouseEvent.MOUSE_DOWN, thumbStart, false, 0, false)

	return self
end