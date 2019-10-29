-- Main.lua

--[[Based on:

SkyBox example in Away3d

Demonstrates:

How to use a CubeTexture to create a SkyBox object.
How to apply a CubeTexture to a material as an environment map.

Code by Rob Bateman
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk

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
View3D = Away3D.Containers.View3D
Mesh = Away3D.Entities.Mesh
Materials = Away3D.Materials
Primitives = Away3D.Primitives
Lenses = Away3D.Cameras.Lenses
Textures = Away3D.Textures
Cast = Away3D.Utils.Cast
Debug = Away3D.Debug
Geom = Lib.Media.Geom
stage = Display.stage

stage.color = 0x00

--setup the view
_view = View3D.new()
stage.addChild(_view)

--setup the camera
_view.camera.z = -600
_view.camera.y = 0
_view.camera.lookAt(Geom.Vector3D.new(0, 0, 0, 0), nil)
_view.camera.lens = Lenses.PerspectiveLens.new(90)

cubeTexture = Textures.BitmapCubeTexture.new(
	Cast.bitmapData("/3D/Away3D/Common/assets/skybox/snow_positive_x.jpg"), -- left
	Cast.bitmapData("/3D/Away3D/Common/assets/skybox/snow_negative_x.jpg"), -- right
	Cast.bitmapData("/3D/Away3D/Common/assets/skybox/snow_positive_y.jpg"), -- top
	Cast.bitmapData("/3D/Away3D/Common/assets/skybox/snow_negative_y.jpg"), -- bottom
	Cast.bitmapData("/3D/Away3D/Common/assets/skybox/snow_positive_z.jpg"), -- back
	Cast.bitmapData("/3D/Away3D/Common/assets/skybox/snow_negative_z.jpg")  -- front
)

material = Materials.ColorMaterial.new(0xFFFFFF, 1)
material.specular = 0.5
material.ambient = 0.25
material.ambientColor = 0x111199
material.ambient = 1
material.addMethod(Materials.Methods.EnvMapMethod.new(cubeTexture, 1))

--setup the scene
_torus = Mesh.new(
	Primitives.TorusGeometry.new(150, 60, 40, 20, true), material)
_view.scene.addChild(_torus)

_skyBox = Primitives.SkyBox.new(cubeTexture)
_view.scene.addChild(_skyBox)
		
--setup the render loop
_view.setRenderCallback(function(e)
	_torus.rotationX = _torus.rotationX + 2
	_torus.rotationY = _torus.rotationY + 1

	_view.camera.position = Geom.Vector3D.new(0, 0, 0, 0)
	_view.camera.rotationY = _view.camera.rotationY + 0.5*(stage.mouseX-stage.stageWidth/2)/800
	_view.camera.moveBackward(600)
		
	_view.render()
end)
		
function onResize(e)
	_view.width = stage.stageWidth
	_view.height = stage.stageHeight
end

stage.addEventListener(Events.Event.RESIZE, onResize, false, 0, false)
onResize(nil)

--stats
stage.addChild(Debug.AwayFPS.new(_view, 10, 10, 0xffffff, 3))