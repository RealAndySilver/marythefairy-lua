function newSoundController()
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
		if not params.audioHandle then
			if not params.path then
				return nil
			end
			if not type(params.path) == "string" then
				return nil
			end
		end
		
		local thisSound = {}
		local thisSoundTimer = nil
		
		local autorelease = true
		local audioHandle = params.audioHandle
		if not audioHandle then
			audioHandle = audio.loadSound(params.path)
			autorelease = false
		end
		if params.autorelease then
			autorelease = params.autorelease
		end
		
		local duration = 0
		if audioHandle then
			duration = audio.getDuration( audioHandle )
		end
		
		local loops = (params.loops) and params.loops or 0
		
		local channel = -1
		local staticChannel = 0
		if params.staticChannel then staticChannel = params.staticChannel end
		
		if (audioHandle) then
			channel = audio.play(audioHandle, { loops=loops,
												onComplete = function(event)
												end,
												channel = staticChannel
											  })
		end
		
		local onComplete = function(event)
			event.completed = true
			if thisSound then
				if thisSound.kill then
					if type(thisSound.kill) == "function" then
						thisSound.kill(event)
					end
				end
			end
		end
		if channel <= 0 or (not audioHandle) then
			if params.duration and type(params.duration)=="number" then
				duration = params.duration
				if loops >= 0 then
					thisSoundTimer = timer.performWithDelay(duration*(loops+1), onComplete)
				end
			else
				print("Error while trying to play \""..params.path.."\"")
				return nil
			end
		else
			if loops >= 0 then
				thisSoundTimer = timer.performWithDelay(duration*(loops+1), onComplete)
			end
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
			if (thisSoundTimer) then
				timer.cancel(thisSoundTimer)
			end
			thisSoundTimer=nil
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
		
		thisSound.pause = function()
			if (channel > 0) then
				audio.pause(channel)
			end
			if (thisSoundTimer) then
				timer.pause(thisSoundTimer)
			end
		end
		
		thisSound.resume = function()
			if (channel > 0) then
				if audio.isChannelPaused(channel) then
					audio.resume(channel)
				end
			end
			if (thisSoundTimer) then
				timer.resume(thisSoundTimer)
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
			--print(i)
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