-- ImageFormats.lua

Display = Lib.Media.Display
BitmapData = Display.BitmapData
PixelFormat = Lib.Media.Image.PixelFormat
ByteArray = Lib.Media.Utils.ByteArray

stage = Display.stage

bmp16 = BitmapData.createUInt16(400,300)

pixels = ByteArray.new(300*400*4)
pixels.bigEndian = false
for y=0, 300 - 1, 1 do
  for x=0, 400 - 1, 1 do
    pixels.writeInt( y*3 )
  end
end

bmp16.setData(pixels, PixelFormat.pfUInt32, 0, 0, 1)

bytes = bmp16.getBytes(PixelFormat.pfNone)
print(Lib.Str.string(bmp16).." "..bmp16.format.."x"..bytes.length)
print(bytes.bigEndian)
bytes.bigEndian = false

bytes.position = bytes.length - 2
print("LastVal:"..bytes.readUnsignedShort())

bytes16 = ByteArray.new(400*300*2)
bmp16.getData(bytes16, PixelFormat.pfNone, 0, 0, 1)
print("x"..bytes16.length)
print(bytes16.bigEndian)
bytes16.bigEndian = false
bytes16.position = bytes16.length - 2
print("LastVal:"..bytes16.readUnsignedShort())

root = Lib.Media.FileSystem.File.applicationStorageDirectory.nativePath
if not Lib.Sys.FileSystem.exists(root) then
	Lib.Sys.FileSystem.createDirectory(root)
end
path = root.."/png16.png"

bmp16.save(path, 0.9)
if Lib.Media.System.systemName() == "ios" then
	Lib.Media.FileSystem.File.new(path).preventBackup = true
end

recon = BitmapData.load(path, PixelFormat.pfNone)
print(Lib.Str.string(recon).." "..recon.format)

reconBytes16 = ByteArray.new(400*300*2)
reconBytes16.bigEndian = false
recon.getData(reconBytes16, PixelFormat.pfUInt16, 0, 0, 1)
print((reconBytes16.bigEndian and "true" or "false").." p:"..reconBytes16.position.." x:"..reconBytes16.length)
while reconBytes16.position < reconBytes16.length do
	b16 = reconBytes16.readUnsignedShort()
    if b16>255 then
	    reconBytes16.position = reconBytes16.position - 2
        reconBytes16.writeShort(255)
    end
end

bmp = BitmapData.new(400, 300, false, 0xff00ffff, PixelFormat.pfNone)
bmp.setData(reconBytes16, PixelFormat.pfUInt16 , 0, 0, 1)

stage.addChild(Display.Bitmap.new(bmp, nil, false))