module(..., package.seeall)

new = function ( params )
	soundController.killAll()
	
	soundController.playNew{
					path = "assets/sound/mainScreen.mp3",
					loops = -1,
					pausable = false,
					staticChannel = 6,
					actionTimes = {},
					action =	function()
								end,
					onComplete = function()
								end
					}
	------------------
	-- Imports
	------------------
	local ui = require("ui")
	local util = require("util")
	
	------------------
	-- Variables
	------------------
	local width = display.contentWidth
	local height = display.contentHeight
	
	local viewableContentWidth = display.viewableContentWidth
	local viewableContentHeight = display.viewableContentHeight
	
	local screenOriginX = display.screenOriginX
	local screenOriginY = display.screenOriginY
	
	local scaleSheets = 1
	if display.contentScaleX<=0.5 then --this wonderful new API will let you know if you're scaling your content and thus if it's playing on a highres device. Since my config.lua has an x size of 480 and the device x is 960, we get the .5.
		scaleSheets = 0.5
	end
	
	local paused = false
	
	local menuButton
	local overlay
	
	--======================================
	-- SUBTITLE FRAME
	--======================================
	local subtitleGroup = display.newGroup()
	local subtitleFrame = display.newImageRect("assets/pedazoDeMadera.png",width,95.5)
	subtitleFrame:setReferencePoint(display.TopLeftReferencePoint)
	subtitleFrame.x,subtitleFrame.y=0,display.screenOriginY+display.viewableContentHeight-95
	subtitleFrame:setReferencePoint(display.CenterReferencePoint)
	subtitleGroup:insert(subtitleFrame)
	
	local subtitleArray = getTextArrayFromFile("assets/c1a1s.txt",system.ResourceDirectory)
	local times = { 3480, 2503, 7254, 8370, 6029, 7983, 5462, 5525, 5700 }
	
	local subtitleDisplayObject = TextCandy.CreateText({
		fontName 	= mainFont1,
		x		= subtitleFrame.x,
		y		= subtitleFrame.y + 5,
		text	 	= "...",
		originX	 	= "CENTER",
		originY	 	= "CENTER",
		textFlow 	= "CENTER",
		fontSize    = 24,
		Color		= {67,34,15,255},
		wrapWidth	= viewableContentWidth*0.8,
		charBaseLine	= "CENTER",
		showOrigin 	= false
	})
	subtitleGroup:insert(subtitleDisplayObject)
	
	--local lastt = system.getTimer()
	local function showSubtitleIndex(index)
		if subtitleArray[index] then
			--print(system.getTimer()-lastt)
			local newString = ""..subtitleArray[index]
			--print(newString)
			
			local cIOT = defaultIOT
			if times[index] then
				local realTime = times[index] - 1000
				if realTime < 0 then realTime = 0 end
				if newString:len() then
					local newDelay = realTime / newString:len()
					cIOT.inCharDelay = newDelay
				end
			end
			
			subtitleDisplayObject:applyInOutTransition( cIOT )
			subtitleDisplayObject:setText(newString)
		else
			subtitleDisplayObject:setText("...")
		end
		--lastt = system.getTimer()
	end
	
	local aSI = 0
	showSubtitleIndex(aSI)
	local function nextSubtitle()
		aSI = aSI+1
		showSubtitleIndex(aSI)
	end
	
	local daScale = 1
	local function getDaScale ()
		local w, h = display.contentWidth, display.contentHeight
		local realw, realh = display.viewableContentWidth, display.viewableContentHeight-subtitleFrame.contentHeight*0.75
		
		local ratioM = (w/h)/(realw/realh)
		if ratioM>1 then ratioM = 1/ratioM end
		local ratioM2 = ratioM^2
		local daScale = (0.65+ratioM2^4*0.1)^2
	end
	getDaScale()
	
	--====================================================================--
	-- SET UP A LOCAL GROUP THAT WILL BE RETURNED
	--====================================================================--
	local localGroup = display.newGroup()
	
	-- LOWER LAYER, THE BACKGROUND COLOR
	local backgroundColor = display.newRect(0,0,width,height)
	backgroundColor:setFillColor(255,255,235)
	localGroup:insert(backgroundColor)
	
	local startAdventure
	local startMaryGreetingAnimation
	local startMaryWalkingAnimation
	local startWaitingGirlsAnimation
	local startMaryGigglingAnimation
	local startAnimalsChasingAnimation
	local startTransition
	
	local maryStopsGreetingAndStartsTalking
	local stopGirlsWaitingAndStartMaryGiggling
	
	local pauseIt
	local continueIt
	
	local function killAll()
		pauseIt=nil
		continueIt=nil
		paused=nil
	end
	
	local function newSheep (xMin, xMax, scale)
			local thisAnimal = {}
			
			local isDragging = false
			
			local movementDirection = 1
			
			local loops = 0
			local lastFrame = 0
			
			local minX = xMin
			local maxX = xMax
			
			local animalTimer
			
			thisAnimal.isAlive = true
			
			if not yPos then
				yPos = 0
			end
			
			if not scale then
				scale = 1
			end
			
			local openEyesR = display.newImage("assets/sheep/EyesOpen.png")
			local closedEyesR = display.newImage("assets/sheep/EyesClosed.png")
			
			thisAnimal.displayObject = display.newGroup()
			thisAnimal.displayObject.x = math.random(minX,maxX)
			
			thisAnimal.runningAnimal = ui.newAnimation{
					comps = {
						{
							--delanteraDerecha
							path = "assets/sheep/delanterader.png",
							x = { 293.5,293.5,293.5,293.55,293.5,293.5,293.5,293.55 },
							y = { 445.65,440.15,434.65,429.15,434.65,440.15,445.65,451.15 },
							rotation = { 0,0,0,0,0,0,0,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--traceraDerecha
							path = "assets/sheep/tracerader.png",
							x = { 459.65,459.65,459.65,459.65,459.65,459.65,459.65,459.65 },
							y = { 369.15,363.65,358.15,352.65,358.15,363.65,369.15,374.65 },
							rotation = { 0,0,0,0,0,0,0,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--delanteraIzquierda
							path = "assets/sheep/delanteraizq.png",
							x = { 377.05,377.05,377.05,377.1,377.05,377.05,377.05,377.1 },
							y = { 469.2,463.7,458.2,452.7,458.2,463.7,469.2,474.7 },
							rotation = { 0,0,0,0,0,0,0,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--traceraIzquierda
							path = "assets/sheep/traceraizq.png",
							x = { 532.4,532.4,532.4,532.4,532.4,532.4,532.4,532.4 },
							y = { 373.9,368.4,362.9,357.4,362.9,368.4,373.9,379.4 },
							rotation = { 0,0,0,0,0,0,0,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--body
							path = "assets/sheep/body.png",
							x = { 384.2,384.2,384.2,384.2,384.2,384.2,384.2,384.2 },
							y = { 265.3,258.3,251.35,244.35,251.35,258.3,265.3,272.35 },
							rotation = { 0,0,0,0,0,0,0,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--head
							path = "assets/sheep/head.png",
							x = { 241.45,241.5,241.5,241.6,241.5,241.5,241.45,241.45 },
							y = { 329.45,324.3,319.35,314.3,319.35,324.3,329.45,334.45 },
							rotation = { -0.3260955810546875,-0.653045654296875,-0.979949951171875,-1.306793212890625,-0.979949951171875,-0.653045654296875,-0.3260955810546875,-0.0008697509765625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							displayObject = closedEyesR,
							scaleComponent = true,
							x = { 241.45,241.5,241.5,241.6,241.5,241.5,241.45,241.45 },
							y = { 329.45,324.3,319.35,314.3,319.35,324.3,329.45,334.45 },
							rotation = { -0.3260955810546875,-0.653045654296875,-0.979949951171875,-1.306793212890625,-0.979949951171875,-0.653045654296875,-0.3260955810546875,-0.0008697509765625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							displayObject = openEyesR,
							scaleComponent = true,
							x = { 241.45,241.5,241.5,241.6,241.5,241.5,241.45,241.45 },
							y = { 329.45,324.3,319.35,314.3,319.35,324.3,329.45,334.45 },
							rotation = { -0.3260955810546875,-0.653045654296875,-0.979949951171875,-1.306793212890625,-0.979949951171875,-0.653045654296875,-0.3260955810546875,-0.0008697509765625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},
					},
					x = -380*scale,
					scale = scale*0.75 * 1.666,
					speed = 0.5
				}
			
			thisAnimal.runningAnimal.hide()
			
			local RBlinks = ui.blink(openEyesR,closedEyesR)
			
			localGroup:insert(thisAnimal.displayObject)
			thisAnimal.addRunningAnimalLayer = function()
				if thisAnimal.runningAnimal.displayObject then
					thisAnimal.displayObject:insert(thisAnimal.runningAnimal.displayObject)
					thisAnimal.displayObject:setReferencePoint(display.TopCenterReferencePoint)
				end
			end
			
			local move
			local defineAnimation
			
			move = function()
				if not thisAnimal.displayObject then
					Runtime:removeEventListener( "enterFrame", move )
					return
				end
				if thisAnimal.runningAnimal.isMoving then
					if not isDragging then
						local thisFrame = thisAnimal.runningAnimal.getActualFrame()
						if (thisFrame < lastFrame) then
							loops = loops + 1
							if loops > 3 then
								loops = 0
								thisAnimal.runningAnimal.stop()
								Runtime:removeEventListener( "enterFrame", move )
							end
						end
						lastFrame = thisFrame
						
						local movementSpeed = -1*scale
						movementSpeed = movementSpeed * thisAnimal.displayObject.xScale
						thisAnimal.displayObject.x = thisAnimal.displayObject.x + movementSpeed
					end
				else
					Runtime:removeEventListener( "enterFrame", move )
				end
			end
			
			defineAnimation = function()
				if not thisAnimal then return end
				if not thisAnimal.displayObject then return end
				if not thisAnimal.displayObject.x then return end
				if thisAnimal.displayObject.x < xMax + 125 then
					if thisAnimal.displayObject.x > xMax then
						thisAnimal.displayObject.x = xMax
					end
				end
				if not thisAnimal.displayObject then
					return
				end
				if not isDragging then
					local direction = 1
					local thisX = thisAnimal.displayObject.x + direction*100*scale
					if thisX<minX or thisX>maxX then
						direction = direction*-1
					end
					if thisAnimal.displayObject.x<minX then
						direction = 1
					end
					if thisAnimal.displayObject.x>maxX then
						direction = -1
					end
					
					thisAnimal.displayObject.xScale = -direction
					thisAnimal.displayObject.yScale = 1
					if (math.random(4) > 1 and (not thisAnimal.runningAnimal.isMoving)) then
						if math.random(20) > 10 then
							direction = -1
						end
						if thisAnimal.displayObject.x > width-50*thisAnimal.displayObject.xScale then
							thisAnimal.displayObject.x = math.random(minX,maxX)
							thisAnimal.runningAnimal.appear(500)
							defineAnimation()
							return
						end
						thisAnimal.runningAnimal.start()
						Runtime:addEventListener("enterFrame",move)
					end
					
					animalTimer = timer.performWithDelay(2000, defineAnimation)
				end
			end
			
			thisAnimal.startRunning = function()
				defineAnimation()
				
				thisAnimal.runningAnimal.stop()
				
				thisAnimal.runningAnimal.stop()
				thisAnimal.runningAnimal.appear()
				
				if RBlinks then
					RBlinks.openEyes()
					RBlinks.startBlinking()
				end
				
				thisAnimal.isRunning = true
			end
			
			thisAnimal.kill = function()
				Runtime:removeEventListener( "enterFrame", move )
				
				timer.cancel(animalTimer)
				
				if thisAnimal.runningAnimal then
					thisAnimal.runningAnimal.kill()
				end
				
				if thisAnimal.displayObject then
					if thisAnimal.displayObject.parent then
						thisAnimal.displayObject.parent: remove(thisAnimal.displayObject)
					end
				end
				
				thisAnimal.isAlive = false
			end
			
			thisAnimal.vanish = function(time)
				thisAnimal.runningAnimal.vanish(time)
			end
			
			thisAnimal.appear = function(time)
				thisAnimal.runningAnimal.appear(time)
			end
			
			return thisAnimal
		end
	
	--======================================
	-- START ADVENTURE
	--======================================
	local function prepareWelcomeScreen()
		local loadingBackground = display.newImageRect("assets/world/silverGardenSky.jpg",width,height)
		loadingBackground:setReferencePoint(display.TopLeftReferencePoint)
		loadingBackground.x = 0
		loadingBackground.y = 0
		localGroup:insert(loadingBackground)
		
		local titleLabel = display.newText( "Mary gets her wings!", 0, 0, mainFont1, 36 )
		titleLabel:setTextColor(67,34,15,255)
		titleLabel.y = 85
		titleLabel.x = width/2
		localGroup:insert(titleLabel)
		
		titleLabel.alpha=0
		transition.to(titleLabel,{alpha=1,time=1500})
		
		local function continue()
			localGroup:remove(loadingBackground)
			localGroup:remove(titleLabel)
		end
		
		--local myTimer
		local result
		local function vanish()
			pauseIt=nil
			continueIt=nil
			startMaryGreetingAnimation()
			timer.performWithDelay(300, continue)
		end
		
		startAdventure = function()
			soundController.playNew{
						path = "assets/sound/voices/cap1/adv1_N1.mp3",
						actionTimes = {0,3500,6000},
						action =	function()
										nextSubtitle()
									end,
						onComplete = function()
										if type(maryStopsGreetingAndStartsTalking) == "function" then
											maryStopsGreetingAndStartsTalking()
										end
										nextSubtitle()
									end
						}
			local vt = timer.performWithDelay(3500, vanish)
			
			pauseIt = function ()
				timer.pause(vt)
			end
			
			continueIt = function()
				timer.resume(vt)
			end
			
			pauseIt()
			continueIt()
		end
	end
	prepareWelcomeScreen()
	
	--======================================
	-- MARY GREETING ANIMATION
	--======================================
	local function prepareMaryGreetingAnimation()
		local background = display.newImageRect("assets/world/closeup.jpg",width,height)
		background:setReferencePoint(display.TopLeftReferencePoint)
		background.x = 0
		background.y = 0
		localGroup:insert(background)
		
		local sheep1 = newSheep (170, 340, 0.25)
		sheep1.displayObject.x = sheep1.displayObject.x-100
		sheep1.displayObject.y = 90
		sheep1.addRunningAnimalLayer()
		
		local magnifier = display.newImageRect("assets/Nuevalupa.png",150.5,131)
		magnifier:setReferencePoint(display.CenterLeftReferencePoint)
		magnifier.alpha = 0
		magnifier.xScale,magnifier.yScale = 0.05,0.05
		
		local maryHead = display.newGroup()
		maryHead:insert(display.newImage("assets/mary/greetingAnimation/Head.png"))
		maryHead:insert(display.newImage("assets/mary/greetingAnimation/lipsync/AI.png"))
		maryHead:insert(display.newImage("assets/mary/greetingAnimation/lipsync/EN.png"))
		maryHead:insert(display.newImage("assets/mary/greetingAnimation/lipsync/FV.png"))
		maryHead:insert(display.newImage("assets/mary/greetingAnimation/lipsync/LDTH.png"))
		maryHead:insert(display.newImage("assets/mary/greetingAnimation/lipsync/MPB.png"))
		maryHead:insert(display.newImage("assets/mary/greetingAnimation/lipsync/O.png"))
		maryHead:insert(display.newImage("assets/mary/greetingAnimation/lipsync/UWQ.png"))
		maryHead:setReferencePoint(display.CenterReferencePoint)
		
		local function showMaryFaceIndex(faceIndex)
			if not maryHead then
				return
			end
			if not faceIndex then
				return
			end
			if not type(faceIndex) == "number" then
				return
			end
			for i=2, maryHead.numChildren do
				if maryHead[i] then
					if i==faceIndex then
						maryHead[i].isVisible = true
					else
						maryHead[i].isVisible = false
					end
				end
			end
		end
		showMaryFaceIndex(1)
		
		local maryOpenEyes = display.newImage("assets/mary/greetingAnimation/eyesOpen.png")
		local maryClosedEyes = display.newImage("assets/mary/greetingAnimation/eyesClosed.png")
		
		local maryBlinks = ui.blink(maryOpenEyes,maryClosedEyes)
		
		local maryWings = display.newImage("assets/budsDeFrente.png")
		maryWings.x,maryWings.y,maryWings.xScale,maryWings.yScale = 525.75/2.5 +147 ,776.30/2.5 -65 ,1/7 ,1/7
		
		local maryBodyAndNeck = display.newImage("assets/mary/greetingAnimation/Body.png")
		maryBodyAndNeck.x,maryBodyAndNeck.y,maryBodyAndNeck.xScale,maryBodyAndNeck.yScale = 525.75/2.5 +150 ,776.30/2.5 -6 ,1/2.5 ,1/2.5
		
		local maryBody = display.newImage("assets/mary/greetingAnimation/Body_noNeck.png")
		maryBody.x,maryBody.y,maryBody.xScale,maryBody.yScale = 525.75/2.5 +150 ,776.30/2.5 -6 ,1/2.5 ,1/2.5
		
		local maryIsTalking = false
		local function animateMag()
			if not maryIsTalking then
				if magnifier.xScale<=1 then
					magnifier.xScale = magnifier.xScale + 0.005
					magnifier.yScale = magnifier.xScale
				end
				if magnifier.alpha<=1 then
					local newAlpha = magnifier.alpha + 0.01
					if newAlpha>1 then newAlpha = 1 elseif newAlpha<0 then newAlpha = 0 end
					magnifier.alpha = newAlpha
				end
			else
				if magnifier.xScale>0.015 then
					magnifier.xScale = magnifier.xScale - 0.005
					magnifier.yScale = magnifier.xScale
				end
				if magnifier.alpha>=0 then
					local newAlpha = magnifier.alpha - 0.01
					if newAlpha>1 then newAlpha = 1 elseif newAlpha<0 then newAlpha = 0 end
					magnifier.alpha = newAlpha
				end
			end
		end
		
		local maryAnimation = ui.newAnimation{
						 comps = {
						 {
						  displayObject = maryHead,
						  x = { 491.25,492.7,494.15,495.45,496.9,498.3,499.7,501.15,502.6,501.3,500.05,498.7,497.45,496.2,494.95,493.7,492.35,491.15,489.9 },
						  y = { 455.3,455.2,455.05,454.95,454.8,454.75,454.65,454.65,454.55,454.65,454.7,454.75,454.75,454.9,454.95,455.05,455.2,455.4,455.55 },
						  rotation = { 0.6023406982421875,1.204559326171875,1.808258056640625,2.4115447998046875,3.0142974853515625,3.6172637939453125,4.21942138671875,4.8223876953125,5.4251556396484375,4.883148193359375,4.34027099609375,3.7974853515625,3.2548828125,2.712554931640625,2.1697540283203125,1.62744140625,1.0848388671875,0.542022705078125,0 },
						  scaleComponent = true,
						 },
						 {
						  displayObject = maryOpenEyes,
						  x = { 491.25,492.7,494.15,495.45,496.9,498.3,499.7,501.15,502.6,501.3,500.05,498.7,497.45,496.2,494.95,493.7,492.35,491.15,489.9 },
						  y = { 455.3,455.2,455.05,454.95,454.8,454.75,454.65,454.65,454.55,454.65,454.7,454.75,454.75,454.9,454.95,455.05,455.2,455.4,455.55 },
						  rotation = { 0.6023406982421875,1.204559326171875,1.808258056640625,2.4115447998046875,3.0142974853515625,3.6172637939453125,4.21942138671875,4.8223876953125,5.4251556396484375,4.883148193359375,4.34027099609375,3.7974853515625,3.2548828125,2.712554931640625,2.1697540283203125,1.62744140625,1.0848388671875,0.542022705078125,0 },
						  scaleComponent = true,
						 },
						 {
						  displayObject = maryClosedEyes,
						  x = { 491.25,492.7,494.15,495.45,496.9,498.3,499.7,501.15,502.6,501.3,500.05,498.7,497.45,496.2,494.95,493.7,492.35,491.15,489.9 },
						  y = { 455.3,455.2,455.05,454.95,454.8,454.75,454.65,454.65,454.55,454.65,454.7,454.75,454.75,454.9,454.95,455.05,455.2,455.4,455.55 },
						  rotation = { 0.6023406982421875,1.204559326171875,1.808258056640625,2.4115447998046875,3.0142974853515625,3.6172637939453125,4.21942138671875,4.8223876953125,5.4251556396484375,4.883148193359375,4.34027099609375,3.7974853515625,3.2548828125,2.712554931640625,2.1697540283203125,1.62744140625,1.0848388671875,0.542022705078125,0 },
						  scaleComponent = true,
						 },
						 {
						  path = "assets/mary/greetingAnimation/LeftArm.png",
						  x = { 583.65,583.4,583.1,582.75,582.4,582.15,581.8,581.4,581.1,581.4,581.7,582,582.35,582.6,582.85,583.2,583.4,583.7,584 },
						  y = { 656.15,656.55,656.95,657.3,657.7,658.1,658.4,658.85,659.15,658.8,658.55,658.2,657.85,657.5,657.15,656.85,656.5,656.1,655.8 },
						  rotation = { 0.5761260986328125,1.1512451171875,1.7278900146484375,2.30419921875,2.8800201416015625,3.456146240234375,4.033294677734375,4.6087646484375,5.1859130859375,4.666961669921875,4.1481170654296875,3.62945556640625,3.110198974609375,2.5921783447265625,2.07373046875,1.5558013916015625,1.0367584228515625,0.5184173583984375,0 },
						  yOffset = 30,
						  xOffset = 15
						 },
						 {
						  path = "assets/mary/greetingAnimation/RightForearm.png",
						  x = { 379.55,380.55,381.6,382.9,384.15,385.65,387.25,388.85,390.65,389.05,387.55,386.1,384.75,383.5,382.35,381.3,380.35,379.45,378.75 },
						  y = { 626.15,623.6,621.05,618.55,616.1,613.8,611.6,609.45,607.5,609.3,611.15,613.15,615.25,617.4,619.6,621.75,624.1,626.45,628.85 },
						  rotation = { 3.8175048828125,7.6357574462890625,11.453445434570313,15.27020263671875,19.087600708007813,22.905563354492188,26.723602294921875,30.54046630859375,34.358062744140625,30.9222412109375,27.487701416015625,24.051406860351563,20.615036010742188,17.180221557617188,13.742935180664063,10.307693481445313,6.871795654296875,3.4352264404296875,0 },
						  yOffset = 34,
						  xOffset = 4
						 },
						 {
						  path = "assets/mary/greetingAnimation/RightArm.png",
						  x = { 442.15,442.15,442.15,442.2,442.2,442.25,442.3,442.3,442.4,442.35,442.3,442.25,442.2,442.2,442.15,442.15,442.15,442.15,442.15 },
						  y = { 632.3,631.85,631.35,630.9,630.45,629.95,629.5,629.05,628.6,629,629.4,629.85,630.25,630.65,631.1,631.5,631.95,632.35,632.8 },
						  rotation = { 0.731719970703125,1.464080810546875,2.195953369140625,2.9271087646484375,3.6599273681640625,4.3915557861328125,5.12347412109375,5.8554534912109375,6.5881195068359375,5.9281158447265625,5.27001953125,4.6113739013671875,3.952392578125,3.293212890625,2.634918212890625,1.975921630859375,1.31640625,0.658294677734375,0 },
						  yOffset = 32,
						  xOffset = 4
						 },
						 {
						  path = "assets/mary/greetingAnimation/LeftHand.png",
						  x = { 651.7,651.35,651,650.7,650.3,649.95,649.65,649.25,648.85,649.2,649.5,649.85,650.15,650.5,650.8,651.15,651.4,651.75,652 },
						  y = { 783.1,783.9,784.7,785.4,786.15,786.95,787.7,788.45,789.15,788.5,787.8,787.2,786.5,785.8,785.15,784.4,783.75,783.05,782.3 },
						  rotation = { -0.3059844970703125,-0.611968994140625,-0.9178924560546875,-1.223785400390625,-1.531341552734375,-1.837066650390625,-2.1435699462890625,-2.4499359130859375,-2.7561798095703125,-2.4804840087890625,-2.204681396484375,-1.92877197265625,-1.653656005859375,-1.378448486328125,-1.1014404296875,-0.8261260986328125,-0.5507659912109375,-0.275390625,0 },
						  yOffset = 30,
						  xOffset = 15
						 },
						 {
						  path = "assets/mary/greetingAnimation/RightHand.png",
						  x = { 333.7,338,342.7,347.95,353.55,359.6,365.9,372.45,379.2,373.1,367.2,361.4,355.95,350.75,345.85,341.25,337.1,333.3,330 },
						  y = { 592.7,586.15,579.95,574.15,568.9,564.25,560.05,556.5,553.45,556.1,559.3,562.95,567,571.55,576.45,581.75,587.4,593.4,599.7 },
						  rotation = { 6.4828338623046875,12.967483520507813,19.451416015625,25.934951782226563,32.41908264160156,38.903656005859375,45.3875732421875,51.87184143066406,58.35560607910156,52.51963806152344,46.68363952636719,40.84889221191406,35.01301574707031,29.178131103515625,23.341827392578125,17.506027221679688,11.6707763671875,5.8347015380859375,0 },
						  yOffset = 32,
						  xOffset = 6
						 }
						},
						 x = 150,
						 y = -15,
						 scale = 1/2.5,
						 speed = 0.5,
						 animateAction = animateMag;
						}
		
		background.isVisible = false
		maryWings.isVisible = false
		maryBody.isVisible = false
		maryBodyAndNeck.isVisible = false
		maryAnimation.hide()
		
		local maryGroup = display.newGroup()
		maryGroup:insert(maryWings)
		maryGroup:insert(maryBodyAndNeck)
		maryGroup:insert(maryBody)
		maryGroup:insert(maryAnimation.displayObject)
		
		localGroup:insert(maryGroup)
		
		maryGroup:setReferencePoint(display.CenterReferencePoint)
		maryGroup.x = maryGroup.x-105
		maryGroup.y = maryGroup.y-subtitleGroup.contentHeight*0.5
		maryGroup.xScale,maryGroup.yScale=daScale*0.9,daScale*0.9
		
		localGroup:insert(magnifier)
		magnifier.x = maryGroup.x+50
		magnifier.y = maryGroup.y-50
		
		local function continue ()
			startMaryWalkingAnimation()
		end
		
		local function kill()
			if maryWings then localGroup:remove(maryWings) end
			if maryBody then localGroup:remove(maryBody) end
			if maryBodyAndNeck then localGroup:remove(maryBodyAndNeck) end
			
			localGroup:remove(background)
			
			maryBlinks.stopBlinking()
			
			sheep1.kill()
			maryAnimation.kill()
		end
		
		local function vanish()
			pauseIt = nil
			continueIt = nil
			
			transition.to(maryWings,{alpha=0,time=300})
			transition.to(maryBody,{alpha=0,time=300})
			transition.to(maryBodyAndNeck,{alpha=0,time=300})
			
			maryAnimation.vanish(300)
			
			timer.performWithDelay(500,continue)
			timer.performWithDelay(1500,kill)
		end
		
		startMaryGreetingAnimation = function ()
			sheep1.startRunning()
			
			maryAnimation.start()
			maryAnimation.appear(300)
			
			maryBlinks.openEyes()
			maryBlinks.startBlinking()
			
			background.isVisible = true
			maryWings.isVisible = true
			maryBody.isVisible = true
			maryBodyAndNeck.isVisible = true
			
			background.alpha = 0
			maryWings.alpha = 0
			maryBody.alpha = 0
			maryBodyAndNeck.alpha = 0
			
			transition.to(background,{alpha=1,time=300})
			transition.to(maryWings,{alpha=1,time=300})
			transition.to(maryBody,{alpha=1,time=300})
			transition.to(maryBodyAndNeck,{alpha=1,time=300})
			
			subtitleGroup.alpha=0
			subtitleGroup.isVisible=true
			transition.to(subtitleGroup,{alpha=1,time=300})
			
			maryStopsGreetingAndStartsTalking = function()
				maryIsTalking = true
				--1 - normal
				--2 - AI
				--3 - EN
				--4 - FV
				--5 - LDTH
				--6 - MPB
				--7 - O
				--8 - UWQ
				local indarr = {2, --I
								3,5, --CAN'T
								8,2,5, --WAIT
								5,8, --TO
								7, --TURN
								4,2, --FIVE
								3, --IT
								8,3, --WILL
								6,3, --BE
								3,1,3, --EASIER
								5,8,5,8, --TO DO
								6,2, --MY
								8,5, --DUTIES
								8,3, --WHEN
								2,3, --I GET
								6,2, --MY
								5,3 --WINGS
								}
				soundController.playNew{
						path = "assets/sound/voices/cap1/adv1_MLipsync.mp3",
						actionTimes = {	625, --I
										300,785, --CAN'T
										1615,1950,2085, --WAIT
										600,1637, --TO
										2550, --TURN
										2880,3300, --FIVE
										3780, --IT
										2000,2000, --WILL
										2000,2220, --BE
										4500,1000,3800, --EASIER
										1000,5120,1330,4330, --TO DO
										1000,4550, --MY
										5790,6140, --DUTIES
										1000,5440, --WHEN
										6580,6850, --I GET
										7000,7360, --MY
										3000,4600 --WINGS
										},
						action =	function()
										if indarr then
											if indarr[1] then
												showMaryFaceIndex(indarr[1])
												table.remove(indarr,1)
											end
										end
										
									end,
						onComplete = function()
										vanish()
										nextSubtitle()
									end
						}
			end
			--local vt = timer.performWithDelay(4000,vanish)
			
			pauseIt = function ()
				maryAnimation.stop()
				maryBlinks.stopBlinking()
				--timer.pause(vt)
			end
			
			continueIt = function()
				maryAnimation.start()
				maryBlinks.startBlinking()
				--timer.resume(vt)
			end
			
			pauseIt()
			continueIt()
		end
	end
	prepareMaryGreetingAnimation()
	
	--====================================================================--
	-- MARY WALKING ANIMATION
	--====================================================================--
	local function prepareMaryWalkingAnimation()
		local background = display.newImageRect("assets/world/nicePlaceToWalk.jpg",width,height)
		background:setReferencePoint(display.TopLeftReferencePoint)
		background.x = 0
		background.y = 0
		background.isVisible=false
		localGroup:insert(background)
		
		local sheep1 = newSheep (220, 340, 0.08)
		local sheep2 = newSheep (140, 270, 0.14)
		
		local maryOpenEyes = display.newImage("assets/mary/walking/EyeOpen.png")
		local maryClosedEyes = display.newImage("assets/mary/walking/EyeClosed.png")
		
		local maryBlinks = ui.blink(maryOpenEyes,maryClosedEyes)
		
		local maryWalkingAnimation = ui.newAnimation{
						 comps = {
						 {
						 path = "assets/mary/walking/arm.png",
						 x = { 226.8,229.65,232.75,235.8,238.9,241.95,245.1,246.65,248.15,249.5,250.55,251.3,251.7,251.75,251.9,251.65,251.1,250.3,248.95,247.55,246.05,244.25,241.7,239.1,236.55,233.95,230.5,227.2},--,223.95 },
						 y = { 297.8,296.35,294.65,293.45,292,290.45,288.6,289.35,289.7,289.85,289.55,289.1,288.35,287.45,287.95,288.2,288.35,288.35,288.9,289.05,288.95,288.4,290.25,291.95,293.45,294.9,296.5,297.9,299.1 },
						 rotation = { 81.77249145507813,75.08349609375,68.39512634277344,61.86460876464844,55.33384704589844,48.802764892578125,42.27076721191406,33.79426574707031,25.3201904296875,16.84527587890625,8.368759155273438,-0.1049041748046875,-8.580001831054688,-17.0556640625,-8.989013671875,-0.9231414794921875,7.1413726806640625,15.208358764648438,23.622772216796875,32.03620910644531,40.4508056640625,48.86470031738281,53.8160400390625,58.76481628417969,63.71258544921875,68.66238403320313,75.2615966796875,81.8607177734375,88.45991516113281 },
						 },
						 {
						 path = "assets/mary/walking/forearm.png",
						 x = { 199.3,204.55,210.25,217.65,226.45,236.35,246.6,252.95,258.95,264.55,269.6,274,277.55,280.25,276.55,272,266.7,260.85,256.85,252.25,247.35,242.3,234.7,227.4,220.45,213.95,206.3,199.85,194.8 },
						 y = { 317.8,319.75,321.3,325.1,327.7,328.45,327.35,327.5,326.75,325,322.35,318.95,315,310.45,314.8,318.3,320.95,322.6,325.2,327.05,327.8,327.65,328.55,328.6,327.75,326.2,323.3,319.65,315.4 },
						 rotation = { 108.75041198730469,100.45065307617188,92.15055847167969,72.35731506347656,52.56205749511719,32.76414489746094,12.969131469726563,9.540847778320313,6.1122894287109375,2.6846466064453125,-0.7422027587890625,-4.16986083984375,-7.59625244140625,-11.027877807617188,-1.456207275390625,8.112716674804688,17.6839599609375,27.254669189453125,24.778457641601563,22.302780151367188,19.826766967773438,17.350845336914063,29.814620971679688,42.27650451660156,54.738494873046875,67.19985961914063,83.81597900390625,100.43289184570313,117.049072265625 },
						 },
						 {
						 path = "assets/mary/walking/hand.png",
						 x = { 169.75,175.1,181.55,192.7,208.45,227.3,247.95,256,263.8,271,277.8,283.85,289,293.25,284.9,275.5,265.25,254.45,251.7,248.5,244.85,241.05,227.05,213.7,201.4,190.45,178.55,170.3,165.8 },
						 y = { 315.85,322.2,328.05,341.3,351.5,357.2,357.6,357.55,356.4,354.25,351.2,347.2,342.45,337.2,343.25,347.75,350.55,351.6,354.5,356.5,357.45,357.3,357.35,355.05,350.75,344.55,334.05,322,309.15 },
						 rotation = { 108.744140625,100.44557189941406,92.14619445800781,72.35174560546875,52.55543518066406,32.76043701171875,12.963333129882813,9.536590576171875,6.1088409423828125,2.68115234375,-0.7457122802734375,-4.17333984375,-7.603118896484375,-11.0303955078125,-1.4597015380859375,8.108444213867188,17.67999267578125,27.250518798828125,24.773422241210938,22.29754638671875,19.82366943359375,17.34686279296875,29.808700561523438,42.27076721191406,54.73384094238281,67.19613647460938,83.81338500976563,100.42613220214844,117.04214477539063 },
						 },
						 {
						 path = "assets/mary/walking/knee.png",
						 x = { 283.15,276.4,269.4,261.55,253.8,246.15,238.75,233.5,228.1,222.65,217.2,216.1,215,214.55,216.7,218.9,221.2,223.55,227.4,231.35,235.35,239.4,245.9,252.45,258.95,265.3,273.75,281.75,289.45 },
						 y = { 418.65,417.8,415.8,414.65,412.6,409.45,405.3,407.05,408.25,409,409.25,415.45,419.4,421.05,420.45,419.65,418.75,417.6,418.05,418.15,417.95,417.65,419.6,421,421.85,422.1,421.8,420.7,418.55 },
						 rotation = { -45.85736083984375,-50.5911865234375,-55.323211669921875,-55.56513977050781,-55.807891845703125,-56.04963684082031,-56.29216003417969,-48.73600769042969,-41.18040466308594,-33.6236572265625,-26.06561279296875,-7.7387847900390625,10.5909423828125,28.918228149414063,23.240036010742188,17.557693481445313,11.87689208984375,6.1961212158203125,5.5126495361328125,4.82672119140625,4.1411590576171875,3.456146240234375,-2.1165008544921875,-7.687286376953125,-13.258544921875,-18.830337524414063,-26.261398315429688,-33.692718505859375,-41.12339782714844 },
						 },
						 {
						 path = "assets/mary/walking/hip.png",
						 x = { 251.95,248.15,244.3,240.85,237.55,234.4,231.4,230,228.6,227.3,226.05,227.7,229.55,231.45,231.65,231.8,231.95,232.1,233.65,235.25,236.85,238.5,240.65,242.8,244.95,247.05,250.05,252.85,255.75 },
						 y = { 374.4,372.55,370.2,368.1,365.65,362.7,359.4,359.85,360.1,360.3,360.35,363.8,367.05,370.2,368.6,367.05,365.45,363.85,363.95,363.85,363.75,363.5,365.6,367.55,369.3,370.95,372.85,374.5,375.85 },
						 rotation = { -18.970413208007813,-11.87103271484375,-4.7694244384765625,2.3286285400390625,9.429428100585938,16.53082275390625,23.633041381835938,27.4443359375,31.254989624023438,35.06694030761719,38.88087463378906,33.92327880859375,28.96441650390625,24.008377075195313,23.386764526367188,22.76446533203125,22.1424560546875,21.521697998046875,18.107528686523438,14.690963745117188,11.274459838867188,7.8597869873046875,3.6207427978515625,-0.6224517822265625,-4.8614501953125,-9.1041259765625,-14.760467529296875,-20.417953491210938,-26.07196044921875 },
						 },
						 {
						 path = "assets/mary/walking/foot.png",
						 x = { 306.3,303.15,299.4,290.75,282.05,273.45,265.05,256,246.55,236.7,226.6,214,201.9,191.75,196.75,201.9,207.45,213.1,217.45,221.9,226.4,230.95,240.95,251,261.1,271.05,284.2,296.85,308.9 },
						 y = { 447.65,444.35,439.4,438.75,437,434.1,430.3,435.15,439,441.85,443.5,450.75,452.2,447.85,449.5,450.7,451.4,451.55,452.05,452.4,452.55,452.45,455.05,456.8,457.75,457.8,456.5,453.7,449.45 },
						 rotation = { -61.216583251953125,-72.74079895019531,-84.26136779785156,-78.12226867675781,-71.98176574707031,-65.84368896484375,-59.70137023925781,-51.407958984375,-43.1162109375,-34.82257080078125,-26.530776977539063,-7.46478271484375,11.598648071289063,30.663528442382813,24.296630859375,17.925689697265625,11.559219360351563,5.19024658203125,3.988067626953125,2.78582763671875,1.5846405029296875,0.3837890625,-5.876220703125,-12.135345458984375,-18.3961181640625,-24.65582275390625,-33.00459289550781,-41.34934997558594,-49.697357177734375 },
						 },
						 {
						 path = "assets/mary/walking/knee.png",
						 x = { 215.45,217.45,219.45,225.1,230.9,236.75,242.7,249.45,256.2,262.85,269.4,275.8,281.9,287.85,280.95,273.7,266.35,258.8,253.3,247.65,242.1,236.75,232.85,228.95,225.05,221.05,218.4,215.75,213.5 },
						 y = { 418.15,416.85,415.25,415.95,416.2,416,415.25,416.85,417.85,418.2,418,417.4,416.2,414.6,415.7,416.05,415.4,413.8,412.75,410.9,408.55,405.8,406.95,407.85,408.55,408.8,414.05,417.55,419.2 },
						 rotation = { 17.393844604492188,11.060714721679688,4.7268829345703125,2.6445159912109375,0.5603790283203125,-1.521728515625,-3.605072021484375,-9.208938598632813,-14.8135986328125,-20.4156494140625,-26.021148681640625,-31.622848510742188,-37.22735595703125,-42.83161926269531,-43.86944580078125,-44.90458679199219,-45.93986511230469,-46.97758483886719,-46.798187255859375,-46.62030029296875,-46.44206237792969,-46.26307678222656,-41.77375793457031,-37.28385925292969,-32.793182373046875,-28.306442260742188,-10.961318969726563,6.3826904296875,23.726165771484375 },
						 },
						 {
						 path = "assets/mary/walking/hip.png",
						 x = { 239.3,239.2,239.05,241.3,243.55,245.85,248.15,250.3,252.35,254.4,256.4,258.4,260.35,262.15,259.15,256,252.75,249.4,247.05,244.65,242.25,239.95,238.85,237.75,236.6,235.4,236.65,238.1,239.35 },
						 y = { 370.6,368.7,366.65,365.95,364.9,363.75,362.4,363.75,365,366,366.85,367.6,368.25,368.65,368.6,368.15,367.3,366.05,365.15,364.1,362.75,361.3,362.3,363.25,364.2,365,367.6,370.2,372.65 },
						 rotation = { 40.010528564453125,39.74537658691406,39.48023986816406,34.46577453613281,29.451324462890625,24.437362670898438,19.422653198242188,14.744125366210938,10.065475463867188,5.3861541748046875,0.7107391357421875,-3.968048095703125,-8.64666748046875,-13.323959350585938,-6.026702880859375,1.2700958251953125,8.567184448242188,15.863265991210938,21.336090087890625,26.810714721679688,32.281829833984375,37.75297546386719,40.73262023925781,43.710906982421875,46.68780517578125,49.66685485839844,46.535430908203125,43.40647888183594,40.27415466308594 },
						 },
						 {
						 path = "assets/mary/walking/foot.png",
						 x = { 198.3,203.9,209.8,216.65,223.7,230.95,238.3,248.75,259.2,269.65,279.9,289.85,299.45,308.65,302.75,296.5,290.05,283.45,277.15,270.75,264.5,258.5,252.05,245.45,238.8,232.05,218.55,205.05,193.05 },
						 y = { 449.5,450,450,451.05,451.75,451.75,451.4,453.4,454.35,454.45,453.55,451.8,449.1,445.5,446.45,446.4,445.3,443.2,442.1,440.5,438.25,435.5,438.05,440.3,442,443.35,450.05,451.75,448.4 },
						 rotation = { 16.537246704101563,9.347732543945313,2.1592864990234375,-0.7798004150390625,-3.7173919677734375,-6.6562652587890625,-9.593551635742188,-16.053192138671875,-22.514251708984375,-28.973785400390625,-35.4324951171875,-41.894622802734375,-48.356353759765625,-54.81901550292969,-58.15077209472656,-61.48118591308594,-64.81568908691406,-68.14540100097656,-64.27470397949219,-60.402374267578125,-56.52876281738281,-52.65641784667969,-47.36604309082031,-42.076751708984375,-36.787506103515625,-31.498428344726563,-13.088638305664063,5.31768798828125,23.726165771484375 },
						 },
						 {
						 path = "assets/budsLaterales.png",
						 x = { 251.3,251.5,251.65,251.9,252.25,252.5,252.85,252.6,252.4,252.15,252,251.75,251.45,251.2,251.4,251.55,251.65,251.8,252.05,252.3,252.55,252.85,252.6,252.45,252.3,252.1,251.8,251.5,251.1 },
						 y = { 330.4,328.5,326.5,325.2,323.85,322.5,321.2,322.5,323.9,325.25,326.55,328,329.4,330.85,329.25,327.65,325.9,324.35,323.55,322.8,322,321.2,322.65,323.9,325.3,326.65,328.6,330.5,332.4 },
						 rotation = { -5.144287109375,-4.2950592041015625,-3.4456939697265625,-2.5956573486328125,-1.745361328125,-0.8960418701171875,-0.044586181640625,-0.895172119140625,-1.7444915771484375,-2.59478759765625,-3.4448089599609375,-4.294189453125,-5.144287109375,-5.995574951171875,-4.962982177734375,-3.9315032958984375,-2.899200439453125,-1.867645263671875,-1.094451904296875,-0.319976806640625,0.45111083984375,1.2246551513671875,0.3234710693359375,-0.576995849609375,-1.4806671142578125,-2.381866455078125,-3.585906982421875,-4.789398193359375,-5.994720458984375 },
						 scale = 0.5,
						 scaleCX = -1,
						 xOffset = 510,
						 yOffset = -60,
						 },
						 {
						 path = "assets/mary/walking/body.png",
						 x = { 251.3,251.5,251.65,251.9,252.25,252.5,252.85,252.6,252.4,252.15,252,251.75,251.45,251.2,251.4,251.55,251.65,251.8,252.05,252.3,252.55,252.85,252.6,252.45,252.3,252.1,251.8,251.5,251.1 },
						 y = { 330.4,328.5,326.5,325.2,323.85,322.5,321.2,322.5,323.9,325.25,326.55,328,329.4,330.85,329.25,327.65,325.9,324.35,323.55,322.8,322,321.2,322.65,323.9,325.3,326.65,328.6,330.5,332.4 },
						 rotation = { -5.144287109375,-4.2950592041015625,-3.4456939697265625,-2.5956573486328125,-1.745361328125,-0.8960418701171875,-0.044586181640625,-0.895172119140625,-1.7444915771484375,-2.59478759765625,-3.4448089599609375,-4.294189453125,-5.144287109375,-5.995574951171875,-4.962982177734375,-3.9315032958984375,-2.899200439453125,-1.867645263671875,-1.094451904296875,-0.319976806640625,0.45111083984375,1.2246551513671875,0.3234710693359375,-0.576995849609375,-1.4806671142578125,-2.381866455078125,-3.585906982421875,-4.789398193359375,-5.994720458984375 },
						 },
						 {
						 path = "assets/mary/walking/rpigtail.png",
						 x = { 288.05,293.8,299.3,302.95,306.45,310.05,313.55,311.75,309.95,308.05,306.2,299.9,293.6,287.1,291.4,295.55,299.75,303.8,307.65,311.55,315.4,319.15,316.45,313.65,310.9,308.05,299.65,291.05,282.3 },
						 y = { 146.6,147.2,147.95,147.95,148,148.05,148.25,148.5,148.75,148.95,149.05,147.65,146.5,145.55,145.85,146.2,146.5,146.85,147.5,148.3,149.1,150.05,149.7,149.25,148.85,148.4,147.3,146.5,146.2 },
						 rotation = { 8.313980102539063,12.017471313476563,15.720794677734375,17.076431274414063,18.430755615234375,19.786514282226563,21.14166259765625,18.587188720703125,16.03460693359375,13.481979370117188,10.9276123046875,8.456024169921875,5.98779296875,3.5153656005859375,7.045806884765625,10.57489013671875,14.10369873046875,17.633956909179688,19.054031372070313,20.473220825195313,21.892990112304688,23.311599731445313,20.063156127929688,16.814834594726563,13.565444946289063,10.317001342773438,8.415817260742188,6.5130462646484375,4.6113739013671875 },
						 },
						 {
						 path = "assets/mary/walking/head.png",
						 x = { 247.7,253.55,259.15,262.75,266.3,269.85,273.4,270.1,266.8,263.45,260.1,254.55,249.1,243.5,248.95,254.4,259.7,265.1,268.7,272.25,275.8,279.4,275.05,270.7,266.4,261.95,255.35,248.75,242 },
						 y = { 158.25,156.75,155.4,154.4,153.45,152.55,151.8,152.7,153.65,154.7,155.8,156.55,157.6,158.7,157.2,155.85,154.7,153.7,153.4,153.25,153.1,153.05,153.45,154,154.7,155.5,156.75,158.25,160.1 },
						 rotation = { 3.7513427734375,6.738189697265625,9.726104736328125,11.094406127929688,12.461685180664063,13.82952880859375,15.19451904296875,13.8641357421875,12.532516479492188,11.202117919921875,9.871261596679688,7.19818115234375,4.5271148681640625,1.8545379638671875,4.207244873046875,6.562225341796875,8.9139404296875,11.267730712890625,12.724807739257813,14.180145263671875,15.639755249023438,17.096405029296875,15.201034545898438,13.304931640625,11.408920288085938,9.512786865234375,6.59674072265625,3.6808319091796875,0.764068603515625 },
						 },
						 {
						 displayObject = maryClosedEyes,
						 scaleComponent = true,
						 x = { 247.7,253.55,259.15,262.75,266.3,269.85,273.4,270.1,266.8,263.45,260.1,254.55,249.1,243.5,248.95,254.4,259.7,265.1,268.7,272.25,275.8,279.4,275.05,270.7,266.4,261.95,255.35,248.75,242 },
						 y = { 158.25,156.75,155.4,154.4,153.45,152.55,151.8,152.7,153.65,154.7,155.8,156.55,157.6,158.7,157.2,155.85,154.7,153.7,153.4,153.25,153.1,153.05,153.45,154,154.7,155.5,156.75,158.25,160.1 },
						 rotation = { 3.7513427734375,6.738189697265625,9.726104736328125,11.094406127929688,12.461685180664063,13.82952880859375,15.19451904296875,13.8641357421875,12.532516479492188,11.202117919921875,9.871261596679688,7.19818115234375,4.5271148681640625,1.8545379638671875,4.207244873046875,6.562225341796875,8.9139404296875,11.267730712890625,12.724807739257813,14.180145263671875,15.639755249023438,17.096405029296875,15.201034545898438,13.304931640625,11.408920288085938,9.512786865234375,6.59674072265625,3.6808319091796875,0.764068603515625 },
						 },
						 {
						 displayObject = maryOpenEyes,
						 scaleComponent = true,
						 x = { 247.7,253.55,259.15,262.75,266.3,269.85,273.4,270.1,266.8,263.45,260.1,254.55,249.1,243.5,248.95,254.4,259.7,265.1,268.7,272.25,275.8,279.4,275.05,270.7,266.4,261.95,255.35,248.75,242 },
						 y = { 158.25,156.75,155.4,154.4,153.45,152.55,151.8,152.7,153.65,154.7,155.8,156.55,157.6,158.7,157.2,155.85,154.7,153.7,153.4,153.25,153.1,153.05,153.45,154,154.7,155.5,156.75,158.25,160.1 },
						 rotation = { 3.7513427734375,6.738189697265625,9.726104736328125,11.094406127929688,12.461685180664063,13.82952880859375,15.19451904296875,13.8641357421875,12.532516479492188,11.202117919921875,9.871261596679688,7.19818115234375,4.5271148681640625,1.8545379638671875,4.207244873046875,6.562225341796875,8.9139404296875,11.267730712890625,12.724807739257813,14.180145263671875,15.639755249023438,17.096405029296875,15.201034545898438,13.304931640625,11.408920288085938,9.512786865234375,6.59674072265625,3.6808319091796875,0.764068603515625 },
						 },
						 {
						 path = "assets/mary/walking/lpigtail.png",
						 x = { 314.4,319.5,324.4,327.9,331.4,334.85,338.25,336.65,335.1,333.4,331.85,325.85,319.7,313.4,317.75,321.9,326.05,330,333.5,336.9,340.3,343.6,341.3,339,336.6,334.1,325.95,317.65,309.05 },
						 y = { 147.55,149.45,151.4,151.9,152.45,153.1,153.75,153.55,153.25,152.9,152.45,150,147.65,145.7,147.05,148.45,149.9,151.35,152.7,154.15,155.55,157.1,155.9,154.65,153.3,151.9,149.45,147.4,145.85 },
						 rotation = { 8.223220825195313,12.153732299804688,16.085479736328125,17.468643188476563,18.850692749023438,20.233444213867188,21.614700317382813,18.985260009765625,16.353897094726563,13.722320556640625,11.093551635742188,8.547531127929688,5.9990386962890625,3.4526519775390625,6.9131622314453125,10.37115478515625,13.830352783203125,17.28948974609375,18.921127319335938,20.550674438476563,22.1844482421875,23.81475830078125,20.444061279296875,17.070831298828125,13.69921875,10.328842163085938,8.316543579101563,6.3049774169921875,4.2915802001953125 },
						 },
						 {
						 path = "assets/mary/walking/arm.png",
						 x = { 261.15,260.8,260.05,259.1,257.75,256.15,254.3,251.75,249.3,246.65,244.05,241.6,239.1,236.6,238.9,241.2,243.6,245.9,248.4,250.9,253.35,255.8,257.15,258.35,259.4,260.2,261.2,261.45,260.95 },
						 y = { 284.2,285.05,285.9,286.85,287.35,287.55,287.15,289,290.65,292.2,293.7,295.05,296.3,297.35,295.95,294.45,292.95,291.25,290.4,289.4,288.35,287.15,287.8,288.05,288.15,287.9,286.65,285,283 },
						 rotation = { -18.015869140625,-8.311416625976563,1.392425537109375,11.098602294921875,20.803207397460938,30.50543212890625,40.210479736328125,45.15510559082031,50.09941101074219,55.04154968261719,59.98504638671875,64.92890930175781,69.8720703125,74.81526184082031,70.95848083496094,67.10185241699219,63.2457275390625,59.38954162597656,54.91139221191406,50.4302978515625,45.95115661621094,41.47230529785156,33.61456298828125,25.760055541992188,17.902725219726563,10.045135498046875,-2.54156494140625,-15.1309814453125,-27.719757080078125 },
						 },
						 {
						 path = "assets/mary/walking/forearm.png",
						 x = { 291.4,287.1,281.75,275.7,268.9,261.5,253.7,247.75,241.85,235.95,230.15,224.4,218.95,213.6,217.9,222.35,227.1,231.9,237.3,242.95,248.65,254.35,260.85,267.05,272.75,278,285.45,291,294.4 },
						 y = { 307.65,312.85,317.1,321.1,323.8,325.2,325.3,326.9,328.15,328.95,329.3,329.2,328.8,327.9,328.4,328.7,328.8,328.7,329.25,329.4,329.15,328.65,328.7,327.85,326.15,323.6,317.7,310.3,301.75 },
						 rotation = { -13.937454223632813,-7.0897216796875,-0.2421722412109375,6.6036529541015625,13.45220947265625,20.298843383789063,27.146087646484375,32.99659729003906,38.849609375,44.70219421386719,50.55415344238281,56.40666198730469,62.259002685546875,68.11077880859375,63.549072265625,58.98970031738281,54.42901611328125,49.869659423828125,44.86158752441406,39.85426330566406,34.84730529785156,29.8409423828125,24.306793212890625,18.771575927734375,13.237838745117188,7.701873779296875,-1.7934112548828125,-11.289581298828125,-20.784866333007813 },
						 },
						 {
						 path = "assets/mary/walking/basket.png",
						 x = { 322.4,310.75,297.9,284.15,269.5,254.15,238.55,226.1,213.9,201.95,190.35,179.25,168.75,158.9,166.6,174.8,183.4,192.4,202.85,213.65,224.75,236.1,248.75,261.25,273.3,284.85,303.2,319.3,332.4 },
						 y = { 371,379.25,385.7,391.05,394.35,395.35,394.2,394.1,393,390.8,387.7,383.6,378.65,372.8,377.2,381.05,384.5,387.35,390.95,393.7,395.75,396.9,398.35,398.25,396.8,393.9,386,374.95,361.25 },
						 rotation = { -14.581298828125,-8.376449584960938,-2.1706390380859375,4.0350341796875,10.240829467773438,16.4464111328125,22.652877807617188,27.864120483398438,33.07708740234375,38.28631591796875,43.49909973144531,48.7108154296875,53.92268371582031,59.13313293457031,55.171539306640625,51.208770751953125,47.24700927734375,43.28486633300781,38.72584533691406,34.16697692871094,29.609512329101563,25.05029296875,20.11328125,15.17578125,10.23828125,5.3012237548828125,-3.3951568603515625,-12.091888427734375,-20.789459228515625 },
						 },
						},
						 x = 0,
						 y = 0,
						 scale = 0.5,
						 speed = 0.48
						}
		
		maryWalkingAnimation.displayObject:setReferencePoint(display.BottomLeftReferencePoint)
		maryWalkingAnimation.displayObject.y = screenOriginY + viewableContentHeight - subtitleGroup.contentHeight*0.8
		maryWalkingAnimation.displayObject.x = width
		maryWalkingAnimation.displayObject.xScale,maryWalkingAnimation.displayObject.yScale = daScale*0.9,daScale*0.9
		
		background.isVisible = false
		maryWalkingAnimation.hide()
		
		sheep1.displayObject.y = 70
		sheep1.addRunningAnimalLayer()
		
		sheep2.displayObject.y = 110
		sheep2.addRunningAnimalLayer()
		
		localGroup:insert(maryWalkingAnimation.displayObject)
		
		local vanishing = false
		local pauseState = paused
		
		local animateMaryWalking
		
		local function continue()
			Runtime:removeEventListener( "enterFrame", animateMaryWalking )
			localGroup:remove(background)
			
			sheep1.kill()
			sheep2.kill()
			
			maryBlinks.stopBlinking()
			maryWalkingAnimation.kill()
		end
		
		local function vanish()
			pauseIt=nil
			continueIt=nil
			vanishing = true
			
			soundController.kill("steps")
			startWaitingGirlsAnimation()
			timer.performWithDelay(1000, continue)
		end
		
		local speed = 1.5 * maryWalkingAnimation.displayObject.xScale
		local prevTime = 0
		animateMaryWalking = function()
			local curTime = system.getTimer();
			local dt = curTime - prevTime;
			local fps = 1000/dt
			prevTime = curTime;
			
			if paused then
				Runtime:removeEventListener( "enterFrame", animateMaryWalking )
				return
			end
			if maryWalkingAnimation.displayObject then
				if not maryWalkingAnimation.displayObject.x then Runtime:removeEventListener( "enterFrame", animateMaryWalking );return end
				if maryWalkingAnimation.displayObject.x < 50  then
					maryWalkingAnimation.displayObject.alpha = maryWalkingAnimation.displayObject.alpha*0.99
				end
				maryWalkingAnimation.displayObject.x = maryWalkingAnimation.displayObject.x - speed * (60/fps)
				maryWalkingAnimation.getActualFrame()
			end
		end
		
		startMaryWalkingAnimation = function()
			soundController.playNew{
						path = "assets/sound/effects/cap1/12footsteps.mp3",
						identifier = "steps",
						actionTimes = nil,
						action =	nil,
						onComplete = nil
						}
						
			prevTime = system.getTimer()
			
			sheep1.startRunning()
			sheep2.startRunning()
			
			maryWalkingAnimation.start()
			maryWalkingAnimation.appear(300)
			
			maryBlinks.openEyes()
			maryBlinks.startBlinking()
			
			background.isVisible = true
			background.alpha = 0
			transition.to(background,{alpha=1,time=300})
			
			Runtime:addEventListener( "enterFrame", animateMaryWalking )
			
			local function playNextVoice()
				soundController.playNew{
						path = "assets/sound/voices/cap1/adv1_N3.mp3",
						actionTimes = {},
						action =	function()
										nextSubtitle()
									end,
						onComplete = function()
										if type(stopGirlsWaitingAndStartMaryGiggling) == "function" then
											stopGirlsWaitingAndStartMaryGiggling()
										end
										nextSubtitle()
									end
						}
			end
			
			soundController.playNew{
						path = "assets/sound/voices/cap1/adv1_N2.mp3",
						actionTimes = {5500},
						action =	function()
										nextSubtitle()
										vanish()
									end,
						onComplete = function()
										playNextVoice()
										nextSubtitle()
									end
						}
			
			pauseIt = function ()
				maryWalkingAnimation.stop()
				maryBlinks.stopBlinking()
				Runtime:removeEventListener( "enterFrame", animateMaryWalking )
			end
			
			continueIt = function()
				maryWalkingAnimation.start()
				maryBlinks.startBlinking()
				Runtime:addEventListener( "enterFrame", animateMaryWalking )
			end
			
			pauseIt()
			continueIt()
		end
	end
	prepareMaryWalkingAnimation()
	
	--====================================================================--
	-- WAITING GIRLS ANIMATION
	--====================================================================--
	local function prepareWaitingGirlsAnimation()
		local background = display.newImageRect("assets/world/silverGarden.jpg",width,height)
		background:setReferencePoint(display.TopLeftReferencePoint)
		background.x = 0
		background.y = 0
		background.isVisible=false
		localGroup:insert(background)
		
		local girl1OpenEyes = display.newImage("assets/idleGirls/black/eyesOpen.png")
		local girl1ClosedEyes = display.newImage("assets/idleGirls/black/eyesClosed.png")
		
		local girl1Blinks = ui.blink(girl1OpenEyes,girl1ClosedEyes)
		
		local girl1Animation = ui.newAnimation{
						 comps = {
						 {
						  --rhip
						  path = "assets/idleGirls/black/rhip.png",
						  x = { 195.7,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.7,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.7,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.65,195.75,195.7,195.75,195.7,195.7,195.7,195.7,195.65,195.6,195.6,195.55,195.45,195.4,195.35,195.25,195.2,195.15,195.05,195,195,195,195,195,195,195,194.95,194.95,194.95,194.9,194.9,194.9,194.85,194.85,194.8,194.8,194.75,194.7,194.6,194.55,194.45,194.4,194.3,194.2,194.15,194,193.95,193.85,193.75,193.8,193.85,193.9,194,193.95,194,194.05,194.1,194.15,194.25,194.3,194.25,194.3,194.35,194.45,194.45,194.5,194.5,194.65,194.75,194.9,195.05,195.1,195.15,195.25,195.35,195.45,195.55,195.7 },
						  y = { 750.5,750.5,750.5,750.5,750.5,750.5,750.5,750.5,750.5,750.5,750.5,750.5,750.45,750.45,750.45,750.45,750.45,750.45,750.45,750.45,750.45,750.45,750.45,750.45,750.4,750.4,750.4,750.4,750.4,750.4,750.45,750.45,750.45,750.45,750.45,750.45,750.45,750.45,750.45,750.45,750.4,750.4,750.4,750.4,750.35,750.35,750.35,750.4,750.4,750.4,750.4,750.4,750.4,750.45,750.45,750.45,750.45,750.5,750.55,750.6,750.65,750.65,750.75,750.8,750.85,750.9,750.85,750.95,751,751,750.9,750.9,750.9,750.85,750.8,750.8,750.75,750.7,750.65,750.65,750.55,750.55,750.55,750.55,750.5,750.5,750.5,750.5,750.45,750.45,750.45,750.45,750.45,750.45,750.45,750.45,750.4,750.4,750.4,750.35,750.25,750.2,750.1,750.05,750,749.9,749.8,749.8,749.75,749.65,749.7,749.75,749.7,749.8,749.8,749.8,749.9,749.85,749.95,749.95,749.95,750,750,750,749.95,749.95,749.9,749.95,749.95,750.05,750.05,750.15,750.2,750.2,750.3,750.35,750.4,750.45,750.5 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.1075286865234375,0.2159423828125,0.3243560791015625,0.433624267578125,0.542022705078125,0.650421142578125,0.758819580078125,0.868072509765625,0.9764556884765625,1.0848388671875,1.1931915283203125,1.30242919921875,1.34088134765625,1.3793182373046875,1.41864013671875,1.4579620361328125,1.49639892578125,1.5357208251953125,1.57415771484375,1.6125946044921875,1.6519012451171875,1.690338134765625,1.7287750244140625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.768951416015625,1.768951416015625,1.768951416015625,1.768951416015625,1.768951416015625,1.8405609130859375,1.9139251708984375,1.98553466796875,2.05712890625,2.12872314453125,2.2011871337890625,2.27276611328125,2.3443450927734375,2.416778564453125,2.48834228515625,2.560760498046875,2.6323089599609375,2.569488525390625,2.504913330078125,2.44122314453125,2.378387451171875,2.314666748046875,2.250946044921875,2.1880950927734375,2.124359130859375,2.0606231689453125,1.9977569580078125,1.9340057373046875,1.869384765625,1.7444915771484375,1.6195831298828125,1.494659423828125,1.36883544921875,1.243011474609375,1.1180419921875,1.01666259765625,0.915283203125,0.8130035400390625,0.712493896484375,0.6102142333984375,0.5079345703125,0.406524658203125,0.30511474609375,0.2028350830078125,0.101409912109375,0 },
						 },
						 {
						  --rknee
						  path = "assets/idleGirls/black/rknee.png",
						  x = { 202.7,202.7,202.7,202.7,202.7,202.7,202.7,202.7,202.7,202.7,202.7,202.7,202.7,202.7,202.7,202.7,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.6,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.6,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.65,202.55,202.5,202.4,202.3,202.25,202.15,202.05,201.9,201.8,201.7,201.6,201.5,201.4,201.35,201.25,201.15,201.05,200.9,200.75,200.65,200.55,200.45,200.35,200.2,200.2,200.2,200.2,200.2,200.2,200.2,200.2,200.15,200.15,200.1,200.1,200.05,200.05,200,200,199.95,199.9,199.8,199.65,199.5,199.3,199.15,199,198.9,198.75,198.5,198.35,198.2,198.1,198.15,198.3,198.4,198.5,198.65,198.75,198.8,198.95,199.05,199.2,199.3,199.4,199.55,199.7,199.9,200.1,200.2,200.4,200.6,200.8,201.05,201.35,201.5,201.7,201.85,202.1,202.3,202.5,202.7 },
						  y = { 807.15,807.15,807.15,807.15,807.15,807.15,807.15,807.15,807.15,807.15,807.15,807.15,807.15,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.05,807,807.05,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.05,807,807.05,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.1,807.15,807.2,807.25,807.3,807.3,807.4,807.45,807.45,807.55,807.55,807.6,807.65,807.65,807.55,807.6,807.55,807.5,807.45,807.45,807.45,807.35,807.4,807.35,807.25,807.25,807.25,807.25,807.25,807.25,807.25,807.25,807.2,807.2,807.2,807.2,807.2,807.2,807.2,807.2,807.2,807.15,807.15,807.05,807,806.9,806.9,806.8,806.75,806.7,806.65,806.6,806.55,806.5,806.5,806.5,806.5,806.55,806.6,806.6,806.6,806.7,806.65,806.7,806.75,806.7,806.7,806.7,806.7,806.7,806.7,806.75,806.7,806.8,806.85,806.9,806.9,806.9,807,807.05,807.1,807.15,807.1 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.1075286865234375,0.2159423828125,0.3243560791015625,0.433624267578125,0.542022705078125,0.650421142578125,0.758819580078125,0.868072509765625,0.9764556884765625,1.0848388671875,1.1931915283203125,1.30242919921875,1.34088134765625,1.3793182373046875,1.41864013671875,1.4579620361328125,1.49639892578125,1.5357208251953125,1.57415771484375,1.6125946044921875,1.6519012451171875,1.690338134765625,1.7287750244140625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.768951416015625,1.768951416015625,1.768951416015625,1.768951416015625,1.768951416015625,1.8405609130859375,1.9139251708984375,1.98553466796875,2.05712890625,2.12872314453125,2.2011871337890625,2.27276611328125,2.3443450927734375,2.416778564453125,2.48834228515625,2.560760498046875,2.6323089599609375,2.569488525390625,2.504913330078125,2.44122314453125,2.378387451171875,2.314666748046875,2.250946044921875,2.1880950927734375,2.124359130859375,2.0606231689453125,1.9977569580078125,1.9340057373046875,1.869384765625,1.7444915771484375,1.6195831298828125,1.494659423828125,1.36883544921875,1.243011474609375,1.1180419921875,1.01666259765625,0.915283203125,0.8130035400390625,0.712493896484375,0.6102142333984375,0.5079345703125,0.406524658203125,0.30511474609375,0.2028350830078125,0.101409912109375,0 },
						 },
						 {
						  --rfoot
						  path = "assets/idleGirls/black/rfoot.png",
						  x = { 197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.6,197.4,197.25,197.05,196.85,196.75,196.5,196.4,196.2,196,195.85,195.65,195.5,195.35,195.2,195.1,194.95,194.85,194.75,194.55,194.4,194.3,194.15,194,193.9,193.9,193.9,193.9,193.9,193.9,193.9,193.9,193.9,193.85,193.85,193.85,193.8,193.8,193.8,193.75,193.75,193.75,193.5,193.3,193.15,192.9,192.7,192.55,192.3,192.05,191.85,191.6,191.45,191.25,191.4,191.5,191.65,191.9,192,192.15,192.3,192.45,192.6,192.8,192.9,193.1,193.35,193.65,194,194.25,194.55,194.8,195.1,195.35,195.65,195.9,196.1,196.35,196.6,196.85,197.1,197.35,197.6 },
						  y = { 848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.2,848.3,848.35,848.4,848.5,848.65,848.65,848.75,848.85,848.9,849,849.1,849.05,849,848.95,848.8,848.75,848.75,848.65,848.55,848.55,848.4,848.35,848.25,848.25,848.25,848.25,848.25,848.25,848.25,848.25,848.25,848.25,848.25,848.25,848.25,848.25,848.25,848.25,848.25,848.25,848.2,848.15,848.15,848,847.95,847.9,847.9,847.8,847.75,847.65,847.55,847.55,847.55,847.6,847.55,847.6,847.6,847.7,847.7,847.7,847.7,847.8,847.75,847.75,847.8,847.8,847.8,847.8,847.8,847.85,847.85,847.9,847.9,847.9,847.95,847.95,848,848.05,848.1,848.1,848.1 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.1084136962890625,0.2168121337890625,0.325225830078125,0.433624267578125,0.542022705078125,0.65130615234375,0.76055908203125,0.868072509765625,0.9764556884765625,1.0848388671875,1.1931915283203125,1.30242919921875,1.34088134765625,1.3793182373046875,1.41864013671875,1.4570770263671875,1.49639892578125,1.5357208251953125,1.57415771484375,1.6125946044921875,1.6519012451171875,1.690338134765625,1.7287750244140625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.7680816650390625,1.768951416015625,1.768951416015625,1.768951416015625,1.768951416015625,1.768951416015625,1.8405609130859375,1.913055419921875,1.98553466796875,2.05712890625,2.12872314453125,2.2011871337890625,2.27276611328125,2.34521484375,2.416778564453125,2.48834228515625,2.560760498046875,2.6323089599609375,2.569488525390625,2.504913330078125,2.44122314453125,2.3792572021484375,2.3155364990234375,2.250946044921875,2.1880950927734375,2.124359130859375,2.0606231689453125,1.9977569580078125,1.933135986328125,1.869384765625,1.7444915771484375,1.6195831298828125,1.494659423828125,1.36883544921875,1.243011474609375,1.1180419921875,1.01666259765625,0.915283203125,0.8130035400390625,0.712493896484375,0.6102142333984375,0.5079345703125,0.406524658203125,0.30511474609375,0.2028350830078125,0.101409912109375,0 },
						 },
						 {
						  --lhip
						  path = "assets/idleGirls/black/lhip.png",
						  x = { 240.05,240.15,240.2,240.25,240.35,240.5,240.55,240.6,240.7,240.75,240.85,240.95,240.95,241.1,241.15,241.25,241.3,241.35,241.35,241.4,241.4,241.4,241.45,241.45,241.5,241.5,241.5,241.5,241.5,241.45,241.45,241.45,241.4,241.4,241.35,241.35,241.35,241.3,241.35,241.35,241.4,241.4,241.45,241.45,241.5,241.5,241.5,241.5,241.45,241.45,241.45,241.4,241.4,241.35,241.35,241.35,241.3,241.6,241.9,242.2,242.5,242.75,243.1,243.3,243.6,243.9,244.15,244.45,244.7,244.6,244.45,244.3,244.2,244.05,243.9,243.8,243.65,243.5,243.35,243.25,243.05,243.05,243.05,243.05,243.05,243.05,243.05,243.05,243.05,243.05,243.05,243.05,243.05,243.05,243.05,243.05,243.05,243.05,243.1,243.1,243.1,243.15,243.15,243.15,243.15,243.15,243.2,243.25,243.2,243.2,243.15,243.1,243.15,243.05,243,242.95,242.9,242.9,242.9,242.8,242.75,242.7,242.45,242.2,242,241.7,241.5,241.25,241.1,241,240.9,240.8,240.65,240.55,240.45,240.3,240.2,240.1,239.95 },
						  y = { 750.95,750.9,750.95,750.95,750.85,750.85,750.85,750.85,750.9,750.8,750.8,750.85,750.8,750.85,750.8,750.75,750.8,750.75,750.75,750.7,750.65,750.65,750.6,750.6,750.55,750.5,750.5,750.5,750.55,750.55,750.6,750.65,750.65,750.7,750.7,750.75,750.75,750.8,750.75,750.7,750.7,750.65,750.6,750.55,750.55,750.5,750.5,750.55,750.55,750.6,750.65,750.65,750.7,750.7,750.75,750.75,750.8,750.65,750.45,750.3,750.15,750.05,749.85,749.75,749.55,749.4,749.2,749.1,748.9,748.95,748.95,749.05,749.15,749.15,749.25,749.3,749.3,749.4,749.4,749.45,749.6,749.55,749.55,749.55,749.55,749.55,749.55,749.55,749.55,749.5,749.5,749.5,749.5,749.5,749.5,749.5,749.5,749.5,749.45,749.45,749.55,749.5,749.55,749.6,749.6,749.6,749.6,749.65,749.65,749.65,749.65,749.65,749.65,749.6,749.65,749.6,749.65,749.6,749.55,749.55,749.55,749.55,749.6,749.65,749.75,749.75,749.85,749.9,750.05,750.05,750.2,750.25,750.35,750.45,750.6,750.65,750.8,750.8,750.9 },
						  rotation = { -0.2465362548828125,-0.493072509765625,-0.739593505859375,-0.9860687255859375,-1.2333984375,-1.478057861328125,-1.72528076171875,-1.9724273681640625,-2.2186431884765625,-2.4656524658203125,-2.712554931640625,-2.95849609375,-3.2052001953125,-3.4517822265625,-3.6982421875,-3.9436798095703125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.192474365234375,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.192474365234375,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.1916046142578125,-4.773773193359375,-5.356689453125,-5.938507080078125,-6.52081298828125,-7.1035003662109375,-7.6855621337890625,-8.268600463867188,-8.850784301757813,-9.432830810546875,-10.015457153320313,-10.598541259765625,-11.180252075195313,-10.9276123046875,-10.676239013671875,-10.423583984375,-10.17138671875,-9.918777465820313,-9.66748046875,-9.414108276367188,-9.162078857421875,-8.90966796875,-8.65777587890625,-8.405548095703125,-8.151275634765625,-8.151275634765625,-8.151275634765625,-8.151275634765625,-8.151275634765625,-8.151275634765625,-8.151275634765625,-8.151275634765625,-8.151275634765625,-8.151275634765625,-8.151275634765625,-8.151275634765625,-8.151275634765625,-8.151275634765625,-8.151275634765625,-8.151275634765625,-8.151275634765625,-8.151275634765625,-8.33966064453125,-8.527008056640625,-8.71417236328125,-8.901138305664063,-9.087066650390625,-9.274520874023438,-9.461761474609375,-9.648788452148438,-9.835617065429688,-10.022247314453125,-10.208648681640625,-10.396530151367188,-10.24591064453125,-10.094284057617188,-9.944229125976563,-9.794876098632813,-9.644546508789063,-9.49407958984375,-9.343475341796875,-9.1927490234375,-9.042739868164063,-8.893463134765625,-8.742355346679688,-8.59197998046875,-8.020156860351563,-7.4467315673828125,-6.8743896484375,-6.301513671875,-5.7291107177734375,-5.15643310546875,-4.68780517578125,-4.2185516357421875,-3.7504730224609375,-3.2810211181640625,-2.8119964599609375,-2.343475341796875,-1.8746337890625,-1.4055328369140625,-0.9371337890625,-0.468597412109375,0 },
						 },
						 {
						  --lknee
						  path = "assets/idleGirls/black/lknee.png",
						  x = { 232.75,233,233.2,233.4,233.65,233.85,234.1,234.3,234.55,234.75,235,235.2,235.45,235.65,235.85,236.1,236.3,236.35,236.35,236.35,236.4,236.4,236.4,236.4,236.45,236.4,236.4,236.4,236.45,236.4,236.4,236.4,236.4,236.35,236.35,236.35,236.35,236.3,236.35,236.35,236.35,236.4,236.4,236.45,236.4,236.4,236.4,236.45,236.4,236.4,236.4,236.4,236.35,236.35,236.35,236.35,236.3,237,237.7,238.4,239.1,239.75,240.45,241.1,241.8,242.5,243.2,243.9,244.55,244.3,244,243.7,243.45,243.15,242.85,242.6,242.3,242.05,241.75,241.45,241.2,241.15,241.15,241.15,241.15,241.15,241.15,241.15,241.15,241.1,241.05,241.05,241,241,240.95,240.95,240.9,240.9,240.95,241.05,241.15,241.25,241.35,241.4,241.55,241.65,241.75,241.85,241.85,242,241.95,241.85,241.75,241.75,241.7,241.6,241.55,241.55,241.45,241.35,241.3,241.25,240.5,239.85,239.2,238.5,237.8,237.15,236.65,236.35,235.85,235.45,235.05,234.6,234.2,233.8,233.35,232.95,232.55 },
						  y = { 807.4,807.4,807.4,807.35,807.3,807.35,807.35,807.25,807.3,807.25,807.25,807.25,807.15,807.2,807.15,807.1,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,806.95,806.85,806.7,806.55,806.35,806.2,806.05,805.85,805.75,805.55,805.35,805.05,805.25,805.35,805.35,805.5,805.55,805.65,805.7,805.8,805.8,805.95,806,806.05,806.05,806.05,806.05,806.05,806.05,806.05,806.05,806.05,806.05,806.05,806.05,806,806,806,806,806,805.95,806,806,805.95,806.05,806.05,806.05,806.05,806.1,806.05,806.1,806.1,806.1,806.15,806.1,806.15,806.15,806.2,806.25,806.25,806.2,806.25,806.3,806.3,806.3,806.45,806.5,806.65,806.75,806.85,806.9,807,807,807.1,807.15,807.15,807.25,807.3,807.3,807.35,807.4,807.4 },
						  rotation = { 0.1031646728515625,0.206329345703125,0.3094940185546875,0.41351318359375,0.517547607421875,0.6198272705078125,0.7229766845703125,0.826995849609375,0.9301300048828125,1.03326416015625,1.1363983154296875,1.2412567138671875,1.3443756103515625,1.447479248046875,1.550567626953125,1.65277099609375,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.7584686279296875,1.7584686279296875,1.7584686279296875,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.7584686279296875,1.7584686279296875,1.7584686279296875,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.757598876953125,1.7401275634765625,1.7217864990234375,1.704315185546875,1.68597412109375,1.6685028076171875,1.651031494140625,1.6335601806640625,1.6160888671875,1.597747802734375,1.5802764892578125,1.5627899169921875,1.54620361328125,1.4317474365234375,1.317291259765625,1.201934814453125,1.0874481201171875,0.97296142578125,0.85845947265625,0.74395751953125,0.6294403076171875,0.51580810546875,0.4004058837890625,0.285888671875,0.171356201171875,0.171356201171875,0.171356201171875,0.171356201171875,0.171356201171875,0.171356201171875,0.171356201171875,0.171356201171875,0.171356201171875,0.171356201171875,0.171356201171875,0.171356201171875,0.171356201171875,0.171356201171875,0.171356201171875,0.171356201171875,0.171356201171875,0.171356201171875,0.287628173828125,0.40478515625,0.5210418701171875,0.63818359375,0.7553253173828125,0.8715667724609375,0.9886932373046875,1.105804443359375,1.2220306396484375,1.339996337890625,1.456207275390625,1.5724029541015625,1.3102874755859375,1.045501708984375,0.7824249267578125,0.520172119140625,0.255279541015625,-0.006988525390625,-0.271026611328125,-0.5341644287109375,-0.797271728515625,-1.0612335205078125,-1.3251495361328125,-1.588134765625,-1.482421875,-1.3766937255859375,-1.270965576171875,-1.1643524169921875,-1.0586090087890625,-0.9519805908203125,-0.8654632568359375,-0.7789154052734375,-0.6923828125,-0.6058349609375,-0.520172119140625,-0.4327545166015625,-0.3462066650390625,-0.2596588134765625,-0.1731109619140625,-0.0865478515625,0 },
						 },
						 {
						  --lfoot
						  path = "assets/idleGirls/black/lfoot.png",
						  x = { 239.5,239.6,239.7,239.85,240,240.15,240.25,240.35,240.5,240.65,240.7,240.85,241,241.1,241.25,241.35,241.45,241.55,241.6,241.65,241.7,241.75,241.7,241.8,241.8,241.8,241.8,241.8,241.8,241.8,241.7,241.75,241.7,241.7,241.6,241.6,241.55,241.45,241.55,241.6,241.7,241.75,241.8,241.8,241.85,241.8,241.85,241.8,241.8,241.8,241.75,241.7,241.65,241.65,241.6,241.5,241.45,242.15,242.85,243.6,244.25,245,245.7,246.4,247.1,247.75,248.5,249.15,249.85,249.65,249.5,249.25,249.15,248.9,248.75,248.6,248.4,248.2,248.05,247.85,247.6,247.6,247.6,247.6,247.6,247.6,247.6,247.55,247.55,247.55,247.5,247.5,247.5,247.45,247.45,247.4,247.4,247.35,247.45,247.45,247.45,247.45,247.45,247.45,247.4,247.45,247.5,247.45,247.5,247.5,247.65,247.75,247.85,248.05,248.2,248.3,248.4,248.6,248.7,248.85,249,249.1,248.4,247.65,246.95,246.2,245.45,244.75,244.25,243.75,243.25,242.8,242.3,241.8,241.3,240.85,240.35,239.85,239.35 },
						  y = { 848.15,848.3,848.35,848.5,848.45,848.55,848.6,848.75,848.8,848.85,848.95,848.95,849.05,849.05,849.1,849.2,849.25,848.95,848.65,848.4,848.05,847.75,847.45,847.15,846.8,846.5,846.25,846.45,846.8,847,847.3,847.65,847.9,848.15,848.45,848.7,849,849.25,848.95,848.6,848.35,848,847.7,847.35,847.05,846.7,846.95,847.15,847.45,847.7,847.85,848.15,848.3,848.55,848.85,849.05,849.25,849.2,849.1,848.9,848.8,848.7,848.55,848.4,848.3,848.1,847.9,847.75,847.6,847.65,847.8,847.8,847.95,847.95,848.05,848.15,848.25,848.3,848.35,848.45,848.5,848.5,848.5,848.5,848.55,848.55,848.55,848.55,848.55,848.6,848.6,848.65,848.65,848.7,848.7,848.75,848.8,848.8,848.85,848.85,848.9,848.95,848.9,849,849.05,849,849.1,849.05,849.1,849.15,849.1,849.1,849.05,849.1,849.1,849.05,849.05,849.05,849,849,848.95,848.9,848.9,848.85,848.85,848.8,848.7,848.65,848.65,848.55,848.55,848.5,848.5,848.45,848.35,848.25,848.2,848.2,848.1 },
						  rotation = { 0.473846435546875,0.948486328125,1.423004150390625,1.8973388671875,2.3722686767578125,2.84600830078125,3.3202362060546875,3.79486083984375,4.26898193359375,4.7442474365234375,5.2180023193359375,5.69189453125,6.166748046875,6.6407318115234375,7.1164093017578125,7.590240478515625,8.064727783203125,6.567413330078125,5.0688323974609375,3.5719757080078125,2.07373046875,0.576995849609375,-0.919647216796875,-2.4185333251953125,-3.91497802734375,-5.41302490234375,-6.9105682373046875,-5.5490264892578125,-4.1881256103515625,-2.825958251953125,-1.4649505615234375,-0.1031646728515625,1.256988525390625,2.6192169189453125,3.980224609375,5.3419647216796875,6.703704833984375,8.064727783203125,6.49664306640625,4.9300079345703125,3.362060546875,1.794281005859375,0.2273101806640625,-1.339996337890625,-2.90618896484375,-4.4749755859375,-3.33416748046875,-2.1941986083984375,-1.0542449951171875,0.084808349609375,1.2246551513671875,2.364410400390625,3.504913330078125,4.6452484130859375,5.7845001220703125,6.9243621826171875,8.064727783203125,8.047592163085938,8.029586791992188,8.011581420898438,7.99444580078125,7.9764404296875,7.95843505859375,7.9412841796875,7.92413330078125,7.9061126708984375,7.8881072998046875,7.870941162109375,7.852935791015625,7.7379302978515625,7.6237335205078125,7.50860595703125,7.394287109375,7.279052734375,7.16546630859375,7.0509796142578125,6.9364166259765625,6.821807861328125,6.7071533203125,6.592437744140625,6.4767913818359375,6.4767913818359375,6.4767913818359375,6.4767913818359375,6.4767913818359375,6.4767913818359375,6.4767913818359375,6.4767913818359375,6.4767913818359375,6.4767913818359375,6.4767913818359375,6.4767913818359375,6.4767913818359375,6.4767913818359375,6.4767913818359375,6.4767913818359375,6.4767913818359375,6.4767913818359375,6.593292236328125,6.710601806640625,6.827850341796875,6.9441680908203125,7.061309814453125,7.178375244140625,7.2945404052734375,7.4114837646484375,7.52838134765625,7.64520263671875,7.761962890625,7.8795166015625,7.615997314453125,7.3513031005859375,7.0888519287109375,6.82525634765625,6.5605010986328125,6.2971954345703125,6.03448486328125,5.770660400390625,5.5065765380859375,5.243133544921875,4.9794769287109375,4.7173309326171875,4.4019775390625,4.0872344970703125,3.773101806640625,3.4578857421875,3.1424407958984375,2.8285675048828125,2.57122802734375,2.3137969970703125,2.0562591552734375,1.7995147705078125,1.5427093505859375,1.28582763671875,1.0280303955078125,0.77105712890625,0.5140533447265625,0.2570343017578125,0 },
						 },
						 {
						  --buds
						  path = "assets/budsDeFrente.png",
						  scale = 0.25,
						  yOffset = -50,
						  xOffset = -5,
						  x = { 219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.2,219.1,219,218.85,218.8,218.7,218.6,218.5,218.4,218.25,218.2,218.1,218.25,218.2,218.3,218.3,218.4,218.4,218.55,218.55,218.65,218.65,218.75,218.8,218.8,218.8,218.8,218.8,218.8,218.8,218.8,218.75,218.75,218.75,218.75,218.75,218.75,218.75,218.75,218.75,218.75,218.7,218.85,218.9,218.95,218.95,219.05,219.1,219.15,219.15,219.2,219.25,219.3,219.3,219.25,219.25,219.25,219.2,219.2,219.15,219.15,219.15,219.1,219.1,219.1,219.1,219.1,219.15,219.15,219.15,219.15,219.2,219.2,219.2,219.25,219.25,219.25,219.25,219.3,219.3,219.3,219.35 },
						  y = { 695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.2,695.15,695.1,695.1,695.1,695,694.95,694.95,694.9,694.9,694.85,694.85,694.85,694.85,694.85,694.85,694.9,694.9,694.85,694.85,694.9,694.9,694.85,694.8,694.8,694.75,694.75,694.75,694.7,694.7,694.7,694.65,694.65,694.6,694.6,694.55,694.55,694.5,694.5,694.5,694.45,694.5,694.45,694.45,694.45,694.5,694.45,694.5,694.5,694.45,694.45,694.45,694.45,694.45,694.45,694.45,694.45,694.4,694.4,694.4,694.4,694.4,694.4,694.35,694.5,694.6,694.7,694.8,694.9,694.95,695,695.05,695.05,695.1,695.15,695.15,695.2,695.25,695.25,695.3,695.3 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.2342987060546875,-0.468597412109375,-0.7028656005859375,-0.9371337890625,-1.1722259521484375,-1.406402587890625,-1.6405487060546875,-1.8755035400390625,-2.109527587890625,-2.3443450927734375,-2.5790863037109375,-2.8119964599609375,-2.7265167236328125,-2.641021728515625,-2.5555267333984375,-2.47088623046875,-2.3853607177734375,-2.2998199462890625,-2.213409423828125,-2.12872314453125,-2.0431671142578125,-1.9575958251953125,-1.87200927734375,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.61346435546875,-1.4413604736328125,-1.2683563232421875,-1.0953216552734375,-0.922271728515625,-0.7500762939453125,-0.5778656005859375,-0.40478515625,-0.2325592041015625,-0.0594482421875,0.111907958984375,0.285003662109375,0.22119140625,0.1573638916015625,0.09442138671875,0.0305938720703125,-0.0323486328125,-0.0952911376953125,-0.15911865234375,-0.222930908203125,-0.285888671875,-0.349700927734375,-0.41351318359375,-0.4773406982421875,-0.4449920654296875,-0.41351318359375,-0.3811798095703125,-0.349700927734375,-0.317352294921875,-0.285888671875,-0.2596588134765625,-0.233428955078125,-0.2071990966796875,-0.1818389892578125,-0.1556243896484375,-0.12939453125,-0.1031646728515625,-0.0778045654296875,-0.05157470703125,-0.025360107421875,0 },
						 },
						 {
						  --body
						  path = "assets/idleGirls/black/body.png",
						  x = { 219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.35,219.2,219.1,219,218.85,218.8,218.7,218.6,218.5,218.4,218.25,218.2,218.1,218.25,218.2,218.3,218.3,218.4,218.4,218.55,218.55,218.65,218.65,218.75,218.8,218.8,218.8,218.8,218.8,218.8,218.8,218.8,218.75,218.75,218.75,218.75,218.75,218.75,218.75,218.75,218.75,218.75,218.7,218.85,218.9,218.95,218.95,219.05,219.1,219.15,219.15,219.2,219.25,219.3,219.3,219.25,219.25,219.25,219.2,219.2,219.15,219.15,219.15,219.1,219.1,219.1,219.1,219.1,219.15,219.15,219.15,219.15,219.2,219.2,219.2,219.25,219.25,219.25,219.25,219.3,219.3,219.3,219.35 },
						  y = { 695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.3,695.2,695.15,695.1,695.1,695.1,695,694.95,694.95,694.9,694.9,694.85,694.85,694.85,694.85,694.85,694.85,694.9,694.9,694.85,694.85,694.9,694.9,694.85,694.8,694.8,694.75,694.75,694.75,694.7,694.7,694.7,694.65,694.65,694.6,694.6,694.55,694.55,694.5,694.5,694.5,694.45,694.5,694.45,694.45,694.45,694.5,694.45,694.5,694.5,694.45,694.45,694.45,694.45,694.45,694.45,694.45,694.45,694.4,694.4,694.4,694.4,694.4,694.4,694.35,694.5,694.6,694.7,694.8,694.9,694.95,695,695.05,695.05,695.1,695.15,695.15,695.2,695.25,695.25,695.3,695.3 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.2342987060546875,-0.468597412109375,-0.7028656005859375,-0.9371337890625,-1.1722259521484375,-1.406402587890625,-1.6405487060546875,-1.8755035400390625,-2.109527587890625,-2.3443450927734375,-2.5790863037109375,-2.8119964599609375,-2.7265167236328125,-2.641021728515625,-2.5555267333984375,-2.47088623046875,-2.3853607177734375,-2.2998199462890625,-2.213409423828125,-2.12872314453125,-2.0431671142578125,-1.9575958251953125,-1.87200927734375,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.61346435546875,-1.4413604736328125,-1.2683563232421875,-1.0953216552734375,-0.922271728515625,-0.7500762939453125,-0.5778656005859375,-0.40478515625,-0.2325592041015625,-0.0594482421875,0.111907958984375,0.285003662109375,0.22119140625,0.1573638916015625,0.09442138671875,0.0305938720703125,-0.0323486328125,-0.0952911376953125,-0.15911865234375,-0.222930908203125,-0.285888671875,-0.349700927734375,-0.41351318359375,-0.4773406982421875,-0.4449920654296875,-0.41351318359375,-0.3811798095703125,-0.349700927734375,-0.317352294921875,-0.285888671875,-0.2596588134765625,-0.233428955078125,-0.2071990966796875,-0.1818389892578125,-0.1556243896484375,-0.12939453125,-0.1031646728515625,-0.0778045654296875,-0.05157470703125,-0.025360107421875,0 },
						 },
						 {
						  --rarm
						  path = "assets/idleGirls/black/rarm.png",
						  x = { 167.9,168.55,169.4,170.25,171.1,171.9,172.8,173.75,174.7,175.7,176.6,177.65,178.65,179.6,180.6,181.65,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,182.6,181.95,181.3,180.55,179.9,179.2,178.5,177.85,177.15,176.5,175.9,175.1,174.5,174.45,174.35,174.25,174.25,174.1,174.1,174,173.95,173.9,173.85,173.8,173.8,173.15,172.65,171.95,171.45,170.85,170.4,169.85,169.2,169.7,170.2,170.7,171.15,171.7,172.25,172.7,173.2,173.75,173.85,174,174.15,174.25,174.4,174.5,174.6,174.75,174.9,175.05,175.15,175.35,175.25,175.25,175.2,175.15,175.05,175.05,175,174.95,174.8,174.85,174.75,174.7,174.65,174.75,174.75,174.75,174.75,174.8,173.95,173.25,172.5,171.8,171,170.4,169.65,169,168.35,167.75,167.15 },
						  y = { 661.75,662.4,662.95,663.55,664.1,664.6,664.95,665.4,665.7,666.05,666.2,666.4,666.6,666.65,666.65,666.65,666.6,666.6,666.6,666.6,666.55,666.55,666.55,666.55,666.55,666.55,666.55,666.55,666.55,666.55,666.55,666.55,666.55,666.6,666.6,666.6,666.6,666.6,666.6,666.6,666.6,666.55,666.55,666.55,666.55,666.55,666.55,666.55,666.55,666.55,666.55,666.55,666.6,666.6,666.6,666.6,666.6,666.8,666.95,667.15,667.35,667.6,667.7,667.85,667.95,668.1,668.3,668.35,668.5,668.4,668.35,668.15,668.1,668,667.95,667.8,667.75,667.5,667.4,667.35,667.2,667.05,666.8,666.6,666.4,666.2,665.9,665.7,665.35,665.55,665.8,666.05,666.25,666.4,666.55,666.85,666.9,667.05,666.95,666.75,666.65,666.5,666.35,666.25,666.1,666,665.85,665.7,665.6,665.45,665.5,665.5,665.6,665.6,665.65,665.7,665.75,665.8,665.9,665.9,665.9,666,665.95,665.9,665.85,665.85,665.85,665.85,665.5,665.25,664.85,664.5,664.1,663.7,663.2,662.65,662.15,661.65,661 },
						  rotation = { -2.9332122802734375,-5.8693084716796875,-8.802978515625,-11.736160278320313,-14.672149658203125,-17.606155395507813,-20.54071044921875,-23.47509765625,-26.409576416015625,-29.343154907226563,-32.278076171875,-35.21250915527344,-38.14654541015625,-41.08119201660156,-44.01631164550781,-46.95048522949219,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-49.88551330566406,-48.756256103515625,-47.627899169921875,-46.499053955078125,-45.369873046875,-44.242401123046875,-43.11341857910156,-41.98509216308594,-40.85589599609375,-39.72831726074219,-38.599517822265625,-37.47100830078125,-36.34254455566406,-35.79420471191406,-35.245758056640625,-34.69807434082031,-34.14842224121094,-33.601226806640625,-33.053131103515625,-32.504364013671875,-31.955718994140625,-31.407455444335938,-30.860427856445313,-30.312301635742188,-29.763259887695313,-27.989028930664063,-26.214279174804688,-24.440261840820313,-22.66552734375,-20.89178466796875,-19.117263793945313,-17.342071533203125,-15.568374633789063,-17.145904541015625,-18.72296142578125,-20.300384521484375,-21.877182006835938,-23.454498291015625,-25.031631469726563,-26.60980224609375,-28.186355590820313,-29.763916015625,-29.59100341796875,-29.418167114257813,-29.245407104492188,-29.073394775390625,-28.901473999023438,-28.728317260742188,-28.555252075195313,-28.382965087890625,-28.210128784179688,-28.037399291992188,-27.864120483398438,-27.692352294921875,-27.75537109375,-27.8197021484375,-27.883255004882813,-27.947418212890625,-28.010833740234375,-28.074859619140625,-28.1387939453125,-28.202667236328125,-28.265777587890625,-28.330154418945313,-28.393798828125,-28.457351684570313,-28.187713623046875,-27.918075561523438,-27.647781372070313,-27.378204345703125,-27.107986450195313,-26.839263916015625,-24.399673461914063,-21.959197998046875,-19.519012451171875,-17.079620361328125,-14.639419555664063,-12.199676513671875,-9.76007080078125,-7.3194732666015625,-4.878814697265625,-2.4394683837890625,0 },
						 },
						 {
						  --rforearm
						  path = "assets/idleGirls/black/rforearm.png",
						  x = { 145.15,148.4,151.7,155.15,158.6,162.15,165.75,169.35,172.9,176.45,179.95,183.5,186.95,190.3,193.55,196.7,199.7,199.85,200,200.1,200.2,200.35,200.45,200.55,200.65,200.75,200.85,200.75,200.65,200.55,200.45,200.4,200.3,200.2,200.05,199.95,199.85,199.7,199.9,200,200.2,200.35,200.45,200.6,200.7,200.85,200.75,200.65,200.55,200.45,200.4,200.3,200.2,200.05,199.95,199.85,199.7,197.8,195.7,193.55,191.25,188.9,186.4,183.85,181.25,178.6,175.9,173.2,170.4,169.95,169.5,169.05,168.65,168.2,167.7,167.3,166.8,166.4,165.9,165.55,165.1,163.2,161.3,159.5,157.65,155.85,154,152.2,150.55,152.7,154.85,157.15,159.4,161.65,163.95,166.25,168.55,170.8,170.85,170.8,170.8,170.85,170.85,170.85,170.9,170.9,170.9,170.85,170.9,170.9,170.9,170.9,170.9,170.9,170.9,170.9,170.85,170.85,170.85,170.85,170.85,170.85,170.45,170.05,169.65,169.25,168.8,168.4,165.85,163.35,160.8,158.35,155.85,153.4,151.05,148.75,146.45,144.2,142.1 },
						  y = { 697.65,699.5,701.15,702.55,703.75,704.7,705.4,705.9,706.2,706.15,705.95,705.5,704.8,704.1,703,701.65,700.25,699.95,699.85,699.65,699.45,699.2,698.95,698.75,698.6,698.35,698.15,698.3,698.55,698.7,698.9,699.15,699.35,699.45,699.65,699.85,700.05,700.25,699.95,699.7,699.45,699.2,698.9,698.65,698.35,698.15,698.3,698.55,698.7,698.9,699.15,699.35,699.45,699.65,699.85,700.05,700.25,701.85,703.3,704.75,706,707.15,708.25,709.1,709.8,710.45,710.85,711.15,711.25,711.1,710.95,710.8,710.55,710.4,710.2,710,709.8,709.6,709.4,709.2,708.95,708.5,708,707.4,706.75,706.05,705.35,704.55,703.65,704.55,705.4,706.05,706.65,707.15,707.55,707.8,708,708.1,707.9,707.75,707.6,707.45,707.3,707.2,707.05,706.85,706.65,706.6,706.4,706.3,706.4,706.35,706.45,706.45,706.5,706.55,706.6,706.65,706.65,706.7,706.75,706.85,706.85,706.8,706.8,706.75,706.8,706.75,706.2,705.65,705,704.15,703.3,702.3,701.1,699.85,698.55,697.1,695.55 },
						  rotation = { -4.94476318359375,-9.890777587890625,-14.835662841796875,-19.781097412109375,-24.725830078125,-29.67291259765625,-34.61761474609375,-39.563995361328125,-44.509918212890625,-49.45567321777344,-54.40069580078125,-59.34552001953125,-64.291015625,-69.23652648925781,-74.18205261230469,-79.12802124023438,-84.07273864746094,-84.95372009277344,-85.83535766601563,-86.71636962890625,-87.59892272949219,-88.48001098632813,-89.36094665527344,-90.24130249023438,-91.12240600585938,-92.00474548339844,-92.88525390625,-92.08506774902344,-91.28407287597656,-90.48170471191406,-89.68177795410156,-88.88020324707031,-88.07908630371094,-87.27871704101563,-86.47679138183594,-85.67538452148438,-84.87391662597656,-84.07273864746094,-85.17413330078125,-86.27651977539063,-87.37815856933594,-88.48001098632813,-89.58123779296875,-90.68190002441406,-91.78379821777344,-92.88525390625,-92.08506774902344,-91.28407287597656,-90.48170471191406,-89.68177795410156,-88.88020324707031,-88.07908630371094,-87.27871704101563,-86.47679138183594,-85.67538452148438,-84.87391662597656,-84.07273864746094,-78.84835815429688,-73.62277221679688,-68.39889526367188,-63.17466735839844,-57.9493408203125,-52.72444152832031,-47.499786376953125,-42.27507019042969,-37.050140380859375,-31.826522827148438,-26.60211181640625,-21.377044677734375,-21.099807739257813,-20.823074340820313,-20.546844482421875,-20.269607543945313,-19.992935180664063,-19.716049194335938,-19.440536499023438,-19.162521362304688,-18.88592529296875,-18.60919189453125,-18.3331298828125,-18.055389404296875,-16.281417846679688,-14.506744384765625,-12.733123779296875,-10.95794677734375,-9.184219360351563,-7.409759521484375,-5.6347503662109375,-3.86102294921875,-7.615997314453125,-11.371963500976563,-15.126907348632813,-18.882003784179688,-22.637985229492188,-26.3934326171875,-30.147842407226563,-33.903411865234375,-37.65830993652344,-37.486419677734375,-37.31373596191406,-37.14024353027344,-36.967071533203125,-36.79423522949219,-36.62229919433594,-36.44903564453125,-36.276123046875,-36.10301208496094,-35.92970275878906,-35.75794982910156,-35.58485412597656,-35.648406982421875,-35.71186828613281,-35.77464294433594,-35.83845520019531,-35.901611328125,-35.96580505371094,-36.02874755859375,-36.0921630859375,-36.15605163574219,-36.21983337402344,-36.28294372558594,-36.347076416015625,-35.5518798828125,-34.75535583496094,-33.959991455078125,-33.16416931152344,-32.36859130859375,-31.572738647460938,-28.70343017578125,-25.831634521484375,-22.9619140625,-20.091690063476563,-17.221710205078125,-14.351776123046875,-11.481155395507813,-8.61077880859375,-5.7403717041015625,-2.8695526123046875,0 },
						 },
						 {
						  --rhand
						  path = "assets/idleGirls/black/rhand.png",
						  x = { 139.05,145.1,151.25,157.5,163.8,170.1,176.4,182.6,188.7,194.7,200.5,206.05,211.4,216.55,221.3,225.8,230,230.35,230.75,231.05,231.4,231.7,232,232.25,232.4,232.65,232.85,232.7,232.5,232.25,232.05,231.85,231.6,231.3,231,230.65,230.35,230,230.5,230.95,231.3,231.7,232,232.35,232.65,232.85,232.7,232.5,232.25,232.05,231.85,231.6,231.3,231,230.65,230.35,230,226.85,223.35,219.5,215.3,210.9,206.2,201.2,196.05,190.7,185.25,179.7,174.05,173.45,172.9,172.35,171.7,171.2,170.6,170.05,169.5,168.9,168.35,167.8,167.25,164.3,161.45,158.6,155.75,152.95,150.15,147.4,144.6,148.95,153.3,157.7,162.1,166.5,170.85,175.25,179.55,183.85,183.75,183.65,183.6,183.5,183.4,183.35,183.25,183.15,183.1,183,182.9,182.85,182.85,182.9,182.85,182.95,183,183,183,183.05,183.1,183.1,183.15,183.15,182.35,181.45,180.55,179.7,178.85,177.95,173.8,169.6,165.4,161.2,157.05,152.95,148.85,144.85,140.9,137,133.2 },
						  y = { 729.6,731.85,733.6,735,735.8,736.2,736.05,735.5,734.5,733.05,731.15,728.85,726.15,723.05,719.6,715.85,711.8,710.95,710.05,709.15,708.25,707.35,706.45,705.5,704.6,703.65,702.7,703.55,704.45,705.25,706.1,706.95,707.75,708.6,709.4,710.2,711,711.8,710.7,709.6,708.5,707.35,706.2,705.05,703.95,702.7,703.55,704.45,705.25,706.1,706.95,707.75,708.6,709.4,710.2,711,711.8,716.1,720.2,724,727.55,730.75,733.75,736.3,738.5,740.25,741.7,742.65,743.25,743.15,742.95,742.9,742.75,742.6,742.4,742.3,742.1,741.95,741.75,741.7,741.45,741.1,740.55,740,739.25,738.55,737.7,736.8,735.75,736.95,737.95,738.65,739.1,739.4,739.4,739.05,738.65,737.9,737.75,737.65,737.5,737.45,737.3,737.15,737.05,736.95,736.85,736.75,736.65,736.5,736.6,736.55,736.65,736.7,736.75,736.75,736.8,736.85,736.9,736.9,736.95,737,737.15,737.3,737.45,737.6,737.7,737.8,737.8,737.6,737.15,736.5,735.7,734.7,733.5,732.1,730.6,728.8,726.85 },
						  rotation = { -4.94476318359375,-9.889938354492188,-14.8348388671875,-19.779556274414063,-24.725112915039063,-29.66961669921875,-34.6158447265625,-39.55931091308594,-44.50457763671875,-49.45011901855469,-54.39491271972656,-59.33970642089844,-64.28463745117188,-69.22964477539063,-74.17475891113281,-79.11959838867188,-84.0640869140625,-85.87884521484375,-87.69406127929688,-89.50779724121094,-91.32252502441406,-93.13546752929688,-94.94996643066406,-96.76492309570313,-98.58000183105469,-100.39398193359375,-102.2088623046875,-100.558837890625,-98.90966796875,-97.26011657714844,-95.61050415039063,-93.96109008789063,-92.31117248535156,-90.66178894042969,-89.01304626464844,-87.36421203613281,-85.71536254882813,-84.0640869140625,-86.33222961425781,-88.6005859375,-90.86807250976563,-93.13546752929688,-95.40348815917969,-97.67268371582031,-99.94084167480469,-102.2088623046875,-100.558837890625,-98.90966796875,-97.26011657714844,-95.61050415039063,-93.96109008789063,-92.31117248535156,-90.66178894042969,-89.01304626464844,-87.36421203613281,-85.71536254882813,-84.0640869140625,-78.83995056152344,-73.61552429199219,-68.38983154296875,-63.165618896484375,-57.939300537109375,-52.71504211425781,-47.48933410644531,-42.2655029296875,-37.03955078125,-31.815780639648438,-26.590225219726563,-21.365676879882813,-21.088394165039063,-20.8123779296875,-20.53533935546875,-20.258071899414063,-19.982894897460938,-19.705978393554688,-19.429656982421875,-19.153167724609375,-18.87652587890625,-18.599761962890625,-18.32366943359375,-18.0474853515625,-16.273361206054688,-14.498550415039063,-12.72314453125,-10.94952392578125,-9.174850463867188,-7.4003143310546875,-5.6260986328125,-3.8514404296875,-7.6065521240234375,-11.362716674804688,-15.117141723632813,-18.87261962890625,-22.629043579101563,-26.384323120117188,-30.13934326171875,-33.894378662109375,-37.65008544921875,-37.47650146484375,-37.3043212890625,-37.13134765625,-36.95869445800781,-36.78582763671875,-36.61384582519531,-36.4405517578125,-36.26930236816406,-36.09559631347656,-35.92283630371094,-35.750457763671875,-35.57734680175781,-35.6414794921875,-35.70494079589844,-35.76887512207031,-35.83213806152344,-35.8958740234375,-35.959503173828125,-36.02302551269531,-36.086456298828125,-36.15034484863281,-36.21357727050781,-36.27668762207031,-36.34027099609375,-35.54493713378906,-34.75004577636719,-33.95457458496094,-33.159881591796875,-32.364227294921875,-31.568923950195313,-28.69805908203125,-25.828811645507813,-22.958221435546875,-20.089385986328125,-17.219314575195313,-14.349319458007813,-11.4786376953125,-8.60906982421875,-5.739501953125,-2.87042236328125,0 },
						 },
						 {
						  --larm
						  path = "assets/idleGirls/black/larm.png",
						  x = { 265.3,264.55,263.8,263.05,262.25,261.35,260.55,259.65,258.7,257.85,256.95,255.95,255,254.1,253.15,252.2,251.25,251.2,251.2,251.2,251.15,251.1,251.1,251.1,251.05,251.05,251.05,251.05,251.05,251.05,251.1,251.1,251.1,251.2,251.2,251.2,251.2,251.25,251.2,251.2,251.2,251.1,251.1,251.05,251.05,251.05,251.05,251.05,251.05,251.1,251.1,251.1,251.2,251.2,251.2,251.2,251.25,251.5,251.75,252,252.25,252.5,252.75,253,253.2,253.5,253.75,254,254.25,254.45,254.6,254.75,255,255.2,255.4,255.55,255.75,255.95,256.15,256.3,256.5,257.05,257.6,258.15,258.7,259.25,259.7,260.25,260.8,260.35,259.95,259.45,259.05,258.6,258.1,257.7,257.25,256.75,255.5,254.4,253.1,251.85,250.55,249.35,248.15,246.9,245.7,244.55,243.45,242.45,242.55,242.8,242.95,243.1,243.35,243.55,243.75,243.95,244.15,244.35,244.55,244.75,244.75,244.75,244.7,244.75,244.75,244.7,246.7,248.7,250.8,252.9,254.95,257.05,259,260.95,262.75,264.45,266 },
						  y = { 662.05,662.7,663.3,663.85,664.3,664.8,665.25,665.65,666,666.3,666.55,666.7,666.9,667,667.1,667.1,667.05,667.05,667.05,667.05,667.05,667,667,667,667,667,666.95,666.95,667,667,667,667,667,667.05,667.05,667.05,667.05,667.05,667.05,667.05,667.05,667,667,667,667,666.95,666.95,667,667,667,667,667,667.05,667.05,667.05,667.05,667.05,666.95,666.8,666.6,666.45,666.25,666.05,665.8,665.6,665.3,665.05,664.8,664.55,664.55,664.6,664.65,664.6,664.7,664.7,664.7,664.8,664.85,664.85,664.85,664.95,664.75,664.45,664.2,664.05,663.75,663.5,663.2,662.9,663.2,663.5,663.75,664,664.3,664.55,664.75,664.95,665.2,665.7,666.05,666.4,666.6,666.65,666.7,666.6,666.4,666.05,665.65,665.15,664.5,664.65,664.75,664.9,664.95,665.1,665.2,665.3,665.35,665.45,665.55,665.65,665.7,665.6,665.55,665.5,665.35,665.35,665.3,665.9,666.4,666.7,666.8,666.65,666.25,665.7,664.9,663.9,662.75,661.4 },
						  rotation = { 2.808502197265625,5.6183013916015625,8.42608642578125,11.236618041992188,14.046112060546875,16.854873657226563,19.66412353515625,22.47320556640625,25.282318115234375,28.0911865234375,30.901641845703125,33.70965576171875,36.51853942871094,39.32835388183594,42.13690185546875,44.94621276855469,47.755584716796875,47.755584716796875,47.755584716796875,47.755584716796875,47.755584716796875,47.75654602050781,47.75654602050781,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75654602050781,47.75654602050781,47.75654602050781,47.755584716796875,47.755584716796875,47.755584716796875,47.755584716796875,47.755584716796875,47.755584716796875,47.755584716796875,47.755584716796875,47.75654602050781,47.75654602050781,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75654602050781,47.75654602050781,47.75654602050781,47.755584716796875,47.755584716796875,47.755584716796875,47.755584716796875,47.755584716796875,46.19923400878906,44.64385986328125,43.08778381347656,41.531646728515625,39.974609375,38.4185791015625,36.863128662109375,35.30693054199219,33.75077819824219,32.19488525390625,30.6383056640625,29.082748413085938,28.827713012695313,28.570770263671875,28.315261840820313,28.0592041015625,27.801910400390625,27.547531127929688,27.291275024414063,27.035903930664063,26.780059814453125,26.523773193359375,26.267730712890625,26.012680053710938,24.28790283203125,22.562728881835938,20.838348388671875,19.11492919921875,17.389068603515625,15.664886474609375,13.939926147460938,12.216384887695313,13.747894287109375,15.281600952148438,16.814834594726563,18.347305297851563,19.880126953125,21.413421630859375,22.94635009765625,24.4801025390625,26.012680053710938,30.211212158203125,34.411651611328125,38.61073303222656,42.810455322265625,47.010772705078125,51.2098388671875,55.409027099609375,59.608917236328125,63.80894470214844,68.00846862792969,72.20817565917969,76.40728759765625,75.49897766113281,74.59075927734375,73.68234252929688,72.77349853515625,71.86483764648438,70.95613098144531,70.04876708984375,69.14027404785156,68.23207092285156,67.32330322265625,66.4154052734375,65.50613403320313,65.62498474121094,65.74406433105469,65.86262512207031,65.98141479492188,66.10041809082031,66.21890258789063,60.19920349121094,54.179931640625,48.159210205078125,42.138824462890625,36.118988037109375,30.099441528320313,24.079833984375,18.059341430664063,12.040054321289063,6.0197906494140625,0 },
						 },
						 {
						  --lforearm
						  path = "assets/idleGirls/black/lforearm.png",
						  x = { 288.15,285.65,283.05,280.4,277.6,274.8,271.95,269.1,266.1,263.2,260.15,257.1,254.05,251.05,248,244.95,241.95,242,242,242.05,242.1,242.1,242.15,242.2,242.25,242.3,242.3,242.3,242.25,242.25,242.15,242.1,242.1,242.05,242.05,242,242,241.95,242,242.05,242.05,242.1,242.15,242.25,242.25,242.3,242.3,242.25,242.25,242.15,242.1,242.1,242.05,242.05,242,242,241.95,243.7,245.5,247.2,249,250.75,252.55,254.4,256.15,257.95,259.75,261.5,263.3,263.5,263.7,263.9,264.1,264.3,264.55,264.75,264.95,265.15,265.35,265.55,265.75,267.55,269.35,271.1,272.8,274.55,276.2,277.9,279.5,277.45,275.35,273.2,271.05,268.9,266.75,264.5,262.3,260.1,255.95,251.75,247.55,243.35,239.15,235.05,231.1,227.2,223.45,219.85,216.45,213.2,213.55,213.95,214.45,214.9,215.35,215.8,216.3,216.75,217.35,217.95,218.45,218.95,219,219,219.05,219,219,219,224.15,229.95,236.1,242.7,249.55,256.65,263.75,270.85,277.75,284.35,290.55 },
						  y = { 697.3,699.05,700.65,702.1,703.45,704.55,705.7,706.5,707.25,707.9,708.35,708.7,708.85,708.8,708.65,708.4,707.95,708,708,707.95,707.95,707.95,708,708,708,708.05,708.05,708.05,708,708,708,707.95,707.95,707.95,708,708,708,707.95,708,708,707.95,707.95,708,708,708.05,708.05,708.05,708,708,708,707.95,707.95,707.95,708,708,708,707.95,708.2,708.45,708.55,708.6,708.6,708.45,708.25,708.05,707.75,707.35,706.85,706.3,706.3,706.3,706.35,706.35,706.35,706.35,706.4,706.4,706.35,706.35,706.35,706.4,705.85,705.35,704.65,704,703.35,702.55,701.7,700.8,701.8,702.65,703.45,704.1,704.6,705.15,705.45,705.7,705.8,706.5,706.75,706.8,706.55,705.8,704.9,703.65,702.05,700.25,698.05,695.65,692.95,692.95,692.9,692.85,692.8,692.75,692.7,692.55,692.45,692.3,692.15,692,691.85,691.9,692,692,692,692.05,692.15,696.35,699.85,702.65,704.8,706.1,706.55,706.15,704.75,702.55,699.4,695.5 },
						  rotation = { 2.80938720703125,5.6183013916015625,8.42779541015625,11.237457275390625,14.046112060546875,16.855682373046875,19.664901733398438,22.474685668945313,25.28375244140625,28.093902587890625,30.90228271484375,33.71147155761719,36.520233154296875,39.32939147949219,42.13978576660156,44.94883728027344,47.75798034667969,47.75749206542969,47.75749206542969,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75605773925781,47.75605773925781,47.755584716796875,47.755584716796875,47.755584716796875,47.75605773925781,47.75605773925781,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75749206542969,47.75749206542969,47.75749206542969,47.75798034667969,47.75749206542969,47.75749206542969,47.75701904296875,47.75701904296875,47.75701904296875,47.75605773925781,47.755584716796875,47.755584716796875,47.755584716796875,47.75605773925781,47.75605773925781,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75749206542969,47.75749206542969,47.75749206542969,47.75798034667969,44.792572021484375,41.82720947265625,38.86285400390625,35.898162841796875,32.93074035644531,29.967727661132813,27.001907348632813,24.036819458007813,21.070892333984375,18.106735229492188,15.141586303710938,12.176284790039063,12.48834228515625,12.802978515625,13.11517333984375,13.42822265625,13.742111206054688,14.054351806640625,14.36737060546875,14.68115234375,14.994033813476563,15.307632446289063,15.619476318359375,15.933624267578125,14.208908081054688,12.484176635742188,10.759796142578125,9.034210205078125,7.3100128173828125,5.5854034423828125,3.86102294921875,2.135711669921875,5.9454193115234375,9.753280639648438,13.561325073242188,17.369155883789063,21.177398681640625,24.98638916015625,28.794158935546875,32.60249328613281,36.41168212890625,40.60939025878906,44.809295654296875,49.00933837890625,53.209136962890625,57.40867614746094,61.60823059082031,65.80804443359375,70.00706481933594,74.20713806152344,78.40638732910156,82.605712890625,86.80525207519531,88.30180358886719,89.79804992675781,91.29368591308594,92.79019165039063,94.286376953125,95.78277587890625,97.279052734375,98.77481079101563,100.27214050292969,101.76800537109375,103.26434326171875,104.76046752929688,104.65986633300781,104.55836486816406,104.45675659179688,104.35588073730469,104.25491333007813,104.15303039550781,94.68434143066406,85.2166748046875,75.74755859375,66.27969360351563,56.81134033203125,47.34239196777344,37.874114990234375,28.405975341796875,18.93756103515625,9.46856689453125,0 },
						 },
						 {
						  --lhand
						  path = "assets/idleGirls/black/lhand.png",
						  x = { 295.25,291.2,287.05,282.8,278.45,274.1,269.7,265.15,260.65,256.1,251.6,247.05,242.5,238,233.55,229.15,224.75,224.8,224.85,224.9,224.9,224.95,225,225,225.05,225.1,225.1,225.1,225.05,225.05,225,224.95,224.95,224.9,224.85,224.85,224.8,224.75,224.8,224.85,224.9,224.95,225,225.05,225.1,225.1,225.1,225.05,225.05,225,224.95,224.95,224.9,224.85,224.85,224.8,224.75,227.85,231.1,234.35,237.65,241,244.35,247.75,251.15,254.55,257.95,261.35,264.7,264.75,264.8,264.85,264.9,264.95,265,265.05,265.1,265.15,265.2,265.25,265.3,268.1,270.8,273.5,276.2,278.9,281.6,284.15,286.75,282.6,278.35,274.1,269.8,265.5,261.25,256.95,252.75,248.55,242.3,236,229.85,223.8,217.85,212.15,206.55,201.35,196.35,191.65,187.3,183.25,183.4,183.65,183.85,184.1,184.45,184.8,185.2,185.65,186.1,186.6,187.15,187.75,187.55,187.4,187.35,187.3,187.35,187.45,193.8,201.4,210.15,219.9,230.45,241.55,253.2,265.05,276.75,288.25,299.2 },
						  y = { 728.8,730.8,732.6,734.25,735.65,736.85,737.8,738.5,739.05,739.35,739.4,739.3,738.9,738.3,737.45,736.4,735.15,735.2,735.2,735.25,735.25,735.3,735.3,735.35,735.35,735.4,735.4,735.4,735.35,735.35,735.3,735.3,735.25,735.25,735.2,735.2,735.15,735.15,735.2,735.2,735.25,735.3,735.3,735.35,735.35,735.4,735.4,735.35,735.35,735.3,735.3,735.25,735.25,735.2,735.2,735.15,735.15,736.25,737.15,738,738.6,739.05,739.4,739.55,739.55,739.45,739.15,738.7,738.05,738.1,738.15,738.1,738.1,738.15,738.15,738.15,738.2,738.15,738.15,738.15,738.2,737.65,737.05,736.4,735.7,734.8,733.9,732.9,731.85,733.25,734.25,735.1,735.7,736.1,736.2,736.05,735.7,735.1,734.9,734.1,732.85,731.15,729.05,726.45,723.4,720,716.2,712,707.45,702.6,701.8,700.95,700.15,699.25,698.35,697.5,696.5,695.6,694.65,693.65,692.7,691.7,692.75,693.8,694.85,695.85,696.9,698,706.8,714.8,721.8,727.65,732.15,735.15,736.7,736.55,734.8,731.45,726.55 },
						  rotation = { 2.808502197265625,5.6183013916015625,8.42694091796875,11.235763549804688,14.046112060546875,16.854873657226563,19.663345336914063,22.47320556640625,25.283035278320313,28.092544555664063,30.9010009765625,33.70965576171875,36.51910400390625,39.32887268066406,42.13835144042969,44.94752502441406,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,44.79168701171875,41.82623291015625,38.86021423339844,35.89701843261719,32.931365966796875,29.966415405273438,27.000518798828125,24.036102294921875,21.07012939453125,18.10516357421875,15.140762329101563,12.175460815429688,12.487518310546875,12.802154541015625,13.11517333984375,13.427398681640625,13.741287231445313,14.05352783203125,14.36737060546875,14.680328369140625,14.993209838867188,15.305999755859375,15.619476318359375,15.932815551757813,14.208084106445313,12.483352661132813,10.758941650390625,9.034210205078125,7.3091583251953125,5.5854034423828125,3.860137939453125,2.1365814208984375,5.943695068359375,9.752426147460938,13.559661865234375,17.368362426757813,21.175872802734375,24.984237670898438,28.793487548828125,32.60002136230469,36.40827941894531,40.60838317871094,44.80754089355469,49.00685119628906,53.20689392089844,57.40618896484375,61.606201171875,65.80586242675781,70.0047607421875,74.20390319824219,78.40303039550781,82.60313415527344,86.80264282226563,88.300048828125,89.79542541503906,91.29194641113281,92.78669738769531,94.28376770019531,95.77931213378906,97.27647399902344,98.77395629882813,100.26960754394531,101.76632690429688,103.2626953125,104.75965881347656,101.10871887207031,97.45877075195313,93.80792236328125,90.15824890136719,86.50814819335938,82.85862731933594,75.32539367675781,67.79307556152344,60.260467529296875,52.72776794433594,45.19554138183594,37.662689208984375,30.129531860351563,22.597763061523438,15.064971923828125,7.5326690673828125,0 },
						 },
						 {
						  displayObject = girl1OpenEyes,
						  x = { 217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,215.7,214,212.3,210.65,208.95,207.25,205.6,203.85,202.2,200.55,198.85,197.2,198.3,199.4,200.55,201.6,202.7,203.85,204.95,206.1,207.2,208.3,209.4,210.55,210.55,210.55,210.55,210.55,210.55,210.55,210.55,210.6,210.55,210.55,210.55,210.55,210.55,210.55,210.55,210.55,210.55,211.2,211.85,212.5,213.15,213.75,214.5,215.15,215.8,216.45,217.1,217.8,218.45,218.2,217.95,217.7,217.45,217.2,216.95,216.7,216.45,216.2,215.95,215.7,215.5,215.6,215.7,215.85,215.95,216.05,216.2,216.35,216.45,216.55,216.65,216.75,216.85,216.95,217.05,217.15,217.25,217.4 },
						  y = { 490.55,490.55,490.55,490.55,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.55,490.6,490.65,490.7,490.8,490.9,491.05,491.15,491.3,491.5,491.6,491.8,491.65,491.55,491.4,491.3,491.2,491.1,491,490.95,490.85,490.8,490.8,490.7,490.7,490.65,490.65,490.65,490.65,490.65,490.65,490.65,490.65,490.65,490.6,490.6,490.6,490.6,490.6,490.6,490.6,490.55,490.55,490.5,490.5,490.5,490.45,490.45,490.45,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.35,490.35,490.3,490.3,490.25,490.2,490.25,490.3,490.3,490.35,490.35,490.4,490.4,490.45,490.45,490.5,490.55 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.58660888671875,-1.173095703125,-1.7602081298828125,-2.346954345703125,-2.9349517822265625,-3.520599365234375,-4.1081085205078125,-4.69561767578125,-5.2821502685546875,-5.8693084716796875,-6.456085205078125,-7.0432281494140625,-6.605377197265625,-6.1676025390625,-5.7291107177734375,-5.29168701171875,-4.8536376953125,-4.4150238037109375,-3.9776153564453125,-3.53887939453125,-3.10235595703125,-2.6637115478515625,-2.2256317138671875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.6143341064453125,-1.44049072265625,-1.2683563232421875,-1.0953216552734375,-0.92401123046875,-0.750946044921875,-0.5778656005859375,-0.4056549072265625,-0.2325592041015625,-0.0603179931640625,0.111907958984375,0.2841339111328125,0.22119140625,0.1573638916015625,0.0935516357421875,0.02972412109375,-0.0323486328125,-0.0961761474609375,-0.1599884033203125,-0.22381591796875,-0.2867584228515625,-0.3505706787109375,-0.414398193359375,-0.47821044921875,-0.44586181640625,-0.414398193359375,-0.382049560546875,-0.3505706787109375,-0.3182220458984375,-0.2867584228515625,-0.260528564453125,-0.2342987060546875,-0.20806884765625,-0.1818389892578125,-0.1556243896484375,-0.1302642822265625,-0.104034423828125,-0.0778045654296875,-0.05157470703125,-0.025360107421875,0 },
						  scaleComponent = true,
						 },
						 {
						  displayObject = girl1ClosedEyes,
						  x = { 217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,217.4,215.7,214,212.3,210.65,208.95,207.25,205.6,203.85,202.2,200.55,198.85,197.2,198.3,199.4,200.55,201.6,202.7,203.85,204.95,206.1,207.2,208.3,209.4,210.55,210.55,210.55,210.55,210.55,210.55,210.55,210.55,210.6,210.55,210.55,210.55,210.55,210.55,210.55,210.55,210.55,210.55,211.2,211.85,212.5,213.15,213.75,214.5,215.15,215.8,216.45,217.1,217.8,218.45,218.2,217.95,217.7,217.45,217.2,216.95,216.7,216.45,216.2,215.95,215.7,215.5,215.6,215.7,215.85,215.95,216.05,216.2,216.35,216.45,216.55,216.65,216.75,216.85,216.95,217.05,217.15,217.25,217.4 },
						  y = { 490.55,490.55,490.55,490.55,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.5,490.55,490.6,490.65,490.7,490.8,490.9,491.05,491.15,491.3,491.5,491.6,491.8,491.65,491.55,491.4,491.3,491.2,491.1,491,490.95,490.85,490.8,490.8,490.7,490.7,490.65,490.65,490.65,490.65,490.65,490.65,490.65,490.65,490.65,490.6,490.6,490.6,490.6,490.6,490.6,490.6,490.55,490.55,490.5,490.5,490.5,490.45,490.45,490.45,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.4,490.35,490.35,490.3,490.3,490.25,490.2,490.25,490.3,490.3,490.35,490.35,490.4,490.4,490.45,490.45,490.5,490.55 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.58660888671875,-1.173095703125,-1.7602081298828125,-2.346954345703125,-2.9349517822265625,-3.520599365234375,-4.1081085205078125,-4.69561767578125,-5.2821502685546875,-5.8693084716796875,-6.456085205078125,-7.0432281494140625,-6.605377197265625,-6.1676025390625,-5.7291107177734375,-5.29168701171875,-4.8536376953125,-4.4150238037109375,-3.9776153564453125,-3.53887939453125,-3.10235595703125,-2.6637115478515625,-2.2256317138671875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.78729248046875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.7864227294921875,-1.6143341064453125,-1.44049072265625,-1.2683563232421875,-1.0953216552734375,-0.92401123046875,-0.750946044921875,-0.5778656005859375,-0.4056549072265625,-0.2325592041015625,-0.0603179931640625,0.111907958984375,0.2841339111328125,0.22119140625,0.1573638916015625,0.0935516357421875,0.02972412109375,-0.0323486328125,-0.0961761474609375,-0.1599884033203125,-0.22381591796875,-0.2867584228515625,-0.3505706787109375,-0.414398193359375,-0.47821044921875,-0.44586181640625,-0.414398193359375,-0.382049560546875,-0.3505706787109375,-0.3182220458984375,-0.2867584228515625,-0.260528564453125,-0.2342987060546875,-0.20806884765625,-0.1818389892578125,-0.1556243896484375,-0.1302642822265625,-0.104034423828125,-0.0778045654296875,-0.05157470703125,-0.025360107421875,0 },
						  scaleComponent = true,
						 },
						 {
						  --lelbow
						  path = "assets/idleGirls/black/elbowmask.png",
						  x = { 282.65,281.05,279.35,277.6,275.8,273.9,271.95,270,268,265.9,263.85,261.75,259.6,257.4,255.2,253.05,250.8,250.8,250.8,250.8,250.8,250.8,250.75,250.75,250.75,250.75,250.7,250.75,250.75,250.75,250.75,250.8,250.8,250.8,250.8,250.8,250.8,250.8,250.8,250.8,250.8,250.8,250.75,250.75,250.75,250.7,250.75,250.75,250.75,250.75,250.8,250.8,250.8,250.8,250.8,250.8,250.8,251.8,252.75,253.7,254.6,255.6,256.5,257.4,258.3,259.2,260,260.9,261.7,261.95,262.3,262.55,262.8,263.05,263.4,263.6,263.9,264.2,264.45,264.75,265,266.25,267.45,268.6,269.75,270.95,272.05,273.15,274.25,273.25,272.3,271.3,270.3,269.25,268.25,267.2,266.2,265.1,262.2,259.45,256.5,253.55,250.6,247.6,244.7,241.85,238.9,236.2,233.55,230.9,231.4,231.85,232.3,232.75,233.2,233.65,234,234.5,234.95,235.4,235.85,236.25,236.3,236.3,236.35,236.4,236.45,236.55,241.1,245.8,250.6,255.3,260.05,264.6,269.05,273.2,277.15,280.85,284.2 },
						  y = { 679.85,681.2,682.65,683.95,685.1,686.3,687.4,688.35,689.2,689.9,690.5,691.05,691.55,691.8,692,692.1,692.2,692.15,692.1,692.05,692.05,692,692,691.95,691.95,691.9,691.9,691.9,691.9,691.95,691.95,692,692,692.05,692.1,692.1,692.15,692.2,692.15,692.1,692.05,692,691.95,691.95,691.9,691.9,691.9,691.9,691.95,691.95,692,692,692.05,692.1,692.1,692.15,692.2,691.95,691.65,691.4,691.15,690.75,690.4,689.9,689.5,688.95,688.5,687.95,687.45,687.35,687.35,687.3,687.25,687.25,687.2,687.2,687.15,687.1,687.1,687.05,687.05,686.55,686.05,685.55,684.9,684.35,683.7,683,682.25,682.9,683.5,684.1,684.65,685.2,685.7,686.1,686.6,687,688.1,688.85,689.6,689.9,690.05,690,689.7,689.1,688.35,687.4,686.2,684.8,685.3,685.8,686.3,686.7,687.2,687.6,688,688.35,688.75,689.1,689.4,689.7,689.75,689.75,689.75,689.7,689.65,689.6,690.95,691.8,692.2,692.05,691.4,690.25,688.65,686.65,684.2,681.4,678.25 },
						  rotation = { 2.808502197265625,5.6183013916015625,8.42694091796875,11.235763549804688,14.0452880859375,16.854873657226563,19.66412353515625,22.47320556640625,25.282318115234375,28.092544555664063,30.900360107421875,33.71026611328125,36.51910400390625,39.32887268066406,42.13835144042969,44.94752502441406,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,44.79168701171875,41.82623291015625,38.86073303222656,35.896453857421875,32.931365966796875,29.96575927734375,26.999130249023438,24.035369873046875,21.070892333984375,18.10516357421875,15.140762329101563,12.176284790039063,12.48834228515625,12.801315307617188,13.11517333984375,13.427398681640625,13.739639282226563,14.05352783203125,14.366546630859375,14.678695678710938,14.9915771484375,15.305999755859375,15.61785888671875,15.931198120117188,14.207260131835938,12.481689453125,10.75726318359375,9.033355712890625,7.30828857421875,5.5836639404296875,3.8592681884765625,2.1348419189453125,5.94195556640625,9.750732421875,13.558013916015625,17.36676025390625,21.172073364257813,24.982086181640625,28.790130615234375,32.5975341796875,36.40545654296875,40.60536193847656,44.80445861816406,49.00386047363281,53.203521728515625,57.40370178222656,61.602813720703125,65.80221557617188,70.00166320800781,74.20228576660156,78.40135192871094,82.60055541992188,86.80003356933594,88.29743957519531,89.79367065429688,91.28932189941406,92.78495788574219,94.28202819824219,95.7784423828125,97.27474975585938,98.77224731445313,100.26791381835938,101.76466369628906,103.26103210449219,104.7572021484375,104.65496826171875,104.55426025390625,104.45265197753906,104.35177612304688,104.24916076660156,104.14891052246094,94.67999267578125,85.21321105957031,75.7442626953125,66.27676391601563,56.80827331542969,47.34002685546875,37.872467041015625,28.403274536132813,18.935211181640625,9.46771240234375,0 },
						 },
						 {
						  --lwrist
						  path = "assets/idleGirls/black/wristmask.png",
						  x = { 293.75,290.45,287.15,283.65,280.15,276.65,273.05,269.35,265.6,261.85,258,254.35,250.55,246.75,243,239.25,235.5,235.55,235.55,235.55,235.55,235.55,235.55,235.55,235.55,235.55,235.5,235.55,235.55,235.55,235.55,235.55,235.55,235.55,235.55,235.55,235.55,235.5,235.55,235.55,235.55,235.55,235.55,235.55,235.55,235.5,235.55,235.55,235.55,235.55,235.55,235.55,235.55,235.55,235.55,235.55,235.5,238,240.55,243.05,245.55,248.15,250.65,253.25,255.8,258.35,260.9,263.4,265.85,265.95,266.1,266.25,266.45,266.55,266.65,266.8,266.95,267.1,267.2,267.4,267.5,269.7,272,274.2,276.35,278.55,280.7,282.75,284.85,281.8,278.65,275.55,272.4,269.3,266.1,263,259.8,256.75,251.6,246.4,241.2,236.05,230.95,226.05,221.25,216.65,212.2,208,203.95,200.25,200.5,200.75,201.1,201.4,201.75,202.05,202.55,202.9,203.35,203.8,204.25,204.75,204.75,204.7,204.7,204.65,204.6,204.6,210.3,216.9,224.3,232.55,241.2,250.5,260,269.5,278.95,288.1,296.9 },
						  y = { 712.55,714.5,716.3,717.85,719.3,720.65,721.7,722.7,723.4,723.95,724.25,724.5,724.5,724.3,723.95,723.45,722.75,722.7,722.7,722.7,722.7,722.75,722.75,722.75,722.75,722.75,722.8,722.75,722.75,722.75,722.75,722.75,722.75,722.7,722.7,722.7,722.7,722.75,722.7,722.7,722.7,722.75,722.75,722.75,722.75,722.8,722.75,722.75,722.75,722.75,722.75,722.75,722.7,722.7,722.7,722.7,722.75,723.1,723.55,723.8,723.95,724,723.95,723.75,723.45,723,722.5,721.9,721.15,721.2,721.25,721.25,721.35,721.3,721.4,721.45,721.4,721.45,721.5,721.5,721.55,720.95,720.35,719.65,718.95,718.05,717.2,716.25,715.2,716.35,717.45,718.3,718.85,719.45,719.8,719.95,719.95,719.9,720.25,720.25,719.8,718.9,717.75,716.15,714.15,711.9,709.25,706.25,702.95,699.35,698.95,698.6,698.2,697.8,697.35,696.95,696.4,695.95,695.5,694.95,694.45,693.9,694.05,694.2,694.3,694.45,694.55,694.6,701.15,707.1,712.05,716,718.95,720.7,721.2,720.4,718.3,714.95,710.4 },
						  rotation = { 2.808502197265625,5.6183013916015625,8.42694091796875,11.235763549804688,14.046112060546875,16.854873657226563,19.66412353515625,22.47320556640625,25.282318115234375,28.091873168945313,30.9010009765625,33.71026611328125,36.51966857910156,39.32835388183594,42.13835144042969,44.94752502441406,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75605773925781,47.75701904296875,47.75701904296875,47.75701904296875,47.75701904296875,44.79168701171875,41.82623291015625,38.86126708984375,35.8958740234375,32.931365966796875,29.96575927734375,27.000518798828125,24.034637451171875,21.069366455078125,18.1043701171875,15.13995361328125,12.17462158203125,12.487518310546875,12.800491333007813,13.112686157226563,13.42657470703125,13.739639282226563,14.052703857421875,14.364898681640625,14.677871704101563,14.9915771484375,15.305191040039063,15.61785888671875,15.930389404296875,14.20562744140625,12.480850219726563,10.75640869140625,9.032501220703125,7.30657958984375,5.581939697265625,3.8575286865234375,2.133087158203125,5.94195556640625,9.7498779296875,13.558837890625,17.36676025390625,21.1766357421875,24.984237670898438,28.792816162109375,32.60188293457031,36.40998840332031,40.609893798828125,44.81016540527344,49.00984191894531,53.20857238769531,57.40867614746094,61.60890197753906,65.80804443359375,70.00706481933594,74.20794677734375,78.4072265625,82.6065673828125,86.80612182617188,88.30267333984375,89.79891967773438,91.29457092285156,92.79106140136719,94.28811645507813,95.78450012207031,97.28077697753906,98.77735900878906,100.27299499511719,101.76968383789063,103.26600646972656,104.76292419433594,101.11207580566406,97.46134948730469,93.80966186523438,90.15998840332031,86.5098876953125,82.8594970703125,75.32621765136719,67.79457092285156,60.260467529296875,52.72831726074219,45.19554138183594,37.662689208984375,30.13018798828125,22.597015380859375,15.0657958984375,7.5326690673828125,0 },
						 },
						 {
						  --relbow
						  path = "assets/idleGirls/black/elbowmask.png",
						  x = { 151.05,152.7,154.4,156.25,158.1,160.05,162.05,164.1,166.2,168.3,170.5,172.65,174.95,177.2,179.5,181.75,184,184.1,184.15,184.2,184.25,184.3,184.35,184.4,184.45,184.5,184.55,184.5,184.4,184.35,184.35,184.3,184.2,184.2,184.1,184.1,184.05,184,184.1,184.15,184.25,184.3,184.35,184.4,184.45,184.55,184.5,184.4,184.35,184.35,184.3,184.2,184.2,184.1,184.1,184.05,184,182.85,181.65,180.45,179.2,178.05,176.85,175.65,174.4,173.2,172.1,171,169.95,169.65,169.35,169.05,168.7,168.45,168.15,167.85,167.55,167.25,166.95,166.7,166.4,165.1,163.8,162.5,161.3,160.1,158.9,157.75,156.55,157.65,158.7,159.75,160.9,162.05,163.15,164.2,165.45,166.6,166.6,166.7,166.7,166.8,166.85,166.9,167,167.05,167.1,167.15,167.2,167.25,167.25,167.2,167.2,167.15,167.05,167.05,167.05,167,166.95,166.95,166.9,166.9,166.7,166.45,166.35,166.15,165.95,165.75,164.15,162.45,160.9,159.35,157.75,156.3,154.85,153.45,152.05,150.75,149.5 },
						  y = { 679.15,680.6,682.05,683.4,684.55,685.75,686.8,687.8,688.55,689.3,689.95,690.45,690.85,691.15,691.3,691.35,691.25,691.4,691.45,691.6,691.75,691.8,691.9,692.05,692.2,692.3,692.4,692.3,692.2,692.1,691.9,691.9,691.75,691.65,691.6,691.5,691.35,691.25,691.45,691.55,691.65,691.8,691.95,692.1,692.3,692.4,692.3,692.2,692.1,691.9,691.9,691.75,691.65,691.6,691.5,691.35,691.25,691.4,691.5,691.6,691.65,691.7,691.75,691.8,691.75,691.8,691.75,691.75,691.75,691.55,691.45,691.3,691.15,691,690.85,690.65,690.5,690.3,690.2,690.05,689.9,689.4,689,688.5,687.95,687.35,686.8,686.15,685.45,686,686.65,687.05,687.55,688,688.4,688.8,689.1,689.45,689.2,689.15,688.95,688.8,688.65,688.45,688.35,688.15,688,687.85,687.7,687.55,687.6,687.65,687.65,687.75,687.85,687.85,687.9,687.95,688,688.05,688.1,688.2,688.15,688.15,688.1,688.1,688.05,688,687.4,686.7,685.9,685.1,684.2,683.25,682.15,681.15,680,678.8,677.6 },
						  rotation = { -4.94476318359375,-9.890777587890625,-14.835662841796875,-19.781097412109375,-24.726547241210938,-29.672256469726563,-34.61820983886719,-39.562957763671875,-44.509033203125,-49.453643798828125,-54.400115966796875,-59.34552001953125,-64.29031372070313,-69.23652648925781,-74.18205261230469,-79.12718200683594,-84.07188415527344,-84.95372009277344,-85.83622741699219,-86.71636962890625,-87.59805297851563,-88.48001098632813,-89.36094665527344,-90.24130249023438,-91.12240600585938,-92.00387573242188,-92.88525390625,-92.08419799804688,-91.283203125,-90.48170471191406,-89.68089294433594,-88.88020324707031,-88.07908630371094,-87.27784729003906,-86.47679138183594,-85.67538452148438,-84.87391662597656,-84.07188415527344,-85.17413330078125,-86.27565002441406,-87.37815856933594,-88.48001098632813,-89.58123779296875,-90.68190002441406,-91.78379821777344,-92.88525390625,-92.08419799804688,-91.283203125,-90.48170471191406,-89.68089294433594,-88.88020324707031,-88.07908630371094,-87.27784729003906,-86.47679138183594,-85.67538452148438,-84.87391662597656,-84.07188415527344,-78.84751892089844,-73.62277221679688,-68.39814758300781,-63.17326354980469,-57.948089599609375,-52.72444152832031,-47.49884033203125,-42.27363586425781,-37.04902648925781,-31.824630737304688,-26.599319458007813,-21.374771118164063,-21.09906005859375,-20.821548461914063,-20.544540405273438,-20.26806640625,-19.991378784179688,-19.713729858398438,-19.437423706054688,-19.160964965820313,-18.884353637695313,-18.607620239257813,-18.33154296875,-18.054595947265625,-16.279815673828125,-14.505111694335938,-12.730636596679688,-10.956268310546875,-9.182525634765625,-7.4071807861328125,-5.633026123046875,-3.8583984375,-7.614288330078125,-11.370285034179688,-15.1260986328125,-18.8812255859375,-22.636489868164063,-26.3934326171875,-30.149139404296875,-33.904022216796875,-37.65940856933594,-37.486968994140625,-37.31373596191406,-37.14190673828125,-36.96986389160156,-36.796478271484375,-36.623992919921875,-36.4512939453125,-36.27839660644531,-36.105865478515625,-35.9337158203125,-35.76081848144531,-35.58717346191406,-35.650726318359375,-35.71473693847656,-35.77809143066406,-35.84190368652344,-35.90504455566406,-35.96923828125,-36.0333251953125,-36.094451904296875,-36.158905029296875,-36.22267150878906,-36.28578186035156,-36.34991455078125,-35.55419921875,-34.75889587402344,-33.9617919921875,-33.16661071777344,-32.37046813964844,-31.575271606445313,-28.7041015625,-25.833755493164063,-22.963409423828125,-20.09246826171875,-17.222503662109375,-14.35260009765625,-11.48199462890625,-8.61077880859375,-5.7403717041015625,-2.8695526123046875,0 },
						 },
						 {
						  --rwrist
						  path = "assets/idleGirls/black/wristmask.png",
						  x = { 140.25,144.8,149.5,154.25,159.1,164,168.95,173.9,178.8,183.65,188.35,193,197.55,201.9,206.15,210.15,213.9,214.1,214.35,214.6,214.8,215.05,215.3,215.55,215.85,216.1,216.4,216.15,215.9,215.65,215.4,215.1,214.9,214.75,214.6,214.35,214.1,213.9,214.25,214.55,214.75,215.05,215.4,215.75,216.1,216.4,216.15,215.9,215.65,215.4,215.1,214.9,214.75,214.6,214.35,214.1,213.9,211.1,208.1,204.95,201.6,198,194.25,190.55,186.6,182.6,178.5,174.45,170.35,169.75,169.2,168.6,168,167.45,166.9,166.4,165.8,165.3,164.8,164.25,163.8,161.4,159.05,156.7,154.4,152.1,149.8,147.55,145.35,148.55,151.75,155.05,158.4,161.65,165,168.3,171.6,174.85,174.8,174.75,174.7,174.65,174.6,174.6,174.55,174.5,174.45,174.45,174.35,174.35,174.35,174.35,174.4,174.35,174.35,174.35,174.4,174.35,174.35,174.4,174.35,174.4,173.8,173.2,172.6,172,171.4,170.75,167.4,164.1,160.75,157.5,154.25,151.05,147.9,144.8,141.75,138.8,135.9 },
						  y = { 712.55,714.8,716.75,718.25,719.5,720.35,720.85,721.05,720.85,720.4,719.5,718.3,716.8,715,712.85,710.45,707.8,707.45,707.05,706.6,706.15,705.65,705.1,704.55,704.1,703.7,703.25,703.65,704.05,704.45,704.9,705.4,705.9,706.35,706.75,707.1,707.45,707.8,707.35,706.8,706.3,705.65,704.9,704.35,703.8,703.25,703.65,704.05,704.45,704.9,705.4,705.9,706.35,706.75,707.1,707.45,707.8,710.65,713.3,715.75,717.9,719.85,721.6,723.1,724.3,725.25,725.95,726.35,726.45,726.4,726.2,726.15,726.05,725.95,725.85,725.8,725.7,725.6,725.5,725.4,725.25,724.75,724.2,723.5,722.8,722,721.15,720.2,719.25,720.35,721.25,721.9,722.45,722.9,723.15,723.2,723.05,722.75,722.65,722.5,722.35,722.2,722.05,721.9,721.85,721.65,721.55,721.4,721.25,721.15,721.15,721.15,721.2,721.25,721.35,721.4,721.4,721.45,721.55,721.55,721.6,721.65,721.8,721.85,721.95,722,722.1,722.15,721.85,721.3,720.6,719.75,718.8,717.75,716.4,715,713.5,711.8,710 },
						  rotation = { -4.94476318359375,-9.889938354492188,-14.8348388671875,-19.779556274414063,-24.725112915039063,-29.66961669921875,-34.6158447265625,-39.55931091308594,-44.50457763671875,-49.449615478515625,-54.39433288574219,-59.33905029296875,-64.28463745117188,-69.22964477539063,-74.17475891113281,-79.11959838867188,-84.0640869140625,-85.87884521484375,-87.69406127929688,-89.50868225097656,-91.32252502441406,-93.1363525390625,-94.95170593261719,-96.76577758789063,-98.58085632324219,-100.39483642578125,-102.20970153808594,-100.56053161621094,-98.911376953125,-97.260986328125,-95.61137390136719,-93.96195983886719,-92.31204223632813,-90.66265869140625,-89.01393127441406,-87.36421203613281,-85.71536254882813,-84.0640869140625,-86.33309936523438,-88.6005859375,-90.86895751953125,-93.1363525390625,-95.40435791015625,-97.67440795898438,-99.94253540039063,-102.21054077148438,-100.56053161621094,-98.911376953125,-97.260986328125,-95.61137390136719,-93.96195983886719,-92.31204223632813,-90.66265869140625,-89.01393127441406,-87.36421203613281,-85.71536254882813,-84.0640869140625,-78.839111328125,-73.61552429199219,-68.38983154296875,-63.165618896484375,-57.939300537109375,-52.71504211425781,-47.48933410644531,-42.2655029296875,-37.03955078125,-31.815780639648438,-26.590225219726563,-21.365676879882813,-21.088394165039063,-20.8123779296875,-20.53533935546875,-20.258071899414063,-19.982894897460938,-19.705978393554688,-19.429656982421875,-19.153167724609375,-18.87652587890625,-18.600540161132813,-18.32366943359375,-18.0474853515625,-16.273361206054688,-14.498550415039063,-12.723983764648438,-10.950363159179688,-9.174850463867188,-7.4011688232421875,-5.6269683837890625,-3.8523101806640625,-7.609130859375,-11.364395141601563,-15.1187744140625,-18.874969482421875,-22.630538940429688,-26.386428833007813,-30.142608642578125,-33.89678955078125,-37.65283203125,-37.47981262207031,-37.307098388671875,-37.134124755859375,-36.96148681640625,-36.78863525390625,-36.61723327636719,-36.44281005859375,-36.271575927734375,-36.09901428222656,-35.925689697265625,-35.75334167480469,-35.580810546875,-35.64436340332031,-35.70782470703125,-35.77117919921875,-35.83500671386719,-35.89759826660156,-35.9617919921875,-36.02531433105469,-36.0887451171875,-36.15205383300781,-36.215850830078125,-36.278961181640625,-36.343109130859375,-35.54667663574219,-34.751220703125,-33.955780029296875,-33.159881591796875,-32.364227294921875,-31.568923950195313,-28.69805908203125,-25.828811645507813,-22.958221435546875,-20.089385986328125,-17.219314575195313,-14.349319458007813,-11.4786376953125,-8.60906982421875,-5.739501953125,-2.87042236328125,0 },
						 },
						},
						 x = 75,
						 y = -110,
						 scale = 1/2.5,
						 speed = 0.5
						}
		girl1Animation.hide()
		
		local girl2OpenEyes = display.newImage("assets/idleGirls/blue/eyesOpen.png")
		local girl2ClosedEyes = display.newImage("assets/idleGirls/blue/eyesClosed.png")
		
		local girl2Blinks = ui.blink(girl2OpenEyes,girl2ClosedEyes)
		
		local girl2Animation = ui.newAnimation{
						 comps = {
						 {
						  --rhip
						  path = "assets/idleGirls/blue/rhip.png",
						  x = { 503.4,503.4,503.4,503.4,503.4,503.35,503.35,503.35,503.35,503.35,503.35,503.3,503.3,503.3,503.3,503.3,503.3,503.2,503.1,503,502.95,502.85,502.75,502.7,502.5,502.3,502.1,501.9,501.75,501.9,502.1,502.25,502.45,502.65,502.8,503,503.2,503.2,503.2,503.25,503.25,503.3,503.3,503.3,503.3,503.3,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,503.35,502.95,502.6,502.2,501.85,501.5,501.45,501.45,501.5,501.5,501.45,501.45,501.45,501.55,501.5,501.6,501.6,501.6,501.6,501.6,501.6,501.65,501.65,501.7,501.65,501.65,501.65,501.65,501.65,501.65,501.65,501.65,501.65,501.7,501.7,501.75,501.7,501.7,501.7,501.65,501.65,501.65,501.65,501.65,501.65,501.65,501.65,501.65,501.8,502.05,502.15,502.35,502.55,502.6,502.7,502.8,502.95,503.05,503.2,503.35 },
						  y = { 622.15,621.8,621.4,621.05,620.7,620.3,619.95,619.6,619.2,618.85,618.5,618.1,617.75,617.4,617,616.65,616.3,616.4,616.5,616.6,616.7,616.8,616.9,617.05,617.05,617.1,617.15,617.2,617.25,617.45,617.7,617.95,618.2,618.4,618.65,618.9,619.15,619.75,620.4,621,621.65,622.3,622.3,622.3,622.3,622.3,622.35,622.35,622.35,622.35,622.35,622.4,622.4,622.4,622.4,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.45,622.2,621.9,621.6,621.35,621,620.95,621.05,621,621.05,621.05,621,621.05,620.95,620.95,621,621,620.9,620.95,620.95,620.9,620.9,620.95,620.95,621,621,621,621,621,621,621,621,621,621,621,620.95,621,621,621,621,621,621,621,621.05,621.05,621.05,621.05,621.05,621.2,621.35,621.45,621.6,621.7,621.85,621.9,621.95,622.05,622.2,622.35,622.45 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0008697509765625,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.8261260986328125,1.65277099609375,2.4787445068359375,3.3062896728515625,4.131591796875,4.0289459228515625,3.9254150390625,3.8218536376953125,3.7191314697265625,3.6155242919921875,3.5136260986328125,3.40997314453125,3.2653350830078125,3.12152099609375,2.976806640625,2.8311767578125,2.6863861083984375,2.5424346923828125,2.3975830078125,2.253570556640625,2.109527587890625,1.9654541015625,1.8204803466796875,1.8204803466796875,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.8222198486328125,1.82135009765625,1.82135009765625,1.8204803466796875,1.8204803466796875,1.8204803466796875,1.6379241943359375,1.456207275390625,1.273590087890625,1.0909423828125,0.9091644287109375,0.799896240234375,0.6923828125,0.582244873046875,0.47296142578125,0.36456298828125,0.1818389892578125,0 },
						 },
						 {
						  --rknee
						  path = "assets/idleGirls/blue/rknee.png",
						  x = { 506.35,506.35,506.35,506.35,506.3,506.3,506.3,506.3,506.25,506.25,506.25,506.25,506.2,506.2,506.2,506.2,506.2,506.1,506,505.95,505.85,505.8,505.7,505.65,505.45,505.25,505.05,504.85,504.7,504.85,505.05,505.2,505.4,505.6,505.75,505.95,506.15,506.15,506.15,506.2,506.2,506.25,506.25,506.25,506.25,506.25,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,506.3,505.2,504.05,502.9,501.75,500.65,500.75,500.85,500.95,501.1,501.15,501.25,501.35,501.5,501.6,501.75,501.9,502.05,502.15,502.3,502.4,502.55,502.7,502.8,502.8,502.85,502.85,502.85,502.85,502.9,502.9,502.85,502.85,502.8,502.8,502.75,502.75,502.75,502.75,502.7,502.7,502.7,502.7,502.7,502.75,502.75,502.8,502.8,503.15,503.5,503.85,504.15,504.5,504.75,504.95,505.2,505.5,505.6,505.9,506.3 },
						  y = { 674.6,674.2,673.85,673.5,673.1,672.75,672.35,672,671.65,671.25,670.9,670.5,670.15,669.8,669.4,669.05,668.65,668.8,668.9,669,669.1,669.2,669.3,669.4,669.5,669.55,669.6,669.65,669.7,669.95,670.15,670.4,670.65,670.85,671.1,671.3,671.5,672.15,672.8,673.5,674.1,674.75,674.8,674.8,674.8,674.8,674.85,674.85,674.85,674.85,674.85,674.85,674.85,674.85,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.9,674.65,674.35,674.15,673.8,673.5,673.45,673.5,673.5,673.45,673.5,673.45,673.45,673.45,673.45,673.45,673.4,673.4,673.4,673.4,673.35,673.4,673.4,673.35,673.35,673.35,673.35,673.35,673.35,673.35,673.3,673.3,673.3,673.3,673.3,673.25,673.25,673.25,673.25,673.25,673.25,673.25,673.2,673.25,673.25,673.3,673.3,673.3,673.4,673.6,673.75,673.95,674.1,674.2,674.3,674.35,674.4,674.5,674.65,674.9 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.8261260986328125,1.65277099609375,2.4804840087890625,3.3062896728515625,4.133331298828125,4.029815673828125,3.9262847900390625,3.8235931396484375,3.720001220703125,3.6172637939453125,3.5136260986328125,3.40997314453125,3.26446533203125,3.119781494140625,2.975067138671875,2.8311767578125,2.6872711181640625,2.5424346923828125,2.3984527587890625,2.252685546875,2.108642578125,1.9636993408203125,1.819610595703125,1.819610595703125,1.819610595703125,1.819610595703125,1.819610595703125,1.8204803466796875,1.8204803466796875,1.8204803466796875,1.8204803466796875,1.8204803466796875,1.8204803466796875,1.8204803466796875,1.8204803466796875,1.8204803466796875,1.8204803466796875,1.8204803466796875,1.819610595703125,1.819610595703125,1.819610595703125,1.819610595703125,1.819610595703125,1.819610595703125,1.819610595703125,1.819610595703125,1.819610595703125,1.6379241943359375,1.4553375244140625,1.273590087890625,1.0909423828125,0.9082794189453125,0.799896240234375,0.6906280517578125,0.58135986328125,0.47296142578125,0.3636932373046875,0.1818389892578125,0 },
						 },
						 {
						  --rfoot
						  path = "assets/idleGirls/blue/rfoot.png",
						  x = { 501.4,501.55,501.65,501.9,502,502.2,502.4,502.55,502.75,502.95,503.2,503.45,503.6,503.85,504.1,504.3,504.6,504.5,504.35,504.15,504.15,504.05,503.9,503.85,503.7,503.65,503.5,503.5,503.35,503.45,503.6,503.7,503.8,504,504.15,504.2,504.3,503.4,502.7,502.1,501.6,501.25,501.25,501.25,501.2,501.2,501.15,501.15,501.15,501.15,501.15,501.15,501.15,501.15,501.15,501.15,501.15,501.15,501.15,501.15,501.25,501.3,501.45,501.55,501.6,501.7,501.75,501.5,501.3,501.15,501,500.65,500.75,500.8,500.9,500.9,501,501,501.1,501.15,499.45,497.85,496.15,494.45,492.85,492.95,493.1,493.25,493.5,493.6,493.75,493.95,494.2,494.4,494.65,494.95,495.2,495.35,495.6,495.85,496.05,496.35,496.6,496.6,496.6,496.6,496.6,496.6,496.6,496.6,496.6,496.65,496.65,496.7,496.75,496.75,496.75,496.75,496.75,496.75,496.75,496.75,496.7,496.65,496.65,496.6,496.6,497.05,497.55,497.95,498.45,499,499.2,499.45,499.75,500.05,500.35,500.8,501.25 },
						  y = { 711.85,711.7,711.6,711.45,711.3,711.2,711.05,710.9,710.8,710.55,710.45,710.35,710.25,710.15,709.95,709.85,709.75,709.75,709.7,709.75,709.7,709.75,709.75,709.75,709.65,709.7,709.6,709.6,709.55,709.65,709.85,709.9,710.1,710.2,710.35,710.4,710.6,710.8,711.1,711.25,711.6,711.9,711.95,711.95,711.95,711.95,712,711.95,711.95,711.95,711.95,711.95,711.95,711.95,711.95,711.95,711.95,711.95,711.95,711.95,711.75,711.55,711.3,711.2,711,710.8,710.65,711.05,711.45,711.85,712.2,712.75,712.65,712.55,712.45,712.35,712.25,712.15,712,711.95,711.55,711.25,710.9,710.5,710.05,710.1,710.1,710.15,710.15,710.15,710.2,710.2,710.25,710.25,710.25,710.2,710.25,710.3,710.25,710.35,710.35,710.4,710.4,710.4,710.4,710.4,710.4,710.4,710.4,710.35,710.4,710.4,710.4,710.4,710.4,710.4,710.4,710.4,710.4,710.4,710.4,710.35,710.35,710.35,710.35,710.35,710.35,710.5,710.7,710.8,710.95,711.1,711.15,711.35,711.45,711.5,711.6,711.75,712 },
						  rotation = { -1.235137939453125,-2.469146728515625,-3.7043304443359375,-4.938690185546875,-6.1745147705078125,-7.408050537109375,-8.64324951171875,-9.8780517578125,-11.11376953125,-12.3482666015625,-13.582794189453125,-14.81768798828125,-16.052383422851563,-17.287887573242188,-18.52197265625,-19.757095336914063,-20.991683959960938,-21.245773315429688,-21.498992919921875,-21.752853393554688,-22.006561279296875,-22.260116577148438,-22.514251708984375,-22.7681884765625,-23.332977294921875,-23.89813232421875,-24.46417236328125,-25.02947998046875,-25.595306396484375,-26.366073608398438,-27.1370849609375,-27.90716552734375,-28.677200317382813,-29.44866943359375,-30.219039916992188,-30.98974609375,-31.76019287109375,-25.408706665039063,-19.056365966796875,-12.704849243164063,-6.3516082763671875,-0.0008697509765625,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.944122314453125,1.8885955810546875,2.83380126953125,3.779205322265625,4.7225494384765625,5.66851806640625,6.613128662109375,4.388946533203125,2.16278076171875,-0.0594482421875,-2.28411865234375,-4.5088653564453125,-3.944549560546875,-3.3820953369140625,-2.8180999755859375,-2.2544403076171875,-1.690338134765625,-1.127655029296875,-0.5630035400390625,0,0.8261260986328125,1.65277099609375,2.4796142578125,3.3062896728515625,4.1324615478515625,4.0289459228515625,3.9262847900390625,3.822723388671875,3.720001220703125,3.6172637939453125,3.5136260986328125,3.40997314453125,3.266204833984375,3.12152099609375,2.976806640625,2.8329315185546875,2.6890106201171875,2.543304443359375,2.3984527587890625,2.2544403076171875,2.109527587890625,1.9663238525390625,1.8204803466796875,1.8204803466796875,1.8204803466796875,1.8204803466796875,1.8204803466796875,1.8204803466796875,1.8204803466796875,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.8204803466796875,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.82135009765625,1.639678955078125,1.4570770263671875,1.2753448486328125,1.094451904296875,0.911773681640625,0.8016510009765625,0.6923828125,0.5831146240234375,0.473846435546875,0.36456298828125,0.1827239990234375,0.0008697509765625 },
						 },
						 {
						  --lhip
						  path = "assets/idleGirls/blue/lhip.png",
						  x = { 538.4,538.4,538.4,538.4,538.4,538.4,538.4,538.4,538.4,538.4,538.4,538.4,538.4,538.4,538.4,538.4,538.35,538.3,538.2,538.1,538.05,537.95,537.85,537.8,537.6,537.45,537.25,537.1,536.95,537.1,537.25,537.45,537.6,537.75,537.95,538.1,538.3,538.3,538.35,538.35,538.4,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.1,537.75,537.5,537.1,536.9,536.9,536.9,536.9,536.9,536.9,536.9,536.9,536.85,536.85,536.8,536.8,536.8,536.8,536.8,536.8,536.8,536.8,536.85,536.85,536.85,536.85,536.85,536.85,536.85,536.85,536.8,536.8,536.75,536.75,536.75,536.7,536.7,536.7,536.7,536.7,536.7,536.7,536.7,536.7,536.75,536.75,536.8,536.95,537.05,537.25,537.4,537.55,537.7,537.75,537.9,538,538.1,538.15,538.45 },
						  y = { 621.85,621.5,621.15,620.8,620.45,620.05,619.7,619.35,619,618.65,618.3,617.9,617.55,617.2,616.85,616.5,616.15,616.2,616.3,616.4,616.45,616.55,616.65,616.75,616.8,616.85,616.9,616.95,617.05,617.25,617.5,617.7,617.95,618.15,618.4,618.6,618.85,619.5,620.15,620.8,621.45,622.1,622.1,622.1,622.1,622.1,622.15,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.1,622.3,622.6,622.85,623,623.25,623.25,623.25,623.25,623.25,623.25,623.25,623.2,623.2,623.2,623.2,623.2,623.15,623.15,623.1,623.1,623.05,623.05,623,623,623,623,623,623,623,623,623,623,623,623,623,623,623,623,623,623,623,623,623,623,623,623,623,622.9,622.8,622.75,622.65,622.55,622.55,622.5,622.45,622.4,622.25,622.25,622.15 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.0008697509765625,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.4991912841796875,-0.9983062744140625,-1.4972686767578125,-1.99688720703125,-2.4953155517578125,-2.4953155517578125,-2.4953155517578125,-2.496185302734375,-2.496185302734375,-2.496185302734375,-2.4970703125,-2.4970703125,-2.4970703125,-2.4970703125,-2.4979400634765625,-2.4979400634765625,-2.4979400634765625,-2.4979400634765625,-2.4979400634765625,-2.4979400634765625,-2.498809814453125,-2.498809814453125,-2.498809814453125,-2.498809814453125,-2.498809814453125,-2.498809814453125,-2.498809814453125,-2.4996795654296875,-2.4996795654296875,-2.4996795654296875,-2.4996795654296875,-2.50054931640625,-2.50054931640625,-2.50054931640625,-2.501434326171875,-2.501434326171875,-2.501434326171875,-2.501434326171875,-2.501434326171875,-2.501434326171875,-2.501434326171875,-2.501434326171875,-2.501434326171875,-2.50054931640625,-2.50054931640625,-2.50054931640625,-2.50054931640625,-2.250946044921875,-2.0021209716796875,-1.7514801025390625,-1.50164794921875,-1.2508697509765625,-1.1014404296875,-0.95111083984375,-0.8016510009765625,-0.650421142578125,-0.500946044921875,-0.25091552734375,-0.0008697509765625 },
						 },
						 {
						  --lknee
						  path = "assets/idleGirls/blue/lknee.png",
						  x = { 535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.4,535.35,535.25,535.15,535.1,535,534.9,534.85,534.65,534.5,534.3,534.15,534,534.15,534.3,534.5,534.65,534.8,535,535.15,535.35,535.35,535.4,535.4,535.45,535.5,535.5,535.5,535.5,535.5,535.5,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.45,535.3,535.2,535.05,534.95,534.85,534.8,534.8,534.8,534.8,534.75,534.75,534.7,534.7,534.7,534.7,534.7,534.7,534.65,534.65,534.65,534.7,534.7,534.7,534.7,534.7,534.7,534.65,534.65,534.65,534.7,534.7,534.75,534.75,534.75,534.75,534.7,534.7,534.7,534.65,534.65,534.65,534.6,534.65,534.7,534.7,534.75,534.75,534.9,534.9,535,535.05,535.1,535.15,535.25,535.25,535.3,535.3,535.4,535.5 },
						  y = { 674.1,673.75,673.4,673.05,672.7,672.35,672,671.65,671.3,670.95,670.6,670.25,669.9,669.55,669.2,668.85,668.55,668.6,668.65,668.7,668.8,668.85,668.9,668.95,669,669.05,669.1,669.15,669.25,669.45,669.7,669.9,670.15,670.35,670.6,670.8,671.05,671.7,672.35,673,673.65,674.3,674.3,674.3,674.3,674.3,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.3,674.3,674.3,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.35,674.65,674.9,675.1,675.25,675.45,675.45,675.45,675.45,675.4,675.4,675.4,675.4,675.35,675.35,675.35,675.35,675.3,675.3,675.3,675.3,675.3,675.3,675.25,675.25,675.25,675.25,675.25,675.25,675.25,675.2,675.2,675.15,675.1,675.05,675,675.05,675.05,675.1,675.1,675.15,675.15,675.15,675.15,675.15,675.1,675.1,675.05,675.05,674.95,674.85,674.9,674.75,674.7,674.65,674.6,674.6,674.5,674.5,674.4 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0008697509765625,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.623321533203125,1.2465057373046875,1.8711395263671875,2.4953155517578125,3.1180419921875,3.1180419921875,3.1180419921875,3.1180419921875,3.1180419921875,3.1171722412109375,3.1171722412109375,3.1171722412109375,3.1171722412109375,3.1171722412109375,3.1171722412109375,3.1171722412109375,3.1171722412109375,3.1171722412109375,3.1171722412109375,3.1171722412109375,3.1180419921875,3.1180419921875,3.1180419921875,3.1180419921875,3.1180419921875,3.1180419921875,3.1171722412109375,3.1171722412109375,3.1171722412109375,3.1171722412109375,3.1171722412109375,3.1180419921875,3.1180419921875,3.1180419921875,3.1180419921875,3.1180419921875,3.1180419921875,3.1189117431640625,3.1189117431640625,3.1189117431640625,3.1189117431640625,3.1189117431640625,3.1189117431640625,3.1189117431640625,3.1180419921875,3.1180419921875,3.1180419921875,2.8067626953125,2.49444580078125,2.182861328125,1.8702545166015625,1.559295654296875,1.3723297119140625,1.1844635009765625,0.9983062744140625,0.8112640380859375,0.62420654296875,0.31298828125,0.0008697509765625 },
						 },
						 {
						  --lfoot
						  path = "assets/idleGirls/blue/lfoot.png",
						  x = { 539.95,539.75,539.6,539.35,539.2,538.95,538.75,538.5,538.2,538,537.75,537.5,537.25,536.95,536.75,536.4,536.2,536.3,536.3,536.45,536.55,536.65,536.8,536.8,536.65,536.5,536.3,536.25,536.05,536.35,536.65,536.9,537.2,537.5,537.8,538.1,538.45,538.9,539.35,539.65,539.9,540.05,540.05,540.05,540.05,540.05,540.1,540.15,540.15,540.15,540.15,540.15,540.15,540.15,540.15,540.15,540.15,540.15,540.15,540.15,540.15,540.15,540.15,540.15,540.15,540.1,540.05,540.05,540.05,540.05,540.05,540.05,540.1,540.15,540.15,540.15,540.15,540.15,540.15,540.15,539.6,539.1,538.6,538.15,537.65,537.65,537.65,537.65,537.6,537.6,537.6,537.6,537.6,537.6,537.6,537.6,537.6,537.6,537.6,537.6,537.6,537.6,537.6,537.6,537.55,537.55,537.55,537.55,537.5,537.5,537.5,537.5,537.5,537.5,537.5,537.5,537.5,537.5,537.5,537.5,537.5,537.5,537.5,537.5,537.5,537.5,537.5,537.7,538.05,538.25,538.5,538.85,539,539.15,539.25,539.45,539.6,539.95,540.15 },
						  y = { 710.75,710.7,710.6,710.45,710.4,710.3,710.15,710.1,710,709.85,709.8,709.7,709.55,709.45,709.4,709.35,709.2,709.45,709.55,709.7,709.85,710.05,710.2,710.45,710.15,709.8,709.5,709.25,708.9,709,709.1,709.05,709.15,709.15,709.1,709.2,709.2,709.5,709.85,710.1,710.5,710.9,710.9,710.9,710.9,710.9,710.9,710.85,710.85,710.8,710.8,710.75,710.75,710.7,710.7,710.65,710.65,710.65,710.6,710.6,710.55,710.55,710.55,710.55,710.55,710.55,710.55,710.55,710.55,710.55,710.55,710.55,710.55,710.55,710.55,710.55,710.55,710.55,710.55,710.55,710.8,711.05,711.25,711.5,711.8,711.8,711.8,711.8,711.8,711.8,711.8,711.85,711.8,711.8,711.8,711.8,711.8,711.8,711.8,711.8,711.8,711.8,711.85,711.85,711.85,711.85,711.85,711.85,711.85,711.85,711.9,711.95,712,712.05,712.1,712.05,712.05,712,712,711.95,711.95,711.95,711.9,711.9,711.85,711.85,711.85,711.75,711.65,711.65,711.5,711.5,711.4,711.35,711.3,711.2,711.25,711.15,710.9 },
						  rotation = { 1.2770843505859375,2.5537872314453125,3.8305511474609375,5.10699462890625,6.384429931640625,7.6615142822265625,8.937835693359375,10.214569091796875,11.4920654296875,12.768890380859375,14.04693603515625,15.322265625,16.599899291992188,17.877395629882813,19.15472412109375,20.430999755859375,21.708343505859375,21.558761596679688,21.410400390625,21.26171875,21.112747192382813,20.963470458984375,20.8154296875,20.666336059570313,21.364913940429688,22.062896728515625,22.762237548828125,23.46112060546875,24.159210205078125,24.61248779296875,25.06463623046875,25.517745971679688,25.969589233398438,26.422897338867188,26.875442504882813,27.327850341796875,27.78070068359375,22.224166870117188,16.668121337890625,11.112075805664063,5.5559539794921875,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.62420654296875,1.2491302490234375,1.8728790283203125,2.496185302734375,3.12152099609375,3.12152099609375,3.12152099609375,3.12152099609375,3.12152099609375,3.122406005859375,3.122406005859375,3.122406005859375,3.122406005859375,3.122406005859375,3.122406005859375,3.122406005859375,3.122406005859375,3.122406005859375,3.122406005859375,3.122406005859375,3.12152099609375,3.12152099609375,3.12152099609375,3.12152099609375,3.12152099609375,3.12152099609375,3.122406005859375,3.122406005859375,3.122406005859375,3.122406005859375,3.12152099609375,3.12152099609375,3.12152099609375,3.12152099609375,3.12152099609375,3.12152099609375,3.12152099609375,3.12152099609375,3.12152099609375,3.12152099609375,3.12152099609375,3.122406005859375,3.122406005859375,3.122406005859375,3.122406005859375,3.122406005859375,3.12152099609375,2.80938720703125,2.496185302734375,2.1854705810546875,1.8728790283203125,1.5601806640625,1.373199462890625,1.1862030029296875,0.9983062744140625,0.8112640380859375,0.623321533203125,0.31298828125,0.0008697509765625 },
						 },
						 {
						  --buds
						  path = "assets/budsDeFrente.png",
						  scale = 0.25,
						  yOffset = -50,
						  xOffset = -5,
						  x = { 522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,521.95,521.85,521.75,521.65,521.55,521.45,521.4,521.2,521.05,520.85,520.7,520.55,520.7,520.85,521.05,521.2,521.35,521.55,521.7,521.9,521.9,521.95,521.95,522,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.35,522.6,522.85,523.1,523.45,523.45,523.45,523.45,523.45,523.45,523.45,523.4,523.45,523.45,523.45,523.45,523.5,523.5,523.5,523.5,523.5,523.5,523.6,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.5,523.5,523.5,523.5,523.5,523.35,523.15,523.05,522.85,522.7,522.7,522.55,522.5,522.4,522.4,522.3,522.05 },
						  y = { 576.4,576.05,575.7,575.35,575,574.65,574.3,574,573.65,573.3,572.95,572.6,572.25,571.9,571.55,571.2,570.9,570.95,571,571.05,571.15,571.2,571.25,571.35,571.4,571.5,571.55,571.65,571.75,571.95,572.15,572.35,572.6,572.8,573,573.2,573.45,574.1,574.75,575.4,576.05,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.7,576.7,576.7,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.8,576.75,576.7,576.7,576.65,576.65,576.6,576.6,576.6,576.6,576.6,576.6,576.6,576.6,576.6,576.6,576.6,576.6,576.6,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.6,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.6,576.6,576.65,576.65,576.75 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.826995849609375,1.65277099609375,2.4796142578125,3.305419921875,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,3.7191314697265625,3.3062896728515625,2.893096923828125,2.4804840087890625,2.0676116943359375,1.8187255859375,1.571533203125,1.3225250244140625,1.075225830078125,0.8278656005859375,0.414398193359375,0 },
						 },
						 {
						  --body
						  path = "assets/idleGirls/blue/body.png",
						  x = { 522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,521.95,521.85,521.75,521.65,521.55,521.45,521.4,521.2,521.05,520.85,520.7,520.55,520.7,520.85,521.05,521.2,521.35,521.55,521.7,521.9,521.9,521.95,521.95,522,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.35,522.6,522.85,523.1,523.45,523.45,523.45,523.45,523.45,523.45,523.45,523.4,523.45,523.45,523.45,523.45,523.5,523.5,523.5,523.5,523.5,523.5,523.6,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.5,523.5,523.5,523.5,523.5,523.35,523.15,523.05,522.85,522.7,522.7,522.55,522.5,522.4,522.4,522.3,522.05 },
						  y = { 576.4,576.05,575.7,575.35,575,574.65,574.3,574,573.65,573.3,572.95,572.6,572.25,571.9,571.55,571.2,570.9,570.95,571,571.05,571.15,571.2,571.25,571.35,571.4,571.5,571.55,571.65,571.75,571.95,572.15,572.35,572.6,572.8,573,573.2,573.45,574.1,574.75,575.4,576.05,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.7,576.7,576.7,576.75,576.75,576.75,576.75,576.75,576.75,576.75,576.8,576.75,576.7,576.7,576.65,576.65,576.6,576.6,576.6,576.6,576.6,576.6,576.6,576.6,576.6,576.6,576.6,576.6,576.6,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.6,576.55,576.55,576.55,576.55,576.55,576.55,576.55,576.6,576.6,576.65,576.65,576.75 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.826995849609375,1.65277099609375,2.4796142578125,3.305419921875,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.1342010498046875,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,4.133331298828125,3.7191314697265625,3.3062896728515625,2.893096923828125,2.4804840087890625,2.0676116943359375,1.8187255859375,1.571533203125,1.3225250244140625,1.075225830078125,0.8278656005859375,0.414398193359375,0 },
						 },
						 {
						  --rarm
						  path = "assets/idleGirls/blue/rarm.png",
						  x = { 467.7,467.1,466.75,466.35,465.95,465.6,465.3,465,464.75,464.5,464.3,464.15,464,463.85,463.85,463.9,463.85,463.7,463.7,463.55,463.55,463.5,463.4,463.35,463.25,463.25,463.2,463.1,463.05,463.15,463.3,463.4,463.45,463.55,463.6,463.75,463.8,463.9,463.95,463.95,464.1,464.15,464,463.95,463.9,463.8,463.75,463.8,464.25,464.9,465.8,467,468.4,469.95,471.65,473.65,475.7,477.85,480.05,482.3,482.3,482.3,482.3,482.3,482.3,482.3,482.3,482.3,482.3,482.25,482.25,482.25,482.25,482.25,482.25,482.25,482.3,482.3,482.3,482.3,482.85,483.45,484.1,484.7,485.4,484.95,484.6,484.2,483.8,483.35,482.95,482.55,482.05,481.5,481.05,480.55,480.05,479.55,479.05,478.55,478.05,477.55,477.05,477.05,477.05,477.1,477.1,477.1,477.1,477.15,476.05,475.1,474.15,473.3,472.45,472.5,472.65,472.75,472.75,472.9,472.9,473.1,473.75,474.55,475.3,476.15,477,476.05,475.1,474.15,473.25,472.3,471.85,471.25,470.8,470.3,469.8,468.95,468.2 },
						  y = { 546.3,545.3,544.3,543.25,542.2,541.15,540.05,538.95,537.85,536.75,535.65,534.5,533.35,532.25,531.1,529.95,528.8,528.9,529,529.15,529.25,529.35,529.45,529.6,529.5,529.45,529.35,529.3,529.1,529.55,529.85,530.2,530.55,530.85,531.15,531.55,531.8,532.25,532.75,533.2,533.65,534.1,534.25,534.4,534.5,534.65,534.9,537.15,539.4,541.55,543.65,545.65,547.45,549.05,550.55,551.8,552.75,553.5,554,554.25,554.25,554.25,554.25,554.25,554.25,554.25,554.25,554.25,554.25,554.25,554.25,554.25,554.25,554.25,554.25,554.25,554.25,554.25,554.25,554.25,553.6,553.1,552.5,551.9,551.35,551.35,551.25,551.2,551.1,551.1,550.95,550.85,550.8,550.6,550.45,550.25,550.1,549.85,549.65,549.45,549.2,548.85,548.6,548.6,548.6,548.6,548.6,548.6,548.55,548.55,547.85,547.05,546.15,545.2,544.15,544.3,544.4,544.5,544.65,544.75,544.85,545,545.8,546.6,547.3,548,548.65,548.5,548.4,548.2,548.1,547.95,547.85,547.8,547.7,547.65,547.55,547.45,547.2 },
						  rotation = { 2.4246368408203125,4.85015869140625,7.275604248046875,9.69976806640625,12.12615966796875,14.550994873046875,16.975723266601563,19.40087890625,21.825973510742188,24.2515869140625,26.676849365234375,29.102096557617188,31.5257568359375,33.951568603515625,36.377685546875,38.80291748046875,41.2274169921875,40.9398193359375,40.65470886230469,40.36665344238281,40.08021545410156,39.79443359375,39.50730895996094,39.220428466796875,39.622650146484375,40.023345947265625,40.42547607421875,40.82637023925781,41.22840881347656,40.976715087890625,40.726593017578125,40.47509765625,40.22322082519531,39.971527099609375,39.720550537109375,39.468780517578125,39.21832275390625,39.62109375,40.02130126953125,40.42344665527344,40.824859619140625,41.2274169921875,40.82637023925781,40.424468994140625,40.02284240722656,39.62213134765625,39.220428466796875,32.43217468261719,25.644363403320313,18.856964111328125,12.0684814453125,5.2804107666015625,-1.5068817138671875,-8.295150756835938,-15.082916259765625,-21.871917724609375,-28.659027099609375,-35.44758605957031,-42.234832763671875,-49.02378845214844,-49.02378845214844,-49.02378845214844,-49.02378845214844,-49.02378845214844,-49.02378845214844,-49.0247802734375,-49.0247802734375,-49.0247802734375,-49.0247802734375,-49.0247802734375,-49.0247802734375,-49.0247802734375,-49.0247802734375,-49.02378845214844,-49.02378845214844,-49.02378845214844,-49.02378845214844,-49.02378845214844,-49.02378845214844,-49.02378845214844,-48.19659423828125,-47.37030029296875,-46.54371643066406,-45.716796875,-44.89054870605469,-43.70268249511719,-42.51399230957031,-41.3251953125,-40.136474609375,-38.948089599609375,-37.76008605957031,-36.57157897949219,-34.90673828125,-33.24311828613281,-31.578445434570313,-29.91455078125,-28.25152587890625,-26.587432861328125,-24.920989990234375,-23.25775146484375,-21.59429931640625,-19.929595947265625,-18.265350341796875,-18.264556884765625,-18.264556884765625,-18.264556884765625,-18.264556884765625,-18.264556884765625,-18.264556884765625,-18.263778686523438,-14.389511108398438,-10.514892578125,-6.6398773193359375,-2.765777587890625,1.108428955078125,0.6617889404296875,0.2141876220703125,-0.2316741943359375,-0.6783905029296875,-1.1259002685546875,-1.573272705078125,-2.0204620361328125,-5.2691497802734375,-8.518447875976563,-11.767166137695313,-15.01605224609375,-18.266143798828125,-16.439178466796875,-14.612411499023438,-12.786361694335938,-10.958786010742188,-9.133102416992188,-8.036453247070313,-6.9398651123046875,-5.844207763671875,-4.74859619140625,-3.652099609375,-1.825714111328125,0 },
						 },
						 {
						  --rforearm
						  path = "assets/idleGirls/blue/rforearm.png",
						  x = { 441.85,439.55,437.3,435.3,433.35,431.5,429.85,428.3,426.9,425.65,424.55,423.6,422.9,422.2,421.75,421.5,421.4,421.3,421.2,421.1,421.05,420.95,420.8,420.8,420.55,420.35,420.25,420.1,419.85,420,420.2,420.4,420.6,420.75,420.95,421.15,421.35,421.35,421.3,421.3,421.4,421.35,421.45,421.45,421.45,421.5,421.55,422.8,425.65,429.95,435.5,442,449.5,457.5,465.75,474,482,489.45,496.15,502.05,502.05,502,502,502,502,502,502,502,502,502,502,502,502,502,502,502,502,502,502.05,502.05,502.2,502.45,502.7,502.95,503.2,502.1,500.95,499.6,498.35,496.95,495.45,493.9,491.65,489.25,486.75,484.25,481.6,478.85,476.15,473.35,470.55,467.7,464.95,464.95,464.95,464.9,464.9,464.9,464.9,464.9,462.4,460,457.7,455.55,453.5,453.8,454.05,454.3,454.55,454.9,455.1,455.35,457.1,458.9,460.85,462.75,464.8,462.7,460.45,458.35,456.25,454.15,452.9,451.7,450.5,449.3,448.1,446.2,444.3 },
						  y = { 579.05,576.7,574.15,571.55,568.75,565.95,563,559.95,556.85,553.65,550.45,547.05,543.65,540.25,536.85,533.4,529.9,530.35,530.8,531.25,531.7,532.15,532.55,533,532.55,532.15,531.7,531.35,530.85,531.4,531.95,532.45,533,533.6,534.05,534.6,535.1,535.25,535.4,535.5,535.7,535.8,536.35,536.8,537.4,537.85,538.45,547.7,556.5,564.75,572.1,578.3,583.2,586.65,588.7,589.4,588.65,586.65,583.6,579.65,579.6,579.6,579.6,579.6,579.6,579.6,579.6,579.6,579.6,579.6,579.6,579.6,579.6,579.6,579.6,579.6,579.6,579.6,579.6,579.65,579.35,579.05,578.75,578.45,578.15,579.3,580.4,581.45,582.5,583.45,584.3,585.2,586.3,587.25,588.05,588.7,589.15,589.45,589.55,589.45,589.2,588.75,588.1,588.1,588.1,588.1,588.1,588.1,588.1,588.05,586.6,584.9,583.1,581.1,578.95,579.2,579.45,579.65,579.9,580.15,580.4,580.55,582.35,583.95,585.45,586.85,588.05,587.65,587.15,586.6,585.95,585.3,584.9,584.4,584,583.5,583,582.05,581.25 },
						  rotation = { 4.012420654296875,8.023590087890625,12.035873413085938,16.04833984375,20.059295654296875,24.071823120117188,28.084381103515625,32.09523010253906,36.10700988769531,40.11909484863281,44.13093566894531,48.14271545410156,52.15531921386719,56.16831970214844,60.178802490234375,64.18962097167969,68.20266723632813,67.91607666015625,67.63064575195313,67.34414672851563,67.05661010742188,66.77104187011719,66.48593139648438,66.19914245605469,66.6007080078125,67.00177001953125,67.40373229980469,67.80430603027344,68.20643615722656,67.95512390136719,67.70320129394531,67.45294189453125,67.20133972167969,66.94918823242188,66.69873046875,66.44699096679688,66.19694519042969,66.59776306152344,67.00028991699219,67.40150451660156,67.80430603027344,68.20643615722656,67.80430603027344,67.40373229980469,67.00177001953125,66.6007080078125,66.19987487792969,52.66748046875,39.134796142578125,25.603134155273438,12.070159912109375,-1.461456298828125,-14.994033813476563,-28.525558471679688,-42.05891418457031,-55.5919189453125,-69.12347412109375,-82.65644836425781,-96.189208984375,-109.720703125,-109.720703125,-109.720703125,-109.720703125,-109.720703125,-109.720703125,-109.720703125,-109.720703125,-109.720703125,-109.720703125,-109.720703125,-109.720703125,-109.720703125,-109.720703125,-109.720703125,-109.720703125,-109.72224426269531,-109.72224426269531,-109.72224426269531,-109.72224426269531,-109.72224426269531,-108.89608764648438,-108.06961059570313,-107.24244689941406,-106.41584777832031,-105.5894775390625,-101.65736389160156,-97.72677612304688,-93.79399108886719,-89.86361694335938,-85.93190002441406,-82.00041198730469,-78.06869506835938,-72.56398010253906,-67.05958557128906,-61.55548095703125,-56.05084228515625,-50.54685974121094,-45.041534423828125,-39.53643798828125,-34.03269958496094,-28.527587890625,-23.024887084960938,-17.520339965820313,-17.520339965820313,-17.520339965820313,-17.520339965820313,-17.520339965820313,-17.520339965820313,-17.520339965820313,-17.520339965820313,-17.643478393554688,-17.767257690429688,-17.891647338867188,-18.01507568359375,-18.139114379882813,-18.232223510742188,-18.326034545898438,-18.4189453125,-18.513336181640625,-18.606826782226563,-18.700225830078125,-18.794296264648438,-18.539276123046875,-18.285049438476563,-18.03009033203125,-17.775177001953125,-17.521926879882813,-15.769378662109375,-14.017318725585938,-12.264816284179688,-10.513198852539063,-8.761138916015625,-7.7096099853515625,-6.6588592529296875,-5.6070404052734375,-4.5566558837890625,-3.504913330078125,-1.752349853515625,-0.0008697509765625 },
						 },
						 {
						  --rhand
						  path = "assets/idleGirls/blue/rhand.png",
						  x = { 430.55,425.5,420.65,416.1,411.8,407.85,404.3,401.05,398.25,395.85,393.85,392.35,391.25,390.7,390.45,390.75,391.45,390.55,389.75,389.25,388.8,388.65,388.65,388.85,388.85,389.2,389.95,391.05,392.55,391.6,390.9,390.2,389.7,389.35,389.2,389.05,389.1,388.85,388.95,389.35,390.2,391.35,390.2,389.45,389,388.95,389.25,392.75,399.6,409.35,421.65,435.8,451.1,466.8,482.25,496.7,509.5,520.1,528.15,533.4,533.4,533.4,533.4,533.4,533.35,533.35,533.35,533.35,533.35,533.35,533.3,533.3,533.3,533.35,533.35,533.35,533.35,533.35,533.35,533.35,533.65,533.95,534.25,534.5,534.75,533.85,532.75,531.35,529.7,527.9,525.85,523.65,520.2,516.35,512.2,507.7,502.9,497.8,492.45,487.05,481.45,475.7,469.85,469.85,469.85,469.9,469.85,469.85,469.85,469.85,467.4,465.05,462.8,460.65,458.75,459,459.3,459.65,459.95,460.3,460.6,460.9,462.45,464.15,466.05,467.9,469.85,466.35,462.8,459.4,455.9,452.5,450.4,448.35,446.3,444.35,442.35,439.05,435.85 },
						  y = { 609.65,606.1,602.05,597.8,593.15,588.15,582.8,577.25,571.55,565.6,559.4,553.2,546.9,540.55,534.15,527.8,521.55,523.7,526.05,528.4,530.8,533.15,535.55,537.95,534.8,531.7,528.55,525.55,522.65,524.65,526.8,528.9,531.15,533.35,535.6,537.8,540,537.6,535.1,532.65,530.25,527.95,530.95,534,537.15,540.3,543.45,560.3,576.05,590,601.4,610.1,615.45,617.6,616.45,612.25,605.3,596.2,585.4,573.65,573.65,573.65,573.65,573.65,573.65,573.65,573.65,573.65,573.65,573.65,573.65,573.6,573.6,573.6,573.6,573.6,573.6,573.6,573.6,573.6,573.8,573.95,574.15,574.3,574.5,577.85,581.05,584.3,587.45,590.6,593.6,596.45,600.35,604.05,607.3,610.3,612.9,615.15,616.9,618.3,619.25,619.65,619.6,619.6,619.65,619.65,619.65,619.7,619.7,619.7,618.15,616.45,614.5,612.45,610.2,610.5,610.8,611,611.25,611.5,611.7,611.95,613.75,615.4,616.95,618.4,619.7,619.5,619.2,618.8,618.2,617.65,617.25,616.65,616.2,615.65,615.05,614,612.75 },
						  rotation = { 6.3930511474609375,12.787185668945313,19.181243896484375,25.575393676757813,31.969558715820313,38.36271667480469,44.7586669921875,51.15092468261719,57.54603576660156,63.94215393066406,70.33509826660156,76.72903442382813,83.12303161621094,89.51741027832031,95.91082763671875,102.30404663085938,108.69865417480469,102.62745666503906,96.55619812011719,90.48432922363281,84.41287231445313,78.341796875,72.27081298828125,66.19841003417969,74.69969177246094,83.19886779785156,91.69819641113281,100.1993408203125,108.69865417480469,103.38603210449219,98.07415771484375,92.76054382324219,87.44970703125,82.13763427734375,76.82513427734375,71.51261901855469,66.20060729980469,74.70132446289063,83.20059204101563,91.70082092285156,100.20103454589844,108.70022583007813,100.20103454589844,91.70082092285156,83.20146179199219,74.70132446289063,66.20060729980469,51.68621826171875,37.17022705078125,22.65362548828125,8.1409912109375,-6.3749237060546875,-20.88873291015625,-35.404632568359375,-49.919281005859375,-64.4345703125,-78.94938659667969,-93.46484375,-107.97869873046875,-122.49441528320313,-122.49441528320313,-122.49441528320313,-122.49378967285156,-122.49378967285156,-122.49378967285156,-122.49378967285156,-122.4931640625,-122.49378967285156,-122.49378967285156,-122.49378967285156,-122.49378967285156,-122.49378967285156,-122.49378967285156,-122.49378967285156,-122.49378967285156,-122.49378967285156,-122.49378967285156,-122.49441528320313,-122.49441528320313,-122.49441528320313,-121.66845703125,-120.84239196777344,-120.01560974121094,-119.18879699707031,-118.36198425292969,-114.43011474609375,-110.49853515625,-106.56777954101563,-102.63577270507813,-98.70391845703125,-94.77203369140625,-90.84098815917969,-85.33737182617188,-79.83285522460938,-74.32864379882813,-68.82489013671875,-63.31965637207031,-57.815765380859375,-52.31156921386719,-46.80747985839844,-41.303009033203125,-35.79937744140625,-30.294708251953125,-30.294708251953125,-30.294708251953125,-30.2940673828125,-30.2940673828125,-30.2940673828125,-30.2940673828125,-30.292755126953125,-30.417739868164063,-30.541122436523438,-30.664825439453125,-30.789505004882813,-30.913223266601563,-31.007095336914063,-31.100128173828125,-31.194259643554688,-31.287567138671875,-31.380050659179688,-31.474273681640625,-31.567657470703125,-31.313095092773438,-31.057159423828125,-30.802413940429688,-30.546951293945313,-30.292098999023438,-27.26226806640625,-24.233413696289063,-21.203994750976563,-18.175430297851563,-15.146469116210938,-13.328109741210938,-11.509689331054688,-9.692977905273438,-7.8760986328125,-6.057830810546875,-3.0291290283203125,0 },
						 },
						 {
						  --larm
						  path = "assets/idleGirls/blue/larm.png",
						  x = { 569.95,570.45,570.85,571.25,571.6,571.95,572.2,572.55,572.7,572.85,573.05,573.2,573.3,573.3,573.35,573.3,573.3,573.35,573.35,573.35,573.4,573.45,573.45,573.55,573.2,572.9,572.5,572.15,571.9,572.2,572.45,572.75,573,573.3,573.5,573.85,574.05,574,573.85,573.75,573.55,573.5,573.55,573.75,573.85,573.95,574.1,573.85,573.15,572.1,570.65,568.95,566.95,564.6,562.15,559.55,556.75,553.95,551.1,548.35,548.35,548.35,548.35,548.35,548.35,548.35,548.35,548.35,548.35,548.35,548.35,548.35,548.35,548.35,548.35,548.35,548.35,548.35,548.35,548.35,548.95,549.55,550.1,550.75,551.35,551.95,552.55,553.15,553.75,554.35,554.95,555.6,556.45,557.25,558.15,559.05,559.9,560.75,561.6,562.55,563.35,564.2,565,565,565,565,565,565,565,565,567.3,569.45,571.4,573.15,574.55,574,573.4,572.75,572,571.3,570.5,569.65,568.8,567.85,566.9,565.95,564.95,565.5,566.1,566.6,567.05,567.6,567.8,568.05,568.35,568.6,568.75,569.05,569.45 },
						  y = { 546.45,545.45,544.4,543.35,542.3,541.2,540.15,539.05,537.95,536.85,535.7,534.5,533.4,532.2,531,529.8,528.75,528.8,528.9,528.9,529.05,529.05,529.15,529.25,529.3,529.45,529.5,529.6,529.75,529.9,530.1,530.3,530.5,530.7,530.95,531.1,531.35,531.95,532.7,533.35,534.05,534.7,534.7,534.65,534.65,534.55,534.65,537.35,540.2,542.85,545.3,547.6,549.6,551.3,552.65,553.7,554.25,554.55,554.45,553.95,553.9,553.9,553.9,553.85,553.85,553.85,553.85,553.8,553.8,553.8,553.8,553.8,553.8,553.8,553.8,553.85,553.85,553.85,553.85,553.9,554.25,554.6,555.05,555.45,555.8,556,556.15,556.35,556.45,556.55,556.65,556.65,556.75,556.8,556.75,556.75,556.65,556.6,556.45,556.25,556.05,555.85,555.55,555.55,555.55,555.55,555.55,555.55,555.55,555.55,554.5,553.2,551.65,549.9,547.9,548.7,549.45,550.15,550.9,551.55,552.15,552.75,553.4,554,554.45,554.95,555.35,554.75,554.15,553.4,552.65,551.85,551.3,550.85,550.35,549.8,549.2,548.25,547.35 },
						  rotation = { -2.351318359375,-4.7042999267578125,-7.0561370849609375,-9.409011840820313,-11.76214599609375,-14.1143798828125,-16.466522216796875,-18.818588256835938,-21.172073364257813,-23.52362060546875,-25.876953125,-28.229141235351563,-30.581954956054688,-32.93321228027344,-35.28656005859375,-37.638580322265625,-39.99052429199219,-39.70916748046875,-39.42655944824219,-39.144775390625,-38.86285400390625,-38.58082580566406,-38.29924011230469,-38.01600646972656,-38.4105224609375,-38.80503845214844,-39.20100402832031,-39.594635009765625,-39.99052429199219,-39.74330139160156,-39.49690246582031,-39.25032043457031,-39.00251770019531,-38.756683349609375,-38.5091552734375,-38.263153076171875,-38.014923095703125,-38.4105224609375,-38.80503845214844,-39.202056884765625,-39.595672607421875,-39.991546630859375,-39.595672607421875,-39.202056884765625,-38.80609130859375,-38.41107177734375,-38.014923095703125,-30.132797241210938,-22.248138427734375,-14.364089965820313,-6.480255126953125,1.4029083251953125,9.28643798828125,17.170654296875,25.054595947265625,32.938140869140625,40.822357177734375,48.70686340332031,56.590240478515625,64.47370910644531,64.47370910644531,64.47370910644531,64.47370910644531,64.47370910644531,64.47227478027344,64.47227478027344,64.47227478027344,64.47227478027344,64.47227478027344,64.47227478027344,64.47227478027344,64.47227478027344,64.47227478027344,64.47227478027344,64.47227478027344,64.47227478027344,64.47227478027344,64.47227478027344,64.47227478027344,64.47227478027344,65.29942321777344,66.12525939941406,66.95362854003906,67.78033447265625,68.60704040527344,66.85525512695313,65.10273742675781,63.351776123046875,61.5987548828125,59.848236083984375,58.095916748046875,56.34422302246094,53.89128112792969,51.439483642578125,48.985931396484375,46.53358459472656,44.08088684082031,41.628997802734375,39.17631530761719,36.724090576171875,34.27278137207031,31.819580078125,29.366409301757813,29.366409301757813,29.366409301757813,29.3670654296875,29.3670654296875,29.3670654296875,29.3670654296875,29.3670654296875,22.364120483398438,15.361297607421875,8.356781005859375,1.3548583984375,-5.6486053466796875,-2.8878631591796875,-0.1276397705078125,2.6331787109375,5.3930816650390625,8.153839111328125,10.91412353515625,13.674453735351563,16.813232421875,19.951995849609375,23.090774536132813,26.229751586914063,29.368392944335938,26.4320068359375,23.494949340820313,20.558334350585938,17.621246337890625,14.684417724609375,12.922637939453125,11.160888671875,9.3970947265625,7.6357574462890625,5.873626708984375,2.93670654296875,0.0008697509765625 },
						 },
						 {
						  --lforearm
						  path = "assets/idleGirls/blue/lforearm.png",
						  x = { 596.2,598.4,600.5,602.55,604.45,606.25,607.9,609.45,610.8,612.1,613.2,614.15,614.9,615.6,616.1,616.4,616.6,616.55,616.45,616.35,616.25,616.25,616.1,616.05,615.85,615.65,615.4,615.15,614.95,615.2,615.4,615.65,615.8,616,616.25,616.5,616.7,616.7,616.7,616.8,616.7,616.8,616.75,616.8,616.75,616.8,616.75,615.1,611.65,606.65,600.25,592.65,584.1,574.95,565.45,556,546.75,538.1,530.35,523.5,523.5,523.5,523.5,523.5,523.5,523.5,523.5,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.55,523.5,523.75,524,524.25,524.5,524.7,526.05,527.5,529,530.65,532.35,534.15,536.15,539,542.1,545.25,548.55,551.95,555.5,559.05,562.65,566.3,569.95,573.6,573.6,573.6,573.6,573.6,573.65,573.65,573.65,578.9,583.9,588.5,592.7,596.35,594.55,592.6,590.65,588.6,586.4,584.2,581.9,580.4,578.75,577.05,575.3,573.5,575.8,578.05,580.3,582.45,584.5,585.75,586.9,588.1,589.2,590.3,592.1,593.85 },
						  y = { 579.1,576.8,574.35,571.85,569.15,566.45,563.55,560.65,557.6,554.45,551.3,548.1,544.75,541.45,538.1,534.65,531.25,531.55,531.85,532.15,532.5,532.75,533.05,533.35,533.15,532.95,532.8,532.55,532.35,532.75,533.2,533.6,533.95,534.35,534.8,535.2,535.6,535.9,536.25,536.55,536.9,537.2,537.55,537.85,538.2,538.55,538.85,549.05,558.7,567.65,575.55,582.15,587.25,590.75,592.65,592.95,591.55,588.75,584.6,579.4,579.4,579.35,579.35,579.35,579.35,579.35,579.35,579.35,579.35,579.35,579.35,579.35,579.35,579.35,579.35,579.35,579.3,579.3,579.35,579.35,579.35,579.4,579.35,579.4,579.4,581.15,582.85,584.4,585.95,587.45,588.9,590.25,591.95,593.55,594.9,596,596.9,597.55,598.05,598.25,598.15,597.85,597.2,597.15,597.15,597.15,597.15,597.15,597.15,597.1,595,592.3,589,585.1,580.6,582.45,584.15,585.8,587.3,588.8,590.1,591.4,592.85,594.1,595.35,596.35,597.1,596.05,594.85,593.6,592.15,590.55,589.6,588.55,587.45,586.4,585.25,583.25,581.25 },
						  rotation = { -4.012420654296875,-8.027023315429688,-12.040054321289063,-16.054000854492188,-20.067779541015625,-24.081298828125,-28.094589233398438,-32.107147216796875,-36.12184143066406,-40.134429931640625,-44.148040771484375,-48.162109375,-52.17604064941406,-56.18943786621094,-60.20184326171875,-64.21583557128906,-68.22904968261719,-67.94911193847656,-67.66802978515625,-67.38809204101563,-67.1077880859375,-66.82716369628906,-66.54624938964844,-66.26651000976563,-66.65965270996094,-67.05438232421875,-67.44770812988281,-67.841796875,-68.23583984375,-67.99043273925781,-67.744384765625,-67.49769592285156,-67.25337219238281,-67.0069580078125,-66.76069641113281,-66.51387023925781,-66.26797485351563,-66.661865234375,-67.05587768554688,-67.44920349121094,-67.84403991699219,-68.23809814453125,-67.84403991699219,-67.44920349121094,-67.05513000488281,-66.661865234375,-66.26724243164063,-52.85142517089844,-39.43333435058594,-26.017623901367188,-12.600799560546875,0.81475830078125,14.231918334960938,27.648468017578125,41.06480407714844,54.481689453125,67.89805603027344,81.31402587890625,94.73123168945313,108.14859008789063,108.14859008789063,108.14859008789063,108.14938354492188,108.14938354492188,108.14938354492188,108.14938354492188,108.14938354492188,108.14938354492188,108.15016174316406,108.15016174316406,108.15016174316406,108.15016174316406,108.15016174316406,108.15016174316406,108.15016174316406,108.15016174316406,108.14938354492188,108.14938354492188,108.14938354492188,108.14938354492188,108.97587585449219,109.802001953125,110.62959289550781,111.45509338378906,112.28257751464844,107.97869873046875,103.67445373535156,99.37156677246094,95.06709289550781,90.76406860351563,86.46025085449219,82.15565490722656,76.13092041015625,70.10517883300781,64.08059692382813,58.05561828613281,52.02960205078125,46.00404357910156,39.97821044921875,33.95216369628906,27.927642822265625,21.902023315429688,15.877822875976563,15.877822875976563,15.877822875976563,15.877822875976563,15.877822875976563,15.877822875976563,15.877822875976563,15.877822875976563,16.0733642578125,16.268524169921875,16.46490478515625,16.66009521484375,16.855682373046875,18.300811767578125,19.746261596679688,21.19183349609375,22.6357421875,24.08056640625,25.524871826171875,26.970657348632813,24.751068115234375,22.533645629882813,20.314224243164063,18.096466064453125,15.877822875976563,14.29022216796875,12.702346801757813,11.114608764648438,9.526397705078125,7.9387054443359375,6.98638916015625,6.03363037109375,5.0809783935546875,4.12811279296875,3.175567626953125,1.5872650146484375,0 },
						 },
						 {
						  --lhand
						  path = "assets/idleGirls/blue/lhand.png",
						  x = { 607.4,612.55,617.4,622.05,626.45,630.5,634.2,637.55,640.45,642.9,645,646.6,647.7,648.35,648.55,648.25,647.5,648.45,649.1,649.55,649.65,649.5,649.1,648.3,648.95,648.95,648.4,647.4,645.75,646.85,647.8,648.45,649,649.25,649.3,649.2,648.75,649.65,650.1,649.85,649.2,647.85,649.25,650,650.25,649.95,649.1,645.2,637.95,627.45,614.45,599.5,583.25,566.4,549.7,533.95,519.75,507.65,498.1,491.45,491.45,491.45,491.45,491.45,491.45,491.45,491.45,491.45,491.45,491.45,491.45,491.45,491.45,491.45,491.45,491.45,491.45,491.45,491.45,491.45,491.7,492,492.35,492.6,492.95,493.85,495.05,496.6,498.4,500.45,502.85,505.5,509.65,514.3,519.4,524.9,530.8,537,543.45,550.15,556.95,564,570.95,570.95,570.95,570.95,570.95,570.95,570.95,570.95,576.2,581.1,585.6,589.65,593.35,590.7,587.95,585.15,582.3,579.4,576.35,573.3,572.95,572.5,572.05,571.55,570.95,574.35,577.65,580.95,584.2,587.35,589.25,591,592.85,594.65,596.4,599.15,602 },
						  y = { 610.15,606.75,603,598.8,594.25,589.3,584.15,578.65,572.9,566.9,560.75,554.5,548.1,541.7,535.35,528.9,522.65,524.7,526.95,529.25,531.65,534,536.35,538.65,535.55,532.35,529.2,526.1,523.25,525.3,527.4,529.65,531.85,534.1,536.35,538.65,540.8,538.25,535.5,532.85,530.3,527.9,530.95,534.2,537.6,540.95,544.25,561.85,578.35,592.9,604.95,614.05,619.8,622.2,621.15,616.85,609.5,599.8,588.15,575.2,575.15,575.15,575.15,575.15,575.15,575.15,575.15,575.1,575.1,575.1,575.1,575.1,575.1,575.1,575.1,575.1,575.1,575.1,575.1,575.15,574.7,574.25,573.85,573.35,572.85,577.05,581.1,585.2,589.15,593.2,596.95,600.65,605.5,610.1,614.2,618.05,621.2,624,626.25,627.9,629,629.45,629.25,629.25,629.25,629.25,629.25,629.25,629.25,629.25,627.05,624.3,620.85,616.9,612.35,614.1,615.75,617.25,618.7,620.05,621.25,622.25,624.05,625.6,627,628.25,629.15,628.25,627.2,625.95,624.55,623,621.95,620.9,619.8,618.55,617.35,615.15,613 },
						  rotation = { -6.9346923828125,-13.8707275390625,-20.807037353515625,-27.743728637695313,-34.678558349609375,-41.61482238769531,-48.55029296875,-55.4873046875,-62.42292785644531,-69.35893249511719,-76.29501342773438,-83.23077392578125,-90.16610717773438,-97.10177612304688,-104.03788757324219,-110.973388671875,-117.90989685058594,-110.53150939941406,-103.15414428710938,-95.77584838867188,-88.39964294433594,-81.02122497558594,-73.64369201660156,-66.26504516601563,-76.59245300292969,-86.92031860351563,-97.24722290039063,-107.57518005371094,-117.90170288085938,-111.447509765625,-104.9915771484375,-98.53640747070313,-92.08332824707031,-85.62843322753906,-79.17440795898438,-72.71928405761719,-66.26504516601563,-76.59245300292969,-86.91944885253906,-97.24635314941406,-107.57518005371094,-117.90101623535156,-107.57518005371094,-97.24722290039063,-86.92031860351563,-76.59245300292969,-66.26577758789063,-52.30718994140625,-38.349822998046875,-24.393142700195313,-10.436279296875,3.5197296142578125,17.478195190429688,31.43609619140625,45.3924560546875,59.35005187988281,73.3070068359375,87.26388549804688,101.22062683105469,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,116.00491333007813,116.83160400390625,117.65943908691406,118.48573303222656,119.31059265136719,115.0079345703125,110.70458984375,106.40057373046875,102.09690856933594,97.79371643066406,93.48924255371094,89.18699645996094,83.16180419921875,77.13551330566406,71.10939025878906,65.08331298828125,59.05975341796875,53.033477783203125,47.00750732421875,40.982696533203125,34.957855224609375,28.931625366210938,22.90631103515625,22.90631103515625,22.90631103515625,22.90631103515625,22.90631103515625,22.90631103515625,22.90631103515625,22.90631103515625,23.10186767578125,23.298324584960938,23.494216918945313,23.68951416015625,23.884963989257813,25.329483032226563,26.775192260742188,28.218948364257813,29.663681030273438,31.10845947265625,32.552825927734375,33.99786376953125,31.779159545898438,29.560592651367188,27.34234619140625,25.123428344726563,22.90631103515625,20.615798950195313,18.324462890625,16.03460693359375,13.744598388671875,11.45428466796875,10.079879760742188,8.70477294921875,7.330657958984375,5.9575347900390625,4.5827178955078125,2.2910919189453125,0.0017547607421875 },
						 },
						 {
						  displayObject = girl2OpenEyes,
						  x = { 517.9,517.9,517.9,517.9,517.9,517.9,517.9,517.9,517.85,517.85,517.85,517.85,517.85,517.85,517.85,517.85,517.8,517.75,517.65,517.6,517.5,517.45,517.35,517.3,517.1,516.95,516.75,516.6,516.45,516.6,516.75,516.95,517.1,517.25,517.45,517.6,517.8,517.8,517.85,517.85,517.9,517.95,517.95,517.95,517.95,517.95,517.95,517.95,517.95,518,518,518,518.05,518.05,518.1,518.1,518.1,518.15,518.15,518.2,519,519.8,520.55,521.35,522.1,522.9,523.7,522.65,521.55,520.5,519.35,518.3,519.5,520.7,521.9,523.1,524.35,525.6,526.75,528,528.85,529.65,530.5,531.35,532.2,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.3,532.3,532.3,532.3,532.3,532.3,532.3,532.3,529.75,527.2,524.6,522.05,519.5,521.35,523.2,525,526.85,528.65,530.55,532.35,529.45,526.6,523.7,520.85,517.9,517.95,517.85,517.9,517.9,517.85,517.85,517.9,517.85,517.85,517.85,517.95,517.95 },
						  y = { 401.8,401.45,401.1,400.75,400.4,400.05,399.75,399.4,399.05,398.7,398.35,398,397.65,397.3,396.95,396.6,396.25,396.35,396.4,396.45,396.55,396.6,396.65,396.75,396.8,396.9,396.95,397.05,397.15,397.35,397.55,397.75,398,398.2,398.4,398.6,398.85,399.5,400.15,400.8,401.45,402.15,402.15,402.15,402.15,402.15,402.15,402.1,402.1,402.05,402.05,402.05,402,402,402,401.95,401.95,401.95,401.9,401.9,401.85,401.85,401.85,401.8,401.85,401.85,401.9,401.85,401.85,401.8,401.85,401.9,401.8,401.85,401.85,401.9,401.9,401.95,402,402.1,402,402,402,402,402.1,402.05,402.05,402.05,402.05,402.05,402.05,402.05,402.05,402.05,402.05,402.05,402.05,402,402,402,402,402,401.95,401.95,401.95,402,402,402,402,402,401.9,401.85,401.9,401.95,402.2,401.95,401.9,401.85,401.8,401.8,401.8,401.9,401.75,401.75,401.75,401.9,402.15,402.05,401.95,402,401.9,401.85,401.85,401.85,401.9,401.9,401.85,401.95,402.15 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0008697509765625,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.433624267578125,0.86895751953125,1.3032989501953125,1.7392578125,2.1741180419921875,2.6087493896484375,3.0439453125,2.4351043701171875,1.82659912109375,1.216796875,0.609344482421875,0,0.6783905029296875,1.35748291015625,2.0344390869140625,2.7143096923828125,3.392547607421875,4.070709228515625,4.7494659423828125,5.4277496337890625,5.1685791015625,4.9100494384765625,4.64959716796875,4.3898162841796875,4.1324615478515625,4.1324615478515625,4.1324615478515625,4.1324615478515625,4.1324615478515625,4.1324615478515625,4.1324615478515625,4.1324615478515625,4.131591796875,4.131591796875,4.131591796875,4.1307220458984375,4.1307220458984375,4.129852294921875,4.129852294921875,4.129852294921875,4.129852294921875,4.129852294921875,4.1289825439453125,4.1289825439453125,4.1289825439453125,4.1289825439453125,4.1289825439453125,4.1289825439453125,4.1289825439453125,4.1289825439453125,2.7055816650390625,1.2823333740234375,-0.139007568359375,-1.5627899169921875,-2.98553466796875,-1.9689483642578125,-0.9528656005859375,0.0629425048828125,1.0787200927734375,2.0946807861328125,3.1119384765625,4.12811279296875,2.5276031494140625,0.927520751953125,-0.6714019775390625,-2.271026611328125,-3.8705902099609375,-3.4831390380859375,-3.0971221923828125,-2.709075927734375,-2.3216552734375,-1.9340057373046875,-1.7025604248046875,-1.470184326171875,-1.2368927001953125,-1.0052947998046875,-0.772796630859375,-0.387298583984375,-0.0008697509765625 },
						  scaleComponent = true,
						 },
						 {
						  displayObject = girl2ClosedEyes,
						  x = { 517.9,517.9,517.9,517.9,517.9,517.9,517.9,517.9,517.85,517.85,517.85,517.85,517.85,517.85,517.85,517.85,517.8,517.75,517.65,517.6,517.5,517.45,517.35,517.3,517.1,516.95,516.75,516.6,516.45,516.6,516.75,516.95,517.1,517.25,517.45,517.6,517.8,517.8,517.85,517.85,517.9,517.95,517.95,517.95,517.95,517.95,517.95,517.95,517.95,518,518,518,518.05,518.05,518.1,518.1,518.1,518.15,518.15,518.2,519,519.8,520.55,521.35,522.1,522.9,523.7,522.65,521.55,520.5,519.35,518.3,519.5,520.7,521.9,523.1,524.35,525.6,526.75,528,528.85,529.65,530.5,531.35,532.2,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.25,532.3,532.3,532.3,532.3,532.3,532.3,532.3,532.3,529.75,527.2,524.6,522.05,519.5,521.35,523.2,525,526.85,528.65,530.55,532.35,529.45,526.6,523.7,520.85,517.9,517.95,517.85,517.9,517.9,517.85,517.85,517.9,517.85,517.85,517.85,517.95,517.95 },
						  y = { 401.8,401.45,401.1,400.75,400.4,400.05,399.75,399.4,399.05,398.7,398.35,398,397.65,397.3,396.95,396.6,396.25,396.35,396.4,396.45,396.55,396.6,396.65,396.75,396.8,396.9,396.95,397.05,397.15,397.35,397.55,397.75,398,398.2,398.4,398.6,398.85,399.5,400.15,400.8,401.45,402.15,402.15,402.15,402.15,402.15,402.15,402.1,402.1,402.05,402.05,402.05,402,402,402,401.95,401.95,401.95,401.9,401.9,401.85,401.85,401.85,401.8,401.85,401.85,401.9,401.85,401.85,401.8,401.85,401.9,401.8,401.85,401.85,401.9,401.9,401.95,402,402.1,402,402,402,402,402.1,402.05,402.05,402.05,402.05,402.05,402.05,402.05,402.05,402.05,402.05,402.05,402.05,402,402,402,402,402,401.95,401.95,401.95,402,402,402,402,402,401.9,401.85,401.9,401.95,402.2,401.95,401.9,401.85,401.8,401.8,401.8,401.9,401.75,401.75,401.75,401.9,402.15,402.05,401.95,402,401.9,401.85,401.85,401.85,401.9,401.9,401.85,401.95,402.15 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0008697509765625,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.433624267578125,0.86895751953125,1.3032989501953125,1.7392578125,2.1741180419921875,2.6087493896484375,3.0439453125,2.4351043701171875,1.82659912109375,1.216796875,0.609344482421875,0,0.6783905029296875,1.35748291015625,2.0344390869140625,2.7143096923828125,3.392547607421875,4.070709228515625,4.7494659423828125,5.4277496337890625,5.1685791015625,4.9100494384765625,4.64959716796875,4.3898162841796875,4.1324615478515625,4.1324615478515625,4.1324615478515625,4.1324615478515625,4.1324615478515625,4.1324615478515625,4.1324615478515625,4.1324615478515625,4.131591796875,4.131591796875,4.131591796875,4.1307220458984375,4.1307220458984375,4.129852294921875,4.129852294921875,4.129852294921875,4.129852294921875,4.129852294921875,4.1289825439453125,4.1289825439453125,4.1289825439453125,4.1289825439453125,4.1289825439453125,4.1289825439453125,4.1289825439453125,4.1289825439453125,2.7055816650390625,1.2823333740234375,-0.139007568359375,-1.5627899169921875,-2.98553466796875,-1.9689483642578125,-0.9528656005859375,0.0629425048828125,1.0787200927734375,2.0946807861328125,3.1119384765625,4.12811279296875,2.5276031494140625,0.927520751953125,-0.6714019775390625,-2.271026611328125,-3.8705902099609375,-3.4831390380859375,-3.0971221923828125,-2.709075927734375,-2.3216552734375,-1.9340057373046875,-1.7025604248046875,-1.470184326171875,-1.2368927001953125,-1.0052947998046875,-0.772796630859375,-0.387298583984375,-0.0008697509765625 },
						  scaleComponent = true,
						 },
						 {
						  --relbow
						  path = "assets/idleGirls/blue/elbowmask.png",
						  x = { 451.25,450.2,449.2,448.25,447.4,446.55,445.75,445.15,444.55,444,443.55,443.15,442.85,442.65,442.45,442.4,442.35,442.2,442.05,441.85,441.65,441.55,441.3,441.1,441,440.85,440.7,440.55,440.35,440.55,440.7,440.8,441,441.15,441.3,441.5,441.55,441.8,441.85,441.95,442.05,442.15,442.05,442,441.95,441.9,441.85,441.9,442.5,443.65,445.4,447.75,450.65,454.2,458.2,462.8,467.75,473.1,478.7,484.35,484.35,484.35,484.35,484.35,484.35,484.25,484.25,484.25,484.3,484.3,484.3,484.3,484.3,484.35,484.35,484.35,484.35,484.35,484.3,484.3,484.4,484.45,484.6,484.7,484.95,483.95,482.95,481.95,481,480.05,479.05,478.05,476.8,475.75,474.6,473.35,472.35,471.05,469.95,468.9,467.9,467.05,466.25,466.2,466.1,466.05,465.95,465.9,465.8,465.75,463.15,460.65,458.3,456.1,454.05,454.3,454.55,454.8,455.05,455.35,455.65,455.85,457.8,459.75,461.75,463.95,466.15,464.6,462.95,461.4,459.95,458.45,457.5,456.6,455.65,454.7,453.9,452.85,452.45 },
						  y = { 560.5,558.8,557,555.15,553.3,551.4,549.45,547.45,545.55,543.5,541.45,539.35,537.35,535.3,533.2,531.05,529,529.2,529.5,529.7,530,530.25,530.45,530.8,530.55,530.3,530.15,529.95,529.75,530.1,530.55,530.9,531.35,531.75,532.1,532.5,532.95,533.25,533.7,534.05,534.5,534.95,535.2,535.5,535.7,536.05,536.35,540.95,545.65,550.45,555.05,559.65,563.95,567.9,571.35,574.45,576.85,578.65,579.65,579.7,579.7,579.7,579.7,579.7,579.7,579.7,579.7,579.7,579.7,579.7,579.7,579.7,579.7,579.7,579.7,579.7,579.7,579.7,579.7,579.7,579.15,578.6,578,577.35,576.75,576.75,576.6,576.5,576.35,576.2,576.05,575.75,575.35,574.9,574.5,573.95,573.45,572.6,571.7,570.7,569.85,568.9,567.95,568.1,568.25,568.4,568.55,568.7,568.9,569.05,567.75,566.25,564.65,562.85,561,561.2,561.3,561.5,561.75,561.9,562.1,562.3,563.65,564.95,566.05,567.1,568,567.6,567.15,566.65,566.1,565.6,565.25,565.05,564.7,564.35,564.1,563.1,562.25 },
						  rotation = { 4.01068115234375,8.022735595703125,12.034194946289063,16.046722412109375,20.05853271484375,24.070358276367188,28.083023071289063,32.09333801269531,36.10643005371094,40.11705017089844,44.13047790527344,48.14222717285156,52.15476989746094,56.1671142578125,60.18011474609375,64.19174194335938,68.20266723632813,67.91682434082031,67.62989807128906,67.34414672851563,67.05735778808594,66.77104187011719,66.48519897460938,66.19841003417969,66.6007080078125,67.00177001953125,67.40298461914063,67.80506896972656,68.20567321777344,67.95437622070313,67.70394897460938,67.45442199707031,67.20431518554688,66.95289611816406,66.70240783691406,66.45140075683594,66.20060729980469,66.60292053222656,67.00325012207031,67.40522766113281,67.80581665039063,68.20718383789063,67.80506896972656,67.40373229980469,67.00177001953125,66.6007080078125,66.19841003417969,52.66636657714844,39.133209228515625,25.60028076171875,12.066818237304688,-1.4649505615234375,-14.996475219726563,-28.529617309570313,-42.062286376953125,-55.59489440917969,-69.12882995605469,-82.66073608398438,-96.19180297851563,-109.725341796875,-109.725341796875,-109.725341796875,-109.72456359863281,-109.72456359863281,-109.72456359863281,-109.72380065917969,-109.72380065917969,-109.72380065917969,-109.72380065917969,-109.72380065917969,-109.72380065917969,-109.72380065917969,-109.72380065917969,-109.72456359863281,-109.72456359863281,-109.72456359863281,-109.72456359863281,-109.725341796875,-109.725341796875,-109.725341796875,-108.8984375,-108.07197570800781,-107.24484252929688,-106.41827392578125,-105.59028625488281,-101.65988159179688,-97.72848510742188,-93.7974853515625,-89.86624145507813,-85.93537902832031,-82.00299072265625,-78.07205200195313,-72.56794738769531,-67.06327819824219,-61.558868408203125,-56.05625915527344,-50.551544189453125,-45.04766845703125,-39.54216003417969,-34.037506103515625,-28.533660888671875,-23.029342651367188,-17.525100708007813,-17.525100708007813,-17.525100708007813,-17.525100708007813,-17.525100708007813,-17.525100708007813,-17.525100708007813,-17.525100708007813,-17.6490478515625,-17.772796630859375,-17.896392822265625,-18.020599365234375,-18.144638061523438,-18.237747192382813,-18.33154296875,-18.425247192382813,-18.518051147460938,-18.611541748046875,-18.704925537109375,-18.7982177734375,-18.543991088867188,-18.28900146484375,-18.034835815429688,-17.780731201171875,-17.525909423828125,-15.7734375,-14.021438598632813,-12.26898193359375,-10.515731811523438,-8.762847900390625,-7.7113189697265625,-6.66058349609375,-5.6087799072265625,-4.5583953857421875,-3.5057830810546875,-1.754974365234375,-0.0017547607421875 },
						 },
						 {
						  --rwrist
						  path = "assets/idleGirls/blue/wristmask.png",
						  x = { 435.9,432.7,429.6,426.55,423.7,420.95,418.35,415.85,413.55,411.45,409.6,408.05,406.75,405.7,404.95,404.6,404.4,404.5,404.5,404.6,404.7,404.75,404.85,404.85,404.95,404.95,404.9,405,405.1,405.15,405.05,405.05,405.05,405.05,404.95,404.95,404.9,404.7,404.55,404.35,404.25,404.15,404.25,404.35,404.6,404.8,405,407.05,411.45,418.25,426.9,437.15,448.35,460.2,472.1,483.5,493.95,503.2,510.9,516.75,516.75,516.75,516.75,516.75,516.7,516.7,516.7,516.7,516.7,516.75,516.8,516.8,516.8,516.8,516.8,516.8,516.8,516.85,516.85,516.85,517.05,517.3,517.55,517.8,518.05,516.9,515.6,514.2,512.6,510.85,509,507,503.85,500.6,497.05,493.35,489.5,485.45,481.35,477.1,472.9,468.55,464.25,464.25,464.25,464.25,464.25,464.25,464.25,464.35,461.85,459.45,457.2,455.1,453.15,453.35,453.6,453.8,454.05,454.3,454.55,454.85,456.5,458.3,460.2,462.25,464.25,461.65,459,456.4,453.85,451.35,449.85,448.35,446.85,445.4,444,441.65,439.25 },
						  y = { 592.95,590.2,587.3,584.25,580.95,577.5,573.95,570.15,566.15,561.9,557.55,553.05,548.4,543.6,538.85,533.95,529.1,529.85,530.6,531.3,531.95,532.5,532.95,533.35,533.1,532.55,531.8,530.95,530.05,530.85,531.6,532.35,533.05,533.7,534.3,534.9,535.35,535.55,535.55,535.4,535.2,534.95,535.95,536.85,537.7,538.45,538.95,552.15,564.65,576.05,585.75,593.4,598.95,602.1,602.95,601.5,598.05,592.85,586.25,578.7,578.7,578.7,578.7,578.7,578.7,578.7,578.7,578.7,578.7,578.75,578.75,578.75,578.75,578.75,578.7,578.7,578.7,578.7,578.65,578.65,578.55,578.45,578.4,578.4,578.3,580.45,582.6,584.75,586.8,588.8,590.65,592.45,594.85,596.95,598.85,600.5,601.75,602.8,603.6,603.95,604,603.75,603.1,603.15,603.15,603.15,603.15,603.15,603.15,603.15,601.65,599.95,598.1,596.1,593.95,594.25,594.5,594.8,595.05,595.3,595.6,595.85,597.55,599.2,600.65,602,603.3,602.8,602.2,601.55,600.9,600.05,599.6,599.1,598.6,598.05,597.4,596.4,595.45 },
						  rotation = { 6.3947906494140625,12.788848876953125,19.183578491210938,25.577529907226563,31.972702026367188,38.366485595703125,44.76261901855469,51.158355712890625,57.5516357421875,63.94708251953125,70.34130859375,76.73648071289063,83.13078308105469,89.52615356445313,95.91947937011719,102.31405639648438,108.70964050292969,102.63661193847656,96.5648193359375,90.49131774902344,84.42066955566406,78.34767150878906,72.27398681640625,66.20280456542969,74.70294189453125,83.20318603515625,91.70344543457031,100.20442199707031,108.70492553710938,103.39265441894531,98.07929992675781,92.76664733886719,87.45407104492188,82.14106750488281,76.82844543457031,71.51576232910156,66.20280456542969,74.70294189453125,83.20318603515625,91.70344543457031,100.20442199707031,108.70492553710938,100.20442199707031,91.70344543457031,83.20318603515625,74.70294189453125,66.20280456542969,51.68675231933594,37.173004150390625,22.6573486328125,8.141845703125,-6.3714752197265625,-20.886444091796875,-35.4017333984375,-49.917236328125,-64.43171691894531,-78.94601440429688,-93.46049499511719,-107.97552490234375,-122.49067687988281,-122.49067687988281,-122.49067687988281,-122.49067687988281,-122.49067687988281,-122.49067687988281,-122.49067687988281,-122.49067687988281,-122.49067687988281,-122.49067687988281,-122.49130249023438,-122.49191284179688,-122.49191284179688,-122.49191284179688,-122.49191284179688,-122.49191284179688,-122.49191284179688,-122.49191284179688,-122.49191284179688,-122.49191284179688,-122.49191284179688,-121.66465759277344,-120.83723449707031,-120.0123291015625,-119.18414306640625,-118.35725402832031,-114.42576599121094,-110.49470520019531,-106.56375122070313,-102.6324462890625,-98.70135498046875,-94.76942443847656,-90.83836364746094,-85.33564758300781,-79.83200073242188,-74.32864379882813,-68.82565307617188,-63.32035827636719,-57.81764221191406,-52.31211853027344,-46.808868408203125,-41.30546569824219,-35.80052185058594,-30.2960205078125,-30.2960205078125,-30.2960205078125,-30.2960205078125,-30.2960205078125,-30.2960205078125,-30.2960205078125,-30.295364379882813,-30.419052124023438,-30.543060302734375,-30.666763305664063,-30.790802001953125,-30.913223266601563,-31.008377075195313,-31.101409912109375,-31.193618774414063,-31.2882080078125,-31.380691528320313,-31.4736328125,-31.568923950195313,-31.312469482421875,-31.057159423828125,-30.802413940429688,-30.546951293945313,-30.292755126953125,-27.265029907226563,-24.235595703125,-21.206268310546875,-18.17779541015625,-15.148101806640625,-13.3314208984375,-11.5130615234375,-9.694671630859375,-7.876953125,-6.0587005615234375,-3.0291290283203125,0 },
						 },
						 {
						  --lelbow
						  path = "assets/idleGirls/blue/elbowmask.png",
						  x = { 587,588.1,589.1,590.15,590.95,591.85,592.7,593.4,594.15,594.7,595.25,595.7,596.15,596.5,596.75,597,597.15,597.05,597,597,597,596.95,596.9,596.85,596.5,596.15,595.8,595.45,595.1,595.35,595.65,595.85,596.2,596.45,596.75,597,597.25,597.2,597.25,597.2,597.25,597.25,597.4,597.55,597.75,597.85,598.1,597.3,595.7,593.3,590.05,586.1,581.45,576.25,570.65,564.7,558.7,552.45,546.4,540.35,540.35,540.35,540.3,540.3,540.3,540.3,540.25,540.25,540.25,540.25,540.25,540.25,540.25,540.3,540.3,540.3,540.3,540.3,540.3,540.3,540.55,540.85,541.05,541.3,541.5,542.95,544.3,545.7,547.1,548.5,549.9,551.25,553.25,555.25,557.2,559.2,561.1,562.95,564.9,566.8,568.55,570.3,572.05,572.1,572.1,572.15,572.15,572.2,572.2,572.2,577.3,582,586.4,590.5,594.2,592.9,591.45,589.85,588.3,586.6,584.9,583,580.9,578.8,576.6,574.3,571.95,573.6,575.25,576.95,578.5,579.95,580.85,581.65,582.5,583.2,584,585.2,586.45 },
						  y = { 560.75,559.05,557.3,555.6,553.8,551.9,550,548.05,546.05,544.1,542.05,539.9,537.8,535.65,533.6,531.4,529.25,529.4,529.7,529.9,530.05,530.2,530.45,530.7,530.65,530.6,530.65,530.6,530.65,530.9,531.1,531.4,531.75,531.95,532.25,532.45,532.8,533.35,533.9,534.5,535.1,535.7,535.8,536,536.2,536.35,536.55,542.5,548.4,554,559.4,564.35,568.75,572.5,575.55,577.55,578.85,579.1,578.6,577.2,577.2,577.2,577.2,577.2,577.2,577.2,577.15,577.2,577.2,577.2,577.2,577.2,577.2,577.2,577.2,577.2,577.2,577.2,577.2,577.2,577.4,577.65,577.95,578.2,578.45,578.85,579.25,579.45,579.8,580.05,580.2,580.3,580.45,580.5,580.5,580.3,580.15,579.9,579.55,579.15,578.65,578.1,577.45,577.4,577.35,577.3,577.2,577.15,577.1,577.05,575.2,572.85,570,566.8,563,564.75,566.3,567.9,569.4,570.75,572.15,573.35,574.35,575.25,576,576.75,577.45,576.4,575.35,574.15,572.8,571.5,570.55,569.7,568.8,567.8,566.85,565.15,563.3 },
						  rotation = { -4.012420654296875,-8.027023315429688,-12.0408935546875,-16.054794311523438,-20.068557739257813,-24.081298828125,-28.095947265625,-32.109649658203125,-36.12355041503906,-40.13749694824219,-44.15074157714844,-48.16551208496094,-52.17877197265625,-56.19305419921875,-60.20841979980469,-64.22151184082031,-68.23583984375,-67.95361328125,-67.67253112792969,-67.39031982421875,-67.11001586914063,-66.82864379882813,-66.54698181152344,-66.26504516601563,-66.66038513183594,-67.05513000488281,-67.44845581054688,-67.84329223632813,-68.23809814453125,-67.99043273925781,-67.744384765625,-67.4969482421875,-67.25262451171875,-67.00473022460938,-66.75775146484375,-66.51167297363281,-66.26431274414063,-66.65965270996094,-67.05513000488281,-67.44920349121094,-67.84480285644531,-68.2403564453125,-67.84403991699219,-67.44845581054688,-67.05438232421875,-66.65890502929688,-66.26284790039063,-52.844757080078125,-39.429168701171875,-26.014083862304688,-12.59747314453125,0.8182525634765625,14.235198974609375,27.650527954101563,41.067779541015625,54.4840087890625,67.89956665039063,81.31744384765625,94.73295593261719,108.14938354492188,108.14938354492188,108.14938354492188,108.14938354492188,108.14938354492188,108.14938354492188,108.15016174316406,108.15016174316406,108.15016174316406,108.15016174316406,108.15016174316406,108.15016174316406,108.15016174316406,108.15016174316406,108.14938354492188,108.14938354492188,108.14938354492188,108.14938354492188,108.14938354492188,108.14938354492188,108.14938354492188,108.97431945800781,109.80122375488281,110.6280517578125,111.45509338378906,112.28108215332031,107.9779052734375,103.67362976074219,99.37071228027344,95.06622314453125,90.76318359375,86.45936584472656,82.15565490722656,76.13009643554688,70.10517883300781,64.08059692382813,58.05497741699219,52.03068542480469,46.00404357910156,39.97871398925781,33.95396423339844,27.92626953125,21.902023315429688,15.876205444335938,15.87701416015625,15.87701416015625,15.87701416015625,15.877822875976563,15.877822875976563,15.878631591796875,15.878631591796875,16.074981689453125,16.270950317382813,16.467330932617188,16.662506103515625,16.860488891601563,18.303970336914063,19.750137329101563,21.194107055664063,22.63873291015625,24.082748413085938,25.527725219726563,26.970657348632813,24.752517700195313,22.535125732421875,20.3165283203125,18.097259521484375,15.879440307617188,14.291030883789063,12.70318603515625,11.114608764648438,9.527236938476563,7.9387054443359375,6.98638916015625,6.03363037109375,5.0809783935546875,4.1289825439453125,3.1764373779296875,1.588134765625,0.0008697509765625 },
						 },
						 {
						  --lwrist
						  path = "assets/idleGirls/blue/wristmask.png",
						  x = { 602.5,605.6,608.75,611.95,614.95,617.9,620.65,623.1,625.4,627.5,629.4,631,632.35,633.45,634.2,634.75,635.05,634.75,634.4,634,633.45,632.85,632.05,631.3,632.1,632.7,633.05,633.2,633.25,633.3,633.25,633.2,633.05,632.9,632.65,632.25,631.8,632.8,633.6,634.15,634.5,634.8,634.55,634.25,633.75,632.95,632,629.8,625,618,608.85,598,586,573.25,560.3,547.65,535.8,525,515.8,508.3,508.35,508.35,508.35,508.35,508.35,508.35,508.35,508.35,508.35,508.35,508.35,508.35,508.35,508.35,508.35,508.35,508.35,508.35,508.35,508.3,508.55,508.85,509.05,509.25,509.5,510.85,512.35,514.1,516,518.1,520.3,522.7,526.5,530.5,534.8,539.3,544.1,549.05,554.1,559.25,564.55,569.8,575,575,575,575,575,575,575,575.05,580.25,585.2,589.8,593.9,597.5,595.3,593,590.65,588.15,585.6,582.95,580.3,579.35,578.3,577.25,576.1,574.95,577.7,580.4,583,585.65,588.15,589.65,591.05,592.45,593.8,595.2,597.3,599.5 },
						  y = { 593.1,590.7,588.1,585.3,582.25,578.85,575.25,571.35,567.45,563.35,559,554.55,549.95,545.35,540.6,535.8,530.95,531.7,532.3,532.85,533.35,533.8,534,533.95,534.1,533.65,533.1,532.45,531.65,532.35,533.1,533.75,534.4,535.05,535.5,535.9,536.05,536.65,536.7,536.75,536.65,536.55,537.35,538.1,538.8,539.45,539.4,553.1,566.15,577.9,588.15,596.35,602.4,605.95,607.05,605.65,602.05,596.3,588.95,580.2,580.15,580.15,580.15,580.15,580.15,580.15,580.15,580.1,580.1,580.1,580.1,580.1,580.1,580.1,580.1,580.1,580.1,580.1,580.1,580.15,579.85,579.7,579.5,579.35,579.1,581.95,584.75,587.45,590.2,592.7,595.25,597.65,600.75,603.5,606.05,608.2,610.1,611.45,612.45,613.15,613.3,613,612.35,612.35,612.35,612.35,612.35,612.35,612.35,612.35,610.15,607.45,604.15,600.15,595.75,597.6,599.25,600.9,602.45,603.85,605.15,606.4,607.95,609.35,610.5,611.5,612.3,611.2,609.95,608.55,607.05,605.4,604.25,603.2,602.1,600.9,599.7,597.5,595.35 },
						  rotation = { -6.9355621337890625,-13.871551513671875,-20.807037353515625,-27.74237060546875,-34.67915344238281,-41.61531066894531,-48.55029296875,-55.486724853515625,-62.42155456542969,-69.358154296875,-76.294189453125,-83.22990417480469,-90.16436767578125,-97.10090637207031,-104.03706359863281,-110.97186279296875,-117.9078369140625,-110.53150939941406,-103.15330505371094,-95.77671813964844,-88.39964294433594,-81.02207946777344,-73.64450073242188,-66.26870727539063,-76.59410095214844,-86.92031860351563,-97.24635314941406,-107.57438659667969,-117.90101623535156,-111.44676208496094,-104.99240112304688,-98.53726196289063,-92.08245849609375,-85.63017272949219,-79.17524719238281,-72.72087097167969,-66.26724243164063,-76.59327697753906,-86.92031860351563,-97.24635314941406,-107.57438659667969,-117.90101623535156,-107.57438659667969,-97.24635314941406,-86.91944885253906,-76.59327697753906,-66.26724243164063,-52.30882263183594,-38.3514404296875,-24.393875122070313,-10.437118530273438,3.520599365234375,17.477401733398438,31.434829711914063,45.3924560546875,59.34941101074219,73.30781555175781,87.26475524902344,101.22062683105469,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,115.17787170410156,116.005615234375,116.83160400390625,117.65737915039063,118.48506164550781,119.31126403808594,115.00865173339844,110.70382690429688,106.39895629882813,102.09690856933594,97.79371643066406,93.4901123046875,89.18611145019531,83.16180419921875,77.13551330566406,71.11016845703125,65.08619689941406,59.059112548828125,53.03404235839844,47.007965087890625,40.982696533203125,34.957855224609375,28.931625366210938,22.90631103515625,22.907791137695313,22.907791137695313,22.907791137695313,22.907791137695313,22.907791137695313,22.907791137695313,22.907791137695313,23.10260009765625,23.2998046875,23.495681762695313,23.69097900390625,23.887161254882813,25.331619262695313,26.77587890625,28.220993041992188,29.664993286132813,31.1097412109375,32.5540771484375,33.99845886230469,31.780426025390625,29.561904907226563,27.344406127929688,25.125579833984375,22.908538818359375,20.61810302734375,18.326034545898438,16.035415649414063,13.744598388671875,11.45428466796875,10.07904052734375,8.70562744140625,7.330657958984375,5.9566650390625,4.58184814453125,2.2910919189453125,0 },
						 },
						},
						 x = 50,
						 y = -110,
						 scale = 1/2.5,
						 speed = 0.5
						}
		girl2Animation.hide()
		
		local girl3OpenEyes = display.newImage("assets/idleGirls/mary/EyesOpen.png")
		local girl3ClosedEyes = display.newImage("assets/idleGirls/mary/EyesClosed.png")
		
		local girl3Blinks = ui.blink(girl2OpenEyes,girl2ClosedEyes)
		
		local girl3Animation = ui.newAnimation{
						 comps = {
						 {
						 --lknee
						 path = "assets/idleGirls/mary/lknee.png",
						 x = { 820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,820.5,821.45,822.45,823.45,824.45,825.45,826.45,827.45,828.45,829.45,830.4,831.4,832.4,833.35,834.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,835.35,834.45,833.6,832.75,831.85,831,830.15,829.25,828.4,827.5,826.65,825.75,824.9,824,823.1,822.25,821.35,820.5 },
						 y = { 760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.8,760.75,760.65,760.55,760.45,760.35,760.2,760.05,759.9,759.7,759.5,759.3,759.1,758.85,758.6,758.35,758.35,758.35,758.35,758.35,758.35,758.35,758.35,758.35,758.35,758.35,758.35,758.35,758.35,758.3,758.3,758.3,758.3,758.3,758.3,758.3,758.3,758.3,758.3,758.3,758.3,758.3,758.3,758.3,758.3,758.3,758.3,758.3,758.3,758.55,758.8,759,759.2,759.4,759.55,759.75,759.9,760.05,760.15,760.3,760.4,760.5,760.6,760.7,760.75,760.8 },
						 rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.004364013671875,0.009613037109375,0.014862060546875,0.020111083984375,0.025360107421875,0.0305938720703125,0.0358428955078125,0.0410919189453125,0.0463409423828125,0.05157470703125,0.05682373046875,0.06207275390625,0.06732177734375,0.07257080078125,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.076934814453125,0.076934814453125,0.076934814453125,0.076934814453125,0.076934814453125,0.076934814453125,0.076934814453125,0.07257080078125,0.0681915283203125,0.0638275146484375,0.0594482421875,0.05419921875,0.049835205078125,0.0454559326171875,0.0410919189453125,0.0358428955078125,0.0314788818359375,0.027099609375,0.022735595703125,0.017486572265625,0.0131072998046875,0.0087432861328125,0.004364013671875,0 },
						 },{
						 --lhip
						 path = "assets/idleGirls/mary/lhip.png",
						 x = { 827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.45,827.9,828.3,828.7,829.15,829.55,829.9,830.35,830.75,831.2,831.6,831.95,832.45,832.8,833.25,833.6,833.6,833.6,833.6,833.6,833.55,833.55,833.55,833.55,833.55,833.55,833.55,833.55,833.55,833.55,833.5,833.5,833.5,833.5,833.5,833.5,833.5,833.5,833.5,833.5,833.5,833.5,833.5,833.5,833.55,833.55,833.55,833.55,833.55,833.2,832.85,832.5,832.1,831.8,831.4,831.1,830.7,830.35,830,829.65,829.25,828.95,828.55,828.2,827.8,827.45 },
						 y = { 703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.85,703.8,703.7,703.65,703.6,703.45,703.3,703.2,703.15,703.05,702.9,702.75,702.6,702.45,702.4,702.2,702.2,702.2,702.2,702.2,702.2,702.2,702.2,702.2,702.2,702.2,702.2,702.2,702.2,702.15,702.2,702.2,702.2,702.2,702.2,702.2,702.2,702.2,702.2,702.25,702.25,702.25,702.25,702.25,702.25,702.25,702.25,702.25,702.25,702.35,702.45,702.55,702.65,702.8,702.9,703,703.1,703.25,703.3,703.4,703.5,703.6,703.65,703.8,703.8,703.85 },
						 rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.8890533447265625,-1.7785491943359375,-2.6689453125,-3.5571746826171875,-4.447174072265625,-5.33502197265625,-6.225494384765625,-7.11468505859375,-8.003875732421875,-8.892608642578125,-9.781295776367188,-10.672012329101563,-11.56005859375,-12.450836181640625,-13.34051513671875,-13.34051513671875,-13.34051513671875,-13.34051513671875,-13.34051513671875,-13.34051513671875,-13.34051513671875,-13.34051513671875,-13.34051513671875,-13.34051513671875,-13.34051513671875,-13.34051513671875,-13.34051513671875,-13.34051513671875,-13.34051513671875,-13.341354370117188,-13.341354370117188,-13.341354370117188,-13.341354370117188,-13.341354370117188,-13.341354370117188,-13.341354370117188,-13.341354370117188,-13.341354370117188,-13.341354370117188,-13.341354370117188,-13.341354370117188,-13.341354370117188,-13.341354370117188,-13.341354370117188,-13.341354370117188,-13.341354370117188,-13.341354370117188,-13.341354370117188,-12.556671142578125,-11.770523071289063,-10.985763549804688,-10.202728271484375,-9.418365478515625,-8.63299560546875,-7.846923828125,-7.062164306640625,-6.2781982421875,-5.4944610595703125,-4.71038818359375,-3.9254150390625,-3.1407012939453125,-2.355682373046875,-1.5706634521484375,-0.7850341796875,0 },
						 },{
						 --lfoot
						 path = "assets/idleGirls/mary/lfoot.png",
						 x = { 825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,825.55,826.55,827.55,828.55,829.55,830.55,831.5,832.5,833.5,834.45,835.45,836.45,837.4,838.4,839.35,840.3,840.3,840.3,840.3,840.3,840.3,840.3,840.3,840.3,840.3,840.3,840.3,840.3,840.3,840.25,840.25,840.25,840.25,840.25,840.25,840.25,840.25,840.25,840.25,840.25,840.25,840.25,840.25,840.25,840.25,840.25,840.25,840.25,840.2,839.4,838.55,837.65,836.8,835.95,835.1,834.25,833.4,832.5,831.65,830.8,829.9,829.05,828.2,827.3,826.45,825.55 },
						 y = { 802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,802.05,801.95,801.85,801.75,801.65,801.5,801.35,801.2,801,800.8,800.6,800.4,800.15,799.9,799.65,799.65,799.65,799.65,799.65,799.65,799.65,799.65,799.65,799.65,799.65,799.65,799.65,799.65,799.6,799.6,799.6,799.6,799.6,799.6,799.6,799.6,799.6,799.6,799.6,799.6,799.6,799.6,799.6,799.6,799.6,799.6,799.6,799.6,799.85,800.1,800.3,800.5,800.7,800.85,801.05,801.2,801.35,801.45,801.6,801.7,801.8,801.9,802,802.05,802.05 },
						 rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.004364013671875,0.009613037109375,0.014862060546875,0.020111083984375,0.025360107421875,0.0305938720703125,0.0358428955078125,0.0410919189453125,0.0463409423828125,0.05157470703125,0.05682373046875,0.06207275390625,0.06732177734375,0.07257080078125,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.0778045654296875,0.076934814453125,0.076934814453125,0.076934814453125,0.076934814453125,0.07257080078125,0.0681915283203125,0.0638275146484375,0.0594482421875,0.05419921875,0.049835205078125,0.0454559326171875,0.0410919189453125,0.0358428955078125,0.0314788818359375,0.027099609375,0.022735595703125,0.017486572265625,0.0131072998046875,0.0087432861328125,0.004364013671875,0 },
						 },{
						 --rknee
						 path = "assets/idleGirls/mary/rknee.png",
						 x = { 789.9,789.25,788.7,788,787.35,786.8,786.15,785.5,784.9,784.25,783.6,782.95,782.35,781.7,781.15,781.2,781.35,781.4,781.55,781.65,781.8,781.95,782,782.1,782.25,782.4,782.5,782.55,782.65,782.5,782.35,782.2,782.05,781.95,781.75,781.65,781.45,781.4,781.15,781.1,780.85,780.65,780.5,780.35,780.5,780.65,780.85,781.1,781.15,781.4,781.45,781.65,781.75,781.95,782.05,782.2,782.35,782.5,782.65,782.5,782.35,782.2,782.05,781.95,781.75,781.65,781.45,781.4,781.15,781.1,780.85,780.65,780.5,780.35,780.7,781.1,781.45,781.9,782.2,782.65,783.05,783.4,783.7,784.15,784.45,784.85,785.2,785.6,785.95,785.95,785.95,785.95,785.95,785.95,785.95,785.95,785.95,785.95,785.95,785.95,785.95,785.95,785.9,785.9,785.9,785.9,785.9,785.9,785.9,785.9,785.9,785.9,785.9,785.9,785.9,785.9,785.9,785.9,785.9,785.9,785.9,785.9,786.25,786.45,786.75,787,787.3,787.55,787.8,788.1,788.4,788.6,788.95,789.25,789.45,789.7,790,790.35,790.5 },
						 y = { 760.85,760.8,760.85,760.8,760.75,760.75,760.7,760.7,760.6,760.6,760.55,760.4,760.4,760.3,760.2,760.15,760.1,760.1,760,760,759.95,759.95,759.85,759.8,759.75,759.7,759.65,759.65,759.5,759.55,759.55,759.55,759.7,759.7,759.65,759.75,759.8,759.75,759.85,759.9,759.9,759.9,759.9,759.95,759.9,759.9,759.9,759.9,759.85,759.75,759.8,759.75,759.65,759.7,759.7,759.55,759.55,759.55,759.5,759.55,759.55,759.55,759.7,759.7,759.65,759.75,759.8,759.75,759.85,759.9,759.9,759.9,759.9,759.95,760.15,760.2,760.3,760.4,760.55,760.65,760.75,760.85,760.9,761.05,761.1,761.2,761.3,761.35,761.5,761.5,761.5,761.5,761.5,761.5,761.5,761.5,761.5,761.5,761.5,761.5,761.45,761.45,761.45,761.45,761.45,761.45,761.45,761.45,761.45,761.45,761.45,761.45,761.45,761.45,761.45,761.45,761.45,761.45,761.45,761.45,761.45,761.45,761.4,761.45,761.4,761.35,761.35,761.35,761.25,761.25,761.2,761.2,761.15,761.1,761,761,760.95,760.9,760.8 },
						 rotation = { 0.13201904296875,0.263153076171875,0.3951568603515625,0.5262908935546875,0.658294677734375,0.7894134521484375,0.9214019775390625,1.052490234375,1.1835784912109375,1.31640625,1.447479248046875,1.5793914794921875,1.7104339599609375,1.8414459228515625,1.97418212890625,1.517364501953125,1.06036376953125,0.6032257080078125,0.146881103515625,-0.3086090087890625,-0.7649383544921875,-1.2229156494140625,-1.6781005859375,-2.1348419189453125,-2.5912933349609375,-3.04742431640625,-3.504913330078125,-3.9602203369140625,-4.418487548828125,-4.053314208984375,-3.68865966796875,-3.3271942138671875,-2.9619903564453125,-2.5982818603515625,-2.2343597412109375,-1.8702545166015625,-1.50775146484375,-1.14251708984375,-0.7789154052734375,-0.4152679443359375,-0.0507049560546875,0.312103271484375,0.67578125,1.0393829345703125,0.67578125,0.312103271484375,-0.0507049560546875,-0.4152679443359375,-0.7789154052734375,-1.14251708984375,-1.50775146484375,-1.8702545166015625,-2.2343597412109375,-2.5982818603515625,-2.9619903564453125,-3.3271942138671875,-3.68865966796875,-4.053314208984375,-4.418487548828125,-4.053314208984375,-3.68865966796875,-3.3271942138671875,-2.9619903564453125,-2.5982818603515625,-2.2343597412109375,-1.8702545166015625,-1.50775146484375,-1.14251708984375,-0.7789154052734375,-0.4152679443359375,-0.0507049560546875,0.312103271484375,0.67578125,1.0393829345703125,1.1818389892578125,1.3251495361328125,1.46844482421875,1.61083984375,1.7541046142578125,1.8973388671875,2.0405426025390625,2.182861328125,2.326019287109375,2.469146728515625,2.61224365234375,2.75531005859375,2.8983306884765625,3.0404510498046875,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,2.9968719482421875,2.80938720703125,2.622711181640625,2.4351043701171875,2.2474517822265625,2.0606231689453125,1.873748779296875,1.685089111328125,1.4981536865234375,1.3111724853515625,1.123291015625,0.936248779296875,0.748321533203125,0.5612640380859375,0.374176025390625,0.1870880126953125,0.0008697509765625 },
						 },{
						 --rhip
						 path = "assets/idleGirls/mary/rhip.png",
						 x = { 783.35,783.15,783,782.9,782.65,782.4,782.2,782.05,781.85,781.65,781.6,781.35,781.2,781,780.75,780.75,780.75,780.75,780.75,780.7,780.75,780.7,780.65,780.65,780.65,780.6,780.65,780.65,780.6,780.55,780.6,780.55,780.6,780.6,780.5,780.5,780.55,780.5,780.5,780.55,780.45,780.5,780.5,780.5,780.5,780.5,780.45,780.55,780.5,780.5,780.55,780.5,780.5,780.6,780.6,780.55,780.6,780.55,780.6,780.55,780.6,780.55,780.6,780.6,780.5,780.5,780.55,780.5,780.5,780.55,780.45,780.5,780.5,780.5,780.7,780.9,781.2,781.35,781.65,781.85,782.15,782.3,782.6,782.75,783.05,783.25,783.55,783.7,784,784,784,784,784,784,784,784,784,784.05,784.05,784.05,784.05,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,783.95,783.9,783.9,783.8,783.85,783.75,783.75,783.8,783.7,783.8,783.65,783.7,783.6,783.6,783.65,783.6,783.55 },
						 y = { 703.85,703.85,703.85,703.75,703.8,703.75,703.7,703.65,703.7,703.6,703.5,703.55,703.45,703.4,703.35,703.35,703.35,703.4,703.35,703.35,703.35,703.3,703.35,703.3,703.3,703.35,703.3,703.3,703.3,703.3,703.3,703.3,703.3,703.3,703.3,703.3,703.25,703.25,703.25,703.25,703.25,703.25,703.3,703.2,703.3,703.25,703.25,703.25,703.25,703.25,703.25,703.3,703.3,703.3,703.3,703.3,703.3,703.3,703.3,703.3,703.3,703.3,703.3,703.3,703.3,703.3,703.25,703.25,703.25,703.25,703.25,703.25,703.3,703.2,703.4,703.4,703.5,703.55,703.6,703.7,703.75,703.85,703.95,704,704.05,704.15,704.25,704.25,704.35,704.35,704.35,704.35,704.35,704.35,704.35,704.35,704.35,704.3,704.3,704.3,704.3,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.25,704.2,704.2,704.15,704.15,704.05,704.1,704.05,704,704,703.95,703.95,703.9 },
						 rotation = { 0.609344482421875,1.21942138671875,1.8274688720703125,2.4377288818359375,3.0465545654296875,3.6547088623046875,4.263763427734375,4.87359619140625,5.4832000732421875,6.0924072265625,6.70111083984375,7.310882568359375,7.918975830078125,8.528717041015625,9.137359619140625,9.177413940429688,9.218307495117188,9.258331298828125,9.298355102539063,9.338363647460938,9.377517700195313,9.418365478515625,9.458358764648438,9.498321533203125,9.538299560546875,9.5782470703125,9.617355346679688,9.65814208984375,9.698074340820313,9.733749389648438,9.767715454101563,9.803375244140625,9.839019775390625,9.874664306640625,9.910293579101563,9.945083618164063,9.979843139648438,10.015457153320313,10.051071166992188,10.086669921875,10.12225341796875,10.156982421875,10.19256591796875,10.228118896484375,10.19256591796875,10.156982421875,10.12225341796875,10.086669921875,10.051071166992188,10.015457153320313,9.979843139648438,9.945083618164063,9.910293579101563,9.874664306640625,9.839019775390625,9.803375244140625,9.767715454101563,9.733749389648438,9.698074340820313,9.733749389648438,9.767715454101563,9.803375244140625,9.839019775390625,9.874664306640625,9.910293579101563,9.945083618164063,9.979843139648438,10.015457153320313,10.051071166992188,10.086669921875,10.12225341796875,10.156982421875,10.19256591796875,10.228118896484375,9.936599731445313,9.646240234375,9.355392456054688,9.064910888671875,8.774810791015625,8.485107421875,8.194961547851563,7.9044036865234375,7.6134185791015625,7.3229217529296875,7.0320281982421875,6.7425079345703125,6.4517669677734375,6.1606903076171875,5.8701629638671875,5.87103271484375,5.87103271484375,5.87103271484375,5.87103271484375,5.87103271484375,5.87103271484375,5.87103271484375,5.87103271484375,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.8693084716796875,5.5247802734375,5.178985595703125,4.83453369140625,4.4888763427734375,4.1428985595703125,3.7974853515625,3.4526519775390625,3.1067047119140625,2.7622833251953125,2.416778564453125,2.0719757080078125,1.7261505126953125,1.381072998046875,1.0350189208984375,0.68975830078125,0.344451904296875,0.0008697509765625 },
						 },{
						 --rfoot
						 path = "assets/idleGirls/mary/rfoot.png",
						 x = { 784.75,784.05,783.4,782.55,781.85,781.1,780.4,779.7,779,778.2,777.5,776.75,776.05,775.4,774.7,775.1,775.5,775.95,776.4,776.9,777.3,777.7,778.15,778.6,779.05,779.5,780,780.35,780.85,780.4,780,779.55,779.15,778.75,778.35,777.95,777.5,777.1,776.65,776.35,775.8,775.4,775,774.55,775,775.4,775.8,776.35,776.65,777.1,777.5,777.95,778.35,778.75,779.15,779.55,780,780.4,780.85,780.4,780,779.55,779.15,778.75,778.35,777.95,777.5,777.1,776.65,776.35,775.8,775.4,775,774.55,774.85,775.1,775.4,775.7,775.95,776.2,776.45,776.75,777.1,777.3,777.6,777.9,778.2,778.4,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,778.7,779.1,779.45,779.85,780.3,780.7,781.1,781.45,781.9,782.25,782.65,783.15,783.5,783.9,784.25,784.65,785.15,785.5 },
						 y = { 802.05,802.05,802.1,802,801.9,801.95,801.85,801.8,801.8,801.75,801.6,801.55,801.5,801.45,801.3,801.3,801.3,801.3,801.3,801.3,801.3,801.25,801.25,801.2,801.15,801.15,801.05,801.15,801.05,801.1,801.1,801.1,801.1,801.15,801.15,801.15,801.15,801.15,801.15,801.2,801.15,801.1,801.15,801.1,801.15,801.1,801.15,801.2,801.15,801.15,801.15,801.15,801.15,801.15,801.1,801.1,801.1,801.1,801.05,801.1,801.1,801.1,801.1,801.15,801.15,801.15,801.15,801.15,801.15,801.2,801.15,801.1,801.15,801.1,801.2,801.3,801.35,801.45,801.6,801.7,801.8,801.85,801.95,801.95,802.1,802.2,802.25,802.3,802.35,802.35,802.35,802.35,802.35,802.35,802.35,802.35,802.35,802.35,802.35,802.35,802.35,802.35,802.3,802.3,802.3,802.3,802.3,802.3,802.3,802.3,802.3,802.3,802.3,802.3,802.3,802.3,802.3,802.3,802.3,802.3,802.3,802.3,802.4,802.4,802.35,802.4,802.4,802.35,802.3,802.4,802.25,802.3,802.35,802.25,802.2,802.2,802.1,802.15,802.05 },
						 rotation = { 0.13201904296875,0.263153076171875,0.3951568603515625,0.5262908935546875,0.658294677734375,0.7894134521484375,0.9214019775390625,1.052490234375,1.1835784912109375,1.31640625,1.447479248046875,1.5793914794921875,1.7104339599609375,1.8414459228515625,1.97418212890625,1.517364501953125,1.06036376953125,0.6032257080078125,0.146881103515625,-0.3086090087890625,-0.7649383544921875,-1.2229156494140625,-1.6781005859375,-2.1348419189453125,-2.5912933349609375,-3.04742431640625,-3.504913330078125,-3.9602203369140625,-4.418487548828125,-4.053314208984375,-3.68865966796875,-3.3271942138671875,-2.9619903564453125,-2.5982818603515625,-2.2343597412109375,-1.8702545166015625,-1.50775146484375,-1.14251708984375,-0.7789154052734375,-0.4152679443359375,-0.0507049560546875,0.312103271484375,0.67578125,1.0393829345703125,0.67578125,0.312103271484375,-0.0507049560546875,-0.4152679443359375,-0.7789154052734375,-1.14251708984375,-1.50775146484375,-1.8702545166015625,-2.2343597412109375,-2.5982818603515625,-2.9619903564453125,-3.3271942138671875,-3.68865966796875,-4.053314208984375,-4.418487548828125,-4.053314208984375,-3.68865966796875,-3.3271942138671875,-2.9619903564453125,-2.5982818603515625,-2.2343597412109375,-1.8702545166015625,-1.50775146484375,-1.14251708984375,-0.7789154052734375,-0.4152679443359375,-0.0507049560546875,0.312103271484375,0.67578125,1.0393829345703125,1.1818389892578125,1.3251495361328125,1.46844482421875,1.61083984375,1.7541046142578125,1.8973388671875,2.0405426025390625,2.182861328125,2.326019287109375,2.469146728515625,2.61224365234375,2.75531005859375,2.8983306884765625,3.0404510498046875,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,3.1842803955078125,2.9968719482421875,2.80938720703125,2.622711181640625,2.4351043701171875,2.2474517822265625,2.0606231689453125,1.873748779296875,1.685089111328125,1.4981536865234375,1.3111724853515625,1.123291015625,0.936248779296875,0.748321533203125,0.5612640380859375,0.374176025390625,0.1870880126953125,0.0008697509765625 },
						 },{
						  --buds
						 path = "assets/budsDeFrente.png",
						 scale = 0.25,
						 yOffset = -50,
						 xOffset = -5,
						 x = { 807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.1,807.15,807.2,807.25,807.3,807.35,807.4,807.4,807.45,807.5,807.55,807.6,807.65,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.6,807.55,807.55,807.5,807.45,807.45,807.4,807.35,807.3,807.3,807.25,807.2,807.2,807.15,807.1,807.05 },
						 y = { 649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1 },
						 rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.1599884033203125,-0.3208465576171875,-0.4817047119140625,-0.6425628662109375,-0.8033905029296875,-0.963348388671875,-1.1241607666015625,-1.2849578857421875,-1.447479248046875,-1.6073455810546875,-1.7680816650390625,-1.9279022216796875,-2.0903167724609375,-2.24920654296875,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.2675323486328125,-2.126983642578125,-1.9837799072265625,-1.842315673828125,-1.701690673828125,-1.5601806640625,-1.41864013671875,-1.2753448486328125,-1.1337738037109375,-0.9921875,-0.8497161865234375,-0.7081146240234375,-0.566497802734375,-0.4248809814453125,-0.28326416015625,-0.141632080078125,0 },
						 },{
						 --body
						 path = "assets/idleGirls/mary/body.png",
						 x = { 807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.1,807.15,807.2,807.25,807.3,807.35,807.4,807.4,807.45,807.5,807.55,807.6,807.65,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.7,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.65,807.6,807.55,807.55,807.5,807.45,807.45,807.4,807.35,807.3,807.3,807.25,807.2,807.2,807.15,807.1,807.05 },
						 y = { 649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.05,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1,649.1 },
						 rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.1599884033203125,-0.3208465576171875,-0.4817047119140625,-0.6425628662109375,-0.8033905029296875,-0.963348388671875,-1.1241607666015625,-1.2849578857421875,-1.447479248046875,-1.6073455810546875,-1.7680816650390625,-1.9279022216796875,-2.0903167724609375,-2.24920654296875,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.4098052978515625,-2.2675323486328125,-2.126983642578125,-1.9837799072265625,-1.842315673828125,-1.701690673828125,-1.5601806640625,-1.41864013671875,-1.2753448486328125,-1.1337738037109375,-0.9921875,-0.8497161865234375,-0.7081146240234375,-0.566497802734375,-0.4248809814453125,-0.28326416015625,-0.141632080078125,0 },
						 },{
						 --larm
						 path = "assets/idleGirls/mary/larm.png",
						 x = { 852.6,851.95,851.3,850.6,849.9,849.15,848.45,847.7,846.95,846.2,845.45,844.65,843.9,843.15,842.35,842.55,842.8,843.05,843.15,843.4,843.6,843.85,844.1,844.3,844.5,844.7,844.9,845.15,845.35,845.3,845.25,845.2,845.15,845.1,845.05,845,844.95,844.9,844.85,844.8,844.75,844.7,844.65,844.6,844.65,844.7,844.75,844.8,844.85,844.9,844.95,845,845.05,845.1,845.15,845.2,845.25,845.3,845.35,845.3,845.25,845.2,845.15,845.1,845.05,845,844.95,844.9,844.85,844.8,844.75,844.7,844.65,844.6,845.2,845.8,846.4,847,847.6,848.2,848.8,849.25,849.85,850.35,850.85,851.4,851.9,852.4,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.9,852.85,852.9,852.9,852.95,853,853,853.05,853,853.1,853.05,853.15,853.15,853.2,853.15,853.25,853.2,853.25 },
						 y = { 615.35,615.7,616.1,616.45,616.85,617.1,617.35,617.55,617.7,617.9,618,618.1,618.15,618.2,618.2,618.3,618.25,618.25,618.25,618.2,618.15,618.15,618.15,618.15,618.1,618.1,618.1,618,618.05,618.05,618.05,618.05,618.05,618.05,618.05,618.05,618.1,618.1,618.1,618.05,618.1,618.1,618.15,618.05,618.15,618.1,618.1,618.05,618.1,618.1,618.1,618.05,618.05,618.05,618.05,618.05,618.05,618.05,618.05,618.05,618.05,618.05,618.05,618.05,618.05,618.05,618.1,618.1,618.1,618.05,618.1,618.1,618.15,618.05,617.95,617.7,617.45,617.15,616.9,616.55,616.25,615.85,615.4,615,614.55,614,613.55,613.1,612.45,612.45,612.45,612.45,612.4,612.4,612.4,612.4,612.4,612.4,612.4,612.4,612.4,612.4,612.35,612.35,612.35,612.35,612.35,612.35,612.35,612.35,612.35,612.35,612.35,612.35,612.35,612.35,612.35,612.35,612.35,612.35,612.35,612.3,612.5,612.75,612.8,613.05,613.15,613.3,613.45,613.6,613.7,613.9,614,614.2,614.4,614.5,614.6,614.8,614.9 },
						 rotation = { 2.3792572021484375,4.7590179443359375,7.1387939453125,9.51959228515625,11.898666381835938,14.278717041015625,16.659286499023438,19.038406372070313,21.419479370117188,23.799392700195313,26.1790771484375,28.559295654296875,30.939605712890625,33.31950378417969,35.6986083984375,35.030609130859375,34.36224365234375,33.69451904296875,33.02610778808594,32.35737609863281,31.688720703125,31.02056884765625,30.352035522460938,29.684127807617188,29.01458740234375,28.347091674804688,27.678634643554688,27.010238647460938,26.340805053710938,26.492965698242188,26.644729614257813,26.796783447265625,26.948440551757813,27.099685668945313,27.25189208984375,27.403701782226563,27.555084228515625,27.7060546875,27.858657836914063,28.010162353515625,28.161224365234375,28.313217163085938,28.465469360351563,28.616592407226563,28.465469360351563,28.313217163085938,28.161224365234375,28.010162353515625,27.858657836914063,27.7060546875,27.555084228515625,27.403701782226563,27.25189208984375,27.099685668945313,26.948440551757813,26.796783447265625,26.644729614257813,26.492965698242188,26.340805053710938,26.492965698242188,26.644729614257813,26.796783447265625,26.948440551757813,27.099685668945313,27.25189208984375,27.403701782226563,27.555084228515625,27.7060546875,27.858657836914063,28.010162353515625,28.161224365234375,28.313217163085938,28.465469360351563,28.616592407226563,26.420791625976563,24.225418090820313,22.029861450195313,19.834503173828125,17.639511108398438,15.443374633789063,13.247787475585938,11.05145263671875,8.856765747070313,6.66058349609375,4.4645538330078125,2.2692718505859375,0.0734405517578125,-2.1217498779296875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.3176727294921875,-4.06201171875,-3.8087921142578125,-3.5554351806640625,-3.3028106689453125,-3.04742431640625,-2.7936859130859375,-2.539825439453125,-2.285858154296875,-2.032684326171875,-1.777679443359375,-1.525238037109375,-1.2718505859375,-1.0157928466796875,-0.7623138427734375,-0.5079345703125,-0.2544097900390625,-0.0008697509765625 },
						 },{
						 --rarm
						 path = "assets/idleGirls/mary/rarm.png",
						 x = { 755.5,756.05,756.55,757.05,757.6,758.2,758.8,759.35,759.85,760.5,761.1,761.65,762.35,762.95,763.5,763.55,763.45,763.35,763.3,763.2,763.2,763.15,763.05,763,763,762.9,762.8,762.75,762.7,762.6,762.6,762.5,762.35,762.3,762.2,762.15,762.15,762.05,762,761.9,761.85,761.7,761.7,761.65,761.7,761.7,761.85,761.9,762,762.05,762.15,762.15,762.2,762.3,762.35,762.5,762.6,762.6,762.7,762.6,762.6,762.5,762.35,762.3,762.2,762.15,762.15,762.05,762,761.9,761.85,761.7,761.7,761.65,761,760.4,759.8,759.25,758.65,758.05,757.45,756.9,756.35,755.75,755.2,754.7,754.1,753.65,753.1,753.8,754.5,755.2,755.9,756.65,757.4,758.15,758.95,759.7,760.5,761.35,762.15,763,763.8,763.8,763.8,763.8,763.8,763.8,763.8,763.8,763.8,763.8,763.8,763.8,763.8,763.8,763.8,763.8,763.8,763.8,763.8,763.8,763.25,762.65,762.1,761.5,760.95,760.45,759.9,759.35,758.85,758.3,757.8,757.25,756.75,756.35,755.85,755.35,755 },
						 y = { 615.45,615.85,616.15,616.45,616.8,617.15,617.4,617.65,617.9,618.15,618.35,618.55,618.75,618.9,619.05,619,619,619.05,618.95,618.95,619,618.9,618.9,618.9,618.9,618.85,618.85,618.8,618.8,618.8,618.75,618.8,618.7,618.75,618.7,618.65,618.65,618.6,618.6,618.65,618.6,618.55,618.5,618.5,618.5,618.55,618.6,618.65,618.6,618.6,618.65,618.65,618.7,618.75,618.7,618.8,618.75,618.8,618.8,618.8,618.75,618.8,618.7,618.75,618.7,618.65,618.65,618.6,618.6,618.65,618.6,618.55,618.5,618.5,618.5,618.35,618.25,618.15,618.1,617.95,617.8,617.75,617.55,617.35,617.15,616.95,616.75,616.55,616.3,616.8,617.35,617.75,618.25,618.6,618.95,619.3,619.6,619.9,620.2,620.35,620.6,620.7,620.8,620.8,620.8,620.8,620.8,620.8,620.8,620.8,620.8,620.8,620.8,620.8,620.8,620.8,620.8,620.8,620.8,620.8,620.8,620.8,620.6,620.45,620.2,619.95,619.75,619.45,619.1,618.75,618.5,618,617.7,617.3,616.9,616.45,616.05,615.5,615 },
						 rotation = { -1.7209014892578125,-3.4430694580078125,-5.1633758544921875,-6.886444091796875,-8.60736083984375,-10.328842163085938,-12.04925537109375,-13.770980834960938,-15.491287231445313,-17.212936401367188,-18.935211181640625,-20.65484619140625,-22.376083374023438,-24.098785400390625,-25.819595336914063,-25.65643310546875,-25.4935302734375,-25.330917358398438,-25.168563842773438,-25.007217407226563,-24.843292236328125,-24.680374145507813,-24.519195556640625,-24.354705810546875,-24.19342041015625,-24.029525756835938,-23.868148803710938,-23.705642700195313,-23.541259765625,-23.343292236328125,-23.145492553710938,-22.94561767578125,-22.74737548828125,-22.549301147460938,-22.350662231445313,-22.152206420898438,-21.953933715820313,-21.757369995117188,-21.558761596679688,-21.359603881835938,-21.161422729492188,-20.961959838867188,-20.763473510742188,-20.564468383789063,-20.763473510742188,-20.961959838867188,-21.161422729492188,-21.359603881835938,-21.558761596679688,-21.757369995117188,-21.953933715820313,-22.152206420898438,-22.350662231445313,-22.549301147460938,-22.74737548828125,-22.94561767578125,-23.145492553710938,-23.343292236328125,-23.541259765625,-23.343292236328125,-23.145492553710938,-22.94561767578125,-22.74737548828125,-22.549301147460938,-22.350662231445313,-22.152206420898438,-21.953933715820313,-21.757369995117188,-21.558761596679688,-21.359603881835938,-21.161422729492188,-20.961959838867188,-20.763473510742188,-20.564468383789063,-19.128189086914063,-17.6934814453125,-16.256439208984375,-14.82177734375,-13.384384155273438,-11.948043823242188,-10.512359619140625,-9.07427978515625,-7.639190673828125,-6.2021636962890625,-4.765960693359375,-3.328948974609375,-1.89471435546875,-0.4572296142578125,0.97821044921875,-1.281463623046875,-3.5380096435546875,-5.7974853515625,-8.0552978515625,-10.3153076171875,-12.573333740234375,-14.834030151367188,-17.090011596679688,-19.349533081054688,-21.609405517578125,-23.868148803710938,-26.126953125,-28.38568115234375,-30.643478393554688,-30.643478393554688,-30.643478393554688,-30.643478393554688,-30.643478393554688,-30.643478393554688,-30.643478393554688,-30.643478393554688,-30.643478393554688,-30.643478393554688,-30.643478393554688,-30.643478393554688,-30.643478393554688,-30.643478393554688,-30.643478393554688,-30.643478393554688,-30.643478393554688,-30.643478393554688,-30.643478393554688,-30.643478393554688,-28.841140747070313,-27.03936767578125,-25.23583984375,-23.433883666992188,-21.632080078125,-19.82830810546875,-18.024566650390625,-16.224212646484375,-14.420684814453125,-12.617462158203125,-10.816314697265625,-9.012039184570313,-7.2093658447265625,-5.40869140625,-3.605072021484375,-1.8021392822265625,0 },
						 },{
						 --lforearmç
						 path = "assets/idleGirls/mary/lforearm.png",
						 x = { 876.3,874.45,872.4,870.45,868.35,866.25,864.05,861.85,859.7,857.35,855.1,852.8,850.5,848.05,845.75,844.65,843.7,842.7,841.9,841.2,840.7,840.3,840.05,840.05,840.3,840.5,841.05,841.7,842.65,842.4,842.1,841.85,841.65,841.55,841.35,841.3,841.1,841,840.9,840.85,840.9,840.85,840.85,840.9,840.85,840.85,840.9,840.85,840.9,841,841.1,841.3,841.35,841.55,841.65,841.85,842.1,842.4,842.65,842.4,842.1,841.85,841.65,841.55,841.35,841.3,841.1,841,840.9,840.85,840.9,840.85,840.85,840.9,842.8,844.7,846.65,848.65,850.55,852.45,854.5,856.4,858.3,860.35,862.3,864.15,866.05,868,869.8,869.8,869.8,869.8,869.8,869.8,869.8,869.8,869.8,869.8,869.8,869.8,869.8,869.8,869.8,869.85,869.85,869.85,869.85,869.85,869.85,869.85,869.85,869.85,869.85,869.85,869.85,869.85,869.85,869.85,869.85,869.85,869.85,869.85,870.25,870.75,871.3,871.7,872.15,872.65,873.2,873.65,874.25,874.65,875.25,875.7,876.15,876.65,877.2,877.75,878.15 },
						 y = { 649.85,651.2,652.45,653.6,654.8,655.8,656.75,657.65,658.4,659.1,659.7,660.2,660.65,661,661.25,660.45,659.5,658.35,657.05,655.65,654.1,652.5,650.7,648.9,646.95,645.15,643.15,641.2,639.3,639.85,640.55,641.25,641.8,642.45,643.15,643.75,644.45,645.05,645.75,646.3,647.05,647.6,648.25,648.85,648.25,647.6,647.05,646.3,645.75,645.05,644.45,643.75,643.15,642.45,641.8,641.25,640.55,639.85,639.3,639.85,640.55,641.25,641.8,642.45,643.15,643.75,644.45,645.05,645.75,646.3,647.05,647.6,648.25,648.85,649.05,649.15,649.1,649.1,648.9,648.65,648.3,647.9,647.4,646.8,646.15,645.35,644.5,643.5,642.5,642.5,642.5,642.5,642.5,642.5,642.5,642.5,642.5,642.5,642.5,642.5,642.5,642.5,642.45,642.45,642.45,642.45,642.45,642.45,642.45,642.45,642.45,642.45,642.45,642.45,642.45,642.45,642.45,642.45,642.45,642.45,642.45,642.45,642.95,643.45,643.9,644.3,644.75,645.15,645.55,645.95,646.3,646.55,646.95,647.25,647.5,647.75,648,648.1,648.4 },
						 rotation = { 1.7008209228515625,3.400390625,5.1000518798828125,6.800262451171875,8.50048828125,10.200180053710938,11.899490356445313,13.599319458007813,15.29949951171875,16.999710083007813,18.698654174804688,20.398757934570313,22.09893798828125,23.798660278320313,25.499237060546875,31.612060546875,37.7239990234375,43.83763122558594,49.95051574707031,56.06288146972656,62.174835205078125,68.28788757324219,74.39997863769531,80.51358032226563,86.62661743164063,92.73872375488281,98.85163879394531,104.96383666992188,111.07698059082031,108.97822570800781,106.88050842285156,104.78172302246094,102.68238830566406,100.58418273925781,98.485107421875,96.38700866699219,94.28724670410156,92.18983459472656,90.09092712402344,87.99263000488281,85.89450073242188,83.79609680175781,81.6971435546875,79.59754943847656,81.6971435546875,83.79609680175781,85.89450073242188,87.99263000488281,90.09092712402344,92.18983459472656,94.28724670410156,96.38700866699219,98.485107421875,100.58418273925781,102.68238830566406,104.78172302246094,106.88050842285156,108.97822570800781,111.07698059082031,108.97822570800781,106.88050842285156,104.78172302246094,102.68238830566406,100.58418273925781,98.485107421875,96.38700866699219,94.28724670410156,92.18983459472656,90.09092712402344,87.99263000488281,85.89450073242188,83.79609680175781,81.6971435546875,79.59754943847656,76.451904296875,73.3070068359375,70.16085815429688,67.01658630371094,63.87162780761719,60.725311279296875,57.58091735839844,54.43653869628906,51.29118347167969,48.14512634277344,45.00044250488281,41.8553466796875,38.71040344238281,35.56462097167969,32.419708251953125,32.419708251953125,32.419708251953125,32.419708251953125,32.419708251953125,32.419708251953125,32.419708251953125,32.419708251953125,32.419708251953125,32.419708251953125,32.419708251953125,32.419708251953125,32.419708251953125,32.419708251953125,32.419708251953125,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,30.513870239257813,28.607833862304688,26.700576782226563,24.792877197265625,22.886276245117188,20.9794921875,19.071212768554688,17.164260864257813,15.257186889648438,13.350448608398438,11.442520141601563,9.535751342773438,7.628021240234375,5.7213287353515625,3.813140869140625,1.907806396484375,0.0008697509765625 },
						 },{
						 --rforearm
						 path = "assets/idleGirls/mary/rforearm.png",
						 x = { 731.5,732.9,734.25,735.8,737.4,738.95,740.45,742.1,743.75,745.4,747.05,748.75,750.45,752.1,753.85,755.75,757.65,759.4,760.95,762.5,763.85,765.05,766,766.75,767.35,767.6,767.7,767.4,767,767,766.95,766.9,766.75,766.6,766.35,766.2,765.9,765.7,765.3,764.9,764.5,764.1,763.6,763.1,763.6,764.1,764.5,764.9,765.3,765.7,765.9,766.2,766.35,766.6,766.75,766.9,766.95,767,767,767,766.95,766.9,766.75,766.6,766.35,766.2,765.9,765.7,765.3,764.9,764.5,764.1,763.6,763.1,761.5,759.9,758.15,756.45,754.65,752.9,751.1,749.35,747.5,745.65,743.9,742.05,740.2,738.4,736.45,738,739.55,741.1,742.7,744.35,746.05,747.75,749.6,751.45,753.25,755.1,757,758.95,760.9,760.9,760.9,760.9,760.9,760.9,760.9,760.9,760.9,760.9,760.9,760.9,760.9,760.9,760.9,760.9,760.9,760.9,760.9,760.9,758.9,756.95,755.05,753.15,751.25,749.25,747.45,745.6,743.7,741.9,740.15,738.4,736.6,734.9,733.3,731.65,730.1 },
						 y = { 649.5,650.5,651.55,652.55,653.5,654.4,655.3,656.05,656.75,657.45,658.15,658.75,659.25,659.85,660.35,659.9,659.25,658.35,657.2,655.9,654.35,652.75,650.95,649.05,647,644.95,642.85,640.7,638.65,639.4,640.1,640.8,641.55,642.25,643.05,643.7,644.45,645.15,645.85,646.55,647.25,647.95,648.6,649.25,648.6,647.95,647.25,646.55,645.85,645.15,644.45,643.7,643.05,642.25,641.55,640.8,640.1,639.4,638.65,639.4,640.1,640.8,641.55,642.25,643.05,643.7,644.45,645.15,645.85,646.55,647.25,647.95,648.6,649.25,649.65,650,650.25,650.55,650.8,650.85,650.95,650.95,650.85,650.7,650.55,650.35,650,649.55,649.1,650.4,651.65,652.85,653.95,655.05,656.05,657.05,657.9,658.75,659.5,660.2,660.7,661.3,661.75,661.75,661.75,661.75,661.75,661.75,661.75,661.75,661.75,661.75,661.75,661.75,661.75,661.75,661.75,661.75,661.75,661.75,661.75,661.75,661.45,661.15,660.75,660.3,659.75,659.2,658.5,657.75,656.95,656.15,655.2,654.15,653.2,652.05,650.9,649.65,648.4 },
						 rotation = { -1.314666748046875,-2.626190185546875,-3.9393310546875,-5.2500762939453125,-6.56396484375,-7.8752288818359375,-9.187637329101563,-10.501373291015625,-11.813247680664063,-13.1251220703125,-14.437896728515625,-15.751571655273438,-17.062057495117188,-18.374862670898438,-19.688156127929688,-26.462844848632813,-33.23455810546875,-40.00848388671875,-46.781463623046875,-53.55662536621094,-60.329071044921875,-67.10333251953125,-73.87579345703125,-80.64971923828125,-87.42353820800781,-94.19680786132813,-100.97059631347656,-107.74267578125,-114.51774597167969,-111.90353393554688,-109.28880310058594,-106.67373657226563,-104.05928039550781,-101.44503784179688,-98.83030700683594,-96.21598815917969,-93.60072326660156,-90.98695373535156,-88.37255859375,-85.75883483886719,-83.14370727539063,-80.52973937988281,-77.914794921875,-75.30085754394531,-77.914794921875,-80.52973937988281,-83.14370727539063,-85.75883483886719,-88.37255859375,-90.98695373535156,-93.60072326660156,-96.21598815917969,-98.83030700683594,-101.44503784179688,-104.05928039550781,-106.67373657226563,-109.28880310058594,-111.90353393554688,-114.51774597167969,-111.90353393554688,-109.28880310058594,-106.67373657226563,-104.05928039550781,-101.44503784179688,-98.83030700683594,-96.21598815917969,-93.60072326660156,-90.98695373535156,-88.37255859375,-85.75883483886719,-83.14370727539063,-80.52973937988281,-77.914794921875,-75.30085754394531,-72.18202209472656,-69.06549072265625,-65.94712829589844,-62.82969665527344,-59.71376037597656,-56.595733642578125,-53.47920227050781,-50.360748291015625,-47.24371337890625,-44.12641906738281,-41.007598876953125,-37.89044189453125,-34.77482604980469,-31.65643310546875,-28.5404052734375,-29.071395874023438,-29.604888916015625,-30.135421752929688,-30.666122436523438,-31.199371337890625,-31.732376098632813,-32.26307678222656,-32.79627990722656,-33.32743835449219,-33.860626220703125,-34.39320373535156,-34.924957275390625,-35.45570373535156,-35.988128662109375,-35.988128662109375,-35.988128662109375,-35.988128662109375,-35.988128662109375,-35.988128662109375,-35.988128662109375,-35.988128662109375,-35.988128662109375,-35.98756408691406,-35.98756408691406,-35.98756408691406,-35.98756408691406,-35.98756408691406,-35.98756408691406,-35.98756408691406,-35.98756408691406,-35.98756408691406,-35.98756408691406,-35.98756408691406,-33.87147521972656,-31.753250122070313,-29.6365966796875,-27.520034790039063,-25.402999877929688,-23.286529541015625,-21.16827392578125,-19.052459716796875,-16.934921264648438,-14.818496704101563,-12.70068359375,-10.58587646484375,-8.467147827148438,-6.3507537841796875,-4.23333740234375,-2.1165008544921875,-0.0008697509765625 },
						 },{
						 --lhand
						 path = "assets/idleGirls/mary/lhand.png",
						 x = { 884.25,881.4,878.5,875.45,872.45,869.4,866.25,863.05,859.85,856.65,853.35,850.1,846.85,843.45,840.2,835.65,831.35,827.25,823.45,820.05,816.95,814.3,812.1,810.45,809.25,808.7,808.55,809.05,810.05,809.7,809.35,809.2,809,808.95,808.9,808.95,809.05,809.2,809.4,809.75,810.1,810.5,811,811.5,811,810.5,810.1,809.75,809.4,809.2,809.05,808.95,808.9,808.95,809,809.2,809.35,809.7,810.05,809.7,809.35,809.2,809,808.95,808.9,808.95,809.05,809.2,809.4,809.75,810.1,810.5,811,811.5,814.25,817.05,820,823,826.1,829.3,832.6,835.95,839.3,842.75,846.2,849.8,853.3,856.85,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,860.4,861.95,863.4,865,866.5,868.05,869.7,871.25,872.85,874.4,876,877.6,879.15,880.75,882.35,883.9,885.5,887 },
						 y = { 681.6,683.15,684.65,686,687.25,688.4,689.45,690.35,691.15,691.8,692.4,692.85,693.15,693.4,693.4,691.9,689.8,687.2,684.1,680.55,676.65,672.3,667.65,662.75,657.6,652.45,647,641.55,636.15,638,639.85,641.7,643.45,645.3,647.2,649,650.8,652.6,654.45,656.25,658,659.75,661.5,663.2,661.5,659.75,658,656.25,654.45,652.6,650.8,649,647.2,645.3,643.45,641.7,639.85,638,636.15,638,639.85,641.7,643.45,645.3,647.2,649,650.8,652.6,654.45,656.25,658,659.75,661.5,663.2,665,666.6,668.15,669.45,670.7,671.75,672.7,673.4,674,674.4,674.65,674.7,674.6,674.3,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,673.85,674.6,675.35,676.05,676.6,677.2,677.75,678.25,678.65,678.95,679.3,679.5,679.75,679.9,680,679.95,680,679.9 },
						 rotation = { 1.699951171875,3.398651123046875,5.0991973876953125,6.799407958984375,8.4996337890625,10.198486328125,11.898666381835938,13.598495483398438,15.298675537109375,16.99810791015625,18.6978759765625,20.397979736328125,22.098190307617188,23.797195434570313,25.497100830078125,31.610794067382813,37.72291564941406,43.83671569824219,49.948974609375,56.06227111816406,62.17414855957031,68.28712463378906,74.399169921875,80.51272583007813,86.62661743164063,92.73785400390625,98.85078430175781,104.96302795410156,111.07621765136719,108.97744750976563,106.87809753417969,104.78091430664063,102.68154907226563,100.58248901367188,98.4842529296875,96.38615417480469,94.286376953125,92.18896484375,90.09004211425781,87.99176025390625,85.89363098144531,83.79524230957031,81.6962890625,79.59754943847656,81.6962890625,83.79524230957031,85.89363098144531,87.99176025390625,90.09004211425781,92.18896484375,94.286376953125,96.38615417480469,98.4842529296875,100.58248901367188,102.68154907226563,104.78091430664063,106.87809753417969,108.97744750976563,111.07621765136719,108.97744750976563,106.87809753417969,104.78091430664063,102.68154907226563,100.58248901367188,98.4842529296875,96.38615417480469,94.286376953125,92.18896484375,90.09004211425781,87.99176025390625,85.89363098144531,83.79524230957031,81.6962890625,79.59754943847656,76.45272827148438,73.30781555175781,70.16163635253906,67.01806640625,63.872344970703125,60.72663879394531,57.5821533203125,54.43769836425781,51.29225158691406,48.14659118652344,45.00175476074219,41.8568115234375,38.71147155761719,35.565765380859375,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,32.42095947265625,30.513870239257813,28.607833862304688,26.700576782226563,24.792877197265625,22.886276245117188,20.9794921875,19.071212768554688,17.164260864257813,15.257186889648438,13.350448608398438,11.442520141601563,9.535751342773438,7.628021240234375,5.7213287353515625,3.813140869140625,1.907806396484375,0 },
						 },{
						 --rhand
						 path = "assets/idleGirls/mary/rhand.png",
						 x = { 723.35,725.55,727.75,729.95,732.2,734.55,736.85,739.15,741.5,743.9,746.35,748.75,751.25,753.7,756.2,761.95,767.5,772.85,777.9,782.6,786.85,790.65,793.8,796.4,798.35,799.65,800.25,800.15,799.3,799.5,799.6,799.6,799.5,799.3,798.95,798.45,797.95,797.3,796.55,795.75,794.8,793.8,792.65,791.4,792.65,793.8,794.8,795.75,796.55,797.3,797.95,798.45,798.95,799.3,799.5,799.6,799.6,799.5,799.3,799.5,799.6,799.6,799.5,799.3,798.95,798.45,797.95,797.3,796.55,795.75,794.8,793.8,792.65,791.4,788.85,786.1,783.3,780.4,777.45,774.4,771.3,767.95,764.65,761.3,757.85,754.45,750.95,747.45,743.8,745.55,747.45,749.35,751.2,753.1,755.15,757.2,759.2,761.3,763.45,765.6,767.8,770.1,772.3,772.3,772.3,772.3,772.3,772.3,772.3,772.3,772.3,772.3,772.3,772.3,772.3,772.3,772.3,772.3,772.3,772.3,772.3,772.3,769.25,766.1,763.05,759.9,756.8,753.75,750.6,747.6,744.5,741.5,738.5,735.5,732.55,729.65,726.8,724.05,721.25 },
						 y = { 681.2,682.45,683.6,684.75,685.85,686.85,687.8,688.55,689.4,690.2,690.85,691.45,692,692.55,692.9,692,690.35,688.1,685.3,681.75,677.7,673.15,668.25,662.9,657.25,651.5,645.55,639.5,633.65,635.8,638,640.25,642.45,644.7,646.9,649.15,651.3,653.45,655.65,657.75,659.8,661.9,663.85,665.8,663.85,661.9,659.8,657.75,655.65,653.45,651.3,649.15,646.9,644.7,642.45,640.25,638,635.8,633.65,635.8,638,640.25,642.45,644.7,646.9,649.15,651.3,653.45,655.65,657.75,659.8,661.9,663.85,665.8,667.75,669.55,671.25,672.85,674.3,675.65,676.8,677.85,678.8,679.6,680.15,680.6,680.9,681.05,681,682.3,683.5,684.55,685.6,686.6,687.55,688.4,689.2,689.95,690.6,691.25,691.75,692.15,692.55,692.55,692.55,692.55,692.55,692.55,692.55,692.55,692.55,692.55,692.55,692.55,692.55,692.55,692.55,692.55,692.55,692.55,692.55,692.55,692.65,692.7,692.65,692.4,692.1,691.6,691.15,690.5,689.75,688.9,687.9,686.85,685.65,684.4,683.05,681.5,679.9 },
						 rotation = { -1.31378173828125,-2.6253204345703125,-3.9367218017578125,-5.24920654296875,-6.5630950927734375,-7.8743743896484375,-9.187637329101563,-10.500518798828125,-11.813247680664063,-13.125946044921875,-14.437896728515625,-15.7491455078125,-17.062850952148438,-18.37408447265625,-19.686599731445313,-26.460037231445313,-33.23455810546875,-40.0074462890625,-46.78053283691406,-53.55549621582031,-60.32774353027344,-67.10185241699219,-73.87498474121094,-80.64971923828125,-87.42178344726563,-94.19593811035156,-100.96890258789063,-107.74267578125,-114.51557922363281,-111.90202331542969,-109.28724670410156,-106.67292785644531,-104.05763244628906,-101.44419860839844,-98.82859802246094,-96.21513366699219,-93.599853515625,-90.98606872558594,-88.37168884277344,-85.75796508789063,-83.14285278320313,-80.52888488769531,-77.91311645507813,-75.30003356933594,-77.91311645507813,-80.52888488769531,-83.14285278320313,-85.75796508789063,-88.37168884277344,-90.98606872558594,-93.599853515625,-96.21513366699219,-98.82859802246094,-101.44419860839844,-104.05763244628906,-106.67292785644531,-109.28724670410156,-111.90202331542969,-114.51557922363281,-111.90202331542969,-109.28724670410156,-106.67292785644531,-104.05763244628906,-101.44419860839844,-98.82859802246094,-96.21513366699219,-93.599853515625,-90.98606872558594,-88.37168884277344,-85.75796508789063,-83.14285278320313,-80.52888488769531,-77.91311645507813,-75.30003356933594,-72.18202209472656,-69.06549072265625,-65.94786071777344,-62.83038330078125,-59.713104248046875,-56.595733642578125,-53.4786376953125,-50.36126708984375,-47.242767333984375,-44.12641906738281,-41.00859069824219,-37.89154052734375,-34.77482604980469,-31.65643310546875,-28.5404052734375,-29.073394775390625,-29.604888916015625,-30.135421752929688,-30.668060302734375,-31.199371337890625,-31.731109619140625,-32.26432800292969,-32.79627990722656,-33.32865905761719,-33.86003112792969,-34.39201354980469,-34.92378234863281,-35.45570373535156,-35.98870849609375,-35.98870849609375,-35.98870849609375,-35.98870849609375,-35.98870849609375,-35.98870849609375,-35.98870849609375,-35.98870849609375,-35.98870849609375,-35.98870849609375,-35.98870849609375,-35.98870849609375,-35.98870849609375,-35.98870849609375,-35.98870849609375,-35.98870849609375,-35.98870849609375,-35.98870849609375,-35.98870849609375,-35.98870849609375,-33.87147521972656,-31.753250122070313,-29.63726806640625,-27.521408081054688,-25.404434204101563,-23.287994384765625,-21.169784545898438,-19.053237915039063,-16.93572998046875,-14.819320678710938,-12.702346801757813,-10.58587646484375,-8.468002319335938,-6.3516082763671875,-4.2342071533203125,-2.11737060546875,0 },
						 },{
						 --lpigtail
						 path = "assets/idleGirls/mary/lpigtail.png",
						 x = { 866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,866.15,863.85,861.5,859.1,856.75,854.4,852,849.65,847.25,844.8,842.45,840,837.65,835.25,832.85,830.4,834.4,838.25,842.2,846.15,850,853.9,857.85,861.7,865.5,869.35,873.05,876.9,880.55,884.3,882.5,880.65,878.85,877.05,875.25,873.4,871.6,869.75,867.9,866.05,864.2,862.3,860.4,858.55,856.7,854.85,852.9,851.05,849.15,850.2,851.15,852.15,853.15,854.2,855.2,856.2,857.15,858.15,859.15,860.15,861.2,862.2,863.2,864.2,865.2,866.15 },
						 y = { 455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.8,455.15,454.45,453.9,453.35,452.8,452.3,451.8,451.35,450.95,450.55,450.25,449.9,449.6,449.35,449.15,449.5,450,450.5,451.15,451.9,452.7,453.6,454.6,455.65,456.9,458.15,459.5,460.95,462.5,461.75,461.1,460.45,459.8,459.15,458.55,458,457.4,456.85,456.35,455.8,455.3,454.85,454.4,453.9,453.55,453.15,452.75,452.45,452.6,452.75,452.9,453.1,453.3,453.4,453.6,453.85,454.05,454.25,454.45,454.7,454.9,455.1,455.35,455.6,455.8 },
						 rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.2771453857421875,-0.55426025390625,-0.83135986328125,-1.108428955078125,-1.3871917724609375,-1.66412353515625,-1.94012451171875,-2.2177734375,-2.49444580078125,-2.771881103515625,-3.0491790771484375,-3.3271942138671875,-3.605072021484375,-3.88189697265625,-4.157684326171875,-3.809661865234375,-3.46484375,-3.1180419921875,-2.7701263427734375,-2.42376708984375,-2.07720947265625,-1.729644775390625,-1.383697509765625,-1.035888671875,-0.6888885498046875,-0.341827392578125,0.0034942626953125,0.3505706787109375,0.6976318359375,0.611083984375,0.5245513916015625,0.4380035400390625,0.3514556884765625,0.264892578125,0.1783447265625,0.091796875,0.0052490234375,-0.0804290771484375,-0.166107177734375,-0.252655029296875,-0.3392181396484375,-0.4257659912109375,-0.512298583984375,-0.598846435546875,-0.685394287109375,-0.7719268798828125,-0.85845947265625,-0.944122314453125,-0.8890533447265625,-0.8331146240234375,-0.778045654296875,-0.72210693359375,-0.6670379638671875,-0.611083984375,-0.555145263671875,-0.50006103515625,-0.444122314453125,-0.3890380859375,-0.3330841064453125,-0.2771453857421875,-0.2220611572265625,-0.166107177734375,-0.1110382080078125,-0.055084228515625,0 },
						 yOffset = -13,
						 },{
						 --rpigtail
						 path = "assets/idleGirls/mary/rpigtail.png",
						 x = { 740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,740.95,738.55,736.2,733.85,731.5,729.2,726.85,724.55,722.25,720,717.7,715.45,713.2,710.95,708.75,706.55,710.1,713.65,717.25,720.9,724.6,728.3,732.05,735.8,739.6,743.4,747.25,751.1,755,758.9,757,755.15,753.3,751.45,749.6,747.75,745.9,744.05,742.2,740.35,738.55,736.7,734.9,733.1,731.3,729.45,727.65,725.95,724.15,725.1,726.05,727.05,728.05,729.05,730,731,732,732.95,733.95,734.95,735.95,737,737.95,738.95,739.95,740.95 },
						 y = { 458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,458.9,459.65,460.4,461.15,461.95,462.8,463.65,464.55,465.45,466.4,467.35,468.35,469.45,470.5,471.6,472.7,470.85,469.05,467.4,465.8,464.25,462.75,461.4,460.15,458.95,457.9,456.9,456,455.15,454.4,454.7,455.05,455.4,455.8,456.05,456.5,457,457.4,457.9,458.35,458.85,459.35,459.85,460.45,461.05,461.6,462.25,462.75,463.5,463.2,462.85,462.5,462.3,462.05,461.7,461.5,461.2,460.9,460.7,460.4,460.1,459.9,459.65,459.45,459.2,458.9 },
						 rotation = { 0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,0.0008697509765625,-0.2316741943359375,-0.4624786376953125,-0.6941375732421875,-0.924896240234375,-1.1573638916015625,-1.3889312744140625,-1.61871337890625,-1.851043701171875,-2.0807037353515625,-2.31292724609375,-2.5424346923828125,-2.77362060546875,-3.0047149658203125,-3.2374420166015625,-3.46746826171875,-3.1424407958984375,-2.8189697265625,-2.492706298828125,-2.1697540283203125,-1.8466796875,-1.5208587646484375,-1.19757080078125,-0.8715667724609375,-0.547271728515625,-0.222930908203125,0.1005401611328125,0.4248809814453125,0.74920654296875,1.0734710693359375,0.979949951171875,0.8864288330078125,0.79290771484375,0.699371337890625,0.6058349609375,0.512298583984375,0.41876220703125,0.3260955810546875,0.2325592041015625,0.139007568359375,0.0454559326171875,-0.047210693359375,-0.1407623291015625,-0.2342987060546875,-0.327850341796875,-0.42138671875,-0.514923095703125,-0.60845947265625,-0.701995849609375,-0.660919189453125,-0.61895751953125,-0.5778656005859375,-0.5367889404296875,-0.495697021484375,-0.4537353515625,-0.4126434326171875,-0.371551513671875,-0.330474853515625,-0.2884979248046875,-0.2474212646484375,-0.206329345703125,-0.1652374267578125,-0.1232757568359375,-0.082183837890625,-0.0410919189453125,0.0008697509765625 },
						 yOffset = -13,
						 },{
						 --head
						 path = "assets/idleGirls/mary/head.png",
						 x = { 804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,803.45,801.95,800.4,798.95,797.35,795.9,794.4,792.85,791.4,789.85,788.4,786.85,785.35,783.9,782.4,784.6,786.9,789.1,791.35,793.6,795.9,798.1,800.4,802.7,804.95,807.2,809.4,811.75,814,812.9,811.85,810.9,809.8,808.8,807.7,806.75,805.65,804.65,803.55,802.6,801.5,800.45,799.35,798.45,797.35,796.3,795.3,794.25,794.9,795.55,796.15,796.8,797.35,798,798.65,799.25,799.9,800.55,801.2,801.85,802.4,803.05,803.65,804.35,804.95 },
						 y = { 469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,470.05,470.05,470.1,470.2,470.25,470.3,470.55,470.7,470.85,471,471.25,471.5,471.65,472,471.5,471.2,470.9,470.6,470.4,470.3,470.1,470.05,470,470,470.1,470.25,470.4,470.65,470.5,470.45,470.35,470.25,470.2,470.15,470.1,470.05,470.05,470,470.05,470,470.05,470.1,470.15,470.2,470.25,470.3,470.35,470.35,470.3,470.2,470.15,470.2,470.15,470.15,470.1,470.05,470.05,469.95,469.95,469.9,469.95,469.9,469.95,469.95 },
						 rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.7308502197265625,-1.4623260498046875,-2.1924591064453125,-2.92449951171875,-3.65557861328125,-4.385467529296875,-5.1165313720703125,-5.8476715087890625,-6.5786285400390625,-7.30743408203125,-8.040725708007813,-8.769683837890625,-9.502578735351563,-10.234054565429688,-10.963851928710938,-9.733749389648438,-8.503921508789063,-7.2721710205078125,-6.041412353515625,-4.81109619140625,-3.5806884765625,-2.352203369140625,-1.1197967529296875,0.109283447265625,1.34088134765625,2.5703582763671875,3.80096435546875,5.030670166015625,6.26177978515625,5.69708251953125,5.1330108642578125,4.568817138671875,4.005462646484375,3.4413299560546875,2.877410888671875,2.312042236328125,1.74798583984375,1.1835784912109375,0.6198272705078125,0.055084228515625,-0.5079345703125,-1.07171630859375,-1.6379241943359375,-2.2011871337890625,-2.764892578125,-3.3306884765625,-3.89495849609375,-4.458465576171875,-4.195068359375,-3.9332427978515625,-3.6712493896484375,-3.4091033935546875,-3.147674560546875,-2.8861236572265625,-2.6218414306640625,-2.360931396484375,-2.0990447998046875,-1.8353271484375,-1.57415771484375,-1.312042236328125,-1.048126220703125,-0.785919189453125,-0.5236663818359375,-0.2613983154296875,0 },
						 yOffset = -13,
						 },{
						 displayObject = girl3ClosedEyes,
						 scaleComponent = true,
						 x = { 804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,803.45,801.95,800.4,798.95,797.35,795.9,794.4,792.85,791.4,789.85,788.4,786.85,785.35,783.9,782.4,784.6,786.9,789.1,791.35,793.6,795.9,798.1,800.4,802.7,804.95,807.2,809.4,811.75,814,812.9,811.85,810.9,809.8,808.8,807.7,806.75,805.65,804.65,803.55,802.6,801.5,800.45,799.35,798.45,797.35,796.3,795.3,794.25,794.9,795.55,796.15,796.8,797.35,798,798.65,799.25,799.9,800.55,801.2,801.85,802.4,803.05,803.65,804.35,804.95 },
						 y = { 469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,470.05,470.05,470.1,470.2,470.25,470.3,470.55,470.7,470.85,471,471.25,471.5,471.65,472,471.5,471.2,470.9,470.6,470.4,470.3,470.1,470.05,470,470,470.1,470.25,470.4,470.65,470.5,470.45,470.35,470.25,470.2,470.15,470.1,470.05,470.05,470,470.05,470,470.05,470.1,470.15,470.2,470.25,470.3,470.35,470.35,470.3,470.2,470.15,470.2,470.15,470.15,470.1,470.05,470.05,469.95,469.95,469.9,469.95,469.9,469.95,469.95 },
						 rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.7308502197265625,-1.4623260498046875,-2.1924591064453125,-2.92449951171875,-3.65557861328125,-4.385467529296875,-5.1165313720703125,-5.8476715087890625,-6.5786285400390625,-7.30743408203125,-8.040725708007813,-8.769683837890625,-9.502578735351563,-10.234054565429688,-10.963851928710938,-9.733749389648438,-8.503921508789063,-7.2721710205078125,-6.041412353515625,-4.81109619140625,-3.5806884765625,-2.352203369140625,-1.1197967529296875,0.109283447265625,1.34088134765625,2.5703582763671875,3.80096435546875,5.030670166015625,6.26177978515625,5.69708251953125,5.1330108642578125,4.568817138671875,4.005462646484375,3.4413299560546875,2.877410888671875,2.312042236328125,1.74798583984375,1.1835784912109375,0.6198272705078125,0.055084228515625,-0.5079345703125,-1.07171630859375,-1.6379241943359375,-2.2011871337890625,-2.764892578125,-3.3306884765625,-3.89495849609375,-4.458465576171875,-4.195068359375,-3.9332427978515625,-3.6712493896484375,-3.4091033935546875,-3.147674560546875,-2.8861236572265625,-2.6218414306640625,-2.360931396484375,-2.0990447998046875,-1.8353271484375,-1.57415771484375,-1.312042236328125,-1.048126220703125,-0.785919189453125,-0.5236663818359375,-0.2613983154296875,0 },
						 yOffset = -13,
						 },{
						 displayObject = girl3OpenEyes,
						 scaleComponent = true,
						 x = { 804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,804.95,803.45,801.95,800.4,798.95,797.35,795.9,794.4,792.85,791.4,789.85,788.4,786.85,785.35,783.9,782.4,784.6,786.9,789.1,791.35,793.6,795.9,798.1,800.4,802.7,804.95,807.2,809.4,811.75,814,812.9,811.85,810.9,809.8,808.8,807.7,806.75,805.65,804.65,803.55,802.6,801.5,800.45,799.35,798.45,797.35,796.3,795.3,794.25,794.9,795.55,796.15,796.8,797.35,798,798.65,799.25,799.9,800.55,801.2,801.85,802.4,803.05,803.65,804.35,804.95 },
						 y = { 469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,469.95,470.05,470.05,470.1,470.2,470.25,470.3,470.55,470.7,470.85,471,471.25,471.5,471.65,472,471.5,471.2,470.9,470.6,470.4,470.3,470.1,470.05,470,470,470.1,470.25,470.4,470.65,470.5,470.45,470.35,470.25,470.2,470.15,470.1,470.05,470.05,470,470.05,470,470.05,470.1,470.15,470.2,470.25,470.3,470.35,470.35,470.3,470.2,470.15,470.2,470.15,470.15,470.1,470.05,470.05,469.95,469.95,469.9,469.95,469.9,469.95,469.95 },
						 rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.7308502197265625,-1.4623260498046875,-2.1924591064453125,-2.92449951171875,-3.65557861328125,-4.385467529296875,-5.1165313720703125,-5.8476715087890625,-6.5786285400390625,-7.30743408203125,-8.040725708007813,-8.769683837890625,-9.502578735351563,-10.234054565429688,-10.963851928710938,-9.733749389648438,-8.503921508789063,-7.2721710205078125,-6.041412353515625,-4.81109619140625,-3.5806884765625,-2.352203369140625,-1.1197967529296875,0.109283447265625,1.34088134765625,2.5703582763671875,3.80096435546875,5.030670166015625,6.26177978515625,5.69708251953125,5.1330108642578125,4.568817138671875,4.005462646484375,3.4413299560546875,2.877410888671875,2.312042236328125,1.74798583984375,1.1835784912109375,0.6198272705078125,0.055084228515625,-0.5079345703125,-1.07171630859375,-1.6379241943359375,-2.2011871337890625,-2.764892578125,-3.3306884765625,-3.89495849609375,-4.458465576171875,-4.195068359375,-3.9332427978515625,-3.6712493896484375,-3.4091033935546875,-3.147674560546875,-2.8861236572265625,-2.6218414306640625,-2.360931396484375,-2.0990447998046875,-1.8353271484375,-1.57415771484375,-1.312042236328125,-1.048126220703125,-0.785919189453125,-0.5236663818359375,-0.2613983154296875,0 },
						 yOffset = -13,
						 },
						},
						 x = 50,
						 y = -110,
						 scale = 1/2.5,
						 speed = 0.5
						}
		girl3Animation.hide()
		
		girl1Animation.displayObject:setReferencePoint(CenterReferencePoint)
		girl1Animation.displayObject.x = girl1Animation.displayObject.x - 20
		girl1Animation.displayObject.y = girl1Animation.displayObject.y + 50
		
		girl2Animation.displayObject:setReferencePoint(CenterReferencePoint)
		girl2Animation.displayObject.x = girl2Animation.displayObject.x - 20
		girl2Animation.displayObject.y = girl2Animation.displayObject.y + 50
		
		girl3Animation.displayObject:setReferencePoint(CenterReferencePoint)
		girl3Animation.displayObject.x = girl3Animation.displayObject.x - 20
		girl3Animation.displayObject.y = girl3Animation.displayObject.y + 50
		
		girl1Animation.displayObject.y = girl1Animation.displayObject.y - subtitleGroup.contentHeight*0.5*daScale
		girl2Animation.displayObject.y = girl2Animation.displayObject.y - subtitleGroup.contentHeight*0.5*daScale
		girl3Animation.displayObject.y = girl3Animation.displayObject.y - subtitleGroup.contentHeight*0.5*daScale
		
		girl1Animation.displayObject.xScale,girl1Animation.displayObject.yScale = 0.8*daScale,0.8*daScale
		girl2Animation.displayObject.xScale,girl2Animation.displayObject.yScale = 0.8*daScale,0.8*daScale
		girl3Animation.displayObject.xScale,girl3Animation.displayObject.yScale = 0.8*daScale,0.8*daScale
		
		localGroup:insert(girl2Animation.displayObject)
		localGroup:insert(girl1Animation.displayObject)
		localGroup:insert(girl3Animation.displayObject)
		
		local function kill()
			localGroup:remove(background)
			
			girl1Blinks.stopBlinking()
			girl2Blinks.stopBlinking()
			girl3Blinks.stopBlinking()
			
			girl1Animation.kill()
			girl2Animation.kill()
			girl3Animation.kill()
		end
		
		local function continue()
			pauseIt=nil
			continueIt=nil
			
			startMaryGigglingAnimation()
			
			girl1Animation.vanish(300)
			girl2Animation.vanish(300)
			girl3Animation.vanish(300)
		end
		
		startWaitingGirlsAnimation = function()
			soundController.playNew{
					path = "assets/sound/effects/girlslaughing.mp3",
					loops = 0,
					pausable = false,
					staticChannel = 4,
					actionTimes = {},
					action =	function()
								end,
					onComplete = function()
								end
					}
			
			background.isVisible=true
			background.alpha = 0
			transition.to(background,{alpha=1,time=300})
			
			girl1Animation.start()
			girl1Animation.appear(300)
			
			girl1Blinks.openEyes()
			girl1Blinks.startBlinking()
			
			girl2Animation.start()
			girl2Animation.appear(300)
			
			girl2Blinks.openEyes()
			girl2Blinks.startBlinking()
			
			girl3Animation.start()
			girl3Animation.appear(300)
			
			girl3Blinks.openEyes()
			girl3Blinks.startBlinking()
			
			local kt = nil
			stopGirlsWaitingAndStartMaryGiggling = function()
				continue()
				local kt = timer.performWithDelay(1000, kill)
			end
			--local ct = timer.performWithDelay(5000, continue)
			--local kt = timer.performWithDelay(6000, kill)
			
			pauseIt = function()
				--timer.pause(ct)
				if kt then timer.pause(kt) end
				girl1Animation.stop()
				girl1Blinks.stopBlinking()
				girl2Animation.stop()
				girl2Blinks.stopBlinking()
				girl3Animation.stop()
				girl3Blinks.stopBlinking()
			end
			
			continueIt = function()
				--timer.resume(ct)
				if kt then timer.resume(kt) end
				girl1Animation.start()
				girl1Blinks.startBlinking()
				girl2Animation.start()
				girl2Blinks.startBlinking()
				girl3Animation.start()
				girl3Blinks.startBlinking()
			end
			
			pauseIt()
			continueIt()
		end
	end
	prepareWaitingGirlsAnimation()
	
	--======================================
	-- MARY GIGGLING ANIMATION
	--======================================
	local function prepareMaryGigglingAnimation()
		local background = display.newImageRect("assets/world/silverGardenCloseup.jpg",width,height)
		background:setReferencePoint(display.TopLeftReferencePoint)
		background.x = 0
		background.y = 0
		background.isVisible=false
		localGroup:insert(background)
		
		local marySurprisedFace = display.newImage("assets/mary/giggling/surprise expresion.png")
		marySurprisedFace.xScale = 0.5
		marySurprisedFace.yScale = 0.5
		
		local maryGiggleFace = display.newImage("assets/mary/giggling/giggle expresion.png")
		maryGiggleFace.xScale = 0.5
		maryGiggleFace.yScale = 0.5
		
		local maryGigglingAnimation = ui.newAnimation{
						 comps = {
						 {
						  --buds
						  path = "assets/budsDeFrente.png",
						  scale = 0.5,
						  yOffset = -65,
						  xOffset = -50,
						  x = { 573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25 },
						  y = { 685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,687.45,689.85,692.25,694.65,697.05,694.65,692.25,689.85,687.45,685.05,687.65,690.3,692.95,695.6,698.25,695.6,692.95,690.3,687.65,685.05,687.65,690.3,692.95,695.6,698.25,695.6,692.95,690.3,687.65,685.05 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
						 },
						 {
						  --body
						  path = "assets/mary/giggling/body.png",
						  x = { 573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25,573.25 },
						  y = { 685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,685.05,687.45,689.85,692.25,694.65,697.05,694.65,692.25,689.85,687.45,685.05,687.65,690.3,692.95,695.6,698.25,695.6,692.95,690.3,687.65,685.05,687.65,690.3,692.95,695.6,698.25,695.6,692.95,690.3,687.65,685.05 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
						 },
						 {
						  --head
						  path = "assets/mary/giggling/head.png",
						  x = { 503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15 },
						  y = { 320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,323.35,326.45,329.55,332.65,335.75,332.65,329.55,326.45,323.35,320.25,323.8,327.35,330.95,334.5,338.1,334.5,330.95,327.35,323.8,320.25,323.55,326.9,330.2,333.55,336.9,333.55,330.2,326.9,323.55,320.25 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
						  xOffset = 20
						 },
						 {
						  --head
						  displayObject = maryGiggleFace,
						  x = { 503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15 },
						  y = { 320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,323.35,326.45,329.55,332.65,335.75,332.65,329.55,326.45,323.35,320.25,323.8,327.35,330.95,334.5,338.1,334.5,330.95,327.35,323.8,320.25,323.55,326.9,330.2,333.55,336.9,333.55,330.2,326.9,323.55,320.25 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
						  xOffset = 20
						 },
						 {
						  --head
						  displayObject = marySurprisedFace,
						  x = { 503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15,503.15 },
						  y = { 320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,320.25,323.35,326.45,329.55,332.65,335.75,332.65,329.55,326.45,323.35,320.25,323.8,327.35,330.95,334.5,338.1,334.5,330.95,327.35,323.8,320.25,323.55,326.9,330.2,333.55,336.9,333.55,330.2,326.9,323.55,320.25 },
						  rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
						  xOffset = 20
						 },
						 {
						  --rforearm
						  path = "assets/mary/giggling/rforearm.png",
						  x = { 339.7,349.85,360.5,371.3,382,392.55,402.5,411.85,420.4,427.95,434.4,439.7,443.75,446.55,448.1,446.6,445.2,444.25,443.45,443.25,443.55,444.6,446.45,449.15,452.45,455.85,458.45,459.65,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.15,459.1,459.1,459.05,459.05,459.05,459.1,459.1,459.15,459.15,459.1,459.05,459,458.95,458.9,458.95,459,459.05,459.1,459.15,459.15,459.1,459.1,459.05,459.05,459.05,459.1,459.1,459.15,459.15 },
						  y = { 754.1,753.2,750.7,746.5,740.75,733.55,725,715.2,704.3,692.65,680.4,667.75,655,642.5,630.3,628.9,627.1,624.6,621.65,618.2,614.35,610.25,606.15,602.25,598.85,596.3,594.45,592.5,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,589.55,591.9,594.25,596.6,598.95,601.3,598.9,596.55,594.2,591.85,589.45,592.1,594.7,597.35,599.95,602.6,599.95,597.35,594.7,592.1,589.45,592.05,594.65,597.25,599.85,602.45,599.85,597.25,594.7,592.1,589.5 },
						  rotation = { -9.005218505859375,-18.011123657226563,-27.015777587890625,-36.02073669433594,-45.02667236328125,-54.03190612792969,-63.03767395019531,-72.04266357421875,-81.04766845703125,-90.05245971679688,-99.05809020996094,-108.06329345703125,-117.06849670410156,-126.07389831542969,-135.0796356201172,-136.98692321777344,-138.89447021484375,-140.80162048339844,-142.70840454101563,-144.61570739746094,-146.52328491210938,-148.42979431152344,-150.337646484375,-152.2453155517578,-154.15206909179688,-156.0602264404297,-157.9663848876953,-159.8743896484375,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547,-161.7811737060547 },
						 },
						},
						 x = 0,
						 y = 0,
						 scale = 0.5,
						 speed = 0.25
						}
		maryGigglingAnimation.hide()
		maryGigglingAnimation.displayObject.xScale = 1.2
		maryGigglingAnimation.displayObject.yScale = 1.2
		maryGigglingAnimation.displayObject.x = -72
		maryGigglingAnimation.displayObject.y = -48 - subtitleGroup.contentHeight*0.5*daScale
		maryGigglingAnimation.displayObject:setReferencePoint(display.CenterReferencePoint)
		maryGigglingAnimation.displayObject.xScale = daScale * 1.2
		maryGigglingAnimation.displayObject.yScale = daScale * 1.2
		
		localGroup:insert(maryGigglingAnimation.displayObject)
		
		local vanishing = false
		local pauseState = paused
		
		local animateMaryGiggling
		
		local function continue()
			localGroup:remove(background)
			
			maryGigglingAnimation.kill()
		end
		
		local function vanish()
			pauseIt=nil
			continueIt=nil
			vanish = nil
			
			vanishing = true
			
			startAnimalsChasingAnimation()
			timer.performWithDelay(1000, continue)
		end
		
		animateMaryGiggling = function()
			if maryGigglingAnimation then
				if pausedState ~= paused then
					pausedState = paused
					if paused then
						maryGigglingAnimation.stop()
					else
						maryGigglingAnimation.start()
					end
					return
				end
				if pausedState then
					return
				end
				if maryGigglingAnimation.getActualFrame() >= 55 then
					marySurprisedFace.isVisible = false
					maryGiggleFace.isVisible = true
				else
					marySurprisedFace.isVisible = true
					maryGiggleFace.isVisible = false
				end
				if maryGigglingAnimation.getActualFrame() >= 84 then
					Runtime:removeEventListener( "enterFrame", animateMaryGiggling )
					vanish()
				end
			end
		end
		
		startMaryGigglingAnimation = function()
			soundController.playNew{
					path = "assets/sound/effects/marygiggle.mp3",
					loops = 3,
					pausable = false,
					staticChannel = 3,
					actionTimes = {},
					action =	function()
								end,
					onComplete = function()
								end
					}
			
			background.isVisible=true
			background.alpha = 0
			transition.to(background,{alpha=1,time=300})
			
			maryGigglingAnimation.appear(300)
			maryGigglingAnimation.start()
			
			Runtime:addEventListener( "enterFrame", animateMaryGiggling )
			
			soundController.playNew{
						path = "assets/sound/voices/cap1/adv1_N4.mp3",
						onComplete = function()
										nextSubtitle()
									end
						}
			
			pauseIt = function() end
			continueIt = function() end
			
			pauseIt()
			continueIt()
		end
	end
	prepareMaryGigglingAnimation()
	
	--======================================
	-- ANIMALS CHASING ANIMATION
	--======================================
	local function prepareAnimalsChasingAnimation()
		local background = display.newImageRect("assets/world/silverGarden.jpg",width,height)
		background:setReferencePoint(display.TopLeftReferencePoint)
		background.x = 0
		background.y = 0
		background.isVisible=false
		localGroup:insert(background)
		
		local girl1OpenEyes = display.newImage("assets/idleGirls/black/eyesOpen.png")
		local girl1ClosedEyes = display.newImage("assets/idleGirls/black/eyesClosed.png")
		
		local girl1Blinks = ui.blink(girl1OpenEyes,girl1ClosedEyes,1)
		
		local girl1Animation = ui.newAnimation{
						 comps = {
						 {
						  --rhip
						  --
						  path = "assets/idleGirls/black/rhip.png",
						  x = { 195.7,195.7,195.7,195.7,195.75,195.7,195.7,195.7,195.75 },
						  y = { 750.15,750.15,750.15,750.15,750.15,750.15,750.15,750.15,750.15 },
						  rotation = { 0,0,0,0,0,0,0,0,0 },
						 },
						 {
						  --rknee
						  --
						  path = "assets/idleGirls/black/rknee.png",
						  x = { 202.7,202.7,202.7,202.7,202.75,202.7,202.7,202.7,202.75 },
						  y = { 807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05,807.05 },
						  rotation = { 0,0,0,0,0,0,0,0,0 },
						 },
						 {
						  --rfoot
						  path = "assets/idleGirls/black/rfoot.png",
						  x = { 197.65,197.65,197.65,197.65,197.7,197.65,197.65,197.65,197.7 },
						  y = { 848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1 },
						  rotation = { 0,0,0,0,0,0,0,0,0 },
						 },
						 {
						  --lhip
						  path = "assets/idleGirls/black/lhip.png",
						  x = { 239.75,239.75,239.75,239.75,239.75,239.75,239.75,239.75,239.75 },
						  y = { 750.15,750.15,750.15,750.15,750.15,750.15,750.15,750.15,750.15 },
						  rotation = { 0,0,0,0,0,0,0,0,0 },
						 },
						 {
						  --lknee
						  path = "assets/idleGirls/black/lknee.png",
						  x = { 232.75,232.75,232.75,232.75,232.75,232.75,232.75,232.75,232.75 },
						  y = { 807.1,807.1,807.1,807.1,807.05,807.1,807.1,807.1,807.05 },
						  rotation = { 0,0,0,0,0,0,0,0,0 },
						 },
						 {
						  --lfoot
						  path = "assets/idleGirls/black/lfoot.png",
						  x = { 238.55,238.55,238.55,238.55,238.55,238.55,238.55,238.55,238.55 },
						  y = { 848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1,848.1 },
						  rotation = { 0,0,0,0,0,0,0,0,0 },
						 },
						 {
						  --buds
						  path = "assets/budsDeFrente.png",
						  scale = 0.25,
						  yOffset = -50,
						  x = { 219.45,219.55,219.65,219.75,219.85,219.7,219.6,219.45,219.35 },
						  y = { 694.65,693.9,693.15,692.4,691.65,692.55,693.5,694.45,695.4 },
						  rotation = { 0,0,0,0,0,0,0,0,0 },
						 },
						 {
						  --body
						  --
						  path = "assets/idleGirls/black/body.png",
						  x = { 219.45,219.55,219.65,219.75,219.85,219.7,219.6,219.45,219.35 },
						  y = { 694.65,693.9,693.15,692.4,691.65,692.55,693.5,694.45,695.4 },
						  rotation = { 0,0,0,0,0,0,0,0,0 },
						 },
						 {
						  --rarm
						  --
						  path = "assets/idleGirls/black/rarm.png",
						  x = { 171.7,171.8,171.95,172.1,172.2,172.05,171.9,171.75,171.55 },
						  y = { 663.7,662.7,661.7,660.7,659.7,660.9,662.1,663.3,664.5 },
						  rotation = { -17.027679443359375,-17.027679443359375,-17.026885986328125,-17.026885986328125,-17.026092529296875,-17.026885986328125,-17.026885986328125,-17.027679443359375,-17.027679443359375 },
						 },
						 {
						  --rforearm
						  --
						  path = "assets/idleGirls/black/rforearm.png",
						  x = { 158.5,158.95,159.45,159.85,160.3,159.8,159.2,158.65,158 },
						  y = { 702.95,702.05,701.05,700.2,699.2,700.45,701.7,702.85,704.05 },
						  rotation = { -18.34967041015625,-19.6741943359375,-20.996246337890625,-22.319244384765625,-23.641845703125,-21.987777709960938,-20.334976196289063,-18.680618286132813,-17.028488159179688 },
						 },
						 {
						  --rhand
						  --
						  path = "assets/idleGirls/black/rhand.png",
						  x = { 159.8,161.1,162.25,163.45,164.7,163.15,161.7,160.1,158.6 },
						  y = { 735.45,734.4,733.4,732.4,731.35,732.6,733.9,735.2,736.35 },
						  rotation = { -18.34967041015625,-19.6741943359375,-20.996246337890625,-22.319244384765625,-23.641845703125,-21.987777709960938,-20.334976196289063,-18.680618286132813,-17.028488159179688 },
						 },
						 {
						  --larm
						  --
						  path = "assets/idleGirls/black/larm.png",
						  x = { 259.25,259.4,259.5,259.6,259.7,259.55,259.4,259.25,259.1 },
						  y = { 664,663.05,662.1,661.1,660.15,661.4,662.6,663.8,665 },
						  rotation = { 22.32672119140625,22.327468872070313,22.327468872070313,22.328216552734375,22.328216552734375,22.327468872070313,22.327468872070313,22.32672119140625,22.32672119140625 },
						 },
						 {
						  --lforearm
						  --
						  path = "assets/idleGirls/black/lforearm.png",
						  x = { 269.25,268.95,268.65,268.45,268,268.35,268.7,269.05,269.4 },
						  y = { 704.55,703.6,702.6,701.65,700.65,701.85,703.1,704.4,705.55 },
						  rotation = { 23.633041381835938,24.937530517578125,26.241714477539063,27.546844482421875,28.85052490234375,27.221481323242188,25.58819580078125,23.958755493164063,22.32672119140625 },
						 },
						 {
						  --lhand
						  --
						  path = "assets/idleGirls/black/lhand.png",
						  x = { 264.6,263.55,262.6,261.6,260.6,261.9,263.05,264.3,265.55 },
						  y = { 737.1,736.05,734.85,733.7,732.6,734.05,735.45,736.8,738.15 },
						  rotation = { 23.633041381835938,24.937530517578125,26.241714477539063,27.546844482421875,28.85052490234375,27.221481323242188,25.58819580078125,23.958755493164063,22.32672119140625 },
						 },
						 {
						  --head
						  displayObject = girl1ClosedEyes,
						  x = { 220.1,222.8,225.5,228.2,230.9,227.5,224.15,220.75,217.4 },
						  y = { 490.5,490.55,490.65,490.8,491.05,490.75,490.6,490.5,490.55 },
						  rotation = { 1.218536376953125,2.4377288818359375,3.6564483642578125,4.875335693359375,6.095001220703125,4.570556640625,3.0465545654296875,1.5234832763671875,0 },
						  scaleComponent = true,
						 },
						 {
						  --head
						  displayObject = girl1OpenEyes,
						  x = { 220.1,222.8,225.5,228.2,230.9,227.5,224.15,220.75,217.4 },
						  y = { 490.5,490.55,490.65,490.8,491.05,490.75,490.6,490.5,490.55 },
						  rotation = { 1.218536376953125,2.4377288818359375,3.6564483642578125,4.875335693359375,6.095001220703125,4.570556640625,3.0465545654296875,1.5234832763671875,0 },
						  scaleComponent = true,
						 },
						 {
						  --lelbow
						  --
						  path = "assets/idleGirls/black/elbowmask.png",
						  x = { 270,270.2,270.35,270.6,270.7,270.55,270.35,270.15,269.9 },
						  y = { 686.85,685.95,685,684.1,683.2,684.35,685.5,686.7,687.9 },
						  rotation = { 23.633041381835938,24.937530517578125,26.241714477539063,27.546844482421875,28.85052490234375,27.221481323242188,25.58819580078125,23.958755493164063,22.32672119140625 },
						 },
						 {
						  --lwrist
						  path = "assets/idleGirls/black/wristmask.png",
						  x = { 269.35,268.65,267.95,267.35,266.7,267.5,268.35,269.2,270.05 },
						  y = { 721.8,720.75,719.7,718.6,717.5,718.95,720.2,721.55,722.9 },
						  rotation = { 23.633041381835938,24.937530517578125,26.241714477539063,27.546844482421875,28.85052490234375,27.221481323242188,25.58819580078125,23.958755493164063,22.32672119140625 },
						 },
						 {
						  --relbow
						  --
						  path = "assets/idleGirls/black/elbowmask.png",
						  x = { 159.55,159.6,159.65,159.65,159.8,159.7,159.7,159.6,159.55 },
						  y = { 684.55,683.65,682.6,681.7,680.75,681.85,683.1,684.3,685.5 },
						  rotation = { -18.34967041015625,-19.6741943359375,-20.996246337890625,-22.319244384765625,-23.641845703125,-21.987777709960938,-20.334976196289063,-18.680618286132813,-17.028488159179688 },
						 },
						 {
						  --rwrist
						  --
						  path = "assets/idleGirls/black/wristmask.png",
						  x = { 157.15,158.1,158.9,159.9,160.65,159.55,158.5,157.35,156.25 },
						  y = { 719.5,718.55,717.6,716.6,715.65,716.9,718.1,719.2,720.35 },
						  rotation = { -18.34967041015625,-19.6741943359375,-20.996246337890625,-22.319244384765625,-23.641845703125,-21.987777709960938,-20.334976196289063,-18.680618286132813,-17.028488159179688 },
						 },
						},
						 x = 75,
						 y = -110,
						 scale = 1/2.5,
						 speed = 0.5
						}
		girl1Animation.hide()
		
		local girl2OpenEyes = display.newImage("assets/idleGirls/blue/eyesOpen.png")
		local girl2ClosedEyes = display.newImage("assets/idleGirls/blue/eyesClosed.png")
		
		local girl2Blinks = ui.blink(girl2OpenEyes,girl2ClosedEyes,1)
		
		local girl2Animation = ui.newAnimation{
						 comps = {
						 {
						  --rhip
						  path = "assets/idleGirls/blue/rhip.png",
						  x = { 503.4,503.4,503.4,503.4,503.4,503.4,503.4,503.4,503.4 },
						  y = { 622.05,622.05,622.05,622.05,622.05,622.05,622.05,622.05,622.05 },
						  rotation = { 0,0,0,0,0,0,0,0,0 },
						 },
						 {
						  --rknee
						  path = "assets/idleGirls/blue/rknee.png",
						  x = { 506.35,506.35,506.35,506.35,506.35,506.35,506.35,506.35,506.35 },
						  y = { 673.95,673.95,673.95,673.95,673.95,673.95,673.95,673.95,673.95 },
						  rotation = { 0,0,0,0,0,0,0,0,0 },
						 },
						 {
						  --rfoot
						  path = "assets/idleGirls/blue/rfoot.png",
						  x = { 501.8,501.8,501.8,501.85,501.8,501.8,501.8,501.8,501.85 },
						  y = { 712.35,712.35,712.35,712.35,712.35,712.35,712.35,712.35,712.35 },
						  rotation = { 0,0,0,0,0,0,0,0,0 },
						 },
						 {
						  --lhip
						  path = "assets/idleGirls/blue/lhip.png",
						  x = { 538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45,538.45 },
						  y = { 622.05,622.05,622.05,622.05,622.05,622.05,622.05,622.05,622.05 },
						  rotation = { 0,0,0,0,0,0,0,0,0 },
						 },
						 {
						  --lknee
						  path = "assets/idleGirls/blue/lknee.png",
						  x = { 535.5,535.5,535.5,535.5,535.5,535.5,535.5,535.5,535.5 },
						  y = { 673.95,673.95,673.95,673.95,673.95,673.95,673.95,673.95,673.95 },
						  rotation = { 0,0,0,0,0,0,0,0,0 },
						 },
						 {
						  --lfoot
						  path = "assets/idleGirls/blue/lfoot.png",
						  x = { 539.95,539.95,539.95,539.95,539.95,539.95,539.95,539.95,539.95 },
						  y = { 712.35,712.35,712.35,712.35,712.35,712.35,712.35,712.35,712.35 },
						  rotation = { 0,0,0,0,0,0,0,0,0 },
						 },
						 {
						  --buds
						  path = "assets/budsDeFrente.png",
						  scale = 0.25,
						  yOffset = -50,
						  x = { 522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05 },
						  y = { 577.25,577.55,577.85,578.15,577.9,577.65,577.4,577.15,576.95 },
						  rotation = { 0,0,0,0,0,0,0,0,0 },
						 },
						 {
						  --body
						  path = "assets/idleGirls/blue/body.png",
						  x = { 522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05,522.05 },
						  y = { 577.25,577.55,577.85,578.15,577.9,577.65,577.4,577.15,576.95 },
						  rotation = { 0,0,0,0,0,0,0,0,0 },
						 },
						 {
						  --rarm
						  path = "assets/idleGirls/blue/rarm.png",
						  x = { 474.05,473.75,473.3,473,473.3,473.65,473.9,474.25,474.45 },
						  y = { 549.7,549.7,549.65,549.6,549.55,549.6,549.7,549.7,549.8 },
						  rotation = { -18.378799438476563,-17.352432250976563,-16.32733154296875,-15.30194091796875,-16.122604370117188,-16.942916870117188,-17.762496948242188,-18.5848388671875,-19.404769897460938 },
						 },
						 {
						  --rforearm
						  path = "assets/idleGirls/blue/rforearm.png",
						  x = { 476.35,475.9,475.45,475.05,475.4,475.7,476,476.45,476.8 },
						  y = { 580.05,579.1,578.15,577.25,578,578.75,579.5,580.2,580.9 },
						  rotation = { -89.03402709960938,-90.71861267089844,-92.40107727050781,-94.08549499511719,-92.73872375488281,-91.39068603515625,-90.04283142089844,-88.69670104980469,-87.34849548339844 },
						 },
						 {
						  --rhand
						  path = "assets/idleGirls/blue/rhand.png",
						  x = { 507.85,507.65,507.3,507,507.3,507.5,507.7,507.95,508.15 },
						  y = { 589.05,587.35,585.6,583.85,585.25,586.65,588,589.4,590.8 },
						  rotation = { -89.03402709960938,-90.71861267089844,-92.40107727050781,-94.08549499511719,-92.73872375488281,-91.39068603515625,-90.04283142089844,-88.69670104980469,-87.34849548339844 },
						 },
						 {
						  --larm
						  path = "assets/idleGirls/blue/larm.png",
						  x = { 562.6,563,563.3,563.8,563.45,563.2,562.85,562.6,562.3 },
						  y = { 550.7,550.55,550.55,550.45,550.45,550.6,550.7,550.75,550.85 },
						  rotation = { 22.0028076171875,20.76806640625,19.536880493164063,18.302398681640625,19.288803100585938,20.275772094726563,21.26171875,22.248138427734375,23.235610961914063 },
						 },
						 {
						  --lforearm
						  path = "assets/idleGirls/blue/lforearm.png",
						  x = { 559.7,560.65,561.5,562.4,561.7,560.95,560.3,559.55,558.9 },
						  y = { 581.9,581.6,581.3,581.05,581.25,581.5,581.7,581.95,582.15 },
						  rotation = { 87.62947082519531,87.24644470214844,86.86190795898438,86.47679138183594,86.78521728515625,87.09207153320313,87.39997863769531,87.7071533203125,88.01622009277344 },
						 },
						 {
						  --lhand
						  path = "assets/idleGirls/blue/lhand.png",
						  x = { 529.15,530.15,531.1,532.25,531.35,530.55,529.75,528.9,528.1 },
						  y = { 591.7,591.5,591.25,590.95,591.25,591.45,591.6,591.75,591.85 },
						  rotation = { 87.62947082519531,87.24644470214844,86.86190795898438,86.47679138183594,86.78521728515625,87.09207153320313,87.39997863769531,87.7071533203125,88.01622009277344 },
						 },
						 {
						  --head
						  displayObject = girl2ClosedEyes,
						  x = { 518.05,518.05,518.05,518.1,518.05,518.05,518.05,518.05,518.1 },
						  y = { 402.15,402.5,402.9,403.3,402.95,402.65,402.35,402.05,401.8 },
						  rotation = { 0,0,0,0,0,0,0,0,0 },
						  scaleComponent = true,
						 },
						 {
						  --head
						  displayObject = girl2OpenEyes,
						  x = { 518.05,518.05,518.05,518.1,518.05,518.05,518.05,518.05,518.1 },
						  y = { 402.15,402.5,402.9,403.3,402.95,402.65,402.35,402.05,401.8 },
						  rotation = { 0,0,0,0,0,0,0,0,0 },
						  scaleComponent = true,
						 },
						 {
						  --relbow
						  path = "assets/idleGirls/blue/elbowmask.png",
						  x = { 461.9,461.3,460.65,460,460.5,461.05,461.5,462.05,462.55 },
						  y = { 574,573.6,573.2,572.8,573.1,573.45,573.75,574.1,574.4 },
						  rotation = { -89.03402709960938,-90.71861267089844,-92.40107727050781,-94.08549499511719,-92.73872375488281,-91.39068603515625,-90.04283142089844,-88.69670104980469,-87.34849548339844 },
						 },
						 {
						  --rwrist
						  path = "assets/idleGirls/blue/wristmask.png",
						  x = { 491.55,491.15,490.7,490.25,490.55,490.95,491.25,491.6,491.95 },
						  y = { 586.15,584.85,583.6,582.25,583.35,584.35,585.4,586.4,587.45 },
						  rotation = { -89.03402709960938,-90.71861267089844,-92.40107727050781,-94.08549499511719,-92.73872375488281,-91.39068603515625,-90.04283142089844,-88.69670104980469,-87.34849548339844 },
						 },
						 {
						  --lelbow
						  path = "assets/idleGirls/blue/elbowmask.png",
						  x = { 573.65,574.45,575.25,576.05,575.4,574.75,574.15,573.4,572.75 },
						  y = { 575.3,574.7,574.1,573.45,573.95,574.4,574.9,575.35,575.9 },
						  rotation = { 87.62860107421875,87.24557495117188,86.86277770996094,86.4776611328125,86.78433227539063,87.09120178222656,87.39997863769531,87.70628356933594,88.01446533203125 },
						 },
						 {
						  --lwrist
						  path = "assets/idleGirls/blue/wristmask.png",
						  x = { 545,545.95,546.95,547.95,547.15,546.35,545.65,544.8,543.95 },
						  y = { 588.55,588.25,587.8,587.4,587.75,588.05,588.35,588.55,588.9 },
						  rotation = { 87.62860107421875,87.24557495117188,86.86277770996094,86.4776611328125,86.78433227539063,87.09120178222656,87.39997863769531,87.70628356933594,88.01446533203125 },
						 },
						},
						 x = 50,
						 y = -110,
						 scale = 1/2.5,
						 speed = 0.5
						}
		girl2Animation.hide()
		
		local girl3OpenEyes = display.newImage("assets/mary/laughing2/eyesOpen.png")
		local girl3ClosedEyes = display.newImage("assets/mary/laughing2/head.png")
		
		local girl3Blinks = ui.blink(girl3OpenEyes,girl3ClosedEyes,1)
		
		local girl3Animation = ui.newAnimation{
						 comps = {
						 {
						  --body
						  path = "assets/mary/laughing2/body.png",
						  x = { 313.3,313.3,313.3,313.25,313.35,313.25,313.3,313.3,313.3,313.3 },
						  y = { 318.6,318.5,318.4,318.3,318.25,318.3,318.4,318.5,318.6,318.75 },
						  rotation = { 5.5109100341796875,5.93157958984375,6.35333251953125,6.7743988037109375,7.1964569091796875,6.7743988037109375,6.35333251953125,5.93157958984375,5.5109100341796875,5.087921142578125 },
						 },
						 {
						  --rleg
						  path = "assets/mary/laughing2/rleg.png",
						  x = { 298.9,298.65,298.35,298,297.7,298,298.35,298.65,298.9,299.2 },
						  y = { 409.4,409.15,408.9,408.6,408.4,408.6,408.9,409.15,409.4,409.6 },
						  rotation = { -2.213409423828125,-2.2282562255859375,-2.24395751953125,-2.259674072265625,-2.2745208740234375,-2.259674072265625,-2.24395751953125,-2.2282562255859375,-2.213409423828125,-2.19769287109375 },
						 },
						 {
						  --lleg
						  path = "assets/mary/laughing2/lleg.png",
						  x = { 329.7,329.45,329.25,329,328.85,329,329.25,329.45,329.7,329.95 },
						  y = { 412.85,412.9,412.95,412.9,412.95,412.9,412.95,412.9,412.85,412.85 },
						  rotation = { -0.3243560791015625,-0.398651123046875,-0.4720916748046875,-0.5455169677734375,-0.61895751953125,-0.5455169677734375,-0.4720916748046875,-0.398651123046875,-0.3243560791015625,-0.250030517578125 },
						 },
						 {
						  --lpigtail
						  path = "assets/mary/laughing2/lpigtail.png",
						  x = { 332.35,337.35,342.3,347.2,352.15,347.2,342.3,337.35,332.35,327.4 },
						  y = { 118.25,119.3,120.45,121.7,123.05,121.7,120.45,119.3,118.25,117.15 },
						  rotation = { 4.7494659423828125,4.408935546875,4.0698394775390625,3.7287139892578125,3.38818359375,3.7287139892578125,4.0698394775390625,4.408935546875,4.7494659423828125,5.09051513671875 },
						  yOffset = 10
						 },
						 {
						  --larm
						  path = "assets/mary/laughing2/larm.png",
						  x = { 362.85,363.35,363.8,364.2,364.6,364.2,363.8,363.35,362.85,362.4 },
						  y = { 270.3,270.4,270.6,270.8,270.95,270.8,270.6,270.4,270.3,270.05 },
						  rotation = { -63.964019775390625,-63.86177062988281,-63.75898742675781,-63.65708923339844,-63.55326843261719,-63.65708923339844,-63.75898742675781,-63.86177062988281,-63.964019775390625,-64.06716918945313 },
						 },
						 {
						  --buds
						  path = "assets/budsDeFrente.png",
						  scale = 0.25,
						  scaleCX = 0.5,
						  coordsXScaleOffset = 2,
						  yOffset = -50,
						  x = { 313.3,313.3,313.3,313.25,313.35,313.25,313.3,313.3,313.3,313.3 },
						  y = { 318.6,318.5,318.4,318.3,318.25,318.3,318.4,318.5,318.6,318.75 },
						  rotation = { 5.5109100341796875,5.93157958984375,6.35333251953125,6.7743988037109375,7.1964569091796875,6.7743988037109375,6.35333251953125,5.93157958984375,5.5109100341796875,5.087921142578125 },
						 },
						 {
						  --body
						  path = "assets/mary/laughing2/body.png",
						  x = { 313.3,313.3,313.3,313.25,313.35,313.25,313.3,313.3,313.3,313.3 },
						  y = { 318.6,318.5,318.4,318.3,318.25,318.3,318.4,318.5,318.6,318.75 },
						  rotation = { 5.5109100341796875,5.93157958984375,6.35333251953125,6.7743988037109375,7.1964569091796875,6.7743988037109375,6.35333251953125,5.93157958984375,5.5109100341796875,5.087921142578125 },
						 },
						 {
						  --head
						  path = "assets/mary/laughing2/head.png",
						  x = { 330.35,332.8,335.4,337.9,340.4,337.9,335.4,332.8,330.35,327.8 },
						  y = { 138.1,138.15,138.25,138.4,138.6,138.4,138.25,138.15,138.1,138.1 },
						  rotation = { 6.1788330078125,7.2678680419921875,8.356781005859375,9.445587158203125,10.534332275390625,9.445587158203125,8.356781005859375,7.2678680419921875,6.1788330078125,5.0913848876953125 },
						 },
						 {
						  displayObject = girl3ClosedEyes,
						  x = { 330.35,332.8,335.4,337.9,340.4,337.9,335.4,332.8,330.35,327.8 },
						  y = { 138.1,138.15,138.25,138.4,138.6,138.4,138.25,138.15,138.1,138.1 },
						  rotation = { 6.1788330078125,7.2678680419921875,8.356781005859375,9.445587158203125,10.534332275390625,9.445587158203125,8.356781005859375,7.2678680419921875,6.1788330078125,5.0913848876953125 },
						  scaleComponent = true
						 },
						 {
						  displayObject = girl3OpenEyes,
						  x = { 330.35,332.8,335.4,337.9,340.4,337.9,335.4,332.8,330.35,327.8 },
						  y = { 138.1,138.15,138.25,138.4,138.6,138.4,138.25,138.15,138.1,138.1 },
						  rotation = { 6.1788330078125,7.2678680419921875,8.356781005859375,9.445587158203125,10.534332275390625,9.445587158203125,8.356781005859375,7.2678680419921875,6.1788330078125,5.0913848876953125 },
						  scaleComponent = true
						 },
						 {
						  --rpigtail
						  path = "assets/mary/laughing2/rpigtail.png",
						  x = { 249.4,254.2,259.05,263.95,268.85,263.95,259.05,254.2,249.4,244.6 },
						  y = { 115.9,114.75,113.75,112.85,111.9,112.85,113.75,114.75,115.9,117.05 },
						  rotation = { 4.96820068359375,4.8458251953125,4.72601318359375,4.6053009033203125,4.4845428466796875,4.6053009033203125,4.72601318359375,4.8466949462890625,4.96820068359375,5.087921142578125 },
						  yOffset = 5
						 },
						 {
						  --lantearm
						  path = "assets/mary/laughing2/lhand.png",
						  x = { 372.25,372.75,373.2,373.65,374.1,373.65,373.2,372.75,372.25,371.8 },
						  y = { 241.7,242.05,242.35,242.65,242.95,242.65,242.35,242.05,241.7,241.55 },
						  rotation = { 172.97055053710938,172.8603515625,172.7501983642578,172.64010620117188,172.52920532226563,172.64010620117188,172.7501983642578,172.8603515625,172.97055053710938,173.08253479003906 },
						 },
						 {
						  --rarm
						  path = "assets/mary/laughing2/rarm.png",
						  x = { 322.3,322.8,323.35,323.95,324.5,323.95,323.35,322.8,322.3,321.65 },
						  y = { 269.8,269.55,269.3,269,268.75,269,269.3,269.55,269.8,270.15 },
						  rotation = { -125.92913818359375,-125.02474975585938,-124.1220703125,-123.21743774414063,-122.31367492675781,-123.21743774414063,-124.1220703125,-125.02474975585938,-125.92913818359375,-126.83233642578125 },
						 },
						 {
						  --rantearm
						  path = "assets/mary/laughing2/rhand.png",
						  x = { 361.7,362.35,363.05,363.7,364.4,363.7,363.05,362.35,361.7,360.9 },
						  y = { 244.95,245.25,245.55,245.9,246.15,245.9,245.55,245.25,244.95,244.6 },
						  rotation = { 173.59140014648438,174.02517700195313,174.45703125,174.89039611816406,175.32261657714844,174.89039611816406,174.45703125,174.02517700195313,173.59140014648438,173.1592254638672 },
						 },
						},
						 x = 0,
						 y = 0,
						 scale = 1/2,
						 speed = 0.4
						}
		girl3Animation.hide()
		
		girl1Animation.displayObject:setReferencePoint(CenterReferencePoint)
		girl1Animation.displayObject.x = girl1Animation.displayObject.x - 20
		girl1Animation.displayObject.y = girl1Animation.displayObject.y + 50 - 20
		
		girl2Animation.displayObject:setReferencePoint(CenterReferencePoint)
		girl2Animation.displayObject.x = girl2Animation.displayObject.x - 20
		girl2Animation.displayObject.y = girl2Animation.displayObject.y + 50 - 20
		
		girl3Animation.displayObject:setReferencePoint(CenterReferencePoint)
		girl3Animation.displayObject.x = 480 * 0.8*daScale
		girl3Animation.displayObject.y = girl3Animation.displayObject.y + 70 - 20
		girl3Animation.displayObject.xScale = -0.85
		girl3Animation.displayObject.yScale = 0.85
		
		girl1Animation.displayObject.y = girl1Animation.displayObject.y - subtitleGroup.contentHeight*0.5*daScale
		girl2Animation.displayObject.y = girl2Animation.displayObject.y - subtitleGroup.contentHeight*0.5*daScale
		girl3Animation.displayObject.y = girl3Animation.displayObject.y - subtitleGroup.contentHeight*0.5*daScale
		
		girl1Animation.displayObject.xScale,girl1Animation.displayObject.yScale = 0.8*daScale,0.8*daScale
		girl2Animation.displayObject.xScale,girl2Animation.displayObject.yScale = 0.8*daScale,0.8*daScale
		girl3Animation.displayObject.xScale = girl3Animation.displayObject.xScale * 0.8*daScale
		girl3Animation.displayObject.yScale = girl3Animation.displayObject.yScale * 0.8*daScale
		
		localGroup:insert(girl2Animation.displayObject)
		localGroup:insert(girl1Animation.displayObject)
		localGroup:insert(girl3Animation.displayObject)
		
		local function newAnimal (ID, yPos, scale, number)
			local thisAnimal = {}
			
			local openEyesR = nil
			local closedEyesR = nil
			
			local distanceScale = 1
			
			local runningSound
			local animalSoundChannel = nil
			
			thisAnimal.isAlive = true
			
			if not ID then
				ID = 1
			end
			
			if not yPos then
				yPos = 0
			end
			
			if not scale then
				scale = 1
			end
			
			thisAnimal.displayObject = display.newGroup()
			
			if ID == 1 then
				openEyesR = display.newImage("assets/cat/EyesOpen.png")
				closedEyesR = display.newImage("assets/cat/EyesClosed.png")
				
				thisAnimal.runningAnimal = ui.newAnimation{
					comps = {
						{
							--tail
							path = "assets/cat/tail.png",
							x = { 37.85,36,40.05,44.4,49.15,50.5,51.95,47.8,43.75,39.95 },
							y = { 115.75,117.15,112.1,107.35,103.1,103.25,103.6,107.1,110.8,114.8 },
							rotation = { -33.51014709472656,-39.37852478027344,-33.28041076660156,-27.186904907226563,-21.088394165039063,-16.932525634765625,-12.77471923828125,-17.72918701171875,-22.685623168945313,-27.640914916992188 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--larm
							path = "assets/cat/larm.png",
							x = { 219.4,213.95,208.65,203.65,199.1,203.65,208.7,213.95,219.4,224.8 },
							y = { 207.4,209,209.4,208.9,207.35,208.9,209.35,209,207.4,204.8 },
							rotation = { 29.1588134765625,40.210479736328125,51.26298522949219,62.31587219238281,73.36959838867188,62.31587219238281,51.26298522949219,40.20997619628906,29.1588134765625,18.10516357421875 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--lleg
							path = "assets/cat/lleg.png",
							x = { 67.4,70.75,74.35,78.25,82.3,78.2,74.35,70.7,67.35,64.4 },
							y = { 203.65,204.75,205.5,205.85,205.75,205.85,205.45,204.75,203.65,202.2 },
							rotation = { -66.32954406738281,-73.04988098144531,-79.77272033691406,-86.49421691894531,-93.21566772460938,-86.49334716796875,-79.77102661132813,-73.05067443847656,-66.32881164550781,-59.60957336425781 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--body
							path = "assets/cat/body.png",
							x = { 152.3,152.7,153.2,153.7,154.2,153.7,153.2,152.7,152.3,151.8 },
							y = { 167.15,167.35,167.5,167.7,167.85,167.7,167.5,167.3,167.1,167.05 },
							rotation = { -26.330978393554688,-25.020858764648438,-23.708572387695313,-22.398513793945313,-21.087631225585938,-22.398513793945313,-23.710769653320313,-25.019424438476563,-26.332382202148438,-27.642974853515625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--head
							path = "assets/cat/head.png",
							x = { 208.95,207.85,206.7,205.55,204.3,205.55,206.65,207.85,208.95,210.05 },
							y = { 85.4,86.8,88.35,90.05,91.95,90.05,88.35,86.85,85.45,84.15 },
							rotation = { -8.8072509765625,-11.87689208984375,-14.945892333984375,-18.016647338867188,-21.08612060546875,-18.016647338867188,-14.945892333984375,-11.876052856445313,-8.806396484375,-5.736907958984375 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
							yOffset = 0
						},{
							displayObject = closedEyesR,
							scaleComponent = true,
							x = { 208.95,207.85,206.7,205.55,204.3,205.55,206.65,207.85,208.95,210.05 },
							y = { 85.4,86.8,88.35,90.05,91.95,90.05,88.35,86.85,85.45,84.15 },
							rotation = { -8.8072509765625,-11.87689208984375,-14.945892333984375,-18.016647338867188,-21.08612060546875,-18.016647338867188,-14.945892333984375,-11.876052856445313,-8.806396484375,-5.736907958984375 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
							yOffset = 0
						},{
							displayObject = openEyesR,
							scaleComponent = true,
							x = { 208.95,207.85,206.7,205.55,204.3,205.55,206.65,207.85,208.95,210.05 },
							y = { 85.4,86.8,88.35,90.05,91.95,90.05,88.35,86.85,85.45,84.15 },
							rotation = { -8.8072509765625,-11.87689208984375,-14.945892333984375,-18.016647338867188,-21.08612060546875,-18.016647338867188,-14.945892333984375,-11.876052856445313,-8.806396484375,-5.736907958984375 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
							yOffset = 0
						},{
							--rleg
							path = "assets/cat/rleg.png",
							x = { 90.8,86.05,81.65,77.65,74.4,77.65,81.6,85.95,90.8,96 },
							y = { 227.9,224.85,221.1,216.65,211.65,216.65,221.1,224.85,227.85,230.25 },
							rotation = { -41.13728332519531,-32.019866943359375,-22.901107788085938,-13.7841796875,-4.6634979248046875,-13.7841796875,-22.900375366210938,-32.01924133300781,-41.137786865234375,-50.25514221191406 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--rarm
							path = "assets/cat/rarm.png",
							x = { 167.1,170.55,175.9,181.05,185.7,180.1,173.95,170.5,167.05,163.55 },
							y = { 236.25,236.65,236.1,234.7,232.3,235.1,236.65,236.7,236.3,235.35 },
							rotation = { 11.56005859375,4.7555389404296875,-5.5282440185546875,-15.8106689453125,-26.093826293945313,-14.074081420898438,-2.0536346435546875,4.7529296875,11.559219360351563,18.366195678710938 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						}
					},
					scale = scale * 1.666,
					speed = 0.2
				}
				thisAnimal.runningAnimal.hide()
				
				runningSound = audio.loadSound("assets/sound/catMeow.mp3")
			elseif ID == 2 then
				openEyesR = display.newImage("assets/dog/EyesOpen.png")
				closedEyesR = display.newImage("assets/dog/EyesClosed.png")
				
				thisAnimal.runningAnimal = ui.newAnimation{
					comps = {
						{
							--tail
							path = "assets/dog/tail.png",
							x = { 25.85,25.9,26,27.35,28.8,30.3,31.9,32.1,32.6,33,33.6,30.95,28.25,25.9 },
							y = { 144.1,143.5,142.9,140.75,138.7,136.55,134.65,135.1,135.75,136.45,137.4,139.6,142,144.9 },
							rotation = { -37.489715576171875,-41.768890380859375,-46.047515869140625,-42.41693115234375,-38.78326416015625,-35.14884948730469,-31.515594482421875,-25.603134155273438,-19.685821533203125,-13.7742919921875,-7.86065673828125,-16.312026977539063,-24.76043701171875,-33.21070861816406 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--body
							path = "assets/dog/body.png",
							x = { 128.55,128.9,129.25,129.55,129.9,130.25,130.55,130.25,129.9,129.55,129.25,128.9,128.55,128.2 },
							y = { 178.95,178.95,179,179,179.1,179.25,179.35,179.25,179.1,179,179,178.95,178.95,178.9 },
							rotation = { -0.5061798095703125,0.4231414794921875,1.3557281494140625,2.285858154296875,3.2174072265625,4.14898681640625,5.0774993896484375,4.14898681640625,3.2174072265625,2.285858154296875,1.3557281494140625,0.4231414794921875,-0.5061798095703125,-1.4387359619140625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--head
							path = "assets/dog/head.png",
							x = { 200.25,202.35,204.3,206.5,208.45,210.45,212.45,210.45,208.45,206.5,204.3,202.35,200.25,198.15 },
							y = { 95.3,96.65,97.95,99.4,100.85,102.35,103.85,102.35,100.85,99.4,97.95,96.65,95.3,94.05 },
							rotation = { 0.1451263427734375,1.7278900146484375,3.3106536865234375,4.8927001953125,6.4733428955078125,8.057876586914063,9.640289306640625,8.057876586914063,6.4733428955078125,4.8927001953125,3.3106536865234375,1.7278900146484375,0.1451263427734375,-1.4387359619140625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							displayObject = closedEyesR,
							scaleComponent = true,
							x = { 200.25,202.35,204.3,206.5,208.45,210.45,212.45,210.45,208.45,206.5,204.3,202.35,200.25,198.15 },
							y = { 95.3,96.65,97.95,99.4,100.85,102.35,103.85,102.35,100.85,99.4,97.95,96.65,95.3,94.05 },
							rotation = { 0.1451263427734375,1.7278900146484375,3.3106536865234375,4.8927001953125,6.4733428955078125,8.057876586914063,9.640289306640625,8.057876586914063,6.4733428955078125,4.8927001953125,3.3106536865234375,1.7278900146484375,0.1451263427734375,-1.4387359619140625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							displayObject = openEyesR,
							scaleComponent = true,
							x = { 200.25,202.35,204.3,206.5,208.45,210.45,212.45,210.45,208.45,206.5,204.3,202.35,200.25,198.15 },
							y = { 95.3,96.65,97.95,99.4,100.85,102.35,103.85,102.35,100.85,99.4,97.95,96.65,95.3,94.05 },
							rotation = { 0.1451263427734375,1.7278900146484375,3.3106536865234375,4.8927001953125,6.4733428955078125,8.057876586914063,9.640289306640625,8.057876586914063,6.4733428955078125,4.8927001953125,3.3106536865234375,1.7278900146484375,0.1451263427734375,-1.4387359619140625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--rarm
							path = "assets/dog/rarm.png",
							x = { 187.85,190.5,192.9,195.15,197.1,198.7,200.05,198.7,197.1,195.15,192.9,190.5,187.85,185.2 },
							y = { 227.65,227.35,226.8,225.9,224.65,223.2,221.55,223.2,224.65,225.9,226.8,227.35,227.65,227.55 },
							rotation = { 41.54829406738281,34.25605773925781,26.961639404296875,19.6695556640625,12.377456665039063,5.084442138671875,-2.210784912109375,5.084442138671875,12.377456665039063,19.6695556640625,26.961639404296875,34.25605773925781,41.54829406738281,48.84040832519531 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--larm
							path = "assets/dog/larm.png",
							x = { 233.4,231.1,227.95,224,219.55,214.75,209.65,214.75,219.55,224,227.95,231.1,233.4,234.7 },
							y = { 196.95,202.65,207.65,212,215.6,218.2,219.7,218.2,215.6,212,207.65,202.65,196.95,190.9 },
							rotation = { 10.557144165039063,22.55377197265625,34.553619384765625,46.5501708984375,58.546722412109375,70.54391479492188,82.53952026367188,70.54391479492188,58.546722412109375,46.5501708984375,34.553619384765625,22.55377197265625,10.557144165039063,-1.4387359619140625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--rleg
							path = "assets/dog/rleg.png",
							x = { 50.6,53.5,56.7,60.1,63.6,67.3,70.85,67.3,63.6,60.1,56.7,53.5,50.6,48.15 },
							y = { 232.15,233.2,233.95,234.1,233.7,232.75,231.3,232.75,233.7,234.1,233.95,233.2,232.15,230.5 },
							rotation = { -9.980697631835938,-18.525909423828125,-27.070571899414063,-35.61375427246094,-44.15928649902344,-52.70396423339844,-61.24681091308594,-52.70396423339844,-44.15928649902344,-35.61375427246094,-27.070571899414063,-18.525909423828125,-9.980697631835938,-1.4369964599609375 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--lleg
							path = "assets/dog/lleg.png",
							x = { 42.85,39.35,36.15,33.15,30.6,28.3,26.6,28.3,30.6,33.15,36.15,39.35,42.85,46.35 },
							y = { 219.6,217.3,214.5,211.3,207.65,203.6,199.3,203.6,207.65,211.3,214.5,217.3,219.6,221.3 },
							rotation = { -65.19200134277344,-56.47222900390625,-47.74983215332031,-39.02784729003906,-30.307098388671875,-21.585983276367188,-12.864486694335938,-21.585983276367188,-30.307098388671875,-39.02784729003906,-47.74983215332031,-56.47222900390625,-65.19271850585938,-73.91532897949219 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},
					},
					scale = scale * 1.666,
					speed = 0.2
				}
				
				thisAnimal.runningAnimal.hide()
				
				runningSound = audio.loadSound("assets/sound/dogBark.mp3")
			elseif ID == 3 then
				openEyesR = display.newImage("assets/rabbit/EyesOpen.png")
				closedEyesR = display.newImage("assets/rabbit/EyesClosed.png")
				
				thisAnimal.runningAnimal = ui.newAnimation{
					comps = {
						{
							--lear
							path = "assets/rabbit/lear.png",
							x = { 591.5,584,576.55,569.2,561.9,565.55,569.2,572.85,576.5,580.25,584.9,589.6,594.4,599.3 },
							y = { 372.5,340.5,308.7,277,245.6,227.3,209.15,191,172.85,154.8,217.15,279.6,342.1,404.75 },
							rotation = { -2.4098052978515625,-4.81805419921875,-7.2257080078125,-9.633499145507813,-12.0408935546875,-10.836563110351563,-9.632644653320313,-8.42694091796875,-7.2239837646484375,-6.021514892578125,-4.5140838623046875,-3.009063720703125,-1.5051422119140625,-0.0008697509765625 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--head
							path = "assets/rabbit/head.png",
							x = { 683,678.6,674.1,669.5,664.75,667.15,669.5,671.8,674.15,676.35,679.05,681.9,684.65,687.3 },
							y = { 567.55,530.65,493.85,457.15,420.6,404.95,389.25,373.65,358.1,342.55,408.05,473.55,539.1,604.65 },
							rotation = { -0.5656280517578125,-1.132904052734375,-1.699066162109375,-2.2649078369140625,-2.8329315185546875,-2.5494232177734375,-2.26666259765625,-1.9846649169921875,-1.7008209228515625,-1.4177703857421875,-1.062103271484375,-0.7081146240234375,-0.35406494140625,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							displayObject = openEyesR,
							scaleComponent = true,
							x = { 683,678.6,674.1,669.5,664.75,667.15,669.5,671.8,674.15,676.35,679.05,681.9,684.65,687.3 },
							y = { 567.55,530.65,493.85,457.15,420.6,404.95,389.25,373.65,358.1,342.55,408.05,473.55,539.1,604.65 },
							rotation = { -0.5656280517578125,-1.132904052734375,-1.699066162109375,-2.2649078369140625,-2.8329315185546875,-2.5494232177734375,-2.26666259765625,-1.9846649169921875,-1.7008209228515625,-1.4177703857421875,-1.062103271484375,-0.7081146240234375,-0.35406494140625,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							displayObject = closedEyesR,
							scaleComponent = true,
							x = { 683,678.6,674.1,669.5,664.75,667.15,669.5,671.8,674.15,676.35,679.05,681.9,684.65,687.3 },
							y = { 567.55,530.65,493.85,457.15,420.6,404.95,389.25,373.65,358.1,342.55,408.05,473.55,539.1,604.65 },
							rotation = { -0.5656280517578125,-1.132904052734375,-1.699066162109375,-2.2649078369140625,-2.8329315185546875,-2.5494232177734375,-2.26666259765625,-1.9846649169921875,-1.7008209228515625,-1.4177703857421875,-1.062103271484375,-0.7081146240234375,-0.35406494140625,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--rear
							path = "assets/rabbit/rear.png",
							x = { 429,422.6,416.55,410.75,405.35,408,410.8,413.65,416.55,419.5,423.3,427.35,431.5,435.8 },
							y = { 448.65,420.6,392.75,365.05,337.4,317.3,297.2,277.05,256.9,236.8,296.8,356.7,416.75,476.85 },
							rotation = { -3.076202392578125,-6.1503143310546875,-9.225967407226563,-12.301544189453125,-15.374298095703125,-13.83612060546875,-12.298202514648438,-10.759796142578125,-9.221710205078125,-7.6838531494140625,-5.7646026611328125,-3.8418731689453125,-1.9209136962890625,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--lgemelo
							path = "assets/rabbit/lgemelo.png",
							x = { 357.85,351.1,346.3,343.8,343.6,343.5,343.9,344.9,346.4,348.4,351.65,355.75,360.8,366.65 },
							y = { 877.45,856.4,834.55,811.55,787.25,765.65,743.65,721.3,698.65,675.7,731.6,787.2,842.6,898 },
							rotation = { -9.095596313476563,-18.190414428710938,-27.287124633789063,-36.38165283203125,-45.47674560546875,-40.92933654785156,-36.380523681640625,-31.833465576171875,-27.28643798828125,-22.738449096679688,-17.053253173828125,-11.36859130859375,-5.6840972900390625,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--lfoot
							path = "assets/rabbit/lfoot.png",
							x = { 322.95,318.15,315.3,315,318.05,316.1,315,314.75,315.2,316.25,318.35,321.25,324.75,328.7 },
							y = { 954.7,947.5,935.25,916.85,892.25,871.45,849,824.95,799.4,772.25,821.3,868.3,913.7,957.6 },
							rotation = { 18.65472412109375,37.307647705078125,55.962493896484375,74.61512756347656,93.26620483398438,83.94044494628906,74.61431884765625,65.28715515136719,55.96009826660156,46.63276672363281,34.97430419921875,23.316757202148438,11.659042358398438,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--body
							path = "assets/rabbit/body.png",
							x = { 448.6,447.2,445.7,444.4,442.9,443.65,444.35,445.05,445.7,446.45,447.35,448.2,449.25,450.2 },
							y = { 716.15,684.2,652.4,620.55,588.85,570.75,552.7,534.6,516.65,498.5,560.9,623.3,685.7,748.1 },
							rotation = { -1.4972686767578125,-2.99163818359375,-4.487152099609375,-5.98260498046875,-7.4768218994140625,-6.72784423828125,-5.9808807373046875,-5.23187255859375,-4.4845428466796875,-3.736541748046875,-2.802398681640625,-1.8685150146484375,-0.93450927734375,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--larm
							path = "assets/rabbit/larm.png",
							x = { 738.9,738.5,737.75,737,735.9,739.3,742.15,744.05,745.4,745.9,744.95,747.4,748.15,747.15 },
							y = { 766.9,728.1,689.4,650.65,611.9,589.5,566.95,544.2,521.35,498.5,551.4,628.95,706.55,784.05 },
							rotation = { 14.927932739257813,13.986038208007813,13.043014526367188,12.101089477539063,11.158370971679688,5.8693084716796875,0.58135986328125,-4.7069091796875,-9.9951171875,-15.284042358398438,-24.328567504882813,-16.21856689453125,-8.108444213867188,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--rarm
							path = "assets/rabbit/rarm.png",
							x = { 600.85,600.3,599.15,597.55,595.4,600.35,604.6,608,610.35,611.85,610.6,611.35,610.9,609.05 },
							y = { 829.05,798.85,768.6,737.95,706.95,679.05,650.45,621.35,592.15,563.1,615.3,689.3,763.5,837.45 },
							rotation = { 13.70745849609375,11.4080810546875,9.108383178710938,6.8088836669921875,4.5088653564453125,0.8995513916015625,-2.7082061767578125,-6.3170623779296875,-9.926422119140625,-13.53570556640625,-21.483108520507813,-14.3214111328125,-7.161163330078125,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--tail
							path = "assets/rabbit/tail.png",
							x = { 146.35,141.1,137.75,136.5,137.45,136.65,136.6,136.95,137.85,139.35,141.65,144.9,148.85,153.4 },
							y = { 757.45,740.5,724.55,709.3,694.2,667.75,641.35,615.05,588.75,562.7,615.2,668.15,721.6,775.65 },
							rotation = { -11.441680908203125,-22.88330078125,-34.32469177246094,-45.76611328125,-57.206817626953125,-51.48548889160156,-45.7647705078125,-40.04435729980469,-34.3240966796875,-28.602447509765625,-21.453567504882813,-14.302536010742188,-7.1508331298828125,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--rmuslo
							path = "assets/rabbit/rmuslo.png",
							x = { 313.25,312.15,310.7,308.95,307.05,308.05,309,309.9,310.75,311.45,312.35,313.05,313.65,314.1 },
							y = { 876.8,853.25,829.2,804.6,779.5,758.15,736.8,715.2,693.45,671.6,729.05,786.15,843.2,900.05 },
							rotation = { 6.758880615234375,13.518356323242188,20.277297973632813,27.03729248046875,33.79608154296875,30.415802001953125,27.035202026367188,23.656509399414063,20.276535034179688,16.895706176757813,12.673233032226563,8.449172973632813,4.2237701416015625,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--rgemelo
							path = "assets/rabbit/rgemelo.png",
							x = { 266,264,261.4,258.6,255.45,257.05,258.65,260.1,261.5,262.85,264.35,265.6,266.75,267.6 },
							y = { 906.75,889.85,872.3,853.9,834.55,810.45,786.05,761.45,736.55,711.55,764.8,817.75,870.5,922.95 },
							rotation = { -2.9776763916015625,-5.9523468017578125,-8.927597045898438,-11.902847290039063,-14.8773193359375,-13.391006469726563,-11.902008056640625,-10.414291381835938,-8.925888061523438,-7.4364166259765625,-5.5784759521484375,-3.7191314697265625,-1.86065673828125,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--rfoot
							path = "assets/rabbit/rfoot.png",
							x = { 252.75,252.6,248.45,240.55,229.3,235.35,240.5,244.95,248.45,251.05,252.95,253.1,251.65,248.65 },
							y = { 942.65,946.7,949.3,949.6,946.55,914.6,881.65,848,813.5,778.4,818.85,858.8,898.4,938.1 },
							rotation = { 13.351287841796875,26.70196533203125,40.053070068359375,53.40473937988281,66.75479125976563,60.07887268066406,53.4041748046875,46.7271728515625,40.05204772949219,33.37745666503906,25.033065795898438,16.68817138671875,8.34393310546875,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
					},
					scale = scale*0.3*5,
					speed = 0.4
				}
				
				thisAnimal.runningAnimal.hide()
				
				runningSound = nil
			elseif ID == 4 then
				openEyesR = display.newImage("assets/frog/EyesOpen.png")
				closedEyesR = display.newImage("assets/frog/EyesClosed.png")
				
				thisAnimal.runningAnimal = ui.newAnimation{
					comps = {
						{
						 --body
						 path = "assets/frog/body.png",
						 x = { 263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8 },
						 y = { 227.1,214.5,201.85,189.25,191.15,193.1,195.05,201.1,207.25,213.75,220.25,226.75,233.25,239.75 },
						 rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 displayObject = closedEyesR,
						 scaleComponent = true,
						 x = { 263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8 },
						 y = { 227.1,214.5,201.85,189.25,191.15,193.1,195.05,201.1,207.25,213.75,220.25,226.75,233.25,239.75 },
						 rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 displayObject = openEyesR,
						 scaleComponent = true,
						 x = { 263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8 },
						 y = { 227.1,214.5,201.85,189.25,191.15,193.1,195.05,201.1,207.25,213.75,220.25,226.75,233.25,239.75 },
						 rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 --rleg
						 path = "assets/frog/rleg.png",
						 x = { 184.15,179.6,175,170.6,173.65,176.95,180.2,183.5,186.85,187.1,187.45,187.8,188.05,188.45 },
						 y = { 315.3,308,299.75,290.4,291.15,291.55,291.55,295,298.15,302.85,307.55,312.2,316.9,321.75 },
						 rotation = { 11.175201416015625,22.350662231445313,33.52412414550781,44.697784423828125,36.772369384765625,28.84716796875,20.921539306640625,12.996536254882813,5.0731658935546875,4.05853271484375,3.0448150634765625,2.03094482421875,1.0157928466796875,0.0017547607421875 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 --rknee
						 path = "assets/frog/rknee.png",
						 x = { 160.85,154.75,149.45,145.2,149.85,155.05,160.45,165.9,171.3,170.3,169.45,168.55,167.95,168.5 },
						 y = { 369.7,368.1,363.3,355.05,355.9,355.15,352.7,352.65,351.4,354.8,358.25,361.65,364.95,367.85 },
						 rotation = { -10.126480102539063,-20.245758056640625,-30.366363525390625,-40.48419189453125,-34.862030029296875,-29.246078491210938,-23.631576538085938,-18.01348876953125,-12.40081787109375,-9.92047119140625,-7.4407196044921875,-4.9621124267578125,-2.4822235107421875,-0.0218505859375 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 --rfoot
						 path = "assets/frog/rfoot.png",
						 x = { 148.9,144.65,141.65,139.75,143.35,147.5,151.85,156.15,160.35,158.8,157.5,156.25,155.05,154.45 },
						 y = { 408.05,411.35,410.05,404.15,404.2,401.9,397.3,394.35,389.3,391.65,393.95,396.2,398.35,400.85 },
						 rotation = { -11.723587036132813,-4.3593902587890625,3.001220703125,10.366073608398438,4.4749755859375,-1.414276123046875,-7.302276611328125,-13.189788818359375,-19.078231811523438,-19.078231811523438,-19.080581665039063,-19.083694458007813,-19.086044311523438,-19.083694458007813 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 -- lknee
						 path = "assets/frog/lknee.png",
						 x = { 222.65,220.95,219.95,219.9,221.05,222.3,223.9,225.85,227.8,227,226.45,225.85,225.4,225.15 },
						 y = { 349.35,340.35,329.35,316.85,319.15,320.75,321.65,325.95,329.35,335,340.55,346.05,351.4,356.1 },
						 rotation = { -8.752593994140625,-17.502044677734375,-26.25225830078125,-35.0001220703125,-31.657058715820313,-28.317291259765625,-24.977767944335938,-21.636611938476563,-18.29766845703125,-14.637771606445313,-10.978179931640625,-7.3194732666015625,-3.6599273681640625,-0.0113677978515625 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 --lfoot
						 path = "assets/frog/lfoot.png",
						 x = { 213.5,212.15,212,213.15,214.6,216.4,218.3,220.4,222.5,220.75,219.15,217.85,216.7,215.95 },
						 y = { 374.1,369.4,362.25,352.8,353.95,354.25,353.6,355.75,357,361.1,365.15,369.1,372.9,376.9 },
						 rotation = { -15.1708984375,-6.047454833984375,3.0770721435546875,12.200515747070313,4.5644683837890625,-3.067474365234375,-10.701553344726563,-18.33233642578125,-25.963943481445313,-25.629440307617188,-25.295196533203125,-24.963409423828125,-24.629104614257813,-24.300262451171875 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 --rarm
						 path = "assets/frog/rarm.png",
						 x = { 294.05,295.5,297,298.45,297.55,296.65,295.8,294.8,293.95,293.65,293.4,293.1,292.85,293.25 },
						 y = { 318.55,306.35,294.05,281.8,283.5,285.05,286.65,292.5,298.35,304.8,311.3,317.75,324.25,330.1 },
						 rotation = { -1.967193603515625,-3.93585205078125,-5.903900146484375,-7.8726654052734375,-7.085418701171875,-6.298065185546875,-5.5100555419921875,-4.7234039306640625,-3.9349822998046875,-3.1494140625,-2.3618011474609375,-1.5750274658203125,-0.78765869140625,-0.0008697509765625 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 --rforearm
						 path = "assets/frog/rforearm.png",
						 x = { 303.55,304.15,304.65,305.1,304.3,304.15,304,303.8,303.8,303.65,303.4,303.2,302.9,304.95 },
						 y = { 348.45,337.05,325.6,314,315.3,316.05,316.9,322.3,327.4,334,340.5,347.05,353.6,357.75 },
						 rotation = { 3.278411865234375,6.55792236328125,9.836471557617188,13.115997314453125,11.802352905273438,10.487838745117188,9.174850463867188,7.8597869873046875,6.5467071533203125,5.2370758056640625,3.9280242919921875,2.61834716796875,1.3085479736328125,0 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 --rhand
						 path = "assets/frog/rhand.png",
						 x = { 341.2,340.95,340.5,339.7,339.6,339.5,339.45,339.2,339,339.55,340.1,340.5,340.9,341.15 },
						 y = { 364.3,355.55,346.7,337.7,338.1,338.45,338.9,343.2,347.65,352.8,357.9,362.95,368,372.95 },
						 rotation = { 3.278411865234375,6.55792236328125,9.836471557617188,13.115997314453125,11.802352905273438,10.487838745117188,9.174850463867188,7.8597869873046875,6.5467071533203125,5.2370758056640625,3.9280242919921875,2.61834716796875,1.3085479736328125,0 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 --lforearm
						 path = "assets/frog/lforearm.png",
						 x = { 359.8,359.75,359.85,359.7,359.7,359.45,359.3,359.2,359.05,359.2,359.4,359.45,359.65,360.4 },
						 y = { 322.4,310.4,298.55,286.6,287.95,289.9,291.9,297.6,303.65,309.7,315.75,321.8,327.85,334.1 },
						 rotation = { -2.239593505859375,0.74920654296875,3.73828125,6.72784423828125,6.05438232421875,5.380096435546875,4.7069091796875,4.0350341796875,3.3664093017578125,1.6475372314453125,-0.071685791015625,-1.7899169921875,-3.50927734375,-5.2188568115234375 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 --lhand
						 path = "assets/frog/lhand.png",
						 x = { 393.05,391.65,390.05,388.35,388.4,389.15,389.9,390.1,390.65,391.4,392.15,392.85,393.5,395.2 },
						 y = { 334.95,324.55,314,303.35,305.1,306.9,308.6,314.6,320.65,325.65,330.6,335.55,340.45,345.4 },
						 rotation = { -2.239593505859375,0.74920654296875,3.73828125,6.72784423828125,6.05438232421875,5.380096435546875,4.7069091796875,4.0350341796875,3.3664093017578125,1.6475372314453125,-0.071685791015625,-1.7899169921875,-3.50927734375,-5.2188568115234375 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},
					},
					scale = scale*0.5*3,
					speed = 0.2
				}
				
				thisAnimal.runningAnimal.hide()
				
				runningSound = nil
			else
				--print("no animal")
			end
			
			local RBlinks = ui.blink(openEyesR,closedEyesR)
			
			localGroup:insert(thisAnimal.displayObject)
			thisAnimal.addRunningAnimalLayer = function()
				if thisAnimal.runningAnimal.displayObject then
					thisAnimal.displayObject:insert(thisAnimal.runningAnimal.displayObject)
				end
			end
			local defineAnimation
			
			local function move()
					if paused or (not thisAnimal.displayObject) then return end
					if not thisAnimal then Runtime:removeEventListener( "enterFrame", move ); return end
					if not thisAnimal.displayObject then Runtime:removeEventListener( "enterFrame", move ); return end
					if not thisAnimal.displayObject.xScale then Runtime:removeEventListener( "enterFrame", move ); return end
					local movementSpeed = 4*scale
					movementSpeed = movementSpeed * thisAnimal.displayObject.xScale
					thisAnimal.displayObject.x = thisAnimal.displayObject.x + movementSpeed
					
					if thisAnimal.displayObject.x < -50*scale or thisAnimal.displayObject.x > width + 50*scale then
						
						if thisAnimal.displayObject.x < -50*scale then
							thisAnimal.displayObject.y = yPos
						end
						thisAnimal.runningAnimal.hide()
						
						thisAnimal.displayObject.x = width
						
						thisAnimal.displayObject.y = yPos
						defineAnimation()
						
						Runtime:removeEventListener( "enterFrame", move )
						thisAnimal.startRunning ()
					end
			end
			
			local function talk()
				if thisAnimal.isAlive and thisAnimal.isRunning then
					if math.random(40) > 35 then
						if not isDragging then
							if animalSoundChannel then
								audio.stop(animalSoundChannel)
							end
							audio.play(runningSound,{loops=0, channel=animalSoundChannel})
						end
					end
				end
				timer.performWithDelay(5000, talk)
			end
			talk()
			
			thisAnimal.startRunning = function()
				Runtime:addEventListener( "enterFrame", move )
				
				thisAnimal.runningAnimal.stop()
				
				thisAnimal.runningAnimal.start()
				thisAnimal.runningAnimal.appear()
				
				if RBlinks then
					RBlinks.openEyes()
					RBlinks.startBlinking()
				end
				
				thisAnimal.isRunning = true
			end
			
			thisAnimal.pauseAnimal = function()
				if thisAnimal.runningAnimal.isMoving then
					thisAnimal.runningAnimal.wasMoving = true
					thisAnimal.runningAnimal.stop()
					RBlinks.stopBlinking()
				end
				animalPaused=true
			end
			
			thisAnimal.resumeAnimal = function()
				if thisAnimal.runningAnimal.wasMoving then
					thisAnimal.runningAnimal.wasMoving = nil
					thisAnimal.runningAnimal.start()
					RBlinks.startBlinking()
				end
				animalPaused=nil
			end
			
			defineAnimation = function ()
				distanceScale = (thisAnimal.displayObject.y / (height/2))^(0.65)
				if distanceScale == 0 then
					distanceScale = 1
				end
					thisAnimal.displayObject.xScale = -1 * distanceScale
					thisAnimal.displayObject.yScale = distanceScale
			end
			defineAnimation()
			
			thisAnimal.sayHello = function ()
				--print("hello")
			end
			
			thisAnimal.kill = function()
				Runtime:removeEventListener( "enterFrame", move )
				
				if thisAnimal.runningAnimal then
					thisAnimal.runningAnimal.kill()
				end
				
				if thisAnimal.displayObject then
					if thisAnimal.displayObject.parent then
						thisAnimal.displayObject.parent: remove(thisAnimal.displayObject)
					end
				end
				
				thisAnimal.isAlive = false
			end
			
			thisAnimal.vanish = function(time)
				thisAnimal.runningAnimal.vanish(time)
			end
			
			return thisAnimal
		end
		
		local animal1 = newAnimal(1,200-subtitleGroup.contentHeight*0.8*daScale,0.3,1)
		local animal2 = newAnimal(2,200-subtitleGroup.contentHeight*0.8*daScale,0.3,2)
		local animal3 = newAnimal(3,210-subtitleGroup.contentHeight*0.8*daScale,0.3,3)
		local animal4 = newAnimal(4,230-subtitleGroup.contentHeight*0.8*daScale,0.3,4)
		
		animal1.addRunningAnimalLayer()
		animal2.addRunningAnimalLayer()
		animal4.addRunningAnimalLayer()
		animal3.addRunningAnimalLayer()
		
		local function continue ()
			localGroup:remove(background)
			
			girl1Blinks.stopBlinking()
			girl2Blinks.stopBlinking()
			girl3Blinks.stopBlinking()
			
			girl1Animation.kill()
			girl2Animation.kill()
			girl3Animation.kill()
			
			animal1.kill()
			animal2.kill()
			animal3.kill()
			animal4.kill()
		end
		
		local function vanish ()
			startTransition ()
			timer.performWithDelay(1500,continue)
		end
		
		startAnimalsChasingAnimation = function()
			soundController.playNew{
					path = "assets/sound/effects/girlslaughing2.mp3",
					loops = 0,
					pausable = false,
					staticChannel = 4,
					actionTimes = {},
					action =	function()
								end,
					onComplete = function()
								end
					}
			
			nextSubtitle()
			
			background.isVisible=true
			background.alpha = 0
			
			transition.to(background,{alpha=1,time=300})
			girl1Animation.appear(300)
			girl2Animation.appear(300)
			girl3Animation.appear(300)
			
			girl1Animation.start()
			girl2Animation.start()
			girl3Animation.start()
			
			local aat1 = timer.performWithDelay(1600, animal1.startRunning)
			local aat2 = timer.performWithDelay(200, animal2.startRunning)
			local aat3 = timer.performWithDelay(4200, animal3.startRunning)
			local aat4 = timer.performWithDelay(3000, animal4.startRunning)
			
			girl1Blinks.closeEyes()
			girl1Blinks.startBlinking()
			
			girl2Blinks.closeEyes()
			girl2Blinks.startBlinking()
			
			girl3Blinks.closeEyes()
			girl3Blinks.startBlinking()
			
			local vt = timer.performWithDelay(6500,vanish)
			
			pauseIt = function()
				timer.pause(vt)
				girl1Animation.stop()
				girl2Animation.stop()
				girl3Animation.stop()
				girl1Blinks.stopBlinking()
				girl2Blinks.stopBlinking()
				girl3Blinks.stopBlinking()
				
				if aat1 then timer.pause(aat1) end
				if aat2 then timer.pause(aat2) end
				if aat3 then timer.pause(aat3) end
				if aat4 then timer.pause(aat4) end
				animal1.pauseAnimal()
				animal2.pauseAnimal()
				animal3.pauseAnimal()
				animal4.pauseAnimal()
			end
			
			continueIt = function()
				timer.resume(vt)
				girl1Animation.start()
				girl2Animation.start()
				girl3Animation.start()
				girl1Blinks.startBlinking()
				girl2Blinks.startBlinking()
				girl3Blinks.startBlinking()
				
				if aat1 then timer.resume(aat1) end
				if aat2 then timer.resume(aat2) end
				if aat3 then timer.resume(aat3) end
				if aat4 then timer.resume(aat4) end
				animal1.resumeAnimal()
				animal2.resumeAnimal()
				animal3.resumeAnimal()
				animal4.resumeAnimal()
			end
			
			pauseIt()
			continueIt()
		end
	end
	prepareAnimalsChasingAnimation()
	
	--======================================
	-- SUBTITLE FRAME
	--======================================
	localGroup:insert(subtitleGroup)
	
	--======================================
	-- TRANSITION TO INTERACTIVITY
	--======================================
	local function prepareTransition()
		local star1 = display.newImage("assets/whiteStar.png")
		star1:setReferencePoint(display.TopLeftReferencePoint)
		star1.x = 20
		star1.y = 30
		star1.xScale = 0.1
		star1.yScale = 0.1
		star1.isVisible = false
		localGroup:insert(star1)
		
		local star2 = display.newImage("assets/whiteStar.png")
		star2:setReferencePoint(display.CenterReferencePoint)
		star2.x = 330
		star2.y = 70
		star2.xScale = 0.5
		star2.yScale = 0.5
		star2.isVisible = false
		localGroup:insert(star2)
		
		local star3 = display.newImage("assets/whiteStar.png")
		star3:setReferencePoint(display.CenterReferencePoint)
		star3.x = 230
		star3.y = 170
		star3.xScale = 0.05
		star3.yScale = 0.05
		star3.isVisible = false
		localGroup:insert(star3)
		
		local star4 = display.newImage("assets/whiteStar.png")
		star4:setReferencePoint(display.CenterReferencePoint)
		star4.x = 130
		star4.y = 220
		star4.xScale = 0.2
		star4.yScale = 0.2
		star4.isVisible = false
		localGroup:insert(star4)
		
		local star5 = display.newImage("assets/whiteStar.png")
		star5:setReferencePoint(display.CenterReferencePoint)
		star5.x = 150
		star5.y = 180
		star5.xScale = 0.25
		star5.yScale = 0.25
		star5.isVisible = false
		localGroup:insert(star5)
		
		local star6 = display.newImage("assets/whiteStar.png")
		star6:setReferencePoint(display.CenterReferencePoint)
		star6.x = 50
		star6.y = 280
		star6.xScale = 0.15
		star6.yScale = 0.15
		star6.isVisible = false
		localGroup:insert(star6)
		
		local star7 = display.newImage("assets/whiteStar.png")
		star7:setReferencePoint(display.CenterReferencePoint)
		star7.x = 10
		star7.y = 300
		star7.xScale = 0.4
		star7.yScale = 0.4
		star7.isVisible = false
		localGroup:insert(star7)
		
		local star8 = display.newImage("assets/whiteStar.png")
		star8:setReferencePoint(display.CenterReferencePoint)
		star8.x = 400
		star8.y = 260
		star8.xScale = 0.35
		star8.yScale = 0.35
		star8.isVisible = false
		localGroup:insert(star8)
		
		local function loadInteraction()
			localGroup:remove(star1)
			localGroup:remove(star2)
			localGroup:remove(star3)
			localGroup:remove(star4)
			localGroup:remove(star5)
			localGroup:remove(star6)
			localGroup:remove(star7)
			localGroup:remove(star8)
			
			pauseIt = nil
			continueIt = nil
			paused = nil
			
			director:changeScene("Interactivity1","crossFade")
		end
		
		local function continue()
			local whiteBackground = display.newImageRect("assets/world/silverGardenSky.jpg",width,height)
			whiteBackground:setReferencePoint(display.TopLeftReferencePoint)
			whiteBackground.x = 0
			whiteBackground.y = 0
			--whiteBackground:setFillColor(255,255,255)
			whiteBackground.alpha=0
			localGroup:insert(whiteBackground)
			transition.to(whiteBackground,{alpha=1,time=300,onComplete=loadInteraction})
		end
		
		local growStars
		
		local function vanish()
			--timer.performWithDelay(300, continue)
			continue()
		end
		
		startTransition = function()
			star1.isVisible = true
			star2.isVisible = true
			star3.isVisible = true
			star4.isVisible = true
			star5.isVisible = true
			star6.isVisible = true
			star7.isVisible = true
			star8.isVisible = true
			
			star1.alpha = 0
			star2.alpha = 0
			star3.alpha = 0
			star4.alpha = 0
			star5.alpha = 0
			star6.alpha = 0
			star7.alpha = 0
			star8.alpha = 0
			
			transition.to(star1,{alpha=1,time=300})
			transition.to(star2,{alpha=1,time=300})
			transition.to(star3,{alpha=1,time=300})
			transition.to(star4,{alpha=1,time=300})
			transition.to(star5,{alpha=1,time=300})
			transition.to(star6,{alpha=1,time=300})
			transition.to(star7,{alpha=1,time=300})
			transition.to(star8,{alpha=1,time=300})
			
			transition.to(star1,{xScale=3,time=1500,transition=easing.outExpo})
			transition.to(star2,{xScale=2.5,time=1500,transition=easing.outExpo})
			transition.to(star3,{xScale=2,time=1500,transition=easing.outExpo})
			transition.to(star4,{xScale=3.5,time=1500,transition=easing.outExpo})
			transition.to(star5,{xScale=2.7,time=1500,transition=easing.outExpo})
			transition.to(star6,{xScale=3,time=1500,transition=easing.outExpo})
			transition.to(star7,{xScale=3.5,time=1500,transition=easing.outExpo})
			transition.to(star8,{xScale=3,time=1500,transition=easing.outExpo})
			
			transition.to(star1,{yScale=3,time=1500,transition=easing.outExpo})
			transition.to(star2,{yScale=2.5,time=1500,transition=easing.outExpo})
			transition.to(star3,{yScale=2,time=1500,transition=easing.outExpo})
			transition.to(star4,{yScale=3.5,time=1500,transition=easing.outExpo})
			transition.to(star5,{yScale=2.7,time=1500,transition=easing.outExpo})
			transition.to(star6,{yScale=3,time=1500,transition=easing.outExpo})
			transition.to(star7,{yScale=3.5,time=1500,transition=easing.outExpo})
			transition.to(star8,{yScale=3,time=1500,transition=easing.outExpo})
			
			timer.performWithDelay(1000, vanish)
		end
	end
	prepareTransition()
	
	--====================================================================--
	-- SET UP A PAUSE OVERLAY
	--====================================================================--
	overlay = display.newRect(0,0,width,height)
	overlay:setFillColor(0,0,0,64)
	overlay.alpha=0
	localGroup:insert(overlay)
	
	--======================================
	-- MENU BUTTON
	--======================================
	-- ACTION
	local continueTimer
	local function continueGame( event )
		paused=false;
		if continueIt then
			continueIt()
			soundController.resume()
		end
    end
	local hideMenu = function ()
		if overlay then
			transition.to( overlay, { alpha=0, time=300, delay=0 } )
		end
		continueTimer = timer.performWithDelay(300, continueGame )
	end
	local menuButtonAction = function ( event )
		if event.phase == "release" then
			if continueTimer then
				timer.cancel(continueTimer)
			end
			if pauseIt and continueIt then
				paused=true
				pauseIt()
				soundController.pause()
				if overlay then
					transition.to( overlay, { alpha=1, time=300, delay=0 } )
				end
				director:openPopUp({inGame = true,
									animated = true,
									hideAction = hideMenu,
									startFromAdventure = nil,
									killCaller = killAll,
									},
									"igMenu")
			end
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
	
	--======================================
	-- EXECUTE FIRST ACTION, THEY WILL BE CHAINEXECUTED
	--======================================
	saveData(1,1)
	startAdventure()
	
	return localGroup
end