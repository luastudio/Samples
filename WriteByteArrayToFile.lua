-- WriteByteArrayToFile.lua

root = Lib.Media.FileSystem.File.applicationStorageDirectory.nativePath
if not Lib.Sys.FileSystem.exists(root) then
	Lib.Sys.FileSystem.createDirectory(root)
end
path = root.."/README.txt"

Lib.Sys.IO.File.saveContent(path, "A SiMpLe FiLe")
if Lib.Media.System.systemName() == "ios" then
	Lib.Media.FileSystem.File.new(path).preventBackup = true
end

ba = Lib.Media.Utils.ByteArray.fromBytes(Lib.Sys.IO.File.getBytes(path))
print("length: " .. ba.length)
dkdkd = ba.asString()
print("file contents: " .. dkdkd)

ba.writeUTFBytes("MODIFIED FILE ///////////////////////")

print("now writing as another file and re-reading")
Lib.Sys.IO.File.saveBytes(path, ba)

ba2 = Lib.Media.Utils.ByteArray.fromBytes(Lib.Sys.IO.File.getBytes(path))
print("length: " .. ba2.length)
dkdkd2 = ba2.asString()
print("file contents: " .. dkdkd2)