-- Socket.lua (WARNING: require internet connection)

socket = Lib.Sys.SSL.Socket.new()
--socket.verifyCert = true --by default not verified, or require setCA() method
print(socket.verifyCert) --false, no verification
print("Connecting to talk.google.com")
socket.connect( Lib.Sys.Net.Host.new( "talk.google.com" ), 5223 )
print("Connected")

print("Writing data")
socket.write( '<?xml version="1.0" encoding="UTF-8"?><stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="talk.google.com" xml:lang="en" version="1.0">' );
print( "Waiting for incoming XMPP stream ...." );
bufSize = 32
buf = Lib.Sys.IO.Bytes.alloc( 4096 )
pos = 0
len = -1
while true do
    len = socket.input.readBytes( buf, pos, bufSize )
	if( len < bufSize ) then break else pos = pos + len end
end
result = buf.toString()
print( 'Recieved xmpp stream: '..result )
--Should be something like: <stream:stream from="talk.google.com" id="E0F18D0BDA98612A" version="1.0" xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client">
socket.write( '</stream>' )

cert = socket.peerCertificate()
print(cert.commonName)
--Lib.Sys.trace(cert.altNames)
Lib.Sys.trace(cert.notBefore)
Lib.Sys.trace(cert.notAfter)

socket.close()

cert = Lib.Sys.SSL.Certificate.loadDefaults()
if cert ~= nil then
	Lib.Sys.trace(cert.commonName)
end
