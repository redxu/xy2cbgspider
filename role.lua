--[[
	角色搜索
--]]

local http = require("socket.http")
local cjson = require("cjson")
require("util")

--角色属性
local _ROLE = {
	talent_num,
	seller_roleid,
}

--角色搜索属性
local _ROLE_SEARCH = {
	race,					--种族[1:人 2:魔 3:仙 4:鬼]
	level_min,				--最低等级
	level_max,				--最大等级
	full_exp_rider_num,		--满坐骑数
	talent_num,				--天赋点
	server_type,			--服务器类型[3:4年以上]
	pass_fair_show,			--时效[0: 公示期 1:已上架(不带该字段都选中)]
	child_eval_point,		--小孩评价[]
	gongji_point_min,		--最小功绩
	gongji_point_max,		--最大功绩
	price_min,				--最低价(单位分)
	price_max,				--最高价(单位分)
}

--修正名对应表 
local _MPREI_NAME_TABLE = {
	def_rate = "抗物理",
	iMp = "法力",
	iHp = "气血",
	re_absorb = "抗抽",
	iDog = "速度",
	re_disorder = "抗混",
	re_disorder_max_ext = "抗混上限",
	re_faint = "抗睡",
	re_faint_max_ext = "抗睡上限",
	re_seal = "抗冰",
	re_seal_max_ext = "抗冰上限",
	re_water = "抗水",
	re_fire = "抗火",
	re_thunder = "抗雷",
	re_wind = "抗风"
}

--[[
 * [跨服找角色]
 * @param {[type]} page   [description]
 * @param {[type]} search [description]
--]]
local function _KFSearchRole( page, search )
	-- body
	local url = "http://xy2.cbg.163.com/cgi-bin/overall_search.py?act=overall_search_role" .. 
				"&race=" .. search.race ..
				"&order_by=price%20ASC" ..
				"&level_min=" .. search.level_min ..
				"&level_max=" .. search.level_max ..
				"&page=" .. page ..
				"&full_exp_rider_num=" .. search.full_exp_rider_num ..
				"&talent_num=" .. search.talent_num ..
				"&server_type=" .. search.server_type ..
				"&child_eval_point=" .. search.child_eval_point

	if search.pass_fair_show ~= nil then
		url = url .. "&pass_fair_show=" .. search.pass_fair_show
	end

	if search.price_min ~= nil then
		url = url .. "&price_min=" .. search.price_min
	end
	if search.price_max ~= nil then
		url = url .. "&price_max=" .. search.price_max
	end

	if search.gongji_point_min ~= nil and search.gongji_point_max ~= nil then
		url = url .. "&gongji_point_min=" .. search.gongji_point_min .. "&gongji_point_max=" .. search.gongji_point_max
	end

	body,status = http.request(url)
	if status ~= 200 then
		return nil,-1
	end

	DumpFile("./body.txt", body)

	return body,0
end

--[[
转换js到json
--]]
local function lpc_2_js( js )
	local s = nil
	s = string.gsub(js, ",]%)", "}")
	s = string.gsub(s, ",}%)", "]")
	s = string.gsub(s, "%(%[", "{")
	s = string.gsub(s, "]%)", "}")
	s = string.gsub(s, "%({", "[")
	s = string.gsub(s, "}%)", "]")
	return s
end

--[[
百分比转数字
--]]
local function per_2_num( percent )
	local str
	str = percent or "0"
	str = string.gsub(str, "%%", "")
	return tonumber(str)
end

