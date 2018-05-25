ESX               			= nil
local ItemsLabels 			= {}
local PlayersAssemblyAK    	= {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('onMySQLReady', function()

	MySQL.Async.fetchAll(
		'SELECT * FROM items',
		{},
		function(result)

			for i=1, #result, 1 do
				ItemsLabels[result[i].name] = result[i].label
			end--

		end
	)

end)

ESX.RegisterServerCallback('esx_illshops:requestDBItems', function(source, cb)

	MySQL.Async.fetchAll(
		'SELECT * FROM illegal_shops',
		{},
		function(result)

			local shopItems  = {}

			for i=1, #result, 1 do

				if shopItems[result[i].name] == nil then
					shopItems[result[i].name] = {}
				end

				table.insert(shopItems[result[i].name], {
					name  = result[i].item,
					price = result[i].price,
					label = ItemsLabels[result[i].item],
					drug =  result[i].drug,
					drugqte = result[i].drugqte
				})

			end

			cb(shopItems)

		end
	)

end)

RegisterServerEvent('esx_illshops:buyItem')
AddEventHandler('esx_illshops:buyItem', function(itemName, price, drug, drugqte)

	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(source)
	local account = xPlayer.getAccount('black_money')
	local drugQuantity = xPlayer.getInventoryItem(drug).count

	if account.money >= price then
		
		if drugQuantity >= drugqte then
		    
		    xPlayer.removeInventoryItem(drug, drugqte)
			xPlayer.removeAccountMoney('black_money', price)
			xPlayer.addInventoryItem(itemName, 1)
			TriggerClientEvent('esx:showNotification', _source, _U('bought') .. ItemsLabels[itemName])
		else
			
			TriggerClientEvent('esx:showNotification', _source, _U('not_enough_drug') .. drug)
		end
	else
		TriggerClientEvent('esx:showNotification', _source, _U('not_enough'))
	end

end)

-----------------------------------------------------------------------------------------------

local function AssemblyAK(source)

		SetTimeout(10000, function()

		if PlayersAssemblyAK[source] == true then

			local xPlayer  = ESX.GetPlayerFromId(source)

			local AK1Quantity = xPlayer.getInventoryItem('AK74_1').count
			local AK2Quantity = xPlayer.getInventoryItem('AK74_2').count
			local AK3Quantity = xPlayer.getInventoryItem('AK74_3').count

			if AK1Quantity >= 1 and AK2Quantity >= 1 and  AK3Quantity >= 1 then
			
				xPlayer.removeInventoryItem('AK74_1', 1)
				xPlayer.removeInventoryItem('AK74_2', 1)
				xPlayer.removeInventoryItem('AK74_3', 1)
				xPlayer.addInventoryItem('AK74_full', 1)
			
				AssemblyAK(source)
			else
				TriggerClientEvent('esx:showNotification', source, _U('missing_part'))
			end

		end
	end)
end

RegisterServerEvent('esx_illweapon:startAssemblyAK')
AddEventHandler('esx_illweapon:startAssemblyAK', function()

	local _source = source

	PlayersAssemblyAK[_source] = true

	TriggerClientEvent('esx:showNotification', _source, _U('assembly_in_prog'))

	AssemblyAK(source)

end)

RegisterServerEvent('esx_illweapon:stopAssemblyAK')
AddEventHandler('esx_illweapon:stopAssemblyAK', function()

	local _source = source

	PlayersAssemblyAK[_source] = false

end)

-- RETURN INVENTORY TO CLIENT
RegisterServerEvent('esx_illweapon:GetUserInventory')
AddEventHandler('esx_illweapon:GetUserInventory', function(currentZone)
	local _source = source
    local xPlayer  = ESX.GetPlayerFromId(_source)
    TriggerClientEvent('esx_illweapon:ReturnInventory', 
    	_source, 
    	xPlayer.getInventoryItem('AK74_1').count, 
		xPlayer.getInventoryItem('AK74_2').count, 
		xPlayer.getInventoryItem('AK74_3').count, 
		xPlayer.getInventoryItem('AK74_full').count, 
		currentZone
    )
end)

------------------------------------------------------------------------------------------------------------------

-- Register Usable Item

ESX.RegisterUsableItem('AK74_full', function(source)

	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('AK74_full', 1)
	xPlayer.addWeapon('WEAPON_ASSAULTRIFLE',30)
	TriggerClientEvent('esx:showNotification', _source, _U('used_one_AK'))

end)
