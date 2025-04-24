# Sand to Glass Resource by GooGooScripts

## Description
This resource allows players to collect sand and smelt it into glass in FiveM using QBCore framework. It uses ox_lib, ox_target, ox_inventory, and PolyZone for modern, optimized functionality.

## Features
- NPC that provides a shovel for sand collection
- NPC can rent you a car
- Sand collection zone marked on the map
- Glass smelting zone marked on the map
- Animations for collecting sand and smelting glass
- Random rewards for sand collection and glass smelting
- ox_target integration for smooth interaction
- ox_lib notifications and progress bars
- PolyZone implementation for efficient zone management

## Dependencies
- qb-core
- ox_lib
- ox_target
- ox_inventory
- PolyZone

## Installation
1. Place the 'sandglass' folder in your server's resources directory or in a [gg] map.
2. Add `ensure sandglass` or `ensure [gg]` to your server.cfg
3. Add the following items to your ox_inventory/data/items.lua:
4. Search or create your own item images!

## Ox-Inventory
```lua
['shovel'] = { label = 'Shovel', weight = 1000, stack = false, close = true, description = 'A shovel for digging sand', client = { image = "shovel.png",} },
['sand'] = { label = 'Sand', weight = 500, stack = true, close = false, description = 'Sand collected from the beach', client = { image = "sand.png",} },
['glass'] = { label = 'Glass', weight = 300, stack = true, close = true, description = 'Smelted glass from sand', client = { image = "glass.png",} },
```

## Configuration
All configurable options are in the files:
- NPC location and model
- Item prices
- Item names
- Zone locations and sizes
- Blip information
- Collection and smelting times
- Reward amounts
- Vehicle info

## Usage
1. Visit the NPC (marked on the map) to get a shovel or a rendabel car,
2. Go to the sand collection area (also marked on the map),
3. Use the target option to collect sand,
4. Visit the glass smelter location,
5. Use the target option to smelt sand into glass and done!


## Support
For issues or questions, please open an issue on the GitHub repository or contact the author via discord in the fxmanifest.lua!

## License
This resource is released under the MIT License.
