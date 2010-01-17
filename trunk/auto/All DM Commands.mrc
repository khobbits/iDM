on $*:TEXT:/^[!.]/Si:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  var %attcmd $right($1,-1)
  if ($hget($chan)) && ($nick == $hget($chan,p1) && ($hget($chan,p2))) {
    var %p2 $hget($chan,p2)
    if (%attcmd == specpot) {
      if (!$hget($nick,specpot)) { notice $nick You don't have any specpots. | halt }
      if ($hget($nick,sp) == 4) { notice $nick You already have a full special bar. | halt }
      hadd $nick sp 4
      db.set equip_item specpot $nick - 1
      hadd $nick laststyle pot
      if ($hget(%p2,poison) >= 1) && ($hget(%p2,hp) >= 1) {
        var %extra = $iif($hget(%p2,hp) < $hget(%p2,poison),$v1,$v2)
        hdec %p2 poison
        hdec %p2 hp %extra
        msgsafe # $logo(DM) $s1($nick) drinks their specpot and now has 100% special.  Poison hit $s1(%p2) for 03 $+ %extra $+  damage. $hpbar($hget(%p2,hp))
      }
      else {
        msgsafe # $logo(DM) $s1($nick) drinks their specpot and now has 100% special.
      }
    }
    elseif ($attack(%attcmd)) {
      if ($calc($specused($right($1,-1)) /25) > $hget($nick,sp)) {
        notice $nick $logo(ERROR) You need $s1($specused($right($1,-1)) $+ $chr(37)) spec to use this weapon.
        halt
      }
      if ($isdisabled($chan,%attcmd)) {
        notice $nick $logo(ERROR) This command has been disabled for this channel.
        halt
      }
      if ($hget($nick,frozen)) && ($max(m,%attcmd)) {
        notice $nick You're frozen and can't use melee.
        halt
      }
      if ($ispvp(%attcmd)) {
        if (!$hget($nick,%attcmd)) {
          notice $nick You don't have this weapon.
          halt
        }
        db.set equip_pvp %attcmd $nick - 1
      }
      var %wep $replace(%attcmd,surf,mudkip)
      if ($isweapon(%wep)) {
        if (!$hget($nick,%wep)) {
          notice $nick You have to unlock this weapon before you can use it.
          halt
        }
      }
      set -u25 %enddm [ $+ [ $chan ] ] 0
      damage $nick %p2 %attcmd #
    }
    else { halt }
    if ($hget(%p2,hp) < 1) {
      if (<iDM>* iswm %p2) dead $chan iDM $nick
      else dead $chan %p2 $nick
      halt
    }
    if ($specused(%attcmd)) {
      hdec $nick sp $calc($specused(%attcmd) /25)
      notice $nick Specbar: $iif($hget($nick,sp) < 1,0,$gettok(25 50 75 100,$hget($nick,sp),32)) $+ $chr(37)
    }
    hadd $nick frozen 0
    hadd $chan p1 %p2
    hadd $chan p2 $nick
    if (<iDM>* iswm %p2) { autoidm.turn $chan }
	return
  }
  elseif ($hget($nick) && $hget($nick,$chan) == $chan && $hget($nick,g)) {
    gwd.att $nick $hget($nick,g) $1 $chan
	return
  }
}

