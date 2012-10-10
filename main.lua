--====================================================================--
-- HIDE THE STATUS BAR
--====================================================================--

display.setStatusBar(display.HiddenStatusBar)

--====================================================================--
-- IMPORT DIRECTOR CLASS
--====================================================================--

local adPreloader = require("adPreloader")
local preloader = require("preloader")
local director = require("director")
local gameNetwork = require("gameNetwork")

ads = require "ads"
ads.init( "inmobi", "4028cbff39009b240139474acaad05df" )

function correctOffset(offset)
	--display.contentScaleX
	local offsetCorrection = 0
	if display.contentScaleX <= 0.5 then
		offsetCorrection = 1
		--offsetCorrection = 0
	else
		offsetCorrection = 0
	end
	
	local newOffset = offset + 10*offsetCorrection
	return newOffset
end

function retinaConditional(fval, tval)
	if display.contentScaleX <= 0.5 then
		return tval
	end
	return fval
end

--====================================================================--
-- FONT CONSTANTS
--====================================================================--

mainFont1 = "KG Empire of Dirt"

--====================================================================--
-- TEXT ANIMATION LIBRARY
--====================================================================--

-- LOAD THE LIBRARY
TextCandy = require("lib_text_candy")
TextCandy.EnableDebug(false)

-- LOAD & ADD A CHARSET
TextCandy.AddVectorFont (mainFont1, "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'’*@():,$.!-%+?;#/_", 20)

defaultIOT =
	{
	-- EFFECT SETTINGS
	hideCharsBefore = true,
	hideCharsAfter  = false,
	startNow	= false,
	loop		= false,
	autoRemoveText  = false,
	restartOnChange	= true,

	-- IN TRANSITION
	inDelay		= 0,
	inCharDelay	= 20,
	inMode   	= "LEFT_RIGHT",
	InSound   	= MySound,
	AnimateFrom	= { alpha = 0, xScale = 2.0, yScale = 2.0, time = 1000 },

	-- OUT TRANSITION
	outDelay	= 10000,
	outCharDelay	= 10,
	outMode   	= "LEFT_RIGHT",
	OutSound   	= MySound,
	AnimateTo	= { alpha = 0, time = 1000 }
	}
	
--====================================================================--
-- CREATE A MAIN GROUP
--====================================================================--

local mainGroup = display.newGroup()

--====================================================================--
-- Notifications
--====================================================================--
local launchArgs = ...

local json = require "json"

local function networkListener( event )
        if ( event.isError ) then
                print( "Network error!")
        else
                print ( "RESPONSE: " .. event.response )
        end
end
 
--postData = "campo="..1234
local params = {}
local date = os.date( "*t" )

if launchArgs and launchArgs.notification then
    native.showAlert( "launchArgs", json.encode( launchArgs.notification ), { "OK" } )
end
-- notification listener
local function onNotification( event )
    if event.type == "remoteRegistration" then
        native.showAlert( "remoteRegistration", event.token, { "OK" } )
        postData = "campo="..event.token.."&".."year="..date.year.."&".."month="..date.month.."&".."day="..date.day.."&".."hour="..date.hour.."&".."minute="..date.min
        params.body = postData
        network.request( "http://174.120.23.123/~api/push_notifications/PushScript/insertindb", "POST", networkListener, params)
    print( "Notification"..event.token)
    elseif event.type == "remote" then
        native.showAlert( "remote", json.encode( event ), { "OK" } )
    end
end
postData = "campo=".."d3d859387bf90cee7e4d54129bfb845b9c375807d650b2262fb26ee078e82cb6".."&".."year="..date.year.."&".."month="..date.month.."&".."day="..date.day.."&".."hour="..date.hour.."&".."minute="..date.min
        params.body = postData
        network.request( "http://174.120.23.123/~api/push_notifications/PushScript/insertindb", "POST", networkListener, params)

print("año "..date.year,"mes "..date.month,"Día "..date.day,"hora "..date.hour, "minutos "..date.min)
Runtime:addEventListener( "notification", onNotification )

--====================================================================--
-- MAIN FUNCTION
--====================================================================--

