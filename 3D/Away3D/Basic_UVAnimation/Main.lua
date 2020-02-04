--Main.lua (WARNING: require internet connection)

--[[Based on:

UV animation example in Away3d

Demonstrates:
How to use the UVAnimator.

Code by Fabrice Closier
fabrice3d@gmail.com
http://www.closier.nl

This code is distributed under the MIT License

Copyright (c) The Away Foundation http://www.theawayfoundation.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]--

Display = Lib.Media.Display
Events = Lib.Media.Events
Away3D = Lib.Away3D
Cast = Away3D.Utils.Cast
Primitives = Away3D.Primitives
View3D = Away3D.Containers.View3D
Scene3D = Away3D.Containers.Scene3D
Animators = Away3D.Animators
Mesh = Away3D.Entities.Mesh
TextureMaterial = Away3D.Materials.TextureMaterial
Geom = Lib.Media.Geom
stage = Display.stage
Thread = Lib.Sys.VM.Thread

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

    wheel = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Basic_UVAnimation/assets/wheel.png")),
    road = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Basic_UVAnimation/assets/road.jpg"))

})
]])
    t.sendMessage(Thread.current())
end

function setUpView()
    _view = View3D.new()
    stage.addChild(_view)

    _view.antiAlias = 2

    _view.camera.x = 500
    _view.camera.y = 500
    _view.camera.z = -1500

    --saving the origin, as we look at it on enterframe
    _view.camera.lookAt(Geom.Vector3D.new(0,0,0,0), nil)


    local onResize = function(e)
        _view.width = stage.stageWidth
        _view.height = stage.stageHeight
    end

    stage.addEventListener(Events.Event.RESIZE, onResize, false, 0, false)
    onResize()
end

--adding a blank set, to meet the generic animators architecture
function generateBlankAnimationSet(animID)
    local uvAnimationSet = Animators.UVAnimationSet.new()
    local node = Animators.Nodes.UVClipNode.new()
    node.name = animID
    uvAnimationSet.addAnimation(node)

    return uvAnimationSet
end

--adding set, composed of multiple keyframes
function generateFirstAnimation(animID)
    local uvAnimationSet = Animators.UVAnimationSet.new()

    local node = Animators.Nodes.UVClipNode.new()
    node.name = animID
    uvAnimationSet.addAnimation(node)

    local duration = 1000
    local offset = 0

    local frame = Animators.Data.UVAnimationFrame.new(offset, offset, 1, 1, 0)
    frame.offsetU = offset
    frame.offsetV = offset
    frame.scaleU = 1
    frame.scaleV = 1
    frame.rotation = 0

    node.addFrame(frame, duration)

    frame = Animators.Data.UVAnimationFrame.new(offset, offset, 2, 2, 0)
    frame.offsetU =  offset;
    frame.offsetV =  offset;
    frame.scaleU = 2;
    frame.scaleV = 2;
    frame.rotation = 0;

    node.addFrame(frame, duration)

    frame = Animators.Data.UVAnimationFrame.new(offset, offset, 1, 1, 90)
    frame.offsetU = offset;
    frame.offsetV = offset;
    frame.scaleU = 1;
    frame.scaleU = 1;
    frame.rotation = 90;

    node.addFrame(frame, duration)

    frame = Animators.Data.UVAnimationFrame.new(offset, offset, 1, 1, 90)
    frame.offsetU = offset;
    frame.offsetV = offset;
    frame.scaleU = 1;
    frame.scaleU = 1;
    frame.rotation = 90;

    node.addFrame(frame, duration)

    frame = Animators.Data.UVAnimationFrame.new(offset, offset, 1, 1, 90)
    frame.offsetU = offset;
    frame.offsetV = offset;
    frame.scaleU = 1;
    frame.scaleU = 1;
    frame.rotation = 90;

    node.addFrame(frame, duration)

    return uvAnimationSet
end

function generateSecondAnimation(animID)
    local uvAnimationSet = Animators.UVAnimationSet.new()
    local node = Animators.Nodes.UVClipNode.new()
    node.name = animID
    uvAnimationSet.addAnimation(node)

    frame = Animators.Data.UVAnimationFrame.new(0, 0, 1, 1, 0)

    node.addFrame(frame, 250)

    frame = Animators.Data.UVAnimationFrame.new(0, 0, 4, 4, 0)
    node.addFrame(frame, 1000)

    return uvAnimationSet
