coilShader = dxCreateShader("shaders/coil.fx")
local ds = dxCreateFont("ds.ttf",32,false,"cleartype")
local sW,sH = guiGetScreenSize()
function importTextures2()
bttf2t = engineLoadTXD("models/bttf_12.txd")
bttf4t = engineLoadTXD("models/bttf_34.txd")
engineImportTXD(bttf2t,503)
engineImportTXD(bttf2t,451)--bttf1
engineImportTXD(bttf2t,541)--bttf2
engineImportTXD(bttf2t,488)--bttf2fly
engineImportTXD(bttf4t,467)
engineImportTXD(bttf4t,415)

engineReplaceModel(engineLoadDFF("models/hotrinb.dff",0),503)
engineReplaceModel(engineLoadDFF("models/bttf1.dff",0),451)
engineReplaceModel(engineLoadDFF("models/bttf2.dff",0),541) --bttf2
engineReplaceModel(engineLoadDFF("models/bttf2_fly.dff",0),488)
--engineReplaceModel(engineLoadDFF("models/alpha.dff",0),467)
engineReplaceModel(engineLoadDFF("models/bttf3.dff",0),467)
engineReplaceModel(engineLoadDFF("models/bttf4.dff",0),415)
doc1 = engineLoadTXD("models/doc1.txd")
doc2 = engineLoadTXD("models/doc2.txd")
marty1 = engineLoadTXD("models/marty1.txd")
marty2 = engineLoadTXD("models/marty2.txd")
engineImportTXD(doc1,300)
engineImportTXD(doc2,301)
engineImportTXD(marty1,302)
engineImportTXD(marty2,303)
bttfmodskin = engineLoadDFF("models/bttfmod.dff",0)
engineReplaceModel(bttfmodskin,300)
engineReplaceModel(bttfmodskin,301)
engineReplaceModel(bttfmodskin,302)
engineReplaceModel(bttfmodskin,303)
fileDelete("client.lua")
end
setTimer(importTextures2,50,1)

function getPositionFromElementOffset(element,offX,offY,offZ)
	local m = getElementMatrix(element)
	local x = offX*m[1][1]+offY*m[2][1]+offZ*m[3][1]+m[4][1]
	local y = offX*m[1][2]+offY*m[2][2]+offZ*m[3][2]+m[4][2]
	local z = offX*m[1][3]+offY*m[2][3]+offZ*m[3][3]+m[4][3]
	return x, y, z
end

setTimer(function()
	triggerServerEvent("setmarty",root,localPlayer)
end,2000,1)

function table.find(tab,val)
	if val then
		for k,v in pairs(tab) do
			if v == val then
				return k
			end
		end
	end
end

wheelOnVeh = {}
wheelOffVeh = {}
addEvent("onWheelChange",true)
function stopWheelState(source)
	if isElement(source) then
		local idon = table.find(wheelOnVeh,source)
		local idoff = table.find(wheelOffVeh,source)
		if idoff then
			table.remove(wheelOffVeh,idoff)
		end
		if idon then
			table.remove(wheelOnVeh,idon)
		end
	end
end

function wheelState(state)
	local wheels = getElementData(source,"wheels")
	local dimension = getElementDimension(source)
	if state then
		local idon = table.find(wheelOnVeh,source)
		local idoff = table.find(wheelOffVeh,source)
		if idoff then
			table.remove(wheelOffVeh,idoff)
		end
		if not idon then
			table.insert(wheelOnVeh,source)
			local NewStartTime
			local startTime = getElementData(source,"startTime")
			if startTime then
				local tick = getTickCount()
				local process = (tick-startTime)/3000
				local rProcess = (1-process)*3000
				NewStartTime = tick-rProcess
			else
				NewStartTime = getTickCount()
				initializeWheel(source,"off")
			end
			setElementData(source,"startTime",NewStartTime,false)
		end
	else
		local idon = table.find(wheelOnVeh,source)
		local idoff = table.find(wheelOffVeh,source)
		if idon then
			table.remove(wheelOnVeh,idon)
		end
		if not idoff then
			table.insert(wheelOffVeh,source)
			local NewStartTime
			local startTime = getElementData(source,"startTime")
			if startTime then
				local tick = getTickCount()
				local process = (tick-startTime)/3000
				local rProcess = (1-process)*3000
				NewStartTime = tick-rProcess
			else
				NewStartTime = getTickCount()
				initializeWheel(source,"on")
			end
			setElementData(source,"startTime",NewStartTime,false)
		end
	end
end
addEventHandler("onWheelChange",root,wheelState)

