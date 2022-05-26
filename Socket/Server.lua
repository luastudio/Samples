-- Server.lua

Thread = Lib.Sys.VM.Thread

t = Thread.create([[

s = Lib.Sys.Net.Socket.new()
s.bind(Lib.Sys.Net.Host.new("localhost"),5000)
s.listen(1)
Lib.Sys.trace("Starting server...")

active = true

while active do
  local c = s.accept() --accept socket
  Lib.Sys.trace("Client connected...")

  while true do
     local status, line = pcall(c.input.readLine)
     if not status then 
       break 
     else
       print(line) 
     end

     if line == "exit" then active = false break end
  end
end

s.close()
print("Server stop")
]])