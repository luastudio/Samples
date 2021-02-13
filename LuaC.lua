-- LuaC.lua

if type(jit) == 'table' then
  error("Lua JIT doesn't work with luac")
end

root = Lib.Media.FileSystem.File.applicationStorageDirectory.nativePath
if not Lib.Sys.FileSystem.exists(root) then
	Lib.Sys.FileSystem.createDirectory(root)
end
path = root.."/test.lua"

Lib.Sys.IO.File.saveContent(path, [[
print('Test Complete!')
Lib.Sys.trace('Done')
]])
if Lib.Media.System.systemName() == "ios" then
	Lib.Media.FileSystem.File.new(path).preventBackup = true
end

local status, err = pcall(Lib.Tool.luac, {"-o", path.."c", path})
if status then
	dofile(path.."c")
else
    print("Error: "..err)
	dofile(path)
end