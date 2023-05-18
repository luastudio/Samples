--Main.lua (WARNING: require internet connection)

--[[Based on:

Globe example in Away3d
Demonstrates:
How to create a textured sphere.
How to use containers to rotate an object.
How to use the PhongBitmapMaterial.

Code by Rob Bateman
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk
The skybox is "Purple Nebula", created by David Bronke for the RFI MMORPG project.
https://github.com/SkewedAspect/rfi-content/tree/master/source/skybox/textures

This code is distributed under the MIT License
Copyright (c) The Away Foundation http://www.theawayfoundation.org
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]

Thread = Lib.Sys.VM.Thread
Display = Lib.Media.Display
Events = Lib.Media.Events
BitmapData = Display.BitmapData
Bitmap = Display.Bitmap
Geom = Lib.Media.Geom
Away3D = Lib.Away3D
View3D = Away3D.Containers.View3D
Scene3D = Away3D.Containers.Scene3D
Camera3D = Away3D.Cameras.Camera3D
Textures = Away3D.Textures
PointLight = Away3D.Lights.PointLight
Primitives = Away3D.Primitives
Materials = Away3D.Materials
Mesh = Away3D.Entities.Mesh
TextureMaterial = Materials.TextureMaterial
HoverController = Away3D.Controllers.HoverController
ObjectContainer3D = Away3D.Containers.ObjectContainer3D
Cast = Away3D.Utils.Cast
Debug = Away3D.Debug
stage = Display.stage

--For mobile devices AGAL shader fragment precision set to medium by default.
--High value can slow down rendering speed on some devicess or may not support it at all. 
--This sample require high fragment precision. Option will be deprecated when most devices can work with high precision properly and we can change default value to high. 
Away3D.Config.OpenGL_ES.FRAGMENT_PRECISION_HIGH = true


function loadAssetsFromWebInThread()
    local t = Thread.create([[
Thread = Lib.Sys.VM.Thread
Cast = Lib.Away3D.Utils.Cast
require("/Common/Utils.lua")
Assets.Web.log = true
--Assets.Web.cache = true
--get ref to main
local main = Thread.readMessage(true)
main.sendMessage({

    flare1 = Assets.Web.getBytes("/3D/Away3D/Intermediate_Globe/assets/lensflare/flare10.jpg"),
    flare2 = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_Globe/assets/lensflare/flare11.jpg")),
    flare3 = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_Globe/assets/lensflare/flare7.jpg")),
    flare4 = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_Globe/assets/lensflare/flare7.jpg")),
    flare5 = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_Globe/assets/lensflare/flare12.jpg")),
    flare6 = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_Globe/assets/lensflare/flare6.jpg")),
    flare7 = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_Globe/assets/lensflare/flare2.jpg")),
    flare8 = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_Globe/assets/lensflare/flare3.jpg")),
    flare9 = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_Globe/assets/lensflare/flare4.jpg")),
    flare10 = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_Globe/assets/lensflare/flare8.jpg")),
    flare11 = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_Globe/assets/lensflare/flare6.jpg")),
    flare12 = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_Globe/assets/lensflare/flare7.jpg")),

    groundMaterialBT = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_Globe/assets/globe/land_ocean_ice_2048_match.jpg")),
    earthNormalBT = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_Globe/assets/globe/EarthNormal.png")),
    landLightsBT = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_Globe/assets/globe/land_lights_16384.jpg")),
    cloudCombinedBT = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_Globe/assets/globe/cloud_combined_2048.jpg")),
    earthSpecularBT = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_Globe/assets/globe/earth_specular_2048.jpg")),

    space_posX = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_PlanarReflection/assets/skybox/space_posX.jpg")), -- left
    space_negX = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_PlanarReflection/assets/skybox/space_negX.jpg")), -- right
    space_posY = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_PlanarReflection/assets/skybox/space_posY.jpg")), -- top
    space_negY = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_PlanarReflection/assets/skybox/space_negY.jpg")), -- bottom
    space_posZ = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_PlanarReflection/assets/skybox/space_posZ.jpg")), -- back
    space_negZ = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_PlanarReflection/assets/skybox/space_negZ.jpg"))  -- front
})
]])
    t.sendMessage(Thread.current())
end

flares = {}
--navigation variables
move = false --Bool
lastPanAngle = 0 --Float
lastTiltAngle = 0 --Float
lastMouseX = 0 --Float
lastMouseY = 0 --Float
mouseLockX = 0 --Float
mouseLockY = 0 --Float
mouseLocked = false --Bool
flareVisible = false --Bool

local FlareObject = {}
function FlareObject.new(bitmapData, size, position, opacity)
    local self = {}

    self.flareSize = 144 --Int
    self.sprite = nil --Bitmap
    self.size = 0 --Float
    self.position = 0 --Float
    self.opacity = 0 --Float

    self.sprite = Bitmap.new(BitmapData.new(bitmapData.width, bitmapData.height, false, 0xFFFFFFFF, nil), Display.PixelSnapping.AUTO, true)
    self.sprite.bitmapData.copyChannel(bitmapData, bitmapData.rect, Geom.Point.new(0, 0),
            Display.BitmapDataChannel.RED, Display.BitmapDataChannel.ALPHA)
    self.sprite.alpha = opacity/100
    self.sprite.smoothing = true
    self.sprite.scaleX = size*self.flareSize/bitmapData.width
    self.sprite.scaleY = self.sprite.scaleX
    self.size = size
    self.position = position
    self.opacity = opacity

    return self
end

function initEngine()
    scene = Scene3D.new()

    --setup camera for optimal skybox rendering
    camera = Camera3D.new(nil)
    camera.lens.far = 100000

    view = View3D.new()
    view.scene = scene
    view.camera = camera

    --setup controller to be used on the camera
    cameraController = HoverController.new(camera, nil, 0, 0, 600, -90, 90, nil, nil, 8,  2, false)
    cameraController.yFactor = 1

    stage.addChild(view)

    -- stats
    stage.addChild(Debug.AwayFPS.new(view, 10, 10, 0xffffff, 3))
end

function initLights()
    light = PointLight.new()
    light.x = 10000
    light.ambient = 1
    light.diffuse = 2

    lightPicker = Materials.LightPickers.StaticLightPicker.new({light})
end

function initLensFlare()
    flares[1] = FlareObject.new(Cast.bitmapData(assets.flare1),  3.2, -0.01, 147.9)
    flares[2] = FlareObject.new(assets.flare2,  6,    0,     30.6)
    flares[3] = FlareObject.new(assets.flare3,   2,    0,     25.5)
    flares[4] = FlareObject.new(assets.flare4,   4,    0,     17.85)
    flares[5] = FlareObject.new(assets.flare5,  0.4,  0.32,  22.95)
    flares[6] = FlareObject.new(assets.flare6,   1,    0.68,  20.4)
    flares[7] = FlareObject.new(assets.flare7,   1.25, 1.1,   48.45)
    flares[8] = FlareObject.new(assets.flare8,   1.75, 1.37,   7.65)
    flares[9] = FlareObject.new(assets.flare9,   2.75, 1.85,  12.75)
    flares[10] = FlareObject.new(assets.flare10,   0.5,  2.21,  33.15)
    flares[11] = FlareObject.new(assets.flare11,   4,    2.5,   10.4)
    flares[12] = FlareObject.new(assets.flare12,   10,   2.66,  50)
end

function modulateDiffuseMethod(vo, t, regCache, sharedRegisters)
    local viewDirFragmentReg = atmosphereDiffuseMethod.sharedRegisters.viewDirFragment
    local normalFragmentReg= atmosphereDiffuseMethod.sharedRegisters.normalFragment

    local code = "dp3 " .. t.toString() .. ".w, " .. viewDirFragmentReg.toString() .. ".xyz, " .. normalFragmentReg.toString() .. ".xyz\n" ..
                 "mul " .. t.toString() .. ".w, " .. t.toString() .. ".w, " .. t.toString() .. ".w\n"

    return code
end

function modulateSpecularMethod(vo, t, regCache, sharedRegisters)
    local viewDirFragmentReg = atmosphereDiffuseMethod.sharedRegisters.viewDirFragment
    local normalFragmentReg = atmosphereDiffuseMethod.sharedRegisters.normalFragment
    local temp = regCache.getFreeFragmentSingleTemp()
    regCache.addFragmentTempUsages(temp, 1)

    local code = "dp3 " .. temp.toString() .. ", " .. viewDirFragmentReg.toString() .. ".xyz, " .. normalFragmentReg.toString() .. ".xyz\n" ..
                 "neg " .. temp.toString() .. ", " .. temp.toString() .. "\n" ..
                 "mul " .. t.toString() .. ".w, " .. t.toString() .. ".w, " .. temp.toString() .. "\n"

    regCache.removeFragmentTempUsage(temp)

    return code
end

function initMaterials()
    cubeTexture = Textures.BitmapCubeTexture.new(
            assets.space_posX, assets.space_negX, assets.space_posY,
            assets.space_negY, assets.space_posZ, assets.space_negZ 
    )

    local specBitmap = assets.earthSpecularBT
    specBitmap.colorTransform(specBitmap.rect, Geom.ColorTransform.new(1, 1, 1, 1, 64, 64, 64, 0))

    local specular = Materials.Methods.FresnelSpecularMethod.new(true, Materials.Methods.PhongSpecularMethod.new())
    specular.fresnelPower = 1
    specular.normalReflectance = 0.1

    sunMaterial = TextureMaterial.new(Cast.bitmapTexture(assets.flare1), true, false, true, nil)
    sunMaterial.blendMode = Display.BlendMode.ADD

    groundMaterial = TextureMaterial.new(assets.groundMaterialBT, true, false, true, nil)
    groundMaterial.specularMethod = specular
    groundMaterial.specularMap = Textures.BitmapTexture.new(specBitmap, true)
    groundMaterial.normalMap = assets.earthNormalBT
    groundMaterial.ambientTexture = assets.landLightsBT
    groundMaterial.lightPicker = lightPicker
    groundMaterial.gloss = 5
    groundMaterial.specular = 1
    groundMaterial.ambientColor = 0xFFFFFF
    groundMaterial.ambient = 1

    local skyBitmap = BitmapData.new(2048, 1024, false, 0xFFFFFFFF, nil)
Lib.Sys.trace(assets.cloudCombinedBT)
    skyBitmap.copyChannel(assets.cloudCombinedBT,
            skyBitmap.rect, Geom.Point.new(0, 0), Display.BitmapDataChannel.RED, Display.BitmapDataChannel.ALPHA)

    cloudMaterial = TextureMaterial.new(Textures.BitmapTexture.new(skyBitmap, true), true, false, true, nil)
    cloudMaterial.alphaBlending = true
    cloudMaterial.lightPicker = lightPicker
    cloudMaterial.specular = 0
    cloudMaterial.ambientColor = 0x1b2048
    cloudMaterial.ambient = 1

    atmosphereDiffuseMethod = Materials.Methods.CompositeDiffuseMethod.new(modulateDiffuseMethod, nil)
    atmosphereSpecularMethod = Materials.Methods.CompositeSpecularMethod.new(modulateSpecularMethod, Materials.Methods.PhongSpecularMethod.new())

    atmosphereMaterial = Materials.ColorMaterial.new(0x1671cc, 1)
    atmosphereMaterial.diffuseMethod = atmosphereDiffuseMethod
    atmosphereMaterial.specularMethod = atmosphereSpecularMethod
    atmosphereMaterial.blendMode = Display.BlendMode.ADD
    atmosphereMaterial.lightPicker = lightPicker
    atmosphereMaterial.specular = 0.5
    atmosphereMaterial.gloss = 5
    atmosphereMaterial.ambientColor = 0x0
    atmosphereMaterial.ambient = 1
end

function initObjects()
    orbitContainer = ObjectContainer3D.new()
    orbitContainer.addChild(light)
    scene.addChild(orbitContainer)

    sun = Away3D.Entities.Sprite3D.new(sunMaterial, 3000, 3000)
    sun.x = 10000
    orbitContainer.addChild(sun)

    earth = Mesh.new(Primitives.SphereGeometry.new(200, 200, 100, true), groundMaterial)

    clouds = Mesh.new(Primitives.SphereGeometry.new(202, 200, 100, true), cloudMaterial)

    atmosphere = Mesh.new(Primitives.SphereGeometry.new(210, 200, 100, true), atmosphereMaterial)
    atmosphere.scaleX = -1

    tiltContainer = ObjectContainer3D.new()
    tiltContainer.rotationX = -23
    tiltContainer.addChild(earth)
    tiltContainer.addChild(clouds)
    tiltContainer.addChild(atmosphere)

    scene.addChild(tiltContainer)

    cameraController.lookAtObject = tiltContainer

    --create a skybox
    skyBox = Primitives.SkyBox.new(cubeTexture)
    scene.addChild(skyBox)
end

function updateFlares()
    local flareVisibleOld = flareVisible

    local sunScreenPosition = view.project(sun.scenePosition)
    local xOffset = sunScreenPosition.x - stage.stageWidth/2
    local yOffset = sunScreenPosition.y - stage.stageHeight/2

    local earthScreenPosition = view.project(earth.scenePosition)
    local earthRadius = 190*stage.stageHeight/earthScreenPosition.z
    local flareObject --FlareObject

    flareVisible = (sunScreenPosition.x > 0 and
            sunScreenPosition.x < stage.stageWidth and
            sunScreenPosition.y > 0 and
            sunScreenPosition.y  < stage.stageHeight and
            sunScreenPosition.z > 0 and
            math.sqrt(xOffset*xOffset + yOffset*yOffset) > earthRadius) and true or false

    --update flare visibility
    if flareVisible ~= flareVisibleOld then
        for i=1, #flares, 1 do
            flareObject = flares[i]
            if flareVisible then
                stage.addChild(flareObject.sprite)
            else
                stage.removeChild(flareObject.sprite)
            end
        end
    end

    --update flare position
    if flareVisible then
        local flareDirection = Geom.Point.new(xOffset, yOffset)
        for i=1, #flares, 1 do
            flareObject = flares[i]
            flareObject.sprite.x = sunScreenPosition.x - flareDirection.x*flareObject.position - flareObject.sprite.width/2;
            flareObject.sprite.y = sunScreenPosition.y - flareDirection.y*flareObject.position - flareObject.sprite.height/2;
        end
    end
end

function initListeners()
    view.setRenderCallback(function(rect)
        earth.rotationY = earth.rotationY - 0.2
        clouds.rotationY = clouds.rotationY - 0.23
        --orbitContainer.rotationY = orbitContainer.rotationY + 0.02

        if move then
            cameraController.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle
            cameraController.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle
        end

        view.render()

        updateFlares()
    end)

    touchDistanceOld = -1

    stage.addEventListener(Events.MouseEvent.MOUSE_DOWN, function(e)
        if touchDistanceOld ~= -1 then return end
        lastPanAngle = cameraController.panAngle
        lastTiltAngle = cameraController.tiltAngle
        lastMouseX = stage.mouseX
        lastMouseY = stage.mouseY
        move = true
    end , false, 0, false)
    stage.addEventListener(Events.MouseEvent.MOUSE_UP, function(e)
        move = false
    end , false, 0, false)
    zoom = function(delta)
        cameraController.distance = cameraController.distance - delta*5

        if cameraController.distance < 400 then
            cameraController.distance = 400
        elseif cameraController.distance > 10000 then
            cameraController.distance = 10000
        end
    end
    stage.addEventListener(Events.MouseEvent.MOUSE_WHEEL, function(e)
		zoom(e.delta)
    end , false, 0, false)

    if Lib.Media.UI.Multitouch.supportsTouchEvents then
	    Lib.Media.UI.Multitouch.inputMode = Lib.Media.UI.MultitouchInputMode.TOUCH_POINT

		primaryTouch = nil
		primaryTouchX = -1
		primaryTouchY = -1
        secondaryTouch = nil
		secondaryTouchX = -1
		secondaryTouchY = -1

		stage.addEventListener(Events.TouchEvent.TOUCH_BEGIN, 
			function(e)
				if primaryTouch == nil then 
					primaryTouch = e.touchPointID 
					primaryTouchX = e.stageX
					primaryTouchY = e.stageY 
				else 
					secondaryTouch = e.touchPointID 
					secondaryTouchX = e.stageX
					secondaryTouchY = e.stageY 
				end
			end, false, 0, false)
		stage.addEventListener(Events.TouchEvent.TOUCH_MOVE, 
			function(e)
				if secondaryTouch ~= nil and  primaryTouch ~= nil then
					if e.touchPointID == primaryTouch then
						primaryTouchX = e.stageX
						primaryTouchY = e.stageY 
                    end
					if e.touchPointID == secondaryTouch then
						secondaryTouchX = e.stageX
						secondaryTouchY = e.stageY 
                    end
					local touchDeltaX =  secondaryTouchX - primaryTouchX
	                local touchDeltaY =  secondaryTouchY - primaryTouchY
	                local touchDistance = math.sqrt(touchDeltaX * touchDeltaX + touchDeltaY * touchDeltaY)
					if touchDistanceOld == -1 then
                    	touchDistanceOld = touchDistance
	                    return
	                end
                    move = false
					zoom(Lib.Media.Capabilities.screenDPI * (touchDistance - touchDistanceOld) / 100000)
				end 
			end, false, 0, false)
		stage.addEventListener(Events.TouchEvent.TOUCH_END, 
			function(e)
				if e.touchPointID == primaryTouch then primaryTouch = nil touchDistanceOld = -1 end
				if e.touchPointID == secondaryTouch then secondaryTouch = nil touchDistanceOld = -1 end
			end, false, 0, false)
	end

    local onResize = function(e)
        view.width = stage.stageWidth
        view.height = stage.stageHeight
    end
    stage.addEventListener(Events.Event.RESIZE, onResize, false, 0, false)
    onResize()
end

function init()
    initEngine()
    initLights()
    initLensFlare()
    initMaterials()
    initObjects()
    initListeners()
end

loadAssetsFromWebInThread()

function frameEvent(e)
    assets = Thread.readMessage(false)
    if assets ~= nil then
        Lib.Media.Display.stage.removeEventListener(Lib.Media.Events.Event.ENTER_FRAME, frameEvent, false)

        init()
    end
end

--wait for thread to finish
Lib.Media.Display.stage.addEventListener(Lib.Media.Events.Event.ENTER_FRAME, frameEvent, false, 0, false)