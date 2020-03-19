--Main.lua

require("/SVGLite/SVGLite.lua")

svg = SVGLite.new()

--https://www.flaticon.com/free-icon/coffee_187455
--Icon made by Pixel perfect from www.flaticon.com
---@language XML
local dom = svg.parse([[<?xml version="1.0" encoding="iso-8859-1"?>
<!-- Generator: Adobe Illustrator 19.0.0, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->
<svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
	 viewBox="0 0 512 512" style="enable-background:new 0 0 512 512;" xml:space="preserve">
<circle style="fill:#88C5CC;" cx="256" cy="256" r="256"/>
<path style="fill:#66401E;" d="M50.028,408C96.656,471.08,171.54,512,256,512s159.344-40.92,205.972-104H50.028z"/>
<path style="fill:#F5F5F5;" d="M284,268c-22.092,0-40,17.908-40,40s17.908,40,40,40s40-17.908,40-40S306.092,268,284,268z M284,328
	c-11.048,0-20-8.952-20-20s8.952-20,20-20s20,8.952,20,20S295.048,328,284,328z"/>
<g>
	<path style="fill:#E6E6E6;" d="M280,288.408c-1.292-0.268-2.628-0.408-4-0.408c-11.048,0-20,8.952-20,20s8.952,20,20,20
		c1.372,0,2.708-0.14,4-0.408c-9.128-1.852-16-9.916-16-19.592S270.872,290.256,280,288.408z"/>
	<path style="fill:#E6E6E6;" d="M284,268c-1.348,0-2.684,0.072-4,0.2c20.212,2.008,36,19.06,36,39.8s-15.788,37.792-36,39.8
		c1.316,0.128,2.652,0.2,4,0.2c22.092,0,40-17.908,40-40S306.092,268,284,268z"/>
</g>
<path style="fill:#F5F5F5;" d="M276,272c0,6.6-5.4,12-12,12H80c-6.6,0-12-5.4-12-12v-48c0-6.6,5.4-12,12-12h184c6.6,0,12,5.4,12,12
	V272z"/>
<path style="fill:#E6E6E6;" d="M264,212h-12c6.6,0,12,5.4,12,12v48c0,6.6-5.4,12-12,12h12c6.6,0,12-5.4,12-12v-48
	C276,217.4,270.6,212,264,212z"/>
<polygon style="fill:#F5F5F5;" points="244,408 100,408 88,284 256,284 "/>
<g>
	<polygon style="fill:#E6E6E6;" points="244,284 232,408 244,408 256,284 	"/>
	<polygon style="fill:#E6E6E6;" points="255.228,292 256,284 88,284 88.772,292 	"/>
	<path style="opacity:0.3;fill:#E6E6E6;enable-background:new    ;" d="M176,52c-4,52,56,64,4,124C204,140,140,108,176,52z"/>
	<path style="opacity:0.2;fill:#E6E6E6;enable-background:new    ;" d="M136,100c4,44,48,52,4,96C156,172,108,144,136,100z"/>
</g>
<path style="fill:#F5F5F5;" d="M482.14,376H324c-4.4,0-8,3.6-8,8v16c0,4.4,3.6,8,8,8h137.972
	C469.452,397.88,476.192,387.184,482.14,376z"/>
<path style="opacity:0.2;fill:#E6E6E6;enable-background:new    ;" d="M220,100c4,44,48,52,4,96C240,172,192,144,220,100z"/>
<path style="fill:#242424;" d="M479.964,380H312v24h152.816C470.28,396.296,475.36,388.3,479.964,380z"/>
<g>
	<circle style="fill:#F5F5F5;" cx="380" cy="392" r="8"/>
	<circle style="fill:#F5F5F5;" cx="404" cy="392" r="8"/>
	<path style="fill:#F5F5F5;" d="M352,396h-12c-2.208,0-4-1.792-4-4s1.792-4,4-4h12c2.208,0,4,1.792,4,4S354.208,396,352,396z"/>
</g>
<g>
</g>
<g>
</g>
<g>
</g>
<g>
</g>
<g>
</g>
<g>
</g>
<g>
</g>
<g>
</g>
<g>
</g>
<g>
</g>
<g>
</g>
<g>
</g>
<g>
</g>
<g>
</g>
<g>
</g>
</svg>
]])

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