alias max {
  if ($1 == r) {
    ;Normal Voidrange_or_Accumulator Both
    var %dmg = $maxdmg(r, $2, 3)
    if (%dmg == $null) { return }
    elseif ($2 == dbow) return $+(%dmg,-,%dmg) $+($calc(%dmg +5),-,$calc(%dmg +5)) $+($calc(%dmg +10),-,$calc(%dmg +10))
    else return %dmg $calc(%dmg +5) $calc(%dmg +10)
  }
  elseif ($1 == ma) {
    ;Normal Voidmage_or_MagesBook_or_GodCape Two_Bonuses Three_Bonuses
    var %dmg = $maxdmg(ma, $2, 3)
    if (%dmg == $null) { return }
    else return %dmg $calc(%dmg +5) $calc(%dmg +10) $calc(%dmg +15)
  }
  elseif ($1 == m) {
    ;Normal Barrowgloves Firecape Both
    var %dmg = $maxdmg(m, $2, 3)
    if (%dmg == $null) { return }
    elseif ($2 == surf) return %dmg %dmg %dmg %dmg
    elseif ($2 == dds) return $+(%dmg,-,%dmg) $+($calc(%dmg +3),-,$calc(%dmg +3)) $+($calc(%dmg +5),-,$calc(%dmg +5)) $+($calc(%dmg +8),-,$calc(%dmg +8))
    elseif ($2 == dbow) return $+(%dmg,-,%dmg) $+($calc(%dmg +3),-,$calc(%dmg +3)) $+($calc(%dmg +5),-,$calc(%dmg +5)) $+($calc(%dmg +8),-,$calc(%dmg +8))
    elseif ($2 == dhally) return $+(%dmg,-,%dmg) $+($calc(%dmg +3),-,$calc(%dmg +3)) $+($calc(%dmg +5),-,$calc(%dmg +5)) $+($calc(%dmg +8),-,$calc(%dmg +8))
    elseif ($2 == gmaul) return $+(%dmg,-,%dmg,-,%dmg) $+($calc(%dmg +3),-,$calc(%dmg +3),-,$calc(%dmg +3)) $+($calc(%dmg +5),-,$calc(%dmg +5),-,$calc(%dmg +5)) $+($calc(%dmg +8),-,$calc(%dmg +8),-,$calc(%dmg +8))
    elseif ($2 == dclaws) return $dclawsdmg(%dmg,0) $dclawsdmg(%dmg,3) $dclawsdmg(%dmg,5) $dclawsdmg(%dmg,8)
    elseif ($2 == dh) {
      var %dmg2 = $maxdmg(m, dh9, 3)
      return $+(%dmg,/,%dmg2) $+($calc(%dmg +3),/,$calc(%dmg2 +3)) $+($calc(%dmg +5),/,$calc(%dmg2 +5)) $+($calc(%dmg +8),/,$calc(%dmg2 +8))
    }
    else return %dmg $calc(%dmg +3) $calc(%dmg +5) $calc(%dmg +8)
  }
}

alias maxdmg { return $gettok($dmg($1, $2, $3),2,44) }
alias dclawsdmg { return $+($calc($1 + $2),-,$ceil($calc(($1 + $2) * 0.5)),-,$ceil($calc(($1 + $2) * 0.25)),-,$ceil($calc(($1 + $2) * 0.125))) }

