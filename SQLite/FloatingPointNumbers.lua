-- FloatingPointNumbers.lua
-- https://www.sqlite.org/floatingpoint.html
-- https://sqlite.org/src/file?name=ext/misc/ieee754.c&ci=trunk
-- https://sqlite.org/src/file?name=ext/misc/decimal.c&ci=trunk

connection = Lib.SQLight.Connection.new(":memory:")

connection.request ([[
-- The pow2 table will hold all the necessary powers of two.
CREATE TABLE pow2(x INTEGER PRIMARY KEY, v TEXT)
]], nil) 

connection.request ([[
WITH RECURSIVE c(x,v) AS (
  VALUES(0,'1')
  UNION ALL
  SELECT x+1, decimal_mul(v,'2') FROM c WHERE x+1<=971
) INSERT INTO pow2(x,v) SELECT x, v FROM c
]], nil) 

connection.request ([[
WITH RECURSIVE c(x,v) AS (
  VALUES(-1,'0.5')
  UNION ALL
  SELECT x-1, decimal_mul(v,'0.5') FROM c WHERE x-1>=-1075
) INSERT INTO pow2(x,v) SELECT x, v FROM c
]], nil) 


resultSet = connection.request ([[
-- This query finds the decimal representation of each value in the "c" table.
WITH c(n) AS (VALUES(47.49))
                 ----XXXXX----------- Replace with whatever you want
SELECT decimal_mul(ieee754_mantissa(c.n),pow2.v)
  FROM pow2, c WHERE pow2.x=ieee754_exponent(c.n)
]], nil) 

while resultSet.hasNext() do
	row = resultSet.next()
	Lib.Sys.trace(row)
end

connection.close()