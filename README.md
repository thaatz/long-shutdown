# Long Shutdown
## Usage
run it bruh. It takes like 30 min to complete these checkups.

There are two scripts, poweroff.bat and restart.bat

Run poweroff.bat when you want to turn your computer off and are ok with having it take about 30 minutes to finish.

Run restart.bat when you want to restart and have it take about 30 minutes.

## What it does
* run dism
* run sfc
* run antivirus stuff
* run defrag (really only needed for xp)

----------
nitty gritty psuedocode (ill update this later)
----------
run chkdsk
	if dirty
		make startup script that deletes itself and shuts the computer down
		restart the computer
	else
		shutdown
todo
* make use of runonce registry entries to shutdown the computer instead of the current method after restarting