alias dmg {
  ; $1 = r/ma/m range/mage/melee
  ; $2 = attack
  ; $3 = 1/2/3 = low/med/high
  if ($1 == r) {
    if ($2 == cbow) {
      if ($3 == 1) return 0,10 | ; $r(0,10)
      elseif ($3 == 2) return 11,20 | ; $r(11,20)
      elseif ($3 == 3) return 21,35 | ; $r(21,35+)
      else return 15 30 | ; 0-15 acc low hit - 15-30 acc med hit - 30-100 acc high hit
    }
    if ($2 == dbow) {
      if ($3 == 1) return 8,8
      elseif ($3 == 2) return 9,20
      elseif ($3 == 3) return 20,35
      else return 8 50
    }
    if ($2 == mjavelin) {
      if ($3 == 1) return 0,7
      elseif ($3 == 2) return 8,25
      elseif ($3 == 3) return 25,40
      else return 4 38
    }
    if ($2 == onyx) {
      if ($3 == 1) return 0,10
      elseif ($3 == 2) return 10,30
      elseif ($3 == 3) return 25,35
      else return 5 35
    }
  }
  elseif ($1 == ma) {
    if ($2 == ice) {
      if ($3 == 1) return 1,2
      elseif ($3 == 2) return 1,15
      elseif ($3 == 3) return 16,30
      else return 4 30
    }
    if ($2 == blood) {
      if ($3 == 1) return 0,2
      elseif ($3 == 2) return 1,15
      elseif ($3 == 3) return 16,30
      else return 4 25
    }
    if ($2 == smoke) {
      if ($3 == 1) return 1,4
      elseif ($3 == 2) return 1,15
      elseif ($3 == 3) return 16,30
      else return 4 35
    }
  }
  elseif ($1 == m) {
    if ($2 == whip) {
      if ($3 == 1) return 0,0
      elseif ($3 == 2) return 0,25
      elseif ($3 == 3) return 11,35
      else return 4 25
    }
    if ($2 == ags) {
      if ($3 == 1) return 0,0
      elseif ($3 == 2) return 1,20
      elseif ($3 == 3) return 21,55
      else return 2 20
    }
    if ($2 == bgs) {
      if ($3 == 1) return 0,0
      elseif ($3 == 2) return 1,35
      elseif ($3 == 3) return 36,75
      else return 5 35
    }
    if ($2 == sgs) {
      if ($3 == 1) return 0,0
      elseif ($3 == 2) return 1,20
      elseif ($3 == 3) return 16,50
      else return 5 25
    }
    if ($2 == zgs) {
      if ($3 == 1) return 0,0
      elseif ($3 == 2) return 1,25
      elseif ($3 == 3) return 26,50
      else return 5 30
    }
    if ($2 == guth) {
      if ($3 == 1) return 0,0
      elseif ($3 == 2) return 1,20
      elseif ($3 == 3) return 11,35
      else return 5 15
    }
    if ($2 == surf) {
      if ($3 == 1) return 0,10
      elseif ($3 == 2) return 11,17
      elseif ($3 == 3) return 18,25
      else return 2 30
    }
    if ($2 == dscim) {
      if ($3 == 1) return 0,0
      elseif ($3 == 2) return 5,25
      elseif ($3 == 3) return 26,30
      else return 4 30
    }
    if ($2 == dlong) {
      if ($3 == 1) return 0,0
      elseif ($3 == 2) return 5,25
      elseif ($3 == 3) return 26,35
      else return 4 30
    }
    if ($2 == vlong) {
      if ($3 == 1) return 0,10
      elseif ($3 == 2) return 10,35
      elseif ($3 == 3) return 30,50
      else return 2 25
    }
    if ($2 == vspear) {
      if ($3 == 1) return 0,10
      elseif ($3 == 2) return 11,35
      elseif ($3 == 3) return 35,45
      else return 3 20
    }
    if ($2 == statius) {
      if ($3 == 1) return 0,15
      elseif ($3 == 2) return 15,35
      elseif ($3 == 3) return 30,65
      else return 4 25
    }
    if ($2 == dmace) {
      if ($3 == 1) return 0,0
      elseif ($3 == 2) return 5,25
      elseif ($3 == 3) return 26,45
      else return 4 60
    }
    if ($2 == dds) {
      if ($3 == 1) return 0,0
      elseif ($3 == 2) return 0,15
      elseif ($3 == 3) return 10,20
      else return 5 32
    }
    if ($2 == dhally) {
      if ($3 == 1) return 0,0
      elseif ($3 == 2) return 5,20
      elseif ($3 == 3) return 20,35
      else return 5 50
    }
    if ($2 == gmaul) {
      if ($3 == 1) return 0,8
      elseif ($3 == 2) return 0,20
      elseif ($3 == 3) return 14,25
      else return 20 50
    }
    if ($2 == dclaws) {
      if ($3 == 1) return 0,10
      elseif ($3 == 2) return 10,24
      elseif ($3 == 3) return 24,24
      else return 8 50
    }
    if ($2 == dh) {
      if ($3 == 1) || ($3 == 2) || ($3 == 3) return 1,40
      else return 10 20
    }
    if ($2 == dh9) {
      if ($3 == 1) || ($3 == 2) || ($3 == 3) return 5,75
      else return 10 20
    }
  }
}

