--Main.lua

require("/SVGLite/SVGLite.lua")

svg = SVGLite.new()

--https://www.flaticon.com/free-icon/coffee_187455
--Icon made by Pixel perfect from www.flaticon.com
---@language XML
local dom = svg.parseProjectFile("/SVGLite/coffee_187455.svg")

Events = Lib.Media.Events
Sprite = Lib.Media.Display.Sprite
stage = Lib.Media.Display.stage

sprite1 = Sprite.new()
stage.addChild(sprite1)

sprite2 = Sprite.new()
sprite2.cacheAsBitmap = true --software rendering
stage.addChild(sprite2)

function resizeAndDraw(e)
    local scale = 1
    if stage.stageWidth > stage.stageHeight then
        scale = stage.stageWidth / (2 * dom.viewBox.width)
        if scale*dom.viewBox.height > stage.stageHeight then
            scale = stage.stageHeight / dom.viewBox.height
        end
        sprite2.x = stage.stageWidth / 2
        sprite2.y = 0
    else
        scale = stage.stageHeight / (2 * dom.viewBox.height)
        if scale*dom.viewBox.width > stage.stageWidth then
            scale = stage.stageWidth / dom.viewBox.width
        end
        sprite2.x = 0
        sprite2.y = stage.stageHeight / 2
    end
    --hardware rendering (triangulation)
    sprite1.graphics.clear()
    svg.render(dom, sprite1.graphics,
            Lib.Media.Geom.Matrix.new(scale,0,0,scale,0,0))
    --software rendering, cacheAsBitmap = true
    sprite2.graphics.clear()
    svg.render(dom, sprite2.graphics,
            Lib.Media.Geom.Matrix.new(scale,0,0,scale,0,0))
end
stage.addEventListener(Events.Event.RESIZE, resizeAndDraw, false, 0, false)
resizeAndDraw(nil)