Framework = nil

createdChars = {}
local charPed = nil
local randommodels = {"mp_m_freemode_01","mp_f_freemode_01"}
local charactersdatas = {}
local characterdata = {}
local islogin = false
local number = 0



Citizen.CreateThread(function()
    Callback = nil
    if Config.Framework == "ESX"  then
        while Framework == nil do
            TriggerEvent('esx:getSharedObject', function(obj) Framework = obj end)
            Citizen.Wait(4)
            Callback = Framework.TriggerServerCallback
        end

    elseif Config.Framework == "ESX-Legacy" then
        while Framework == nil do
            Framework = exports['es_extended']:getSharedObject()
            Citizen.Wait(4)
            Callback = Framework.TriggerServerCallback
        end

    elseif Config.Framework == "OLDQBCore" then

        while Framework == nil do
            TriggerEvent("QBCore:GetObject", function(obj) Framework = obj end)    
            Citizen.Wait(4)
            Callback = Framework.Functions.TriggerCallback

        end
    elseif Config.Framework == "QBCore" then
        while Framework == nil do
            Framework = exports['qb-core']:GetCoreObject()
            Citizen.Wait(4)
            Callback = Framework.Functions.TriggerCallback

        end
    end
end)

CreateThread(function()
	while true do
		Wait(0)
		if NetworkIsSessionStarted() then
			TriggerEvent('qb-multi:start')
            print("Success Session Started")
			return
		end
	end
end)


RegisterNetEvent('qb-multi:start', function()
    DoScreenFadeOut(10)
    Wait(1000)
    DisplayRadar(false)
    local interior = GetInteriorAtCoords(Config.Interior.x, Config.Interior.y, Config.Interior.z - 18.9)
    LoadInterior(interior)
    while not IsInteriorReady(interior) do
        Wait(1000)
    end
    SetEntityCoords(PlayerPedId(), Config.HiddenCoords.x, Config.HiddenCoords.y, Config.HiddenCoords.z)
    SetRainFxIntensity(-1.0)
    SetTimecycleModifier('default')
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    
    FreezeEntityPosition(PlayerPedId(), true)
    SendNUIMessage({
        type = "ui",
        data = nil
    })
    skyCam(true)
    
end)



function skyCam(bool)
    TriggerEvent('qb-weathersync:client:DisableSync')
    if bool then
        DoScreenFadeIn(1000)
        SetTimecycleModifier('hud_def_blur')
        SetTimecycleModifierStrength(1.0)
        SetEntityVisible(PlayerPedId(), 0)
        SetEntityCoords(PlayerPedId(), Config.HiddenCoords.x, Config.HiddenCoords.y, Config.HiddenCoords.z)
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", Config.camcoords.x, Config.camcoords.y, Config.camcoords.z, 300.00,0.00,0.00, 110.00, false, 0)
        SetCamRot(cam, 0.0, 0.0, Config.camcoords.h, 2)
        SetCamCoord(cam, Config.camcoords.x, Config.camcoords.y, Config.camcoords.z)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, 1, 0)
    else
        SetTimecycleModifier('default')
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)
        SetEntityVisible(PlayerPedId(), 1)

    end
end

