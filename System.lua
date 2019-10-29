-- System.lua

print("Lua Studio version: "..Lib.Sys.version)

-- lua info
print(_VERSION)

if type(jit) == 'table' then
   print(jit.version)
end

--Capabilities
print(Lib.Media.Capabilities.pixelAspectRatio)
print(Lib.Media.Capabilities.screenDPI)
print(Lib.Media.Capabilities.screenResolutionX)
print(Lib.Media.Capabilities.screenResolutionY)
print(Lib.Media.Capabilities.language)

--System
print(Lib.Media.System.deviceID)
print(Lib.Media.System.totalMemory)
print(Lib.Media.System.systemName())
print(Lib.Media.System.exeName)
print(Lib.Media.System.getLocalIpAddress())

--Lib garbage collector
Lib.Media.System.gc()
--Exit
--Lib.Media.System.restart(0)
Lib.Media.System.exit(0) 

--Web
--Lib.Media.System.getURL(Lib.Media.Net.URLRequest.new("https://www.wikipedia.org/"), "_blank")