--[[
地煞星符搜索
--]]

local http = require("socket.http")
local cjson = require("cjson")
require("util")

local _STAR_SEARCH = {
	server_type,			--服务器类型[3:4年以上]
	pass_fair_show,			--时效[0: 公示期 1:已上架(不带该字段都选中)]
	price_min,				--最低价(单位分)
	price_max,				--最高价(单位分)
	current_level_min,		--当前最低等级
	current_level_max,		--当前最高等级
	limit_level_min,		--最低等级
	limit_level_max,		--最高等级
	aptitude_min,			--最低资质
	aptitude_max,			--最高资质
	shentong,				--神通[47:忽视震慑]
	xingzhen,				--星阵[3:苍狼]
}

--[[
神通对应表
--]]
local _SHENTONG_NAME_TABLE = {}
_SHENTONG_NAME_TABLE[12] = "强风"
_SHENTONG_NAME_TABLE[13] = "强水"
_SHENTONG_NAME_TABLE[14] = "强雷"
_SHENTONG_NAME_TABLE[15] = "强火"
_SHENTONG_NAME_TABLE[19] = "忽视抗冰"
_SHENTONG_NAME_TABLE[20] = "强冰"
_SHENTONG_NAME_TABLE[21] = "忽视抗混"
_SHENTONG_NAME_TABLE[25] = "忽视抗雷"
_SHENTONG_NAME_TABLE[26] = "忽视抗水"
_SHENTONG_NAME_TABLE[27] = "忽视抗风"
_SHENTONG_NAME_TABLE[28] = "忽视抗火"
_SHENTONG_NAME_TABLE[30] = "强鬼火"
_SHENTONG_NAME_TABLE[31] = "强三尸"
_SHENTONG_NAME_TABLE[32] = "强力克火"
_SHENTONG_NAME_TABLE[33] = "强力克水"
_SHENTONG_NAME_TABLE[35] = "强力克木"
_SHENTONG_NAME_TABLE[36] = "强力克金"
_SHENTONG_NAME_TABLE[38] = "加强震慑"
_SHENTONG_NAME_TABLE[42] = "四抗上限"
_SHENTONG_NAME_TABLE[47] = "忽视震慑"
_SHENTONG_NAME_TABLE[50] = "忽视抗鬼火"
_SHENTONG_NAME_TABLE[57] = "水狂暴程度"
_SHENTONG_NAME_TABLE[58] = "雷狂暴程度"
_SHENTONG_NAME_TABLE[59] = "火狂暴程度"
_SHENTONG_NAME_TABLE[60] = "雷狂暴"
_SHENTONG_NAME_TABLE[61] = "火狂暴"
_SHENTONG_NAME_TABLE[62] = "风狂暴"
_SHENTONG_NAME_TABLE[63] = "水狂暴"
_SHENTONG_NAME_TABLE[64] = "鬼火狂暴几率"
_SHENTONG_NAME_TABLE[65] = "鬼火狂暴程度"
_SHENTONG_NAME_TABLE[66] = "无属性"
_SHENTONG_NAME_TABLE[67] = "三尸狂暴几率"
_SHENTONG_NAME_TABLE[69] = "三尸回血程度"


function _KFSearchDiShaStar( page, search )
	local url = "http://xy2.cbg.163.com/cgi-bin/search.py?act=overall_search_disha_star" .. 
			"&page=" .. page ..
			"&server_type=" .. search.server_type ..
			"&current_level_min=" .. search.current_level_min ..
			"&current_level_max=" .. search.current_level_max ..
			"&limit_level_min=" .. search.limit_level_min ..
			"&limit_level_max=" .. search.limit_level_max ..
			"&aptitude_min=" .. search.aptitude_min ..
			"&aptitude_max=" .. search.aptitude_max

	if search.pass_fair_show ~= nil then
		url = url .. "&pass_fair_show=" .. search.pass_fair_show
	end

	if search.shentong ~= nil then
		url = url .. "&shentong=" .. search.shentong
	end

	if search.xingzhen ~= nil then
		url = url .. "&xingzhen=" .. search.xingzhen
	end

	if search.price_min ~= nil then
		url = url .. "&price_min=" .. search.price_min
	end
	if search.price_max ~= nil then
		url = url .. "&price_max=" .. search.price_max
	end

	body,status = http.request(url)
	if status ~= 200 then
		return nil,-1
	end

	DumpFile("./body_star.txt", body)

	return body,0
