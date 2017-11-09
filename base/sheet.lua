--author:bbbirder

--deprecated,use "table.sheet" instead.

--@Example:
-- local st = sheet
-- :headers
-- 		"name"	"age"	"birthday" 
-- :rows
-- 		"leo"	(18)	{10,21}
-- 		"lee"	(20)	{11,3}
-- 		"woo"	(11)	{9,13}
-- dump(st:data())
sheet = sheet or {}
sheet.headers = function(_t,h)
	local headers = {h}
	local headlen = 1
	local index = 0
	local body	= {}
	local function fillBoby(val)
		index = index % headlen + 1
		if index==1 then--start new row
			table.insert(body,{})
		end
		local curRow = body[#body]
		curRow[headers[index]] = val
	end
	return setmetatable({
		rows = function(t,val)
			fillBoby(val)
			return setmetatable({
				data = function()
					return body
				end,
			},{
				__call = function(t,val)
					fillBoby(val)
					return t
				end,
			})
		end
	},{
		__call = function(t,nh)
			table.insert(headers,nh)
			headlen = #headers
			return t
		end,
	})
end

-- sheet.create = function(headers)
-- 	local data = {}
-- 	return setmetatable({
-- 		data = function() return data end
-- 	},{
-- 		__call = function(t,p)
-- 			local curRow = {}
-- 			for i,hn in pairs(headers) do
-- 				curRow[hn] = p[i]
-- 			end
-- 			table.insert(data,curRow)
-- 		end
-- 	})
-- end