alias damage {
  ;1 is person attacking
  ;2 is other person
  ;3 is weapon
  ;4 is chan

  var %hp1 $hget($1,hp)
  var %hp2 $hget($2,hp)

  if ($3 == dh) {
    if (%hp1 < 10) { var %hit $hit(d_h9,$1,$2,$4) }
    else { var %hit $hit(d_h10,$1,$2,$4) }
  }
  else {
    var %hit $hit($3,$1,$2,$4)
  }

  var %i = 1
  var %hitshow
  while (%i <= $numtok(%hit,32)) {
    if (%i != 1) var %hitshow %hitshow -
    var %hitdmg $gettok(%hit,%i,32)
    if (%hp2 == 0) {
      var %hit $puttok(%hit,KO,%i,32)
      var %hitshow %hitshow 4KO
    }
    elseif (%hp2 <= %hitdmg) {
      var %hit $puttok(%hit,%hp2,%i,32)
      var %hitshow %hitshow $s2(%hp2)
      var %hp2 0
    }
    else {
      dec %hp2 %hitdmg
      var %hitshow %hitshow $s2(%hitdmg)
    }
    inc %i
  }
  var %msg $logo(DM) $s1($1)

  if (($3 == cbow) && (%cbowspec [ $+ [ $1 ] ])) {
    var %msg %msg 5UNLEASHES a dragon bolt special on $s1($replace($2,$chr(58),$chr(32)))
    unset %cbowspec [ $+ [ $1 ] ]
  }
  else {
    var %msg %msg $doeswhat($3) $s1($replace($2,$chr(58),$chr(32)))
  }

  if ($splasher($3)) {
    if (%hitdmg == 0) {
      var %msg %msg using $attackname($3) and splashed
    }
    else {
      var %msg %msg using $attackname($3) hitting %hitshow
    }
  }
  else {
    var %msg %msg with their $attackname($3) hitting %hitshow
  }

  if ($freezer($3)) {
    var %freeze $r(1,$v1)
    if ((%freeze == 1) && (%hitdmg >= 1)) {
      hadd $2 frozen 1
      if (<iDM>* !iswm $2) { notice $2 You have been frozen and can't use melee! }
      var %msg %msg and successfully 12FREEZES them
    }
    else {
      var %msg %msg and fails to freeze them
    }
  }

  var %heal 0
  if ($gettok($healer($3),1,32)) {
    var %heal $r(1,$v1)
    if (%heal == 1) && (%hitdmg != 0) && (%hp1 < 99) {
      $iif($calc($floor(%hp1) + $floor($calc(%hit / $gettok($healer($3),2,32)))) > 99,set %hp1 99,inc %hp1 $floor($calc(%hit / $gettok($healer($3),2,32))))
      var %msg %msg and 09HEALING
    }
  }

  if ($poisoner($3)) {
    var %pois.chance $r(1,$v1)
    if (%pois.chance == 1) || ($hget($1,snake)) && (!$hget($2,poison)) {
      hadd $2 poison 6
    }
  }
  if ($hget($2,poison) >= 1) && (%hp2 >= 1) {
    var %extra $iif(%hp2 < $hget($2,poison),$v1,$v2)
    hdec $2 poison
    dec %hp2 %extra
    var %msg %msg - 03 $+ %extra $+ 
  }

  if (%heal == 1) {
    var %msg %msg $+ . $s1($replace($2,$chr(58),$chr(32))) $hpbar(%hp2) - $s1($replace($1,$chr(58),$chr(32))) $hpbar(%hp1)
  }
  else {
    var %msg %msg $+ . $hpbar(%hp2)
  }

  msgsafe $4 %msg

  if ($max(m,$3)) { hadd $1 laststyle melee }
  elseif ($max(ma,$3)) { hadd $1 laststyle mage }
  elseif ($max(r,$3)) { hadd $1 laststyle range }

  if ($hget($4,stake) == $null) {

    if ($hget(belong,$1)) && ($r(1,100) >= 99) && (%hp2 >= 1) {
      var %extra $iif(%hp2 < 12,$($v1,2),12)
      dec %hp2 %extra
      msgsafe $4 $logo(DM) $s1($1) whips out their Bêlong Blade and deals $s2(%extra) extra damage. $hpbar(%hp2)
    }
    if ($hget($2,allegra)) && ($r(1,100) >= 99) && (%hp2 >= 1) && (%hp2 < 99) {
      var %extraup $iif(%hp2 >= 84,$calc(99- %hp2),15)
      inc %hp2 %extraup
      msgsafe $4 $logo(DM) Allêgra gives $s1($2) Allergy pills, healing $s2(%extraup) HP. $hpbar(%hp2)
    }
    elseif ($hget($2,kh)) && ($r(1,100) >= 99) && (%hp2 >= 1) {
      inc %hp2 $calc($replace(%hit,$chr(32),$chr(43)))
      msgsafe $4 $logo(DM) KHobbits uses his KHonfound Ring to let $s1($2) avoid the damage. $hpbar(%hp2)
    }
    elseif ($hget($2,support)) && ($r(1,100) >= 99) && (%hp2 >= 1) {
      var %temp.hit $calc($replace(%hit,$chr(32),$chr(43)))
      inc %hp2 $floor($calc(%temp.hit / 2))
      msgsafe $4 $logo(DM) $s1($2) uses THE SUPPORTER to help defend against $s1($1) $+ 's attacks. $hpbar(%hp2)
    }
  }

  if (%hp2 < 1) {
    if ($hget($2,beau)) && ($r(1,50) >= 49) && ($hget($4,stake) == $null) {
      var %hp2 1
      msgsafe $4 $logo(DM) $s1($2) $+ 's Bêaumerang brings them back to life, barely. $hpbar(%hp2)
    }
  }
  hadd $1 hp %hp1
  hadd $2 hp %hp2
}


alias hpbar {
  if (-* iswm $1) { tokenize 32 0 }
  elseif ($1 !isnum 0-99) { tokenize 32 99 }
  if ($1 isnum 46-50) return HP 3,3 $+ $str($chr(58),9) $+ 00 $+ $left($1,1) $+ 0,04 $+ $right($1,1) $+ 4 $+ $str($chr(46),9) $+ 
  if ($1 < 46) return HP 3,3 $+ $str($chr(58),$ceil($calc( $1 /5)))) $+ 4,4 $+ $str($chr(46),$calc(9 - $ceil($calc( $1 /5))))) $+ 00 $+ $right($chr(32) $+ $iif($1 == 0,KO,$v1),2) $+ 4 $+ $str($chr(46),9) $+ 
  return HP 3,3 $+ $str($chr(58),9) $+ 00 $+ $1 $+ 3 $+ $str($chr(58),$ceil($calc(( $1 /5) -11)))) $+ 4,4 $+ $str($chr(46),$calc(20 - $ceil($calc( $1 /5))))) $+ 
}

