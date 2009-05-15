on *:TEXT:!part*:#: {
  if (# == #iDM) || (# == #iDM.Staff) { halt }
  if ($2 == $me) {
    if ($nick isop #) || ($readini(Admins.ini,Admins,$address($nick,3))) || ($readini(Admins.ini,Support,$address($nick,3))) {
      if (%part.spam [ $+ [ # ] ]) { halt }
      part # Part requested by $nick $+ .
      set -u10 %part.spam [ $+ [ # ] ] on
      msg #iDM.staff $logo(PART) I have parted: $chan $+ . Requested by $iif($nick,$v1,N/A) $+ .
      cancel #
    }
  }
}
on *:PART:#: {
  if (%lootimer) { part # | cancel $1 | halt }
  if ($istok(#idm #idm.staff #idm.support,#,32)) { halt }
  if ($nick(#,0) < 5) { 
    part # Parting channel. Need 5 or more people to have iDM.
  }
  if ($nick == $me) && (!%rjoinch. [ $+ [ $me ] ]) {
    cancel #
    remini -n OnOff.ini #
  }
}
