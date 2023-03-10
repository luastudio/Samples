-- Base64.lua
--https://sqlite.org/src/file?name=ext/misc/base64.c&ci=trunk

connection = Lib.SQLight.Connection.new(":memory:")


textBytes = Lib.Sys.IO.Bytes.ofString("test")

resultSet = connection.request('SELECT base64(?) as encode64, base64(?) as decode64', {textBytes.getData(), "dGVzdA=="})
while resultSet.hasNext() do
	row = resultSet.next()

    encode64 = Lib.Str.join(Lib.Str.split(row.encode64, "\n"), "") -- remove text line endings
    print(encode64)
    print(encode64 == Lib.Sys.Crypto.Base64.encode(textBytes, true))

    decode64 = Lib.Sys.IO.Bytes.ofData(row.decode64).toString()
    print(decode64)
    print(decode64 == Lib.Sys.Crypto.Base64.decode("dGVzdA==", true).toString())
end

connection.close()