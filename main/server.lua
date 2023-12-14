local Framework = nil

local loadFile= LoadResourceFile(GetCurrentResourceName(), "./json/data.json") -- you only have to do this once in your code, i just put it in since it wont get confusing.
local datajson = {}
datajson = json.decode(loadFile)

Citizen.CreateThread(function()

    Callback = nil
    if Config.Framework == "ESX" or Config.Framework == "ESX-Legacy" then
        while Framework == nil do
            if Config.Framework == "ESX-Legacy" then
                Framework = exports['es_extended']:getSharedObject()
            elseif Config.Framework == "ESX" then
                TriggerEvent('esx:getSharedObject', function(obj) Framework = obj end)

            end
                
            Citizen.Wait(4)
            Callback = Callback
        end


            

        Framework.RegisterServerCallback('qb-kashacters:GetPlayerData', function(source, cb, id)
            local identifier
            local result
            for k,v in ipairs(GetPlayerIdentifiers(source)) do
                if string.match(v, 'steam:') then
                    identifier = string.sub(v, 7)
                    
                    break
                end
            end
            if Config.Mysql == "mysql-async" then
                result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE  identifier LIKE '%"..identifier.."%'", {})
 
            elseif Config.Mysql == "ghmattimysql" then
                result = exports['ghmattimysql']:execute("SELECT * FROM users WHERE  identifier LIKE '%"..identifier.."%'", {})

            elseif Config.Mysql == "oxmysql" then
                result = exports.oxmysql:executeSync("SELECT * FROM users WHERE  identifier LIKE '%"..identifier.."%'", {})

            end
            
            local sayi = #result
            cb(result, datajson, sayi)


                
        end)

        RegisterNetEvent('nc:create', function(data, sira)
            local src = source
            local newData = {}
            newData.cid = sira
            newData.charinfo = data
            if Framework.Login(src, false, newData) then
                TriggerClientEvent('qb-multicharacter:client:closeNUI',src)
                TriggerClientEvent('esx_skin:openSaveableMenu', src)
                Citizen.Wait(5000)
                GiveStarterItems(src,newData)
            end
        
        
        end)


        RegisterNetEvent('nc:delete', function(id)


            if Config.Mysql == "mysql-async" then
                MySQL.Async.execute("DELETE FROM `users` WHERE `identifier` = '"..id.."'") 
            elseif Config.Mysql == "ghmattimysql" then
                exports['ghmattimysql']:execute("DELETE FROM `users` WHERE `identifier` = '"..id.."'")
            elseif Config.Mysql == "oxmysql" then
                exports.oxmysql:executeSync("DELETE FROM `users` WHERE `identifier` = '"..id.."'")
            end
            


            
        
        
        end)

        RegisterNetEvent('nc:select', function(data, sira)
            local src = source
            if Framework.Login(src, data) then
                TriggerClientEvent('qb-multicharacter:client:closeNUI',src)

            end
        
        
        end)

        
        GiveStarterItems = function(src,data)
            local xPlayer = Framework.GetPlayerFromId(src)
            for k, v in pairs(Config.GiveStarterItems) do
                local info = {}
                xPlayer.addInventoryItem(v.item, v.count, false, info)
            end
        end


        RegisterServerEvent("nc:updateOnlineTime")
        AddEventHandler("nc:updateOnlineTime", function()
            local _source = source
            local xPlayer = Framework.GetPlayerFromId(_source)
            if xPlayer ~= nil then

                if datajson[xPlayer.identifier] ~= nil then
                    datajson[xPlayer.identifier].gametime = datajson[xPlayer.identifier].gametime + 1
                else
                    datajson[xPlayer.identifier] = {}
                    datajson[xPlayer.identifier].gametime = 1
                end
            end     
            SaveResourceFile(GetCurrentResourceName(), "./json/data.json", json.encode(datajson), -1)
            
        end)


        print('Script By Lxr Dev discord.gg/R9KgyCkXJp')

        RegisterNetEvent('qb-level:up', function(levelcount)
            local _source = source
            local xPlayer = Framework.GetPlayerFromId(_source)
            local identifier = xPlayer.identifier
            levelcount = tonumber(levelcount)

            local users
            if Config.Mysql == "mysql-async" then
                users = MySQL.Sync.fetchAll("SELECT * FROM `players` WHERE `citizenid` = '"..identifier.."'", {})
 
            elseif Config.Mysql == "ghmattimysql" then
                users = exports['ghmattimysql']:execute("SELECT * FROM `players` WHERE `citizenid` = '"..identifier.."'", {})

            elseif Config.Mysql == "oxmysql" then
                users = exports.oxmysql:executeSync("SELECT * FROM `players` WHERE `citizenid` = '"..identifier.."'", {})
            end       
            if users[1] ~= nil then
                level = users[1].level
                count = users[1].levelcount
                if (count + levelcount) >= 100 then

                    uplevel = math.floor(((count + levelcount) / 100))
                    if levelcount >= 100 then

                    end
                    kac = (uplevel * 100)
                    kackaldi = (levelcount - kac)
                    if kackaldi < 0 then

                        count = 0
                    else
                        count = kackaldi
                    end
                    
                    level = level + uplevel
                    if Config.Mysql == "mysql-async" then
                        MySQL.Sync.fetchAll("UPDATE `users` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `identifier` = '"..identifier.."'", {})
         
                    elseif Config.Mysql == "ghmattimysql" then
                        exports['ghmattimysql']:execute("UPDATE `users` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `identifier` = '"..identifier.."'", {})
        
                    elseif Config.Mysql == "oxmysql" then
                        exports.oxmysql:executeSync("UPDATE `users` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `identifier` = '"..identifier.."'", {})
                    end   
    
    
    
    
    
    
                else
                    count = count + levelcount
                    if Config.Mysql == "mysql-async" then
                        MySQL.Sync.fetchAll("UPDATE `users` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `identifier` = '"..identifier.."'", {})
         
                    elseif Config.Mysql == "ghmattimysql" then
                        exports['ghmattimysql']:execute("UPDATE `users` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `identifier` = '"..identifier.."'", {})
        
                    elseif Config.Mysql == "oxmysql" then
                        exports.oxmysql:executeSync("UPDATE `users` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `identifier` = '"..identifier.."'", {})
                    end
                end
            end
            
            
   
            

        
        
            
        
        
        end)

        
        RegisterNetEvent('qb-level:down', function(levelcount)
            local _source = source
            local xPlayer = Framework.GetPlayerFromId(_source)
            local identifier = xPlayer.identifier
            levelcount = tonumber(levelcount)


            local users
            if Config.Mysql == "mysql-async" then
                users = MySQL.Sync.fetchAll("SELECT * FROM `players` WHERE `citizenid` = '"..identifier.."'", {})
 
            elseif Config.Mysql == "ghmattimysql" then
                users = exports['ghmattimysql']:execute("SELECT * FROM `players` WHERE `citizenid` = '"..identifier.."'", {})

            elseif Config.Mysql == "oxmysql" then
                users = exports.oxmysql:executeSync("SELECT * FROM `players` WHERE `citizenid` = '"..identifier.."'", {})
            end       
            if users[1] ~= nil then
                    
                level = users[1].level
                count = users[1].levelcount

                if (levelcount >= 100) then


                    uplevel = math.floor(((count + levelcount) / 100))
                    if levelcount >= 100 then

                    end
                    kac = (uplevel * 100)
                    kackaldi = (levelcount - kac)
                    if kackaldi < 0 then

                        count = 0
                    elseif kackaldi == 0 then
                        count = 0
                    else
                        count = 100 - kackaldi
                    end
                    
                    level = level - uplevel




                  
                    if uplevel >= level then

                        level = 0
                    end
                    
                    if Config.Mysql == "mysql-async" then
                        MySQL.Sync.fetchAll("UPDATE `users` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `identifier` = '"..identifier.."'", {})
            
                    elseif Config.Mysql == "ghmattimysql" then
                        exports['ghmattimysql']:execute("UPDATE `users` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `identifier` = '"..identifier.."'", {})
        
                    elseif Config.Mysql == "oxmysql" then
                        exports.oxmysql:executeSync("UPDATE `users` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `identifier` = '"..identifier.."'", {})
                    end
    
    
    
    
    
    
                else
                    count = count - levelcount
                    if Config.Mysql == "mysql-async" then
                        MySQL.Sync.fetchAll("UPDATE `users` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `identifier` = '"..identifier.."'", {})
            
                    elseif Config.Mysql == "ghmattimysql" then
                        exports['ghmattimysql']:execute("UPDATE `users` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `identifier` = '"..identifier.."'", {})
        
                    elseif Config.Mysql == "oxmysql" then
                        exports.oxmysql:executeSync("UPDATE `users` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `identifier` = '"..identifier.."'", {})
                    end
                end
            end
        end)



    else

        if Config.Framework == "OLDQBCore" then

            while Framework == nil do
                TriggerEvent('QBCore:GetObject', function(obj) Framework = obj end)
                Callback = Framework.Functions.CreateCallback
                Wait(4)
    
            end

        elseif Config.Framework == "QBCore" then
            while Framework == nil do
                Framework = exports['qb-core']:GetCoreObject()
                Callback = Framework.Functions.CreateCallback
                Wait(4)
    
            end

        end



            
        Callback('qb-kashacters:GetPlayerData', function(source, cb, id)
            local identifier
            local result
            if Config.Framework == "OLDQBCore" then

                for k,v in ipairs(GetPlayerIdentifiers(source)) do
                    if string.match(v, 'steam:') then
                        identifier = string.sub(v, 6)
                        
                        break
                    end
                end
                if Config.Mysql == "mysql-async" then
                    result = MySQL.Sync.fetchAll("SELECT * FROM players WHERE  steam LIKE '%"..identifier.."%'", {})
     
                elseif Config.Mysql == "ghmattimysql" then
                    result = exports['ghmattimysql']:execute("SELECT * FROM players WHERE  steam LIKE '%"..identifier.."%'", {})
    
                elseif Config.Mysql == "oxmysql" then
                    result = exports.oxmysql:executeSync("SELECT * FROM players WHERE  steam LIKE '%"..identifier.."%'", {})
                end
                
                local sayi = #result
                cb(result, datajson, sayi)
    
            elseif Config.Framework == "QBCore" then
                for k,v in ipairs(GetPlayerIdentifiers(source)) do
                    if string.match(v, 'license:') then
                        identifier = string.sub(v, 8)
                        
                        break
                    end
                end
                if Config.Mysql == "mysql-async" then
                    result = MySQL.Sync.fetchAll("SELECT * FROM players WHERE  license LIKE '%"..identifier.."%'", {})
     
                elseif Config.Mysql == "ghmattimysql" then
                    result = exports['ghmattimysql']:execute("SELECT * FROM players WHERE  license LIKE '%"..identifier.."%'", {})
    
                elseif Config.Mysql == "oxmysql" then
                    result = exports.oxmysql:executeSync("SELECT * FROM players WHERE  license LIKE '%"..identifier.."%'", {})
                end
                
                local sayi = #result
                cb(result, datajson, sayi)
    
            end
            
            


                
        end)

        RegisterNetEvent('nc:create', function(data, sira)
            local src = source
            local newData = {}
            newData.cid = sira
            newData.charinfo = data

            
            if Framework.Player.Login(src, false, newData) then
                if Config.StartingApartment then
                    print('^2[qb-core]^7 '..GetPlayerName(src)..' has succesfully loaded!')
                    Framework.Commands.Refresh(src)
                    TriggerClientEvent('qb-multicharacter:client:closeNUI',src)
                    TriggerClientEvent('apartments:client:setupSpawnUI', src, newData)
                    Citizen.Wait(5000)
                    loadHouseData()
                    GiveStarterItems(src)

                else
                    print('^2[qb-core]^7 '..GetPlayerName(src)..' has succesfully loaded!')
                    Framework.Commands.Refresh(src)
                    TriggerClientEvent('qb-multicharacter:client:closeNUI',src)
                    Citizen.Wait(5000)
                    loadHouseData()
                    GiveStarterItems(src)

                end
                
                
            end

          
        
        
        end)


        RegisterNetEvent('nc:delete', function(id)
           
        
            if Config.Mysql == "mysql-async" then
                MySQL.Async.execute("DELETE FROM `players` WHERE `citizenid` = '"..id.."'") 
            elseif Config.Mysql == "ghmattimysql" then
                exports['ghmattimysql']:execute("DELETE FROM `players` WHERE `citizenid` = '"..id.."'")
            elseif Config.Mysql == "oxmysql" then
                exports.oxmysql:executeSync("DELETE FROM `players` WHERE `citizenid` = '"..id.."'")
            end
        
        end)

        RegisterNetEvent('nc:select', function(data, sira)
            local src = source
            if Framework.Player.Login(src, data) then
                Framework.Commands.Refresh(src)
                print('^2[qb-core]^7 '..GetPlayerName(src)..' (Citizen ID: '..data..') has succesfully loaded!')
                TriggerClientEvent('qb-multicharacter:client:closeNUI',src)
                loadHouseData()
                TriggerClientEvent('apartments:client:setupSpawnUI', src, data)
            end
       
        


            
        
        
        end)




        function GiveStarterItems(src)
            local Player = Framework.Functions.GetPlayer(src)
            for k, v in pairs(Config.GiveStarterItems) do
                local info = {}
                if v.item == "id_card" then
                    info.citizenid = Player.PlayerData.citizenid
                    info.firstname = Player.PlayerData.charinfo.firstname
                    info.lastname = Player.PlayerData.charinfo.lastname
                    info.birthdate = Player.PlayerData.charinfo.birthdate
                    info.gender = Player.PlayerData.charinfo.gender
                    info.nationality = Player.PlayerData.charinfo.nationality
                elseif v.item == "driver_license" then
                    info.firstname = Player.PlayerData.charinfo.firstname
                    info.lastname = Player.PlayerData.charinfo.lastname
                    info.birthdate = Player.PlayerData.charinfo.birthdate
                    info.type = "Class C Driver License"
                end
                Player.Functions.AddItem(v.item, v.count, false, info)
            end
        end


        RegisterServerEvent("nc:updateOnlineTime")
        AddEventHandler("nc:updateOnlineTime", function()
            local _source = source
            local xPlayer = Framework.Functions.GetPlayer(_source)
            if xPlayer ~= nil then

                if datajson[xPlayer.PlayerData.citizenid] ~= nil then
                    datajson[xPlayer.PlayerData.citizenid].gametime = datajson[xPlayer.PlayerData.citizenid].gametime + 1
                else
                    datajson[xPlayer.PlayerData.citizenid] = {}
                    datajson[xPlayer.PlayerData.citizenid].gametime = 1
                end
            end     
            SaveResourceFile(GetCurrentResourceName(), "./json/data.json", json.encode(datajson), -1)
            
        end)

        Callback("qb-multicharacter:server:getSkin", function(source, cb, cid)
            -- print("HELLO")
            local src = source
            local char = {}
            model = 0
            -- print(cid)

            exports.ghmattimysql:execute("SELECT * FROM `character_current` WHERE citizenid = '" .. cid .. "'", {}, function(character_current)
                -- print(#character_current)
                model = '1885233650'
                char.drawables = json.decode('{"1":["masks",0],"2":["hair",0],"3":["torsos",0],"4":["legs",0],"5":["bags",0],"6":["shoes",1],"7":["neck",0],"8":["undershirts",0],"9":["vest",0],"10":["decals",0],"11":["jackets",0],"0":["face",0]}')
                char.props = json.decode('{"1":["glasses",-1],"2":["earrings",-1],"3":["mouth",-1],"4":["lhand",-1],"5":["rhand",-1],"6":["watches",-1],"7":["braclets",-1],"0":["hats",-1]}')
                char.drawtextures = json.decode('[["face",0],["masks",0],["hair",0],["torsos",0],["legs",0],["bags",0],["shoes",2],["neck",0],["undershirts",1],["vest",0],["decals",0],["jackets",11]]')
                char.proptextures = json.decode('[["hats",-1],["glasses",-1],["earrings",-1],["mouth",-1],["lhand",-1],["rhand",-1],["watches",-1],["braclets",-1]]')
                -- print(json.encode(char))
                if character_current[1] and character_current[1].model then
                    model = character_current[1].model
                    char.drawables = json.decode(character_current[1].drawables)
                    char.props = json.decode(character_current[1].props)
                    char.drawtextures = json.decode(character_current[1].drawtextures)
                    char.proptextures = json.decode(character_current[1].proptextures)
                    -- print(json.encode(char))
                end

                exports.ghmattimysql:execute("SELECT * FROM `character_face` WHERE citizenid = '" .. cid .. "'", {}, function(character_face)
                    if character_face[1] and character_face[1].headBlend then
                        char.headBlend = json.decode(character_face[1].headBlend)
                        char.hairColor = json.decode(character_face[1].hairColor)
                        char.headStructure = json.decode(character_face[1].headStructure)
                        char.headOverlay = json.decode(character_face[1].headOverlay)
                    end
                    -- print(model, json.encode(char))
                    cb(model, char)
                end)
            end)
        end)


        RegisterNetEvent('qb-level:up', function(levelcount)
            local _source = source
            local xPlayer = Framework.Functions.GetPlayer(_source)
            local identifier = xPlayer.PlayerData.citizenid
            levelcount = tonumber(levelcount)
            local users


            if Config.Mysql == "mysql-async" then
                users = MySQL.Sync.fetchAll("SELECT * FROM `players` WHERE `citizenid` = '"..identifier.."'", {})
 
            elseif Config.Mysql == "ghmattimysql" then
                users = exports['ghmattimysql']:execute("SELECT * FROM `players` WHERE `citizenid` = '"..identifier.."'", {})

            elseif Config.Mysql == "oxmysql" then
                users = exports.oxmysql:executeSync("SELECT * FROM `players` WHERE `citizenid` = '"..identifier.."'", {})
            end                
            if users[1] ~= nil then
                level = users[1].level
                count = users[1].levelcount
                a = 0
                b = 0
                if (count + levelcount) >= 100 then
                    
                    uplevel = math.floor(((count + levelcount) / 100))
                    if levelcount >= 100 then

                    end
                    kac = (uplevel * 100)
                    kackaldi = (levelcount - kac)
                    if kackaldi < 0 then

                        count = 0
                    else
                        count = kackaldi
                    end
                    
                    level = level + uplevel
                    
    
    
                    if Config.Mysql == "mysql-async" then
                        MySQL.Sync.fetchAll("UPDATE `players` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `citizenid` = '"..identifier.."'", {})
            
                    elseif Config.Mysql == "ghmattimysql" then
                        exports['ghmattimysql']:execute("UPDATE `players` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `citizenid` = '"..identifier.."'", {})
        
                    elseif Config.Mysql == "oxmysql" then
                        exports.oxmysql:executeSync("UPDATE `players` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `citizenid` = '"..identifier.."'", {})
                    end
    
    
                else
                    count = count + levelcount

                    if Config.Mysql == "mysql-async" then
                        MySQL.Sync.fetchAll("UPDATE `players` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `citizenid` = '"..identifier.."'", {})
            
                    elseif Config.Mysql == "ghmattimysql" then
                        exports['ghmattimysql']:execute("UPDATE `players` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `citizenid` = '"..identifier.."'", {})
        
                    elseif Config.Mysql == "oxmysql" then
                        exports.oxmysql:executeSync("UPDATE `players` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `citizenid` = '"..identifier.."'", {})
                    end
                end
            end        
            
        
        
        end)

        
        RegisterNetEvent('qb-level:down', function(levelcount)
            local _source = source
            local xPlayer = Framework.Functions.GetPlayer(_source)
            local identifier = xPlayer.PlayerData.citizenid
            levelcount = tonumber(levelcount)
            local users
            if Config.Mysql == "mysql-async" then
                users = MySQL.Sync.fetchAll("SELECT * FROM `players` WHERE `citizenid` = '"..identifier.."'", {})
 
            elseif Config.Mysql == "ghmattimysql" then
                users = exports['ghmattimysql']:execute("SELECT * FROM `players` WHERE `citizenid` = '"..identifier.."'", {})

            elseif Config.Mysql == "oxmysql" then
                users = exports.oxmysql:executeSync("SELECT * FROM `players` WHERE `citizenid` = '"..identifier.."'", {})
            end


            if users[1] ~= nil then
                
                level = users[1].level
                count = users[1].levelcount

                if (levelcount >= 100) then


                    uplevel = math.floor(((count + levelcount) / 100))
                    if levelcount >= 100 then

                    end
                    kac = (uplevel * 100)
                    kackaldi = (levelcount - kac)
                    if kackaldi < 0 then

                        count = 0
                    elseif kackaldi == 0 then
                        count = 0
                    else
                        count = 100 - kackaldi
                    end
                    
                    level = level - uplevel




                  
                    if uplevel >= level then

                        level = 0
                    end
                    
                    if Config.Mysql == "mysql-async" then
                        MySQL.Sync.fetchAll("UPDATE `players` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `citizenid` = '"..identifier.."'", {})
         
                    elseif Config.Mysql == "ghmattimysql" then
                        exports['ghmattimysql']:execute("UPDATE `players` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `citizenid` = '"..identifier.."'", {})
        
                    elseif Config.Mysql == "oxmysql" then
                        exports.oxmysql:executeSync("UPDATE `players` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `citizenid` = '"..identifier.."'", {})
                    end
    
    
    
    
    
    
                else
                    count = count - levelcount

                    if Config.Mysql == "mysql-async" then
                        MySQL.Sync.fetchAll("UPDATE `players` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `citizenid` = '"..identifier.."'", {})
         
                    elseif Config.Mysql == "ghmattimysql" then
                        exports['ghmattimysql']:execute("UPDATE `players` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `citizenid` = '"..identifier.."'", {})
        
                    elseif Config.Mysql == "oxmysql" then
                        exports.oxmysql:executeSync("UPDATE `players` SET `level` = '"..level.."', levelcount = '"..count.."' WHERE `citizenid` = '"..identifier.."'", {})
                    end
                end
            end
            
            
        end)



        function loadHouseData()
            local HouseGarages = {}
            local Houses = {}
            local result
            if Config.Mysql == "mysql-async" then
                result = MySQL.Sync.fetchAll("SELECT * FROM houselocations", {})
 
            elseif Config.Mysql == "ghmattimysql" then
                result = exports['ghmattimysql']:execute("SELECT * FROM houselocations", {})

            elseif Config.Mysql == "oxmysql" then
                result = exports.oxmysql:executeSync("SELECT * FROM houselocations", {})
            end

            if result[1] ~= nil then
                for k, v in pairs(result) do
                    local owned = false
                    if tonumber(v.owned) == 1 then
                        owned = true
                    end
                    local garage = v.garage ~= nil and json.decode(v.garage) or {}
                    Houses[v.name] = {
                        coords = json.decode(v.coords),
                        owned = v.owned,
                        price = v.price,
                        locked = true,
                        adress = v.label,
                        tier = v.tier,
                        garage = garage,
                        decorations = {},
                    }
                    HouseGarages[v.name] = {
                        label = v.label,
                        takeVehicle = garage,
                    }
                end
            end
            TriggerClientEvent("qb-garages:client:houseGarageConfig", -1, HouseGarages)
            TriggerClientEvent("qb-houses:client:setHouseConfig", -1, Houses)
        end
        
        

    end
       
        

  


    ExecuteSql = function(wait, query, sync, cb)
        local rtndata = {}
        local waiting = true

        if Config.Mysql == "mysql-async" then
            if sync then
                MySQL.Sync.fetchAll(query, {}, function(data)
                    if cb ~= nil and wait == false then
                        cb(data)
                    end
                    rtndata = data
                    waiting = false
                end)
            else
                MySQL.Async.fetchAll(query, {}, function(data)
                    if cb ~= nil and wait == false then
                        cb(data)
                    end
                    rtndata = data
                    waiting = false
                end)


            end
                
        elseif Config.Mysql == "ghmattimysql" then
            exports['ghmattimysql']:execute(query, {}, function(data)
                if cb ~= nil and wait == false then
                    cb(data)
                end
                rtndata = data
                waiting = false
            end)
        elseif Config.Mysql == "oxmysql" then
            if sync then
                exports.oxmysql:executeSync(query, {}, function(data)
                    if cb ~= nil and wait == false then
                        cb(data)
                    end
                    rtndata = data
                    waiting = false
                end)

            else


            end
        end
        if wait then
            while waiting do
                Citizen.Wait(5)
            end
            if cb ~= nil and wait == true then
                cb(rtndata)
            end
        end
        return rtndata
    end
    
end)    




 



