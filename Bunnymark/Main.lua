Text = Lib.Media.Text
Events = Lib.Media.Events
Display = Lib.Media.Display
BitmapData = Display.BitmapData
Bitmap = Display.Bitmap
Geom = Lib.Media.Geom
stage = Display.stage

if type(jit) == 'table' then
  bit32 = bit
end

local Env = {
    dpi = 1,
    width = 0,
    height = 0
}

local maxX = 0
local minX = 0
local maxY = 0
local minY = 0
local numBunnies = 1000
local gravity = 0.5
local times = {}
local tf, fps

local cols = 8
local rows = 12

local Bunny = {}
function Bunny.new()
    local self = {}

    self.speedX = 0
    self.speedY = 0
    self.position = nil
    self.rotation = 0
    self.scale = 0
    self.alpha = 0

    return self
end

bunnies = {}
drawList = {}

local texture = BitmapData.loadFromBytes(Lib.Project.getBytes("/Bunnymark/assets/grass.png"), nil)
local vertices = {}
local uvt = {}
local indices = {}
local function buildBackground()
    local sw = Env.width + 100
    local sh = Env.height + 100
    local uw = sw / texture.width
    local uh = sh / texture.height
    local kx, ky
    local ci, ci2, ri

    for j=0, rows, 1 do
        ri = j * (cols + 1) * 2
        ky = j / rows
        for i=0, cols, 1 do
            ci = ri + i * 2
            kx = i / cols
            vertices[1 + ci] = sw * kx - 50
            vertices[1 + ci + 1] = sh * ky - 50
            uvt[1 + ci] = uw * kx
            uvt[1 + ci + 1] = uh * ky
        end
    end

    local indicesIdx = 1
    for j=0, rows-1, 1 do
        ri = j * (cols + 1)
        for i=0, cols-1, 1 do
            ci = i + ri
            ci2 = ci + cols + 1
            indices[indicesIdx] = ci;
            indices[indicesIdx + 1] = ci + 1
            indices[indicesIdx + 2] = ci2
            indices[indicesIdx + 3] = ci + 1
            indices[indicesIdx + 4] = ci2 + 1
            indices[indicesIdx + 5] = ci2
            indicesIdx = indicesIdx + 6
        end
    end
end

function createCounter()
    local format = Text.TextFormat.new("_sans", 20, 0, true, false, false)
    format.align = Text.TextFormatAlign.LEFT

    tf = Text.TextField.new()
    tf.selectable = false
    tf.defaultTextFormat = format
    tf.width = 200
    tf.height = 60
    tf.x = maxX - tf.width - 10
    tf.y = 10
    stage.addChild(tf)

    fps = Text.TextField.new()
    fps.selectable = false
    fps.defaultTextFormat = format
    fps.width = 150
    fps.x = 10
    fps.y = 10
    stage.addChild(fps)

    tf.addEventListener(Events.MouseEvent.CLICK, function(e)
        counter_click()
    end, false, 0, false)
end

function counter_click()
	local incBunnies = 100
	if numBunnies >= 1500 then incBunnies = 250 end
    local more = numBunnies + incBunnies

    for i=numBunnies + 1, more, 1 do
	    local bunny = Bunny:new()
	    bunny.position = {x = 0, y = 0}
	    bunny.speedX = math.random() * 5
	    bunny.speedY = (math.random() * 5) - 2.5
	    bunny.scale = 0.3 + math.random()
	    bunny.rotation = 15 - math.random() * 30
	    bunnies[i] = bunny
    end
	numBunnies = more

	stage_resize()
end

function stage_resize ()
    print("resize ...")
    Env.width = math.ceil(stage.stageWidth / Env.dpi)
    Env.height = math.ceil(stage.stageHeight / Env.dpi)
    maxX = Env.width
    maxY = Env.height

    buildBackground()

    if(tf ~= nil) then
        tf.text = "Bunnies:\n"..numBunnies
        tf.x = maxX - tf.width - 10
    end
end

createCounter()
stage_resize()

