-- Utils.lua

Assets = { -- GitHub Assets
    Web = {
        projectURL = "https://raw.githubusercontent.com/luastudio/Samples/master",
        log = false,
        cache = false,

        getText = function(path)
            local text
            local url = Assets.Web.projectURL..path

            if Assets.Web.cache then
                text = Assets.Utils.getCacheText(path)
                if text ~= nil then
                    if Assets.Web.log then print("Loaded from cache url: "..url) end
                    return text
                end
            end

            local r = Lib.Sys.Net.Http.new( url )
            r.onData = function(msg)
                text=msg
                if Assets.Web.log then print("Loaded url: "..url) end
                if Assets.Web.cache then
                    Assets.Utils.saveCacheText(path, text)
                    if Assets.Web.log then print("Saved to cache from url: "..url) end
                end
            end
            r.onError = function(msg)error("Can't load: "..url.." Error: "..msg);end
            if Assets.Web.log then print("Loading url: "..url) end
            r.request(false)
            return text
        end,
        getBytes = function(path)
            local url = Assets.Web.projectURL..path

            if Assets.Web.cache then
                local bytes = Assets.Utils.getCacheBytes(path)
                if bytes ~= nil then
                    if Assets.Web.log then print("Loaded from cache url: "..url) end
                    return Lib.Media.Utils.ByteArray.fromBytes(bytes)
                end
            end

            local byteArray
            local r = Lib.Sys.Net.Http.new( url )
            r.onBytesData = function(bytes)
                byteArray=Lib.Media.Utils.ByteArray.fromBytes(bytes)
                if Assets.Web.log then print("Loaded url: "..url) end
                if Assets.Web.cache then
                    Assets.Utils.saveCacheBytes(path, bytes)
                    if Assets.Web.log then print("Saved to cache from url: "..url) end
                end
            end
            r.onError = function(msg)error("Can't load: "..url.." Error: "..msg);end
            if Assets.Web.log then print("Loading url: "..url) end
            r.request(false)
            return byteArray
        end
    },
    Utils = {
        projectCacheURL = nil,
        prepareCache = function()
            Assets.Utils.projectCacheURL = Lib.Media.FileSystem.File.applicationStorageDirectory.nativePath
            if not Lib.Sys.FileSystem.exists(Assets.Utils.projectCacheURL) then
                Lib.Sys.FileSystem.createDirectory(Assets.Utils.projectCacheURL)
            end
            Assets.Utils.projectCacheURL = Assets.Utils.projectCacheURL.."/samples_cache"
            if not Lib.Sys.FileSystem.exists(Assets.Utils.projectCacheURL) then
                Lib.Sys.FileSystem.createDirectory(Assets.Utils.projectCacheURL)
            end
        end,
        getCacheText = function(path)
            Assets.Utils.prepareCache()
            if Lib.Sys.FileSystem.exists(Assets.Utils.projectCacheURL..path) then
                return Lib.Sys.IO.File.getContent(Assets.Utils.projectCacheURL..path)
            else
                return nil
            end
        end,
        getCacheBytes = function(path)
            Assets.Utils.prepareCache()
            if Lib.Sys.FileSystem.exists(Assets.Utils.projectCacheURL..path) then
                return Lib.Sys.IO.File.getBytes(Assets.Utils.projectCacheURL..path)
            else
                return nil
            end
        end,
        saveCacheText = function(path, text)
            Assets.Utils.prepareCache()
            local normPath = Lib.Str.replace(path, "\\", "/")
            local pathParts = Lib.Str.split(normPath, "/")
            table.remove(pathParts, #pathParts)
            Lib.Sys.FileSystem.createDirectory(Assets.Utils.projectCacheURL.."/"..Lib.Str.join(pathParts, "/"))
            Lib.Sys.IO.File.saveContent(Assets.Utils.projectCacheURL..normPath, text)
        end,
        saveCacheBytes = function(path, bytes)
            Assets.Utils.prepareCache()
            local normPath = Lib.Str.replace(path, "\\", "/")
            local pathParts = Lib.Str.split(normPath, "/")
            table.remove(pathParts, #pathParts)
            Lib.Sys.FileSystem.createDirectory(Assets.Utils.projectCacheURL.."/"..Lib.Str.join(pathParts, "/"))
            Lib.Sys.IO.File.saveBytes(Assets.Utils.projectCacheURL..normPath, bytes)
        end,
        cleanCache = function()
            if Assets.Utils.projectCacheURL ~= nil then
                Utils.File.deleteFolder(Assets.Utils.projectCacheURL, true)
            end
        end
    }
}

Utils = {
    File = {
        deleteFolder = function (path, recursively)
            if(not recursively)then
                Lib.Sys.FileSystem.deleteDirectory(path)
                return
            end

            local subDelete
            subDelete = function (subPath)
                local items = Lib.Sys.FileSystem.readDirectory(subPath)
                if(items ~= nil)then
                    for i=1,#items,1 do
                        local itemPath = subPath.."/"..items[i]
                        --print(itemPath)
                        if Lib.Sys.FileSystem.isDirectory(itemPath) then
                            subDelete(itemPath)
                        else
                            Lib.Sys.FileSystem.deleteFile(itemPath)
                        end
                    end
                end
                Lib.Sys.FileSystem.deleteDirectory(subPath)
            end
            subDelete(path)
        end
    }
}