-- URLLoader.lua (WARNING: require internet connection)

Net = Lib.Media.Net
Text = Lib.Media.Text
stage = Lib.Media.Display.stage

xmlTextField = Text.TextField.new()
xmlTextField.x = 10
xmlTextField.y = 100
xmlTextField.background = true
xmlTextField.border = true
xmlTextField.autoSize = Text.TextFieldAutoSize.LEFT

stage.addChild(xmlTextField)

postTextField = Text.TextField.new()
postTextField.x = 10
postTextField.y = 10
postTextField.border = true
postTextField.background = true
postTextField.autoSize = Text.TextFieldAutoSize.LEFT

stage.addChild(postTextField)

request = Net.URLRequest.new("https://www.w3.org/")
request.basicAuth("basic","basic")
request.cookieString = "name=value"

loader = Net.URLLoader.new(nil)
loader.addEventListener(Lib.Media.Events.IOErrorEvent.IO_ERROR,
        function(event)
            print("Html load error: "..event.text)
        end, false, 0, false)
loader.addEventListener(Lib.Media.Events.Event.COMPLETE,
        function(event)
            xmlTextField.text = string.sub(loader.data, 1, 2000) --trim text to 2000 bytes. Large text can slow down TextField and app
        end, false, 0, false)
loader.addEventListener(Lib.Media.Events.ProgressEvent.PROGRESS,
        function(event)
            print("Html Loaded " .. event.bytesLoaded .. "/" .. event.bytesTotal)
        end, false, 0, false)

local status, err = pcall(function()
    loader.load(request)   
end)

if not status then
    print(err)
end

image_loader = Lib.Media.Display.Loader.new()
image_loader.contentLoaderInfo.addEventListener(Lib.Media.Events.Event.COMPLETE,
        function(event)
            local bmp = image_loader.content
            print("Loaded image " .. bmp.bitmapData.width .. "x" .. bmp.bitmapData.height)
        end, false, 0, false)
image_loader.contentLoaderInfo.addEventListener(Lib.Media.Events.ProgressEvent.PROGRESS,
        function(event)
            print("Image Loaded " .. event.bytesLoaded .. "/" .. event.bytesTotal)
        end, false, 0, false)
image_loader.contentLoaderInfo.addEventListener(Lib.Media.Events.IOErrorEvent.IO_ERROR,
        function(event)
            local bmp = image_loader.content
            print("loading image error: "..event.text)
        end, false, 0, false)

request = Net.URLRequest.new("https://source.unsplash.com/random/200x300")

--request = Net.URLRequest.new("https://picsum.photos/200/300/?random")
--request.userAgent = "My custom user agent v1.0"

request.contentType = "image/jpeg"

image_loader.load(request, nil)
image_loader.x = 15
image_loader.y = 190
image_loader.scaleX = 0.5
image_loader.scaleY = 0.5
stage.addChild(image_loader)

post = Net.URLRequest.new("https://tryphp.w3schools.com/demo/welcome.php")
vars = Net.URLVariables.new(nil)
vars.set("name", "Milla")
vars.set("email", "Jovovich@hotmail.com")
vars.set("submit", "1")
post.method = Net.URLRequestMethod.POST
post.data = vars
Lib.Sys.trace(post.data)
postLoad = Net.URLLoader.new(nil)
postLoad.addEventListener(Lib.Media.Events.IOErrorEvent.IO_ERROR,
        function(event)
            print("form post error: "..event.toString())
        end, false, 0, false)
postLoad.addEventListener(Lib.Media.Events.Event.COMPLETE,
        function(event)
            postTextField.text = postLoad.data
        end, false, 0, false)

local status, err = pcall(function()
    postLoad.load(post)   
end)

if not status then
    print(err)
end