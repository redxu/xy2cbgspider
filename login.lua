--[[
登录
--]]

local http = require("socket.http")
local cjson = require("cjson")
require("util")

function PreLogin( serverid, servername, areaid, areaname )
	serverid = serverid or 1
	servername = servername or "%%E5%%A4%%A9%%E8%%8B%%A5%%E6%%9C%%89%%E6%%83%%85"
	areaid = areaid or 4
	areaname = areaname or "%%E4%%BA%%BA%%E7%%95%%8C%%20"

	local url = string.format("http://xy2.cbg.163.com/cgi-bin/show_login.py?act=show_login&server_id=%d&server_name=%s&area_name=%s&area_id=%d",
				serverid, servername, areaname, areaid)
	_,err = http.request(url)
	return err
end

function ShowCaptcha( )
	math.randomseed(os.time())
	local r = math.random()
	local url = "http://xy2.cbg.163.com/cgi-bin/show_captcha.py?stamp=" .. r
	image,err = http.request(url)
	if err ~= 200 then
		return err
	end

	DumpBinFile("./login.jpg", image)

	return 0
end
