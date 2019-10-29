-- sendMsgs.lua

Thread = Lib.Sys.VM.Thread

--get ref to main and thread2
local main = Thread.readMessage(true)
local t2 = Thread.readMessage(true)

for ii=0, 5, 1 do
	print("t1 sending: "..ii)
	t2.sendMessage(ii)
	Lib.Sys.sleep(0.5)
end

main.sendMessage("thread1 done")