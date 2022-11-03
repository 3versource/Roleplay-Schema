local PLUGIN = PLUGIN

PLUGIN.Scenes = PLUGIN.Scenes or {}

local function hideEnts(hide, hidePlayers)
	for k,v in pairs(ents.GetAll()) do
		if v.CPPIGetOwner then
			local owner = v:CPPIGetOwner()

			if owner then
				if not hide and not v.sceneHide then
					continue
				end

				v:SetNoDraw(hide)
				v.sceneHide = hide
			end
		end
	end

	if hidePlayers or not hide then
		for v,k in pairs(player.GetAll()) do
			if not hidePlayers and k.sceneHide then
				k:SetNoDraw(false)
				k.sceneHide = nil
				continue
			end
			
			if hidePlayers and not k:GetNoDraw() then
				k:SetNoDraw(hidePlayers)
				k.sceneHide = true
			end
		end
	end
end

function PLUGIN.Scenes.Play(stage, sceneData, onDone, skipPVS, preLoad)
	PLUGIN.Scenes.pos = nil
	PLUGIN.Scenes.ang = nil
	sceneData.speed = sceneData.speed or 1

	if not skipPVS then
		net.Start("impulseScenePVS")
		net.WriteVector(sceneData.pvsPos or sceneData.pos)
		net.SendToServer()
	end

	hideEnts((sceneData.noHideProps == nil and true) or sceneData.noHideProps, sceneData.hidePlayers)

	local fov
	local lastAdd = 0
	local lastPosAdd = 0
	hook.Add("CalcView", "impulseScene", function()
		PLUGIN.Scenes.pos = PLUGIN.Scenes.pos or sceneData.pos
		PLUGIN.Scenes.ang = PLUGIN.Scenes.ang or sceneData.ang

		local view = {}

		if sceneData.endpos and not sceneData.static then
		    if sceneData.posNoLerp then
		    	lastPosAdd = lastPosAdd + FrameTime() * sceneData.posSpeed
		    	PLUGIN.Scenes.pos = LerpVector(lastPosAdd, sceneData.pos, sceneData.endpos)
		    else
		    	PLUGIN.Scenes.pos = LerpVector(FrameTime() * sceneData.speed, PLUGIN.Scenes.pos, sceneData.endpos)
		    end
		end

		if sceneData.endang and not sceneData.static then
			PLUGIN.Scenes.ang = LerpAngle(FrameTime() * sceneData.speed, PLUGIN.Scenes.ang, sceneData.endang)
		end

		if sceneData.fovFrom or sceneData.fovTo then
			if sceneData.fovSpeed then
				if sceneData.fovNoLerp then
					lastAdd = lastAdd + FrameTime() * sceneData.fovSpeed
					fov = Lerp(lastAdd, sceneData.fovFrom or 70, sceneData.fovTo or 70)
				else
					fov = Lerp(FrameTime() * sceneData.fovSpeed + ((fov or 0) * 0.000013), fov or (sceneData.fovFrom or 70), sceneData.fovTo or 70)
				end
			else
				fov = sceneData.fovFrom
			end
		end

		view.origin = PLUGIN.Scenes.pos
		view.angles = PLUGIN.Scenes.ang
		view.farz = 15000
		view.drawviewer = true
		view.fov = fov
		return view
	end)

	local outputText = ""
	local textPos = 1
	local nextTime = 0

	if sceneData.text then
		hook.Add("HUDPaint", "impulseScene", function()
			if CurTime() > nextTime and textPos != string.len(sceneData.text) then
				textPos = textPos + 1
				nextTime = CurTime() + .08
				surface.PlaySound("impulse/typewriter"..tostring(math.random(1,4))..".wav")
			end

			PLUGIN.Scenes.markup = markup.Parse("<font=ixNoticeFont>"..string.sub(sceneData.text, 1, textPos).."</font>", ScrW() * .7)
			PLUGIN.Scenes.markup:Draw(ScrW()/2, ScrH() * .8, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end)
	end

	if sceneData.time then
		timer.Simple(sceneData.time, function()
			hook.Remove("CalcView", "impulseScene")
			hook.Remove("HUDPaint", "impulseScene")

			if not sceneData.noHUDReEnable then
				PLUGIN.hudEnabled = true
			end

			hideEnts(false)

			if onDone then
				onDone()
			end
		end)

		timer.Simple(sceneData.time - 1, function()
			if sceneData.fadeOut then
				LocalPlayer():ScreenFade(SCREENFADE.OUT, Color(0, 0, 0), 1, 0.05)
			end

			if preLoad then
				preLoad(stage)
			end
		end)
	end

	if sceneData.onStart then
		sceneData.onStart()
	end

	if sceneData.fadeIn then
		LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 0, 0), 1, 0)
	end

	PLUGIN.hudEnabled = false
end

function PLUGIN.Scenes.PlaySet(set, music, onDone)
	local counter = 1

	SCENES_PLAYING = true

	local function pvsPreLoad(counter) -- preloads the pvs 1 second before scene loads
		local nextScene = set[counter + 1]

		if nextScene then
			net.Start("impulseScenePVS")
			net.WriteVector(nextScene.pvsPos or nextScene.pos)
			net.SendToServer()
		end
	end

	local function playScenes()
		if set[counter + 1] then
			counter = counter + 1
			PLUGIN.Scenes.Play(counter, set[counter], playScenes, true, pvsPreLoad)
		else
			if onDone then
				onDone()
			end

			SCENES_PLAYING = false
		end
	end

	if music then
		if music:find("www.") or music:find("http") then
			if IsValid(SCENE_MUSIC) then
				SCENE_MUSIC:stop()
			end

			local service = medialib.load("media").guessService(link)
			local clip = service:load(music)

			SCENE_MUSIC = clip

			clip:play()
		else
			surface.PlaySound(music)
		end
	end

	PLUGIN.Scenes.Play(1, set[counter], playScenes, false, pvsPreLoad)
end