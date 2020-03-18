# traffic-changer
Code-snippet designed as an add-on to [PD5M](https://github.com/xSilvermanx/PD5M) by xSilvermanx.
This resource changes the police-vehicles that spawn all over the map to the correct vehicles (Highway: CHP, City: LSPD, County: BCSO).
It does so by checking for every vehicle if it is a police vehicle. If yes, it respawns them and applies a neon-light at the front, which prevents it from being respawned. This is an extremely messy way to approach the problem but it works for the most part.

Shoutout to IllidanS4 for his Entityiter, which is used to iterate over every car.

Only use this together with the following mods:
- [LSPD-Mega-Pack](https://www.lcpdfr.com/downloads/gta5mods/vehiclemodels/17911-los-santos-police-department-mega-pack-els/) by T0y
- [BCSO-Mega-Pack](https://forum.cfx.re/t/els-bcso-mega-pack-fixed-again/81604) by BradM (FiveM-ready version by Kipz)
- [California Highway Patrol](https://forum.cfx.re/t/release-2017-california-highway-patrol-mega-pack-els/64875) by Thehurk (FiveM-ready version by Broderick)

## Installation

- download the latest release and move the folder into the `resource/` directory.
- edit `server.cfg` to include:

```
ensure traffic-changer
```
