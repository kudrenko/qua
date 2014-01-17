--> removes "temp_photos" dir to trash if it exists
try
	do shell script "mv ~/temp_photos ~/.Trash/"
end try

--> creates new folder in home directory "temp_photos"
try
	do shell script "mkdir ~/temp_photos"
end try

tell application "Finder"
	set TempPhotos to folder "temp_photos" of home
end tell

--> serches for a tag within kMDItemKeywords metadata attribute of JPEG images
--> & then copies all matching files to the "temp_folder" dir
try
	do shell script "mdfind -0 '((kMDItemKeywords == '*qua_PAR*') && (kMDItemContentType == \"public.jpeg\"))' | xargs -0 -I {} cp {} ~/temp_photos"
end try

--> checks if there are any files in "temp_folder"
--> if not stops the ascript
tell application "Finder"
	count files of entire contents of TempPhotos
	if the result = 0 then
		display notification "Man, you have no images selected for sending to your parents this time!"
		delay 2
		error number -128
		
	end if
end tell

--> [man](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/sips.1.html)
--> resample image so height and width aren't greater than specified size
try
	do shell script "sips -Z 2000 ~/temp_photos/*"
end try

--> creates a list of files to be attached
tell application "Finder" to set attchList to (every item of TempPhotos) as alias list

--> checks if application Mail is running
tell application "System Events"
	set ProcessList to name of every process
	if "Mail" is in ProcessList then
		set MailAppRun to 1
	else
		set MailAppRun to 2
	end if
end tell

--> generates a new string with current date for e-mail subj
tell (current date) to get ((its year) * 10000 + (its month as integer) * 100 + (its day)) as string
set MailSubj to (text 1 thru 4 of the result & "-" & text 5 thru 6 of the result & "-" & text 7 thru 8 of the result)

--> creates a new e-mail
set theSender to "Alex Kudrenko<alex@kudrenko.me>"
set RecipList to {"kudrenko@icloud.com", "alex@alexkudrenko.com"}
set msgText to "Sent using cool Qua app."

tell application "Mail"
	
	set newMessage to make new outgoing message with properties {subject:"Some cool photos " & MailSubj, content:msgText & return & return, visible:false}
	tell newMessage
		set visible to false
		set sender to theSender
		repeat with i from 1 to count RecipList
			make new to recipient at end of to recipients with properties ¬
				{address:item i of RecipList}
		end repeat
		
		repeat with attach in attchList
			make new attachment with properties {file name:(contents of attach)} at after the last paragraph
		end repeat
		
	end tell
	send newMessage
end tell

delay 20

--> count files are in dir (excludes invisible files or items within packages)
tell application "Finder"
	set AllFiles to count files of entire contents of TempPhotos
end tell

--> deletes all files & DIR
tell application "Finder"
	delete (files of TempPhotos)
	delete TempPhotos
end tell

--> finds PID of Mail.app
tell application "System Events"
	set ProcessList to name of every process
	if "Mail" is in ProcessList then
		set ThePID to unix id of process "Mail"
	end if
end tell

--> quits Mail app if it wasn't running
if MailAppRun is equal to 2 then
	do shell script "kill -KILL " & ThePID
end if

--> generates new tag with current date
tell (current date) to get ((its year) * 10000 + (its month as integer) * 100 + (its day)) as string
set DateTag to (text 1 thru 8 of the result)

--> install exiftool to use this shell script
--> [download](http://www.sno.phy.queensu.ca/~phil/exiftool/)
--> [faq](http://www.sno.phy.queensu.ca/~phil/exiftool/faq.html)
--> escape literal double quote with a backslash charachter
try
	do shell script "mdfind -0 '((kMDItemKeywords == '*qua_PAR*') && (kMDItemContentType == \"public.jpeg\"))' | xargs -0 -I {} exiftool -overwrite_original_in_place -P -keywords+=\"emailed_" & DateTag & ¬
		"\" -keywords-=\"qua_PAR\" {}"
end try

display notification "New tag \"emailed_" & DateTag & "\" was applied to " & AllFiles & " images."
delay 7 --> allow time for the notification to trigger

display notification (AllFiles as string) & ¬
	" images were e-mailed to your parents."
delay 1 --> allow time for the notification to trigger