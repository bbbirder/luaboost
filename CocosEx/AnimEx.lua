--author:bbbirder
--@EXAMPLE:
-- sp:runActionEx{
--     {x=0, y=0, time=1, call=packfunc(print,"ok")},
--     {x=300, y=500, time=2, scaleX=0.1, scaleY=1, call=packfunc(print,"ok2")},
--     {x=100, time=1, by=true, call=function(caller)
--         local sz = caller:size()
--         dump(sz)
--         caller:setTexture("logo1.png")
--         caller:scaleToSize(sz) 
--     end},
--     loop = {
--         {time=1, by=true, x=100},
--         {time=1, by=true, x=-100},
--     },
-- }
-- sp:runActionEx{
--     {rotation=720,time=4}
-- }

cc.Move3To = {
	create = function(o,t,x,y)
		return cc.MoveTo:create(t,cc.p(x,y))
	end,
}
cc.Move3By = {
	create = function(o,t,x,y)
		return cc.MoveBy:create(t,cc.p(x,y))
	end,
}

local function table2Action(caller,props)
	local _ret = {}
	for i,act in pairs(props) do
		if i=="loop" then
			_ret["loop"] = table2Action(caller,act)
			break --return _ret
		end
		local _act = {}
		local time = act.time
		local ease = act.ease
		local by   = act.by
		-- act.time= nil
		act.ease= nil
		act.by 	= nil
		for k,v in pairs(act) do
			if not ({time=true})[k] then
				local clsinfo = ({
					x 		= {	"Move3%s",	{"time","x","y"}},
					y 		= {	"Move3%s",	{"time","x","y"}},
					scaleX 	= {	"Scale%s",	{"time","scaleX","scaleY"}},
					scaleY 	= {	"Scale%s",	{"time","scaleX","scaleY"}},
					rotation= {	"Rotate%s",	{"time","rotation"}},
					opacity = {	"FadeTo",	{"time","opacity"}},
					call	= {	"CallFunc",	{"call"}},
				})[k]
				if clsinfo then
					local clsnm = clsinfo and clsinfo[1]:format(by and "By" or "To")
					local params= {}
					for i,pn in pairs(clsinfo[2]) do
						params[i] = act[pn] or 0
					end
					local _tmp = cc[clsnm]:create(unpack(params))
					if ease then
						local _name = ease[1] or ease
						local _rate = ease[2]
						xpcall(function()
							_tmp = cc["Ease".._name]:create(unpack{_tmp,_rate})
						end,function()end)
					end
					_act[clsnm] = _act[clsnm] or _tmp
				else
					table.insert(_act,cc.CallFunc:create(function()
						caller:getNodeEx()[k] = v
					end))
				end
			end
		end
		table.insert(_ret,table.values(_act))
	end
	return _ret
end

--interfaces
function cc.Node:runActionEx(acts)
	self:runEx(table2Action(self,acts))
end