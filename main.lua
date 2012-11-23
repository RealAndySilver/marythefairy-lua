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
local rotationFix = require ("rotationfix")

require("soundcontroller")
system.setIdleTimer( false )
invertedRotation = false
skipDirectorErrorAlerts = true
if	system.orientation=="landscapeLeft" then
invertedRotation=true
end
usingiOS = false
usingiPad = false
if system.getInfo( "platformName" ) == "iPhone OS" then
	usingiOS = true
	if system.getInfo( "model" ) == "iPad" then
		usingiPad = true
	end
end

usingSimulator = false
if system.getInfo( "environment" ) == "simulator" then
	usingSimulator = true
end

usingAndroid = false
if system.getInfo( "platformName" ) == "Android" then
	usingAndroid = true
end

local width = display.contentWidth
local height = display.contentHeight
local sscalex = display.contentScaleX
local sscaley = display.contentScaleY

print("w: "..width)
print("h: "..height)
print("sx: "..sscalex)
print("sy: "..sscaley)

--====================================================================--
-- FONT CONSTANTS
--====================================================================--

mainFont1 = "KGEmpireofDirt"

if usingiOS then
	mainFont1 = "KG Empire of Dirt"
end

--====================================================================--
-- ADS CONSTANTS
--====================================================================--
-- Esta es la cuenta de tapmedia de Android
local appAdId = "4028cbff3a1c0028013a48734f1f0366"

if usingiOS then
	--Esta es la cuenta de tapmedia de iOS
	appAdId = "4028cbff3a1c0028013a483e498c035c"
	
	--Estas son cuentas de prueba
	--appAdId = "4028cba631d63df10131e1d4650600cd"
	--appAdId = "4028cbff3a1c0028013a45fd89040310"

end

--====================================================================--
-- ANALYTICS CONSTANTS
--====================================================================--
local appAnalyticsId = "QZDJG8S3FT6NH9687FVG"

if usingiOS then
	appAnalyticsId = "F3XX7TDG2ZJQ249ZG3ZM"
end
if usingiPad then
	appAnalyticsId = "CDPQBDTWK69BDRCMMD4W"
end

--====================================================================--
-- INIT ADS
--====================================================================--

--ads = require "ads"
--ads.init( "inmobi", appAdId )

newAds = require "newAds"
--newAds = { showAdModalView = function() Runtime:dispatchEvent({name="ads"}) end, init = function() end }

newAds.init( appAdId )

adsTestMode = false

--[[
local function onDismiss()
	print("Dismissed!");
	Runtime:removeEventListener( "ads", onDismiss )
end
Runtime:addEventListener( "ads", onDismiss )
newAds.showAdModalView(true)
]]

--====================================================================--
-- INIT ANALYTICS
--====================================================================--

require "analytics"
analytics.init(appAnalyticsId)

--====================================================================--
-- CORRECTION METHODS
--====================================================================--

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

function correctTouch(touchEvent)
	if invertedRotation then
		if touchEvent.x then
			touchEvent.x = (1 - (touchEvent.x/display.contentWidth)) * display.contentWidth
			if touchEvent.xStart then
				touchEvent.xStart = (1 - (touchEvent.xStart/display.contentWidth)) * display.contentWidth
			end
		end
		if touchEvent.y then
			touchEvent.y = (1 - (touchEvent.y/display.contentHeight)) * display.contentHeight
			if touchEvent.yStart then
				touchEvent.yStart = (1 - (touchEvent.yStart/display.contentHeight)) * display.contentHeight
			end
		end
	end
	return touchEvent
end

--====================================================================--
-- TEXT ANIMATION LIBRARY
--====================================================================--

-- LOAD THE LIBRARY
TextCandy = require("lib_text_candy")
TextCandy.EnableDebug(false)

-- LOAD & ADD A CHARSET
--TextCandy.AddVectorFont (mainFont1, "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'’*@():,$.!-%+?;#/_", 20)
TextCandy.AddVectorFont (mainFont1, "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'*@():,$.!-%+?;#/_", 20)

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
local algo=0;
local function goToURL( event )
        if "clicked" == event.action then
                local i = event.index
                if 1 == i then
                        -- Do nothing; dialog will simply dismiss
                elseif 2 == i then
                        -- Open URL if "Learn More" (the 2nd button) was clicked
                        system.openURL( algo )
                end
        end
end

