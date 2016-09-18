local socket = require("socket")

--[[
保存文件
--]]
function DumpFile( filename, body )
	local file = io.open(filename, "w+")
	file:write(body)
	file:close()
end

--[[
保存二进制文件
--]]
function DumpBinFile( filename, bin )
	local file = io.open(filename, "wb")
	file:write(bin)
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

--[[
休眠
--]]
function Sleep( n )
	socket.select(nil, nil, n)
end

--[[
计算表中元素个数
--]]
function GetTableItemCount( tb )
	local count = 0
	for _,_ in pairs(tb) do
		count = count+1
	end
	return count
end

function table.print( tb )
	for k,v in pairs(tb) do
		print("table key/value: " .. k .. " / " .. v)
	end
end

--合并两个table,返回新table
function table.merge( src, dst )
	if (src == nil) then
		return nil
	end
	local newt = src
	if (dst == nil) then
		return newt
	end

	for k,v in pairs(dst) do
		newt[k] = v
	end

	return newt
end

function string.trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--[[
分割字符串
--]]
function string.split(str, delimiter)
	if str==nil or str=='' or delimiter==nil then
		return nil
	end
	
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end


