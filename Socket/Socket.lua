-- Socket.lua (WARNING: require internet connection)

socket = Lib.Sys.SSL.Socket.new()
--socket.verifyCert = true --by default not verified, or require setCA() method
print(socket.verifyCert) --false, no verification
print("Connecting to ipinfo.io (more free APIs: https://apipheny.io/free-api/)")
socket.connect( Lib.Sys.Net.Host.new( "ipinfo.io" ), 443 )
print("Connected")

print("Writing data")
socket.write( 'GET /161.185.160.93/geo HTTP/1.1'..'\r\n' )
socket.write( 'Host: ipinfo.io'..'\r\n' )
socket.write( 'User-Agent: LuaStudio socket example v1.0'..'\r\n' )

socket.write( 'Connection: keep-alive'..'\r\n'..'\r\n' )

print( "Waiting for incoming data ...." )

bufSize = 32
buf = Lib.Sys.IO.Bytes.alloc( 4096 )
pos = 0
len = -1
while true do
    len = socket.input.readBytes( buf, pos, bufSize )
	if( len < bufSize ) then break else pos = pos + len end
end
result = buf.toString()
lines = Lib.Str.split(result, '\n')
print( 'Recieved data: ')
for i=1,#lines,1 do
    print( Lib.Str.trim(lines[i]) )
end

cert = socket.peerCertificate()
print(cert.commonName)
Lib.Sys.trace(cert.altNames)
Lib.Sys.trace(cert.notBefore)
Lib.Sys.trace(cert.notAfter)

socket.close()

cert = Lib.Sys.SSL.Certificate.loadDefaults()
if cert ~= nil then
	Lib.Sys.trace(cert.commonName)
end