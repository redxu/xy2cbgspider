
--[[
保存文件
--]]
function DumpFile( filename, body )
	local file = io.open(filename, "w+")
	file:write(body)
	file:close()
end

--[[
读取文件
--]]
function ReadFile( filename )
	local file = io.open(filename, "r")
	local ctx = file:read("*all")
	file:close()
	return ctx
end

--[[
记录日志
--]]
function Log( filename, body )
	local file = io.open(filename, "a")
	file:write(body)
	file:close()
end