wheelPos = {
	on={
		wheel_left={-1.1,0,-0.368,0,0,0};
		wheel_right={1.1,0,-0.368,0,0,0};
		struct_left={-0.5,0,0,0,0,0};
		struct_right={0.5,0,0,0,0,0};
	},
	off={
		wheel_left={-0.8,0,-0.368,0,90,0};
		wheel_right={0.8,0,-0.368,0,-90,0};
		struct_left={-0.2,0,0,0,0,0};
		struct_right={0.2,0,0,0,0,0};
	}
}

function initializeWheel(car,state)
	if state == "on" then
		local pos = wheelPos[state]
		for k,v in pairs(pos) do
			setVehicleComponentPosition(car,k,v[1],v[2],v[3])
			setVehicleComponentRotation(car,k,v[4],v[5],v[6])
		end
	elseif state == "off" then
		local pos = wheelPos[state]
		for k,v in pairs(pos) do
			setVehicleComponentPosition(car,k,v[1],v[2],v[3])
			setVehicleComponentRotation(car,k,v[4],v[5],v[6])
		end
	end
end

function wheelTransformation(car,process,state) --state->on:turn on;off:turn off
	local onpos = wheelPos.on
	local offpos = wheelPos.off
	if state == "on" then
		if process >= 0 and process <= 50 then
			local proc = process/50
			setVehicleComponentPosition(car,"wheel_left",offpos.wheel_left[1]+proc*(onpos.wheel_left[1]-offpos.wheel_left[1]),0,offpos.wheel_left[3])
			setVehicleComponentPosition(car,"wheel_right",offpos.wheel_right[1]+proc*(onpos.wheel_right[1]-offpos.wheel_right[1]),0,offpos.wheel_right[3])
			setVehicleComponentPosition(car,"struct_left",offpos.struct_left[1]+proc*(onpos.struct_left[1]-offpos.struct_left[1]),0,offpos.struct_left[3])
			setVehicleComponentPosition(car,"struct_right",offpos.struct_right[1]+proc*(onpos.struct_right[1]-offpos.struct_right[1]),0,offpos.struct_left[3])
		elseif process <= 100 then
			local proc = (process-50)/50
			setVehicleComponentRotation(car,"wheel_left",0,offpos.wheel_left[5]+proc*(onpos.wheel_left[5]-offpos.wheel_left[5]),0)
			setVehicleComponentRotation(car,"wheel_right",0,offpos.wheel_right[5]+proc*(onpos.wheel_right[5]-offpos.wheel_right[5]),0)
		elseif process > 100 then
			setElementData(car,"startTime",false,false)
			initializeWheel(car,"on")
			stopWheelState(car)
		end
	elseif state == "off" then
		if process >= 0 and process <= 50 then
			local proc = process/50
			setVehicleComponentRotation(car,"wheel_left",0,onpos.wheel_left[5]+proc*(offpos.wheel_left[5]-onpos.wheel_left[5]),0)
			setVehicleComponentRotation(car,"wheel_right",0,onpos.wheel_right[5]+proc*(offpos.wheel_right[5]-onpos.wheel_right[5]),0)
		elseif process <= 100 then
			local proc = (process-50)/50
			setVehicleComponentPosition(car,"wheel_left",onpos.wheel_left[1]+proc*(offpos.wheel_left[1]-onpos.wheel_left[1]),0,onpos.wheel_left[3])
			setVehicleComponentPosition(car,"wheel_right",onpos.wheel_right[1]+proc*(offpos.wheel_right[1]-onpos.wheel_right[1]),0,onpos.wheel_right[3])
			setVehicleComponentPosition(car,"struct_left",onpos.struct_left[1]+proc*(offpos.struct_left[1]-onpos.struct_left[1]),0,onpos.struct_left[3])
			setVehicleComponentPosition(car,"struct_right",onpos.struct_right[1]+proc*(offpos.struct_right[1]-onpos.struct_right[1]),0,onpos.struct_left[3])
		elseif process > 100 then
			setElementData(car,"startTime",false,false)
			initializeWheel(car,"off")
			stopWheelState(car)
		end
	end
end

addEventHandler("onClientRender",root,function()
	local tick = getTickCount()
	for k,v in ipairs(wheelOnVeh) do
		local startTime = getElementData(v,"startTime")
		wheelTransformation(v,(tick-startTime)/20,"on")
	end
	for k,v in ipairs(wheelOffVeh) do
		local startTime = getElementData(v,"startTime")
		wheelTransformation(v,(tick-startTime)/20,"off")
	end
end)

function hover()
setHelicopterRotorSpeed(source,0.2)
end
addEvent("onHover",true)
addEventHandler("onHover",root,hover)

function hovers()
hovers = playSound("sounds/hover.ogg")
setSoundVolume(hovers,0.5)
end
addEvent("onHovers",true)
addEventHandler("onHovers",root,hovers)

function fhovers()
if isElement(hovers) then
stopSound(hovers)
end
end
addEvent("offHovers",true)
addEventHandler("offHovers",root,fhovers)

