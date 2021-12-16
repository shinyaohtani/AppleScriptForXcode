--
--	Created by: Shinya Ohtani
--	Created on: 2021/12/11
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
		set windocs to getWinDocs() of me # {fname, ext, win, doc}
		set {rows, cols} to numRowsCols(number of windocs) of me
		
		-- Sort the window list
		set sortkey to {1, -2} -- 1st: filename w/o extention, 2nd extention only (".h", ".cpp"). 
		quickSortMulti(windocs, sortkey) of me
		
		set spT to 25 -- top side space (menu bar height)
		set spL to 10
		set spR to 40
		set spB to 20
		set stepRow to round of ((scH - spT - spB) / rows)
		set stepColumn to round of ((scW - spL - spR) / cols)
		
		-- Leave space between each window where we can
		-- click on another window behind it.
		set spRowB to 10 -- distance between two neighbors (shift bottom to up)
		set spColumnR to 10 -- distance between two neighbors (shift right to left)
		
		set row to 0
		set col to 0
		repeat with wd in windocs
			set {fname, ext, win, doc} to wd -- we use only win (= item 3 of wd)
			set L to spL + (stepColumn * col)
			set T to spT + (stepRow * row)
			set R to L + stepColumn - spColumnR
			set B to T + stepRow - spRowB
			if col is equal to cols - 1 then -- This is to recover double space.
				set R to R + spColumnR
			end if
			if row is equal to rows - 1 then -- This is to recover double space.
				set B to B + spRowB
			end if
			if number of windocs is 1 then -- if single window, then move to center.
				set L to L + (stepColumn / 2)
				set R to R + (stepColumn / 2)
			end if
			
			set bounds of win to {L, T, R, B}
			set index of win to 1
			set col to col + 1
			if col ≥ cols then
				set col to 0
				set row to row + 1
			end if
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

on numRowsCols(numOfWindows)
	-- Decide on the number of windows to line up horizontally.
	if numOfWindows ≤ 9 then -- Even if only one window, set to 2 because the right margin is wasted
		set cols to item (numOfWindows) of {2, 2, 3, 2, 3, 3, 4, 4, 3}
	else
		set cols to 4
	end if
	-- The number of rows is calculated from the number of columns.
	set rows to (numOfWindows) div cols
	if (numOfWindows) mod cols is not equal to 0 then
		set rows to rows + 1
	end if
	return {rows, cols}
end numRowsCols

-- For the following, please refer to https://macscripter.net/viewtopic.php?pid=205924
on quickSortMulti(alist, sortList) -- Non-Recursive FASTEST
	local px, lo, hi, j, L, H, sw, c, comp -- px means 'Pivot Index'
	script mL
		property nlist : alist
		property sList : {}
		property oList : {}
		property stack : {}
	end script
	repeat with j in sortList
		if j > 0 then -- if positive, sort ascending
			set end of mL's sList to (contents of j)
		else -- if negative,sort descending
			set end of mL's sList to -(contents of j)
		end if
		set end of mL's oList to (j > 0)
	end repeat
	set end of mL's stack to {1, count of mL's nlist}
	repeat until (count of mL's stack) = 0 --sc
		set lo to item 1 of item 1 of mL's stack
		set hi to item 2 of item 1 of mL's stack
		-- partitionHoare
		set px to item ((hi + lo) div 2) of mL's nlist
		set L to lo
		set H to hi
		repeat
			set comp to true
			repeat while comp
				repeat with j from 1 to count of mL's sList -- do multiple comparisons
					set c to item j of mL's sList
					set comp to false
					if item c of item L of mL's nlist < item c of px then
						if item j of mL's oList then set comp to true -- ascending
						exit repeat
					else if item c of item L of mL's nlist > item c of px then
						if not (item j of mL's oList) then set comp to true --descending
						exit repeat
					end if
				end repeat
				if comp then set L to L + 1
			end repeat
			
			set comp to true
			repeat while comp
				repeat with j from 1 to count of mL's sList -- do multiple comparisons
					set c to item j of mL's sList
					set comp to false
					if item c of item H of mL's nlist > item c of px then
						if item j of mL's oList then set comp to true -- ascending
						exit repeat
					else if item c of item H of mL's nlist < item c of px then
						if not (item j of mL's oList) then set comp to true --descending
						exit repeat
					end if
				end repeat
				if comp then set H to H - 1
			end repeat
			
			if L ≥ H then
				exit repeat
			end if
			set sw to item L of mL's nlist
			set item L of mL's nlist to item H of mL's nlist
			set item H of mL's nlist to sw
			set L to L + 1
			set H to H - 1
		end repeat
		set px to H -- end of partitionHoare
		set mL's stack to rest of mL's stack
		if px + 1 < hi then
			set beginning of mL's stack to {px + 1, hi}
		end if
		if lo < px then
			set beginning of mL's stack to {lo, px}
		end if
	end repeat
end quickSortMulti
