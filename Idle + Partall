on *:TEXT:!idle*:#iDM.Staff: {
  if ($readini(admins.ini,admins,$address($nick,3))) {
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
