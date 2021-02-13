-- Zip.lua

text = "test test test test test"
print(string.len(text))
bytesForCompression = Lib.Sys.IO.Bytes.ofString(text)
compressedBytes = Lib.Sys.Zip.Compress.run(bytesForCompression, 7)
print(compressedBytes.length)
print(compressedBytes.toHex())

uncompressedBytes = Lib.Sys.Zip.Uncompress.run(compressedBytes, nil)
print(uncompressedBytes.length)
print(uncompressedBytes.toString())