alias accuracy {
  ;1 is Attack
  ;2 is Attackee
  if ($istok(melee mage range,$hget($2,laststyle),32)) {
    if ($max(m,$1)) {
      if ($hget($2,laststyle) == melee) return 0
      elseif ($hget($2,laststyle) == mage) return -1
      elseif ($hget($2,laststyle) == range) return 1
    }
    elseif ($max(ma,$1)) {
      if ($hget($2,laststyle) == melee) return 1
      elseif ($hget($2,laststyle) == mage) return 0
      elseif ($hget($2,laststyle) == range) return -1
    }
    elseif ($max(r,$1)) {
      if ($hget($2,laststyle) == melee) return -1
      elseif ($hget($2,laststyle) == mage) return 1
      elseif ($hget($2,laststyle) == range) return 0
    }
  }
  return 0
}

alias hit {
  ;1 is Weapon
  ;2 is Attacker
  ;3 is Attackee
  ;4 is Chan
  if ($accuracy($1,$3) == -1) { var %acc $r(1,80) }
  elseif ($accuracy($1,$3) == 1) { var %acc $r(15,100) }
  else { var %acc $r(1,100) }

  var %atk $calc($iif($hget($2,firecape),5,0) + $iif($hget($2,bgloves),3,0))
  var %def $iif($hget($3,elshield),$calc($r(85,99) / 100),1)
  var %ratk $calc($iif($hget($2,void),5,0) + $iif($hget($2,accumulator),5,0))
  var %matk $calc($iif($hget($2,void-mage),5,0) + $iif($hget($2,mbook),5,0) + $iif($hget($2,godcape),5,0))

  goto $1
  :whip
  return $hitdmg(m,whip,%acc,1,%atk,%def)
  :dds
  return $hitdmg(m,dds,%acc,2,%atk,%def)
  :ags
  return $hitdmg(m,ags,%acc,1,%atk,%def)
  :cbow
  if (%acc isnum 98-100) && ($hget(>equiphit,void) || $hget(>equiphit,accumulator)) { set %cbowspec [ $+ [ $2 ] ] 1 | return $r(50,65) }
  return $hitdmg(r,cbow,%acc,1,%ratk,%def)
  :dbow
  return $hitdmg(r,dbow,%acc,2,%ratk,%def)
  :bgs
  return $hitdmg(m,bgs,%acc,1,%atk,%def)
  :sgs
  return $hitdmg(m,sgs,%acc,1,%atk,%def)
  :gmaul
  return $hitdmg(m,gmaul,%acc,3,%atk,%def)
  :guth
  return $hitdmg(m,guth,%acc,1,%atk,%def)
  :ice
  return $hitdmg(ma,ice,%acc,1,%matk,%def)
  :zgs
  return $hitdmg(m,zgs,%acc,1,%atk,%def)
  :blood
  return $hitdmg(ma,blood,%acc,1,%matk,%def)
  :smoke
  return $hitdmg(ma,smoke,%acc,1,%matk,%def)
  :surf
  return $hitdmg(r,surf,%acc,1,0,1)
  :dclaws
  var %dclaws $hitdmg(m,dclaws,%acc,1,%atk,%def)
  return %dclaws $ceil($calc(%dclaws * 0.5)) $ceil($calc(%dclaws * 0.25)) $ceil($calc(%dclaws * 0.125))
  :dmace
  return $hitdmg(m,dmace,%acc,1,%atk,%def)
  :dscim
  return $hitdmg(m,dscim,%acc,1,%atk,%def)
  :dlong
  return $hitdmg(m,dlong,%acc,1,%atk,%def)
  :dhally
  return $hitdmg(m,dhally,%acc,2,%atk,%def)
  :d_h9
  return $hitdmg(m,dh9,%acc,1,%atk,%def)
  :d_h10
  return $hitdmg(m,dh,%acc,1,%atk,%def)
  :vlong
  return $hitdmg(m,vlong,%acc,1,%atk,1)
  :statius
  return $hitdmg(m,statius,%acc,1,%atk,1)
  :vspear
  return $hitdmg(m,vspear,%acc,1,%atk,%def)
  :mjavelin
  return $hitdmg(r,mjavelin,%acc,1,%ratk,%def)
  :onyx
  return $hitdmg(r,onyx,%acc,1,%ratk,%def)
  :snow
  return $hitdmg(r,snow,%acc,3,0,1)
}

alias hitdmg {
  ; $1 = r/ma/m
  ; $2 = attack
  ; $3 = accuracy
  ; $4 = number of hits
  ; $5 = attack bonus
  ; $6 = defense bonus
  if ($6) {
    var %acclimit $dmg($1,$2)
    if ($3 <= $gettok(%acclimit,1,32)) {
      var %ndmg $dmg($1,$2,1)
    }
    elseif ($3 <= $gettok(%acclimit,2,32)) {
      var %ndmg $dmg($1,$2,2)
    }
    else {
      var %ndmg $dmg($1,$2,3)
    }
    var %i = 0
    while (%i < $4) {
      inc %i
      var %dmg = $rand($gettok(%ndmg,1,44),$calc($gettok(%ndmg,2,44) + $5)))
      var %dmg = $ceil($calc(%dmg * $6))
      var %return = %return %dmg
    }
    return %return
  }
  return
}
