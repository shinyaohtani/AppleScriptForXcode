--
--	Created by: Shinya Ohtani
--	Created on: 2021/12/16
--
--	Copyright (C) 2021 Shinya Ohtani, All Rights Reserved
--

use AppleScript version "2.7" -- macOS 10.13 or later
use scripting additions

-- Version history
-- 2021-10-07 shinya.ohtani@cookpad.com

on run
	-- get default display size
	tell application "Finder"
		tell (do shell script "/usr/sbin/system_profiler SPDisplaysDataType -json | grep -B 5 '\"spdisplays_main\" : \"spdisplays_yes\"' | grep _spdisplays_resolution | cut -d'\"' -f4") to set {scW, scH} to {word 1, word 3}
		set spT to 60 -- top side space (menu bar height)
		set spL to 10
		set spR to 40
		set spB to 20
		set h to round of ((scH - spT - spB) / 1)
		set w to round of ((scW - spL - spR) / 3)
		set spColumnR to 10 -- distance between two neighbors (shift right to left)
		set L to spL + w / 2
		set boundsL to {L, spT, L + w, spT + h}
		set L to spL + w / 2 + w + spColumnR
		set boundsR to {L, spT, L + w, spT + h}
	end tell
	
	tell application "Xcode-13.2"
		activate
		delay 0.1
		set origWin to front window
		set wNth to fnameNthOfWname(version) of me
		set cur_name to word wNth of (name of origWin as text)
		
		set AppleScript's text item delimiters to "."
		set seplist to every text item of cur_name
		
		set task to false
		set openAtLeft to false
		if last item of seplist is "h" then
			set fname to ((items 1 thru -2 of seplist) & "cpp") as string
			set task to true
		else if last item of seplist is "cpp" then
			set fname to ((items 1 thru -2 of seplist) & "h") as string
			set task to true
			set openAtLeft to true
		end if
		
		if task is true then
			tell application "System Events" to tell process "Xcode"
				
				tell menu bar 1 to tell menu bar item "File"
					pick menu item "Open Quickly…" of menu "File"
				end tell
				-- keystroke fname -- This break system if with modifier keys are pressed
				set tmp to the clipboard
				set the clipboard to fname
				keystroke "v" using {command down}
				delay 0.2
				keystroke return using {option down}
				set the clipboard to tmp
			end tell
			set newWin to front window
			if openAtLeft is true then
				set bounds of newWin to boundsL
				set bounds of origWin to boundsR
			else
				set bounds of newWin to boundsR
				set bounds of origWin to boundsL
			end if
		end if
		
	end tell
	
end run

on fnameNthOfWname(xcode_ver)
	# Before xcode 13.2, the win names were simple. Project names were not included.
	# before 13.2: "myFile.h"
	#    or if it is edited and not saved "myFile.h -- edited"
	# from 13.2: "Projname -- myFile.h" or "Projname -- myFile.h -- edited"
	
	set nth to 2
	
	set tmp to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "."
	set v to (xcode_ver as string)
	if number of (text items of v) ≥ 3 then # care sub-sub... version. ex 13.2.1
		set v to ({(text item 1 of v) as string, (text item 2 of v) as string} as string)
	end if
	if (v as number) is less than 13.2 then # Before xcode 13.2, the win names were simple.
		set nth to 1
	end if
	set AppleScript's text item delimiters to tmp
	return nth
end fnameNthOfWname