levelIDS = {"c1a1","c1a2","c1a3","c1a4","c1a5"}
local lowVolume = 0.3
local highVolume = 1.0

function saveData(indexID,nextID)
	if type(indexID) ~= "number" then
		indexID = 1
		nextID = 1
	end
	if indexID<1 or indexID>#levelIDS then
		indexID = 1
		nextID = 1
	end
	if type(nextID) ~= "number" then
		nextID = 1
	end
	if nextID<1 or nextID>#levelIDS then
		nextID = 1
	end
	
	local path = system.pathForFile( "progressData", system.DocumentsDirectory )
	local fh
	
	local maxUnlockedLevel = 1
	fh = io.open( path, "r" )
	if fh then
		local contents = fh:read( "*a" )
		for i=1,#levelIDS do
			if string.find(contents,levelIDS[i]) then
				maxUnlockedLevel = i
			end
		end
		io.close(fh)
	end
	
	if maxUnlockedLevel>indexID then
		indexID=maxUnlockedLevel
	end
	
	fh = io.open( path, "w" )
	
	if fh then
		for i=1,indexID do
			fh:write("-",levelIDS[i],"\n")
		end
		fh:write("nl",levelIDS[nextID])
		io.close(fh)
	else
		print( "savedata file creation failed" )
	end
end

function getMaxUnlockedLevel()
	local path = system.pathForFile( "progressData", system.DocumentsDirectory )
	local maxUnlockedLevel = 1
	fh = io.open( path, "r" )
	if fh then
		local contents = fh:read( "*a" )
		for i=1,#levelIDS do
			if string.find(contents,levelIDS[i]) then
				maxUnlockedLevel = i
			end
		end
		io.close(fh)
	end
	return maxUnlockedLevel
end

function getDifficulty()
	local difficultyLevel = 1
	local path = system.pathForFile( "difficultyLevel", system.DocumentsDirectory )
	
	-- io.open opens a file at path. returns nil if no file found
	local fh, reason = io.open( path, "r" )
	
	if fh then
		-- read all contents of file into a string
		local contents = fh:read( "*a" )
		if string.find(contents,"1") then
			difficultyLevel = 1
		elseif string.find(contents,"2") then
			difficultyLevel = 2
		elseif string.find(contents,"3") then
			difficultyLevel = 3
		else
			io.close( fh )
			fh = io.open( path, "w" )
			fh:write("1")
		end
	else
		print( "Reason open failed: " .. reason )  -- display failure message in terminal
		
		-- create file because it doesn't exist yet
		fh = io.open( path, "w" )
		
		if fh then
			fh:write("1")
		else
			print( "difficultylevel file creation failed" )
		end
	end
	io.close( fh )
	
	return difficultyLevel
end

soundActivated = nil

function setSoundActivation(value)
	audio.reserveChannels(6)
	if value then
		for i=1,32,1 do
			audio.setVolume( highVolume, { channel=i } )
		end
		for i=1,6,1 do
			audio.setVolume( lowVolume/2, { channel=i } )
		end
		for i=1,4,1 do
			audio.setVolume( lowVolume, { channel=i } )
		end
		soundActivated = true
	else
		for i=1,32,1 do
			audio.setVolume( 0.0, { channel=i } )
		end
		soundActivated = false
	end
end

function getSoundActivation()
	local path = system.pathForFile( "volumeConfig", system.DocumentsDirectory )
	
	-- io.open opens a file at path. returns nil if no file found
	local fh, reason = io.open( path, "r" )
	
	soundActivated = true
	
	if fh then
		for line in fh:lines() do
			if string.find(line,"on") then
				soundActivated = true
			else
				soundActivated = false
			end
		end
	else
		print( "Reason open failed: " .. reason )  -- display failure message in terminal
		
		-- create file because it doesn't exist yet
		fh = io.open( path, "w" )
		
		if fh then
			if soundActivated then
				fh:write("on")
			else
				fh:write("off")
			end
		else
			print( "volumeConfig file creation failed" )
		end
	end
	io.close( fh )
	
	audio.reserveChannels(6)
	if soundActivated then
		for i=1,32,1 do
			audio.setVolume( highVolume, { channel=i } )
		end
		for i=1,6,1 do
			audio.setVolume( lowVolume/2, { channel=i } )
		end
		for i=1,4,1 do
			audio.setVolume( lowVolume, { channel=i } )
		end
		soundActivated = true
	else
		for i=1,32,1 do
			audio.setVolume( 0.0, { channel=i } )
		end
		soundActivated = false
	end
