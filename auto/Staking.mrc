on *:TEXT:!stake*:#: {
  if (# == #iDM.Support) { halt }
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (%wait. [ $+ [ $chan ] ]) { halt }
  if (%dm.spam [ $+ [ $nick ] ]) { halt }
  if ($allupdate) { notice $nick $logo(ERROR) Staking is currently disabled, as we're performing an update. | halt }
  tokenize 32 $1 $floor($iif($right($2,1) isin kmbt,$calc($replace($remove($2-,$chr(44)),k,*1000,m,*1000000,b,*1000000000,t,*1000000000000)),$remove($2-,$chr(44))))
  if (!$readini(login.ini,login,$nick)) { notice $nick You must be logged in to use the stake command. | halt }
  if (!%p1 [ $+ [ $chan ] ]) {
    if ($maxstake($nick) < 10000) { notice $nick You can't stake until you have $s1($price(200000)) $+ . | halt }
    if (!$2) { notice $nick Please enter an amount between $s1($price(10000)) and $s1($price($maxstake($nick))) $+ . (!stake 150M) | halt }
    if ($2 > $maxstake($nick)) { notice $nick Your maximum stake is only $s1($price($maxstake($nick))) $+ . | halt }
    if ($2 < 10000) { notice $nick The minimum stake is $s1($price(10000)) $+ . | halt }
    if ($readini(money.ini,money,$nick) < $2) || (!$readini(money.ini,money,$nick)) { notice $nick You don't have enough money. | halt }
    if ($2 <= $maxstake($nick)) { msg # $logo(DM) $s1($nick) $winloss($nick) has requested a stake of $s2($price($2)) $+ ! You have $s2(20 seconds) to accept. | .timer $+ # 1 20 enddm # | set %dming [ $+ [ $nick ] ] on | writeini -n status.ini currentdm $nick true | set %p1 [ $+ [ $chan ] ] $nick | set %dmon [ $+ [ $chan ] ] on | set %stake [ $+ [ $chan ] ] $2 | set %stakeon [ $+ [ $chan ] ] on | set %address1 [ $+ [ $chan ] ] $address($nick,4) | halt }
  }
  if (!%p2 [ $+ [ $chan ] ]) && ($2 <= %stake [ $+ [ $chan ] ]) && (%stake [ $+ [ $chan ] ]) { notice $nick A wager of $s2($price(%stake [ $+ [ $chan ] ])) has already been risked by %p1 [ $+ [ $chan ] ] $+ . To accept, type !stake. | halt }
  if (%p1 [ $+ [ $chan ] ]) && ($nick == %p1 [ $+ [ $chan ] ]) { halt }
  if (!%p2 [ $+ [ $chan ] ]) && (($iif($readini(money.ini,money,$nick),$v1,0) < %stake [ $+ [ $chan ] ]) || ($maxstake($nick) < %stake [ $+ [ $chan ] ])) { notice $nick You either don't have enough money to stake, or your staking limit ( $+ $s1($price($maxstake($nick))) $+ ) is too low. | halt }
  if ($readini(status.ini,currentdm,$nick)) { notice $nick You're already in a DM. | halt }
  if (%p2 [ $+ [ $chan ] ]) && (!%dm.spam [ $+ [ $nick ] ]) { notice $nick $logo(DM) People are already DMing in this channel. | inc -u10 %dm.spam [ $+ [ $nick ] ] | halt }
  if (%p1 [ $+ [ $chan ] ]) && (!%p2 [ $+ [ $chan ] ]) && (%stake [ $+ [ $chan ] ]) { .timer $+ # off | set %dming [ $+ [ $nick ] ] on | writeini -n status.ini currentdm $nick true | set %turn [ $+ [ $chan ] ] $r(1,2) | set %p2 [ $+ [ $chan ] ] $nick | set %hp1 [ $+ [ $chan ] ] 99 | set %hp2 [ $+ [ $chan ] ] 99 | set %sp1 [ $+ [ $chan ] ] 4 | set %sp2 [ $+ [ $chan ] ] 4 | set %food1 [ $+ [ $chan ] ] 10 | set %food2 [ $+ [ $chan ] ] 10 | set %address2 [ $+ [ $chan ] ] $address($nick,4) | msg $chan $logo(DM) $s1($nick) $winloss($nick) has accepted $s1(%p1 [ $+ [ $chan ] ]) $+ 's $winloss(%p1 [ $+ [ $chan ] ]) stake. $s1($iif(%turn [ $+ [ $chan ] ] == 1,%p1 [ $+ [ $chan ] ],$nick)) gets the first move. }
  if ($address(%p1 [ $+ [ $chan ] ],2) == $address(%p2 [ $+ [ $chan ] ],2)) && (%stake [ $+ [ $chan ] ]) {  
    if (!$readini(exceptions.ini,exceptions,$address(%p1 [ $+ [ $chan ] ],2)) && !$readini(exceptions.ini,exceptions,$address(%p2 [ $+ [ $chan ] ],2)) && $gettok($read(exceptions.ini,23),1,61) !iswm $address($nick,2)) {
      ;msg $secondchan $logo(Clones) $s1(%p1 [ $+ [ $chan ] ]) $s1($chr(91)) $+ $s2($remove($address(%p1 [ $+ [ $chan ] ],2),%p1 [ $+ [ $chan ] ] $+ ! $+ $chr(126))) $+ $s1($chr(93)) and $s1(%p2 [ $+ [ $chan ] ]) $s1($chr(91)) $+ $s2($remove($address(%p2 [ $+ [ $chan ] ],2),%p2 [ $+ [ $chan ] ] $+ ! $+ $chr(126))) $+ $s1($chr(93)) in $s1($chan) | halt }
      msg $secondchan $logo(Clones) $s1(%p1 [ $+ [ $chan ] ]) $+($s2([),$cloneStats(%p1 [ $+ [ $chan ] ]),$s2(])) and $s1(%p2 [ $+ [ $chan ] ]) $+($s2([),$cloneStats(%p2 [ $+ [ $chan ] ]),$s2(])) $s2([) $+ $remove($address(%p1 [ $+ [ $chan ] ],2),%p1 [ $+ [ $chan ] ] $+ ! $+ $chr(126)) $+ $s2(]) in $s1($chan)
      ;msg # $logo(WARNING) DM'ing yourself is against the iDM rules and you risk getting blacklisted AND banned from iDM. Take this time to type !enddm or we will do it for you.
      halt
    }
  }
}
alias maxstake {
  return $iif($ceil($calc($readini(money.ini,money,$1) *.05)) > 1000000000,$v2,$v1)
}

on *:TEXT:!tour*:#iDM.Tournaments: {
  if ($istok(Tournament tourney tourny,$right($1,-1),32)) {
    if (!$readini(Tournament,Started,started)) {
      if (!$readini(admins.ini,admins,$address($nick,3))) {
        notice $nick $logo(ERROR) You can't start a tournament.
        halt
      }
      elseif ($readini(admins.ini,admins,$address($nick,3))) {
        writeini Tournament Started started true
        msg # $logo(TOURNEY) A tournament has begun, type !join to join in.
      }
    }
  }
}
on *:TEXT:!join:#iDM.Tournaments: {
  if (!$readini(Tournament,Started,started)) {
    notice $nick $logo(ERROR) There is no tournament.
    halt
  }
  if ($readini(Tournament,players,$nick)) {
    notice $nick $logo(ERROR) You're already in the tournament.
    halt
  }
  if ($readini(money.ini,money,$nick) < 10000000) {
    notice $nick $logo(ERROR) You need at least $s1($price(10000000)) to join a tournament.
    halt
  }
  if ($ini(tournament,players,0) > 16) {
    notice $nick $logo(ERROR) There are already 16 players.
    halt
  }
  writeini tournament.ini players $nick on
  notice $nick $logo(TOURNEY) You've been entered in the tournament.
  halt
}
