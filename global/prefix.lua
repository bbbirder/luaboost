--author:bbbirder

--[[globals]]
_VERSION_N = _VERSION:sub(5)*1e3//1   -- eg: 5100 | 5200 | 5300

FLOAT_U    = (function(f,i)return i/2==0 and i or f(f,i/2)end) -- precision of number in lua
             (function(f,i)return i/2==0 and i or f(f,i/2)end,1)

-- INT_LEN    = #tostring{}-7<<2

--[[uniform 5.1 & 5.3]]

debug.getfenv = false
    or debug.getfenv 
    or getfenv
    or function(fn)
        local i = 1
        while true do
            local   name, val = debug.getupvalue(fn, i)

            if      name == "_ENV" 
            then    return val
            elseif  not name 
            then    break
            end

            i = i + 1
        end
    end

debug.setfenv = false
    or debug.setfenv 
    or setfenv
    or function(fn, env)
        local i = 1
        while true do
            local   name = debug.getupvalue(fn, i)

            if      name == "_ENV" 
            then    debug.setupvalue(fn, i, env)
                    break
            elseif  not name 
            then    break
            end

            i = i + 1
        end
        return fn
    end

unpack = unpack or table.unpack
loadstring = loadstring or load



--[[useful prefix]]
dump = dump or function(value,depth)
    depth = depth or 0
    if depth==0 then 
        print(debug.traceback("dump "..tostring(value))) 
    end
    if type(value)=="table" then
        print(("  "):rep(depth).."{")
        for k,v in pairs(value) do
            print(("  "):rep(depth+1)..tostring(k).." = "..tostring(v))
            if type(v)=="table" then dump(v,depth+1) end
        end
        print(("  "):rep(depth).."}")
    end
end


        ;(function()

        local mappingPaths = {}

        local up = function(dir)
            for i=#dir,1,-1 do if dir:byte(i) == 46 then -- lastIndexOf('.')
                return dir:sub(1,i-1)
            end end
            return ""
        end

        local whereRequirer = function(l)
            local _,dir = debug.getlocal(l and l+3 or 4, 1) --v is what required(string)
            return up(dir)
        end

        local calcPath = function(parent,v)
            local i = 1
            while v:byte(i)==46 do
                parent = up(parent)
                i = i+1
            end
            return parent.."."..v:sub(i)
        end

-- 短名查找常用模块，快捷方式
function import_redir(k) return function(v)
    local dir = whereRequirer()
    mappingPaths[k] = calcPath(dir,v)
end end

-- 在当前路径下require
function import(moduleName, l)
    if mappingPaths[moduleName] then return require(mappingPaths[moduleName]) end
    local parent = whereRequirer(l)
    return require(calcPath(parent,moduleName))
end

        end)();


-- 跟其它语言里的enum写法类似，不用加引号，且内部字段不受外部环境干扰。
-- 从别的语言里复制一段enum代码到lua时会变得方便。
-- firstindex: index from,default 1
-- eg:
-- local Thursday="a good day"
-- local week = enum(0){
--     Sunday,
--     Monday,
--     Tuesday,
--     Wednesday,
--     Thursday,
--     Friday,
--     Saturday,
-- }
-- print(Thursday)      --a good day
-- print(week.Thursday) --4

function enum(firstindex)
    firstindex = firstindex or 1
    local oldf = debug.getinfo(2).func
    local oldenv,olduv,oldlc = debug.getfenv(oldf),{},{}
    for i,k,v in lcpairs(2) do
        oldlc[i] = v
        debug.setlocal(2,i,k)
    end
    for i,k,v in uvpairs(2) do
        olduv[i] = v
        if k~="_ENV" then debug.setupvalue(oldf,i,k) end
    end
    local newenv = setmetatable({},{__index = function(t,k)return k end})
    debug.setfenv(oldf,newenv)
    return function(--[[strict codes...]]t)
        debug.setfenv(oldf,oldenv)
        for i,k,v in uvpairs(2) do
            if k~="_ENV" then debug.setupvalue(oldf,i,olduv[i]) end
        end
        for i,k,v in lcpairs(2) do
            debug.setlocal(2,i,oldlc[i])
        end
        ret = {}
        local i = firstindex
        for k,v in ipairs(t) do
            -- local isiv = tonumber(k)
            -- ret [isiv and v         or  k] = 
            --  (isiv and {_ENV[v]} or {v})[1]
            if ret[v] then error(("a redef field:%s in enum!"):format(v),2) end
            ret[v] = i
            i=i+1       
        end
        return ret
    end
