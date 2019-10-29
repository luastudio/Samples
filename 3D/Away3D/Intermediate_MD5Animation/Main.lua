--Main.lua (WARNING: require internet connection)

--[[Based on:

MD5 animation loading and interaction example in Away3d

Demonstrates:

How to load MD5 mesh and anim files with bones animation from web resources.
How to map animation data after loading in order to playback an animation sequence.
How to control the movement of a game character using keys and screen arrows.

Code by Rob Bateman & David Lenaerts
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk
david.lenaerts@gmail.com
http://www.derschmale.com

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
]]--

-- declarations
Display = Lib.Media.Display
Sprite = Display.Sprite
Events = Lib.Media.Events
Away3D = Lib.Away3D
Animators = Away3D.Animators
View3D = Away3D.Containers.View3D
Scene3D = Away3D.Containers.Scene3D
Mesh = Away3D.Entities.Mesh
SegmentSet = Away3D.Entities.SegmentSet
Materials = Away3D.Materials
Primitives = Away3D.Primitives
Camera3D = Away3D.Cameras.Camera3D
Lenses = Away3D.Cameras.Lenses
PointLight = Away3D.Lights.PointLight
DirectionalLight = Away3D.Lights.DirectionalLight
Textures = Away3D.Textures
LookAtController = Away3D.Controllers.LookAtController
ObjectContainer3D = Away3D.Containers.ObjectContainer3D
Cast = Away3D.Utils.Cast
Debug = Away3D.Debug
Keyboard = Lib.Media.UI.Keyboard
stage = Display.stage
Thread = Lib.Sys.VM.Thread

isRunning = false
isMoving = false
movementDirection = 0.0
onceAnim = nil
currentAnim = nil
count = 0.0
currentRotationInc = 0.0

IDLE_NAME = "idle2"
WALK_NAME = "walk7"
ANIM_NAMES = {IDLE_NAME, WALK_NAME, "attack3", "turret_attack", "attack2", "chest", "roar1", "leftslash", "headpain", "pain1", "pain_luparm", "range_attack2"}
ANIM_CLASSES = {}
ROTATION_SPEED = 3.0
RUN_SPEED = 2.0
WALK_SPEED = 1.0
IDLE_SPEED = 1.0
ACTION_SPEED = 1.0

function loadAssetsFromWebInThread()
    local t = Thread.create([[
Thread = Lib.Sys.VM.Thread
Cast = Lib.Away3D.Utils.Cast
require("/Common/Utils.lua")
Assets.Web.log = true
--get ref to main
local main = Thread.readMessage(true)
main.sendMessage({

    redlight = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/redlight.png")),
    bluelight = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/bluelight.png")),
    rockbase_diffuse = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/rockbase_diffuse.jpg")),
    rockbase_normals = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/rockbase_normals.png")),
    rockbase_specular = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/rockbase_specular.png")),
    hellknight_diffuse = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/hellknight/hellknight_diffuse.jpg")),
    hellknight_specular = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/hellknight/hellknight_specular.png")),
    hellknight_normals = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/hellknight/hellknight_normals.png")),
    grimnight_posX = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/skybox/grimnight_posX.png")), -- left
    grimnight_negX = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/skybox/grimnight_negX.png")), -- right
    grimnight_posY = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/skybox/grimnight_posY.png")), -- top
    grimnight_negY = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/skybox/grimnight_negY.png")), -- bottom
    grimnight_posZ = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/skybox/grimnight_posZ.png")), -- back
    grimnight_negZ = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/skybox/grimnight_negZ.png")),  -- front

    hellknight = Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/hellknight/hellknight.md5mesh"),
    idle2 = Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/hellknight/idle2.md5anim"),
    walk7 = Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/hellknight/walk7.md5anim"),
    attack3 = Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/hellknight/attack3.md5anim"),
    turret_attack = Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/hellknight/turret_attack.md5anim"),
    attack2 = Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/hellknight/attack2.md5anim"),
    chest = Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/hellknight/chest.md5anim"),
    roar1 = Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/hellknight/roar1.md5anim"),
    leftslash = Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/hellknight/leftslash.md5anim"),
    headpain = Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/hellknight/headpain.md5anim"),
    pain1 = Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/hellknight/pain1.md5anim"),
    pain_luparm = Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/hellknight/pain_luparm.md5anim"),
    range_attack2 = Assets.Web.getBytes("/3D/Away3D/Intermediate_MD5Animation/assets/hellknight/range_attack2.md5anim")

})
]])
    t.sendMessage(Thread.current())