alias specused {
  if ($1 == dbow) return 75
  elseif ($1 == mjavelin) return 25
  elseif ($1 == dds) return 25
  elseif ($1 == ags) return 50
  elseif ($1 == bgs) return 100
  elseif ($1 == sgs) return 50
  elseif ($1 == zgs) return 50
  elseif ($1 == gmaul) return 100
  elseif ($1 == dclaws) return 50
  elseif ($1 == dmace) return 50
  elseif ($1 == dhally) return 75
  elseif ($1 == dlong) return 25
  elseif ($1 == vlong) return 50
  elseif ($1 == vspear) return 50
  elseif ($1 == statius) return 100
  else return $false
}

alias bonus {
  if ($1 == cbow) return 3 $+ $chr(37) chance of hitting 50-69 $+ $chr(44) void or accumulator required
  elseif ($1 == ice) return 1/3 Chance of freezing your opponent for one turn
  elseif ($1 == blood) return Heals 1/3 of whatever you hit
  elseif ($1 == dds) return 1/3 Chance of poisoning opponent
  elseif ($1 == sgs) return Heals 1/2 of whatever you hit
  elseif ($1 == zgs) return 1/2 Chance of freezing your opponent for one turn
  elseif ($1 == vlong) return Ignores all defence bonuses
  elseif ($1 == vspear) return Freezes your opponent for one turn
  elseif ($1 == guth) return 1/3 Chance of healing whatever you hit
  elseif ($1 == statius) return Ignores all defence bonuses
  elseif ($1 == surf) return Highly accurate and ignores all defence bonuses
  elseif ($1 == smoke) return 1/2 Chance of poisoning opponent
  elseif ($1 == onyx) return Heals 1/3 of whatever you hit
  elseif ($1 == dh) return !hitchance dh9

}

alias doeswhat {
  if ($1 == cbow) return shoots a dragon bolt at
  elseif ($1 == vlong) return thrusts towards
  elseif ($1 == vspear) return stuns
  elseif ($1 == statius) return critically injures
  elseif ($1 == mjavelin) return impales
  elseif ($1 == sgs) return crushes
  elseif ($1 == ags) return whirls around and slashes at
  elseif ($1 == zgs) return cleaves
  elseif ($1 == bgs) return dismembers
  elseif ($1 == guth) return stabs at
  elseif ($1 == blood) return casts at
  elseif ($1 == ice) return casts above
  elseif ($1 == smoke) return casts about
  elseif ($1 == dbow) return fires two dragon arrows towards
  elseif ($1 == whip) return slashes
  elseif ($1 == dds) return stabs
  elseif ($1 == dclaws) return scratches
  elseif ($1 == surf) return uses surf on
  elseif ($1 == gmaul) return whacks at
  elseif ($1 == dh) return crushes
  elseif ($1 == dscim) return severs
  elseif ($1 == dlong) return hacks
  elseif ($1 == dmace) return smashes
  elseif ($1 == dhally) return swipes
  elseif ($1 == onyx) return shoots at
}

alias splasher {
  if ($1 == ice) return 1
  elseif ($1 == blood) return 1
  elseif ($1 == smoke) return 1
  else return 0
}

alias attack {
  if ($istok(whip dds ags bgs sgs zgs dh gmaul guth surf dclaws dmace dhally dscim dlong vlong vspear statius mjavelin cbow dbow ice blood smoke onyx,$1,32)) {
    return $true
  }
}

