-- Http.lua (WARNING: require internet connection)

url = 'https://www.w3.org/'
print( 'Sending http request to '..url )

r = Lib.Sys.Net.Http.new( url )
r.onData = print
r.onError = print
r.onStatus = function(code)
  print("status code: "..code)
end
r.onBytesData = function(bytes)
  print("bytes length: "..bytes.length)
  print("first byte: "..bytes.get(0))
end
r.request(false)