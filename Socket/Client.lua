-- Client.lua

s = Lib.Sys.Net.Socket.new()

status, msg = pcall(s.connect, Lib.Sys.Net.Host.new("localhost"), 5000)
if not status then 
  print("Can't connect to server: "..msg)
else
  s.write("Hi from\n");
  s.write("client\n");
  --s.write("exit");
  s.close()
end