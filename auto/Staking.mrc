on *:TEXT:!stake*:#: {
  if (# == #iDM.Support) { halt }
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if (%wait. [ $+ [ $chan ] ]) { halt }
  if (%dm.spam [ $+ [ $nick ] ]) { halt }
  if ($allupdate) { notice $nick $logo(ERROR) Staking is currently disabled, as we're performing an update. | halt }
  if (!$readini(login.ini,login,$nick)) { notice $nick You must be logged in to use the stake command. | halt }
  if ($chr(46) isin $2) { notice $nick The characters 7. are not allowed in staking money, please state whole figures! | halt }
  if (%p1 [ $+ [ $chan ] ] == $null) && ($2 == $null) { notice $nick Please enter an amount between 1 and 100000000 (100m). Eg: !stake 10000 | halt }
  if (%p1 [ $+ [ $chan ] ] == $null) && ($2 isnum 100000001-) || (m isin $2) || (k isin $2) || (b isin $2) { notice $nick Please enter an amount between 1 and 100000000 (100m) in digits. Eg: !stake 10000 | halt }
  if (!%p2 [ $+ [ $chan ] ]) && ($2 != $null) && (%stake [ $+ [ $chan ] ]) { notice $nick A wager of $s2($price(%stake [ $+ [ $chan ] ])) has already been set in $chan by %p1 [ $+ [ $chan ] ] $+ . To accept, type !stake | halt }
  if (%p1 [ $+ [ $chan ] ] == $null) && ($readini(money.ini,money,$nick) < $2 || $readini(money.ini,money,$nick) == $null) { notice $nick You don't have enough money to create this stake. | halt }
  if (%p1 [ $+ [ $chan ] ]) && ($nick == %p1 [ $+ [ $chan ] ]) { halt }
  if (!%p2 [ $+ [ $chan ] ]) && ($readini(money.ini,money,$nick) < %stake [ $+ [ $chan ] ] || $readini(money.ini,money,$nick) == $null) { notice $nick You don't have enough money to accept this stake. | halt }
  if ($readini(status.ini,currentdm,$nick)) { notice $nick You're already in a DM. | halt }
  if (%p2 [ $+ [ $chan ] ]) && (!%dm.spam [ $+ [ $nick ] ]) { notice $nick $logo(DM) People are already DMing in this channel. | inc -u10 %dm.spam [ $+ [ $nick ] ] | halt }
  if (!%p1 [ $+ [ $chan ] ]) && ($2 isnum 1-100000000) { msg # $logo(DM) $s1($nick) $winloss($nick) has requested a stake of $price($2) $+ ! You have $s2(20 seconds) to accept. | .timer $+ # 1 20 enddm # | set %dming [ $+ [ $nick ] ] on | writeini -n status.ini currentdm $nick true | set %p1 [ $+ [ $chan ] ] $nick | set %dmon [ $+ [ $chan ] ] on | set %stake [ $+ [ $chan ] ] $2 | set %stakeon [ $+ [ $chan ] ] on | set %address1 [ $+ [ $chan ] ] $address($nick,4) | halt }
  if (%p1 [ $+ [ $chan ] ]) && (!%p2 [ $+ [ $chan ] ]) && (%stake [ $+ [ $chan ] ]) { .timer $+ # off | set %dming [ $+ [ $nick ] ] on | writeini -n status.ini currentdm $nick true | set %turn [ $+ [ $chan ] ] $r(1,2) | set %p2 [ $+ [ $chan ] ] $nick | set %hp1 [ $+ [ $chan ] ] 99 | set %hp2 [ $+ [ $chan ] ] 99 | set %sp1 [ $+ [ $chan ] ] 4 | set %sp2 [ $+ [ $chan ] ] 4 | set %food1 [ $+ [ $chan ] ] 10 | set %food2 [ $+ [ $chan ] ] 10 | set %address2 [ $+ [ $chan ] ] $address($nick,4) | msg $chan $logo(DM) $s1($nick) $winloss($nick) has accepted $s1(%p1 [ $+ [ $chan ] ]) $+ 's $winloss(%p1 [ $+ [ $chan ] ]) stake. $s1($iif(%turn [ $+ [ $chan ] ] == 1,%p1 [ $+ [ $chan ] ],$nick)) gets the first move. }
  if ($address(%p1 [ $+ [ $chan ] ],2) == $address(%p2 [ $+ [ $chan ] ],2)) {  
    if (!$readini(exceptions.ini,exceptions,$address(%p1 [ $+ [ $chan ] ],2)) && !$readini(exceptions.ini,exceptions,$address(%p2 [ $+ [ $chan ] ],2)) && $gettok($read(exceptions.ini,23),1,61) !iswm $address($nick,2)) {
      ;msg #idm.staff $logo(Clones) $s1(%p1 [ $+ [ $chan ] ]) $s1($chr(91)) $+ $s2($remove($address(%p1 [ $+ [ $chan ] ],2),%p1 [ $+ [ $chan ] ] $+ ! $+ $chr(126))) $+ $s1($chr(93)) and $s1(%p2 [ $+ [ $chan ] ]) $s1($chr(91)) $+ $s2($remove($address(%p2 [ $+ [ $chan ] ],2),%p2 [ $+ [ $chan ] ] $+ ! $+ $chr(126))) $+ $s1($chr(93)) in $s1($chan) | halt }
      msg #idm.staff $logo(Clones) $s1(%p1 [ $+ [ $chan ] ]) $+($s2([),$cloneStats(%p1 [ $+ [ $chan ] ]),$s2(])) and $s1(%p2 [ $+ [ $chan ] ]) $+($s2([),$cloneStats(%p2 [ $+ [ $chan ] ]),$s2(])) $s2([) $+ $remove($address(%p1 [ $+ [ $chan ] ],2),%p1 [ $+ [ $chan ] ] $+ ! $+ $chr(126)) $+ $s2(]) in $s1($chan)
      ;msg # $logo(WARNING) DM'ing yourself is against the iDM rules and you risk getting blacklisted AND banned from iDM. Take this time to type !enddm or we will do it for you.
      halt
    }
  }
}