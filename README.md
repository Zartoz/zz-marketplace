# QBCore Marketplace Script 🛒

This script provides a dynamic marketplace system within the QBCore framework, allowing players to buy and sell items in-game. Players can list items from their inventory for sale, browse items others have listed, and view recent purchases. The marketplace is accessible via a ped placed in the game world, and both the menu and target systems are configurable to support either `qb-menu` or `ox_lib`, and `qb-target` or `ox_target`.

## Features 🌟

- **Sell Items**: Players can list items from their inventory for sale with customizable pricing and descriptions. 💸
- **Buy Items**: Browse and purchase items listed by other players in the marketplace. 🛍️
- **Recent Purchases**: View a list of recent purchases made by other players. 📜
- **Configurable Menus**: Supports both `qb-menu` and `ox_lib` for a flexible menu experience. 📋
- **Ped and Target System**: Place a marketplace ped in-game and interact with it using `qb-target` or `ox_target`, depending on your preference. 🎯
- **Blip Integration**: Adds a customizable blip on the map to mark the marketplace location. 🗺️

## Installation ⚙️

1. **Download and Extract** 📥
   - Download the script and extract it to your `resources` folder.

3. Add `zz-marketplac.sql` file to your Database 

4. **Add to Server Config** 📝
   - Add the resource to your `server.cfg`:
     ```plaintext
     ensure zz-marketplace
     ```

5. **Configure the Ped** 👤
   - Edit the `config.lua` to set the ped model and position for the marketplace NPC.

6. **Setup Menu and Target System** ⚙️
   - Choose your preferred menu (`qb-menu` or `ox_lib`) and target system (`qb-target` or `ox_target`) in the `config.lua`.
   - Support for ox_inventory will be added soon!

## Usage 🎮

- Players can approach the marketplace NPC to open the marketplace menu, where they can buy or sell items.

## Credits 🙌

- Created by Zartoz 