end

function initEngine()
    view = View3D.new()
    scene = view.scene
    camera = view.camera

    camera.lens.far = 5000
    camera.z = -200
    camera.y = 160

    --setup controller to be used on the camera
    placeHolder = ObjectContainer3D.new()
    placeHolder.y = 50
    cameraController = LookAtController.new(camera, placeHolder)

    stage.addChild(view)

    stage.addChild(Debug.AwayFPS.new(_view, 10, 10, 0xffffff, 3))
end

function initLights()
    --create a light for shadows that mimics the sun's position in the skybox
	redLight = PointLight.new()
    redLight.x = -1000
	redLight.y = 200
	redLight.z = -1400
	redLight.color = 0xff1111
	scene.addChild(redLight)

    blueLight = PointLight.new()
	blueLight.x = 1000
	blueLight.y = 200
	blueLight.z = 1400
	blueLight.color = 0x1111ff
    scene.addChild(blueLight)

    whiteLight = DirectionalLight.new(-50, -20, 10)
    whiteLight.color = 0xffffee
    --whiteLight.castsShadows = true -- shadows currently not working
    whiteLight.ambient = 1
    whiteLight.ambientColor = 0x303040
    --whiteLight.shadowMapper = Away3D.Lights.ShadowMaps.NearDirectionalShadowMapper.new(.2)
    scene.addChild(whiteLight)

    lightPicker = Materials.LightPickers.StaticLightPicker.new({redLight, blueLight, whiteLight})

    --create a global shadow method
    --shadowMapMethod = Materials.Methods.NearShadowMapMethod.new(
    --        Materials.Methods.FilteredShadowMapMethod.new(whiteLight), 0.1)
    --shadowMapMethod.epsilon = .1

    --create a global fog method
    fogMethod = Materials.Methods.FogMethod.new(0, camera.lens.far*0.5, 0x000000)
end

function initMaterials()
    --red light material
    redLightMaterial = Materials.TextureMaterial.new(assets.redlight, true, false, true, nil)
    redLightMaterial.alphaBlending = true
    redLightMaterial.addMethod(fogMethod)

    --blue light material
    blueLightMaterial = Materials.TextureMaterial.new(assets.bluelight, true, false, true, nil)
    blueLightMaterial.alphaBlending = true
    blueLightMaterial.addMethod(fogMethod)

    --ground material
    groundMaterial = Materials.TextureMaterial.new(assets.rockbase_diffuse, true, false, true, nil)
    groundMaterial.smooth = true
    groundMaterial['repeat'] = true
    groundMaterial.mipmap = true
    groundMaterial.lightPicker = lightPicker
    groundMaterial.normalMap = assets.rockbase_normals
    groundMaterial.specularMap = assets.rockbase_specular
    --groundMaterial.shadowMethod = shadowMapMethod -- shadows currently not working
    groundMaterial.addMethod(fogMethod)

    --body material
    bodyMaterial = Materials.TextureMaterial.new(assets.hellknight_diffuse, true, false, true, nil)
    bodyMaterial.gloss = 20
    bodyMaterial.specular = 1.5
    bodyMaterial.specularMap = assets.hellknight_specular
    bodyMaterial.normalMap = assets.hellknight_normals
    bodyMaterial.addMethod(fogMethod)
    bodyMaterial.lightPicker = lightPicker
    --bodyMaterial.shadowMethod = shadowMapMethod -- shadows currently not working
end

function stop()
    isMoving = false

    if currentAnim == IDLE_NAME then
        return
    end

    currentAnim = IDLE_NAME

    if onceAnim ~= nil then
        return
    end

    --update animator
    animator.playbackSpeed = IDLE_SPEED
    animator.play(currentAnim, stateTransition, nil)
end

function updateMovement(dir)
    isMoving = true
    animator.playbackSpeed = dir*(isRunning and RUN_SPEED or WALK_SPEED)

    if currentAnim == WALK_NAME then
        return
    end

    currentAnim = WALK_NAME

    if onceAnim ~= nil then
        return
    end

    --update animator
    animator.play(currentAnim, stateTransition, nil)
