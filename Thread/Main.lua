-- Main.lua

Thread = Lib.Sys.VM.Thread

print("Message Passing Example")
--create two threads, keep references
t1 = Thread.create("/Thread/sendMsgs.lua")
t2 = Thread.create([[--thread getMsgs
Thread = Lib.Sys.VM.Thread

--get ref to main
local main = Thread.readMessage(true)

for ii=0, 5, 1 do
	print("t2 waiting for msg")
	print("t2 got: "..Thread.readMessage(true))
end

main.sendMessage("thread2 done")
]])

--give thread2 a ref to main thread
t2.sendMessage(Thread.current())

--give thread1 ref to main thread and thread2
t1.sendMessage(Thread.current())
t1.sendMessage(t2)

--wait for them to finish
Lib.Media.Display.stage.addEventListener(Lib.Media.Events.Event.ENTER_FRAME,
    function (e)
		local message = Thread.readMessage(false)
		if message ~= nil then
			print(message)
		end
    end, false, 0, false)