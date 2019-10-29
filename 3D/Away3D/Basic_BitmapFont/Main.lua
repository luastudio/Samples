-- Main.lua

Display = Lib.Media.Display
Events = Lib.Media.Events
Away3D = Lib.Away3D
View3D = Away3D.Containers.View3D
ObjectContainer3D = Away3D.Containers.ObjectContainer3D
Mesh = Away3D.Entities.Mesh
Debug = Away3D.Debug
TextureMaterial = Away3D.Materials.TextureMaterial
Textures = Away3D.Textures
BitmapFont = Away3D.Text.BitmapFont
Text = Away3D.Text.TextField
PlaneGeometry = Away3D.Primitives.PlaneGeometry
Cast = Away3D.Utils.Cast
Geom = Lib.Media.Geom
stage = Display.stage

-- init font material and xml
texture = Display.BitmapData.loadFromBytes(Lib.Project.getBytes("/3D/Away3D/Basic_BitmapFont/assets/BerberRevKC_260.png"), nil)
bmTexture = Textures.BitmapTexture.new(texture, false)

fntXml = Lib.Sys.Xml.parse(Lib.Project.getText("/3D/Away3D/Basic_BitmapFont/assets/BerberRevKC_260.fnt"))

--setup the view
_view = View3D.new()
stage.addChild(_view)
_view.antiAlias = 0

--setup the camera
_view.camera.z = -600
_view.camera.y = 200
_view.camera.lookAt(Geom.Vector3D.new(0, 0, 0, 0), nil)

--setup the scene
container = ObjectContainer3D.new()
_view.scene.addChild(container)
		
len = 14
for i = 1, len, 1 do
	local textContainer = ObjectContainer3D.new()
	textContainer.rotationY = (i - 1) / len * 360
	container.addChild(textContainer)
	local colour = math.ceil(0xFFFFFF * math.random())
	local fontMaterial = TextureMaterial.new(bmTexture, true, false, true, nil)
	fontMaterial.alphaBlending = true
	fontMaterial.bothSides = true
	local bitmapFont = BitmapFont.new(fontMaterial, fntXml)
			
	local textField = Text.new(800, 600, "THIS IS A TEST", bitmapFont, 100, colour, false, Away3D.Text.HAlign.CENTER)
	textField.x = -400
	textField.y = -300 + ((i - 1) * 60)
	textField.rotationX = 90

	textContainer.addChild(textField)
end

_view.setRenderCallback(function(rect)
		container.rotationY = container.rotationY + 1
		
		_view.render()
end)

onResize = function(e)
	_view.width = stage.stageWidth
	_view.height = stage.stageHeight
end

stage.addEventListener(Events.Event.RESIZE, onResize, false, 0, false)
onResize()

-- stats
stage.addChild(Debug.AwayFPS.new(_view, 10, 10, 0xffffff, 1))