on *:text:!lootupdate*:#idm.staff:{
  if ($.readini(Admins.ini,Admins,$address($nick,3))) {
    if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
    if (%lootupdating) && ($2 != -r) { notice $nick $logo(ERROR) Loot is already being updated.. (Loot $iif(%l,%l,$lines(loot.txt)) $+ / $+ $lines(loot.txt) - Rares $iif(%r,%r,0) $+ / $+ $lines(rares.txt) $+ ) | halt }
    if ($read(lootupdate.txt)) { remove lootupdate.txt }
    if ($read(rareupdate.txt)) { remove rareupdate.txt }
    sockclose lootupdate
    sockclose rareupdate
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
    rareupdate
    unset %l
    remove loot.txt
    rename lootupdate.txt loot.txt
  }
}
alias rareupdate {
  if (!$1) { unset %r }
  if (!%r) { set %r 1 }
  if ($read(rares.txt,%r)) { 
    set %search $replace($gettok($read(rares.txt,%r),1,58),$chr(32),$chr(43))
    sockopen rareupdate itemdb-rs.runescape.com 80
  }
  if (!$read(rares.txt,%r)) {
    unset %lootupdating
    remove rares.txt
    rename rareupdate.txt rares.txt
    msg #iDM.Staff $logo(GE UPDATE) Loot update finished ( $+ $duration($calc($ctime - %t)) $+ ).
    unset %t
  }
}
on *:SOCKOPEN:lootupdate: {
  sockwrite -nt $sockname GET /results.ws?query= $+ %search HTTP/1.1 
  sockwrite -nt $sockname Host: itemdb-rs.runescape.com
  sockwrite -nt $sockname $crlf 
  inc %l
}
on *:SOCKOPEN:rareupdate: {
  sockwrite -nt $sockname GET /results.ws?query= $+ %search HTTP/1.1 
  sockwrite -nt $sockname Host: itemdb-rs.runescape.com
  sockwrite -nt $sockname $crlf 
  inc %r
}
on *:SOCKREAD:rareupdate: { 
  if ($sockerr) { halt } 
  else {
    var %sockread 
    sockread %sockread
    if (%search == clue scroll) { write Rareupdate.txt Clue Scroll:1 | sockclose rareupdate | rareupdate %r | halt }
    if (%search == mudkip) { write Rareupdate.txt Mudkip:50000000 | sockclose rareupdate | rareupdate %r | halt }
    if (%search == accumulator) || (%search == mage's+book) { write Rareupdate.txt $+($replace(%search,$chr(43),$chr(32)),:100000000) | sockclose rareupdate | rareupdate %r | halt }
    if (<td>*</td> iswm %sockread) && ($calc($replace($remove(%sockread,<td>,</td>,$chr(44)),k,*1000,m,*1000000)) >= 1) {
      tokenize 32 $calc($replace($remove(%sockread,<td>,</td>,$chr(44)),k,*1000,m,*1000000))
      write Rareupdate.txt $+($replace(%search,$chr(43),$chr(32)),$chr(58),$1)
      sockclose rareupdate
      rareupdate %r
      halt
    }
  }
}
on *:SOCKREAD:lootupdate: { 
  if ($sockerr) { halt } 
  else {
    var %sockread 
    sockread %sockread
    if (%search == specpot) { write Lootupdate.txt Specpot:1 | sockclose lootupdate | geupdate %l | halt }
    if (%search == ancient+statuette) { write Lootupdate.txt Ancient Statuette:5000000 | sockclose lootupdate | geupdate %l | halt }
    if (%search == seren+statuette) { write Lootupdate.txt Seren Statuette:1000000 | sockclose lootupdate | geupdate %l | halt }
    if (%search == armadyl+statuette) { write Lootupdate.txt Armadyl Statuette:750000 | sockclose lootupdate | geupdate %l | halt }
    if (%search == zamorak+statuette) { write Lootupdate.txt Zamorak Statuette:500000 | sockclose lootupdate | geupdate %l | halt }
    if (%search == saradomin+statuette) { write Lootupdate.txt Saradomin Statuette:400000 | sockclose lootupdate | geupdate %l | halt }
    if (%search == bandos+statuette) { write Lootupdate.txt Bandos Statuette:300000 | sockclose lootupdate | geupdate %l | halt }
    if (<td>*</td> iswm %sockread) && ($calc($replace($remove(%sockread,<td>,</td>,$chr(44)),k,*1000,m,*1000000)) >= 1) {
      tokenize 32 $calc($replace($remove(%sockread,<td>,</td>,$chr(44)),k,*1000,m,*1000000))
      write Lootupdate.txt $+($replace(%search,$chr(43),$chr(32)),$chr(58),$1)
      sockclose lootupdate
      geupdate %l
      halt
    }
  }
}
