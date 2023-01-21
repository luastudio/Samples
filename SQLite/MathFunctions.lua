-- MathFunctions.lua

connection = Lib.SQLight.Connection.new(":memory:")

--math functions
resultSet = connection.request ([[
select 
	pi() as pi, 
	floor(1.8) as floor, 
	ceil(1.3) as ceil, 
	sqrt(4) as sqrt, 
	mod(7,2) as mod]], nil)
while resultSet.hasNext() do
	row = resultSet.next()
	print('Math: pi(): '..row.pi..' floor(1.8): '..row.floor..' ceil(1.3): '..row.ceil..' sqrt(4): '..row.sqrt..' mod(7,2): '..row.mod)
end

connection.close()