local bunnyAsset = BitmapData.loadFromBytes(Lib.Project.getBytes("/Bunnymark/assets/wabbit_alpha.png"), nil)
local pirate = Bitmap.new(BitmapData.loadFromBytes(Lib.Project.getBytes("/Bunnymark/assets/pirate.png"), nil), Display.PixelSnapping.AUTO, true)
pirate.scaleX = Env.height / 768
pirate.scaleY = Env.height / 768
stage.addChild(pirate)

local tilesheet = Display.Tilesheet.new(bunnyAsset)
tilesheet.addTileRect(Geom.Rectangle.new(0, 0, bunnyAsset.width, bunnyAsset.height), Geom.Point.new(0, 0))

--drawList = nme.Array.new()
for i=1, numBunnies, 1 do
    local bunny = Bunny:new()
    bunny.position = {x = 0, y = 0}
    bunny.speedX = math.random() * 5
    bunny.speedY = (math.random() * 5) - 2.5
    bunny.scale = 0.3 + math.random()
    bunny.rotation = 15 - math.random() * 30
    bunnies[i] = bunny
end

stage.addEventListener(Events.Event.RESIZE,
    function (e)
        stage_resize()
    end, false, 0, false)

local tileFlag = bit32.bor(Display.Tilesheet.TILE_SCALE, Display.Tilesheet.TILE_ROTATION, Display.Tilesheet.TILE_ALPHA)
local timesLen = 0
local graphics = stage.graphics
local graphicsClear = graphics.clear
local graphicsBeginBitmapFill = graphics.beginBitmapFill
local graphicsDrawTriangles = graphics.drawTriangles
local graphicsEndFill = graphics.endFill
local getTime = Lib.Sys.getTime
local drawTiles = tilesheet.drawTiles
local TILE_FIELDS = 6

stage.addEventListener(Events.Event.ENTER_FRAME,
    function (e)
        graphicsClear()

        local t = getTime()
        local now = t / 1000.0

        --background
        local sw = Env.width + 100
        local sh = Env.height + 100
        local kx, ky
        local ci, ri
        for j=0, rows, 1 do
            ri = j * (cols + 1) * 2
            for i=0, cols, 1 do
                ci = ri + i * 2
                kx = i / cols + math.cos(now + i) * 0.02
                ky = j / rows + math.sin(now + j + i) * 0.02
                vertices[1 + ci] = sw * kx - 50
                vertices[1 + ci + 1] = sh * ky - 50
            end
        end
        graphicsBeginBitmapFill(texture, nil, true, false)
        graphicsDrawTriangles(vertices, indices, uvt, nil, nil, 0)
        --graphicsEndFill()

        local bunny
        for i = 1, numBunnies, 1 do
            bunny = bunnies[i]
            local position = bunny.position
            position.x = position.x + bunny.speedX
            position.y = position.y + bunny.speedY
            bunny.speedY = bunny.speedY + gravity
            bunny.alpha = 0.3 + 0.7 * position.y / maxY

            if position.x > maxX then
                bunny.speedX = bunny.speedX * -1
                position.x = maxX
            elseif position.x < minX then
                bunny.speedX = bunny.speedX * -1
                position.x = minX
            end

            if position.y > maxY then
                bunny.speedY = bunny.speedY * -0.8
                position.y = maxY
                if math.random() > 0.5 then bunny.speedY = bunny.speedY - (3 + math.random() * 4) end
            elseif position.y < minY then
                bunny.speedY = 0
                position.y = minY
            end

            local index = (i-1) * TILE_FIELDS + 1
            drawList[index] = position.x
            drawList[index + 1] = position.y
            drawList[index + 2] = 0 -- sprite index
            drawList[index + 3] = bunny.scale
            drawList[index + 4] = bunny.rotation
            drawList[index + 5] = bunny.alpha
        end --end for

        drawTiles(graphics, drawList, smooth, tileFlag, -1)

        pirate.x = (Env.width - pirate.width) * (0.5 + 0.5 * math.sin(t / 3000))
        pirate.y = Env.height - pirate.height + 70 - 30 * math.sin(t / 100)
        --FPS
        --times[#times+1] = now
        timesLen = timesLen + 1
        times[timesLen] = now
        while times[1]<now-1 do
            table.remove(times, 1)
            timesLen = timesLen - 1
        end

        fps.text = "Frame rate: "..timesLen
    end, false, 0, false)