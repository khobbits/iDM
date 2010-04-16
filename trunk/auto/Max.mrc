alias max {
  if ($dmg($1,type) == range) {
    ;Normal Voidrange_or_Accumulator Both
    var %dmg = $dmg.maxhit($1, 3)
    if (%dmg == $null) { return }
    elseif ($1 == surf) return %dmg %dmg %dmg
    elseif ($1 == dbow) return $+(%dmg,-,%dmg) $+($calc(%dmg +5),-,$calc(%dmg +5)) $+($calc(%dmg +10),-,$calc(%dmg +10))
    elseif ($1 == snow) return $+(%dmg,-,%dmg,-,%dmg) $+(%dmg,-,%dmg,-,%dmg) $+(%dmg,-,%dmg,-,%dmg)
    else return %dmg $calc(%dmg +5) $calc(%dmg +10)
  }
  elseif ($dmg($1,type) == magic) {
    ;Normal Voidmage_or_MagesBook_or_GodCape Two_Bonuses Three_Bonuses
    var %dmg = $dmg.maxhit($1, 3)
    if (%dmg == $null) { return }
    else return %dmg $calc(%dmg +5) $calc(%dmg +10) $calc(%dmg +15)
  }
  elseif ($dmg($1,type) == melee) {
    ;Normal Barrowgloves Firecape Both
    var %dmg = $dmg.maxhit($1, 3)
    if (%dmg == $null) { return }
    elseif ($1 == dds) return $+(%dmg,-,%dmg) $+($calc(%dmg +3),-,$calc(%dmg +3)) $+($calc(%dmg +5),-,$calc(%dmg +5)) $+($calc(%dmg +8),-,$calc(%dmg +8))
    elseif ($1 == dbow) return $+(%dmg,-,%dmg) $+($calc(%dmg +3),-,$calc(%dmg +3)) $+($calc(%dmg +5),-,$calc(%dmg +5)) $+($calc(%dmg +8),-,$calc(%dmg +8))
    elseif ($1 == dhally) return $+(%dmg,-,%dmg) $+($calc(%dmg +3),-,$calc(%dmg +3)) $+($calc(%dmg +5),-,$calc(%dmg +5)) $+($calc(%dmg +8),-,$calc(%dmg +8))
    elseif ($1 == gmaul) return $+(%dmg,-,%dmg,-,%dmg) $+($calc(%dmg +3),-,$calc(%dmg +3),-,$calc(%dmg +3)) $+($calc(%dmg +5),-,$calc(%dmg +5),-,$calc(%dmg +5)) $+($calc(%dmg +8),-,$calc(%dmg +8),-,$calc(%dmg +8))
    elseif ($1 == dclaws) return $dmg.dclaws(%dmg,0) $dmg.dclaws(%dmg,3) $dmg.dclaws(%dmg,5) $dmg.dclaws(%dmg,8)
    elseif ($1 == dh) {
      var %dmg2 = $dmg.maxhit($1, 1)
      return $+(%dmg2,/,%dmg) $+($calc(%dmg2 +3),/,$calc(%dmg +3)) $+($calc(%dmg2 +5),/,$calc(%dmg +5)) $+($calc(%dmg2 +8),/,$calc(%dmg +8))
    }
    else return %dmg $calc(%dmg +3) $calc(%dmg +5) $calc(%dmg +8)
  }
}

alias dmg.maxhit { return $gettok($dmg($1, $2),2,44) }
alias dmg.dclaws { return $+($calc($1 + $2),-,$ceil($calc(($1 + $2) * 0.5)),-,$ceil($calc(($1 + $2) * 0.25)),-,$ceil($calc(($1 + $2) * 0.125))) }

alias hitdmg {
  ; $1 = attack
  ; $2 = accuracy
  ; $3 = hit pattern
  ; $4 = attack bonus
  ; $5 = defense bonus
  if ($5) {
    var %acclimit $dmg($1)
    if ($1 == dh_9) { var %ndmg $dmg(dh,3) }
    elseif ($1 == dh_10) { var %ndmg $dmg(dh,1) }
    elseif ($2 <= $gettok(%acclimit,1,44)) { var %ndmg $dmg($1,1) }
    elseif ($2 <= $gettok(%acclimit,2,44)) { var %ndmg $dmg($1,2) }
    else { var %ndmg $dmg($1,3) }

    var %i = 0
    while (%i < $numtok($3,45)) {
      inc %i
      if ($gettok($3,%i,45) == 1) {
        var %dmg = $rand($gettok(%ndmg,1,44),$calc($gettok(%ndmg,2,44) + $4)))
        var %dmg = $ceil($calc(%dmg * $5))
        var %return = %return %dmg
      }
      else {
        var %sdmg = $ceil($calc(%dmg * (1 / $gettok($3,%i,45))))
        var %return = %return %sdmg
      }
    }
    return %return
  }
  return
}

