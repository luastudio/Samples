-- Main.lua

Events = Lib.Media.Events
Display = Lib.Media.Display
BitmapData = Display.BitmapData
Bitmap = Display.Bitmap
Geom = Lib.Media.Geom
Net = Lib.Media.Net
stage = Display.stage

require("/Bitmaps/Sample.lua")

--local image = BitmapData.loadFromBytes(Lib.Project.getBytes("/Bitmaps/assets/Image.jpg"), nil)

root = Lib.Media.FileSystem.File.applicationStorageDirectory.nativePath
if not Lib.Sys.FileSystem.exists(root) then
	Lib.Sys.FileSystem.createDirectory(root)
end

Lib.Sys.IO.File.saveBytes(root.."/Image.jpg", Lib.Project.getBytes("/Bitmaps/assets/Image.jpg"))
Lib.Sys.IO.File.saveBytes(root.."/Image1.png", Lib.Project.getBytes("/Bitmaps/assets/Image1.png"))
Lib.Sys.IO.File.saveBytes(root.."/Image2.png", Lib.Project.getBytes("/Bitmaps/assets/Image2.png"))

loader1 = Display.Loader.new()
loader1.contentLoaderInfo.addEventListener(Events.Event.COMPLETE, 
function(e)
	local bmp1 = loader1.content
	image1 = bmp1.bitmapData
	local loader2 = Display.Loader.new()
	loader2.contentLoaderInfo.addEventListener(Events.Event.COMPLETE, 
	function(e)
		local bmp2 = loader2.content
		image2 = bmp2.bitmapData	
		local loader3 = Display.Loader.new()
		loader3.contentLoaderInfo.addEventListener(Events.Event.COMPLETE, 
		function(e)
			local bmp3 = loader3.content
			image3 = bmp3.bitmapData	

			local sample = Sample.new(image1, image2, image3)
			sample.run()

		end, false, 0, false)
		loader3.load(Net.URLRequest.new(root.."/Image2.png"), nil)
	end, false, 0, false)
	loader2.load(Net.URLRequest.new(root.."/Image1.png"), nil)
end, false, 0, false)
loader1.load(Net.URLRequest.new(root.."/Image.jpg"), nil)