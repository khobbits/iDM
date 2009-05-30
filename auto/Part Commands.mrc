on $*:TEXT:/^[!@.]part/Si:#: { 
  if (# == #iDM) || (# == #iDM.Staff) { halt }
  if ($2 == $me) {
    if ($nick isop #) || ($.readini(Admins.ini,Support,$address($nick,3))) {
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


on *:TEXT:!idle*:#iDM.Staff: {
  if ($.readini(admins.ini,admins,$address($nick,3))) {
    var %a = 1,%c
    while (%a <= $chan(0)) {
      if ($nick($chan(%a),$me).idle > 1800) {
        if ($chan(%a) != #iDM && $chan(%a) != #iDM.staff && $chan(%a) != #iStake && $chan(%a) != #iDM.Support) {
          part $chan(%a) This bot has been idling over 30 mins. Parting channel.
          var %c %c $chan(%a)
        }
      }
      inc %a
    } 
    if (%c) notice $nick $logo(IDLE) I have parted: %c 
    else {
      notice $nick $LOGO(IDLE) I have parted no chans.
    }
  }
}
