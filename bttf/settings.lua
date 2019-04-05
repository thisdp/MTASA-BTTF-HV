timeMachine = {[451]="BTTF1",[541]="BTTF2",[488]="BTTF2_Fly",[467]="BTTF3",[415]="BTTF3R"}
timeMachineType = {["BTTF1"] = 1,["BTTF2"] = 1,["BTTF2_Fly"] = 1,["BTTF3"] = 2,["BTTF3R"] = 2}
BttfYearDimen = {[1885]=0,[1955]=2,[1985]=3,[2015]=4}
BttfYearWeather = {[1885]=18,[1955]=8,[1985]=0,[2015]=16}
BttfYearIndex = {}
for k,v in pairs(BttfYearDimen) do
	BttfYearIndex[v] = k
end

function table.find(tab,value)
	for k,v in pairs(tab) do
		if v == value then
			return k
		end
	end
end

function isTimeMachine(vehicle)
	if isElement(vehicle) then
		local model = getElementModel(vehicle)
		return timeMachine[model] or false
	end
	return false
end

function getTimeMachineType(theType)
	return timeMachineType[theType] or false
end
