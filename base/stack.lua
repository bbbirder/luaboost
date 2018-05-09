local stack = {}

function stack.stack()
	local rt = {}
	local index = 0
	local function push( ... )
		for i=1,select("#",...) do
			index = index + 1
			rt[index] = ({...})[i]
		end
	end
	local function pop( n )
		n = n or 1
		local ret = {}
		for i=n,1,-1 do
			ret[i] = rt[index]
			rt[index] = nil
			index = index - 1
		end
		return table.unpack(ret)
	end
	return setmetatable({
		push = push,
		pop  = pop,
	},{
		__len = function()
			return index
		end,
		__index = rt
	})
end

function stack.spairs(s,reverse)
	local i = 0
	return function()
		i = i + 1
		if i<=#s then
			return i,s[reverse and #s-i+1 or i]
		end
	end
end

return stack