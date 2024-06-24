--[[
**********************************************************************
MagicMarker - your best friend for raid marking. See README.txt for
more details.
**********************************************************************
This file is part of MagicMarker, a World of Warcraft Addon

MagicMarker is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

MagicMarker is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with MagicMarker.  If not, see <http://www.gnu.org/licenses/>.

**********************************************************************
List of spell ID's for 2.4 for all crowd control spells.
Used for auto-learning which abilities can be used to CC a mob
**********************************************************************
]]
local comm = LibStub("MagicComm-1.0")

comm.spellIdToCCID = {
   -- Polymorph
   [118] = 2, [12824] = 2, [12825] = 2, [12826] = 2, [28271] = 2, [28272] = 2,

   -- Banish
   [710] = 3, [18647] = 3,

   -- Shackle
   [9484] = 4, [9485] = 4, [10955] = 4,

   -- Hibernate
   [2637] = 5, [18657] = 5, [18658] = 5,

   -- Freezing Trap
   [3355] = 6, [14308] = 6, [14309] = 6,

   -- Mind control
   [605] = 8, [10911] = 8, [19812] = 8,

   -- Fear
   [5782] = 9, [6213] = 9, [6215] = 9, [5484] = 9, [17928] = 9, [8122] = 9,
   [8124] = 9, [10888] = 9, [10890] = 9,
   [50577] = 9, -- DemonForm howl of Terror

   -- Death Coil
   [17924] = 9, [6798] = 9, [17926] = 9, [27223] = 9, [47859] = 9, [47860] = 9,
   
   -- Sap
   [6770] = 10, [2070] = 10, [11297] = 10, [51724] = 10, 

   -- Enslave
   [1098] = 11, [11725] = 11, [11726] = 11, 
   
   -- Root
   [339] = 12, [1062] = 12, [5195] = 12, [5196] = 12,
   [9852] = 12, [9853] = 12, [26989] = 12, [53308] = 12,

   -- Cyclone
   [33786] = 13,

   -- Turn Undead (=> sets Turn Evil too)
   [2878] = { 14, 17 }, [5627] = { 14, 17 },

   -- Scare Beast
   [1513] = 15, [14326] = 15, [14327] = 15,

   -- Seduction
   [6358] = 16,
   
   -- Turn Evil
   [10326] = 17,

   -- Blind
   [2094] = 18,

}


-- Spell durations in seconds
comm.spellIdToDuration = {
   [118] = 20, 
   [339] = 12, 
   [605] = 60, 
   [710] = 20, 
   [1062] = 15, 
   [1098] = 300, 
   [1513] = 10, 
   [2070] = 35, 
   [2094] = 10, 
   [2637] = 20, 
   [2878] = 10, 
   [3355] = 10, 
   [5195] = 18, 
   [5196] = 21, 
   [5484] = 6, 
   [5627] = 15, 
   [5782] = 10, 
   [6213] = 15, 
   [6215] = 20, 
   [6358] = 15, 
   [6770] = 25, 
   [8122] = 8, 
   [8124] = 8, 
   [9484] = 30, 
   [9485] = 40, 
   [9852] = 24, 
   [9853] = 27, 
   [10326] = 20, 
   [10888] = 8, 
   [10890] = 8, 
   [10911] = 60, 
   [10955] = 50, 
   [11297] = 45, 
   [11725] = 300, 
   [11726] = 300, 
   [12824] = 30, 
   [12825] = 40, 
   [12826] = 50, 
   [14308] = 15, 
   [14309] = 20, 
   [14326] = 15, 
   [14327] = 20, 
   [17928] = 8, 
   [18647] = 30, 
   [18657] = 30, 
   [18658] = 40, 
   [19812] = 8, 
   [26989] = 27, 
   [28271] = 50, 
   [28272] = 50, 
   [33786] = 6,

   -- WotLK
   [50577] = 8,[51724] = 60,[53308] = 27,[17924] = 3,
   [6798] = 3,[17926] = 3, [27223] = 3, [47859] = 3, [47860] = 3,
}
