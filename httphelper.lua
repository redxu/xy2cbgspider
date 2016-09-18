--[[
Http 访问方法
--]]

local http = require("socket.http")
local ltn12 = require("socket.ltn12")
require("util")

--[[
去除cookie中限制的字段
domain,path,expires
--]]
local function DealCookie( cookietable, cookie )
	cookietable = cookietable or {}
	cookie = cookie or ""

	--newcookie = newcookie .. ";"
	--newcookie = string.gsub(newcookie, "(expires=.-; )", "")
	--newcookie = string.gsub(newcookie, "(domain=.-; )", "")
	--newcookie = string.gsub(newcookie, "(path=.-; )", "")
	----[[
	local ck = string.split(cookie, ";") or {}
	for _,v in pairs(ck) do
		local ck2 = string.split(string.trim(v), ",") or {}
		for _,v2 in pairs(ck2) do
			local ck3 = string.split(string.trim(v2), "=") or {}
			if #ck3 == 2 then
				local key = string.trim(ck3[1])
				local value = string.trim(ck3[2])
				if key ~= "expires" and key ~= "domain" and key ~= "path" then
					cookietable[key] = value
				end
			end
		end
	end
	----]]
	--[[
	if oldcookie == "" then
		oldcookie = newcookie
	elseif (string.sub(oldcookie, -2, -1) == "; ") then
		oldcookie = oldcookie .. newcookie
	elseif (string.sub(oldcookie, -1, -1) == ";") then
		oldcookie = oldcookie .. "; " .. newcookie
	else
		print(oldcookie .. " unknow end")
	end
	--]]

	return cookietable
end

--
local function Cookie2String( cookie )
	local str = "";
	cookie = cookie or {}
	for k,v in pairs(cookie) do
		str = str .. string.format("%s=%s; ", k, v)
	end
	return str;
end

local _useragents = {
	"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36",
	"Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.76 Mobile Safari/537.36",
	"Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; WOW64; Trident/7.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0)",
	"Mozilla/5.0 (Windows NT 6.1; rv:36.0) Gecko/20100101 Firefox/36.0",
	"Mozilla/5.0 (Windows NT 6.1; WOW64; rv:31.0) Gecko/20130401 Firefox/31.0"
}

HttpSession = {
	header = nil,
	custom = nil,
	cookie = nil,
	response = nil,
	errcode = nil,
	location = nil
}
HttpSession.__index = HttpSession

HttpSession.Init = function ()
	local self = {}
	setmetatable(self, HttpSession)
	self.header = {}
	self.custom = {}
	self.cookie = {}
	self.response = ""
	self.errcode = 0
	math.randomseed(os.time())
	self.header["user-agent"] = _useragents[math.random(1,#_useragents)]
	self.header["connection"] = "Keep-Alive"
	self.header["accept"] = "text/html, application/xhtml+xml, application/xml, */*"
	return self
end

--[[
return:HttpSession
--]]
function HttpGet( url, session )
	local _tmp = {}
	local header = table.merge(session.header, session.custom)
	header["Cookie"] = Cookie2String(session.cookie)
	local context,code,head = http.request{
			url = url,
			method = "GET",
			sink = ltn12.sink.table(_tmp),
			headers = header,
			redirect = false
		}

	session.response = table.concat(_tmp, "")
	_tmp = nil
	session.errcode = code
	--处理cookie
	if (head) then
		_tmp = {}
		if (head["Cookie"]) then
			print("Cookie" .. head["Cookie"])
			session.cookie = head["Cookie"]
		end
		if (head["set-cookie"]) then
			session.cookie = DealCookie(session.cookie, head["set-cookie"])
		end
	else
		print("head = nil")
		session.cookie = nil
	end

	--support 303
	if code == 303 then
		session.location = head["location"]
		return HttpGet(session.location, session)
	end

	return session
end


function HttpPost( url, postdata, session )
	local _tmp = {}
	postdata = postdata or ""
	local header = table.merge(session.header, session.custom)
	header["Cookie"] = Cookie2String(session.cookie)
	header["Content-Type"] = "application/x-www-form-urlencoded"
	header["Content-Length"] = string.len(postdata)

	local context,code,head = http.request({
			url = url,
			method = "POST",
			headers = header,
			source = ltn12.source.string(postdata),
			sink = ltn12.sink.table(_tmp),
			redirect = false
		}, postdata)
	session.response = table.concat(_tmp, "")
	_tmp = nil
	session.errcode = code
	--处理cookie
	if (head) then
		_tmp = {}
		if (head["Cookie"]) then
			print("Cookie" .. head["Cookie"])
			session.cookie = head["Cookie"]
		end
		if (head["set-cookie"]) then
			session.cookie = DealCookie(session.cookie, head["set-cookie"])
		end
	else
		session.cookie = nil
	end

	return session
end