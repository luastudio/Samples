-- ToType.lua

connection = Lib.SQLight.Connection.new(":memory:")

--totype
--https://sqlite.org/src/file?name=ext/misc/totype.c&ci=trunk
resultSet = connection.request('SELECT tointeger("3"), toreal("7.2"), toreal("error")', nil)
while resultSet.hasNext() do
	row = resultSet.next()
    Lib.Sys.trace(row)
end

connection.close()