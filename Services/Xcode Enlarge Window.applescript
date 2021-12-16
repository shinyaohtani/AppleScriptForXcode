--
--	Created by: Shinya Ohtani
--	Created on: 2021/12/06
--
--	Copyright (C) 2021 Shinya Ohtani, All Rights Reserved
--

use AppleScript version "2.7" -- macOS 10.13 or later
use scripting additions

on run
	-- get default display size
	tell application "Finder"
		tell (do shell script "/usr/sbin/system_profiler SPDisplaysDataType -json | grep -B 5 '\"spdisplays_main\" : \"spdisplays_yes\"' | grep _spdisplays_resolution | cut -d'\"' -f4") to set {scW, scH} to {word 1, word 3}
	end tell
	
	tell application "Xcode-13.2"
		set spT to 45 -- top side space (menu bar is 25)
		set spL to 10
		set spR to 40
		set spB to 40 -- bottom side space (auto layout is 20)
		set stepRow to round of (scH - spT - spB)
		set stepColumn to round of ((scW - spL - spR) / 2)
		
		set win to front window
		set L to spL + (round of (stepColumn / 2))
		set T to spT
		set R to L + stepColumn
		set B to T + stepRow
		
		set shiftX to 100
		set shiftY to 30
		set rect to {L, T, R, B}
		set allWins to ((every window) whose (id is not -1 and id is not (id of win) and visible is true))
		set confirmed to false
		repeat while (confirmed is false)
			set confirmed to true
			repeat with w in allWins
				if bounds of w is equal to rect then
					set confirmed to false
					set L to L + shiftX
					set R to R + shiftX
					set T to T + shiftY
					set B to B + shiftY
					set rect to {L, T, R, B}
					exit repeat
				end if
			end repeat
		end repeat
		
		set bounds of win to rect
		set index of win to 1
	end tell
	
end run