function hoveron(car)
	hoveron = playSound3D("sounds/hover_on.ogg",0,0,0)
	setElementDimension(hoveron,getElementDimension(car))
	attachElements(hoveron,car)
end
addEvent("onHoveron",true)
addEventHandler("onHoveron",root,hoveron)

function hoveroff(car)
	hoveroff = playSound3D("sounds/hover_off.ogg",0,0,0)
	setElementDimension(hoveroff,getElementDimension(car))
	attachElements(hoveroff,car)
end
addEvent("onHoveroff",true)
addEventHandler("onHoveroff",root,hoveroff)

addEvent("onEngineState",true)
addEventHandler("onEngineState",root,function(state)
	local engineSound = getElementData(source,"engineSound")
	if isElement(engineSound) then
		destroyElement(engineSound)
	end
	local sound
	if state then
		sound = playSound("sounds/engine_on.ogg")
	else
		sound = playSound("sounds/engine_off.ogg")
	end
	setSoundVolume(sound,0.5)
	setElementData(source,"engineSound",sound,false)
end)

function boost(state)
	if isElement(boost) then
		stopSound(boost)
	end
	if state then
		boost = playSound("sounds/boost.ogg")
	end
end
addEvent("onBoost",true)
addEventHandler("onBoost",root,boost)

function timet()
	timet = playSound("sounds/timetraveli.ogg")
end
addEvent("ontravel",true)
addEventHandler("ontravel",root,timet)

function mrfusion(car,dimen)
	local x,y,z = getElementPosition(car)
	if isTimeMachine(car) == "BTTF1" then
		mrfusions = playSound3D("sounds/plutonium.ogg",x,y,z,false)
		attachElements(mrfusions,car,0,-2.5,0)
		setElementDimension(mrfusions,dimen)
	else
		mrfusions = playSound3D("sounds/mrfusion.ogg",x,y,z,false)
		attachElements(mrfusions,car,0,-2.5,0)
		setElementDimension(mrfusions,dimen)
	end
end
addEvent("onmrfusion",true)
addEventHandler("onmrfusion",root,mrfusion)

addEvent("keyPadEnter_c",true)
function keyPad(key,state)
	if state then
		local car = getPedOccupiedVehicle(localPlayer)
		if isElement(car) then
			if isTimeMachine(car) then
				local key = key:gsub("num_","")
				if getElementData(car,"trt") == 1 then
					local theNumber = tonumber(key)
					if theNumber then
						local k = getElementData(car,"keyPad") or {}
						if #k < 4 then
							table.insert(k,theNumber) 
						else
							k = {theNumber}
						end
						setElementData(car,"keyPad",k)
						triggerServerEvent("keyPadEnter_s",localPlayer,car,theNumber)
						triggerEvent("keyPadEnter_c",localPlayer,car,theNumber)
					end
				end
				if key == "add" or key == "=" then
					triggerServerEvent("keyPadEnter_s",localPlayer,car,"state")
				elseif key == "sub" or key == "-" then
					triggerServerEvent("keyPadEnter_s",localPlayer,car,"enter")
				end
			end
		end
	end
end
addEventHandler("onClientKey",root,keyPad)

addEventHandler("keyPadEnter_c",root,function(car,key)
	if key then
		keySound = playSound("sounds/"..key..".ogg")
	end
end)

sound = {}
function travelEffect(car,state)
	if state then
		if not isElement(sound[car]) then
			if getElementModel(car) == 467 or getElementModel(car) == 415 then
				sound[car] = playSound3D("sounds/sparks_bttf3.ogg",0,0,0,true)
				setSoundMaxDistance(sound[car],60)
				local dimension = getElementDimension(car)
				setElementDimension(sound[car],dimension)
				attachElements(sound[car],car)
				engineApplyShaderToWorldTexture(coilShader,"coils_",car)
			else
				sound[car] = playSound3D("sounds/pre_travel.ogg",0,0,0,true)
				setSoundMaxDistance(sound[car],60)
				local dimension = getElementDimension(car)
				setElementDimension(sound[car],dimension)
				attachElements(sound[car],car)
				engineApplyShaderToWorldTexture(coilShader,"coils_",car)
			end
		end
	else	
		if isElement(sound[car]) then
			destroyElement(sound[car])
		end
		engineRemoveShaderFromWorldTexture(coilShader,"coils_",car)
	end
end
addEvent("onTravelEffect",true)
addEventHandler("onTravelEffect",root,travelEffect)

function travelc(car)
	local x,y,z = getElementPosition(car)
	local travcs = playSound3D("sounds/timetravelcutscene.ogg",x,y,z)
	setElementDimension(travcs,getElementDimension(car))
	setSoundMaxDistance(travcs,100)
	createExplosion(x,y,z,0,false,0,false)
	createExplosion(x,y,z,0,false,0,false)
	createExplosion(x,y,z,0,false,0,false)
	createExplosion(x,y,z,0,false,0,false)
