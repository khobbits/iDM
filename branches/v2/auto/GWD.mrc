on $*:TEXT:/^[!@.](gwd)\b/Si:#: {
  if ($isbanned($nick)) { halt }
  if (# != #idm.dev) { halt }
  if ((# == #idm.Support) || (# == #idm.help)) && ($nick !isop $chan) { halt }
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if ($update) { notice $nick $logo(ERROR) IDM is currently disabled, please try again shortly | halt }
  if ((%dm.spam [ $+ [ $nick ] ]) || (%wait. [ $+ [ $chan ] ])) { halt }

  if ($allupdate) { notice $nick $logo(ERROR) DMing is currently disabled, as we're performing an update. | halt }
  if ($regex($nick,/^Unknown[0-9]{5}$/Si)) { notice $Nick You currently have a nick that isn't allowed to use iDM please change it before DMing. | halt }
  if ($isbanned($nick)) { putlog $logo(Banned) $nick tried to dm on $chan | halt }
  if (!$islogged($nick,$address,3)) {  notice $nick You have to login before you can use this command. (To check your auth type: /msg $me id) | halt }


  if ($hget($chan)) {
    ; check if player matches current player
    if ($hget($nick)) { notice $nick You're already in a DM... | inc -u6 %dm.spam [ $+ [ $nick ] ] | halt }
    if ($db.get(user,indm,$nick)) { notice $nick You're already in a DM.. | inc -u6 %dm.spam [ $+ [ $nick ] ] | halt }
    if ($hget($chan,p1)) { notice $nick $logo(DM) People are already DMing in this channel. | inc -u8 %dm.spam [ $+ [ $nick ] ] | halt }
    if ($hget($chan,gi)) { notice $nick $logo(GWD) There is already a GWD in progress. | inc -u8 %dm.spam [ $+ [ $nick ] ] | halt }
    ;check to see if match has already started
    if (1 == 2) { }
    else {
      hinc $chan g
      hadd $chan g $+ $hget($chan,g) $nick
      msgsafe # $logo(GWD) $s1($nick) joined the group to go to $hget($chan,g0) $+ !
      db.set user indm $nick 1

    }
  }
  else {
    if ($hget($nick)) { notice $nick You're already in a DM... | inc -u6 %dm.spam [ $+ [ $nick ] ] | halt }
    if ($db.get(user,indm,$nick)) { notice $nick You're already in a DM.. | inc -u6 %dm.spam [ $+ [ $nick ] ] | halt }
    var %dungion $dungion($2-)
    hmake $chan 10
    hadd $chan g0 %dungion
    hadd $chan g1 $nick
    hadd $chan g 1
    .timer $+ # 1 30 gwd.run #
    msgsafe # $logo(GWD) $s1($nick) $winloss($nick) is gathering a group to go to %dungion $+ ! You have $s2(30 seconds) to accept.
  }
  db.set user indm $nick 1
}

alias dungion {
  ; $1 = user input

  ;#insert code to differentiate different dungions

  return corp
}


alias dungion.hp {
  ; $1 = number of players

  return $calc(200 * $1)
}

alias gwd.run {
  ; $1 = chan
  ; This is triggered at start of game

  set -u25 %enddm [ $+ [ $1 ] ] 0
  var %x = 1
  while (%x <= $hget($1,g)) {
    ; loop through players and init them
    msg #idm.dev Added User $hget($1,g $+ %x)
    playerinit $hget($1,g $+ %x) $1 1
    hadd $hget($1,g $+ %x) g $hget($1,g0)
    inc %x
  }
  ; Innit channel settings
  playerinit <gwd> $+ $1 $1 0
  hadd <gwd> $+ $1 hp $dungion.hp($hget($1,g))
  hadd $1 gi 1
  msgsafe $1 $logo(GWD) $1 is ready to raid $s1($hget($1,g0)) $+ . Everyone make their attacks, $hget($1,g0) will hit in 30s.
  .timer $+ $1 1 30 gwd.npc $1
}

alias gwd.npc {
  ; $1 = chan
  ; This is triggered when it is the NPC's Turn
  msg #idm.dev NPC Attack
  ;# Add attack by NPC here

  ;# Display damage / round stats?

  .timer $+ $1 1 30 gwd.npc $1

}

alias gwd.att {
  ;1 is person attacking
  ;2 is person attacked
  ;3 is weapon
  ;4 is chan

  ; # Insert code to stop same person attacking twice

  ; # Insert code to handle player prereqs (see all dm commands.mrc)
  msg #idm.dev $1 attacks $2 with $3
  damage $1 $2 $3 $4

  gwd.turn $4 $1
}

alias gwd.turn {
  ;1 is chan
  ;2 is person attacking
  ; This is just to check if all players have made their turn

  hadd $2 turn 1
  var %x = 1
  while (%i < $hget($1,g)) {
    if ($hget($hget($1,g $+ %x),turn) == 1) { inc %y }
    inc %x
  }
  if ($hget($1,g) == %y) {
    .timer $+ $4 off
    msg #idm.dev All Players attacked, NPC turn.
    gwd.npc $4
  }
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

alias autoidm.acc {
  if (<idm>#dm.newbies == $1) return iDMnewbie
  if (<iDM>* iswm $1) return iDM
  if (<gwd>* iswm $1) return iDMGod
  return $1
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
