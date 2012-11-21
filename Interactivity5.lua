module(..., package.seeall)

local function restartIt()
	preloader:changeScene("Interactivity5","crossfade")
end

new = function ( params )
	soundController.killAll()
	Runtime:removeEventListener( "system", systemEvent )
	
	soundController.playNew{
					path = "assets/sound/interactivity5.mp3",
					loops = -1,
					identifier = "bgsound",
					pausable = false,
					staticChannel = 1,
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
	
	local screenMessages = ui.newScreenMessages()
	
	local misses = 0
	local extras = 0
	local startTime = 0
	local finishTime = 0
	
	local function addMisses(message,value,x,y)
		if type(message) ~= "string" then
			message,value,x,y = "",message,value,x
		end
		misses = misses + value
		if message and message ~= "" then message = message.." " end
		--screenMessages.newMessage(message.."-"..value*1000,x,y)
		screenMessages.newMessage("-"..value*1000,x,y)
	end
	
	local function addExtras(message,value,x,y)
		if type(message) ~= "string" then
			message,value,x,y = "",message,value,x
		end
		extras = extras + value
		if message and message ~= "" then message = message.." " end
		--screenMessages.newMessage(message.."+"..value*1000,x,y)
		screenMessages.newMessage("+"..value*1000,x,y)
	end
	
	--====================================================================--
	-- SET UP A LOCAL GROUP THAT WILL BE RETURNED
	--====================================================================--
	local localGroup = display.newGroup()
	localGroup:insert(screenMessages.displayObject)
	
	-- LOWER LAYER, THE BACKGROUND COLOR
	local backgroundColor = display.newRect(0,0,width,height)
	backgroundColor:setFillColor(255,255,235)
	localGroup:insert(backgroundColor)
	
	local startAdventure
	local startDemoLoop
	local startInteraction
	local startMarySleeping
	local startTheParty
	local startTransition
	
	local killAdventure
	local killDemoLoop
	local killInteraction
	local killTheParty
	local killTransition
	
	local gameOver
	local pauseIt
	local continueIt
	
	local function killAll()
		paused = nil
		gameOver = nil
		pauseIt = nil
		continueIt = nil
		screenMessages.kill()
		if killAdventure then
			killAdventure()
		end
		if killDemoLoop then
			killDemoLoop()
		end
		if killInteraction then
			killInteraction()
		end
		if killTheParty then
			killTheParty()
		end
		if killMarySleeping then
			killMarySleeping()
		end
		if killTransition then
			killTransition()
		end
	end
	
	local difficultyLevel = getDifficulty()
	
	--======================================
	-- START ADVENTURE
	--======================================
	local function prepareWelcomeScreen()
		local loadingBackground = display.newImageRect("assets/world/silverGardenSky.jpg",width,height)
		loadingBackground:setReferencePoint(display.TopLeftReferencePoint)
		loadingBackground.x = 0
		loadingBackground.y = 0
		localGroup:insert(loadingBackground)
		loadingBackground.isVisible = false
		
		local titleLabel = util.centeredWrappedText("Adventure 5\nHelp mary to go to sleep", 30, 36, mainFont1, {67,34,15,255})
		titleLabel.y = 0
		titleLabel.x = width/2
		localGroup:insert(titleLabel)
		titleLabel.isVisible = false
		
		titleLabel.alpha=0
		transition.to(titleLabel,{alpha=1,time=1500})
		timer.performWithDelay(1500,	function()
											titleLabel.alpha=1
										end)
		
		local function continue()
			localGroup:remove(loadingBackground)
			localGroup:remove(titleLabel)
			
			loadingBackground = nil
			titleLabel = nil
			
			continue = nil
			killAdventure = nil
		end
		killAdventure = function()
			startAdventure=nil
			vanish=nil
			continue()
		end
		
		local function vanish()
			pauseIt = nil
			continueIt = nil
			
			startDemoLoop()
			timer.performWithDelay(300, continue)
			
			vanish = nil
		end
		
		startAdventure = function()
			soundController.playNew{
						path = "assets/sound/voices/cap5/int5_N1.mp3",
						duration = 15000,
						actionTimes = {4500},
						identifier = "directions",
						action =	function()
										if vanish then
											vanish()
										end
									end,
						onComplete = function()
										if vanish then
											vanish()
										end
									end
						}
			--local thisTimer = timer.performWithDelay(3000, vanish)
			
			loadingBackground.isVisible = true
			titleLabel.isVisible = true
			
			pauseIt = function()
				--timer.pause(thisTimer)
			end
			
			continueIt = function()
				--timer.resume(thisTimer)
			end
			
			startAdventure = nil
		end
	end
	prepareWelcomeScreen()
	
	--======================================
	-- DEMO LOOP
	--======================================
	local function prepareDemoLoop()
		local started = false
		
		local loadingBackground = display.newImageRect("assets/interactivity5/fenceBG.jpg",width,height)
		loadingBackground:setReferencePoint(display.TopLeftReferencePoint)
		loadingBackground.x = 0
		loadingBackground.y = -75
		localGroup:insert(loadingBackground)
		loadingBackground.isVisible = false
		
		local openEyesR = nil
		local closedEyesR = nil
		
		local openEyesC = nil
		local closedEyesC = nil
		
		openEyesR = display.newImage("assets/sheep/EyesOpen.png")
		closedEyesR = display.newImage("assets/sheep/EyesClosed.png")
		
		openEyesC = display.newImage("assets/sheepCaught/EyesOpen.png")
		closedEyesC = display.newImage("assets/sheepCaught/EyesClosed.png")
		
		local runningAnimal = ui.newAnimation{
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
					scale = 0.3*0.75*1.666,
					speed = 0.4
				}
		local caughtAnimal = ui.newAnimation{
					comps = {
						{
							--Body
							path = "assets/sheepCaught/body.png",
							x = { 260.95,260.95,260.95,260.95,260.95,260.95,260.95,260.95,260.95,260.95 },
							y = { 244.85,241.85,238.85,235.85,232.9,235.85,238.85,241.85,244.85,247.85 },
							rotation = { 0,0,0,0,0,0,0,0,0,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--Head
							path = "assets/sheepCaught/head.png",
							x = { 255,255.2,255.35,255.55,255.7,255.55,255.35,255.2,255,254.85 },
							y = { 118.15,115.05,111.95,108.85,105.75,108.85,111.95,115.05,118.15,121.3 },
							rotation = { 1.506011962890625,3.011688232421875,4.5175628662109375,6.02325439453125,7.52923583984375,6.02325439453125,4.5175628662109375,3.011688232421875,1.506011962890625,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							displayObject = closedEyesC,
							scaleComponent = true,
							x = { 255,255.2,255.35,255.55,255.7,255.55,255.35,255.2,255,254.85 },
							y = { 118.15,115.05,111.95,108.85,105.75,108.85,111.95,115.05,118.15,121.3 },
							rotation = { 1.506011962890625,3.011688232421875,4.5175628662109375,6.02325439453125,7.52923583984375,6.02325439453125,4.5175628662109375,3.011688232421875,1.506011962890625,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							displayObject = openEyesC,
							scaleComponent = true,
							x = { 255,255.2,255.35,255.55,255.7,255.55,255.35,255.2,255,254.85 },
							y = { 118.15,115.05,111.95,108.85,105.75,108.85,111.95,115.05,118.15,121.3 },
							rotation = { 1.506011962890625,3.011688232421875,4.5175628662109375,6.02325439453125,7.52923583984375,6.02325439453125,4.5175628662109375,3.011688232421875,1.506011962890625,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--LArm
							path = "assets/sheepCaught/larm.png",
							x = { 329.5,330.5,331.4,332.3,333.35,332.3,331.4,330.5,329.5,329.05 },
							y = { 239.75,236.35,233.05,229.7,226.35,229.7,233.05,236.35,239.75,242.8 },
							rotation = { 13.017288208007813,11.787277221679688,10.556304931640625,9.324752807617188,8.093017578125,9.324752807617188,10.556304931640625,11.787277221679688,13.017288208007813,14.25408935546875 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--RLeg
							path = "assets/sheepCaught/rleg.png",
							x = { 228.9,229.85,230.85,231.8,232.75,231.8,230.85,229.85,228.9,227.95 },
							y = { 394.95,391.9,388.85,385.75,382.65,385.75,388.85,391.9,394.95,398 },
							rotation = { -1.3513641357421875,-2.702972412109375,-4.0550537109375,-5.406951904296875,-6.758026123046875,-5.406951904296875,-4.0550537109375,-2.702972412109375,-1.3513641357421875,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--RArm
							path = "assets/sheepCaught/rarm.png",
							x = { 206.9,206.2,205.5,204.8,204.1,204.8,205.5,206.2,206.9,207.65 },
							y = { 237.55,234.5,231.4,228.3,225.2,228.3,231.4,234.5,237.55,240.65 },
							rotation = { 1.1092987060546875,2.2186431884765625,3.328948974609375,4.4376068115234375,5.54815673828125,4.4376068115234375,3.328948974609375,2.2186431884765625,1.1092987060546875,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--LLeg
							path = "assets/sheepCaught/lleg.png",
							x = { 310.15,309.05,307.95,306.85,305.75,306.85,307.95,309.05,310.15,311.3 },
							y = { 390.75,387.75,384.75,381.75,378.65,381.75,384.75,387.75,390.75,393.7 },
							rotation = { 1.59075927734375,3.1808013916015625,4.7711639404296875,6.361968994140625,7.952423095703125,6.361968994140625,4.7711639404296875,3.1808013916015625,1.59075927734375,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},
					},
					x = -150*0.3,
					scale = 0.3 * 1.666,
					speed = 0.5
				}
		
		local RBlinks = ui.blink(openEyesR,closedEyesR)
		local CBlinks = ui.blink(openEyesC,closedEyesC)
		
		localGroup:insert(runningAnimal.displayObject)
		runningAnimal.hide()
		
		localGroup:insert(caughtAnimal.displayObject)
		caughtAnimal.hide()
		
		runningAnimal.displayObject:setReferencePoint(display.CenterReferencePoint)
		runningAnimal.displayObject.y = 150
		runningAnimal.displayObject.x = width - 100
		runningAnimal.displayObject.xScale = -1
		
		caughtAnimal.displayObject:setReferencePoint(display.CenterReferencePoint)
		
		local handComponent = {
							path = "assets/hand.png",
							x = { 190.55,181.65,174.05,168.25,164.6,163.15,163.6,165.85,169.45,174.2,179.85,186.25,193.2,200.55,208.3,216.4,224.7,233.2,241.9,250.7,259.65,268.7,277.8,287,296.25,305.55,314.9,324.25,333.7,343.15,352.6,362.05,371.55,381.1,390.6,400.15,409.65,419.2,428.75,438.3,447.9,457.4,467,476.55,486.1,495.65,505.2,514.75,524.3,533.85,543.4,552.9,562.4,571.9,581.35,590.8,600.25,609.7,619.05,628.4,637.7,646.95,656.15,665.25,674.3,683.3,692.15,700.9,709.55,718,726.25,734.3,742.1,749.55,756.65,763.25,769.3,774.65,779.15,782.55,784.6,784.95,783.25,779.15,772.65,764.3,754.95,745.35,736.5,729.15,723.4,718.65,714.4,710.25,706.05,701.6,696.75,691.55,685.85,679.65,673.05,665.95,658.5,650.65,642.55,634.15,625.55,616.75,607.8,598.75,589.55,580.3,571,561.6,552.15,542.7,533.25,523.75,514.2,504.65,495.1,485.55,476,466.45,456.9,447.35,437.8,428.25,418.7,409.15,399.65,390.15,380.7,371.3,361.95,352.65,343.45,334.4,325.5,316.85,308.5,300.55,293.15,286.4,280.4,275.2,270.8,267.1,264,261.25,258.55,255.55,251.8,246.7,239.95,231.7,222.6,213.2,203.65 },
							y = { 378.7,375.2,369.5,361.9,353.1,343.7,334.15,324.85,316,307.7,300,292.9,286.35,280.3,274.75,269.65,264.9,260.6,256.6,252.9,249.5,246.4,243.55,240.9,238.5,236.3,234.25,232.45,230.75,229.25,227.9,226.65,225.6,224.65,223.8,223.05,222.45,221.95,221.55,221.25,221.05,220.9,220.9,220.9,221.05,221.3,221.6,222.05,222.55,223.2,223.95,224.8,225.8,226.9,228.2,229.55,231.1,232.8,234.7,236.7,238.9,241.35,243.95,246.75,249.85,253.1,256.7,260.5,264.65,269.1,273.9,279.05,284.6,290.6,297,303.9,311.3,319.2,327.65,336.6,345.9,355.45,364.85,373.45,380.35,384.85,386.7,386.05,382.65,376.65,369,360.75,352.2,343.55,334.95,326.5,318.25,310.25,302.6,295.3,288.4,282,276,270.55,265.5,260.95,256.8,253.05,249.65,246.65,243.95,241.6,239.5,237.65,236.05,234.65,233.45,232.45,231.65,231,230.5,230.15,229.95,229.9,229.9,230.05,230.35,230.8,231.35,232.15,233.05,234.2,235.6,237.25,239.2,241.45,244.05,247.1,250.65,254.7,259.35,264.7,270.7,277.45,284.85,292.9,301.35,310.2,319.25,328.4,337.55,346.65,355.4,363.5,370.2,375,377.95,379.4,379.8 },
							scale = 0.7,
						}
		local handAnimation = ui.newAnimation{
					comps = {
						handComponent,
					},
					scale = 0.5,
					speed = 0.5,
				}
		
		localGroup:insert(handAnimation.displayObject)
		handAnimation.hide()
		
		local whiteSquare = display.newImageRect("assets/pedazoDeMadera.png",width,95.5)
		whiteSquare:setReferencePoint(display.TopLeftReferencePoint)
		whiteSquare.x,whiteSquare.y=0,display.screenOriginY+display.viewableContentHeight-95
		localGroup:insert(whiteSquare)
		whiteSquare.isVisible = false
		
		local startHandAnimation
		local stopHandAnimation
		local killHandAnimation
		
		local function prepareHandAnimation()
			local alive = true
			
			local appearSheep,disappearSheep
			local function sheepToLeft()
				if paused then return end
				if not runningAnimal then Runtime:removeEventListener("enterFrame",sheepToLeft);return end
				if not runningAnimal.displayObject then Runtime:removeEventListener("enterFrame",sheepToLeft);return end
				if not runningAnimal.displayObject.isVisible then Runtime:removeEventListener("enterFrame",sheepToLeft);return end
				if runningAnimal.displayObject.x > 80 then
					if runningAnimal.displayObject.x >= 150 then
						local alp = 1-((runningAnimal.displayObject.x-150)*0.1)
						runningAnimal.displayObject.alpha=alp
					end
					runningAnimal.displayObject.x = runningAnimal.displayObject.x - 0.5
				else
					Runtime:removeEventListener("enterFrame",sheepToLeft)
				end
			end
			
			local function sheepToRight()
				if paused then return end
				if not runningAnimal then Runtime:removeEventListener("enterFrame",sheepToRight);return end
				if not runningAnimal.displayObject then Runtime:removeEventListener("enterFrame",sheepToRight);return end
				if not runningAnimal.displayObject.isVisible then Runtime:removeEventListener("enterFrame",sheepToRight);return end
				if runningAnimal.displayObject.x < 360 then
					if runningAnimal.displayObject.x > 350 then
						local alp = 1-((runningAnimal.displayObject.x-350)*0.1)
						runningAnimal.displayObject.alpha=alp
					end
					runningAnimal.displayObject.x = runningAnimal.displayObject.x + 0.5
				else
					Runtime:removeEventListener("enterFrame",sheepToRight)
					appearSheep()
				end
			end
			
			appearSheep=function()
				runningAnimal.displayObject.x = 160
				runningAnimal.displayObject.xScale = 1
				runningAnimal.displayObject.alpha = 0
				runningAnimal.isVisible = true
				Runtime:addEventListener("enterFrame",sheepToLeft)
			end
			
			disappearSheep=function()
				runningAnimal.displayObject.x = 340
				runningAnimal.displayObject.xScale = -1
				runningAnimal.displayObject.alpha = 1
				runningAnimal.isVisible = true
				Runtime:addEventListener("enterFrame",sheepToRight)
			end
			
			local function animateHand()
				if paused then return end
				if handAnimation.getActualFrame() >= 0 and handAnimation.getActualFrame() <=80 then
					caughtAnimal.displayObject.x = handComponent.displayObject.x - 20
					caughtAnimal.displayObject.y = handComponent.displayObject.y - 30
					
					if (not caughtAnimal.isMoving) and not started then
						caughtAnimal.start()
						caughtAnimal.show()
						
						runningAnimal.stop()
						runningAnimal.hide()
						
						if RBlinks then
							RBlinks.openEyes()
							RBlinks.stopBlinking()
						end
						if CBlinks then
							CBlinks.openEyes()
							CBlinks.startBlinking()
						end
					end
				else
					if caughtAnimal.isMoving and not started then
						caughtAnimal.stop()
						caughtAnimal.hide()
						
						runningAnimal.show()
						runningAnimal.start()
						
						if RBlinks then
							RBlinks.openEyes()
							RBlinks.startBlinking()
						end
						if CBlinks then
							CBlinks.openEyes()
							CBlinks.stopBlinking()
						end
						
						disappearSheep()
					end
				end
			end
			
			startHandAnimation = function ()
				if alive then
					handAnimation.start()
					Runtime:addEventListener("enterFrame",animateHand)
				end
			end
			
			stopHandAnimation = function ()
				handAnimation.stop()
				Runtime:removeEventListener("enterFrame",animateHand)
			end
			
			killHandAnimation = function ()
				alive = false
				handAnimation.kill()
				stopHandAnimation()
			end
		end
		prepareHandAnimation()
		
		local function continue()
			killHandAnimation()
			
			handAnimation = nil
			handComponent = nil
			
			runningAnimal.kill()
			runningAnimal = nil
			
			caughtAnimal.kill()
			caughtAnimal = nil
			
			openEyesR = nil
			closedEyesR = nil
			
			openEyesC = nil
			closedEyesC = nil
			
			localGroup:remove(loadingBackground)
			localGroup:remove(whiteSquare)
			
			continue=nil
			killDemoLoop=nil
		end
		killDemoLoop = function()
			startDemoLoop=nil
			vanish=nil
			continue()
		end
		
		local vanish
		
		--START BUTTON
		local startButtonAction = function ( event )
			if event.phase == "release" and not started then
				soundController.kill("directions")
				vanish()
				started = true
			end
		end
		-- UI ELEMENT
		local startButton = ui.newButton{
						default = "assets/botonAzulGigante.png",
						onEvent = startButtonAction,
						text = "Start",
						size = 112,
						font = mainFont1,
						offset = correctOffset(0),
						emboss = true,
						textColor={66,33,11,255},
						id = "bt01"}
		startButton.xScale,startButton.yScale = 0.4,0.4
		startButton.x=display.screenOriginX+startButton.contentWidth/2+20
		startButton.y=whiteSquare.y+whiteSquare.contentHeight*5/8-2
		startButton.isVisible = false
		localGroup:insert(startButton)
		
		local someInfoText = "Let’s help Mary to go to sleep by counting sheep. DRAG and DROP the sheep over to the other side of the fence."
		
		local infoDisplayObject = util.wrappedText(someInfoText, 55, 16, mainFont1, {67,34,15,255})
		infoDisplayObject.y=whiteSquare.y+whiteSquare.contentHeight*5/9-infoDisplayObject.contentHeight/2 - 0
		infoDisplayObject.x=startButton.x+startButton.contentWidth/2+20
		infoDisplayObject.isVisible=false
		localGroup:insert(infoDisplayObject)
		
		--local myTimer
		local result
		vanish = function()
			pauseIt = nil
			continueIt = nil
			
			startButton.isVisible = false
			
			transition.to(whiteSquare,{y=height, time = 550})
			transition.to(startButton,{alpha=0,y=startButton.y+whiteSquare.contentHeight,time=550})
			transition.to(infoDisplayObject,{alpha=0,y=infoDisplayObject.y+whiteSquare.contentHeight,time=550})
			
			transition.to(loadingBackground,{y=0,time = 500})
			
			runningAnimal.vanish(300)
			caughtAnimal.vanish(300)
			handAnimation.vanish(300)
			
			timer.performWithDelay(600, function()
											whiteSquare.y=height
											startButton.alpha=0
											infoDisplayObject.alpha=0
											loadingBackground.y=0
										end)
			
			timer.performWithDelay(1000, startInteraction)
			timer.performWithDelay(1500, continue)
			
			vanish=nil
		end
		
		startDemoLoop = function()
			local function killTheBug()
				loadingBackground.alpha = 1
				whiteSquare.alpha = 1
				startButton.alpha = 1
				infoDisplayObject.alpha = 1
				whiteSquare.alpha = 1
				handComponent.displayObject.alpha = 1
				killTheBug = nil
			end
			timer.performWithDelay(350,killTheBug)
			
			loadingBackground.isVisible = true
			
			loadingBackground.alpha = 0
			
			transition.to(loadingBackground,{alpha=1,time=300})
			transition.to(whiteSquare,{alpha=1,time=300})
			
			whiteSquare.isVisible = true
			whiteSquare.alpha = 0
			startButton.isVisible = true
			infoDisplayObject.isVisible = true
			startButton.alpha=0
			infoDisplayObject.alpha=0
			
			transition.to(startButton,{alpha=1,time=300})
			transition.to(infoDisplayObject,{alpha=1,time=300})
			transition.to(whiteSquare,{alpha=1,time=300})
			
			handAnimation.appear(300)
			
			startHandAnimation()
			
			pauseIt = function()
				handAnimation.stop()
				if runningAnimal.isMoving then
					runningAnimal.wasMoving = true
					runningAnimal.stop()
					RBlinks.stopBlinking()
				end
				if caughtAnimal.isMoving then
					caughtAnimal.wasMoving = true
					caughtAnimal.stop()
					CBlinks.stopBlinking()
				end
			end
			
			continueIt = function()
				handAnimation.start()
				
				if runningAnimal.wasMoving then
					runningAnimal.wasMoving = nil
					runningAnimal.start()
					RBlinks.startBlinking()
				end
				if caughtAnimal.wasMoving then
					caughtAnimal.wasMoving = nil
					caughtAnimal.start()
					CBlinks.startBlinking()
				end
			end
			
			startDemoLoop = nil
		end
	end
	prepareDemoLoop()
	
	--====================================================================--
	-- INTERACTION
	--====================================================================--
	local function prepareInteraction()
		local loadingBackground = display.newImageRect("assets/interactivity5/fenceBG.jpg",width,height)
		loadingBackground:setReferencePoint(display.TopLeftReferencePoint)
		loadingBackground.x = 0
		loadingBackground.y = 0
		localGroup:insert(loadingBackground)
		loadingBackground.isVisible = false
		
		local finished = false
		local vanish
		local kidnappedAnimalsCount = 0
		
		local isDraggingAnimal = false
		
		local lastAnimalTime = nil
		
		local addPoints
		
		local checkOrder
		
		local animalLimit = (difficultyLevel<=1 and 20) or (difficultyLevel==2 and 30) or (difficultyLevel>=3 and 40)
		local timeLimit = (difficultyLevel<=1 and 90) or (difficultyLevel==2 and 60) or (difficultyLevel>=3 and 60)
		
		local counterCircle = display.newImage("assets/contadorOvejas.png")
		counterCircle:setReferencePoint(display.CenterReferencePoint)
		counterCircle.x=display.screenOriginX+85
		counterCircle.y=display.screenOriginY+22
        counterCircle.xScale,counterCircle.yScale=0.45,0.45
		localGroup:insert(counterCircle)
		counterCircle.isVisible = false
		
        local text1 = display.newText("", 0, 0, mainFont1, retinaConditional(28,36))
        text1:setTextColor(67,34,15,255)
        text1.x = counterCircle.x - 10
        text1.y = counterCircle.y + retinaConditional(0,5)
        text1.isVisible=false
        
        local timeLeft = timeLimit
		
		local isCongratulatingPlayer = false
		local function congratulatePlayer(special)
			if not isCongratulatingPlayer then
				isCongratulatingPlayer = true
				local function completeFunction()
					timer.performWithDelay(3000,function() isCongratulatingPlayer = false; end)
				end
				if special then
					soundController.playNew{
									path = "assets/sound/voices/SonidosNarrador/wellDone.mp3",
									onComplete = completeFunction
									}
				else
					soundController.playNew{
									path = "assets/sound/voices/SonidosNarrador/great.mp3",
									onComplete = completeFunction
									}
				end
			end
		end
		
		local isCheeringUpPlayer = false
		local firstCheerUp = true
		local function cheerUpPlayer()
			if not isCheeringUpPlayer then
				isCheeringUpPlayer = true
				local function completeFunction()
					timer.performWithDelay(5000,function() isCheeringUpPlayer = false; end)
				end
				
				if firstCheerUp or math.random(2) == 1 then
					soundController.playNew{
									path = "assets/sound/voices/SonidosNarrador/catchSheep.mp3",
									onComplete = completeFunction
									}
					firstCheerUp = false
				else
					soundController.playNew{
									path = "assets/sound/voices/SonidosNarrador/comeOn.mp3",
									onComplete = completeFunction
									}
				end
			end
		end
		local function checkPlayerActivity()
			if system.getTimer() - lastAnimalTime > 3000 then
				cheerUpPlayer()
			end
		end
		
		local timerCircle = display.newImage("assets/reloj.png")
		timerCircle:setReferencePoint(display.CenterReferencePoint)
		timerCircle.x = width/2
        timerCircle.y = display.screenOriginY+25
        timerCircle.xScale,timerCircle.yScale=0.45,0.45
		localGroup:insert(timerCircle)
		timerCircle.isVisible = false
		
		local text2size = retinaConditional(28,36)
		local text2 = display.newText("", 0, 0, mainFont1, text2size)
		text2:setReferencePoint(display.CenterReferencePoint)
		--text2.size = text2size
        text2:setTextColor(107,18,22,255)
        text2.x = timerCircle.x+10
        text2.y = timerCircle.y - retinaConditional(3,-2)
        text2.text = ""..timeLeft
        text2.isVisible=false
		
		local countdownTimer = nil
		local function updateTimer()
			if finished then return end
			timeLeft = timeLeft-1
			text2.text = ""..timeLeft
			checkPlayerActivity()
			if timeLeft<=0 then
				if gameOver then gameOver() end
			else
				if timeLeft==5 or timeLeft==13 then
					soundController.playNew{
									path = "assets/sound/voices/SonidosNarrador/hurryUp.mp3",
									}
				end
				if timeLeft<=5 then
					text2:setTextColor(220,55,44,255)
					--text2.size = text2size*1.5
					text2.xScale = 1.25
					text2.yScale = 1.25
				elseif timeLeft<=13 then
					if math.fmod(timeLeft,2) == 1 then
						text2:setTextColor(190,49,40,255)
					else
						text2:setTextColor(107,18,22,255)
					end
					--text2.size = text2size*1.25
					text2.xScale = 1.125
					text2.yScale = 1.125
				end
				countdownTimer = timer.performWithDelay(1000, updateTimer)
			end
		end
		
		local function showPoints()
			text1.text = ""..kidnappedAnimalsCount.."/"..animalLimit
			text1.x = counterCircle.x - 10
	        text1.y = counterCircle.y + retinaConditional(0,5)
		end
		showPoints()
		
		local treeDistanceScale = 1.35
		local function newAnimal (yPos, xMin, xMax, scale, number)
			local thisAnimal = {}
			local canDrag = true
			local isDragging = false
			
			local positivePoints = 1
			local negativePoints = 0
			
			local distanceScale = 1
			
			local movementDirection = 1
			
			local dat1
			
			local caughtSound
			local dropSound = audio.loadSound("assets/sound/drop.mp3")
			local animalSoundChannel = nil
			
			local loops = 0
			local lastFrame = 0
			
			local minX = xMin
			local maxX = xMax
			
			thisAnimal.isAlive = true
			
			if not yPos then
				yPos = 0
			end
			
			if not scale then
				scale = 1
			end
			
			thisAnimal.displayObject = display.newGroup()
			thisAnimal.displayObject.x = math.random(minX,maxX)
			thisAnimal.displayObject.y = yPos
			
			local openEyesR = display.newImage("assets/sheep/EyesOpen.png")
			local closedEyesR = display.newImage("assets/sheep/EyesClosed.png")
			
			local openEyesC = display.newImage("assets/sheepCaught/EyesOpen.png")
			local closedEyesC = display.newImage("assets/sheepCaught/EyesClosed.png")
			
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
					scale = scale*0.75*1.666,
					speed = 0.5
				}
			thisAnimal.caughtAnimal = ui.newAnimation{
					comps = {
						{
							--Body
							path = "assets/sheepCaught/body.png",
							x = { 260.95,260.95,260.95,260.95,260.95,260.95,260.95,260.95,260.95,260.95 },
							y = { 244.85,241.85,238.85,235.85,232.9,235.85,238.85,241.85,244.85,247.85 },
							rotation = { 0,0,0,0,0,0,0,0,0,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--Head
							path = "assets/sheepCaught/head.png",
							x = { 255,255.2,255.35,255.55,255.7,255.55,255.35,255.2,255,254.85 },
							y = { 118.15,115.05,111.95,108.85,105.75,108.85,111.95,115.05,118.15,121.3 },
							rotation = { 1.506011962890625,3.011688232421875,4.5175628662109375,6.02325439453125,7.52923583984375,6.02325439453125,4.5175628662109375,3.011688232421875,1.506011962890625,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							displayObject = closedEyesC,
							scaleComponent = true,
							x = { 255,255.2,255.35,255.55,255.7,255.55,255.35,255.2,255,254.85 },
							y = { 118.15,115.05,111.95,108.85,105.75,108.85,111.95,115.05,118.15,121.3 },
							rotation = { 1.506011962890625,3.011688232421875,4.5175628662109375,6.02325439453125,7.52923583984375,6.02325439453125,4.5175628662109375,3.011688232421875,1.506011962890625,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							displayObject = openEyesC,
							scaleComponent = true,
							x = { 255,255.2,255.35,255.55,255.7,255.55,255.35,255.2,255,254.85 },
							y = { 118.15,115.05,111.95,108.85,105.75,108.85,111.95,115.05,118.15,121.3 },
							rotation = { 1.506011962890625,3.011688232421875,4.5175628662109375,6.02325439453125,7.52923583984375,6.02325439453125,4.5175628662109375,3.011688232421875,1.506011962890625,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--LArm
							path = "assets/sheepCaught/larm.png",
							x = { 329.5,330.5,331.4,332.3,333.35,332.3,331.4,330.5,329.5,329.05 },
							y = { 239.75,236.35,233.05,229.7,226.35,229.7,233.05,236.35,239.75,242.8 },
							rotation = { 13.017288208007813,11.787277221679688,10.556304931640625,9.324752807617188,8.093017578125,9.324752807617188,10.556304931640625,11.787277221679688,13.017288208007813,14.25408935546875 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--RLeg
							path = "assets/sheepCaught/rleg.png",
							x = { 228.9,229.85,230.85,231.8,232.75,231.8,230.85,229.85,228.9,227.95 },
							y = { 394.95,391.9,388.85,385.75,382.65,385.75,388.85,391.9,394.95,398 },
							rotation = { -1.3513641357421875,-2.702972412109375,-4.0550537109375,-5.406951904296875,-6.758026123046875,-5.406951904296875,-4.0550537109375,-2.702972412109375,-1.3513641357421875,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--RArm
							path = "assets/sheepCaught/rarm.png",
							x = { 206.9,206.2,205.5,204.8,204.1,204.8,205.5,206.2,206.9,207.65 },
							y = { 237.55,234.5,231.4,228.3,225.2,228.3,231.4,234.5,237.55,240.65 },
							rotation = { 1.1092987060546875,2.2186431884765625,3.328948974609375,4.4376068115234375,5.54815673828125,4.4376068115234375,3.328948974609375,2.2186431884765625,1.1092987060546875,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--LLeg
							path = "assets/sheepCaught/lleg.png",
							x = { 310.15,309.05,307.95,306.85,305.75,306.85,307.95,309.05,310.15,311.3 },
							y = { 390.75,387.75,384.75,381.75,378.65,381.75,384.75,387.75,390.75,393.7 },
							rotation = { 1.59075927734375,3.1808013916015625,4.7711639404296875,6.361968994140625,7.952423095703125,6.361968994140625,4.7711639404296875,3.1808013916015625,1.59075927734375,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},
					},
					x = -150*scale,
					scale = scale * 1.666,
					speed = 0.5
				}
			
			local RBlinks = ui.blink(openEyesR,closedEyesR)
			local CBlinks = ui.blink(openEyesC,closedEyesC)
			
			thisAnimal.runningAnimal.hide()
			thisAnimal.caughtAnimal.hide()
			
			caughtSound  = nil
			
			localGroup:insert(thisAnimal.displayObject)
			thisAnimal.addRunningAnimalLayer = function()
				if thisAnimal.runningAnimal.displayObject then
					thisAnimal.displayObject:insert(thisAnimal.runningAnimal.displayObject)
					thisAnimal.displayObject:setReferencePoint(display.TopCenterReferencePoint)
				end
			end
			thisAnimal.addCaughtAnimalLayer = function()
				if thisAnimal.caughtAnimal.displayObject then
					localGroup:insert(thisAnimal.caughtAnimal.displayObject)
				end
			end
			
			local move
			local defineAnimation
			
			move = function()
				if paused then return end
				if thisAnimal.runningAnimal.isMoving then
					if not isDragging then
						local thisFrame = thisAnimal.runningAnimal.getActualFrame()
						if (thisFrame < lastFrame) then
							loops = loops + 1
							if loops > 3 then
								loops = 0
								thisAnimal.runningAnimal.stop()
								Runtime:removeEventListener( "enterFrame", move )
								if thisAnimal.displayObject.x > width-100 then
									thisAnimal.runningAnimal.vanish(500)
								end
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
			
			thisAnimal.pauseAnimal = function()
				if dat1 then
					timer.pause(dat1)
				end
				if thisAnimal.caughtAnimal.isMoving then
					thisAnimal.caughtAnimal.wasMoving = true
					thisAnimal.caughtAnimal.stop()
					CBlinks.stopBlinking()
				elseif thisAnimal.runningAnimal.isMoving or (not isDragging) then
					if thisAnimal.runningAnimal.isMoving then
						thisAnimal.runningAnimal.wasMoving = true
						thisAnimal.runningAnimal.stop()
					end
					RBlinks.stopBlinking()
				end
				animalPaused=true
			end
			
			thisAnimal.resumeAnimal = function()
				if dat1 then
					timer.resume(dat1)
				end
				if thisAnimal.caughtAnimal.wasMoving then
					thisAnimal.caughtAnimal.wasMoving = nil
					thisAnimal.caughtAnimal.start()
					CBlinks.startBlinking()
				elseif thisAnimal.runningAnimal.wasMoving or (not isDragging) then
					if thisAnimal.runningAnimal.wasMoving then
						thisAnimal.runningAnimal.wasMoving = nil
						thisAnimal.runningAnimal.start()
					end
					RBlinks.startBlinking()
				end
				animalPaused=nil
			end
			
			defineAnimation = function()
				if not thisAnimal then
					return
				end
				if not thisAnimal.displayObject or not thisAnimal.isAlive then
					return
				end
				
				if paused then
					dat1 = timer.performWithDelay(2000, defineAnimation)
					return
				end
				
				if thisAnimal.displayObject.x < xMax + 100 then
					if thisAnimal.displayObject.x > xMax then
						thisAnimal.displayObject.x = xMax
					end
					thisAnimal.displayObject.y = yPos
				end
				
				distanceScale = (thisAnimal.displayObject.y / (height/2))^(1.5)
				if distanceScale == 0 then
					distanceScale = 1
				end
				if not isDragging then
					if thisAnimal.displayObject.x < xMax + 100 then
						canDrag = true
					else
						if canDrag then
							if thisAnimal.displayObject.x < 330 then
								thisAnimal.displayObject.x = 330
							end
							addPoints(positivePoints,(distanceScale >= treeDistanceScale))
							canDrag = false
						end
					end
					
					local direction = 1
					if canDrag then
						local thisX = thisAnimal.displayObject.x + (distanceScale * direction)*100*scale
						if thisX<minX or thisX>maxX then
							direction = direction*-1
						end
						if thisAnimal.displayObject.x<minX then
							direction = 1
						end
						if thisAnimal.displayObject.x>maxX then
							direction = -1
						end
					end
					thisAnimal.displayObject.xScale = distanceScale * -direction
					thisAnimal.displayObject.yScale = distanceScale
					
					if (math.random(4) > 1 and (not thisAnimal.runningAnimal.isMoving)) or (not canDrag  and (not thisAnimal.runningAnimal.isMoving)) then
						if math.random(20) > 10 and canDrag then
							direction = -1
						end
						if thisAnimal.displayObject.x > width-50 then
							thisAnimal.displayObject.x = math.random(minX,maxX)
							thisAnimal.runningAnimal.appear(500)
							defineAnimation()
							return
						end
						thisAnimal.runningAnimal.start()
						Runtime:addEventListener("enterFrame",move)
					end
					dat1 = timer.performWithDelay(2000, defineAnimation)
				end
				
				if checkOrder then
					checkOrder()
				end
				if showPoints then
					showPoints()
				end
			end
			
			thisAnimal.startRunning = function()
				defineAnimation()
				
				thisAnimal.caughtAnimal.stop()
				thisAnimal.runningAnimal.stop()
				
				thisAnimal.runningAnimal.stop()
				thisAnimal.runningAnimal.appear()
				thisAnimal.caughtAnimal.hide()
				
				if RBlinks then
					RBlinks.openEyes()
					RBlinks.startBlinking()
				end
				if CBlinks then
					CBlinks.openEyes()
					CBlinks.stopBlinking()
				end
				
				thisAnimal.isRunning = true
			end
			
			thisAnimal.kill = function()
				Runtime:removeEventListener( "enterFrame", move )
				
				if thisAnimal.runningAnimal then
					thisAnimal.runningAnimal.kill()
				end
				if thisAnimal.caughtAnimal then
					thisAnimal.caughtAnimal.kill()
				end
				
				if thisAnimal.displayObject then
					if thisAnimal.displayObject.parent then
						thisAnimal.displayObject.parent: remove(thisAnimal.displayObject)
					end
				end
				
				thisAnimal.isAlive = false
				thisAnimal = nil
			end
			
			thisAnimal.vanish = function(time)
				thisAnimal.runningAnimal.vanish(time)
				thisAnimal.caughtAnimal.vanish(time)
			end
			
			thisAnimal.getDistanceScale = function()
				return distanceScale
			end
			
			local function touchScreen (event)
				event = correctTouch(event)
				lastAnimalTime = system.getTimer()
				if event.phase == "moved" then
					if thisAnimal.displayObject.markX and thisAnimal.displayObject.markY then
					local x = (event.x - event.xStart) + thisAnimal.displayObject.markX
					local y = (event.y - event.yStart) + thisAnimal.displayObject.markY
					thisAnimal.displayObject.x, thisAnimal.displayObject.y = x, y    -- move object based on calculations above
					thisAnimal.caughtAnimal.displayObject.x, thisAnimal.caughtAnimal.displayObject.y = x-100*scale, y
				end
				elseif event.phase == "ended" then
					Runtime:removeEventListener( "touch", touchScreen )
					if animalSoundChannel then
						if animalSoundChannel>4 then
							audio.stop(animalSoundChannel)
						end
					end
					
					thisAnimal.caughtAnimal.hide()
					thisAnimal.caughtAnimal.stop()
					thisAnimal.runningAnimal.show()
					thisAnimal.runningAnimal.stop()
					
					if RBlinks then
						RBlinks.openEyes()
						RBlinks.startBlinking()
					end
					if CBlinks then
						CBlinks.openEyes()
						CBlinks.stopBlinking()
					end
					
					isDragging = false
					isDraggingAnimal = false
					
					if thisAnimal.displayObject.markX and thisAnimal.displayObject.markY then
					local x = (event.x - event.xStart) + thisAnimal.displayObject.markX
					local y = (event.y - event.yStart) + thisAnimal.displayObject.markY
					thisAnimal.displayObject.x, thisAnimal.displayObject.y = x, y    -- move object based on calculations above
					thisAnimal.caughtAnimal.displayObject.x, thisAnimal.caughtAnimal.displayObject.y = x-100*scale, y
					end
					
					if thisAnimal.displayObject.y < 120 then
						thisAnimal.displayObject.y = 120
					end
					
					thisAnimal.displayObject.markX = nil
					thisAnimal.displayObject.markY = nil
					
					if animalSoundChannel then
						if animalSoundChannel>4 then
							audio.stop(animalSoundChannel)
						end
					end
					animalSoundChannel = audio.play(dropSound,{loops=0})
					
					loops = 0
					Runtime:removeEventListener( "enterFrame", move )
					defineAnimation ()
				end
			end
			
			local function touchAnimal (event)
				event = correctTouch(event)
				if event.phase == "began" then
					if not canDrag then
						return
					end
					
					if isDraggingAnimal then
						return
					end
					isDraggingAnimal = true
					
					if animalSoundChannel then
						if animalSoundChannel>4 then
							audio.stop(animalSoundChannel)
						end
					end
					animalSoundChannel = audio.play(caughtSound,{loops=-1})
					
					Runtime:addEventListener( "touch", touchScreen )
					
					thisAnimal.displayObject.markX = thisAnimal.displayObject.x    -- store x location of object
					thisAnimal.displayObject.markY = thisAnimal.displayObject.y    -- store y location of object
					
					thisAnimal.caughtAnimal.show()
					thisAnimal.caughtAnimal.start()
					thisAnimal.runningAnimal.hide()
					thisAnimal.runningAnimal.stop()
					
					if RBlinks then
						RBlinks.openEyes()
						RBlinks.stopBlinking()
					end
					if CBlinks then
						CBlinks.openEyes()
						CBlinks.startBlinking()
					end
					
					loops = 0
					Runtime:removeEventListener( "enterFrame", move )
					
					thisAnimal.caughtAnimal.displayObject.x, thisAnimal.caughtAnimal.displayObject.y = thisAnimal.displayObject.x-100*scale, thisAnimal.displayObject.y
					
					isDragging = true
				end
			end
			
			thisAnimal.displayObject:addEventListener( "touch", touchAnimal )
			
			return thisAnimal
		end
		
		local animal1 = newAnimal(115,100,275,0.3,1)
		local animal2 = newAnimal(130,100,240,0.3,2)
		local animal3 = newAnimal(145,100,205,0.3,3)
		local animal4 = newAnimal(160,100,175,0.3,4)
		local animal5 = newAnimal(175,100,150,0.3,5)
		local animal6 = newAnimal(190,100,130,0.3,6)
		
		animal1.addRunningAnimalLayer()
		animal2.addRunningAnimalLayer()
		animal3.addRunningAnimalLayer()
		animal4.addRunningAnimalLayer()
		animal5.addRunningAnimalLayer()
		animal6.addRunningAnimalLayer()
		
		local fence = display.newImageRect("assets/interactivity5/fence.png",width,height)
		fence:setReferencePoint(display.TopLeftReferencePoint)
		fence.x = 0
		fence.y = 0
		localGroup:insert(fence)
		fence.isVisible = false
		
		local tree = display.newImageRect("assets/interactivity5/bigTree1.png",width,height)
		tree:setReferencePoint(display.TopLeftReferencePoint)
		tree.x = 0
		tree.y = 0
		localGroup:insert(tree)
		tree.isVisible = false
		
		animal1.addCaughtAnimalLayer()
		animal2.addCaughtAnimalLayer()
		animal3.addCaughtAnimalLayer()
		animal4.addCaughtAnimalLayer()
		animal5.addCaughtAnimalLayer()
		animal6.addCaughtAnimalLayer()
		
		localGroup:insert(counterCircle)
		localGroup:insert(text1)
		
		localGroup:insert(timerCircle)
		localGroup:insert(text2)
		
		checkOrder = function()
			if finished then return end
			
			local disordered = {animal1,animal2,animal3,animal4,animal5,animal6}
			
			local lower = 1000
			
			local treeInserted = false
			
			for i=1 , #disordered do
				if disordered[i].getDistanceScale() < lower then
					lower = disordered[i].getDistanceScale()
				end
			end
			
			local lowerChanged = true
			while lowerChanged do
				lowerChanged = false
				for i=1 , #disordered do
					if disordered[i].getDistanceScale() == lower then
						if lower >= treeDistanceScale and not treeInserted then
							treeInserted = true
							localGroup:insert(tree)
						end
						localGroup:insert(disordered[i].displayObject)
					end
				end
				
				local newLower = 1000
				for i=1 , #disordered do
					if disordered[i].getDistanceScale() < newLower and disordered[i].getDistanceScale() > lower then
						newLower = disordered[i].getDistanceScale()
					end
				end
				if not (newLower == 1000) then
					lower = newLower
					lowerChanged = true
				end
			end
			
			if not treeInserted then
				treeInserted = true
				localGroup:insert(tree)
			end
			localGroup:insert(fence)
			
			animal1.addCaughtAnimalLayer()
			animal2.addCaughtAnimalLayer()
			animal3.addCaughtAnimalLayer()
			animal4.addCaughtAnimalLayer()
			animal5.addCaughtAnimalLayer()
			animal6.addCaughtAnimalLayer()
			
			localGroup:insert(counterCircle)
			localGroup:insert(text1)
			
			localGroup:insert(timerCircle)
			localGroup:insert(text2)
			
			screenMessages.sendToFront()
			overlay:toFront()
		end
		
		addPoints = function(positivePoints, inFrontOfTree)
			if inFrontOfTree then
				addExtras(difficultyLevel*0.75,width*3/4,height/2)
			else
				addExtras(difficultyLevel*0.25,width*3/4,height/2)
			end
			kidnappedAnimalsCount = kidnappedAnimalsCount + positivePoints
			
			if math.floor(animalLimit/3) == kidnappedAnimalsCount then
				congratulatePlayer()
			elseif math.floor(animalLimit*2/3) == kidnappedAnimalsCount then
				congratulatePlayer()
			end
			
			if kidnappedAnimalsCount >= animalLimit then
				if not finished then
					vanish()
				end
				finished = true
				
				unlockAchievement("com.tapmediagroup.MaryTheFairy.EndDay","End of a long day","End of a long day")
			end
		end
		
		local function continue()
			localGroup:remove(loadingBackground)
			localGroup:remove(fence)
			localGroup:remove(tree)
			
			localGroup:remove(counterCircle)
			localGroup:remove(text1)
			
			localGroup:remove(timerCircle)
			localGroup:remove(text2)
			
			animal1.kill()
			animal2.kill()
			animal3.kill()
			animal4.kill()
			animal5.kill()
			animal6.kill()
			
			animal1=nil
			animal2=nil
			animal3=nil
			animal4=nil
			animal5=nil
			animal6=nil
			
			if countdownTimer then
				timer.cancel(countdownTimer)
			end
			
			continue = nil
			killInteraction = nil
		end
		killInteraction = function()
			startInteraction=nil
			vanish=nil
			continue()
		end
		
		vanish = function ()
			finishTime = system.getTimer()
			
			soundController.kill("sheep")
			
			pauseIt = nil
			continueIt=nil
			
			if countdownTimer then
				timer.cancel(countdownTimer)
			end
			
			startMarySleeping()
			timer.performWithDelay(300, continue)
			
			vanish = nil
		end
		
		startInteraction = function()
			soundController.playNew{
						path = "assets/sound/effects/cap5/sheep.mp3",
						identifier = "sheep",
						pausable = false,
						--staticChannel = 2,
						loops = -1,
						actionTimes = nil,
						action =	nil,
						onComplete = nil
						}
			
			startTime = system.getTimer()
			lastAnimalTime = startTime
			local aat1 = timer.performWithDelay(1300, animal1.startRunning)
			local aat2 = timer.performWithDelay(3000, animal2.startRunning)
			local aat3 = timer.performWithDelay(4000, animal3.startRunning)
			local aat4 = timer.performWithDelay(7600, animal4.startRunning)
			local aat5 = timer.performWithDelay(6000, animal5.startRunning)
			local aat6 = timer.performWithDelay(5500, animal6.startRunning)
			
			loadingBackground.isVisible = true
			fence.isVisible = true
			tree.isVisible = true
			
			counterCircle.alpha = 0
			counterCircle.isVisible = true
			transition.to(counterCircle,{alpha = 1,time = 300})
			
			text1.alpha = 0
			text1.isVisible = true
			transition.to(text1,{alpha = 1,time = 300})
			
			if timeLimit>0 then
				timerCircle.alpha = 0
				timerCircle.isVisible = true
				transition.to(timerCircle,{alpha = 1,time = 300})
				
				text2.alpha = 0
				text2.isVisible = true
				transition.to(text2,{alpha = 1,time = 300})
				
				timer.performWithDelay(1000, updateTimer)
			end
			
			timer.performWithDelay( 300,
									function()
										counterCircle.alpha=1
										text1.alpha=1
										if timeLimit>0 then
											timerCircle.alpha=1
											text2.alpha=1
										end
									end)
			
			local pausedTime = 0
			pauseIt = function()
				pausedTime = system.getTimer()
				if countdownTimer then
					timer.pause(countdownTimer)
				end
				if aat1 then timer.pause(aat1) end
				if aat2 then timer.pause(aat2) end
				if aat3 then timer.pause(aat3) end
				if aat4 then timer.pause(aat4) end
				if aat5 then timer.pause(aat5) end
				if aat6 then timer.pause(aat6) end
				animal1.pauseAnimal()
				animal2.pauseAnimal()
				animal3.pauseAnimal()
				animal4.pauseAnimal()
				animal5.pauseAnimal()
				animal6.pauseAnimal()
			end
			
			continueIt = function()
				if pausedTime ~= 0 then
					startTime = startTime + (system.getTimer() - pausedTime)
				end
				pausedTime = 0
				if countdownTimer then
					timer.resume(countdownTimer)
				end
				if aat1 then timer.resume(aat1) end
				if aat2 then timer.resume(aat2) end
				if aat3 then timer.resume(aat3) end
				if aat4 then timer.resume(aat4) end
				if aat5 then timer.resume(aat5) end
				if aat6 then timer.resume(aat6) end
				animal1.resumeAnimal()
				animal2.resumeAnimal()
				animal3.resumeAnimal()
				animal4.resumeAnimal()
				animal5.resumeAnimal()
				animal6.resumeAnimal()
			end
			
			pauseIt()
			continueIt()
			
			startInteraction = nil
		end
	end
	prepareInteraction()
	
	--======================================
	-- MARY SLEEPING
	--======================================
	local function prepareMarySleeping()
		
		-- SUBTITLE FRAME
		local subtitleGroup = display.newGroup()
		local subtitleFrame = display.newImageRect("assets/pedazoDeMadera.png",width,95.5)
		subtitleFrame:setReferencePoint(display.TopLeftReferencePoint)
		subtitleFrame.x,subtitleFrame.y=0,display.screenOriginY+display.viewableContentHeight-95
		subtitleFrame:setReferencePoint(display.CenterReferencePoint)
		subtitleGroup:insert(subtitleFrame)
		
		local subtitleArray = getTextArrayFromFile("assets/c1f.txt",system.ResourceDirectory)
		local times = { 3490, 2480, 7470, 4700 }
		
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
		
		local sleepingGroup = display.newGroup()
		sleepingGroup.isVisible = false
		localGroup:insert(sleepingGroup)
		
		local loadingBackground = display.newImageRect("assets/sleeping/faceless.jpg",width,height)
		loadingBackground:setReferencePoint(display.TopLeftReferencePoint)
		loadingBackground.x = 0
		loadingBackground.y = 0
		sleepingGroup:insert(loadingBackground)
		loadingBackground.isVisible = false
		
		local statesGroup = display.newGroup()
		local s1 = display.newImageRect("assets/sleeping/1.png",width,height)
		s1:setReferencePoint(display.TopLeftReferencePoint)
		s1.x = 0
		s1.y = 0
		local s2 = display.newImageRect("assets/sleeping/2.png",width,height)
		s2:setReferencePoint(display.TopLeftReferencePoint)
		s2.x = 0
		s2.y = 0
		local maryBlinks = ui.blink(s1,s2,1)
		
		statesGroup:insert(s1)
		statesGroup:insert(s2)
		
		sleepingGroup:insert(statesGroup)
		
		local maryAnimation = ui.newAnimation{
						comps = {
						 {
						  displayObject = display.newText( "z", 0, 0, "Curse Casual JVE", 36 ),
						  x = { 194.85,191.4,187.95,184.45,182.3,180.15,177.95,175.8,173.65,171.45,169.3,167.15,164.95,162.8,160.65,158.45,156.3,154.15,151.95,154.35,156.75,159.15,161.55,163.9,166.3,168.7,171.1,173.5,175.85,178.25,180.65,183.05,185.45,187.8,190.2,192.6,195,197.4,199.75,197.65,195.55,193.45,191.35,189.25,187.15,185.05,182.95,180.85,178.75,176.65,174.55,172.45,170.35,168.25,166.15,164.05,161.95,159.85,157.7 },
						  y = { 196.8,193.45,190.1,186.75,184.6,182.4,180.2,178.05,175.85,173.65,171.5,169.3,167.1,164.95,162.75,160.55,158.4,156.2,154,152.1,150.2,148.3,146.4,144.5,142.6,140.7,138.8,136.9,134.95,133.05,131.15,129.25,127.35,125.45,123.55,121.65,119.75,117.85,115.9,114.7,113.5,112.3,111.1,109.9,108.7,107.5,106.3,105.1,103.9,102.7,101.5,100.3,99.1,97.9,96.7,95.5,94.35,93.1,91.9 },
						  alpha = { 0.25,0.5,0.75,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0.94921875,0.8984375,0.8515625,0.80078125,0.75,0.69140625,0.6484375,0.58984375,0.5390625,0.48828125,0.44140625,0.390625,0.33984375,0.2890625,0.23828125,0.19140625,0.140625,0.08984375,0.0390625,0 },
						 }
						},
						 x = 0,
						 y = 0,
						 scale = 1/2,
						 speed = 0.5
						}
		maryAnimation.hide()
		sleepingGroup:insert(maryAnimation.displayObject)
		
		local maryAnimation2 = ui.newAnimation{
						comps = {
						 {
						  displayObject = display.newText( "z", 0, 0, "Curse Casual JVE", 48 ),
						  x = { 194.85,191.4,187.95,184.45,182.3,180.15,177.95,175.8,173.65,171.45,169.3,167.15,164.95,162.8,160.65,158.45,156.3,154.15,151.95,154.35,156.75,159.15,161.55,163.9,166.3,168.7,171.1,173.5,175.85,178.25,180.65,183.05,185.45,187.8,190.2,192.6,195,197.4,199.75,197.65,195.55,193.45,191.35,189.25,187.15,185.05,182.95,180.85,178.75,176.65,174.55,172.45,170.35,168.25,166.15,164.05,161.95,159.85,157.7 },
						  y = { 196.8,193.45,190.1,186.75,184.6,182.4,180.2,178.05,175.85,173.65,171.5,169.3,167.1,164.95,162.75,160.55,158.4,156.2,154,152.1,150.2,148.3,146.4,144.5,142.6,140.7,138.8,136.9,134.95,133.05,131.15,129.25,127.35,125.45,123.55,121.65,119.75,117.85,115.9,114.7,113.5,112.3,111.1,109.9,108.7,107.5,106.3,105.1,103.9,102.7,101.5,100.3,99.1,97.9,96.7,95.5,94.35,93.1,91.9 },
						  alpha = { 0.25,0.5,0.75,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0.94921875,0.8984375,0.8515625,0.80078125,0.75,0.69140625,0.6484375,0.58984375,0.5390625,0.48828125,0.44140625,0.390625,0.33984375,0.2890625,0.23828125,0.19140625,0.140625,0.08984375,0.0390625,0 },
						 }
						},
						 x = 0,
						 y = 0,
						 scale = 1/2,
						 speed = 0.5
						}
		maryAnimation2.hide()
		sleepingGroup:insert(maryAnimation2.displayObject)
		
		sleepingGroup:insert(subtitleGroup)
		
		local function continue()
			if sleepingGroup then
				maryAnimation.kill()
				maryAnimation2.kill()
				sleepingGroup:remove(loadingBackground)
				sleepingGroup:remove(statesGroup)
				sleepingGroup:removeSelf()
			end
			continue=nil
		end
		
		local function vanish()
			soundController.kill("mary")
			soundController.kill("cricket")
			timer.performWithDelay(300, continue)
		end
		
		startMarySleeping = function()
			
			soundController.kill("bgsound")
			
			soundController.playNew{
						path = "assets/sound/voices/cap5/int5_MaryZZZ.mp3",
						--duration = 9000,
						identifier = "mary",
						loops = -1,
						staticChannel = 5,
						actionTimes = {0},
						action =	function()
									end,
						onComplete = function()
									end
						}
			
			soundController.playNew{
						path = "assets/sound/effects/cap5/cricketsound.mp3",
						identifier = "cricket",
						pausable = false,
						staticChannel = 3,
						loops = -1,
						actionTimes = nil,
						action =	nil,
						onComplete = nil
						}
			
			soundController.playNew{
						path = "assets/sound/voices/outro/NarratorsOutro.mp3",
						duration = 6000,
						actionTimes = {0,3500},
						action =	function()
										if nextSubtitle then
											if type(nextSubtitle) == "function" then
												nextSubtitle()
											end
										end
									end,
						onComplete = function()
										startTheParty()
										timer.performWithDelay(1500, vanish)
									end
						}
			
			localGroup:insert(sleepingGroup)
			sleepingGroup.isVisible = true
			maryAnimation.start()
			maryAnimation.appear(300)
			
			timer.performWithDelay(700, maryAnimation2.start)
			timer.performWithDelay(700, function() maryAnimation2.appear(300) end)
			
			--timer.performWithDelay(4500, startTheParty)
			--timer.performWithDelay(6000, vanish)
			
			loadingBackground.isVisible = true
			loadingBackground.alpha = 0
			transition.to(loadingBackground,{alpha=1,time=300})
			
			statesGroup.isVisible = true
			statesGroup.alpha = 0
			transition.to(statesGroup,{alpha=1,time=300})
			maryBlinks.openEyes()
			maryBlinks.startBlinking()
			
			subtitleGroup.isVisible = true
			subtitleGroup.alpha = 0
			transition.to(subtitleGroup,{alpha=1,time=300})
			
		end
	end
	prepareMarySleeping()
	
	--======================================
	-- PARTY
	--======================================
	local function prepareTheParty()
		local partyGroup = display.newGroup()
		localGroup:insert(partyGroup)
		
		local loadingBackground = display.newImageRect("assets/world/fairiesTownNight.jpg",width,height)
		loadingBackground:setReferencePoint(display.TopLeftReferencePoint)
		loadingBackground.x = 0
		loadingBackground.y = 0
		partyGroup:insert(loadingBackground)
		loadingBackground.isVisible = false
		
		local gPS = require( "gPS" )
		local rdm = math.random
		
		local mGroup = display.newGroup()
		local fGroup = display.newGroup()
		partyGroup:insert(mGroup)
		partyGroup:insert(fGroup)
		
		local colors = {
						{193,39,45},
						{140,198,63},
						{63,255,63},
						{140,214,234},
						}
		
		local fireIt, explodeIt
		
		---------------------------------------------------------------------------------------------------------
		function fireIt()
			local star1 = { imgStart = { life = rdm(800,1000), alpha = 1, size = {1,1}, stroke={}, pos = {((display.viewableContentWidth-display.screenOriginX)*0.35)+display.screenOriginX+rdm(-50,50),height/2+rdm(-50,50),rdm(-70,70),height},color={0,0,0,255}},
							imgEnd = { onComplete = explodeIt, alpha = 1, scale ={1,1},pos={0,0,0,0,move = 1, ease = easing.outQuad}},
							imgInfo = { group = fGroup, max = 5}}
			gPS.newCircle(star1)
		end
		
		
		---------------------------------------------------------------------------------------------------------
		function explodeIt(params)
			local radius = (rdm()*3+7)*10
			local life = rdm(1000,1200)
			local colorIndex=rdm(1,#colors)
			for a = 1, 50 do
				local angle = rdm()*3.1416*2
				local radiusVariation=(rdm()*2+9)*0.1
				local onComplete
				if a==1 then
					--onComplete = fireIt
				end
				local thisLife = life*(rdm()*6+7)*0.1
				local star2 = { imgStart = { life = thisLife, alpha = 1, size = {2,2},stroke={0,0,0,0}, pos = {params.pos[1],params.pos[2],0,0},color=colors[colorIndex]},
								imgEnd = { onComplete = onComplete, alpha = 0.8, scale ={1.2,1.2},pos={math.cos(angle)*radius*radiusVariation*thisLife/life,math.sin(angle)*radius*radiusVariation*thisLife/life,0,0,move = 1, ease = easing.outQuad}},
								imgInfo = { group = mGroup, max = 150}}
				gPS.newCircle(star2)	
			end
		end
		
		local maryWings = display.newImage("assets/mary/wings.png")
		maryWings.x,maryWings.y,maryWings.xScale,maryWings.yScale = 525.75/2.5 +142 ,776.30/2.5 -60 ,(1/2.5)*0.5 ,(1/2.5)*0.5
		
		local maryBodyAndNeck = display.newImage("assets/mary/greetingAnimation/Body.png")
		maryBodyAndNeck.x,maryBodyAndNeck.y,maryBodyAndNeck.xScale,maryBodyAndNeck.yScale = 525.75/2.5 +150 ,776.30/2.5 -6 ,1/2.5 ,1/2.5
		
		local maryBody = display.newImage("assets/mary/greetingAnimation/Body_noNeck.png")
		maryBody.x,maryBody.y,maryBody.xScale,maryBody.yScale = 525.75/2.5 +150 ,776.30/2.5 -6 ,1/2.5 ,1/2.5
		
		local maryOpenEyes = display.newImage("assets/mary/greetingAnimation/eyesOpen.png")
		local maryClosedEyes = display.newImage("assets/mary/greetingAnimation/eyesClosed.png")
		
		local maryBlinks = ui.blink(maryOpenEyes,maryClosedEyes)
		
		local maryAnimation = ui.newAnimation{
						 comps = {
						 {
						  path = "assets/mary/greetingAnimation/Head.png",
						  x = { 491.25,492.7,494.15,495.45,496.9,498.3,499.7,501.15,502.6,501.3,500.05,498.7,497.45,496.2,494.95,493.7,492.35,491.15,489.9 },
						  y = { 455.3,455.2,455.05,454.95,454.8,454.75,454.65,454.65,454.55,454.65,454.7,454.75,454.75,454.9,454.95,455.05,455.2,455.4,455.55 },
						  rotation = { 0.6023406982421875,1.204559326171875,1.808258056640625,2.4115447998046875,3.0142974853515625,3.6172637939453125,4.21942138671875,4.8223876953125,5.4251556396484375,4.883148193359375,4.34027099609375,3.7974853515625,3.2548828125,2.712554931640625,2.1697540283203125,1.62744140625,1.0848388671875,0.542022705078125,0 },
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
						  yOffset = 32,
						  xOffset = 2
						 },
						 {
						  path = "assets/mary/greetingAnimation/RightArm.png",
						  x = { 442.15,442.15,442.15,442.2,442.2,442.25,442.3,442.3,442.4,442.35,442.3,442.25,442.2,442.2,442.15,442.15,442.15,442.15,442.15 },
						  y = { 632.3,631.85,631.35,630.9,630.45,629.95,629.5,629.05,628.6,629,629.4,629.85,630.25,630.65,631.1,631.5,631.95,632.35,632.8 },
						  rotation = { 0.731719970703125,1.464080810546875,2.195953369140625,2.9271087646484375,3.6599273681640625,4.3915557861328125,5.12347412109375,5.8554534912109375,6.5881195068359375,5.9281158447265625,5.27001953125,4.6113739013671875,3.952392578125,3.293212890625,2.634918212890625,1.975921630859375,1.31640625,0.658294677734375,0 },
						  yOffset = 32,
						  xOffset = 2
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
						  yOffset = 30
						 }
						},
						 x = 150,
						 y = -15,
						 scale = 1/2.5,
						 speed = 0.75
						}
						
		maryWings.isVisible = false
		maryBody.isVisible = false
		maryBodyAndNeck.isVisible = false
		maryAnimation.hide()
		
		local maryGroup = display.newGroup()
		maryGroup:insert(maryWings)
		maryGroup:insert(maryBodyAndNeck)
		maryGroup:insert(maryBody)
		maryGroup:insert(maryAnimation.displayObject)
		
		partyGroup:insert(maryGroup)
		maryGroup.xScale, maryGroup.yScale = 1.25,1.25
		maryGroup.y = maryGroup.y + 225
		maryGroup.x = maryGroup.x - 130
		maryGroup.rotation = -30
		
		local winSound = audio.loadSound("assets/sound/win.mp3")
		local winSoundChannel
		
		local function continue()
			localGroup:remove(partyGroup)
			
			maryBlinks.stopBlinking()
			maryAnimation.kill()
			
			continue=nil
			killTheParty=nil
		end
		killTheParty = function()
			startTheParty =nil
			vanish=nil
			continue()
		end
		
		local fireTimer = nil
		local function vanish()
			timer.performWithDelay(300, continue)
		end
		
		startTheParty = function()
			pauseIt = nil
			continueIt = nil
			
			localGroup:insert(partyGroup)
			
			saveData(5,1)
			
			winSoundChannel = audio.play(winSound,{loops=0})
			
			local function continueToNextScene()
				startTransition(false)
				timer.cancel(fireTimer)
				fireTimer=nil
				timer.performWithDelay(1500, vanish)
			end
			
			local function repeatThisScene()
				startTransition(true)
				timer.cancel(fireTimer)
				fireTimer=nil
				timer.performWithDelay(1500, vanish)
			end
			
			local points = calculatePoints(misses, extras, startTime, finishTime, difficultyLevel, "com.tapmediagroup.sleep")
			
			director:openPopUp({points = points,
								hideAction = continueToNextScene,
								repeatAction = repeatThisScene,
								killCaller = killAll,
								darkMode = true,
								},
								"pointsView")
			
			maryAnimation.start()
			maryAnimation.appear(300)
			
			maryBlinks.openEyes()
			maryBlinks.startBlinking()
			
			loadingBackground.isVisible = true
			maryWings.isVisible = true
			maryBody.isVisible = true
			maryBodyAndNeck.isVisible = true
			
			loadingBackground.alpha = 0
			maryWings.alpha = 0
			maryBody.alpha = 0
			maryBodyAndNeck.alpha = 0
			
			transition.to(loadingBackground,{alpha=1,time=300})
			transition.to(maryWings,{alpha=1,time=300})
			transition.to(maryBody,{alpha=1,time=300})
			transition.to(maryBodyAndNeck,{alpha=1,time=300})
			
			local function newBomb()
				fireIt()
				fireTimer = timer.performWithDelay(500, newBomb )
			end
			fireTimer = timer.performWithDelay(500, newBomb )
		end
	end
	prepareTheParty()
	
	--======================================
	-- TRANSITION TO INTERACTIVITY
	--======================================
	local function prepareTransition()
		local star1 = display.newImage("assets/whiteStar.png")
		star1:setReferencePoint(display.TopLeftReferencePoint)
		star1.x = 10
		star1.y = 20
		star1.xScale = 0.1
		star1.yScale = 0.1
		star1.isVisible = false
		localGroup:insert(star1)
		
		local star2 = display.newImage("assets/whiteStar.png")
		star2:setReferencePoint(display.CenterReferencePoint)
		star2.x = 350
		star2.y = 40
		star2.xScale = 0.5
		star2.yScale = 0.5
		star2.isVisible = false
		localGroup:insert(star2)
		
		local star3 = display.newImage("assets/whiteStar.png")
		star3:setReferencePoint(display.CenterReferencePoint)
		star3.x = 320
		star3.y = 300
		star3.xScale = 0.05
		star3.yScale = 0.05
		star3.isVisible = false
		localGroup:insert(star3)
		
		local star4 = display.newImage("assets/whiteStar.png")
		star4:setReferencePoint(display.CenterReferencePoint)
		star4.x = 30
		star4.y = 280
		star4.xScale = 0.2
		star4.yScale = 0.2
		star4.isVisible = false
		localGroup:insert(star4)
		
		star1:setFillColor(193,39,45)
		star2:setFillColor(140,198,63)
		star3:setFillColor(140,214,234)
		star4:setFillColor(255,255,0)
		
		killTransition = function()
			changeScene=nil
			loadInteraction=nil
			continue=nil
			vanish=nil
			startTransition =nil
			killTransition=nil
			
			localGroup:remove(star1)
			localGroup:remove(star2)
			localGroup:remove(star3)
			localGroup:remove(star4)
		end
		
		local repeatInteraction
		
		local function repeatScene()
			director:changeScene("Interactivity5","crossFade")
			repeatScene=nil
		end
		
		local function changeScene()
			director:changeScene({showPlayAgainMessage = true},"mainMenu","crossFade")
			changeScene=nil
		end
		
		local function loadInteraction()
			localGroup:remove(star1)
			localGroup:remove(star2)
			localGroup:remove(star3)
			localGroup:remove(star4)
			
			if repeatInteraction then
				timer.performWithDelay(500, repeatScene)
			else
				timer.performWithDelay(500, changeScene)
			end
			
			loadInteraction=nil
		end
		
		local function continue()
			local whiteBackground
			whiteBackground = display.newRect(0,0,width,height)
			whiteBackground:setFillColor(255,255,255)
			whiteBackground:setFillColor(255,255,255)
			whiteBackground.alpha=0
			localGroup:insert(whiteBackground)
			transition.to(whiteBackground,{alpha=1,time=300,onComplete=loadInteraction})
			continue=nil
		end
		
		local growStars
		
		local function vanish()
			timer.performWithDelay(300, continue)
			vanish=nil
		end
		
		startTransition = function(shouldRepeat)
			if shouldRepeat then repeatInteraction = shouldRepeat end
			
			localGroup:insert(star1)
			localGroup:insert(star2)
			localGroup:insert(star3)
			localGroup:insert(star4)
			
			star1.isVisible = true
			star2.isVisible = true
			star3.isVisible = true
			star4.isVisible = true
			
			star1.alpha = 0
			star2.alpha = 0
			star3.alpha = 0
			star4.alpha = 0
			
			local function animateStars()
				transition.to(star1,{alpha=1,time=700})
				transition.to(star2,{alpha=1,time=700})
				transition.to(star3,{alpha=1,time=700})
				transition.to(star4,{alpha=1,time=700})
				
				transition.to(star1,{xScale=3,yScale=3,		time=1500,transition=easing.inExpo})
				transition.to(star2,{xScale=2.5,yScale=2.5,	time=1500,transition=easing.inExpo})
				transition.to(star3,{xScale=2,yScale=2,		time=1500,transition=easing.inExpo})
				transition.to(star4,{xScale=3.5,yScale=3.5,	time=1500,transition=easing.inExpo})
			end
			timer.performWithDelay(200, animateStars)
			
			timer.performWithDelay(500, vanish)
			startTransition=nil
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
	
	gameOver = function()
		if overlay then
			transition.to( overlay, { alpha=1, time=300, delay=0 } )
		end
		director:openPopUp({hideAction = restartIt,
							killCaller = killAll,
							},
							"goMenu")
		gameOver = nil
	end
	
	--======================================
	-- MENU BUTTON
	--======================================
	-- ACTION
	local continueTimer
	local function continueGame( event )
		paused=false;
		if continueIt then
			screenMessages.resume()
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
				screenMessages.pause()
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
	local function systemEvent(event)
		if event.type == "applicationSuspend" and not paused then
			menuButtonAction({phase="release"})
		end
	end
	Runtime:addEventListener( "system", systemEvent )
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
	
	screenMessages.sendToFront()
	overlay:toFront()
	
	--======================================
	-- EXECUTE FIRST ACTION, THEY WILL BE CHAINEXECUTED
	--======================================
	startAdventure()
	
	return localGroup
end