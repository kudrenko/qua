-- creates new folder in home directory
do shell script "mkdir ~/temp_photos"

tell application "Finder"
	set TempPhotos to folder "temp_photos" of home
end tell

-- serches for a tag within specified folder
-- & then copies all matching files to a folder
set script_1 to "mdfind -0 'tbe_par' | xargs -0 -I {} cp {} ~/temp_photos"
do shell script script_1

-- checks if there are any files in folder
-- if not stops the ascript
tell application "Finder"
	count files of entire contents of TempPhotos
	if the result = 0 then
		error number -128
	end if
end tell

-- [man](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/sips.1.html)
-- resample image so height and width aren't greater than specified size
set script_2 to "sips -Z 2000 ~/temp_photos/*"
do shell script script_2

-- creates a list of files to be attached
tell application "Finder" to set attchList to (every item of TempPhotos) as alias list

-- checks if application Mail is running
tell application "System Events"
	set ProcessList to name of every process
	if "Mail" is in ProcessList then
		set TheMail to 1
	else
		set TheMail to 2
	end if
end tell

-- creates a new e-mail
set theSender to "Alex Kudrenko<alex@alex.me>"
set recipName to "The Dude"
set recipAddress to "alex@icloud.com"
set msgText to "Sent using cool Alex Kudrenko's Application"

tell application "Mail"
	
	set newmessage to make new outgoing message with properties {subject:"Important File Attachment", content:msgText & return & return, visible:false}
	tell newmessage
		set visible to false
		set sender to theSender
		make new to recipient with properties {name:recipName, address:recipAddress}
		repeat with attach in attchList
			make new attachment with properties {file name:(contents of attach)} at after the last paragraph
		end repeat
		
	end tell
	send newmessage
end tell

delay 30

-- deletes all files & DIR
tell application "Finder"
	delete (files of TempPhotos)
	delete TempPhotos
end tell

-- finds PID of Mail.app
tell application "System Events"
	set ProcessList to name of every process
	if "Mail" is in ProcessList then
		set ThePID to unix id of process "Mail"
	end if
end tell

-- quits Mail app if it wasn't running
if TheMail is equal to 2 then
	do shell script "kill -KILL " & ThePID
end if

-- generates new tag with current date
tell (current date) to get ((its year) * 10000 + (its month as integer) * 100 + (its day)) as string
set DateTag to (text 1 thru 8 of the result)

-- install exiftool to use this shell script
-- [download](http://www.sno.phy.queensu.ca/~phil/exiftool/)
-- [faq](http://www.sno.phy.queensu.ca/~phil/exiftool/faq.html)
-- escape literal double quote with a backslash charachter
do shell script "mdfind -0 'tbe_par' | xargs -0 -I {} exiftool -overwrite_original_in_place -P -keywords+=\"emailed_" & DateTag & ¬
	"\" -keywords-=\"tbe_par\" {}"