local function ShowRoleInfo( role )
	local desc = string.format("role: %s nickname: %s price: %.2f\n", role.role, role.seller_nickname, role.price)
	desc = desc .. string.format("服务器: %s 等级: %d pass_fair_show: %s\n", role.server_name, role.iGrade, role.pass_fair_show)
	--坐骑 飞行器
	desc = desc .. string.format("满坐骑数: %d 飞行器等级: %d\n", role.full_exp_rider_num, role.flyfabaolv)
	--天赋 功绩
	desc = desc .. string.format("天赋: %d 功绩: %d\n", role.talent_num, role.iAchievement)
	--体力 师徒 地宫
	desc = desc .. string.format("体力: %d 师徒: %d 地宫:%d\n", role.iTili, role.iShitu, role.iDigong)
	--五行强克
	if role.beat_water > 100 then
		desc = desc .. string.format("克水: %.1f\n", role.beat_water)
	end
	if role.beat_fire > 100 then
		desc = desc .. string.format("克火: %.1f\n", role.beat_fire)
	end
	if role.beat_wood > 100 then
		desc = desc .. string.format("克木: %.1f\n", role.beat_wood)
	end
	if role.beat_metal > 100 then
		desc = desc .. string.format("克金: %.1f\n", role.beat_metal)
	end
	if role.beat_earth > 100 then
		desc = desc .. string.format("克土: %.1f\n", role.beat_earth)
	end
	--强法属性
	if role.add_water + role.ignore_re_water*1.5 > 80 then
		desc = desc .. string.format("强水: %.1f 忽视: %.1f 狂暴: %.1f\n", role.add_water, role.ignore_re_water, role.water_cruel_rate)
	end
	if role.add_fire + role.ignore_re_fire*1.5 > 80 then
		desc = desc .. string.format("强火: %.1f 忽视: %.1f 狂暴: %.1f\n", role.add_fire, role.ignore_re_fire, role.fire_cruel_rate)
	end
	if role.add_wind + role.ignore_re_wind*1.5 > 80 then
		desc = desc .. string.format("强风: %.1f 忽视: %.1f 狂暴: %.1f\n", role.add_wind, role.ignore_re_wind, role.wind_cruel_rate)
	end
	if role.add_thunder + role.ignore_re_thunder*1.5 > 80 then
		desc = desc .. string.format("强雷: %.1f 忽视: %.1f 狂暴: %.1f\n", role.add_thunder, role.ignore_re_thunder, role.thunder_cruel_rate)
	end
	if role.add_wildfire + role.ignore_re_wildfire*1.5 > 80 then
		desc = desc .. string.format("强鬼火: %.1f 忽视: %.1f 狂暴: %.1f\n", role.add_wildfire, role.ignore_re_wildfire, role.wildfire_cruel_rate)
	end
	--小孩属性
	for i=1,role.iBabyCount,1
	do
		desc = desc .. string.format("baby%d: 亲密/孝心: %d/%d 结局: %s\n", i, role.babys[i].iQinmi, role.babys[i].iXiaoxin, role.babys[i].cEnd)
	end
	if role.shenbing ~= "" then
		desc = desc .. string.format("神兵: %s\n", role.shenbing)
	end
	if role.xianqi ~= "" then
		desc = desc .. string.format("仙器: %s\n", role.xianqi)
	end
	desc = desc .. string.format("灵修: %d 套装: %s\n", role.iSuitPoint, table.concat(role.suit, " "))
	--修正
	desc = desc .. "修正1:"
	for _k,_v in pairs(role.mpRei) do
		desc = desc .. string.format("%s:%s ", _MPREI_NAME_TABLE[_k] or _k, _v)
	end
	desc = desc .. "\n"
	--修正2
	if role.mpRei2 ~= nil then
		desc = desc .. "修正2:"
		for _k,_v in pairs(role.mpRei2) do
			desc = desc .. string.format("%s:%s ", _MPREI_NAME_TABLE[_k] or _k, _v)
		end
		desc = desc .. "\n"		
	end

	desc = desc .. string.format("http://xy2.cbg.163.com/cgi-bin/equipquery.py?act=overall_search_show_detail&equip_id=" .. role.equipid.. "&serverid=" .. role.serverid .. "\n\n")
	
	--print(desc)
	Log("./role.txt", desc)
end

--[[
属性过滤
--]]
local function SearchRoleFilter( role )
	if role.iAchievement < 4800 then
		return false
	end

	if role.talent_num < 41 then
		return false
	end

	local baby = false;
	for i=1,role.iBabyCount,1
	do
		if role.babys[i].iQinmi+role.babys[i].iXiaoxin > 750 then
			baby = true
			break
		end
	end
	if baby == false then
		return false
	end

	return true;
end

