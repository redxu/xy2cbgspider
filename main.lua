--[[ 
	藏宝阁爬虫程序
--]]

--设置环境变量
local old_package_path = package.path
package.path = string.format("%s?.lua;%s", "./socket/", old_package_path)

require("role")
require("dishastar")

--[[
--角色搜索
local search = {}
search.race = 3
search.level_min = 4000
search.level_max = 4165
search.full_exp_rider_num = 4
search.talent_num = 40
search.server_type = 3
search.child_eval_point = 4500
search.gongji_point_min = 4800
search.gongji_point_max = 10000
search.price_max = 500000
--search.pass_fair_show = 0

err = KFSearchRole(search)
if err ~= 0 then
	print("NetWork Error!")
	return
end
--]]

----[[
--地煞星搜索
local search = {}
search.server_type = 3
search.price_max = 300000
search.current_level_min = 11
search.current_level_max = 14
search.limit_level_min = 11
search.limit_level_max = 14
search.aptitude_min = 91
search.aptitude_max = 100
search.shentong = "12%2C47"
--search.pass_fair_show = 0
err = KFSearchDiShaStar(search)
--body,err = _KFSearchDiShaStar(3, search)
if err ~= 0 then
	print("NetWork Error!")
	return
end
----]]


