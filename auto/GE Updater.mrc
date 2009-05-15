on *:text:!lootupdate*:#idm.staff:{
  if ($readini(Admins.ini,Admins,$address($nick,3))) {
    if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
    if (%lootupdating) { notice $nick $logo(ERROR) Loot is already being updated.. On item %l $+ / $+ $lines(loot.txt) $+ . | halt }
    if ($read(lootupdate.txt)) { remove lootupdate.txt }
    geupdate
    set %lootupdating on
    set %t $ctime
    msg # $logo(GE UPDATE) Loot update started ( $+ $time(hh:nn:ss) $+ ).
  }
}
alias geupdate {
  if (!$1) { unset %l }
  if (!%l) { set %l 1 }
  if ($read(loot.txt,%l)) { 
    set %search $replace($gettok($read(loot.txt,%l),1,58),$chr(32),$chr(43))
    sockopen lootupdate itemdb-rs.runescape.com 80
  }
  if (!$read(loot.txt,%l)) {
    unset %l
    unset %lootupdating
    remove loot.txt
    rename lootupdate.txt loot.txt
    msg #iDM.Staff $logo(GE UPDATE) Loot update finished ( $+ $duration($calc($ctime - %t)) $+ ).
  }
}
on *:SOCKOPEN:lootupdate: {
  sockwrite -nt $sockname GET /results.ws?query= $+ %search HTTP/1.1 
  sockwrite -nt $sockname Host: itemdb-rs.runescape.com
  sockwrite -nt $sockname $crlf 
  inc %l
}
on *:SOCKREAD:lootupdate: { 
  if ($sockerr) { halt } 
  else {
    var %sockread 
    sockread %sockread
    if (%search == specpot) { write Lootupdate.txt Specpot:1 | sockclose lootupdate | geupdate %l | halt }
    if (<td>*</td> iswm %sockread) && ($calc($replace($remove(%sockread,<td>,</td>,$chr(44)),k,*1000,m,*1000000)) >= 1) {
      tokenize 32 $calc($replace($remove(%sockread,<td>,</td>,$chr(44)),k,*1000,m,*1000000))
      write Lootupdate.txt $+($replace(%search,$chr(43),$chr(32)),$chr(58),$1)
      sockclose lootupdate
      geupdate %l
      halt
    }
  }
}
