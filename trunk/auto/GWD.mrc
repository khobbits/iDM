#on $*:TEXT:/^[!@.](gwd)\b/Si:#: {
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
      msgsafe # $logo(GWD) $s1($nick) joined the group to go to $hget(chan,g0) $+ !
      db.set user indm $nick 1

    }
  }
  else {
    if ($hget($nick)) { notice $nick You're already in a DM... | inc -u6 %dm.spam [ $+ [ $nick ] ] | halt }
    if ($db.get(user,indm,$nick)) { notice $nick You're already in a DM.. | inc -u6 %dm.spam [ $+ [ $nick ] ] | halt }
    var %dungion $dungion
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
  return corp
}

alias dungion.hp {
  return $calc(200 * $1)
}

alias gwd.run {
  ; $1 = chan
  set -u25 %enddm [ $+ [ $1 ] ] 0
  var %x = 1
  while (%i < $hget($1,g)) {
    playerinit $hget($1,g $+ %i) $1
    hadd $hget($1,g $+ %i) g $hget($1,g0)
  }
  hadd <gwd> $+ $1 hp $dungion.hp($hget($1,g))
  hadd <gwd> $+ $1 poison 0
  hadd <gwd> $+ $1 frozen 0
  hadd <gwd> $+ $1 laststyle 0
  hadd $1 gi 1
  msgsafe $1 $logo(GWD) $1 is ready to raid $s1($hget($1,g0)) $+ . Everyone make their attacks, $hget($1,g0) will hit in 30s.
  .timer $+ $1 1 30 gwd.npc $1
}

alias gwd.npc {
  ; add attack by npc here
}

alias gwd.att {
  ;1 is person attacking
  ;2 is person attacked
  ;3 is weapon
  ;4 is chan

  gwd.turn $4 $1
}

alias gwd.turn {
  hadd $2 turn 1
  var %x = 1
  while (%i < $hget($1,g)) {
    if ($hget($hget($1,g $+ %x),turn) == 1) { inc %y }
    inc %x
  }
  if ($hget($1,g) == %y) {
    .timer $+ $4 off
    gwd.npc $4
  }
}
