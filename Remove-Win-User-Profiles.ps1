# Removes local and Active Directory user accounts in a Windows computer

# IMPORTANT: script must be modified - running it as is will remove all users accounts!

# There are 3 steps to removing a user profile:
# Step 1: Remove profile; equivalent to deleting profile via Run > sysdm.cpl > Advanced > User Profiles > Settings
# Step 2: Cleanup; delete any user folders under C:\Users that weren't deleted in step 1
# Step 3: Cleanup; delete any registry keys belonging to user that weren't deleted in step 1

# You must specify which users you want to *keep* (not get removed)
# This is done via the users' SID (Steps 1 and 3) and username (Step 2)
# Users you want to keep must be added within the switch statements *in each of the 3 steps*
# See the comments for each step in the script for more information


# Step 1: Remove User Profiles

# Equivalent to removing a profile via Run > sysdm.cpl > Advanced > User Profiles > Settings
# To view current SID's on a PC, run command: Get-WmiObject -Class Win32_UserProfile
# To keep specific user, create a line in the switch statement below in the following format: '%SID%' {continue}  

Write-Host "1. Remove User Profiles" -ForegroundColor Green
Start-Sleep -s 4

$global:extraUsers = 0

ForEach ($sid in Get-WmiObject -Class Win32_UserProfile)
{
    switch($sid.sid)
    {
        'S-1-5-18' {continue} # system SID's
        'S-1-5-19' {continue}
        'S-1-5-20' {continue} 

        # add SID's of users you want to *keep* here

        default # all other SID's get deleted
        {
            $global:extraUsers++
            Write-Host "Removing profile: $($sid.LocalPath -replace "C:\\Users\\")"
            $sid.Delete()
            Start-Sleep -s 2
        } 
    }
}

if ($global:extraUsers -eq 0)
{
    Write-Host "There are no User profiles that need to be removed."
}


Start-Sleep -s 3
Write-Host ""


# Step 2, cleanup: delete any leftover user folders in C:\Users\ that weren't deleted in Step 1

# To keep a user profile, their folder in the above directory cannot be deleted; 
# create a line in the switch statement below in the following format to keep their profile: '%user%' {continue}


Write-Host "2. Delete any leftover User Folders" -ForegroundColor Green
Start-Sleep -s 4

$global:folderCount = 0

ForEach ($directory in Get-ChildItem C:\Users)
{
    $directoryString = [string]$directory.Name # cast to a string

    switch($directoryString)
    {
        'Public' {continue}
        'Default' {continue} # this is the hidden folder named 'Default'

        # add users you want to *keep* here

        default # all other directories get deleted
        {
            $global:folderCount++
            Write-Host "Deleting folder: C:\Users\$($directoryString)"
            cmd /c rmdir /s /q "C:\Users\$directoryString"
            Start-Sleep -s 2
        }
    }
}

if ($global:folderCount -eq 0)
{
    Write-Host "There are no leftover User folders that need to be deleted."
}


Start-Sleep -s 3
Write-Host ""


# Step 3, cleanup: delete any leftover user profile registry keys

# User keys are under HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList
# To view SID of user keys in Powershell: Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' -Name
# To keep specific user, create a line in the switch statement below in the following format: '%SID%' {continue}  

Write-Host "3. Delete any leftover User Registry Keys" -ForegroundColor Green
Start-Sleep -s 4

$global:regkeyCount = 0

ForEach ($regkey in Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' -Name)
{
    $regkeyString = [string]$regkey # cast to a string

    switch($regkeyString)
    {
        'S-1-5-18' {continue} # system SID's
        'S-1-5-19' {continue}
        'S-1-5-20' {continue} 

        # add SID's of users you want to *keep* here

        default # all other regkeys get deleted
        {
            $global:regkeyCount++
            Write-Host "Removing registry key: $regkeyString"
            Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$regkeyString'
            Start-Sleep -s 2
        }
    }
}

if ($global:regkeyCount -eq 0)
{
    Write-Host "There are no leftover User registry keys that need to be deleted."
}

Write-Host ""
cmd /c pause
