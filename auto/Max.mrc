alias max {
  if ($1 == r) {
    ;Range
    ;Normal Voidrange_or_Accumulator Both
    if ($2 == cbow) return 35 40 45
    if ($2 == dbow) return 35-35 40-40 45-45
    if ($2 == mjavelin) return 40 45 50
  }
  if ($1 == ma) {
    ;Mage
    ;Normal Voidmage_or_MagesBook Both
    if ($2 == ice) return 30 35 40
    if ($2 == blood) return 30 35 40
    if ($2 == smoke) return 30 35 40
  }
  elseif ($1 == m) {
    ;Melee
    ;Normal Barrowgloves Firecape Both
    if ($2 == whip) return 35 38 40 43
    if ($2 == dds) return 20-20 23-23 25-25 28-28
    if ($2 == ags) return 55 58 60 63
    if ($2 == bgs) return 75 78 80 83
    if ($2 == sgs) return 50 53 55 58
    if ($2 == zgs) return 50 53 55 58
    if ($2 == dh) return 40/75 43/78 45/80 48/83
    if ($2 == gmaul) return 30-30-30 31-31-31 33-33-33 34-34-34
    if ($2 == guth) return 35 38 40 43
    if ($2 == surf) return 22 22 22 22
    if ($2 == dclaws) return 24-12-6-3 27-14-7-4 29-15-8-4 32-16-8-4
    if ($2 == dmace) return 45 48 50 53
    if ($2 == dhally) return 35-35 38-38 40-40 43-43
    if ($2 == dscim) return 30 33 35 38
    if ($2 == dlong) return 35 38 40 43
    if ($2 == vlong) return 50 53 55 58
    if ($2 == vspear) return 45 48 50 53
    if ($2 == statius) return 65 68 70 73
  }
}
alias specused {
  if ($1 == cbow) return $false
  if ($1 == dbow) return 75
  if ($1 == mjavelin) return 25
  if ($1 == ice) return $false
  if ($1 == blood) return $false
  if ($1 == whip) return $false
  if ($1 == dds) return 25
  if ($1 == ags) return 50
  if ($1 == bgs) return 100
  if ($1 == sgs) return 50
  if ($1 == zgs) return 50
  if ($1 == dh) return $false
  if ($1 == gmaul) return 100
  if ($1 == guth) return $false
  if ($1 == surf) return $false
  if ($1 == dclaws) return 50
  if ($1 == dmace) return 50
  if ($1 == dhally) return 75
  if ($1 == dscim) return $false
  if ($1 == dlong) return 25
  if ($1 == vlong) return 50
  if ($1 == vspear) return 50
  if ($1 == statius) return 100
}
alias bonus {
  if ($1 == cbow) return 3 $+ $chr(37) chance of hitting 60-69 $+ $chr(44) void or accumulator required.
  if ($1 == ice) return 1/3 Chance of freezing your opponent for one turn.
  if ($1 == blood) return Heals 1/3 of whatever you hit.
  if ($1 == dds) return 1/3 Chance of poisoning opponent.
  if ($1 == sgs) return Heals 1/2 of whatever you hit.
  if ($1 == zgs) return 1/2 Chance of freezing your opponent for one turn.
  if ($1 == vspear) return Freezes your opponent for one turn.
  if ($1 == guth) return Heals whatever you hit.
  if ($1 == statius) return Ignores all defence bonuses.
  if ($1 == smoke) return 1/2 Chance of poisoning opponent.
}
alias attack {
  if ($istok(whip dds ags bgs sgs zgs dh gmaul guth surf dclaws dmace dhally dscim dlong vlong vspear statius mjavelin cbow dbow ice blood smoke,$1,32)) {
    return $true
  }
}
alias freezer {
  ;The number is the chance of it freezing (Ice is 1/3).
  if ($1 == ice) return 3
  if ($1 == vspear) return 1
  if ($1 == zgs) return 2
  return $false
}
alias healer {
  ;The first number is the chance of it healing (Sgs is 1/1).
  ;The second number is how much is heals (Sgs heals 1/2).
  if ($1 == guth) return 3 1
  if ($1 == sgs) return 1 2
  if ($1 == blood) return 1 3
  return $false
}
alias poisoner {
  ;The number is the chance of it poisoning (Dds is 1/3).
  if ($1 == dds) return 3
  if ($1 == smoke) return 2
  return $false
}
alias c124 {
  return $chr(124)
}
on $*:TEXT:/^[!@]max/Si:#: { 
  if (# == #iDM) || (# == #iDM.Staff) && ($me != iDM) { halt }
  if (!$2) { $iif($left($1,1) == !,notice $nick,msg #) Please specify the weapon to look up. Syntax: !max whip | halt }
  if (!$attack($2)) { 
    notice $nick $logo(ERROR) $s1($2) is not a recognized attack.
    halt
  }
  if ($max(r,$2)) { $iif($left($1,1) == !,notice $nick,msg #) $logo(MAX) $upper($2) $+ $iif($specused($2),$+($chr(32),$chr(40),$s1($v1 $+ $chr(37)),$chr(41))) $+ : $s2($gettok($max(r,$2),1,32)) $iif($totalhit(r,$2,1),$+($chr(40),$s2($v1),$chr(41))) $c124 Void range or Accumulator $s2($gettok($max(r,$2),2,32)) $iif($totalhit(r,$2,2),$+($chr(40),$s2($v1),$chr(41))) $c124 Void range and Accumulator $s2($gettok($max(r,$2),3,32)) $iif($totalhit(r,$2,3),$+($chr(40),$s2($v1),$chr(41))) $iif($bonus($2),$+($chr(40),$v1,$chr(41))) }
  elseif ($max(ma,$2)) { $iif($left($1,1) == !,notice $nick,msg #) $logo(MAX) $upper($2) $+ $iif($specused($2),$+($chr(32),$chr(40),$1($v1 $+ $chr(37)),$chr(41))) $+ : $s2($gettok($max(ma,$2),1,32)) $iif($totalhit(ma,$2,1),$+($chr(40),$s2($v1),$chr(41))) $c124 Void mage or Mage's book $s2($gettok($max(ma,$2),2,32)) $iif($totalhit(ma,$2,2),$+($chr(40),$s2($v1),$chr(41))) $c124 Void mage and Mage's book $s2($gettok($max(ma,$2),3,32)) $iif($totalhit(ma,$2,3),$+($chr(40),$s2($v1),$chr(41))) $iif($bonus($2),$+($chr(40),$v1,$chr(41))) }
  elseif ($max(m,$2)) { $iif($left($1,1) == !,notice $nick,msg #) $logo(MAX) $upper($2) $+ $iif($specused($2),$+($chr(32),$chr(40),$s1($v1 $+ $chr(37)),$chr(41))) $+ $iif($2 == dh,$+($chr(32),$chr(40),10+ HP/9 or less HP,$chr(41))) $+ : $s2($gettok($max(m,$2),1,32)) $iif($totalhit(m,$2,1),$+($chr(40),$s2($v1),$chr(41))) $c124 Barrow gloves $s2($gettok($max(m,$2),2,32)) $iif($totalhit(m,$2,2),$+($chr(40),$s2($v1),$chr(41))) $c124 Fire cape $s2($gettok($max(m,$2),3,32)) $iif($totalhit(m,$2,3),$+($chr(40),$s2($v1),$chr(41))) $c124 Barrow gloves and Fire cape $s2($gettok($max(m,$2),4,32)) $iif($totalhit(m,$2,4),$+($chr(40),$s2($v1),$chr(41))) $iif($bonus($2),$+($chr(40),$v1,$chr(41))) }
  else notice $nick $logo(ERROR) $s1($2) is not a recognized attack.
}
alias totalhit {
  if (- isin $max($1,$2)) { 
    return $calc($gettok($gettok($v2,$3,32),1,45) + $gettok($gettok($v2,$3,32),2,45) + $gettok($gettok($v2,$3,32),3,45) + $gettok($gettok($v2,$3,32),4,45)) 
  }
  return $false
}

on $*:TEXT:/^[!@]top/Si:#: { 
  if (# == #iDM || # == #iDM.staff) && ($me != iDM) { halt }
  var %display = $iif(@* iswm $1,msg #,notice $nick)
  if ($2 !isnum 1-9) { %display $logo(ERROR) The maximum number of users you can lookup is 9. Syntax: !top 9 | halt }
  filter -fkg money.ini hiscores /(.+?)=(\d{11,})/ 
  set %results $calc($iif($2,$2,5) + 2)
  var %x = $sorttok($regsubex(%tophi,/(.+?)=(\d+)(?:\s|$)/g,$+(\2,=,\1,$chr(32))),32,nr)

  var %output = $regsubex(%x,/(\d+)=(\S+)(?:\s|$)/g,$+($chr(3),03,$findtok(%x,$wildtok(%x,$+(*,\2,*),1,32),32),.,$chr(3)) \2 $+($chr(3),07,$chr(40),$chr(3),03,$bytes(\1,bd),$chr(3),07,$chr(41)) $+($chr(3),$chr(124),$chr(32)))

  var %output = $gettok(%output,$+(1-,%results),124)
  var %output = $regsubex(%output,/~(.+?)~/g,$+($chr(91),\1,$chr(93)))
  %display $logo(TOP) Total DM's: $bytes($readini(totalwins.ini,totalwins,totalwins),bd) $chr(124) %output
  unset %tophi
}
alias hiscores {
  set %tophi %tophi $1-
}
