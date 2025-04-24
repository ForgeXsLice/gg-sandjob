Config = {}

--Ped options
Config.NPC = {
    model = 's_m_y_construct_01',
    coords = vector4(2832.62, 2800.0, 56.47, 97.07)
}

-- Dig Location
Config.DigZones = {
    vector3(2947.09, 2794.07, 40.64),

-- Add more DigZones if you like
    vector3(424.91, 2902.38, 40.28),
}

-- Smelt Location
Config.Smeltery = vector3(1086.22, -2003.63, 30.8)

-- Vehicle options
Config.VehicleModel = 'caddy3'
Config.VehicleSpawn = vector4(2827.68, 2804.78, 56.78, 181.36) -- Positie om het voertuig te spawnen
Config.VehicleReturn = vector3(2825.12, 2797.58, 56.47) -- Positie om het voertuig terug te brengen
Config.ReturnBlipSprite = 225 -- Blip sprite voor voertuig inleverpunt
Config.VehicleDeposit = 500 -- Waarborgsom voor het werkvoertuig

-- Quantity settings
Config.SandPerDig = 1         -- Aantal zand per schep
Config.SandRequiredToSmelt = 5 -- Hoeveel zand nodig om te kunnen smelten
Config.GlassPerSmelt = 5      -- Aantal glas per smeltactie
