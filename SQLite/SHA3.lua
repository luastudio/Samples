-- SHA3.lua

connection = Lib.SQLight.Connection.new(":memory:")

--sha3
--https://sqlite.org/src/file?name=ext/misc/shathree.c&ci=trunk
--SIZE is included it must be one of the integers 224, 256, 384, or 512
resultSet = connection.request('SELECT sha3(10, 224), sha3_query("select 10")', nil)
while resultSet.hasNext() do
	row = resultSet.next()
    Lib.Sys.trace(row)
end

connection.close()