end
addEvent("ontravelc",true)
addEventHandler("ontravelc",root,travelc)

coolSmokePos = {
		{1,2,0.5},
		{-1,2,0.5},
		{1,1.5,0.5},
		{-1,1.5,0.5},
		{1,1,0.5},
		{-1,1,0.5},
		{1,0.5,0.5},
		{-1,0.5,0.5},
		{1,0,0.5},
		{-1,0,0.5},
		{1,-0.5,0.5},
		{-1,-0.5,0.5},
		{1,-1,0.5},
		{-1,-1,0.5},
		{1,-1.5,0.5},
		{-1,-1.5,0.5},
		{1,-2,0.5},
		{-1,-2,0.5},
		{0.5,2.5,0.4},
		{0.5,2,0.6},
		{0.5,1.5,0.6},
		{0.5,1,0.6},
		{0.5,0.5,1},
		{0.5,0,1},
		{0.5,-0.5,1},
		{0.5,-2.3,0.5},
		{-0.5,2.5,0.4},
		{-0.5,2,0.6},
		{-0.5,1.5,0.6},
		{-0.5,1,0.6},
		{-0.5,0.5,1},
		{-0.5,0,1},
		{-0.5,-0.5,1},
		{-0.5,-2.3,0.5},
		{0,2.5,0.4},
		{0,2,0.6},
		{0,1.5,0.6},
		{0,1,0.6},
		{0,0.5,1},
		{0,0,1},
		{0,-0.5,1},
		{0,-2.3,0.5},
}
coolSmokeCount = 0

addEvent("onClientVehicleDoorOpenRatioChange",true)
addEventHandler("onClientVehicleDoorOpenRatioChange",root,function(old,new)
	if isTimeMachine(source) then
		if old == 0 and new ~= 0 then
			local sounds = playSound3D("sounds/door_open.ogg",0,0,0)
			setSoundMaxDistance(sounds,100)
			setElementDimension(sounds,getElementDimension(source))
			attachElements(sounds,source)
		end
		if old ~= 0 and new == 0 then
			local sounds = playSound3D("sounds/door_close.ogg",0,0,0)
			setSoundMaxDistance(sounds,100)
			setElementDimension(sounds,getElementDimension(source))
			attachElements(sounds,source)
		end
	end
end)

addEventHandler("onClientRender",root,function()
	local dimens = getElementDimension(localPlayer)
	for k,car in ipairs(getElementsByType("vehicle")) do
		local dimen = getElementDimension(car)
		if dimen == dimens then
			for i=2,5 do
				local olddoorv = getElementData(car,"doorstate"..(i-1).."")
				local newdoorv = getVehicleDoorOpenRatio(car,i)
				if not olddoorv then
					setElementData(car,"doorstate"..(i-1).."",newdoorv,false)
				else
				if olddoorv ~= newdoorv then
					triggerEvent("onClientVehicleDoorOpenRatioChange",car,olddoorv,newdoorv)
					setElementData(car,"doorstate"..(i-1).."",newdoorv,false)
					end
				end
			end
		end
		if isTimeMachine(car) then
			if getElementModel(car) == 466 and getElementData(car,"ven") and dimen == dimens then
				local ven1 = getElementData(car,"ven1")
				local ven2 = getElementData(car,"ven2")
				if isElement(ven1) then
					local x,y,z = getPositionFromElementOffset(car,-0.4,-2.1,0.4)
					local rx,ry,rz = getElementRotation(car)
					setElementPosition(ven1,x,y,z)
					setElementRotation(ven1,rx-80,ry,-rz)
				else
					local x,y,z = getPositionFromElementOffset(car,-0.4,-2.1,0.4)
					local rx,ry,rz = getElementRotation(car)
					local ven1 = createEffect("extinguisher",x,y,z)
					setElementData(car,"ven1",ven1,false)
					setEffectDensity(ven1,2)
					setEffectSpeed(ven1,0.8)
					local sounds = playSound3D("sounds/vent.ogg",0,0,0)
					setSoundMaxDistance(sounds,100)
					setElementDimension(sounds,dimen)
					attachElements(sounds,car,0,-1,0)
				end
				if isElement(ven2) then
					local x,y,z = getPositionFromElementOffset(car,0.4,-2.1,0.4)
					local rx,ry,rz = getElementRotation(car)
					setElementPosition(ven2,x,y,z)
					setElementRotation(ven2,rx-80,ry,-rz)
				else
					local x,y,z = getPositionFromElementOffset(car,-0.4,-2.1,0.4)
					local rx,ry,rz = getElementRotation(car)
					local ven2 = createEffect("extinguisher",x,y,z)
					setElementData(car,"ven2",ven2,false)
					setEffectDensity(ven2,2)
					setEffectSpeed(ven2,0.8)
				end
			else
				if isElement(getElementData(car,"ven1")) then
					setElementPosition(getElementData(car,"ven1"),0,0,100000)
					setTimer(function(effect)
						if isElement(effect) then
							destroyElement(effect)
						end
					end,1000,1,getElementData(car,"ven1"))
					setElementData(car,"ven1",false,false)
				end
				if isElement(getElementData(car,"ven2")) then
					setElementPosition(getElementData(car,"ven2"),0,0,100000)
					setTimer(function(effect)
						if isElement(effect) then
							destroyElement(effect)
						end
					end,1000,1,getElementData(car,"ven2"))
					setElementData(car,"ven2",false)
				end
			end
			if getElementData(car,"coolSmoke") and dimen == dimens then
				for k,v in ipairs(coolSmokePos) do
					local x,y,z = getPositionFromElementOffset(car,v[1],v[2],v[3])
					local effect = getElementData(car,"smoke"..k.."")
					if not isElement(effect) then
						effect = createEffect("vent2",x,y,z,180,0,0)
						setEffectDensity(effect,0.3)
						setElementData(car,"smoke"..k.."",effect,false)
					else
						setElementPosition(effect,x,y,z)
					end
				end
				if not isElement(getElementData(car,"coldsound")) then
					local sound = playSound3D("sounds/cold.ogg",0,0,0,true)
					setSoundMaxDistance(sound,70)
					attachElements(sound,car)
					setElementDimension(sound,dimen)
					setElementData(car,"coldsound",sound,false)
				end
			else
				for i=1,#coolSmokePos do
					local effect = getElementData(car,"smoke"..i.."")
					if isElement(effect) then
						destroyElement(effect)
					end
				end
				local msound = getElementData(car,"coldsound")
				if isElement(msound) then
					destroyElement(msound)
				end
			end
		end
		local myrcped = getElementData(localPlayer,"rcped")
		if isElement(myrcped) then
			local health = getElementHealth(myrcped)
			setElementHealth(localPlayer,health)
		end
	end

end)
	