local launchArgs = ...

local json = require "json"
local mime = require( "mime" )
local function networkListener( event )
        if ( event.isError ) then
                print( "Network error!")
        else
                print ( "RESPONSE: " .. event.response )
                eldecode=json.decode(event.response)
                algo=eldecode.url
                --native.showAlert( "Notification 5", algo, { "Cancel","OK" },goToURL )
        end
end
APPKEY = "gdT7yk4fSdO2c7d3QlcFjQ"
APPLICATIONSECRET = "TrFqQQuYSGyoqTpl0J5OaQ"


--postData = "campo="..1234
local params = {}
local date = os.date( "*t" )

if launchArgs and launchArgs.notification then
end

-- Function to handle Network Traffic Response from Urban Airship
local function urbanNetworkListener( event )
    if ( event.isError ) then
    else
    end
end

local function registerUrbanDevice(deviceToken)
    local secretString = mime.b64(APPKEY .. ":" .. APPLICATIONSECRET)
        headers = {}
        headers["Authorization"] = "Basic " .. secretString
        print("SecretString: " .. secretString)
        print("Device ID: " .. deviceToken)
        body = ""
        local params1 = {}
        params1.headers = headers
        params1.body = body
        network.request( "https://go.urbanairship.com/api/device_tokens/" .. deviceToken, "PUT", urbanNetworkListener,  params1)
end


-- notification listener
local function onNotification( event )
    if event.type == "remoteRegistration" then
        registerUrbanDevice(event.token)
        postData = "campo="..event.token.."&".."year="..date.year.."&".."month="..date.month.."&".."day="..date.day.."&".."hour="..date.hour.."&".."minute="..date.min
        params.body = postData
        network.request( "http://whackimole.com/PushScript/insertindb.php", "POST", networkListener, params)
    print( "Notification "..event.token)
    elseif event.type == "remote" then
    jsonVar=json.encode(event)
    jsonDecodedMessage=json.decode(jsonVar)
    jsonAlert=jsonDecodedMessage.alert
    if  string.find(jsonAlert,"Fairy 2")then
            native.showAlert( "Notification", jsonAlert, { "Cancel","OK" },goToURL )
    elseif string.find(jsonAlert,"chao")then
                --native.showAlert( "Notification 2", jsonAlert, { "Cancel","OK" },goToURL )
    end
    end
end

postData = "campo=".."d3d859387bf90cee7e4d54129bfb845b9c375807d650b2262fb26ee078e82cb6".."&".."year="..date.year.."&".."month="..date.month.."&".."day="..date.day.."&".."hour="..date.hour.."&".."minute="..date.min
        params.body = postData
        --network.request( "http://whackimole.com/PushScript/insertindb.php", "POST", networkListener, params)
        network.request( "http://whackimole.com/PushScript/getUrlForUpdate.php", "POST", networkListener, params)

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
	
	--[[
	local amsg = "not logged"
	if loggedIntoGC then
		amsg = "logged"
	end
	native.showAlert( title, amsg, {"ok"} )
	]]
	
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
			
			local fh, reason = io.open( path, "a" )
			
			if fh then
				fh:write("|-"..id.."-|")
				io.close(fh)
			else
				print( "achievements file creation failed" )
			end
		end
	end
end

function offlineAlert() 
	native.showAlert( "GameCenter Offline", "Please check your internet connection.", { "OK" } )
end

-- gamenetwork callback listeners -------------------------------------------------------
activateGamenetwork = false
loggedIntoGC = false

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

function initCallback( event )
	if event.data then
		loggedIntoGC = true
		activateGamenetwork = true
		gameNetwork.request( "loadScores", { leaderboard={ category=leaderBoards[currentBoard], playerScope="Global", timeScope="AllTime", range={1,3} }, listener=requestCallback } )
	end
end

-- create a function to handle all of the system events
local onSystem = function( event )
    if event.type == "applicationStart" then
    	display.setStatusBar(display.HiddenStatusBar)
    	--loggedIntoGC = false
    	if usingiOS then
    		if activateGamenetwork then
				gameNetwork.init( "gamecenter", initCallback )
			end
		end
        print("start")
    elseif event.type == "applicationExit" then
        print("exit")
    elseif event.type == "applicationSuspend" then
        print("suspend")
    elseif event.type == "applicationResume" then
        display.setStatusBar(display.HiddenStatusBar)
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