alias attackname {
  if ($storename($1)) return $v1
  elseif ($1 == whip) return Abyssal Whip
  elseif ($1 == dds) return Dragon Dagger
  elseif ($1 == dh) return Dharok's Greataxe
  elseif ($1 == gmaul) return Granite Maul
  elseif ($1 == guth) return Guthan's Warspear
  elseif ($1 == surf) return Mudkip
  elseif ($1 == dmace) return Dragon Mace
  elseif ($1 == dhally) return Dragon Halberd
  elseif ($1 == dscim) return Dragon Scimitar
  elseif ($1 == dlong) return Dragon Longsword
  elseif ($1 == cbow) return Crossbow
  elseif ($1 == dbow) return Dark Bow
  elseif ($1 == ice) return Ice Barrage
  elseif ($1 == blood) return Blood Barrage
  elseif ($1 == smoke) return Smoke Barrage
  elseif ($1 == onyx) return Onyx Bolt
  elseif ($1 == vspear) return Vesta's Spear
  elseif ($1 == vlong) return Vesta's Longsword
  elseif ($1 == statius) return Statius's Warhammer
  elseif ($1 == mjavelin) return Morrigan's Javelin
  else return $null 
}

alias ispvp {
  if ($1 == mjavelin) return 1
  elseif ($1 == statius) return 1
  elseif ($1 == vlong) return 1
  elseif ($1 == vspear) return 1
  else return 0
}

alias isweapon {
  if ($1 == ags) return 1
  elseif ($1 == bgs) return 1
  elseif ($1 == mudkip) return 1
  elseif ($1 == sgs) return 1
  elseif ($1 == zgs) return 1
  elseif ($1 == dclaws) return 1
  else return 0
}

alias freezer {
  ;The number is the chance of it freezing (Ice is 1/3).
  if ($1 == ice) return 3
  elseif ($1 == vspear) return 1
  elseif ($1 == zgs) return 2
  else return $false
}

alias healer {
  ;The first number is the chance of it healing (Sgs is 1/1).
  ;The second number is how much is heals (Sgs heals 1/2).
  if ($1 == guth) return 3 1
  elseif ($1 == sgs) return 1 2
  elseif ($1 == blood) return 1 3
  elseif ($1 == onyx) return 2 3
  else return $false
}

alias poisoner {
  ;The number is the chance of it poisoning (Dds is 1/3).
  if ($1 == dds) return 3
  elseif ($1 == smoke) return 2
  else return $false
}