end

function playAction(val)
    onceAnim = ANIM_NAMES[val + 2]
    animator.playbackSpeed = ACTION_SPEED
    animator.play(onceAnim, stateTransition, 0)
end

function initNavigation()
    size = (stage.stageWidth > stage.stageHeight and stage.stageWidth or stage.stageHeight)  / 6

    spriteNavigation = Sprite.new()
    stage.addChild(spriteNavigation)

    local sprite = Sprite.new()
    sprite.name = "up"
    sprite.graphics.lineStyle(2, 0x00FF00, 1.0, false, nil, nil, nil, 3)
    sprite.graphics.beginFill(0xFFFF00, 1.0)
    sprite.graphics.moveTo(0 + size / 2, 0)
    sprite.graphics.lineTo(0 + size / 3, 0 + size / 3)
    sprite.graphics.lineTo(0 + 2 * size / 3, 0 + size / 3)
    sprite.graphics.lineTo(0 + size / 2,0)
    sprite.graphics.endFill()
    sprite.buttonMode = true
    spriteNavigation.addChild(sprite)

    sprite = Sprite.new()
    sprite.name = "left"
    sprite.graphics.lineStyle(2, 0x00FF00, 1.0, false, nil, nil, nil, 3)
    sprite.graphics.beginFill(0xFFFF00, 1.0)
    sprite.graphics.moveTo(0, 0 + size / 2)
    sprite.graphics.lineTo(0 + size / 3, 0 + size / 3)
    sprite.graphics.lineTo(0 + size / 3, 0 + 2 * size / 3)
    sprite.graphics.lineTo(0, 0 + size / 2)
    sprite.graphics.endFill()
    sprite.buttonMode = true
    spriteNavigation.addChild(sprite)

    sprite = Sprite.new()
    sprite.name = "down"
    sprite.graphics.lineStyle(2, 0x00FF00, 1.0, false, nil, nil, nil, 3)
    sprite.graphics.beginFill(0xFFFF00, 1.0)
    sprite.graphics.moveTo(0 + size / 2, 0 + size)
    sprite.graphics.lineTo(0 + size / 3, 0 + 2 * size / 3)
    sprite.graphics.lineTo(0 + 2 * size / 3, 0 + 2 * size / 3)
    sprite.graphics.lineTo(0 + size / 2, 0 + size)
    sprite.graphics.endFill()
    sprite.buttonMode = true
    spriteNavigation.addChild(sprite)

    sprite = Sprite.new()
    sprite.name = "right"
    sprite.graphics.lineStyle(2, 0x00FF00, 1.0, false, nil, nil, nil, 3)
    sprite.graphics.beginFill(0xFFFF00, 1.0)
    sprite.graphics.moveTo(0 + size, 0 + size / 2)
    sprite.graphics.lineTo(0 + 2 * size / 3, 0 + size / 3)
    sprite.graphics.lineTo(0 + 2 * size / 3, 0 + 2 * size / 3)
    sprite.graphics.lineTo(0 + size, 0 + size / 2)
    sprite.graphics.endFill()
    sprite.buttonMode = true
    spriteNavigation.addChild(sprite)
end