end

function setUpUVAnimators()
    local pg = Primitives.PlaneGeometry.new(500, 500, 1, 1, false, false)

    --In this demo, the two upper planes, will be using non- keyframe information
    --while the two others will display keyframe based animations

    --All the animations are non destructive (the mesh uvs are kept unchanged) and very efficient as they are executed on the gpu.

    --Endless rotations, map scrolls are very useful. They are hard to define using keyframes.
    --UVAnimator offers both options without the need to define any keyframes.

    -- 1: The top left plane, will display the endless rotation of a image
    local animID = "anim_rotation"
    --material declaration
    local mat = TextureMaterial.new(assets.wheel, true, false, true, nil)
    --adding an empty set with our animation id
    local uvAnimationSet = generateBlankAnimationSet(animID)
    local uvAnimator = Animators.UVAnimator.new(uvAnimationSet)
    --setting the animator autoRotation
    uvAnimator.autoRotation = true
    uvAnimator.rotationIncrease = 1.1 --default is 1 degree
    --the geometry receiver
    local mesh = Mesh.new(pg, mat)
    --assigning the animator to the mesh
    mesh.animator = uvAnimator
    --let's play our animation
    uvAnimator.play(animID, nil, nil)
    mesh.x = mesh.x - 300
    mesh.y = mesh.y + 300
    _view.scene.addChild(mesh)

    --2: The top right plane, will display the endless scroll of an image
    animID = "anim_translate"
    mat = TextureMaterial.new(assets.road, true, false, true, nil)
    -- the road map that we use is seamless, so we set repeat to true to prevent elongated pixel
    mat['repeat'] = true
    uvAnimationSet = generateBlankAnimationSet(animID)
    uvAnimator = Animators.UVAnimator.new(uvAnimationSet)
    -- setting the auto translate
    uvAnimator.autoTranslate = true
    -- in this example we scroll a endless road, so the increase is made only along the v axis
    -- note that using integers values would not affect the rendering. The image would stay still as the uvs are using values between 0 and 1.
    uvAnimator.setTranslateIncrease(0, -.01)
    uvAnimator.play(animID, nil, nil)
    mesh = Mesh.new(pg, mat)
    mesh.animator = uvAnimator
    mesh.x = mesh.x + 300
    mesh.y = mesh.y + 300
    _view.scene.addChild(mesh)

    -- 3: The down left plane, will display an animation using keyframes.
    animID = "anim3"
    --material setup, similar to the above examples
    mat = TextureMaterial.new(assets.wheel, true, false, true, nil)
    mat['repeat'] = true
    --this time, we use a keyframe based approach.
    uvAnimationSet = generateFirstAnimation(animID)
    uvAnimator = Animators.UVAnimator.new(uvAnimationSet)
    --setting the animator autoRotation
    uvAnimator.autoRotation = true
    uvAnimator.rotationIncrease = 1.1 --default is 1 degree
    --the geometry receiver
    mesh = Mesh.new(pg, mat)
    --assigning the animator to the mesh
    mesh.animator = uvAnimator
    --let's play our animation
    uvAnimator.play(animID, nil, nil)
    mesh.x = mesh.x + 300
    mesh.y = mesh.y - 300
    _view.scene.addChild(mesh)

    --4: The down right plane, will display another animation using another set of keyframes.
    animID = "anim4"
    mat = TextureMaterial.new(assets.wheel, true, false, true, nil)
    mat['repeat'] = true
    mesh = Mesh.new(pg, mat)
    uvAnimationSet = generateSecondAnimation(animID)
    uvAnimator = Animators.UVAnimator.new(uvAnimationSet)
    mesh.animator = uvAnimator
    uvAnimator.play(animID, nil, nil)
    mesh.x = mesh.x - 300
    mesh.y = mesh.y - 300
    _view.scene.addChild(mesh)
end

loadAssetsFromWebInThread()
setUpView()

function frameEvent(e)
    assets = Thread.readMessage(false)
    if assets ~= nil then
        Lib.Media.Display.stage.removeEventListener(Lib.Media.Events.Event.ENTER_FRAME, frameEvent, false)

        setUpUVAnimators()

        _view.setRenderCallback(function(e)
            _view.render()
        end)
    end
end

--wait for thread to finish
Lib.Media.Display.stage.addEventListener(Lib.Media.Events.Event.ENTER_FRAME, frameEvent, false, 0, false)