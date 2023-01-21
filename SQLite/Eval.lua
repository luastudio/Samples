-- Eval.lua

connection = Lib.SQLight.Connection.new(":memory:")

--eval
--https://sqlite.org/src/file?name=ext/misc/eval.c&ci=trunk
resultSet = connection.request('SELECT eval("select 1,2,eval(""select 3,4"",""|"")", ",")', nil)
while resultSet.hasNext() do
	row = resultSet.next()
    Lib.Sys.trace(row)
end

connection.close()