on $*:TEXT:/^[!.]\w/Si:#: {
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
      if ($hget($nick,frozen)) && ($dmg(%attcmd,type) == melee) {
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
      var %wepitem $isweapon(%attcmd)
      if (%wepitem !== $false) {
        if (!$hget($nick,%wepitem)) {
          notice $nick You have to unlock this weapon before you can use it.
          halt
        }
      }
      .timercw $+ $chan off
      .timerc $+ $chan off
      set -u25 %enddm [ $+ [ $chan ] ] 0
      damage $nick %p2 %attcmd #
    }
    else { halt }
    if ($hget(%p2,hp) < 1) {
      dead $chan $autoidm.acc(%p2) $nick
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
  if ($4 == $null) { putlog Syntax Error: damage (4) - $db.safe($1-) | halt }
  var %hp1 $hget($1,hp)
  var %hp2 $hget($2,hp)

  if ($3 == dh) {
    if (%hp1 < 10) { var %hit $hit(dh_9,$1,$2,$4) }
    else { var %hit $hit(dh_10,$1,$2,$4) }
  }
  else { var %hit $hit($3,$1,$2,$4) }

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

  ; Starting value for one hit acheivement
  var %dmg-dealt %hitdmg

  ; ## OVERRIDE
  if (($3 == cbow) && (%cbowspec [ $+ [ $1 ] ])) {
    var %msg %msg 5UNLEASHES a dragon bolt special on $s1($replace($2,$chr(58),$chr(32)))
    unset %cbowspec [ $+ [ $1 ] ]
  }
  else { var %msg %msg $doeswhat($3) $s1($replace($2,$chr(58),$chr(32))) }

  if ($splasher($3)) {
    if (%hitdmg == 0) { var %msg %msg using $attackname($3) and splashed }
    else { var %msg %msg using $attackname($3) hitting %hitshow }
  }
  else { var %msg %msg with their $attackname($3) hitting %hitshow }

  if ($freezer($3)) {
    var %freeze $r(1,$v1)
    if ((%freeze == 1) && (%hitdmg >= 1)) {
      hadd $2 frozen 1
      if (<iDM>* !iswm $2) { notice $2 You have been frozen and can't use melee! }
      var %msg %msg and successfully 12FREEZES them
    }
    else { var %msg %msg and fails to freeze them }
  }

  var %heal 0
  if ($gettok($healer($3),1,32)) {
    var %heal $r(1,$v1)
    if (%heal == 1) && (%hitdmg != 0) && (%hp1 < 99) {
      $iif($calc($floor(%hp1) + $floor($calc(%hit / $gettok($healer($3),2,32)))) > 99,set %hp1 99,inc %hp1 $floor($calc(%hit / $gettok($healer($3),2,32))))
      var %msg %msg and 09HEALING
    }
  }
  var %poisoner $poisoner($3)
  if ($gettok(%poisoner,1,32)) {
    var %pois.chance $r(1,$v1)
    if (%pois.chance == 1) || (($hget($1,snake)) && (!$hget($2,poison)) && ($gettok(%poisoner,2,32) < 8)) {
      hadd $2 poison $gettok(%poisoner,2,32)
    }
  }
  if ($hget($2,poison) >= 1) && (%hp2 >= 1) {
    var %extra $iif(%hp2 < $hget($2,poison),$v1,$v2)
    hdec $2 poison
    inc %dmg-dealt %extra
    dec %hp2 %extra
    var %msg %msg - 03 $+ %extra $+ 
  }

  if (%heal == 1) { var %msg %msg $+ . $s1($replace($2,$chr(58),$chr(32))) $hpbar(%hp2) - $s1($replace($1,$chr(58),$chr(32))) $hpbar(%hp1) }
  else { var %msg %msg $+ . $hpbar(%hp2) }

  msgsafe $4 %msg

  if ($dmg($3,type) == melee) { hadd $1 laststyle melee }
  elseif ($dmg($3,type) == mage) { hadd $1 laststyle mage }
  elseif ($dmg($3,type) == range) { hadd $1 laststyle range }

  if ($hget($1,belong)) && ($r(1,100) >= 99) && (%hp2 >= 1) {
    var %extra $iif(%hp2 < 12,$($v1,2),12)
    inc %dmg-dealt %extra
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

  if (%hp2 < 1) {
    if (($hget($2,beau)) && ($r(1,50) >= 49) ) {
      var %hp2 1
      msgsafe $4 $logo(DM) $s1($2) $+ 's Bêaumerang brings them back to life, barely. $hpbar(%hp2)
    }
  }
  hadd $1 hp %hp1
  hadd $2 hp %hp2

  if (%dmg-dealt >= 99) { db.set achievements 1hit $nick 1 }
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

    if ($dmg($1,type) == melee) {
      if ($hget($2,laststyle) == melee) return 0
      elseif ($hget($2,laststyle) == mage) return -1
      elseif ($hget($2,laststyle) == range) return 1
    }
    elseif ($dmg($1,type) == magic) {
      if ($hget($2,laststyle) == melee) return 1
      elseif ($hget($2,laststyle) == mage) return 0
      elseif ($hget($2,laststyle) == range) return -1
    }
    elseif ($dmg($1,type) == range) {
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
  if ($4 == $null) { putlog Syntax Error: hit (4) - $db.safe($1-) | halt }
  if ($accuracy($1,$3) == -1) { var %acc $r(1,80) }
  elseif ($accuracy($1,$3) == 1) { var %acc $r(15,100) }
  else { var %acc $r(1,100) }

  var %def $iif($hget($3,elshield),$calc($r(90,98) / 100),1)

  if ($dmg($1,type) == magic) { var %atk $calc($iif($hget($2,void-mage),5,0) + $iif($hget($2,godcape),5,0)) + $iif($hget($2,mbook),5,0)  }
  elseif ($dmg($1,type) == range) { var %atk $calc($iif($hget($2,void),5,0) + $iif($hget($2,accumulator),5,0)) }
  elseif ($dmg($1,type) == melee) { var %atk $calc($iif($hget($2,firecape),5,0) + $iif($hget($2,bgloves),3,0))  }

  if ($dmg($1,atkbonus) == 0) { var %atk 0 }
  if ($dmg($1,defbonus) == 0) { var %def 1 }

  ; ## OVERRIDE
  if ($1 == cbow) && (%acc isnum 98-100) && ($hget($2,void) || $hget($2,accumulator)) { set %cbowspec [ $+ [ $2 ] ] 1 | return $r(50,65) }
  return $hitdmg($1,%acc,$dmg($1,hits),%atk,%def)
}