function explodexx(car)
	local x,y,z = getElementPosition(car)
	createExplosion(x,y,z,0,false,0,false)
	createExplosion(x,y,z,0,false,0,false)
	createExplosion(x,y,z,0,false,0,false)
	createExplosion(x,y,z,0,false,0,false)
end
addEvent("letExplode",true)
addEventHandler("letExplode",root,explodexx)

function HandleTheRender (thePlayer)
	if thePlayer == localPlayer then
		if isTimer(timer) then
			killTimer(timer)
		end
		local car = getPedOccupiedVehicle(localPlayer)
		if isTimeMachine(car) then
			if getElementData(car,"mrf") ~= 1 then
				emptyd(car)
			else
				setElementData(car,"pemptystate",false)
			end
			timer = setTimer(function()
				setElementData(localPlayer,"colon",not getElementData(localPlayer,"colon"))
			end,500,0)
		end
	end
end
addEventHandler("onClientVehicleEnter",root,HandleTheRender)

function emptyd(car)
	if isPedInVehicle(localPlayer) and not getElementData(car,"emptystate") then
		if isElement(emptysound) then
			destroyElement(emptysound)
		end
		emptysound = playSound("sounds/empty.ogg")
		emptycount = 0
		setElementData(car,"pemptystate",true)
		if isTimer(bttfempty) then
			killTimer(bttfempty)
		end
		bttfempty = setTimer(function(car)
			if isPedInVehicle(localPlayer) then
				setElementData(car,"pemptystate",not getElementData(car,"pemptystate"))
				emptycount = emptycount + 1
				if emptycount >= 6 then
					killTimer(bttfempty)
				end
			else
				if isTimer(bttfempty) then
					killTimer(bttfempty)
				end
			end
		end,400,0,source)
	end
end
addEvent("emptyd",true)
addEventHandler("emptyd",root,emptyd)

setTimer(function()
	setMinuteDuration(999999999)
	local dimen = getElementDimension(localPlayer)
	local year = BttfYearIndex[dimen]
	local yearData = TC_Year[year]
	if yearData then
		local hour,minute = getTime()
		local d_hour,d_min = tonumber(yearData[4]),tonumber(yearData[5])
		if d_hour and d_min then
			local d_hour = yearData[6] == "AM" and d_hour or d_hour+12
			if hour ~= d_hour or minute ~= d_min then
				setTime(d_hour,d_min)
			end
			BttfYearWeather[year] = BttfYearWeather[year] or 0
			if getWeather() ~= BttfYearWeather[year] then
				setWeather(BttfYearWeather[year])
			end
		end
	end
end,50,0)

