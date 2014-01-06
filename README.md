Qua.app
============

### What does it do?

It is a small script that finds photographs with predefined tag/keyword and e-mails them to user predefined e-mail address.

Real life situation would look like that: I tag a photograph of my kid (in Lightroom/Bridge or basically any other app) that I want to be e-mailed to my parents. When Qua.app is triggered by e.g. Calendar (once a month or so) it automatically resizes the photographs and e-mails them to my parents' e-mail addresses.


### How does it do it?

It is a combination of AppleScript & shell script that does:

- search for predefined keywords (qua_PAR) in kMDItemKeywords metadata attribute of files
- create temp copy of found files
- resize them to max size of 2000 pix
- e-mail photos to predefined e-mail address
- remove original keyword & add "emailed_CurrentDate" to kMDItemKeywords metadata attribute of e-mailed files
