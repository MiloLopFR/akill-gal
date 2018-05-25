local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}


ESX                           = nil
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}

local AK1QTE					= 0
local AK2QTE					= 0
local AK3QTE					= 0
local AKFULLQTE					= 0





Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

AddEventHandler('onClientMapStart', function()

	ESX.TriggerServerCallback('esx_illshops:requestDBItems', function(ShopItems)
		for k,v in pairs(ShopItems) do
			Config.Zones[k].Items = v
		end
	end)
	
end)

function OpenShopMenu(zone)

	local elements = {}

	for i=1, #Config.Zones[zone].Items, 1 do

		local item = Config.Zones[zone].Items[i]

		table.insert(elements, {
			label     = item.label .. ' - <span style="color:red;">$' .. item.price .. ' et '.. item.drugqte .. ' de ' .. item.drug ..' </span>',
			realLabel = item.label,
			value     = item.name,
			price     = item.price,
			drug 	  = item.drug,	
			drugqte   = item.drugqte
		})

	end


	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'illshop',
		{
			title  = _U('illshop'),
			elements = elements
		},
		function(data, menu)
			TriggerServerEvent('esx_illshops:buyItem', data.current.value, data.current.price, data.current.drug, data.current.drugqte)
		end,
		function(data, menu)

			menu.close()

			CurrentAction     = 'illshop_menu'
			CurrentActionMsg  = _U('press_menu')
			CurrentActionData = {zone = zone}
		end
	)
end

AddEventHandler('esx_illshops:hasEnteredMarker', function(zone)

	CurrentAction     = 'illshop_menu'
	CurrentActionMsg  = _U('press_menu')
	CurrentActionData = {zone = zone}

end)

AddEventHandler('esx_illshops:hasExitedMarker', function(zone)

	CurrentAction = nil
	ESX.UI.Menu.CloseAll()

end)

-- Create Blips
--[[Citizen.CreateThread(function()
	for k,v in pairs(Config.Zones) do
  	for i = 1, #v.Pos, 1 do
		local blip = AddBlipForCoord(v.Pos[i].x, v.Pos[i].y, v.Pos[i].z)
		SetBlipSprite (blip, 52)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 1.0)
		SetBlipColour (blip, 2)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U('illshops'))
		EndTextCommandSetBlipName(blip)
		end
	end
end)]]

-- Display markers
Citizen.CreateThread(function()
  while true do
    Wait(0)
    local coords = GetEntityCoords(GetPlayerPed(-1))
    for k,v in pairs(Config.Zones) do
      for i = 1, #v.Pos, 1 do
        if(Config.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, true) < Config.DrawDistance) then
          DrawMarker(Config.Type, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Size.x, Config.Size.y, Config.Size.z, Config.Color.r, Config.Color.g, Config.Color.b, 100, false, true, 2, false, false, false, false)
        end
      end
    end
	for l,w in pairs(Config.factory) do
      for i = 1, #w.Pos, 1 do
        if(Config.TypeFactory ~= -1 and GetDistanceBetweenCoords(coords, w.Pos[i].x, w.Pos[i].y, w.Pos[i].z, true) < Config.DrawDistance) then
          DrawMarker(Config.TypeFactory, w.Pos[i].x, w.Pos[i].y, w.Pos[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.SizeFactory.x, Config.SizeFactory.y, Config.SizeFactory.z, Config.ColorFactory.r, Config.ColorFactory.g, Config.ColorFactory.b, 100, false, true, 2, false, false, false, false)
        end
      end
    end

  end
  
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Wait(0)
		local coords      = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker  = false
		local currentZone = nil

		for k,v in pairs(Config.Zones) do
			for i = 1, #v.Pos, 1 do
				if(GetDistanceBetweenCoords(coords, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, true) < Config.Size.x) then
					isInMarker  = true
					ShopItems   = v.Items
					currentZone = k
					LastZone    = k
				end
			end
		end
		if isInMarker and not HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = true
			TriggerEvent('esx_illshops:hasEnteredMarker', currentZone)
		end
		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_illshops:hasExitedMarker', LastZone)
		end
		
	end
end)

-- Key Controls
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if CurrentAction ~= nil then

      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)

      if IsControlJustReleased(0, 38) then

        if CurrentAction == 'illshop_menu' then
          OpenShopMenu(CurrentActionData.zone)
        end

        CurrentAction = nil

      end

    end
  end
end)


------------------------------------------------------------------------------------------------------------------


-- Activate menu when player is inside marker
Citizen.CreateThread(function()
    while true do

        Wait(0)

        local coords      = GetEntityCoords(GetPlayerPed(-1))
        local isInMarker  = false
        local currentZone = nil

     for k,v in pairs(Config.factory) do
			for i = 1, #v.Pos, 1 do
				if(GetDistanceBetweenCoords(coords, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, true) < Config.Size.x) then
					isInMarker  = true
					currentZone = k
					
				end
			end
		end

        if isInMarker and not hasAlreadyEnteredMarker then
            hasAlreadyEnteredMarker = true
            lastZone                = currentZone
            TriggerServerEvent('esx_illweapon:GetUserInventory', currentZone)
        end

        if not isInMarker and hasAlreadyEnteredMarker then
            hasAlreadyEnteredMarker = false
            TriggerEvent('esx_illweapon:hasExitedMarker', lastZone)
        end

    end
end)

AddEventHandler('esx_illweapon:hasEnteredMarker', function(zone)

        ESX.UI.Menu.CloseAll()

        --AK
		 if zone == 'illweapon_factoryAK' then
                if AK1QTE >= 1 and AK2QTE >= 1 and AK3QTE >= 1 then
					CurrentAction     = 'ak_assembly'
					CurrentActionMsg  = _U('press_assembly_ak')
					CurrentActionData = {}
                end
            
        end

end)

AddEventHandler('esx_illweapon:hasExitedMarker', function(zone)

        CurrentAction = nil
        ESX.UI.Menu.CloseAll()

        TriggerServerEvent('esx_illweapon:stopAssemblyAK')

end)

-- RETURN NUMBER OF ITEMS FROM SERVER
RegisterNetEvent('esx_illweapon:ReturnInventory')
AddEventHandler('esx_illweapon:ReturnInventory', function(AK1Nbr, AK2Nbr, AK3Nbr, AKFULLnbr, currentZone)
    AK1QTE       = AK1Nbr
	AK2QTE       = AK2Nbr
	AK3QTE       = AK3Nbr
	AKFULLQTE	 = AKFULLnbr
	TriggerEvent('esx_illweapon:hasEnteredMarker', currentZone)
end)

-- Key Controls
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if CurrentAction ~= nil then
            SetTextComponentFormat('STRING')
            AddTextComponentString(CurrentActionMsg)
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            if IsControlJustReleased(0, 38) then
                if CurrentAction == 'ak_assembly' then
                    TriggerServerEvent('esx_illweapon:startAssemblyAK')
                end
			end
		end
	end
end)