--BG,Text
DSpeedColor = {tocolor(110,10,10,50),tocolor(220,20,20,255)}
--Future,Current,Past
TC_Color = {tocolor(220,0,0,255),tocolor(0,220,0,255),tocolor(200,80,0,255)}
TC_Year = {}
TC_Year[1885] = {"SEP","02","1885","08","00","AM"}
TC_Year[1955] = {"NOV","12","1955","10","04","PM"}
TC_Year[1985] = {"OCT","26","1985","01","21","AM"}
TC_Year[2015] = {"OCT","21","2015","04","30","AM"}
TC_Year[1998] = {"FEB","11","1998","11","00","PM"}
TC_Year[-1] = {"---","--","----","--","--","AM"}
TC_YearPosY = {8,53,98}
TC_YearPosX = {6,58,96,169,208}
local shader = dxCreateShader("tp.fx")
engineApplyShaderToWorldTexture(shader,"tempdisplay")
local TCD = dxCreateRenderTarget(245,135)
dxSetShaderValue(shader,"gTexture",TCD)
dxSetShaderTransform(shader,0,70,0)
function keydisp()
	local car = getPedOccupiedVehicle(localPlayer)
	if not isElement(car) then
		if isTimer(bttfempty) then
			stopSound(emptysound)
			killTimer(bttfempty)
		end
		return
	end
	local sx,sy,sz = getElementVelocity (car)
	local mph = math.floor(((sx^2 + sy^2 + sz^2)^(0.5))*111.847)
	if isTimeMachine(car) then
		if getElementData(car,"pemptystate") then
			dxDrawImageSection(sW*0.75,sH*0.68,sW*0.06,sH*0.06,0,40,70,40, "empty.png" )
		else
			dxDrawImageSection(sW*0.75,sH*0.68,sW*0.06,sH*0.06,0,0,70,40,"empty.png" )
		end
		dxDrawImage(sW*0.84,sH*0.68,sW*0.1,sH*0.08,'speedo3d.png')
		dxSetRenderTarget(TCD,true)
		local tpx,tpy = 245,135
		dxDrawImage(0,0,tpx,tpy,'TCD.png')
		if getElementData(car,"trt") == 1 then
			--Destination
			local furtureYear = getElementData(car,"year")
			local tcYear = TC_Year[furtureYear] or TC_Year[-1]
			if tcYear then
				for i=1,5 do
					local v = tcYear[i]
					dxDrawText(v,TC_YearPosX[i],TC_YearPosY[1],sW,sH,TC_Color[1],0.5464,0.5376,ds)
				end
			end
			--Current
			local dime = getElementDimension(car)
			local year = BttfYearIndex[dime]
			local tcYear = TC_Year[year] or TC_Year[-1]
			if tcYear then
				for i=1,5 do
					local v = tcYear[i]
					dxDrawText(v,TC_YearPosX[i],TC_YearPosY[2],sW,sH,TC_Color[2],0.5464,0.5376,ds)
				end
			end
			
			--Past
			local dime = getElementData(car,"oyear")
			local year = BttfYearIndex[dime]
			local tcYear = TC_Year[year] or TC_Year[-1]
			if year and tcYear then
				for i=1,5 do
					local v = tcYear[i]
					dxDrawText(v,TC_YearPosX[i],TC_YearPosY[3],sW,sH,TC_Color[3],0.5464,0.5376,ds)
				end
			end
		end
		dxSetRenderTarget()
		dxDrawImage(sW*0.75,sH*0.77,sW*0.19,sH*0.18,TCD)
		dxDrawText(8,sW*0.9145,sH*0.687,sW,sH,DSpeedColor[1],sW*0.0006,sH*0.0012,ds)
		dxDrawText(8,sW*0.8935,sH*0.687,sW,sH,DSpeedColor[1],sW*0.0006,sH*0.0012,ds)
		dxDrawText(8,sW*0.872,sH*0.687,sW,sH,DSpeedColor[1],sW*0.0006,sH*0.0012,ds)
		if mph < 10 then
			dxDrawText(mph,sW*0.9145,sH*0.687,sW,sH,DSpeedColor[2],sW*0.0006,sH*0.0012,ds)
		else
			if mph >= 10 and mph < 100 then
				mphs = math.floor(mph*0.1)
				dxDrawText(mphs,sW*0.8935,sH*0.687,sW,sH,DSpeedColor[2],sW*0.0006,sH*0.0012,ds)
				mphs = mph-(math.floor(mph*0.1))*10
				dxDrawText(mphs,sW*0.9145,sH*0.687,sW,sH,DSpeedColor[2],sW*0.0006,sH*0.0012,ds)
			else
				if mph >= 100 then
					mpha = math.floor(mph*0.01)*100
					mphs = math.floor(mph*0.01)
					dxDrawText(mphs,sW*0.872,sH*0.687,sW,sH,DSpeedColor[2],sW*0.0006,sH*0.0012,ds)
					mphs = math.floor((mph-mpha)*0.1)
					dxDrawText(mphs,sW*0.8935,sH*0.687,sW,sH,DSpeedColor[2],sW*0.0006,sH*0.0012,ds)
					mphs = mph-mpha-(math.floor((mph-mpha)*0.1))*10
					dxDrawText(mphs,sW*0.9145,sH*0.687,sW,sH,DSpeedColor[2],sW*0.0006,sH*0.0012,ds)
				end
			end
		end
	end
	local isboost = getElementData(car,"boosted")
	if isboost == 1 then
		local rX,rY,rZ = getElementRotation(car)
		local cvx,cvy,cvz = getElementVelocity(car)
		local xcvx,xcvy = -math.sin(math.rad(rZ)),math.cos(math.rad(rZ))
		setElementVelocity(car,cvx+xcvx*((1/(mph+5))^0.5)*0.02,cvy+xcvy*((1/(mph+5))^0.5)*0.02,cvz)
	elseif isboost == 2 then
		local rX,rY,rZ = getElementRotation(car)
		local cvx,cvy,cvz = getElementVelocity(car)
		local xcvx,xcvy = -math.sin(math.rad(rZ)),math.cos(math.rad(rZ))
		setElementVelocity(car,cvx-xcvx*(1/(mph+5))*0.04,cvy-xcvy*(1/(mph+5))*0.04,cvz)
	end