alias dmg.hload {
  if ($hget(>weapon)) { hfree >weapon }
  hmake >weapon 50
  var %sql SELECT * FROM weapon
  var %res $db.query(%sql)
  while ($db.query_row(%res, >row)) {
    hadd >weapon $hget(>row, weapon) $+ .name $hget(>row, name)
    hadd >weapon $hget(>row, weapon) $+ .0 $hget(>row, range)
    hadd >weapon $hget(>row, weapon) $+ .1 $hget(>row, low)
    hadd >weapon $hget(>row, weapon) $+ .2 $hget(>row, mid)
    hadd >weapon $hget(>row, weapon) $+ .3 $hget(>row, high)
    hadd >weapon $hget(>row, weapon) $+ .hits $hget(>row, hits)
    hadd >weapon $hget(>row, weapon) $+ .type $hget(>row, type)
    hadd >weapon $hget(>row, weapon) $+ .atkbonus $hget(>row, atkbonus)
    hadd >weapon $hget(>row, weapon) $+ .defbonus $hget(>row, defbonus)
    hadd >weapon $hget(>row, weapon) $+ .spec $hget(>row, spec)
    hadd >weapon $hget(>row, weapon) $+ .poison $hget(>row, poison)
    hadd >weapon $hget(>row, weapon) $+ .freeze $hget(>row, freeze)
    hadd >weapon $hget(>row, weapon) $+ .heal $hget(>row, healchance) $hget(>row, healamount)
    hadd >weapon $hget(>row, weapon) $+ .splash $hget(>row, splash)
    hadd >weapon $hget(>row, weapon) $+ .what $hget(>row, what)
    hadd >weapon $hget(>row, weapon) $+ .effect $hget(>row, effect)
  }
  mysql_free %res
}

alias dmg.hget {
  if (!$hget(>weapon)) { dmg.hload }
  tokenize 32 $1- 0
  return $hget(>weapon,$1 $+ . $+ $2)
}

alias dmg {
  ; $1 = attack
  ; $2 = 1/2/3 = low/med/high
  return $dmg.hget($gettok($1,1,95),$2)
}

alias attackname { return $dmg($1,name) }
alias specused { return $calc($dmg($1,spec) * 25) }
alias poisoner { return $dmg($1,poison) }
alias freezer { return $dmg($1,freeze) }
alias healer { return $dmg($1,heal) }
alias splasher { return $dmg($1,splash) }
alias doeswhat { return $dmg($1,what) }
alias effect { return $dmg($1,effect) }
alias attack { return $iif($dmg($1,name),$true,$false) }

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
  elseif ($1 == snow) return 1
  elseif ($1 == corr) return 1
  else return 0
}

on $*:TEXT:/^[!@.]max/Si:#: {
  if (# == #idm) || (# == #idm.Staff) && ($me != iDM) { halt }
  if ($update) { notice $nick $logo(ERROR) IDM is currently disabled, please try again shortly | halt }
  if (!$2) { $iif($left($1,1) == @,msgsafe #,notice $nick) Please specify the weapon to look up. Syntax: !max whip | halt }
  if (!$attack($2)) {
    notice $nick $logo(ERROR) $s1($2) is not a recognized attack.
    halt
  }
  if (!$max($2)) notice $nick $logo(ERROR) $s1($2) is not a recognized attack.
  var %msg $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(MAX) $upper($2) $iif($specused($2),$+($chr(32),$chr(40),$s1($v1 $+ $chr(37)),$chr(41)))
  var %msg %msg $+ $iif($2 == dh,$+($chr(32),$chr(40),10+ HP/9 or less HP,$chr(41))) $+ : $dmg.breakdown($2,1) $chr(124)

  if ($dmg($2,type) == range) { var %msg %msg Void range or Accumulator $dmg.breakdown($2,2) $c124 Void range and Accumulator $dmg.breakdown($2,3) }
  if ($dmg($2,type) == magic) { var %msg %msg Void mage or Mage's book or God Cape $dmg.breakdown($2,2) $chr(124) Two bonuses $dmg.breakdown($2,3) $chr(124) Three bonuses $dmg.breakdown($2,4) }
  if ($dmg($2,type) == melee) { var %msg %msg Barrow gloves $dmg.breakdown($2,2) $chr(124) Fire cape $dmg.breakdown($2,3) $chr(124) Barrow gloves and Fire cape $dmg.breakdown($2,4) }
  %msg $iif($effect($2),$+($chr(40),$v1,$chr(41)))
}

alias dmg.breakdown return $s2($gettok($max($1),$2,32)) $iif($totalhit($1,$2),$+($chr(40),$s2($v1),$chr(41)))

alias totalhit {
  if (- isin $max($1)) {
    return $calc($gettok($gettok($v2,$2,32),1,45) + $gettok($gettok($v2,$2,32),2,45) + $gettok($gettok($v2,$2,32),3,45) + $gettok($gettok($v2,$2,32),4,45))
  }
  return $false
}

on $*:TEXT:/^[!@.]hitchance/Si:#: {
  if (# == #idm) || (# == #idm.Staff) && ($me != iDM) { halt }
  if ($update) { notice $nick $logo(ERROR) IDM is currently disabled, please try again shortly | halt }
  if (!$3) { $iif($left($1,1) == @,msgsafe #,notice $nick) Syntax: !hitchance <weapon> <damage> | halt }
  if (!$attack($2) && $2 != dh9) { notice $nick $logo(ERROR) $s1($2) is not a recognized attack. | halt }

  var %lowchance = $calc(($gettok($dmg($2),1,44)) /100)
  var %midchance = $calc(($gettok($dmg($2),2,44) - $gettok($dmg($2),1,44)) /100)
  var %highchance = $calc((100 - $gettok($dmg($2),2,44)) /100)

  var %lowbot = $gettok($dmg($2, 1),1,44)
  var %lowtop = $gettok($dmg($2, 1),2,44)
  var %midbot = $gettok($dmg($2, 2),1,44)
  var %midtop = $gettok($dmg($2, 2),2,44)
  var %highbot = $gettok($dmg($2, 3),1,44)
  var %hightop = $gettok($dmg($2, 3),2,44)

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
  $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(HITCHANCE) There is a $s2($floor($calc(( %lowchance + %midchance + %highchance) * 100)) $+ %) chance of $2 hitting $s1($3) or higher each hit without bonuses.  Use !max $2 to check bonuses and special infomation.
}
