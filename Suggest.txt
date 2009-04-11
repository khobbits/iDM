off *:TEXT:!suggest*:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (%sugg.spam [ $+ [ $nick ] ]) { halt }
  if (!$2) { notice $nick Please suggest something. | halt }
  inc -u20 %new.sugg
  inc -u10 %sugg.spam [ $+ [ $nick ] ]
  write Suggestions.txt $nick - $time(hh:nn:ss TT) ( $+ $date(mm/dd/yy) $+ ) - $2-
  notice $nick Thanks for the suggestion, it will be read by an admin.
  if (%new.sugg < 2) {
    msg #iDM.Staff $logo(SUGGESTION) There are new suggestions! (Total suggestions $lines(suggestions.txt) $+ )
  } 
}
on *:TEXT:!suggest:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (%sugg.spam [ $+ [ $nick ] ]) { halt }
  inc -u10 %sugg.spam [ $+ [ $nick ] ]
  notice $nick $LOGO(SUGGESTIONS FORUM) To suggest new content please goto: http://forum.idm-bot.com/viewforum.php?f=6
} 
