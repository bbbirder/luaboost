--author:bbbirder
--local storage
local _UserDefaultProperty = function(defaultValue)
	return {
		get = function(t,k)
			return cc.UserDefault:getInstance():getStringForKey(k,defaultValue)
		end,
		set = function(t,k,v)
			cc.UserDefault:getInstance():setStringForKey(k,v)
		end,
	}
end

LocalStorage = access {
	--register your keys...
	openid = _UserDefaultProperty("0"),
	code = _UserDefaultProperty("0"),
	un = _UserDefaultProperty(""),
	pw = _UserDefaultProperty(""),
	mscVol = _UserDefaultProperty(0.8),
	sndVol = _UserDefaultProperty(1),
	mscEnb = _UserDefaultProperty(1),
	sndEnb = _UserDefaultProperty(1),
	guiderStep = _UserDefaultProperty(1),
	use_card = _UserDefaultProperty(1),
	proxyID = _UserDefaultProperty("-1"),
	viewName = _UserDefaultProperty("SY"),
	round = _UserDefaultProperty(1),
	pay = _UserDefaultProperty(1),
	daixue = _UserDefaultProperty(0),
	daigang = _UserDefaultProperty(255),
	qionghu = _UserDefaultProperty(0),
	diansanpao = _UserDefaultProperty(255),
	qhgang = _UserDefaultProperty(255),
}
