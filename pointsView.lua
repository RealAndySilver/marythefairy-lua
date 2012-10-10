module(..., package.seeall)

new = function (params)
	local thisView = {params = params, name="pointsView"}
	
	local ui = require("ui")
	local util = require("util")
	local gPS = require( "gPS" )
	
	local points = 0
	if params.points then
		if type(params.points) == "number" then
			points = params.points
		end
	end
	
	local setPointsText
	
	local starValue = 15000
	
	local localGroup = display.newGroup()
	
	local w, h = display.contentWidth, display.contentHeight
	local realw, realh = display.viewableContentWidth, display.viewableContentHeight
	
	local background = display.newRect(0,0,480,640)
	background:setReferencePoint(display.TopLeftReferencePoint)
	--background.xScale,background.yScale=800/background.contentWidth,571/background.contentHeight
	background.isVisible=false
	
	local windowGroup = display.newGroup()
	windowGroup:insert(background)
	
	local realBG = display.newImage( "assets/menu/fondoMiniMenu.png" )
	realBG:setReferencePoint(display.BottomCenterReferencePoint)
	local rbgScaleFactor = (windowGroup.contentWidth / realBG.contentWidth)*1.25
	realBG.xScale,realBG.yScale = rbgScaleFactor*1.5,rbgScaleFactor*1.5
	realBG.x = windowGroup.contentWidth/2
	realBG.y = windowGroup.contentHeight-10
	windowGroup:insert(realBG)
	
	local myText = display.newText("Score:", 0, 0, mainFont1, 110)
	myText:setReferencePoint(display.BottomLeftReferencePoint)
	myText.x=-80
	myText.y=180
	myText:setTextColor(67,34,15,255)
	windowGroup:insert(myText)
	
	local congratsMSG = display.newImage( "assets/congratulationsMessage.png" )
	congratsMSG:setReferencePoint(display.TopCenterReferencePoint)
	local cmsgScaleFactor = (windowGroup.contentWidth / realBG.contentWidth)*1.25
	congratsMSG.xScale,congratsMSG.yScale = cmsgScaleFactor*1.1,cmsgScaleFactor*1.1
	congratsMSG.x = realBG.x
	congratsMSG.y = -(realBG.contentHeight*3/5)
	windowGroup:insert(congratsMSG)
	
	local retryButtonAction = function ( event )
		if event.phase == "release" then
			setPointsText(points)
			local function action()
				director:closePopUp()
				if params.repeatAction then
					params.repeatAction()
				end
			end
			transition.to(windowGroup,{alpha=0,xScale=windowGroup.xScale*0.1,yScale=windowGroup.yScale*0.1,time=200,onComplete=action})
			retryButtonAction=nil
		end
	end
	local resumeButtonAction = function ( event )
		if event.phase == "release" then
			setPointsText(points)
			local function action()
				director:closePopUp()
				if params.hideAction then
					params.hideAction()
				end
			end
			transition.to(windowGroup,{alpha=0,xScale=windowGroup.xScale*2,yScale=windowGroup.yScale*2,time=200,onComplete=action})
			resumeButtonAction=nil
		end
	end
	local mainMenuButtonAction = function ( event )
		if event.phase == "release" then
			setPointsText(points)
			local function action()
				director:closePopUp()
				if params.killCaller then
					params.killCaller()
				end
				preloader:changeScene("mainMenu","crossfade")
			end
			transition.to(windowGroup,{alpha=0,xScale=windowGroup.xScale*2,yScale=windowGroup.yScale*2,time=200,onComplete=action})
			mainMenuButtonAction=nil
		end
	end
	
	--[[
	local homeButton = ui.newButton{
					default = "assets/homeButton.png",
					onEvent = mainMenuButtonAction,
					id = "bt01"}
	homeButton.isVisible=false
	homeButton.x,homeButton.y=70,40
	homeButton.xScale,homeButton.yScale=0.65,0.65
	windowGroup:insert(homeButton)
	]]
	
	local resumeButton = ui.newButton{
					default = "assets/botonVerde.png",
					onEvent = resumeButtonAction,
					text = "Continue",
					size = 72,
					font = mainFont1,
					--offset = correctOffset(-10),
					emboss = true,
					textColor={66,33,11,255},
					id = "bt01"}
	resumeButton:setReferencePoint(display.BottomRightReferencePoint)
	resumeButton.x=realBG.x+340
	resumeButton.y=background.contentHeight-65
	resumeButton.xScale,resumeButton.yScale = 1.7,1.7
	windowGroup:insert(resumeButton)
	resumeButton.isVisible=true
	
	local retryButton = ui.newButton{
					default = "assets/botonAzulPequeno.png",
					onEvent = retryButtonAction,
					text = "Retry",
					size = 72,
					font = mainFont1,
					--offset = correctOffset(-10),
					emboss = true,
					textColor={66,33,11,255},
					id = "bt01"}
	retryButton:setReferencePoint(display.BottomLeftReferencePoint)
	retryButton.x=realBG.x-340
	retryButton.y=background.contentHeight-65
	retryButton.xScale,retryButton.yScale = 1.7,1.7
	windowGroup:insert(retryButton)
	retryButton.isVisible=true
	
	local adventuresTitles = {"Help Mary to catch the funny animals",
							  "Help Mary to dry her wings",
							  "Help Mary to fly"}
	local buttonsArray = {}
	local maxUnlockedLevel=getMaxUnlockedLevel()
	
	----------------------------------------------------------------------
	local rdm = math.random
	local explosionColor = {140,214,234,255}
	if params.darkMode then
		explosionColor = {140,214,234,255}
	end
	function startStar(group)
		for i=1,50 do
			local star1 = { imgStart = { life = rdm(600,1000), alpha = 0.6, size = {8,8}, stroke={}, pos = {0,0,rdm(-5,5),rdm(30,40)},color=explosionColor},
								imgEnd = { onComplete = nil, alpha = 0.3, scale ={1,1},pos={0,0,rdm(-200,50),rdm(-30,90),move = 1, ease = easing.outQuad}},
								imgInfo = { group = group, max = 60}}
			gPS.newCircle(star1)
		end
	end
	----------------------------------------------------------------------
	
	animationDuration = 50
	animationDelay = 450
	for i=1,5,1 do
		buttonsArray[i] = display.newGroup()
		local starImage = display.newImageRect("assets/star_d.png",101,101)
		starImage.alpha = 1.0
		buttonsArray[i]:insert(starImage)
		
		if i<=(points/(starValue)) then
			local particleGroup = display.newGroup()
			local coolStarImage = display.newImageRect("assets/star.png",101,101)
			coolStarImage.alpha = 0
			transition.to(coolStarImage,{alpha=1,time = animationDuration, delay = (animationDuration + animationDelay)*(i+1), onComplete=function() startStar(particleGroup) end})
			buttonsArray[i]:insert(coolStarImage)
			buttonsArray[i]:insert(particleGroup,true)
		end
		
		buttonsArray[i]:setReferencePoint(display.CenterLeftReferencePoint)
		buttonsArray[i].xScale,buttonsArray[i].yScale=1.1,1.1
		buttonsArray[i].x=(i-1)*110-80
		buttonsArray[i].y=realBG.y-(realBG.contentHeight*3/5)-25
		
		windowGroup:insert(buttonsArray[i])
	end
	
	pointsTextNumber = 0
	local pointsText = display.newText(pointsTextNumber, 0, 0, mainFont1, 150)
	pointsText:setReferencePoint(display.CenterLeftReferencePoint)
	pointsText:setTextColor(193,39,45,255)
	if params.darkMode then
		--pointsText:setTextColor(252,247,156,255)
    end
    pointsText.x = -80
    pointsText.y = 330--correctOffset(365)
	windowGroup:insert(pointsText)
	
	local function growPointsTextNumber()
		if pointsTextNumber >= points then
			Runtime:removeEventListener("enterFrame",growPointsTextNumber)
			return
		end
		local growNumber = math.random(350,650)
		if pointsTextNumber < points then
			for i=1,10 do
				if pointsTextNumber + growNumber > points then
					growNumber = math.ceil(growNumber/2)
				else
					i=10
				end
			end
		end
		if pointsTextNumber + growNumber <= points then
			pointsTextNumber = pointsTextNumber + growNumber
		else
			pointsTextNumber = pointsTextNumber+1
		end
		pointsText.text = pointsTextNumber
		pointsText.x = -80
		pointsText:setReferencePoint(display.CenterLeftReferencePoint)
	end
	timer.performWithDelay(500, function() Runtime:addEventListener("enterFrame",growPointsTextNumber) end )
	
	setPointsText = function()
		Runtime:removeEventListener("enterFrame",growPointsTextNumber)
		pointsTextNumber = points
		pointsText.text = pointsTextNumber
	end
	
	local windowWScaleFactor = realw/windowGroup.contentWidth
	local windowHScaleFactor = realh/windowGroup.contentHeight
	local wSF = ((windowWScaleFactor > windowHScaleFactor) and windowHScaleFactor) or windowWScaleFactor
	windowGroup:setReferencePoint(display.CenterReferencePoint)
	windowGroup.x = display.contentWidth/2 - realw/5
	windowGroup.y = display.contentHeight/2 + display.contentHeight*0.05
	windowGroup.xScale = wSF * 0.8
	windowGroup.yScale = wSF * 0.8
	
	if params.animated then
		transition.from(windowGroup,{alpha=0,xScale=windowGroup.xScale*2,yScale=windowGroup.yScale*2,time=200})
	end
	localGroup:insert( windowGroup )
	
	--======================================
	-- MENU BUTTON
	--======================================
	-- ACTION
	local menuButtonAction = function ( event )
		if event.phase == "release" then
			setPointsText(points)
			local function action()
				director:closePopUp()
			end
			local function otherAction()
				director:openPopUp({inGame = true,
									animated = false,
									hideAction = nil,
									startFromAdventure = nil,
									caller = thisView,
									killCaller = params.killCaller,
									},
									"igMenu")
			end
			transition.to(windowGroup,{alpha=0,xScale=windowGroup.xScale*0.1,yScale=windowGroup.yScale*0.1,time=200,onComplete=function() action(); otherAction(); end})
			menuButtonAction = nil
		end
	end
	-- UI ELEMENT
	local menuButton = ui.newButton{
					default = "assets/botonMenu.png",
					onEvent = menuButtonAction,
					text = "Menu",
					size = 72,
					font = mainFont1,
					emboss = true,
					textColor={66,33,11,255},
					id = "bt01"}
	menuButton:setReferencePoint(display.CenterRightReferencePoint)
	menuButton.x=display.screenOriginX+display.viewableContentWidth-15
	menuButton.y=display.screenOriginY+25
	menuButton.xScale,menuButton.yScale=0.45,0.45
	localGroup:insert(menuButton)
	
	return localGroup
end