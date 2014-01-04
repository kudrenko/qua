tell application "Finder"
	set theLocation to ("/Users/me/" as POSIX file)
	set folderNames to {"temp_applescript"}
	repeat with theFolder in folderNames
		try
			make new folder at theLocation with properties {name:"" & theFolder & ""}
		end try
	end repeat
end tell

set script_1 to "mdfind -0 -onlyin '/Volumes/HDD_MED_201304/Photos' 'as_test_20140103' | xargs -0 -I {} cp {} /Users/me/temp_applescript"
do shell script script_1

set script_2 to "sips -Z 2000 /Users/me/temp_applescript/*"
do shell script script_2

tell application "Finder"
	set attchList to every file of alias "Macintosh HD:Users:Me:temp_applescript:"
	set theCNT to count of attchList
	if theCNT = 1 then
		set attchList to attchList as alias as list
	else
		set attchList to every file of alias "Macintosh HD:Users:Me:temp_applescript:" as alias list
	end if
end tell

set theSender to "Alex Kudrenko<alex@kudrenko.me>"
set recipCommon to "The Dude"
set recipAddress to "kudrenko@icloud.com"
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

tell application "Finder" to delete (files of folder "Macintosh HD:Users:Me:temp_applescript" whose name extension is "jpg")
