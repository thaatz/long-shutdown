# https://www.sevenforums.com/tutorials/96938-check-disk-chkdsk-read-event-viewer-log.html
#doesnt work in vista
get-winevent -FilterHashTable @{logname="Application"; id="1001"}| ?{$_.providername –match "wininit"} | fl timecreated, message | out-file "$home\Desktop\CHKDSKResults.txt"