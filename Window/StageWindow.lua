-- StageWindow.lua

Events = Lib.Media.Events
Display = Lib.Media.Display
stage = Display.stage

sysName = Lib.Media.System.systemName()
desktop = true
if sysName == "android" or sysName == "ios" then
    desktop = false
end

if desktop then
    print("active: "..Lib.Str.string(stage.window.active))
    print("x: "..stage.window.x)
    print("y: "..stage.window.y)
    print("width: "..stage.window.width)
    print("height: "..stage.window.height)
    print("title: "..stage.window.title)

    stage.addEventListener(Events.Event.RESIZE, function(e)
        print("resized width: "..stage.stageWidth.." "..stage.window.width)
        print("resized height: "..stage.stageHeight.." "..stage.window.height)
    end, false, 0, false)

    stage.window.setPosition(50, 50)
    stage.window.resize(200, 200)
    stage.window.title = "Test"
else
    print("Stage Window has only desktop apps")
end