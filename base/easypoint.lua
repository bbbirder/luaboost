--author:bbbirder

--创建方法：
-- 	1.newp(5,6)
-- 	2.newp{x=5,y=6}
--主要成员：
--	x、y
--主要特性：
-- 	1.可比较向量是否相等
-- 	2.支持向量间加减
-- 	3.支持向量与数值乘除
-- 	4.可直接打印xy值
-- 	5.可以通过调用的方式重新设置xy,如：p(1,0)
-- 	6.可通过负号取反
--主要方法：
-- 	distanceTo:	到目标点的距离
-- 	angleTo:	到目标点的向量角度
-- 	getMul:		获取向量的模

function newp(x,y)
	if not y then
		y = x.y
		x = x.x
	end
	local p = {x = x,y = y}
	function p:distanceTo(x,y)
		local target = newp(x,y)
		return math.sqrt((target.x - self.x)^2 + (target.y - self.y)^2)
	end
	function p:angleTo(x,y)
		local target = newp(x,y)
		return math.atan2(target.y-self.y,target.x-self.x)*180/math.pi
	end
	function p:getMul()
		return self / self:distanceTo(0,0)
	end
	local mt = {
		-- __index = function(t,k)
		-- 	if k~="lat" and k~="lng" then return nil end
		-- 	local p = MapView:GetInstance():ToLatlng(t.x,t.y)
		-- 	return p[k]
		-- end,
		__call = function(t,x,y)
			t.x = x
			t.y = y
			return t
		end,
		__add = function(a,b)
			return newp(a.x+b.x,a.y+b.y)
		end,
		__sub = function(a,b)
			return newp(a.x-b.x,a.y-b.y)
		end,
		__eq = function(a,b)
			return a.x == b.x and a.y == b.y
		end,
		__tostring = function(t)
			return " vec2( " .. t.x .. " , " .. t.y .. " )"
		end,
		__mul = function(a,b)
			if type(a) == "number" then
				a,b = b,a
			end
			if type(b) == "number" then
				return newp(a.x*b,a.y*b)
			elseif type(b) == "table" then
				return newp(a.x*b.x,a.y*b.y)
			end
		end,
		__div = function(a,b)
			return newp(a.x/b,a.y/b)
		end,
		__unm = function(a)
			return newp(-a.x,-a.y)
		end,
	}
	setmetatable(p,mt)
	return p
end
