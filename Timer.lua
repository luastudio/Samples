-- Timer.lua

startTime = Lib.Sys.getTime()

i = 1
timer = Lib.Media.Utils.Timer.new(500,10)
timer.addEventListener(Lib.Media.Events.TimerEvent.TIMER, function(e)
    print("timer: "..i)
    if i == 10 then timer.stop(); print("Finished: "..(Lib.Sys.getTime() - startTime)) end 
    i = i + 1
end, false, 0 ,false)
timer.start()