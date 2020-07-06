# Geary

Official home: https://www.curseforge.com/wow/addons/geary

Official source home: `git clone https://repos.curseforge.com/wow/geary`

Unofficial home: This git repo

## No Longer Supported

I'm sorry that Geary was broken by the 7.x update, but, unfortunately, I'm no longer playing WoW. One of the best parts of WoW addons is the source code is available so anyone can pick up the reins and keep it going. If you are interested, please let me know as I can grant source code access to the official home.

I wrote Geary because I wanted a purely factual representation of what people were wearing. At the time, addons like GearScore/PlayerScore rated your gear which IMHO led to a toxic culture. I achieved more than I set out to do with Geary and I am proud of what it became.

I appreciate everyone's kind words. I'm glad I could share this project with you and hope that Geary can find a new champion to keep it going.

## Features

Geary is a World of Warcraft (WoW) lightweight addon to examine equipped gear of yourself and other players. Key features:

- It shows a summary of all items with their gems and enchants
- Missing gems, enchants, belt buckles, and unfilled upgrades are noted
- Shows equipped item level and number of item levels necessary to reach next item level milestone (e.g. 123 for BRF LFR)
- Can store inspect results for later review and external parsing
- Stored inspection results can be added to player tooltips
- Can show a summary of all stored inspection results for members of your party/raid including an overall average item level
- Missing parts of the MoP legendary quest line (Eye of the Black Prince, Crown of Heaven legendary meta gem, and Cloak of Virtue) are noted
- Because the WoW server controls what inspection data the client receives, retry when necessary 

## Geary Icon

The Geary icon is a handy button for doing Geary operations:

- Left-click dragging moves the icon
- Left-clicking inspects your current target
- Middle-clicking toggles the Geary Interface
- Right-clicking inspects yourself
- Mouse button 4 toggles the Geary options
- Mouse button 5 inspects all members of your group or aborts the current group inspection 

## Geary Interface

The Geary interface has several tabs for reviewing inspection results:

- The entire Geary interface can be moved by Left-click dragging it
- Player tab - Shows detailed results of the most recent inspection
- Group tab - Shows the database stored inspection results of all party/raid members
  - If a player's inspection data is not in the Geary database, the player's details cannot be shown
  - The average iLevel of members with inspection results is shown at the bottom
  - Right-clicking on a row will attempt to reinspect that player
  - Left-clicking on the header will toggle the sort order between by name and by iLevel 
- Database tab - Shows all database stored inspection results
  - Right-clicking on a row will attempt to reinspect that player
  - Left-clicking on the header will toggle the sort order between by name and by iLevel 
- Log tab - A detailed account of what Geary does during an inspection 

## Slash Commands

Geary has slash commands for all important operations as well as some debugging operations:

`/geary`
    Shows usage

`/geary inspect <self | target | group>`
    Use Geary to inspect yourself, your current target, or all players in your group

`/geary ui <show | hide | toggle>`
    Show, hide, or toggle the Geary interface

`/geary icon <show | hide | toggle>`
    Show, hide, or toggle the Geary icon

`/geary options <show | hide | toggle>`
    Show Geary's options

`/geary debug [on | off]`
    Show current debugging state or turn debugging on or off

`/geary dumpitem <itemid | itemlink> [slotname]`
    Dump detailed, debug information about an item. slotname is case sensitive and can be Head, Neck, Shoulder, Back, Chest, Waist, Legs, Feet, Wrist, Hands, Finger0, Finger1, Trinket0, Trinket1, MainHand, or SecondaryHand.

## Key Bindings

Geary supports key bindings for all useful commands. Go the Game Menu -> Key Bindings to manage them.

## Geary Macro

You can also use a macro to invoke Geary inspections. For example, the following macro makes left-click inspect your current target and right-click inspect yourself:

`/run if SecureCmdOptionParse("[btn:2]") then Geary_Inspect:InspectSelf() else Geary_Inspect:InspectTarget() end`

## To Do

See TODO.txt.

## License

See LICENSE.txt.
