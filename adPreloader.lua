module(..., package.seeall)

-- Your loading Scene
local loadingScene = "adScene"

-- Global variables for chain loading
adPreloader.params = nil
adPreloader.plNextLoadScene = nil
adPreloader.plEffect = nil
adPreloader.plArg1 = nil
adPreloader.plArg2 = nil
adPreloader.plArg3 = nil

function adPreloader:changeScene(params,nextLoadScene, effect, arg1, arg2, arg3)
		if type( params ) ~= "table" then
			arg3 = arg2
			arg2 = arg1
			arg1 = effect
			effect = nextLoadScene
			nextLoadScene = params
			params = nil
		end
		params = params
        plNextLoadScene = nextLoadScene
        plEffect = effect
        plArg1 = arg1
        plArg2 = arg2
        plArg3 = arg3
        director:changeScene(loadingScene,effect,arg1,arg2,arg3)
end