RegisterNUICallback('setupCharacters', function()
    SetTimecycleModifier('default')
    Callback('qb-kashacters:GetPlayerData', function(data, onlinetime, sayi)
        if Config.Framework == "ESX" or Config.Framework == "ESX-Legacy" then
            characterdata = {}
            number = sayi
            if number > 0 then
                if data ~= nil then
                    for k,v in pairs(data) do
                        models = nil
                        characterdata[v.identifier] = {}
                        characterdata[v.identifier] = v
                        local hours = 0
                        if onlinetime[v.identifier] ~= nil then
                            minute = onlinetime[v.identifier].gametime
                            if minute >= 60 then
                                while minute >= 60 do
                                hours =  hours + 1
                                minute = minute - 60
                                end
                            end
        
                            if hours > 0 then
                                characterdata[v.identifier].onlinetime = hours.." h "..minute.." min"
                            else
                                characterdata[v.identifier].onlinetime = minute.." min"
                            end
                        else
                            characterdata[v.identifier].onlinetime = "0 min"
                        end
        
                    end
                else
                    local randommodels = {
                        "mp_m_freemode_01",
                        "mp_f_freemode_01",
                    }
                    local model = GetHashKey(randommodels[math.random(1, #randommodels)])
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Citizen.Wait(0)
                    end
                    PedCreate(3, model, Config.CharacterCoords.x, Config.CharacterCoords.y, Config.CharacterCoords.z - 1, Config.CharacterCoords.h, false, false)
            
                end
                
        
                SendNUIMessage({
                    type = "ui",
                    data = data
                })
        
                SetDisplay(true, true)
            else
                local randommodels = {
                    "mp_m_freemode_01",
                    "mp_f_freemode_01",
                }
                local model = GetHashKey(randommodels[math.random(1, #randommodels)])
                RequestModel(model)
                while not HasModelLoaded(model) do
                    Citizen.Wait(0)
                end
                PedCreate(3, model, Config.CharacterCoords.x, Config.CharacterCoords.y, Config.CharacterCoords.z - 1, Config.CharacterCoords.h, false, false)
                SendNUIMessage({
                    type = "createui"
                })
        
                SetDisplay(true, true)
            end

        elseif Config.Framework == "QBCore" or Config.Framework == "OLDQBCore" then
            characterdata = {}
            number = sayi
            if number > 0 then
                if data ~= nil then
                    for k,v in pairs(data) do
                        char = json.decode(v.charinfo)
                        j = json.decode(v.money)
                        v.firstname = char.firstname
                        v.lastname = char.lastname
                        if char.gender == 0 then
                            v.sex = "M"
                        else
                            v.sex = "F"

                        end
                        v.dateofbirth = char.birthdate
                        bank = {
                            bank = j.bank,
                            money = j.cash
                        }
                        v.accounts = json.encode(bank)
                        v.identifier = v.citizenid
                        models = nil
                        characterdata[v.citizenid] = {}
                        characterdata[v.citizenid] = v
                        local hours = 0
                        if onlinetime[v.citizenid] ~= nil then
                            minute = onlinetime[v.citizenid].gametime
                            if minute >= 60 then
                                while minute >= 60 do
                                hours =  hours + 1
                                minute = minute - 60
                                end
                            end
        
                            if hours > 0 then
                                characterdata[v.citizenid].onlinetime = hours.." h "..minute.." min"
                            else
                                characterdata[v.citizenid].onlinetime = minute.." min"
                            end
                        else
                            characterdata[v.citizenid].onlinetime = "0 min"
                        end
        
                    end
                else
                    local randommodels = {
                        "mp_m_freemode_01",
                        "mp_f_freemode_01",
                    }
                    local model = GetHashKey(randommodels[math.random(1, #randommodels)])
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Citizen.Wait(0)
                    end
                    PedCreate(3, model, Config.CharacterCoords.x, Config.CharacterCoords.y, Config.CharacterCoords.z - 1, Config.CharacterCoords.h, false, false)
            
                end
                
        
                SendNUIMessage({
                    type = "ui",
                    data = data
                })
        
                SetDisplay(true, true)
            else
                local randommodels = {
                    "mp_m_freemode_01",
                    "mp_f_freemode_01",
                }
                local model = GetHashKey(randommodels[math.random(1, #randommodels)])
                RequestModel(model)
                while not HasModelLoaded(model) do
                    Citizen.Wait(0)
                end
                PedCreate(3, model, Config.CharacterCoords.x, Config.CharacterCoords.y, Config.CharacterCoords.z - 1, Config.CharacterCoords.h, false, false)
                SendNUIMessage({
                    type = "createui"
                })
        
                SetDisplay(true, true)
            end

        end
        
        




    end)


end)
    


local display = false

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
end
ilk = false

if Config.Framework == "ESX" or Config.Framework == "ESX-Legacy" then
    RegisterNUICallback('loadPed', function(data)
        DeleteEntity(charPed)
        charPed = nil
        if characterdata[data.id].sex == "M" then
            models = GetHashKey("mp_m_freemode_01")
        else
            models = GetHashKey("mp_f_freemode_01")
        end
        while not HasModelLoaded(models) do
            RequestModel(models)
            Citizen.Wait(1) 
        end
        PedCreate(3, models, Config.CharacterCoords.x, Config.CharacterCoords.y, Config.CharacterCoords.z - 1, Config.CharacterCoords.h, false, false)
        LoadAnim("anim@amb@nightclub@peds@")
        TaskPlayAnim(charPed, "anim@amb@nightclub@peds@", "rcmme_amanda1_stand_loop_cop", 2.0, 2.0, -1, 33, 0, false, false, false)
        
        ApplySkin(charPed, json.decode(characterdata[data.id].skin))

    
    
    end)


elseif Config.Framework == "QBCore" or Config.Framework == "OLDQBCore" then

    RegisterNUICallback('loadPed', function(data)


        DeleteEntity(charPed)
        charPed = nil
        
        Callback("qb-multicharacter:server:getSkin", function(model, data)
            model = model ~= nil and tonumber(model) or false
            if data ~= nil then
                Citizen.CreateThread(function()
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Citizen.Wait(0)
                    end
                    PedCreate(3, model, Config.CharacterCoords.x, Config.CharacterCoords.y, Config.CharacterCoords.z - 1, Config.CharacterCoords.h, false, false)
                    SetPedComponentVariation(charPed, 0, 0, 0, 2)
                    FreezeEntityPosition(charPed, false)
                    SetEntityInvincible(charPed, true)
                    PlaceObjectOnGroundProperly(charPed)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                    -- data = json.decode(data)
                     TriggerEvent('qb-clothing:client:loadPlayerClothing', data, charPed)
                    Wait(1000)
                    LoadAnim("anim@amb@nightclub@peds@")
                    TaskPlayAnim(charPed, "anim@amb@nightclub@peds@", "rcmme_amanda1_stand_loop_cop", 2.0, 2.0, -1, 33, 0, false, false, false)

                end)
            else
                Citizen.CreateThread(function()
                    local randommodels = {
                        "mp_m_freemode_01",
                        "mp_f_freemode_01",
                    }
                    local model = GetHashKey(randommodels[math.random(1, #randommodels)])
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Citizen.Wait(0)
                    end
                    PedCreate(2, model, Config.CharacterCoords.x, Config.CharacterCoords.y, Config.CharacterCoords.z - 1, Config.CharacterCoords.h, false, false)
                    SetPedComponentVariation(charPed, 0, 0, 0, 2)
                    FreezeEntityPosition(charPed, false)
                    SetEntityInvincible(charPed, true)
                    PlaceObjectOnGroundProperly(charPed)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                    LoadAnim("anim@amb@nightclub@peds@")
                    TaskPlayAnim(charPed, "anim@amb@nightclub@peds@", "rcmme_amanda1_stand_loop_cop", 2.0, 2.0, -1, 33, 0, false, false, false)
                end)
            end
    

        
        end, data.id)
    
    
    
    end)

end



RegisterNUICallback('newcharacter', function()
    local randommodels = {
        "mp_m_freemode_01",
        "mp_f_freemode_01",
    }
    local model = GetHashKey(randommodels[math.random(1, #randommodels)])
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end
    PedCreate(2, model, Config.CharacterCoords.x, Config.CharacterCoords.y, Config.CharacterCoords.z - 1, Config.CharacterCoords.h, false, false)
    SetEntityAlpha(charPed,0.9,false)
    LoadAnim("anim@amb@nightclub@peds@")
    TaskPlayAnim(charPed, "anim@amb@nightclub@peds@", "rcmme_amanda1_stand_loop_cop", 2.0, 2.0, -1, 33, 0, false, false, false)
    
    

end)

RegisterNUICallback('delecharacter', function(data)
    if charPed ~= nil then
        DeleteEntity(charPed)
        charPed = nil
    end
    TriggerServerEvent('nc:delete', data.id)


end)

RegisterNetEvent('qb-multicharacter:client:closeNUI', function()
    DoScreenFadeOut(250)
    SetDisplay(false)
    DeleteEntity(charPed)
    DisplayRadar(true)
    SendNUIMessage({
        type = "exit"
    })
    charPed = nil

    

end)

if Config.Framework == "ESX" or Config.Framework == "ESX-Legacy" then
    RegisterNUICallback('addnewcharacter', function(data)
        if number <= Config.CharacterLimit then
            local alldata = data.data
            if data.data.sex == "Male" then
                alldata.sex = "M"
            elseif data.data.sex == "Female" then
                alldata.sex = "F"
            end
            FreezeEntityPosition(PlayerPedId(), false)
            TriggerServerEvent('nc:create', data.data, number)
            DeleteEntity(charPed)
            charPed = nil
            islogin = true


        else
            Framework.ShowNotification("Character Limit")


        end

        

    end)

elseif Config.Framework == "QBCore" or Config.Framework == "OLDQBCore" then
    RegisterNUICallback('addnewcharacter', function(data)
        if number <= Config.CharacterLimit then
            local alldata = data.data
            local cData  ={}
            FreezeEntityPosition(PlayerPedId(), false)
            cData.birthdate = data.data.date
            cData.firstname = alldata.firstname
            cData.lastname = alldata.lastname
            if data.data.sex == "M" then
                cData.gender = 0
            elseif data.data.sex == "F" then
                cData.gender = 1
            end
            TriggerServerEvent('nc:create', cData, number)
            DeleteEntity(charPed)
            charPed = nil
            islogin = true
        else
            Framework.Functions.Notify("Character Limit", "error")

        end
    
    end)

end



RegisterNUICallback('startGame', function(data)
    FreezeEntityPosition(PlayerPedId(), false)
    TriggerServerEvent('nc:select', data.id)
    DeleteEntity(charPed)
    charPed = nil
    islogin = true
end)


RegisterCommand("level", function(src, args) 
    TriggerServerEvent('qb-level:up', args[1])
end)


RegisterCommand("down", function(src, args) 
    TriggerServerEvent('qb-level:down', args[1])
end)



function LoadAnim(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

function PedCreate(a, b, c, d, e, f, g, s)
    if charPed ~= nil then
        DeleteEntity(charPed)
        charPed = nil
        charPed = CreatePed(a, b, c, d, e, f, g, s)

    else
        charPed = CreatePed(a, b, c, d, e, f, g, s)

    end

end


function ApplySkin(playerPed, skin, clothes)
    if skin ~= nil then
        Character = {}

        for k,v in pairs(skin) do
            Character[k] = v
    
        end
    
    
        SetPedHeadBlendData			(playerPed, Character['face'], Character['face'], Character['face'], Character['skin'], Character['skin'], Character['skin'], 1.0, 1.0, 1.0, true)
    
        SetPedHairColor				(playerPed,			Character['hair_color_1'],		Character['hair_color_2'])					-- Hair Color
        SetPedHeadOverlay			(playerPed, 3,		Character['age_1'],				(Character['age_2'] / 10) + 0.0)			-- Age + opacity
        SetPedHeadOverlay			(playerPed, 0,		Character['blemishes_1'],		(Character['blemishes_2'] / 10) + 0.0)		-- Blemishes + opacity
        SetPedHeadOverlay			(playerPed, 1,		Character['beard_1'],			(Character['beard_2'] / 10) + 0.0)			-- Beard + opacity
        SetPedEyeColor				(playerPed,			Character['eye_color'], 0, 1)												-- Eyes color
        SetPedHeadOverlay			(playerPed, 2,		Character['eyebrows_1'],		(Character['eyebrows_2'] / 10) + 0.0)		-- Eyebrows + opacity
        SetPedHeadOverlay			(playerPed, 4,		Character['makeup_1'],			(Character['makeup_2'] / 10) + 0.0)			-- Makeup + opacity
        SetPedHeadOverlay			(playerPed, 8,		Character['lipstick_1'],		(Character['lipstick_2'] / 10) + 0.0)		-- Lipstick + opacity
        SetPedComponentVariation	(playerPed, 2,		Character['hair_1'],			Character['hair_2'], 2)						-- Hair
        SetPedHeadOverlayColor		(playerPed, 1, 1,	Character['beard_3'],			Character['beard_4'])						-- Beard Color
        SetPedHeadOverlayColor		(playerPed, 2, 1,	Character['eyebrows_3'],		Character['eyebrows_4'])					-- Eyebrows Color
        SetPedHeadOverlayColor		(playerPed, 4, 1,	Character['makeup_3'],			Character['makeup_4'])						-- Makeup Color
        SetPedHeadOverlayColor		(playerPed, 8, 1,	Character['lipstick_3'],		Character['lipstick_4'])					-- Lipstick Color
        SetPedHeadOverlay			(playerPed, 5,		Character['blush_1'],			(Character['blush_2'] / 10) + 0.0)			-- Blush + opacity
        SetPedHeadOverlayColor		(playerPed, 5, 2,	Character['blush_3'])														-- Blush Color
        SetPedHeadOverlay			(playerPed, 6,		Character['complexion_1'],		(Character['complexion_2'] / 10) + 0.0)		-- Complexion + opacity
        SetPedHeadOverlay			(playerPed, 7,		Character['sun_1'],				(Character['sun_2'] / 10) + 0.0)			-- Sun Damage + opacity
        SetPedHeadOverlay			(playerPed, 9,		Character['moles_1'],			(Character['moles_2'] / 10) + 0.0)			-- Moles/Freckles + opacity
        SetPedHeadOverlay			(playerPed, 10,		Character['chest_1'],			(Character['chest_2'] / 10) + 0.0)			-- Chest Hair + opacity
        SetPedHeadOverlayColor		(playerPed, 10, 1,	Character['chest_3'])														-- Torso Color
        SetPedHeadOverlay			(playerPed, 11,		Character['bodyb_1'],			(Character['bodyb_2'] / 10) + 0.0)			-- Body Blemishes + opacity
    
        if Character['ears_1'] == -1 then
            ClearPedProp(playerPed, 2)
        else
            SetPedPropIndex			(playerPed, 2,		Character['ears_1'],			Character['ears_2'], 2)						-- Ears Accessories
        end
    
        SetPedComponentVariation	(playerPed, 8,		Character['tshirt_1'],			Character['tshirt_2'], 2)					-- Tshirt
        SetPedComponentVariation	(playerPed, 11,		Character['torso_1'],			Character['torso_2'], 2)					-- torso parts
        SetPedComponentVariation	(playerPed, 3,		Character['arms'],				Character['arms_2'], 2)						-- Amrs
        SetPedComponentVariation	(playerPed, 10,		Character['decals_1'],			Character['decals_2'], 2)					-- decals
        SetPedComponentVariation	(playerPed, 4,		Character['pants_1'],			Character['pants_2'], 2)					-- pants
        SetPedComponentVariation	(playerPed, 6,		Character['shoes_1'],			Character['shoes_2'], 2)					-- shoes
        SetPedComponentVariation	(playerPed, 1,		Character['mask_1'],			Character['mask_2'], 2)						-- mask
        SetPedComponentVariation	(playerPed, 9,		Character['bproof_1'],			Character['bproof_2'], 2)					-- bulletproof
        SetPedComponentVariation	(playerPed, 7,		Character['chain_1'],			Character['chain_2'], 2)					-- chain
        SetPedComponentVariation	(playerPed, 5,		Character['bags_1'],			Character['bags_2'], 2)						-- Bag
    
        if Character['helmet_1'] == -1 then
            ClearPedProp(playerPed, 0)
        else
            SetPedPropIndex			(playerPed, 0,		Character['helmet_1'],			Character['helmet_2'], 2)					-- Helmet
        end
    
        if Character['glasses_1'] == -1 then
            ClearPedProp(playerPed, 1)
        else
            SetPedPropIndex			(playerPed, 1,		Character['glasses_1'],			Character['glasses_2'], 2)					-- Glasses
        end
    
        if Character['watches_1'] == -1 then
            ClearPedProp(playerPed, 6)
        else
            SetPedPropIndex			(playerPed, 6,		Character['watches_1'],			Character['watches_2'], 2)					-- Watches
        end
    
        if Character['bracelets_1'] == -1 then
            ClearPedProp(playerPed,	7)
        else
            SetPedPropIndex			(playerPed, 7,		Character['bracelets_1'],		Character['bracelets_2'], 2)				-- Bracelets
        end


    end
end

  

AddEventHandler('onResourceStop', function (resourceName)
    if resourceName == GetCurrentResourceName() then
        DeleteEntity(charPed)
        charPed = nil
    end
end)
      




Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        if islogin then
            TriggerServerEvent('nc:updateOnlineTime')
        end
    end
end)

print('Script By Lxr Dev discord.gg/R9KgyCkXJp')

RegisterNetEvent('qb-level:xp:up', function(xp)
    TriggerServerEvent('qb-level:up', xp)
end)

RegisterNetEvent('qb-level:xp:down', function(xp)
    TriggerServerEvent('qb-level:down', xp)
end)


