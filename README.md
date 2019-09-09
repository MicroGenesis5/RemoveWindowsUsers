# RemoveWindowsUsers

Removes local and Active Directory user accounts in a Windows computer<br /><br />

IMPORTANT: script must be modified - running it as is will remove all users accounts!<br /><br />

There are 3 steps to removing a user profile:<br />
Step 1: Remove profile; equivalent to deleting profile via Run > sysdm.cpl > Advanced > User Profiles > Settings<br />
Step 2: Cleanup; delete any user folders under C:\Users that weren't deleted in step 1<br />
Step 3: Cleanup; delete any registry keys belonging to user that weren't deleted in step 1<br /><br />

You must specify which users you want to *keep* (not get removed)<br />
This is done via the users' SID (Steps 1 and 3) and username (Step 2)<br />
Users you want to keep must be added within the switch statements *in each of the 3 steps*<br />
See the comments for each step in the script for more information