function initObjects()
    --create light billboards
    redLight.addChild(Away3D.Entities.Sprite3D.new(redLightMaterial, 200, 200))
    blueLight.addChild(Away3D.Entities.Sprite3D.new(blueLightMaterial, 200, 200))

    --parse hellknight mesh
    Away3D.Library.Asset3DLibrary.addEventListener(Away3D.Events.Asset3DEvent.ASSET_COMPLETE,
            function(e)
                if e.asset.assetType == Away3D.Library.Assets.Asset3DType.ANIMATION_NODE then
                    local node = e.asset
                    local name = e.asset.assetNamespace
                    node.name = name
                    animationSet.addAnimation(node)

                    if name == IDLE_NAME or name == WALK_NAME then
                        node.looping = true
                    else
                        node.looping = false
                        node.addEventListener(Away3D.Events.AnimationStateEvent.PLAYBACK_COMPLETE,
                                function(e2)
                                    if animator.activeState ~= e2.animationState then
                                        return
                                    end
                                    onceAnim = nil
                                    animator.play(currentAnim, stateTransition, nil)
                                    animator.playbackSpeed = isMoving and
                                            movementDirection*(isRunning and RUN_SPEED or WALK_SPEED) or IDLE_SPEED
                                end , false, 0, false)
                    end

                    if name == IDLE_NAME then
                        stop()
                    end
                elseif e.asset.assetType == Away3D.Library.Assets.Asset3DType.ANIMATION_SET then
                    animationSet = e.asset
                    animator = Animators.SkeletonAnimator.new(animationSet, skeleton, false)
                    for i=1,#ANIM_NAMES,1 do
                        Away3D.Library.Asset3DLibrary.loadData(ANIM_CLASSES[i], nil, ANIM_NAMES[i],
                                Away3D.Loaders.Parsers.MD5AnimParser.new(nil, 0))
                    end
                    mesh.animator = animator
                elseif e.asset.assetType == Away3D.Library.Assets.Asset3DType.SKELETON then
                    skeleton = e.asset
                elseif e.asset.assetType == Away3D.Library.Assets.Asset3DType.MESH then
                    --grab mesh object and assign our material object
                    mesh = e.asset
                    mesh.material = bodyMaterial
                    --mesh.castsShadows = true -- shadows currently not working
                    scene.addChild(mesh)

                    --add our lookat object to the mesh
                    mesh.addChild(placeHolder)

                    --add key listeners
                    stage.addEventListener(Events.KeyboardEvent.KEY_DOWN, function(ke)
                        if ke.keyCode == Keyboard.SHIFT then
                            isRunning = true;
                            if isMoving then
                                updateMovement(movementDirection)
                            end
                        elseif ke.keyCode == Keyboard.UP or ke.keyCode == Keyboard.W then
                            movementDirection = 1
                            updateMovement(movementDirection)
                        elseif ke.keyCode == Keyboard.DOWN or ke.keyCode == Keyboard.S then
                            movementDirection = -1
                            updateMovement(movementDirection)
                        elseif ke.keyCode == Keyboard.LEFT or ke.keyCode == Keyboard.A then
                            currentRotationInc = -ROTATION_SPEED
                        elseif ke.keyCode == Keyboard.RIGHT or ke.keyCode == Keyboard.D then
                            currentRotationInc = ROTATION_SPEED
                        elseif ke.keyCode == Keyboard.NUMBER_1 then
                            playAction(1)
                        elseif ke.keyCode == Keyboard.NUMBER_2 then
                            playAction(2)
                        elseif ke.keyCode ==  Keyboard.NUMBER_3 then
                            playAction(3)
                        elseif ke.keyCode ==  Keyboard.NUMBER_4 then
                            playAction(4)
                        elseif ke.keyCode ==  Keyboard.NUMBER_5 then
                            playAction(5)
                        elseif ke.keyCode ==  Keyboard.NUMBER_6 then
                            playAction(6)
                        elseif ke.keyCode ==  Keyboard.NUMBER_7 then
                            playAction(7)
                        elseif ke.keyCode ==  Keyboard.NUMBER_8 then
                            playAction(8)
                        elseif ke.keyCode ==  Keyboard.NUMBER_9 then
                            playAction(9)
                        end
                    end , false, 0, false)
                    stage.addEventListener(Events.KeyboardEvent.KEY_UP, function(ke)
                        if ke.keyCode == Keyboard.SHIFT then
                            isRunning = false
                            if isMoving then
                                updateMovement(movementDirection)
                            end
                        elseif ke.keyCode == Keyboard.UP or ke.keyCode == Keyboard.W or ke.keyCode == Keyboard.DOWN or ke.keyCode == Keyboard.S then
                            stop()
                        elseif ke.keyCode == Keyboard.LEFT or ke.keyCode == Keyboard.A or ke.keyCode == Keyboard.RIGHT or ke.keyCode == Keyboard.D then
                            currentRotationInc = 0
                        end
                    end , false, 0, false)
                    stage.addEventListener(Events.MouseEvent.MOUSE_DOWN, function(e)
                        if e.target.name == "up" then
                            movementDirection = 1
                            updateMovement(movementDirection)
                        elseif e.target.name == "down" then
                            movementDirection = -1
                            updateMovement(movementDirection)
                        elseif e.target.name == "left" then
                            currentRotationInc = -ROTATION_SPEED
                        elseif e.target.name == "right" then
                            currentRotationInc = ROTATION_SPEED
                        end
                    end, false, 0, false)
                    stage.addEventListener(Events.MouseEvent.MOUSE_UP, function(e)
                        if e.target.name == "up" or e.target.name == "down" then
                            stop()
                        elseif e.target.name == "left" or e.target.name == "right" then
                            currentRotationInc = 0
                        end
                    end, false, 0, false)
                end
            end, false, 0, false)
    Away3D.Library.Asset3DLibrary.loadData(HellKnight_Mesh, nil, nil, Away3D.Loaders.Parsers.MD5MeshParser.new(nil, 0))

    --create a snowy ground plane
    ground = Mesh.new(Primitives.PlaneGeometry.new(50000, 50000, 1, 1, true, false), groundMaterial)
    ground.geometry.scaleUV(200, 200)
    -- ground.castsShadows = false -- shadows currently not working
    scene.addChild(ground)

    --create a skybox
    cubeTexture = Textures.BitmapCubeTexture.new(
            assets.grimnight_posX, -- left
            assets.grimnight_negX, -- right
            assets.grimnight_posY, -- top
            assets.grimnight_negY, -- bottom
            assets.grimnight_posZ, -- back
            assets.grimnight_negZ  -- front
    )
    skyBox = Primitives.SkyBox.new(cubeTexture)
    scene.addChild(skyBox)
