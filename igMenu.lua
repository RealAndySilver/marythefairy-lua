module(..., package.seeall)

new = function (params)
	local thisView = {params = params, name="igMenu"}
	
	local ui = require("ui")
	local util = require("util")
	
	local localGroup = display.newGroup()
	
	local w, h = display.contentWidth, display.contentHeight
	local realw, realh = display.viewableContentWidth, display.viewableContentHeight
	
	local ratioM = (w/h)/(realw/realh)
	if ratioM>1 then ratioM = 1/ratioM end
	local ratioM2 = ratioM^2
	local scaleFactor = (0.65+ratioM2^4*0.1)^2
	
	local background = display.newImage( "assets/menu/fondoMenu"..suffix..".png" )
	background:setReferencePoint(display.TopLeftReferencePoint)
	background.xScale,background.yScale=800/background.contentWidth,571/background.contentHeight
	
	local windowGroup = display.newGroup()
	windowGroup:insert(background)
	
	--======================================
	-- TEXT
	--======================================
	local myString = "Select Adventure"
	if params.inGame then
		myString = "Game paused"
	end
	local myText = display.newText(myString, 0, 0, mainFont1, 64)
	myText:setReferencePoint(display.CenterReferencePoint)
	myText.x=windowGroup.contentWidth/2
	myText.y=windowGroup.contentHeight/2-130
	myText:setTextColor(67,34,15,255)
	windowGroup:insert(myText)
	
	local resumeButtonAction = function ( event )
		if event.phase == "release" then
			local function action()
				director:closePopUp()
				if params.hideAction then
					params.hideAction()
				end
				if params.caller then
					local callerParams = nil
					if params.caller.params then
						callerParams = params.caller.params
						callerParams.animated = false
					end
					if callerParams == nil then
						callerParams = {}
					end
					director:openPopUp(callerParams, params.caller.name, nil )
				end
			end
			transition.to(windowGroup,{alpha=0,xScale=windowGroup.xScale*2,yScale=windowGroup.yScale*2,time=200,onComplete=action})
			resumeButtonAction=nil
		end
	end
	local mainMenuButtonAction = function ( event )
		if event.phase == "release" then
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
	
	local homeButton = ui.newButton{
					default = "assets/homeButton.png",
					onEvent = mainMenuButtonAction,
					id = "bt01"}
	homeButton.isVisible=false
	homeButton.x,homeButton.y=70,40
	homeButton.xScale,homeButton.yScale=0.65,0.65
	windowGroup:insert(homeButton)
	
	local closeButton = ui.newButton{
					default = "assets/xButton.png",
					onEvent = resumeButtonAction,
					id = "bt02"}
	closeButton.isVisible=false
	closeButton.x,closeButton.y=windowGroup.contentWidth-40,30
	closeButton.xScale,closeButton.yScale=0.65,0.65
	windowGroup:insert(closeButton)
	
	if params.inGame then
		homeButton.isVisible=true
		closeButton.isVisible=true
		local resumeButton = ui.newButton{
						default = "assets/botonVerde.png",
						onEvent = resumeButtonAction,
						text = "Resume",
						size = 84,
						font = mainFont1,
						--offset = correctOffset(-5),
						emboss = true,
						textColor={66,33,11,255},
						id = "bt01"}
		resumeButton.x=windowGroup.contentWidth/2
		resumeButton.y=windowGroup.contentHeight-150
		resumeButton.xScale,resumeButton.yScale = 0.8,0.8
		windowGroup:insert(resumeButton)
	else
		closeButton.isVisible=true
		local resumeButton = ui.newButton{
						default = "assets/botonAzul.png",
						onEvent = resumeButtonAction,
						text = "Back",
						size = 84,
						font = mainFont1,
						--offset = correctOffset(-5),
						emboss = true,
						textColor={66,33,11,255},
						id = "bt01"}
		resumeButton.x=windowGroup.contentWidth/2
		resumeButton.y=windowGroup.contentHeight-150
		resumeButton.xScale,resumeButton.yScale = 0.8,0.8
		windowGroup:insert(resumeButton)
	end
	
	local adventuresTitles = {"Catch",
							  "Dry",
							  "Fly",
							  "Race",
							  "Sleep"}
	local textTransformingIndex = 1
	
	--[[
	if (screenScale >= 2) then
		adventuresTitles = {"Help Mary to catch the funny animals",
							"Help Mary to dry her wings",
							"Help Mary to fly",
							"Help Mary to win her first race",
							"Help Mary to sleep"}
		textTransformingIndex = 2
	end
	]]
	
	local buttonsArrayFunctions = {}
	local buttonsArray = {}
	local maxUnlockedLevel=getMaxUnlockedLevel()
	
	for i=1,5,1 do
		-- ACTION
		buttonsArrayFunctions[i] = function ( event )
			if i<=maxUnlockedLevel and event.phase == "release" then
				director:closePopUp()
				if params.startFromAdventure then
					director:openPopUp({startFromAdventure = params.startFromAdventure, adventureToStart = i, caller = thisView}, "selectDiff", nil )
				else
					local function startFromAdventure(adventureNumber)
						if not adventureNumber then
							return
						end
						if adventureNumber<=0 or adventureNumber>#levelIDS then
							return
						end
						if params.killCaller then
							params.killCaller()
						end
						preloader:changeScene("Interactivity"..adventureNumber,"moveFromRight")
					end
					director:openPopUp({startFromAdventure = startFromAdventure, adventureToStart = i, caller = thisView}, "selectDiff", nil )
				end
			elseif event.phase == "release" then
				print("not available")
			end
		end
		
		if i<=maxUnlockedLevel then
			buttonsArray[i] = display.newGroup()
			local displayButton = ui.newButton{
							default = "assets/menu/botonSeleccionAdv.png",
							onEvent = buttonsArrayFunctions[i],
							text = ""..i,
							size = 86,
							font = mainFont1,
							offset = correctOffset(-20),
							emboss = true,
							textColor={66,33,11,255},
							id = "bt01"}
			displayButton.xScale,displayButton.yScale=0.8,0.8
			buttonsArray[i]:insert(displayButton)
			
			local buttonLabel = util.centeredWrappedText(adventuresTitles[i], 10*textTransformingIndex, 40/textTransformingIndex, mainFont1, {67,34,15,255})
			buttonLabel.y=50
			buttonsArray[i]:insert(buttonLabel)
			
			buttonsArray[i].x=(windowGroup.contentWidth/2 - 260 + 130 * (i-1))-10
			buttonsArray[i].y=200
			
		else
			buttonsArray[i] = display.newGroup()
			local displayButton = display.newCircle(0,0,50)
			displayButton:setFillColor(0,0,0,0)
			displayButton:setStrokeColor(0,0,0,128)
			displayButton.strokeWidth=2
			displayButton.xScale,displayButton.yScale=0.8,0.8
			buttonsArray[i]:insert(displayButton)
			
			local displayButtonText = display.newText(""..i, 0, 0, mainFont1, 86)
			displayButtonText:setReferencePoint(display.CenterReferencePoint)
			displayButtonText.x=0
			displayButtonText.y= correctOffset(-8)
			displayButtonText:setTextColor(0,0,0,128)
			buttonsArray[i]:insert(displayButtonText)
			
			local buttonLabel = util.centeredWrappedText("Blocked", 10*textTransformingIndex, 40/textTransformingIndex, mainFont1, {67,34,15,255})
			buttonLabel.y=60
			buttonsArray[i]:insert(buttonLabel)
			
			buttonsArray[i].x=(windowGroup.contentWidth/2 - 260 + 130 * (i-1))-10
			buttonsArray[i].y=190
		end
		-- ACTION
		if i<=maxUnlockedLevel then
			buttonsArray[i].alpha=1
		else
			buttonsArray[i].alpha=0.5
		end
		
		buttonsArray[i].xScale,buttonsArray[i].yScale = 1.0,1.0
		buttonsArray[i].y = buttonsArray[i].y+70
		
		windowGroup:insert(buttonsArray[i])
	end
	
	local soundActivationGroup = display.newGroup()
	
	local soundLabel = display.newText("Sound", 0, 0, mainFont1, 48)
	soundLabel.y = correctOffset(soundLabel.y)
	soundLabel:setTextColor(66,33,11,255)
	soundActivationGroup:insert(soundLabel)
	
	local SBGSRoundedRect = display.newRoundedRect(100, 10, 150, 50, 12)
	SBGSRoundedRect.strokeWidth = 8
	SBGSRoundedRect:setFillColor(255, 121, 171)
	SBGSRoundedRect:setStrokeColor(255, 121, 171)
	SBGSRoundedRect:setReferencePoint(display.CenterReferencePoint)
	soundActivationGroup:insert(SBGSRoundedRect)
	
	local SBGRoundedRect = display.newRoundedRect(100, 10, 150, 50, 12)
	SBGRoundedRect.strokeWidth = 0
	SBGRoundedRect:setFillColor(158, 98, 123)
	SBGRoundedRect:setStrokeColor(0, 0, 0)
	SBGRoundedRect:setReferencePoint(display.CenterReferencePoint)
	soundActivationGroup:insert(SBGRoundedRect)
	
	local SliderMask = display.newImageRect("assets/SBBGM.png",12,50)
	SliderMask:setReferencePoint(display.TopLeftReferencePoint)
	SliderMask.x = 0
	SliderMask.y = 10
	SliderMask:setReferencePoint(display.CenterReferencePoint)
	SliderMask.x = SBGRoundedRect.x
	soundActivationGroup:insert(SliderMask)
	
	local SSliderRoundedRect = display.newImageRect("assets/SBBG.png", 75, 50)
	SSliderRoundedRect:setReferencePoint(display.TopLeftReferencePoint)
	SSliderRoundedRect.x = 100
	SSliderRoundedRect.y = 10
	SSliderRoundedRect:setReferencePoint(display.CenterReferencePoint)
	soundActivationGroup:insert(SSliderRoundedRect)
	
	local onTextLabel = display.newText( "On", 0, 0, mainFont1, 42 )
	onTextLabel.x = SBGRoundedRect.x - 35
	onTextLabel.y = soundLabel.y
	onTextLabel:setTextColor(142,84,111)
	soundActivationGroup:insert(onTextLabel)
	
	local offTextLabel = display.newText( "Off", 0, 0, mainFont1, 42 )
	offTextLabel.x = SBGRoundedRect.x + 35
	offTextLabel.y = soundLabel.y
	offTextLabel:setTextColor(142,84,111)
	soundActivationGroup:insert(offTextLabel)
	
	soundActivationGroup:setReferencePoint(display.CenterReferencePoint)
	soundActivationGroup.x=windowGroup.contentWidth*3/4
	soundActivationGroup.y=windowGroup.contentHeight-75
	soundActivationGroup.xScale,soundActivationGroup.yScale = 0.9,0.9
	windowGroup:insert(soundActivationGroup)
	
	local function showSoundState(animate)
		SBGRoundedRect:setReferencePoint(display.CenterRightReferencePoint)
		SSliderRoundedRect:setReferencePoint(display.CenterRightReferencePoint)
		local newX = SBGRoundedRect.x
		if soundActivated then
			SBGRoundedRect:setReferencePoint(display.CenterLeftReferencePoint)
			SSliderRoundedRect:setReferencePoint(display.CenterLeftReferencePoint)
			newX = SBGRoundedRect.x
		end
		
		if animate then
			transition.to(SSliderRoundedRect,{x = newX, time=100})
		else
			SSliderRoundedRect.x = newX
		end
		
		SBGRoundedRect:setReferencePoint(display.CenterReferencePoint)
		newX = SBGRoundedRect.x + 6
		if soundActivated then
			newX = SBGRoundedRect.x - 6
		end
		
		if animate then
			transition.to(SliderMask,{x = newX, time=100})
		else
			SliderMask.x = newX
		end
	end
	showSoundState()
	
	local function changeSoundStateEvent(event)
		if event.phase == "ended" then
			setSoundActivation(not soundActivated)
			saveSoundActivation()
			showSoundState(true)
		end
	end
	soundActivationGroup:addEventListener("touch",changeSoundStateEvent)
	
	local titleLabel = ui.newButton{
					default = "assets/botonMadera.png",
					text = "Menu",
					size = 72,
					font = mainFont1,
					offset = correctOffset(-10),
					emboss = true,
					textColor={66,33,11,255},
					id = "bt01"}
	titleLabel.x=windowGroup.contentWidth/2
	titleLabel.y=35
	titleLabel.xScale,titleLabel.yScale=1.1,1.1
	windowGroup:insert(titleLabel)
	
	windowGroup:setReferencePoint(display.CenterReferencePoint)
	windowGroup.x = display.contentWidth/2
	windowGroup.y = display.contentHeight/2
	windowGroup.xScale = scaleFactor*0.9
	windowGroup.yScale = scaleFactor*0.9
	
	if params.animated then
		transition.from(windowGroup,{alpha=0,xScale=windowGroup.xScale*2,yScale=windowGroup.yScale*2,time=200})
	end
	localGroup:insert( windowGroup )
	
	return localGroup
end