end

-- create a read-only table,deprecated.(access metatable may cause problems)
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
function iif(exp) return function(yesval) return function(noval)
    if exp then
        return yesval
    end
    return noval
end end end

--  [[eg1:v的类型]]
-- local a = switch(3){
--   [1] = "one",
--   [2] = "two",
--   [3] = function return "three" end
-- }
-- print(a) -- three
--function、thread 都是返回被调用后的值,其他类型返回原值

--  [[eg2:k是表达式]]
-- local i = 3
-- local ret = switch(i){
--     [script''[[i<10]]] = "<10",
--     [script''[[i>10]]] = ">10",
-- }
-- print(ret) -- <10
-- k可以是一个判断函数

--  [[eg3:缺省值]]
-- local ret = switch(2){
--     [1] = "one",
--     [3] = "three",
--     [default] = "other"
-- }
-- print(ret) -- other
-- [default]可以指定缺省值

_G.default = {}
function switch(val) return function(t)

    local function getv(v)
        if type(v) == "function" then 
            return v()
        elseif type(v) == "thread" then
            return coroutine.resume(v)
        else
            return v
        end
    end

    local function ismatch(k,v)
        if type(k)=="function" then 
            return k(v)
        else
            return k == val
        end
    end

    for k,v in pairs(t) do if ismatch(k,v) then
        return getv(v)
    end end
    return getv(t[default])
end end

--用于实现模块化。
-- src参数类型如果是table，则把table中的成员加入到当前namespace；
-- 如果是字符串，表示这是个需要require的文件，先load再把返回的table加入到当前ns（加载过的不会重复加载）
--move table or file into environment.
--src:
--    table type will be recognized as module itself
--    string type will be recognized as require path to module.
function using(src)
    if type(src)=="string" then
        src = import(src,2)
    end
    assert(({userdata=true,table=true})[type(src)],"attempt to using a invalid type:"..type(src),2)
    local func = debug.getinfo(2).func
    local ori_env = debug.getfenv(func)
    debug.setfenv(func,setmetatable({},{
        __index = function(t,k)--read:new > ori
            if src[k]~=nil then return src[k] end
            return ori_env[k]
        end,
        __newindex = function(t,k,v)--write:ori
            ori_env[k] = v
        end
    }))
end



-- 嵌入一段字符串lua代码，返回对应的function，用于简化代码和元编程。字符串内可以正常的读写scope里的任何变量，无任何限制
-- run a string as code,eg:
-- local a = 1
-- local t = {}
-- t.n = 1
-- local f = script "x,y" [[
--     a   = x
--     t.n = y
-- ]]
-- f(13,13)
-- print(a,t.n)  -- 13    13
function script(sargs)
    sargs = sargs or ""
    return function(s)
        local prefix = "return function("..sargs..") return ("
        local suffix = ") end"
        local f,err = loadstring(prefix..s..suffix)
        if not f then 
            prefix = "return function("..sargs..") "
            suffix = " end"
            f,err = loadstring(prefix..s..suffix)
        end
        if not f then
            error(err,2)
        end
        f = f()
        debug.setfenv(f,copyscope(2))
        return f
    end
end



--use 'functional.bind' instead
--@Ability:
-- better impliment of Handler,useful in cocos-event-callback,DEPRACATED
-- jump to file './functional.lua'
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

--用 _ 变量名代替nil，方便传空值、赋空值。
--需要NIL_ALWAYS_VAR_ENABLED为真才能用。在config.lua里配置。
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

