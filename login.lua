--[[
登录
--]]

local http = require("socket.http")
local ltn12 = require("socket.ltn12")
local cjson = require("cjson")
require("util")
require("httphelper")

--1
function PreLogin( serverid, servername, areaid, areaname, session)
	serverid = serverid or 1
	servername = servername or "%E5%A4%A9%E8%8B%A5%E6%9C%89%E6%83%85"
	areaid = areaid or 4
	areaname = areaname or "%E4%BA%BA%E7%95%8C%20"

	local url = string.format("http://xy2.cbg.163.com/cgi-bin/show_login.py?act=show_login&server_id=%d&server_name=%s&area_name=%s&area_id=%d",
				serverid, servername, areaname, areaid)
	--_,err = http.request(url)
	session = HttpGet(url, session)
	return session
end

--2
function ShowCaptcha( session )
	math.randomseed(os.time())
	local r = math.random()
	local url = "http://xy2.cbg.163.com/cgi-bin/show_captcha.py?stamp=" .. r
	--image,err = http.request(url)
	session = HttpGet(url, session)
	if session.errcode ~= 200 then
		return err
	end

	DumpBinFile("./login.jpg", session.response)

	return session
end

--3
function CheckCaptcha( code, session )
	local _url = "http://xy2.cbg.163.com/cgi-bin/show_captcha.py?act=check_login_captcha&captcha=" .. code

	local head = {["X-Request"] = "JSON", ["X-Requested-With"] = "XMLHttpRequest"}
	session.custom = nil
	session.custom = head
	session = HttpGet(_url, session)
	if session.errcode ~= 200 then
		return session
	end

	local ctx = cjson.decode(session.response)
	err = ctx["status"] or 0
	if (err == 1) then
		session = HttpGet(_url, session)
		ctx = cjson.decode(session.response)
		err = ctx["status"] or 0
	end

	return session,err

	--print(response_body)
end

--anonymous login
function NonauthLogin1( server_id, server_name, session)
	server_id = server_id or 1
	server_name = server_name or "%CC%EC%C8%F4%D3%D0%C7%E9"
	local url = "http://xy2.cbg.163.com/cgi-bin/login.py?act=do_anon_auth"
				.. "&server_id=" .. server_id
				.. "&server_name=" .. server_name

	local head = {
		["Cache-Control"] = "no-cache",
		["Host"] = "xy2.cbg.163.com",
		["Upgrade-Insecure-Requests"] = 1,
		["Referer"] = url,
	}

	session.custom = nil
	session.custom = head
	session = HttpGet(url, session)
	return session
end
