module(..., package.seeall)

-- Your loading Scene
local loadingScene = "sceneLoad"

-- Global variables for chain loading
preloader.params = nil
preloader.plNextLoadScene = nil
preloader.plEffect = nil
preloader.plArg1 = nil
preloader.plArg2 = nil
preloader.plArg3 = nil

function preloader:changeScene(params,nextLoadScene, effect, arg1, arg2, arg3)
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