--[[
解析角色信息
返回array,totalpage
--]]
function ParseRole( body )
	local array = {}
	local ctx = cjson.decode(body)
	local totalpage;
	totalpage = ctx["paging"]["num_end"]
	local msg = ctx["msg"]
	for key,value in pairs(msg) do
		local role = {}
		role.zuofang2_type = value["zuofang2_type"]
		role.talent_num = value["talent_num"]
		role.role = value["role"]
		role.seller_roleid = value["seller_roleid"]
		role.seller_nickname = value["seller_nickname"]
		role.shenbing = value["shenbing"]
		role.xianqi = value["xianqi"]
		role.equipid = value["equipid"]
		role.serverid = value["serverid"]
		role.server_name = value["server_name"]
		role.full_exp_rider_num = value["full_exp_rider_num"]
		role.pass_fair_show = value["pass_fair_show"]
		role.price = value["price"]
		local large = lpc_2_js(value["large_equip_desc"])
		DumpFile("large.txt", large)
		role.detail = cjson.decode(large)
		--功绩
		role.iAchievement = role.detail["iAchievement"]
		--体力
		role.iTili = role.detail["iTili"]
		--师徒积分
		role.iShitu = role.detail["iShitu"]
		--地宫积分
		role.iDigong = role.detail["iDigong"]
		--等级?
		role.iGrade = role.detail["iGrade"]
		--小孩格子数
		role.iInitBabyCount = role.detail["iInitBabyCount"]
		--小孩数量
		role.iBabyCount = #role.detail["BabyList"]
		role.babys = {}
		--小孩属性
		for i=1,role.iBabyCount,1
		do
			role.babys[i] = {}
			--亲密
			role.babys[i].iQinmi = role.detail["BabyList"][i]["iQinmi"]
			--孝心
			role.babys[i].iXiaoxin = role.detail["BabyList"][i]["iXiaoxin"]
			--叛逆
			role.babys[i].iPanni = role.detail["BabyList"][i]["iPanni"]
			--年龄
			role.babys[i].cAge = role.detail["BabyList"][i]["cAge"]
			--养育金
			role.babys[i].iMoney = role.detail["BabyList"][i]["iMoney"]
			--结局
			role.babys[i].cEnd = role.detail["BabyList"][i]["cEnd"]
		end
		--收录套装
		role.suit = {}
		for k,_ in pairs(role.detail["mpEngravingSuit"]) do
			role.suit[#role.suit+1] = k
		end
		--灵修值
		role.iSuitPoint = role.detail["iSuitPoint"]
		--法术属性
		role.add_water = per_2_num(role.detail["mpResist"]["add_water"])
		role.add_fire = per_2_num(role.detail["mpResist"]["add_fire"])
		role.add_wind = per_2_num(role.detail["mpResist"]["add_wind"])
		role.add_thunder = per_2_num(role.detail["mpResist"]["add_thunder"])
		role.add_wildfire = per_2_num(role.detail["mpResist"]["add_wildfire"])
		role.add_corpse_bug = per_2_num(role.detail["mpResist"]["add_corpse_bug"])
		role.add_corpse_bug_degree = per_2_num(role.detail["mpResist"]["add_corpse_bug_degree"])
		role.ignore_re_water = per_2_num(role.detail["mpResist"]["ignore_re_water"])
		role.ignore_re_fire = per_2_num(role.detail["mpResist"]["ignore_re_fire"])
		role.ignore_re_wind = per_2_num(role.detail["mpResist"]["ignore_re_wind"])
		role.ignore_re_thunder = per_2_num(role.detail["mpResist"]["ignore_re_thunder"])
		role.ignore_re_wildfire = per_2_num(role.detail["mpResist"]["ignore_re_wildfire"])
		role.water_cruel_rate = per_2_num(role.detail["mpResist"]["water_cruel_rate"])
		role.fire_cruel_rate = per_2_num(role.detail["mpResist"]["fire_cruel_rate"])
		role.wind_cruel_rate = per_2_num(role.detail["mpResist"]["wind_cruel_rate"])
		role.thunder_cruel_rate = per_2_num(role.detail["mpResist"]["thunder_cruel_rate"])
		role.wildfire_cruel_rate = per_2_num(role.detail["mpResist"]["wildfire_cruel_rate"])
		
		role.beat_fire = per_2_num(role.detail["mpResist"]["beat_fire"])
		role.beat_earth = per_2_num(role.detail["mpResist"]["beat_earth"])
		role.beat_wood = per_2_num(role.detail["mpResist"]["beat_wood"])
		role.beat_metal = per_2_num(role.detail["mpResist"]["beat_metal"])
		role.beat_water = per_2_num(role.detail["mpResist"]["beat_water"])
		--飞行器
		role.flyfabaolv = 1
		for _,_v in pairs(role.detail["mpFlyFabao"]["flyfabao"]) do
			role.flyfabaolv = math.max(role.flyfabaolv, _v["iLevel"])
		end
		--属性修正
		if role.detail["mpRei2"]["2"] == nil then
			role.mpRei = role.detail["mpRei"]
		else
			role.mpRei = role.detail["mpRei2"]["1"]
			role.mpRei2 = role.detail["mpRei2"]["2"]
		end

		if SearchRoleFilter(role) == true then
			array[#array+1] = role
			ShowRoleInfo(role)
		end
	end
	return array,totalpage
end

function KFSearchRole( search )
	local page = 1
	local totalpage = 0
	local body

	repeat
		body,err = _KFSearchRole(page, search)
		if err ~= 0 then
			print("Searching page " .. page .. " Err! " .. err)
			return -1
		else
			print("Searching page " .. page)
			_,totalpage = ParseRole(body)
			page = page+1
		end
	until(page > totalpage)

	return 0
end
