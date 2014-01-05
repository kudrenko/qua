property temp_photos : alias "Macintosh HD:Users:Me:temp_photos:"

--creates new folder if it doesn't exist
--!!!change user path to suit
tell application "Finder"
	set theLocation to ("/Users/me/" as POSIX file)
	set folderNames to {"temp_photos"}
	repeat with theFolder in folderNames
		try
			make new folder at theLocation with properties {name:"" & theFolder & ""}
		end try
	end repeat
end tell

--serches for a tag within specified folder
--& then copies all matching files to a folder
set script_1 to "mdfind -0 -onlyin '/Volumes/HDD_MED_201304/Photos' 'as_test_20140103' | xargs -0 -I {} cp {} /Users/me/temp_photos"
do shell script script_1

--checks if there are any files in folder
--if not stops the ascript
tell application "Finder"
	count files of entire contents of temp_photos
	if the result = 0 then
		error number -128
	end if
end tell

--[man](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/sips.1.html)
--resample image so height and width aren't greater than specified size
set script_2 to "sips -Z 2000 /Users/me/temp_photos/*"
do shell script script_2

--creates a list of files to be attached
tell application "Finder"
	set attchList to every file of temp_photos
	set theCNT to count of attchList
	if theCNT = 1 then
		set attchList to attchList as alias as list
	else
		set attchList to every file of temp_photos as alias list
	end if
end tell

--checks if application Mail is running
tell application "System Events"
	set ProcessList to name of every process
	if "Mail" is in ProcessList then
		set TheMail to 1
	else
		set TheMail to 2
	end if
end tell

--creates a new e-mail
set theSender to "Alex <alex@alex.me>"
set recipCommon to "The Dude"
set recipAddress to "alex@icloud.com"
set msgText to "Sent using cool Alex Kudrenko's Application"

tell application "Mail"
	
	set newmessage to make new outgoing message with properties {subject:"Important File Attachment", content:msgText & return & return}
	tell newmessage
		set visible to false
		set sender to theSender
		
		make new to recipient with properties {name:recipCommon, address:recipAddress}
		make new attachment with properties {file name:attchList} at after the last paragraph
		
	end tell
	send newmessage
end tell

--gives some time for files to be e-mailed
--not sure if it is required
delay 15

tell application "Finder" to delete (files of temp_photos whose name extension is "jpg")

tell application "System Events"
	set ProcessList to name of every process
	if "Mail" is in ProcessList then
		set ThePID to unix id of process "Mail"
	end if
end tell

--quits Mail app if it wasn't running
if TheMail is equal to 2 then
	do shell script "kill -KILL " & ThePID
end if



--install exiftool to use this shell script
--[download](http://www.sno.phy.queensu.ca/~phil/exiftool/)
--[faq](http://www.sno.phy.queensu.ca/~phil/exiftool/faq.html)
--escape literal double quote with a backslash charachter
do shell script "mdfind -0 -onlyin '/Volumes/HDD_MED_201304/Photos' 'as_test_20140103' | xargs -0 -I {} exiftool -overwrite_original_in_place -P -keywords+=\"photo_emailed\" -keywords-=\"as_test_20140103\" {}"
