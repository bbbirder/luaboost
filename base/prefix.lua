--author:bbbirder

function enum(t)
    local rt = {}
    for i,v in ipairs(t) do
        rt[v] = i-1
    end
    return rt
end

--create a read-only table,deprecated.
function const(t)
	local proxy = {}
    local mt = {
        __index = t,
        __newindex = function(t, k, v)
            error('attempt to update a read-only table', 2)
        end
    }
    setmetatable(proxy, mt)
    return proxy
end

--3目运算
--iif (1) "one" "other"
function iif(exp)
    return function(yesval)
        return function(noval)
            if exp then
                return yesval
            end
            return noval
        end
    end
end

function switch(val)
    local function innerfunc(t)
        for k,v in pairs(t) do
            if type(k)=="function" then k = k(v) end
            if k == val then
                if type(v) == "function" then 
                    return v()
                elseif type(v) == "thread" then
                    return coroutine.resume(v)
                else
                    return v
                end
            end
        end
        return t.default
    end
    return innerfunc
end

--move table or file into environment.
function using(src)
    if type(src)=="string" then
        src = require(src)
    end
    local func = debug.getinfo(2).func
    local ori_env = debug.getfenv(func)
    debug.setfenv(func,setmetatable({},{
        __index = function(t,k)
            if src[k]~=nil then return src[k] end
            return ori_env[k]
        end
    }))
end

--DEPRACATED.
--you can run string as script with params.
function loadscript(s,params)
    local function _loadtable(t,isInner)
        if not t then return "" end
        local _s = ""
        local _specifier = iif(isInner,"","local ")
        local _equal = ""
        local _endl = iif(isInner,",\n","\n")
        for k,v in pairs(t) do
            if type(k) == "string" then
                _equal = " = "
            else
                _equal = ""
                k = ""
                if not isInner then error("failed to loadscript,param of value '"..v.."' must has a name.") end
            end
            if type(v) == "string" then
                v = "\""..v.."\""
            elseif type(v) == "table" then
                v = "{".._loadtable(v,true).."}"
            end
            _s = _s.._specifier..k.._equal..v.._endl
        end
        return _s
    end
    local _script = _loadtable(params) .."\n".. s
    return loadstring(_script)
end

--@Ability:
-- better impliment of Handler,useful in cocos-event-callback,DEPRACATED
function packfunc(func,...)
  local _argsSuper = {...}
  local _c1 = select("#",...)
  local function innerFunc(...)
    local args = {...}
    local argsOut = {unpack(_argsSuper,1,_c1)}
    for i,v in pairs(args) do
      argsOut[_c1 + i] = v
    end
    return func(unpack(argsOut,1,table.maxn(argsOut)))
  end
  return innerFunc
end

--DEPRACATED
function packthread(co,...)
    local args = {...}
    local innerco = coroutine.create(function()
        while true do
            local stat = coroutine.resume(co,unpack(args))
            coroutine.yield()
            if not stat then break end
        end
    end)
    return innerco
end

function thread(func,...)
    local args = {...}
    return packthread(coroutine.create(func),unpack(args))
end

--占位变量（毫无存在感的）
if NIL_ALWAYS_VAR_ENABLED then
    _G._ = nil
    setmetatable(_G,{
        __newindex = function(t,k,v)
            if k~="_" then
                rawset(t,k,v)
            end
        end
    })
end