end
addEventHandler("onClientRender",root,keydisp)

bindKey("tab","down",function()
	local target = getPedTarget(localPlayer)
	if isElement(target) then
		if getElementType(target) == "vehicle" then
			if isTimeMachine(target) then
				local x,y,z = getPositionFromElementOffset(target,0,-2.5,0)
				local px,py,pz = getElementPosition(localPlayer)
				local distance = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
				if getElementDimension(target) == getElementDimension(localPlayer) then
					if distance <= 0.8 then
						if getElementData(target,"mrf") ~= 1 then
							triggerServerEvent("onBTTFAddMrFusion",localPlayer,target)
						end
					end
				end
			end
		end
	end
end)


local vehlight = dxCreateShader("tp.fx")
local vehlighton = dxCreateTexture("vehlighton.png")
dxSetShaderValue(vehlight,"gTexture",vehlighton)
local streamedInVeh = {}
addEventHandler( "onClientElementStreamIn",root,function ( )
	if getElementType( source ) == "vehicle" then
		if getElementModel(source) == 488 then
			local id = table.find(streamedInVeh,source)
			if not id then
				table.insert(streamedInVeh,source)
				if getVehicleOverrideLights(source) == 1 then
					engineRemoveShaderFromWorldTexture(vehlight,"vehiclelights128",source)
					local lights = getElementData(source,"isApplyed")
					if lights then
						for k,v in pairs(lights) do
							corona:destroyCorona(v)
						end
					end
					setElementData(source,"isApplyed",false,false)
				elseif getVehicleOverrideLights(source) == 2 then
					engineApplyShaderToWorldTexture(vehlight,"vehiclelights128",source)
					createLightForBTTF2(source)
				end
			end
		end
	end
end)

function createLightForBTTF2(veh)
	local lights = {}
	lights[-1] = createLight(1,0,0,0,3,255,255,255,0,0,0,true)
	lights[-2] = createLight(1,0,0,0,3,255,255,255,0,0,0,true)
	lights[1] = corona:createCorona(0,0,0,0.16,255,255,255,255)
	lights[2] = corona:createCorona(0,0,0,0.16,255,255,255,255)
	lights[3] = corona:createCorona(0,0,0,0.1,255,0,0,190)
	lights[4] = corona:createCorona(0,0,0,0.1,255,0,0,190)
	lights[5] = corona:createCorona(0,0,0,0.4,255,255,0,200)
	lights[6] = corona:createCorona(0,0,0,0.4,255,255,0,200)
	lights[7] = corona:createCorona(0,0,0,0.4,255,255,0,200)
	lights[8] = corona:createCorona(0,0,0,0.4,255,255,0,200)
	setElementData(veh,"isApplyed",lights,false)
	return lights
end

