on $*:TEXT:/^[!@.](gwd)\b/Si:#: {
  if ($isbanned($nick)) { halt }
  if ((# == #idm.Support) || (# == #idm.help)) && ($nick !isop $chan) { halt }
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if ($update) { notice $nick $logo(ERROR) IDM is currently disabled, please try again shortly | halt }
  if ((%dm.spam [ $+ [ $nick ] ]) || (%wait. [ $+ [ $chan ] ])) { halt }

  if ($isdisabled($chan,gwd) === 1) { notice $nick $logo(ERROR) Godwars raiding in this channel has been disabled. | halt }
  if ($allupdate) { notice $nick $logo(ERROR) DMing is currently disabled, as we're performing an update. | halt }
  if ($regex($nick,/^Unknown[0-9]{5}$/Si)) { notice $Nick You currently have a nick that isn't allowed to use iDM please change it before DMing. | halt }
  if ($isbanned($nick)) { putlog $logo(Banned) $nick tried to dm on $chan | halt }
  if (!$islogged($nick,$address,3)) {  notice $nick You have to login before you can use this command. (To check your auth type: /msg $me id) | halt }

  if ($hget($chan)) {
    ; check if player matches current player
    if ($hget($nick)) { notice $nick You're already in a DM... | inc -u6 %dm.spam [ $+ [ $nick ] ] | halt }
    if ($db.get(user,indm,$nick)) { notice $nick You're already in a DM.. | inc -u6 %dm.spam [ $+ [ $nick ] ] | halt }
    if ($hget($chan,p) || $hget($chan,p1) || $hget($chan,p2)) { notice $nick $logo(DM) People are already DMing in this channel. | inc -u8 %dm.spam [ $+ [ $nick ] ] | halt }
    if ($hget($chan,gi)) { notice $nick $logo(GWD) There is already a GWD in progress. | inc -u8 %dm.spam [ $+ [ $nick ] ] | halt }
    if ($numtok($hget($chan,players),44) == 8) { notice $nick $logo(GWD) There are already $s1(8) people on this team. Please wait untill the raid is over. | halt }
    hinc $chan g
    hadd $chan g $+ $hget($chan,g) $nick
    hadd $chan players $addtok($hget($chan,players),$nick,44)
    hadd $chan gwd.alive $addtok($hget($chan,gwd.alive),$nick,44)
    hadd $chan gwd.turn $addtok($hget($chan,gwd.turn),$nick,44)
    msgsafe # $logo(GWD) $s1($nick) joined the group to go to $+($s1($hget($chan,g0)),!) You've joined as $s2(Player $findtok($hget($chan,players),$nick,1,44))
    db.set user indm $nick 1
  }
  else {
    if ($hget($nick)) { notice $nick You're already in a DM... | inc -u6 %dm.spam [ $+ [ $nick ] ] | halt }
    if ($db.get(user,indm,$nick)) { notice $nick You're already in a DM.. | inc -u6 %dm.spam [ $+ [ $nick ] ] | halt }
    var %dungion $dungion($iif($istok(Bandos Corporeal Zamorak Saradomin Armadyl,$2,32),$2,None))
    hmake $chan 10
    hadd $chan g0 %dungion
    hadd $chan players $nick
    hadd $chan gwd.alive $nick
    hadd $chan gwd.turn $nick
    .timer $+ # 1 30 gwd.run #
    msgsafe # $logo(GWD) $s1($nick) $winloss($nick) is gathering a group to go to $s1(%dungion) $+ ! You have $s2(30 seconds) to join.
  }
  db.set user indm $nick 1
}

alias dungion {
  return $iif($1 == None,$gettok(Corporeal Zamorak Saradomin Bandos Armadyl,$r(1,5),32),$1)
}

alias dungion.hp {
  ; $1 = number of players
  return $calc(200 * $1)
}

alias gwd.run {
  ; $1 = chan
  set -u25 %enddm [ $+ [ $1 ] ] 0
  var %e = $hget($1,players), %x = 1
  while (%x <= $gettok(%e,0,44)) {
    ;loop through players and init them
    playerinit $gettok(%e,%x,44) $1 1
    hadd $gettok(%e,%x,44) g $hget($1,g0)
    inc %x
  }
  ; Init channel settings
  playerinit <gwd> $+ $1 $1 0
  hadd <gwd> $+ $1 hp $dungion.hp($numtok($hget($1,players),44))
  hadd <gwd> $+ $1 mhp $dungion.hp($numtok($hget($1,players),44))
  hadd <gwd> $+ $1 npc 1
  hadd $1 gi 1
  hadd $1 gwdtime $ctime
  msgsafe $1 $logo(GWD) $lower($1) is ready to raid $+($s1($hget($1,g0)),.) Everyone make their attacks, $s1($hget($1,g0)) will hit in $+($s2(30 seconds),.)
  .timer $+ $1 1 30 gwd.npc $1
}

alias gwd.npc {
  ; $1 = chan
  if ($numtok($hget($1,gwd.turn),44) >= 1) {
    var %p2 $gettok($hget($1,gwd.turn),1,44)
  }
  else {
    var %o = $hget($1,gwd.alive), %p2 = $gettok(%o,$r(1,$numtok(%o,44)),44)
  }
  ;hits
  damage <gwd> $+ $1 %p2 $hget($1,g0) $1  

  if ($hget(%p2,hp) < 1) {
    hadd $1 gwd.alive $remtok($hget($1,gwd.alive),%p2,44)
    if ($numtok($hget($1,gwd.alive),44) >= 1) {
      userlog loss %p2 $autoidm.acc(<gwd> $+ $1)
      db.set user losses %p2 + 1
      hadd $1 players $remtok($hget($1,players),%p2,44)
      hadd $1 gwd.turn $remtok($hget($1,gwd.turn),%p2,44)
      db.set user indm %p2 0
      .hfree %p2

      hadd $1 gwd.turn $hget($1,gwd.alive)
      .timer $+ $1 1 30 gwd.npc $1
      halt
    }
    else {
      msgsafe $1 $logo(KO) $s1($autoidm.acc(<gwd> $+ $1)) has killed the last player on the team $+($s1(%p2),.) $+($s1([),Time: $s2($duration($calc($ctime - $hget($1,gwdtime)))),$s1(]))

      userlog loss %p2 $autoidm.acc(<gwd> $+ $1)
      userlog win $autoidm.acc(<gwd> $+ $1) %p2
      db.set user losses %p2 + 1
      db.set user wins $autoidm.acc(<gwd> $+ $1) + 1

      var %sql = INSERT INTO loot_player (`chan`, `cash`, `bot`, `date`, `count`) VALUES ( $db.safe($1) , ' $+ 0 $+ ' , ' $+ $tag $+ ' , CURDATE(), '1' ) ON DUPLICATE KEY UPDATE cash = cash + 0 , count = count+1
      db.exec %sql
      set -u10 %wait. [ $+ [ $1 ] ] on
      .timer 1 10 msgsafe $1 $logo(GWD) Ready.    
      gwdcancel $1
      halt 
    }
  }
  hadd $1 gwd.turn $hget($1,gwd.alive)
  .timer $+ $1 1 30 gwd.npc $1
}

alias gwd.att {
  ;1 is person attacking
  ;2 is person attacked
  ;3 is weapon
  ;4 is chan
  if (!$istok($hget($4,gwd.turn),$1,44)) { notice $1 $logo(GWD) You have already attacked | halt }
  hadd $4 gwd.turn $remtok($hget($4,gwd.turn),$1,44)

  damage $1 $2 $3 $4
  if ($hget($2,hp) < 1) { 
    dead $4 $autoidm.acc($2) $1
    halt 
  }
  gwd.turn $4 $1
}

alias gwd.turn {
  ;1 is chan
  ;2 is person attacking
  hadd $1 gwd.turn $remtok($hget($1,gwd.turn),$2,44)
  if ($numtok($hget($1,gwd.turn),44) < 1) {
    .timer $+ $1 1 5 gwd.npc $1
  }
  else {
    .timer $+ $1 1 30 gwd.npc $1
  }
}

alias autoidm.acc {
  if (<idm>#dm.newbies == $1) return iDMnewbie
  if (<iDM>* iswm $1) return iDM
  if (<gwd>* iswm $1) return iDMGod
  return $1
}

alias autoidm.run {
  ; $1 = chan
  if (!$isdisabled($1,timeout)) {
    enddm $1
    return
  }
  autoidm.start $1
}
alias autoidm.start {
  ; $1 = chan
  if (!$hget($1)) return
  if ($hget($1,p2)) return

  var %nick $lower(<idm> $+ $1)
  var %p1 $hget($1,p1)
  if (!%p1) halt
  db.set user indm %p1 1
  chaninit %p1 %nick $1 $hget($1,sitems) 1
  set -u25 %enddm [ $+ [ $1 ] ] 0
  var %winloss $winloss(%nick,%p1,$autoidm.acc($2))
  var %winlossp1 $gettok(%winloss,1,45)
  var %winlossp2 $gettok(%winloss,2,45)
  var %bonus $ceil($calc( ($hget(%p1,wins) / 1000 ) + ( $hget(%p1,aikills) / 50 ) ))
  msgsafe $1 $logo(DM) $s1(%nick) %winlossp1 (+ $+ %bonus $+ ) has accepted $s1(%p1) $+ 's %winlossp2 DM. $s1($hget($1,p1)) gets the first move.
  if ($hget($1,p1) == %nick) autoidm.turn $1
  else { timerc $+ $1 1 60 autoidm.waiting $1 }
}

alias autoidm.turn {
  ; $1 = chan
  var %nick $lower(<idm> $+ $1)
  var %p2 $hget($1,p2)
  var %spec $hget(%nick,sp)
  var %hp $hget(%nick,hp)
  var %hp2 $hget(%p2,hp)
  if (%hp2 <= 15) var %attcmd surf
  elseif ((%hp <= 9) && (%hp2 <= 50)) var %attcmd dh
  elseif ($hget(%p2,laststyle) == melee) {
    if ($1 == #dm.newbies) { var %attcmd blood }
    elseif ($hget(%p2,poison) >= 1) || (%hp < 60) {
      if ((%hp >= 70) && (%spec >= 3) && (!$hget(%nick,frozen))) var %attcmd dclaws
      else var %attcmd blood
    }
    else var %attcmd smoke
  }
  elseif ($hget(%p2,laststyle) == mage) {
    if ($1 == #dm.newbies) { var %attcmd onyx }
    elseif ((%spec >= 3) && ($hget(%p2,poison) >= 1)) var %attcmd dbow
    elseif ((%spec >= 1) && (%hp > 50)) var %attcmd mjavelin
    else var %attcmd onyx
  }
  elseif ($hget(%p2,laststyle) == range) || ($hget(%p2,laststyle) == pot) {
    if ($hget(%nick,frozen)) var %attcmd onyx
    elseif ((!$hget(%p2,poison)) && (%spec >= 1) && (%hp2 > 50)) var %attcmd dds
    elseif ($1 == #dm.newbies) { var %attcmd guth }
    elseif (%spec >= 3) {
      if ((%hp >= 50) || (%hp2 < 30)) var %attcmd dhally
      else var %attcmd sgs
    }
    elseif (%spec >= 2) {
      if ((%hp >= 50) || (%hp2 < 30)) var %attcmd dclaws
      else var %attcmd sgs
    }
    elseif (%spec >= 1) var %attcmd dds
    else var %attcmd guth
  }
  else {
    if ($1 == #dm.newbies) { var %attcmd smoke }
    else { var %attcmd mjavelin }
  }
  set -u25 %enddm [ $+ [ $1 ] ] 0
  damage %nick %p2 %attcmd $1
  if ($hget(%p2,hp) < 1) {
    dead $1 %p2 $autoidm.acc(%nick)
    halt
  }
  if ($specused(%attcmd)) {
    hdec %nick sp $calc($specused(%attcmd) /25)
  }
  hadd %nick frozen 0
  hadd $1 p1 %p2
  hadd $1 p2 %nick
  timerc $+ $1 1 60 autoidm.waiting $1
}

alias autoidm.waiting {
  var %othernick = $hget($1,p1)
  if (%enddm [ $+ [ $1 ] ] != 0) {
    notice %othernick The DM will end in 40 seconds if %othernick does not make a move or !enddm. If the dm times out %othernick will lose $price($ceil($calc($db.get(user,money,%othernick) * 0.005)))
    set %enddm [ $+ [ $1 ] ] %othernick
    timercw $+ $1 1 20 delaycancelw $1 %othernick
    timerc $+ $1 1 40 delaycancel $1 %othernick
  }
}