end

function ShowStarInfo( star )
	local desc = string.format("[%s]%d/%d 资质: %d 价格: %.2f元\n", star.equip_name, star.current_level, star.limit_level, star.aptitude, star.price/100)
	desc = desc .. string.format("服务器: %s 过期时间: %s pass_fair_show: %d\n", star.server_name, star.remain_expire_time, star.pass_fair_show)
	--神通
	desc = desc .. "神通:"
	for _,_v in pairs(star.shentong) do
		desc = desc .. string.format("%s ", _SHENTONG_NAME_TABLE[_v] or _v)
	end
	desc = desc .. "\n"
	--星阵
	if #star.xingzhen ~= 0 then
		desc = desc .. string.format("星阵: %d\n", star.xingzhen[1])
	end
	--描述
	desc = desc .. string.format("描述: %s\n", star.desc)
	desc = desc .. string.format("http://xy2.cbg.163.com/cgi-bin/equipquery.py?act=overall_search_show_detail&ordersn=" .. 
								star.game_ordersn .. "&serverid=" .. star.serverid .. "\n\n")
	Log("./result_star.txt", desc)
end

--查找元素是否在表中
local function V_In_Table(tb, val)
	for _,value in pairs(tb) do
		if value == val then
			return true
		end
	end
	return false;
end

--[[
属性过滤
--]]
local function SearchStarFilter( star )
----[[
	--查找双忽视抽
	for _,v in pairs(star.shentong) do
		if v ~= 47 then
			return false
		end
	end

	_,count = string.gsub(star.desc, "忽视抗震慑", "忽视抗震慑")
	if count ~= 2 then
		return false
	end
----]]
--[[
	--查找忽视/强
	if V_In_Table(star.shentong, 12) == false then
		return false
	end
	if V_In_Table(star.shentong, 27) == false then
		return false
	end
--]]

	return true
end

--[[
解析地煞信息
返回array,totalpage
--]]
function ParseDiShaStar( body )
	local array = {}
	local ctx = cjson.decode(body)
	local totalpage;
	totalpage = ctx["paging"]["total_pages"]
	local msg = ctx["msg"]
	for _,value in pairs(msg) do
		local star = {}
		star.aptitude = value["aptitude"]
		star.pass_fair_show = value["pass_fair_show"]
		star.server_name = value["server_name"]
		star.equip_name = value["equip_name"]
		star.remain_expire_time = value["remain_expire_time"]
		star.current_level = value["current_level"]
		star.limit_level = value["limit_level"]
		star.price = value["price"]
		star.shentong = value["shentong"]
		star.xingzhen = value["xingzhen"]
		star.game_ordersn = value["game_ordersn"]
		star.serverid = value["serverid"]
		star.other_info = cjson.decode(value["other_info"])
		star.desc = star.other_info["desc"]

		if SearchStarFilter(star) == true then
			array[#array+1] = star
			ShowStarInfo(star)
		end
	end

	return array,totalpage
end

function KFSearchDiShaStar( search )
	local page = 1
	local totalpage = 0
	local body

	repeat
		body,err = _KFSearchDiShaStar(page, search)
		if err ~= 0 then
			print("Searching page " .. page .. " Err! " .. err)
			return -1
		else
			print("Searching page " .. page .. "/" .. totalpage)
			_,totalpage = ParseDiShaStar(body)
			page = page+1
			Sleep(3.3)
		end
	until(page > totalpage)

	return 0
end
