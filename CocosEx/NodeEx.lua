--author:bbbirder
--@HOW TO USE
-- 1.获取NodeEx
-- local sp = display.newSprite("HelloWorld.png")
--     :move(display.center)
--     :addTo(self)
--     :getNodeEx() --convert to NodeEx
-- 2.读写属性
-- sp.x = 120	--设置单个属性
-- sp.y = 120
-- print(sp.x)	--读取属性
-- sp:setProp{	--设置多个属性 NodeEx
-- 	x = 0,
-- 	y = 0,
-- }
-- display.newNode():props{	--设置多个属性 cc.Node
-- 	x = 0,
-- 	y = 0,
-- }
-- 3.获取cc.Node
-- print(sp:getNode()) --或者
-- print(sp.node)

local newNodeEx = function(node)
	local ret = {node = node}
	ret.getNode = function()
		return node
	end
	ret.setProp = function(prop)
		for k,v in pairs(prop) do
			ret[k] = v
		end
		return ret
	end
	return setmetatable(ret,{
		__newindex = function(t,k,v)
			local fn = ({
				x 	= "setPositionX",
				y 	= "setPositionY",
				scale 	= "setScale",
				scaleX 	= "setScaleX",
				scaleY 	= "setScaleY",
				rotation= "setRotation",
				zOrder	= "setLocalZOrder",
				anchorX	= "setAnchorX",
				anchorY = "setAnchorY",
				texture = "setTexture",
				opacity = "setOpacity",
				visiblity = "visible",
			})[k]
			local f = node[fn or k]
			if f then
				f(node,v)
			else
				rawset(t,k,v)
			end
		end,
		__index = function(t,k)
			local fn = ({
				x	= "getPositionX",
				y	= "getPositionY",
				scale 	= "getScale",
				scaleX 	= "getScaleX",
				scaleY 	= "getScaleY",
				rotation= "getRotation",
				zOrder	= "getLocalZOrder",
				anchorX	= "getAnchorX",
				anchorY = "getAnchorY",
				texture = "getTexture",
				opacity = "getOpacity",
				visiblity = "visible",
			})[k]
			if fn then
				return node[fn](node)
			end
			return node[fn or k] or rawget(t,k)
		end,
	})
end

function cc.Node:getNodeEx()
	return newNodeEx(self)
end

function cc.Node:props(props)
	self:getNodeEx():setProp(props):getNode()
	return self
end