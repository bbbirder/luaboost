--author:bbbirder

import ".base.memory"
using "lambda"




--[[run_memory_test]];(function ()
	print("memory模块测试，当前lua版本".._VERSION..",详细细节:")

	-- tail call test
	local _ = "\t:) 底层实现了tail call"
	function test_callstack()
		local _ = "\t:( 小心爆栈,底层未实现tail call"
		return findvar("_")
	end
	print(test_callstack(),"")

	-- upvalue cast test
	function test_upvalue_cast(val)
		function inner()
			return val
		end
		return function()
			return inner()
		end
	end
	local f1 = test_upvalue_cast("f1")
	local f2 = test_upvalue_cast("f2")
	_ = f1()=="f1" 
		and "\t:( upvalue在内部传递" 
		or  "\t:) upvalue不在内部传递"
	print(_)


	-- _ENV test
	_ = _ENV 
		and "\t:) 常量型环境变量" 
		or  "\t:( memory模块不能使用,应改用环境方法"
	print(_)

	-- table memory test
	_ = function()return {}end
	_ = _()==_() 
		and "\t:| table右值引用内存,不要再使用functional模块！" 
		or  "\t:| table左值引用内存" 
	print(_)


	-- function memory test
	_ = function()return function()end end
	_ = _()==_() 
		and "\t:( function右值引用内存，旧版本functional会出错" 
		or  "\t:) function左值引用内存\n\t:) thread左值引用内存"
	print(_)
	
	-- decimal test
	_ = .1+.2==.3 and "\t :) 定点运算" or "\t :) 浮点运算"
	print(_)

	-- int test
if _VERSION_N>=5300-FLOAT_U then
	local _ = [[
		local d,i = 1,1
		while i>0 do
			i = i<<1
			d = d+1
		end
		return d
	]]
	print("\t:) "..loadstring(_)().."位int")
end

	--module test
	print "开始测试："
	function test_local()
		local lcval = "lc"
		print(findlocal("lcval")=="lc" and "\t:) findlocal works!" or "\t:( findlocal fialed!")
	end
	test_local()

	local upval = "uv"
	function test_upvalue()
		local upval = upval
		print(findupval("upval")=="uv" and "\t:) findupval works!" or "\t:( findupval fialed!")
	end
	test_upvalue()

	local tmp
	_ENV.__TEST_SCOOP,tmp = "env",_ENV.__TEST_SCOOP
	local __TEST_SCOOP = "uv"
	function test_scoop()
		function f0()
			local _ = findvar("__TEST_SCOOP")
			return _ == "env"
		end
		function f1()
			local lc = __TEST_SCOOP
			local _ = findvar("__TEST_SCOOP")
			return _ == "uv"
		end
		function f2()
			local __TEST_SCOOP = "lc"
			local _ = findvar("__TEST_SCOOP")
			return _ == "lc"
		end
		print(f0() and f1() and f2() and "\t:) findvar works!" or "\t:( findvar fialed!")
	end
	test_scoop()

	local __TEST_SCOOP = "uv"
	function test_setvar()
		function f0()
			setvar("__TEST_SCOOP","_env")
			return __TEST_SCOOP == "_env"
		end
		function f1()
			local lc = __TEST_SCOOP
			setvar("__TEST_SCOOP","_uv")
			return __TEST_SCOOP == "_uv"
		end
		function f2()
			local __TEST_SCOOP = "lc"
			setvar("__TEST_SCOOP","_lc")
			return __TEST_SCOOP == "_lc"
		end
		print(f2() and f1() and f1() and "\t:) setvar works!" or "\t:( setvar fialed!")
	end
	test_setvar()
	_ENV.__TEST_SCOOP = tmp
	print(_ENV.__TEST_SCOOP and ":| end memory test!" or ":) end memory test!")
end)()






--[[run_enum_test]];(function()
	local two = "uv"
	return function()
		local _ = two
		local one = "lc"
		local e = enum(--[[index from 0]]0){
			zero,	--0,will automatically name this field
			one,	--1,will ignore local value
			two,	--2,will ignore upvalue
			three,	--3,will automatically name this field
		}
		
		if e.zero~=0
		or e.one~=1
		or e.two~=2
		or e.three~=3
		then return error(":( enum test failed! bad result")
		end

		if one~="lc"
		or two~="uv"
		then return error(":( enum test failed! bad scoop")
		end

		print(":) enum works!")
	end
end)()()





--[[run_lambda_test]];(function()
	-- do return end--uncomment this line to pass test
	local f



	local a = 2
	if (lambda()(x){a*x+3})(3)~=9
	or a~=2
	then return error(":( lambda test failed! scope error")
	end

	local foo = function() return error(":( lambda test failed! meta called") end
	lambda()(x){foo(x)}

	print(":) lambda works!")

end)()
