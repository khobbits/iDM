off *:text:!lootupdate*:#idm.staff:{
  HALT
  ;DO NOT REMOVE THIS HALT YET.
  if (%loottimer) { notice $nick $logo(ERROR) GE Price is updating atm. This command is inactive until its done. | halt }
  if ($me == iDM) { msg #idm.staff $logo(GE UPDATE) Updating Grand Exchange database! }
  unsetall
  if ($me == iDM) {
    set %loottimer $ctime
    set %lootupdate 1
    sockopen lootupdate.1 itemdb-rs.runescape.com 80
  }
  var %n. [ $+ [ $me ] ] 1
  while ($chan(%n. [ $+ [ $me ] ])) {
    if ($chan(%n. [ $+ [ $me ] ]) != #idm.staff) { set %rjoinch. [ $+ [ $me ] ] $+(%rjoinch. [ $+ [ $me ] ],$v1,$chr(44)) }
    inc %n. [ $+ [ $me ] ]
  }
  part $left(%rjoinch. [ $+ [ $me ] ],-1) $logo(GE UPDATE) Updating Grand Exchange database. Please DO not re-invite me. I will join as soon as GE is done updating.
}

on *:SockOpen:lootupdate.*: {
  if (*obby* iswm $read($iif(%raresupdate,rares.txt,loot.txt),%lootupdate)) {
    var %obby = $iif($read(loot.txt,%lootupdate) == Obby Shield,Obsidian Cape,Toktz-ket-xil)
  }
  sockwrite -nt $sockname GET $+(/results.ws?query=,$chr(34),$urlcode($iif(%obby,%obby,$gettok($read($iif(%raresupdate,rares.txt,loot.txt),%lootupdate),1,58))),&price=all&members=) HTTP/1.1 
  sockwrite -nt $sockname Host: itemdb-rs.runescape.com 
  sockwrite -nt $sockname Connection: Close 
  sockwrite -nt $sockname $crlf 
}

on *:SockRead:lootupdate.*: { 
  if ($sockerr) { halt } 
  else { 
    var %sockread 
    sockread %sockread
    if ($regex(%sockread,/<td>(\d[\s\w.\x{2C}]*)<\/td>/Si)) {
      var %lootge $regsubex($remove($iif($+(*,$chr(32),*) iswm $regml(1),$remove($regml(1),$chr(32)),$regml(1)),$chr(44)),/([\d.]+)([mk])?/,$iif(\2 == m,$calc(\1 * 1000000),$iif(\2 == k,$calc(\1 * 1000),\1)))
      write -l $+ %lootupdate $iif(%raresupdate,rares.txt,loot.txt) $gettok($read($iif(%raresupdate,rares.txt,loot.txt),%lootupdate),1,58) $+ : $+ %lootge
      inc %lootupdate
      if ($read($iif(%raresupdate,rares.txt,loot.txt),%lootupdate)) { sockopen lootupdate. [ $+ [ %lootupdate ] ] itemdb-rs.runescape.com 80 }
      sockclose $sockname
    }
    if (*did not return any results* iswm %sockread) { 
      inc %lootupdate
      if ($read($iif(%raresupdate,rares.txt,loot.txt),%lootupdate)) { sockopen lootupdate. [ $+ [ %lootupdate ] ] itemdb-rs.runescape.com 80 }
      sockclose $sockname
    }
    if (!%raresupdate) && (!$read(loot.txt,%lootupdate)) { set %lootupdate 1 | set -s %raresupdate on | sockopen lootupdate.1 itemdb-rs.runescape.com 80 | msg #idm.staff $logo(GE UPDATER) 03Common loot is completely updated. Moving on to 03Rares... | set %raresupdate }
    if (%raresupdate) && (!$read(rares.txt,%lootupdate)) { msg #idm.staff $logo(GE UPDATER) Complete! Took03 $duration($calc($ctime - %loottimer)) to complete it. | geucomplete | unset %lootupdate | unset %loottimer | unset %raresupdate | halt }
  }
}

alias geucomplete {
  ctcp iDM[AL] geucomplete
  ctcp iDM[BA] geucomplete
  ctcp iDM[BU] geucomplete
  ctcp iDM[FU] geucomplete
  ctcp iDM[LL] geucomplete
  ctcp iDM[PK] geucomplete
  ctcp iDM[SN] geucomplete
  ctcp iDM[US] geucomplete
  ctcp iDM[EU] geucomplete
  ctcp iDM[LA] geucomplete
  ctcp iDM[BE] geucomplete
  set -u10 %blockinvspam on
  join $left(%rjoinch. [ $+ [ $me ] ],-1)
}

CTCP *:geucomplete:?: {
  if ($nick != iDM) { halt }
  set -u10 %blockinvspam on
  join $left(%rjoinch. [ $+ [ $me ] ],-1)
  unset %rjoinch. [ $+ [ $me ] ]
}

alias urlcode {
  return $replace($regsubex($1-,/([^\w\s])/Sg,$+(%,$base($asc(\1),10,16,2))),$chr(32),$chr(43))
}
