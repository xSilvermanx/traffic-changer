--GetNameOfZone
--GetStreetNameAtCoord
--GetStreetNameFromhashKey

HighwayList={
	"Los Santos Freeway",
	"Los Santos Fwy",
	"Del Perro Fwy",
	"Del Perro Freeway",
	"Elysian Fields Fwy",
	"Elysian Fields Freeway",
	"Palomino Fwy",
	"Palomino Freeway",
	"Senora Fwy",
	"Senora Freeway",
	"Great Ocean Hwy",
	"Great Ocean Highway",
	"La Puerta Fwy",
	"La Puerta Freeway",
	"Olympic Fwy",
	"Olympic Freeway",
	"Route 68",
}

CountyList={
	"ALAMO",
	"ARMYB",
	"BANHAMC",
	"BHAMCA",
	"BRADP",
	"BRADT",
	"CALAFB",
	"CANNY",
	"CCREAK",
	"CHU",
	"CMSW",
	"DESRT",
	"ELGORL",
	"GALFISH",
	"GRAPES",
	"GREATC",
	"HARMO",
	"HUMLAB",
	"JAIL",
	"LACT",
	"LAGO",
	"LDAM",
	"MTCHIL",
	"MTGORDO",
	"MTJOSE",
	"NCHU",
	"OCEANA",
	"PALCOV",
	"PALETO",
	"PALFOR",
	"PALMPOW",
	"PROCOB",
	"RTRAK",
	"SANCHIA",
	"SANDY",
	"SLAB",
	"TATAMO",
	"TONGVAH",
	"TONGVAV",
	"WINDF",
	"ZANCUDO",
	"ZQ_UAR",
}

Models={
	"police",
	"police2",
	"police3",
	"sheriff",
	"sheriff2",
}

ModelsHighway={
	"hwaycar5",
	"hwaycar13",
	"hwaycar15",
	"hwaycar12",
}

ModelsCounty={
	"sheriff",
	"sheriff2",
	"fbi2",
	"police",
	"police2",
	"police3",
}

ModelsCity={
	"lspd2",
	"lspd",
	"lspd3",
	"lspd9",
	"lspd8",
}

local entityEnumerator = {
  __gc = function(enum)
    if enum.destructor and enum.handle then
      enum.destructor(enum.handle)
    end
    enum.destructor = nil
    enum.handle = nil
  end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
  return coroutine.wrap(function()
    local iter, id = initFunc()
    if not id or id == 0 then
      disposeFunc(iter)
      return
    end
    
    local enum = {handle = iter, destructor = disposeFunc}
    setmetatable(enum, entityEnumerator)
    
    local next = true
    repeat
      coroutine.yield(id)
      next, id = moveFunc(iter)
    until not next
    
    enum.destructor, enum.handle = nil, nil
    disposeFunc(iter)
  end)
end

function EnumerateObjects()
  return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
  return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
  return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
  return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end

local function isempty(s)
	return s == nil or s ==''
end

CreateThread(function()
	local spawnedcars = {}
	local hwyflag = true
	local countyflag = true
	local foundflag = true
	local changeflag = true
	
	while true do
		for car in EnumerateVehicles() do
			if isempty(IsVehicleNeonLightEnabled(car, 2)) then
				changeflag = true
			elseif IsVehicleNeonLightEnabled(car, 2) == 1 then
				changeflag = false
			end		
			if changeflag then
				SetVehicleNeonLightEnabled(vehicle, 2, true)
				local carmodel = GetEntityModel(car)
				for m, policemodel in ipairs(Models) do
					if GetHashKey(policemodel) == carmodel and foundflag then
						foundflag = false
						local carlocation = GetEntityCoords(car)
						local locx, locy, locz = table.unpack(carlocation)
						local streetname = GetStreetNameFromHashKey(GetStreetNameAtCoord(locx, locy, locz))
						for i,highwayname in ipairs(HighwayList) do
							if hwyflag and streetname == highwayname then
								hwyflag = false
							end
						end
						for k,countyname in ipairs(CountyList) do
							if hwyflag and countyflag and IsEntityInZone(car, countyname) then
								countyflag = false
							end
						end
					end
				end
				
				if not foundflag then
					if not hwyflag then
						RespawnCar(car, 'Highway')
					elseif not countyflag then
						RespawnCar(car, 'County')
					else
						RespawnCar(car, 'City')
					end
				end
				foundflag = true
				countyflag = true
				hwyflag = true
			end
		changeflag = true
		end
		Wait(1000)	
	end
end)



function RespawnCar(car, area)
	
	local carmodel = GetEntityModel(car)
	local carlocation = GetEntityCoords(car)
	local carangle = GetEntityHeading(car)
	local ModelList = {}
	local PedList = {}
	
	if area == 'Highway' then
		ModelList = ModelsHighway
		number = math.random(1,#ModelList)
	elseif area == 'County' then
		ModelList = ModelsCounty
		number = math.random(1,#ModelList)
	else
		ModelList = ModelsCity
		number = math.random(1,#ModelList)
	end

	for i=-1,2 do
		Ped = GetPedInVehicleSeat(car, i)
		if Ped ~= nil then
			table.insert(PedList, {Ped, GetPedType(Ped), GetEntityModel(Ped), tostring(i)})
		end
	end
	
	local carx, cary, carz = table.unpack(carlocation)
	
	local model = GetHashKey(ModelList[number])
	RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(50)
    end
	
	local velocity = GetEntityVelocity(car)
	local velox, veloy, veloz = table.unpack(velocity)
	
	DeleteEntity(car)
	for i=1,4 do
		DeleteEntity(PedList[i][1])
	end
	if not IsAnyVehicleNearPoint(carx, cary, carz, 1.5) then
		local vehicle = CreateVehicle(model, carx, cary, carz, carangle, true, false)
		for i=1,4 do
			if PedList[i][2] ~= 0 then
				local officer = CreatePed(PedList[i][2], PedList[i][3], carx, cary, carz+2, carangle, true, true)
				SetPedIntoVehicle(officer, vehicle, i-2)
				SetPedAsCop(officer, true)
				if i == 1 then
					SetVehicleEngineOn(vehicle, true, true, false)
					GiveWeaponToPed(officer, GetHashKey("weapon_pistol"), 500, false, false)
					GiveWeaponToPed(officer, GetHashKey("weapon_taser"), 500, false, false)
					GiveWeaponToPed(officer, GetHashKey("weapon_nightstick"), 500, false, false)
				else
					GiveWeaponToPed(officer, GetHashKey("weapon_pistol"), 500, false, false)
					GiveWeaponToPed(officer, GetHashKey("weapon_pumpshotgun"), 500, false, false)
					GiveWeaponToPed(officer, GetHashKey("weapon_taser"), 500, false, false)
					GiveWeaponToPed(officer, GetHashKey("weapon_nightstick"), 500, false, false)
				end
				if PedList[i][2] == GetHashKey(s_m_y_swat_01) then
					GiveWeaponToPed(officer, GetHashKey("weapon_carbinerifle"), 1000, false, false)
					SetPedArmour(officer, 100)
				end
				SetPedCanSwitchWeapon(officer, true)
				SetPedAsNoLongerNeeded(officer)
			end
		end
		SetEntityVelocity(vehicle, velox, veloy, veloz)
		SetVehicleNeonLightEnabled(vehicle, 2, true)
		SetVehicleAsNoLongerNeeded(vehicle)
	end
	
	PedList = {}
end