addEventHandler( "onClientElementStreamOut",root,function ( )
	if getElementType( source ) == "vehicle" then
		if getElementModel(source) == 488 then
			local id = table.find(streamedInVeh,source)
			if id then
				table.remove(streamedInVeh,id)
				if getVehicleOverrideLights(source) == 1 then
					engineRemoveShaderFromWorldTexture(vehlight,"vehiclelights128",source)
					local lights = getElementData(source,"isApplyed")
					if lights then
						for k,v in pairs(lights) do
							corona:destroyCorona(v)
						end
					end
					setElementData(source,"isApplyed",false,false)
				--[[elseif getVehicleOverrideLights(source) == 2 then
					engineApplyShaderToWorldTexture(vehlight,"vehiclelights128",source)
					local lights = {}
					lights[-1] = createLight(1,0,0,0,3,255,255,255,0,0,0,true)
					lights[-2] = createLight(1,0,0,0,3,255,255,255,0,0,0,true)
					
					lights[1] = corona:createCorona(0,0,0,0.2,255,255,255,255)
					lights[2] = corona:createCorona(0,0,0,0.2,255,255,255,255)
					
					lights[3] = corona:createCorona(0,0,0,0.2,255,0,0,255)
					lights[4] = corona:createCorona(0,0,0,0.2,255,0,0,255)
					
					lights[5] = corona:createCorona(0,0,0,0.4,255,255,0,200)
					lights[6] = corona:createCorona(0,0,0,0.4,255,255,0,200)
					lights[7] = corona:createCorona(0,0,0,0.4,255,255,0,200)
					lights[8] = corona:createCorona(0,0,0,0.4,255,255,0,200)
					setElementData(source,"isApplyed",lights,false)]]
				end
			end
		end
	end
end)

addEventHandler("onClientElementDestroy",root,function()
	if getElementType( source ) == "vehicle" then
		if getElementModel(source) == 488 then
			local id = table.find(streamedInVeh,source)
			if id then
				table.remove(streamedInVeh,id)
			end
			engineRemoveShaderFromWorldTexture(vehlight,"vehiclelights128",source)
			local lights = getElementData(source,"isApplyed")
			if lights then
				corona:destroyCorona(lights[1])
				corona:destroyCorona(lights[2])
			end
		end
	end
end)

addEventHandler("onClientPreRender",root,function()
	for i=1,#streamedInVeh do
		local veh = streamedInVeh[i]
		if isElement(veh) then
			local lights = getElementData(veh,"isApplyed")
			if getVehicleOverrideLights(veh) == 1 or getElementModel(veh) ~= 488 then
				if lights then
					engineRemoveShaderFromWorldTexture(vehlight,"vehiclelights128",veh)
					for k,v in pairs(lights) do
						corona:destroyCorona(v)
					end
					setElementData(veh,"isApplyed",false,false)
				end
			elseif getVehicleOverrideLights(veh) == 2 then
				if not lights then
					engineApplyShaderToWorldTexture(vehlight,"vehiclelights128",veh)
					lights = createLightForBTTF2(veh)
				end
				local matrix = veh.matrix
				local posL = matrix:transformPosition(Vector3(0.72,2.25,-0.03))
				local posR = matrix:transformPosition(Vector3(-0.72,2.25,-0.03))
				
				corona:setCoronaPosition(lights[1],posL.x,posL.y,posL.z)
				corona:setCoronaPosition(lights[2],posR.x,posR.y,posR.z)
				setElementPosition(lights[-1],posL.x,posL.y,posL.z)
				setElementPosition(lights[-2],posR.x,posR.y,posR.z)
				
				setLightDirection(lights[-1],0,1,0)
				setLightDirection(lights[-2],0,1,0)
				
				lights[-1].dimension = veh.dimension
				lights[-2].dimension = veh.dimension
				
				local posL_back = matrix:transformPosition(Vector3(0.52,-2.25,0.2))
				local posR_back = matrix:transformPosition(Vector3(-0.52,-2.25,0.2))
				corona:setCoronaPosition(lights[3],posL_back.x,posL_back.y,posL_back.z)
				corona:setCoronaPosition(lights[4],posR_back.x,posR_back.y,posR_back.z)
				
				local wheel_lf = matrix:transformPosition(Vector3(1.1,1.35,-0.4))
				local wheel_rf = matrix:transformPosition(Vector3(-1.1,1.35,-0.4))
				local wheel_lb = matrix:transformPosition(Vector3(1.1,-1.3,-0.4))
				local wheel_rb = matrix:transformPosition(Vector3(-1.1,-1.3,-0.4))
				corona:setCoronaPosition(lights[5],wheel_lf.x,wheel_lf.y,wheel_lf.z)
				corona:setCoronaPosition(lights[6],wheel_rf.x,wheel_rf.y,wheel_rf.z)
				corona:setCoronaPosition(lights[7],wheel_lb.x,wheel_lb.y,wheel_lb.z)
				corona:setCoronaPosition(lights[8],wheel_rb.x,wheel_rb.y,wheel_rb.z)
			end
		else
			table.remove(streamedInVeh,i)
		end
		corona = exports.corona
	end
end)