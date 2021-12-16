--
--	Created by: Shinya Ohtani
--	Created on: 2021/12/06
--
--	Copyright (C) 2021 Shinya Ohtani, All Rights Reserved
--

use AppleScript version "2.7" -- macOS 10.13 or later
use scripting additions

on run
	
	tell application "Xcode-13.2"
		-- get the source window list of Xcode.
		set windocs to getWinDocs() of me # {fname, ext, win, doc}
		set winToClose to {}
		set frontWinID to id of front window
		repeat with wd in windocs
			set {fname, ext, win, doc} to wd
			if id of win is not equal to frontWinID then
				set end of winToClose to win
			end if
		end repeat
		repeat with w in winToClose
			close w
		end repeat
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

on getWinDocs() # get the source window list of Xcode.
	set windocs to {}
	tell application "Xcode-13.2"
		activate
		delay 0.1
		
		set allDocs to (every source document)
		set allWins to ((every window) whose (id is not -1 and visible is true))
		-- Refine this list of windows to include only those windows
		-- for which the corresponding document type is "source document".
		set wID to fnameNthOfWname(version) of me
		
		set tmp to AppleScript's text item delimiters
		set AppleScript's text item delimiters to "."
		repeat with win in allWins
			if document of win is not missing value then
				set wname to word wID of (name of win as text)
				repeat with doc in allDocs
					if name of doc is equal to wname then
						-- Mix in a sort key for later sorting.
						set end of windocs to {text item 1 of wname, text item 2 of wname, win, doc}
						exit repeat
					end if
				end repeat
			end if
		end repeat
		set AppleScript's text item delimiters to tmp
		if number of windocs is 0 then
			return
		end if
	end tell
	return windocs
end getWinDocs