end
getSoundActivation()

function saveSoundActivation()
	audio.reserveChannels(6)
	if soundActivated then
		for i=1,32,1 do
			audio.setVolume( highVolume, { channel=i } )
		end
		for i=1,6,1 do
			audio.setVolume( lowVolume/2, { channel=i } )
		end
		for i=1,4,1 do
			audio.setVolume( lowVolume, { channel=i } )
		end
	else
		for i=1,32,1 do
			audio.setVolume( 0.0, { channel=i } )
		end
	end
	
	local path = system.pathForFile( "volumeConfig", system.DocumentsDirectory )
	
	local fh, reason = io.open( path, "w" )
	
	if fh then
		if soundActivated then
			fh:write("on")
		else
			fh:write("off")
		end
		io.close(fh)
	else
		print( "volumeConfig file creation failed" )
	end
end

function getTextArrayFromFile(filename, directory)
	if directory == nil then directory = system.DocumentsDirectory end
	
	local path = system.pathForFile( filename, directory )
	
	if path == nil then return {} end
	
	daarray = {}
	
	-- io.open opens a file at path. returns nil if no file found
	local fh, reason = io.open( path, "r" )
	
	if fh then
		for line in fh:lines() do
			daarray[#daarray+1] = string.gsub(line, "\\n", "\n")
		end
		io.close( fh )
	end
	
	return daarray
end

function calculatePoints(misses, extras, startTime, finishTime, difficultyLevel, leaderboardID)
	local points = 100
	
	-- misses
	points = points - (misses * 2 / difficultyLevel)
	
	-- extras
	points = points + (extras * 1.25 * difficultyLevel)
	
	-- time
	local totalTime = (finishTime - startTime) / 1000
	points = points - totalTime/2*(difficultyLevel)
	
	local pointsFancyNumber = math.ceil(points*1000)
	
	if leaderboardID then
		if type(leaderboardID) == "number" then
			if loggedIntoGC then
				gameNetwork.request( "setHighScore", {	localPlayerScore={ 
															category=leaderboardID,
															value=pointsFancyNumber },
														listener=requestCallback } )
			end
		end
	end
	
	return pointsFancyNumber
end

local function newSoundController()
	local thisSC ={}
	
	local playing = true
	local playList = {}
	
	local pausedTime = nil
	local function checkAllSounds()
		--if (not playing) or (#playList == 0) then
		if (not playing) then
			Runtime:removeEventListener( "enterFrame", checkAllSounds )
			return
		end
		
		for i=1, #playList do
			if playList[i] then
				playList[i].check()
			end
		end
	end
	
	thisSC.playNew = function(params)
		if not audioHandle then
			if not params.path then
				return nil
			end
			if not type(params.path) == "string" then
				return nil
			end
		end
		
		local autorelease = true
		local audioHandle = params.audioHandle
		if not audioHandle then
			audioHandle = audio.loadSound(params.path)
			autorelease = false
		end
		if not audioHandle then
			return
		end
		if params.autorelease then
			autorelease = params.autorelease
		end
		local duration = audio.getDuration( audioHandle )
		local loops = (params.loops) and params.loops or 0
		local channel = -1
		
		local thisSound = {}
		
		thisSound.kill = function(event)
			local completed = false
			if event then
				if event.completed then
					completed = event.completed
				end
			end
			if channel then
				if channel>0 then
					if audio.isChannelActive(channel) then
						audio.stop(channel)
					end
				end
			end
			if audioHandle and autorelease then
				audio.dispose(audioHandle)
				audioHandle = nil
			end
			for i=1, #playList do
				if playList[i] == thisSound then
					table.remove(playList,i)
					i=i-1
				end
			end
			if params.onComplete and completed then
				if type(params.onComplete) == "function" then
					params.onComplete()
				end
			end
			thisSound = nil
			loops = nil
			duration = nil
			params = nil
			channel = nil
		end
		
		thisSound.identifier = ""
		if params.identifier then
			thisSound.identifier = params.identifier
		end
		
		thisSound.pausable = true
		if params.pausable then
			thisSound.pausable = params.pausable
		end
		
		thisSound.check = function()
			if not params then
				return
			end
			if type(params.actionTimes) == "table" then
				local diffTime = system.getTimer() - thisSound.timeStarted
				if params.actionTimes[1] then
					if (params.actionTimes[1] >= 0) and (params.actionTimes[1] <= diffTime) then
						if params.action then
							if type(params.action) == "function" then
								--print(params.path)
								params.action()
							end
						end
						if params.repeatActions then
							actionTimes[#actionTimes+1] = actionTimes[1]
						end
						table.remove(params.actionTimes,1)
					end
				end
				if diffTime > duration then
					--thisSound.timeStarted = thisSound.timeStarted + duration
					thisSound.timeStarted = system.getTimer()
					if params.actionTimes[1] then
						if params.actionTimes[1] < 0 then
							print("restarted")
							if params.repeatActions then
								actionTimes[#actionTimes+1] = actionTimes[1]
							end
							table.remove(params.actionTimes,1)
						end
					end
				end
			end
		end
		
		thisSound.addTime = function(value)
			if thisSound.timeStarted then
				thisSound.timeStarted = thisSound.timeStarted + value
			end
		end
		
		local staticChannel = 0
		if params.staticChannel then staticChannel = params.staticChannel end
		channel = audio.play(audioHandle, { loops=loops,
											onComplete = function(event)
												if thisSound then
													if thisSound.kill then
														if type(thisSound.kill) == "function" then
															thisSound.kill(event)
														end
													end
												end
											end,
											channel = staticChannel
										  })
		if channel == 0 then
			print("Error while trying to play \""..params.path.."\"")
			return nil
		end
		thisSound.timeStarted = system.getTimer()
		if not playing then
			if pausedTime then
				thisSound.timeStarted = pausedTime
			end
			audio.pause(channel)
		else
			thisSC.play()
		end
		
		thisSound.pause = function()
			audio.pause(channel)
		end
		
		thisSound.resume = function()
			if audio.isChannelPaused(channel) then
				audio.resume(channel)
			end
		end
		--[[
		print("-")
		print("path "..params.path)
		print("channel "..channel)
		print("volume "..audio.getVolume(channel))
		print("-")
		]]
		table.insert(playList,thisSound)
	end
	
	thisSC.pause = function()
		pausedTime = system.getTimer()
		playing = false
		Runtime:removeEventListener( "enterFrame", checkAllSounds )
		for i=1, #playList do
			if playList[i].pausable then
				playList[i].pause()
			end
		end
	end
	
	thisSC.resume = function()
		if pausedTime then
			local totalPaused = system.getTimer() - pausedTime
			for i=1, #playList do
				playList[i].addTime(totalPaused)
			end
		end
		pausedTime = nil
		if not playing then
			playing = true
			Runtime:addEventListener( "enterFrame", checkAllSounds )
			for i=1, #playList do
				playList[i].resume()
			end
		end
	end
	thisSC.play = thisSC.resume
	
	thisSC.stop = function()
		thisSC.killAll()
	end
	
	thisSC.killAll = function()
		thisSC.play()
		pausedTime = nil
		playing = true
		while playList[1] do
			playList[1].kill()
		end
		--Runtime:removeEventListener( "enterFrame", checkAllSounds )
	end
	
	thisSC.kill = function(identifier)
		for i = 1, #playList do
			print(i)
			if playList[i] then
				if playList[i].identifier == identifier then
					playList[i].kill()
					i = i-1
				end
			end
		end
	end
	
	playing = true
	Runtime:addEventListener( "enterFrame", checkAllSounds )
	return thisSC
end
soundController = newSoundController()
soundController.play()

function unlockAchievement(id, reference, title)
	local alreadyUnlocked = false
	local path = system.pathForFile( "achievements", system.DocumentsDirectory )
	
	local fh, reason = io.open( path, "r" )
	if fh then
		local contents = fh:read( "*a" )
		if string.find(contents,"-"..id.."-") then
			alreadyUnlocked = true
		end
		io.close(fh)
	end
	
	if alreadyUnlocked then return end
	
	if not alreadyUnlocked then
		if loggedIntoGC then
			gameNetwork.request( "unlockAchievement", {
						achievement = {
							identifier=id,
							percentComplete=100,
							showsCompletionBanner=true,
						}
					});
		end
		
		local fh, reason = io.open( path, "a" )
		
		if fh then
			fh:write("|-"..id.."-|")
			io.close(fh)
		else
			print( "achievements file creation failed" )
		end
	end
end

function offlineAlert() 
	native.showAlert( "GameCenter Offline", "Please check your internet connection.", { "OK" } )
end

-- gamenetwork callback listeners -------------------------------------------------------
activateGamenetwork = false

function requestCallback( event )
	if event.type == "setHighScore" then
		--[[
		local function alertCompletion() gameNetwork.request( "loadScores", { leaderboard={ category=leaderBoards[currentBoard], playerScope="Global", timeScope="AllTime", range={1,3} }, listener=requestCallback } ); end
		native.showAlert( "High Score Reported!", "", { "OK" }, alertCompletion )
		]]
	elseif event.type == "loadScores" then
		--[[
		if event.data then
			local topRankID = event.data[1].playerID
			local topRankScore = event.data[1].formattedValue
			bestTextValue = string.sub( topRankScore, 1, 12 ) .. "..."
			
			if topRankID then gameNetwork.request( "loadPlayers", { playerIDs={ topRankID }, listener=requestCallback} ); end
		end
		
		if event.localPlayerScore then
			userBest = event.localPlayerScore.formattedValue
		else
			userBest = "Not ranked"
		end
		
		if userBestText then ui.updateLabel( userBestText, userBest, display.contentWidth-25, 177, display.TopRightReferencePoint ); end
		]]
	elseif event.type == "loadPlayers" then
		--[[
		if event.data then
			local topRankAlias = event.data[1].alias
			
			if topRankAlias then
				topScorer = topRankAlias
				if bestLabel and bestText then
					ui.updateLabel( bestLabel, topScorer .. " got:", 25, 212, display.TopLeftReferencePoint )
					ui.updateLabel( bestText, bestTextValue, display.contentWidth-25, 212, display.TopRightReferencePoint )
				end
			end
		end
		]]
	end
end

local function initCallback( event )
	if event.data then
		loggedIntoGC = true
		--gameNetwork.request( "loadScores", { leaderboard={ category=leaderBoards[currentBoard], playerScope="Global", timeScope="AllTime", range={1,3} }, listener=requestCallback } )
	end
end

-- create a function to handle all of the system events
local onSystem = function( event )
    if event.type == "applicationStart" then
    	loggedIntoGC = false
    	if activateGamenetwork then
			gameNetwork.init( "gamecenter", initCallback )
		end
        print("start")
    elseif event.type == "applicationExit" then
        print("exit")
    elseif event.type == "applicationSuspend" then
        print("suspend")
    elseif event.type == "applicationResume" then
        print("resume")
    end
end

function initGameNetwork(callback)
	if callback then
		gameNetwork.init( "gamecenter", callback )
	else
		gameNetwork.init( "gamecenter", initCallback )
	end
end
 
-- setup a system event listener
Runtime:addEventListener( "system", onSystem )

local main = function ()
	activateGamenetwork = false
	
	suffix = ""
	screenScale = 1
	if display.contentScaleX<=0.5 then
		suffix = "@200"
		screenScale = 2
	end
	
	------------------
	-- Add the group from director class
	------------------
	
	mainGroup:insert(director.directorView)
	
	director:changeScene("TapMediaIntro","crossFade")
	
	--[[
	local fps = require("fps")
	local performance = fps.PerformanceOutput.new();
	performance.group.x, performance.group.y = display.contentWidth/2, display.screenOriginY;
	performance.group.alpha = 0.6;
	]]
	
	return true
end

--====================================================================--
-- BEGIN
--====================================================================--

main()