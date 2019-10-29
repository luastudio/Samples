-- Crypto.lua

print(Lib.Sys.Crypto.Base64.encode( Lib.Sys.IO.Bytes.ofString("test"), true))
print(Lib.Sys.Crypto.Base64.decode("dGVzdA==", true).toString())

print(Lib.Sys.Crypto.Md5.encode("test"))

print(Lib.Sys.Crypto.Sha1.encode('test'))
print(Lib.Sys.Crypto.Sha224.encode('test'))
print(Lib.Sys.Crypto.Sha256.encode('test'))