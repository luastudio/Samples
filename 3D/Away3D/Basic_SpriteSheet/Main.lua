--Main.lua (WARNING: require internet connection)

--[[Based on:

Sprite sheet animation example in Away3d

Demonstrates:

How to use the SpriteSheetAnimator.
- using TextureMaterial for single maps animations
- using SpriteSheetMaterial for multiple maps animations
- using the SpriteSheetHelper

Code by Fabrice Closier
fabrice3d@gmail.com
http://www.closier.nl

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

Display = Lib.Media.Display
Events = Lib.Media.Events
Away3D = Lib.Away3D
View3D = Away3D.Containers.View3D
Mesh = Away3D.Entities.Mesh
Debug = Away3D.Debug
TextureMaterial = Away3D.Materials.TextureMaterial
PlaneGeometry = Away3D.Primitives.PlaneGeometry
Cast = Away3D.Utils.Cast
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

    testSheet1 = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Basic_SpriteSheet/assets/testSheet1.jpg")),
    testSheet2 = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Basic_SpriteSheet/assets/testSheet2.jpg"))

})
]])
    t.sendMessage(Thread.current())
end

--setting up the spritesheets with a single map
function prepareSingleMap()
    --if the animation is something that plays non stop, and fits a single map,
    -- you can use a regular TextureMaterial
    local material = TextureMaterial.new(assets.testSheet1, true, false, true, nil)

    -- the name of the animation
    local animID = "mySingleMapAnim"
    -- to simplify the generation of the required nodes for the animator, away3d has an helper class.
    local spriteSheetHelper = Away3D.Tools.Helpers.SpriteSheetHelper.new()
    -- first we make our SpriteSheetAnimationSet, which will hold one or more spriteSheetClipNode
    local spriteSheetAnimationSet = Away3D.Animators.SpriteSheetAnimationSet.new()
    -- in this case our simple map is composed of 4 cells: 2 rows, 2 colums
    local spriteSheetClipNode = spriteSheetHelper.generateSpriteSheetClipNode(animID, 2, 2, 1, 0, 0)
    --we can now add the animation to the set.
    spriteSheetAnimationSet.addAnimation(spriteSheetClipNode)
    -- Finally we can build the animator and add the animation set to it.
    local spriteSheetAnimator = Away3D.Animators.SpriteSheetAnimator.new(spriteSheetAnimationSet)

    -- construct the receiver geometry, in this case a plane;
    local mesh = Mesh.new(PlaneGeometry.new(700, 700, 1, 1, false, false), material)
    mesh.x = -400
    --asign the animator
    mesh.animator = spriteSheetAnimator
    -- because our very simple map has only 4 images in itself, playing it the same speed as the swf would be way too fast.
    spriteSheetAnimator.fps = 4
    --start play the animation
    spriteSheetAnimator.play(animID, nil, nil)

    _view.scene.addChild(mesh)
end

--	Because one animation may require more resolution or duration. The animation source may be spreaded over multiple sources
--	A dedicated material handles the maps management
function prepareMultipleMaps()
    --the first map, we the beginning of the animation
    local texture1 = assets.testSheet1

    --the rest of teh animation
    local texture2 = assets.testSheet2

    local diffuses = {texture1, texture2}
    local material = Away3D.Materials.SpriteSheetMaterial.new(diffuses, nil, nil, true, false, true)

    -- the name of the animation
    local animID = "myMultipleMapsAnim"
    -- to simplify the generation of the required nodes for the animator, away3d has an helper class.
    local spriteSheetHelper = Away3D.Tools.Helpers.SpriteSheetHelper.new()
    -- first we make our SpriteSheetAnimationSet, which will hold one or more spriteSheetClipNode
    local spriteSheetAnimationSet = Away3D.Animators.SpriteSheetAnimationSet.new()
    -- in this case our simple map is composed of 4 cells: 2 rows, 2 colums
    -- note compared to the above "prepareSingleMap" method, we now pass a third parameter (2): how many maps are used inthis animation
    local spriteSheetClipNode = spriteSheetHelper.generateSpriteSheetClipNode(animID, 2, 2, 2, 0, 0)
    --we can now add the animation to the set and build the animator
    spriteSheetAnimationSet.addAnimation(spriteSheetClipNode)
    local spriteSheetAnimator =  Away3D.Animators.SpriteSheetAnimator.new(spriteSheetAnimationSet)

    -- construct the reciever geometry, in this case a plane;
    local mesh = Mesh.new(PlaneGeometry.new(700, 700, 1, 1, false, false), material)
    mesh.x = 400
    --asign the animator
    mesh.animator = spriteSheetAnimator
    --the frame rate at which the animation should be played
    spriteSheetAnimator.fps = 10
    --we can set the animation to play back and forth
    spriteSheetAnimator.backAndForth = true

    --start play the animation
    spriteSheetAnimator.play(animID, nil, nil)

    _view.scene.addChild(mesh)
end

function onResize(e)
    _view.width = stage.stageWidth
    _view.height = stage.stageHeight
end


loadAssetsFromWebInThread()

--setup the view
_view = View3D.new()
stage.addChild(_view)

--setup the camera
_view.camera.z = -1500
_view.camera.y = 200
_view.camera.lookAt(Geom.Vector3D.new(0, 0, 0, 0), nil)


stage.addEventListener(Events.Event.RESIZE, onResize, false, 0, false)
onResize(nil)


function frameEvent(e)
    assets = Thread.readMessage(false)
    if assets ~= nil then
        Lib.Media.Display.stage.removeEventListener(Lib.Media.Events.Event.ENTER_FRAME, frameEvent, false)

        --setup the meshes and their SpriteSheetAnimator
        prepareSingleMap()
        prepareMultipleMaps()

        --setup the render loop
        _view.setRenderCallback(function(e)
            _view.render()
        end)
    end
end

--wait for thread to finish
Lib.Media.Display.stage.addEventListener(Lib.Media.Events.Event.ENTER_FRAME, frameEvent, false, 0, false)