end

function initListeners()
    view.setRenderCallback(function(rect)
        cameraController.update(true)

        --update character animation
        if mesh ~= nil then
            mesh.rotationY = mesh.rotationY + currentRotationInc
        end

        count = count + 0.01

        redLight.x = math.sin(count)*1500
        redLight.y = 250 + math.sin(count*0.54)*200
        redLight.z = math.cos(count*0.7)*1500
        blueLight.x = -math.sin(count*0.8)*1500
        blueLight.y = 250 - math.sin(count*.65)*200
        blueLight.z = -math.cos(count*0.9)*1500

        view.render()
    end)

    local onResize = function(e)
        view.width = stage.stageWidth
        view.height = stage.stageHeight
        spriteNavigation.x = 20
        spriteNavigation.y = stage.stageHeight - spriteNavigation.height - 20
    end

    stage.addEventListener(Events.Event.RESIZE, onResize, false, 0, false)
    onResize()
end


loadAssetsFromWebInThread()
initEngine()
initLights()

function frameEvent(e)
    assets = Thread.readMessage(false)
    if assets ~= nil then
        Lib.Media.Display.stage.removeEventListener(Lib.Media.Events.Event.ENTER_FRAME, frameEvent, false)

        HellKnight_Mesh = assets.hellknight

        HellKnight_Idle2 = assets.idle2
        HellKnight_Walk7 = assets.walk7
        HellKnight_Attack3 = assets.attack3
        HellKnight_TurretAttack = assets.turret_attack
        HellKnight_Attack2 = assets.attack2
        HellKnight_Chest = assets.chest
        HellKnight_Roar1 = assets.roar1
        HellKnight_LeftSlash = assets.leftslash
        HellKnight_HeadPain = assets.headpain
        HellKnight_Pain1 = assets.pain1
        HellKnight_PainLUPArm = assets.pain_luparm
        HellKnight_RangeAttack2 = assets.range_attack2

        ANIM_CLASSES = {HellKnight_Idle2, HellKnight_Walk7, HellKnight_Attack3, HellKnight_TurretAttack, HellKnight_Attack2, HellKnight_Chest, HellKnight_Roar1, HellKnight_LeftSlash, HellKnight_HeadPain, HellKnight_Pain1, HellKnight_PainLUPArm, HellKnight_RangeAttack2}

        initMaterials()
        initObjects()
        initNavigation()
        initListeners()
    end
end

--wait for thread to finish
Lib.Media.Display.stage.addEventListener(Lib.Media.Events.Event.ENTER_FRAME, frameEvent, false, 0, false)