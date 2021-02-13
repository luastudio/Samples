-- Sprite.lua

Sprite = Lib.Media.Display.Sprite
stage = Lib.Media.Display.stage

sprite = Sprite.new()
sprite.name = "Sprite 1"
sprite.graphics.lineStyle(2, 0x00FF00, 1.0, false, nil, nil, nil, 3)
sprite.graphics.beginFill(0xFFFF00, 1.0)
sprite.graphics.drawRect(0,0, 200, 100)
sprite.graphics.endFill()
sprite.buttonMode = true
stage.addChild(sprite)

sprite.x = 10
sprite.y = 10

sprite.addEventListener(Lib.Media.Events.MouseEvent.CLICK, 
function(e)
	print(e.target.name)
end, false, 0, false)