on $*:TEXT:/^[!@.]max/Si:#: {
  if (# == #idm) || (# == #idm.Staff) && ($me != iDM) { halt }
  if (!$2) { $iif($left($1,1) == @,msg #,notice $nick) Please specify the weapon to look up. Syntax: !max whip | halt }
  if (!$attack($2)) {
    notice $nick $logo(ERROR) $s1($2) is not a recognized attack.
    halt
  }
  if ($max(r,$2)) { $iif($left($1,1) == @,msg #,notice $nick) $logo(MAX) $upper($2) $+ $iif($specused($2),$+($chr(32),$chr(40),$s1($v1 $+ $chr(37)),$chr(41))) $+ : $s2($gettok($max(r,$2),1,32)) $iif($totalhit(r,$2,1),$+($chr(40),$s2($v1),$chr(41))) $c124 Void range or Accumulator $s2($gettok($max(r,$2),2,32)) $iif($totalhit(r,$2,2),$+($chr(40),$s2($v1),$chr(41))) $c124 Void range and Accumulator $s2($gettok($max(r,$2),3,32)) $iif($totalhit(r,$2,3),$+($chr(40),$s2($v1),$chr(41))) $iif($bonus($2),$+($chr(40),$v1,$chr(41))) }
  elseif ($max(ma,$2)) { $iif($left($1,1) == @,msg #,notice $nick) $logo(MAX) $upper($2) $+ $iif($specused($2),$+($chr(32),$chr(40),$1($v1 $+ $chr(37)),$chr(41))) $+ : $s2($gettok($max(ma,$2),1,32)) $iif($totalhit(ma,$2,1),$+($chr(40),$s2($v1),$chr(41))) $c124 Void mage or Mage's book or God Cape $s2($gettok($max(ma,$2),2,32)) $iif($totalhit(ma,$2,2),$+($chr(40),$s2($v1),$chr(41))) $c124 Two bonuses $s2($gettok($max(ma,$2),3,32)) $iif($totalhit(ma,$2,3),$+($chr(40),$s2($v1),$chr(41))) $c124 Three bonuses $s2($gettok($max(ma,$2),4,32)) $iif($totalhit(ma,$2,4),$+($chr(40),$s2($v1),$chr(41))) $iif($bonus($2),$+($chr(40),$v1,$chr(41))) }
  elseif ($max(m,$2)) { $iif($left($1,1) == @,msg #,notice $nick) $logo(MAX) $upper($2) $+ $iif($specused($2),$+($chr(32),$chr(40),$s1($v1 $+ $chr(37)),$chr(41))) $+ $iif($2 == dh,$+($chr(32),$chr(40),10+ HP/9 or less HP,$chr(41))) $+ : $s2($gettok($max(m,$2),1,32)) $iif($totalhit(m,$2,1),$+($chr(40),$s2($v1),$chr(41))) $c124 Barrow gloves $s2($gettok($max(m,$2),2,32)) $iif($totalhit(m,$2,2),$+($chr(40),$s2($v1),$chr(41))) $c124 Fire cape $s2($gettok($max(m,$2),3,32)) $iif($totalhit(m,$2,3),$+($chr(40),$s2($v1),$chr(41))) $c124 Barrow gloves and Fire cape $s2($gettok($max(m,$2),4,32)) $iif($totalhit(m,$2,4),$+($chr(40),$s2($v1),$chr(41))) $iif($bonus($2),$+($chr(40),$v1,$chr(41))) }
  else notice $nick $logo(ERROR) $s1($2) is not a recognized attack.
}
alias c124 { return $chr(124) }

on $*:TEXT:/^[!@.]hitchance/Si:#: {
  if (# == #idm) || (# == #idm.Staff) && ($me != iDM) { halt }
  if (!$3) { $iif($left($1,1) == @,msg #,notice $nick) Syntax: !hitchance <weapon> <damage> | halt }
  if (!$attack($2) && $2 != dh9) { notice $nick $logo(ERROR) $s1($2) is not a recognized attack. | halt }
  if ($max(r,$2)) var %t = r
  elseif ($max(ma,$2)) var %t = ma
  else var %t = m
  var %lowchance = $calc(($gettok($dmg(%t, $2),1,32)) /100)
  var %midchance = $calc(($gettok($dmg(%t, $2),2,32) - $gettok($dmg(%t, $2),1,32)) /100)
  var %highchance = $calc((100 - $gettok($dmg(%t, $2),2,32)) /100)
  var %lowbot = $gettok($dmg(%t, $2, 1),1,44)
  var %lowtop = $gettok($dmg(%t, $2, 1),2,44)
  var %midbot = $gettok($dmg(%t, $2, 2),1,44)
  var %midtop = $gettok($dmg(%t, $2, 2),2,44)
  var %highbot = $gettok($dmg(%t, $2, 3),1,44)
  var %hightop = $gettok($dmg(%t, $2, 3),2,44)
  if ($3 <=  %lowtop) {
    if ($3 >= %lowbot) var %lowchance = $calc(((%lowtop - $3 +1) / (%lowtop - %lowbot +1 )) * %lowchance)
  }
  else {  var %lowchance = 0 }
  if ($3 <=  %midtop) {
    if ($3 >= %midbot) var %midchance = $calc(((%midtop - $3 +1) / (%midtop - %midbot +1 )) * %midchance)
  }
  else { var %midchance = 0 }
  if ($3 <= %hightop) {
    if ($3 >= %highbot) var %highchance = $calc(((%hightop - $3 +1) / (%hightop - %highbot +1 )) * %highchance)
  }
  else { var %highchance = 0 }
  $iif($left($1,1) == @,msg #,notice $nick) $logo(HITCHANCE) There is a $s2($floor($calc(( %lowchance + %midchance + %highchance) * 100)) $+ %) chance of $2 hitting $s1($3) or higher each hit without bonuses.  Use !max $2 to check bonuses and special infomation.
}

alias totalhit {
  if (- isin $max($1,$2)) {
    return $calc($gettok($gettok($v2,$3,32),1,45) + $gettok($gettok($v2,$3,32),2,45) + $gettok($gettok($v2,$3,32),3,45) + $gettok($gettok($v2,$3,32),4,45))
  }
  return $false
}
