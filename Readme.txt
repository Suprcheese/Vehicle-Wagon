Vehicle Wagon 1.1.2
===================

Version 1.1.2 was released July 8, 2017, was tested using Factorio v0.15.28, and was authored by Supercheese, with graphics provided by the awesome YuokiTani.
Additional contributions from: Mooncat, The_Destroyer, Phasma Felis, & Brant Wedel.

This mod allows you to load your fully-laden car or tank onto a flatbed train wagon and take it with you on your rail journeys!
Just use the Winch to haul your vehicle onto the wagon, and use the same Winch to haul it back off when you're ready to drive off.
No more tedious re-inserting ammo, fuel, etc. into your combat vehicle after a long trip by rail to some remote outpost!

This mod should play well with other tank or car mods, and has been successfully tested with the following mods from the mod portal:

-Bob's Warfare
-Advanced Tanks by Neomore
-Tanks! by LCruel
-SuperTank by binbinhrf
-Trucks by KatzSmile

Modded vehicle models will revert to a standard, grey-colored version while riding on the wagon, but after unloading it should be back to normal.

Vehicles that this mod cannot automatically identify, including aircraft, will be loaded on the wagon covered in a tarp.

You also cannot winch vehicles that have a passenger; all players must exit the relevant vehicles before loading/unloading.


Known Issues/Quirks:
--------------------

When loading/unloading a Vehicle Wagon, the train it is attached to will revert to Manual mode.

If a mod adds a "car"-type entity that is not meant to be an actual vehicle, such as the Nixie Tubes mod, it may still be able to be loaded on a Vehicle Wagon under a tarp.
Specific exceptions have been added for Nixie Tubes (and other mods) to disallow this, but other mods may exist that this mod lacks exceptions for.

*************************************************************************************************************
In Factorio v0.15, it seems that the following issues are greatly ameliorated, but do still exercise caution:
*************************************************************************************************************
If a Vehicle Wagon is at the end of a train, everything seems to work just fine.
If a Vehicle Wagon is in the middle of a train, however, then when loading/unloading vehicles, the wagon tends to become disconnected from the train.
There is currently no way to connect wagons via script, but fixing it by hand is simple: just hop into the wagon or locomotive and press the "Connect train" hotkey (G by default).
I recommend getting into the habit of always pressing G after winching vehicles around.

Furthermore, if you have your Vehicle Wagon at the end of your train, and another train is very close behind, the wagon can sometimes get confused and reattach itself to the wrong train.
Should this happen, both trains will be in Manual mode and won't run away on you, so you'll have plenty of time to manually fix the issue.


Credits:
--------

The flatbed wagon graphics are by the extremely talented and gracious YuokiTani!

The wagon tarp graphics for supporting unidentified vehicles provided by Brant Wedel (https://github.com/brantwedel).

This mod makes use of the Factorio Standard Library by Afforess (https://github.com/Afforess/Factorio-Stdlib).

The sound effect was edited from this sound: https://www.freesound.org/people/calivintage/sounds/95701
It was uploaded by the user "calivintage" under the CC Sampling+ License.

Thanks to the forum, Github, and #factorio IRC denizens for camaraderie & advice.

See also the associated forum thread to give feedback, view screenshots, etc.:

https://forums.factorio.com/viewtopic.php?f=93&t=31489
