on *:TEXT:!event*:#iDm.staff: {
  if (!$.readini(Admins.ini,Admins,$nick)) && (!$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if ($me != iDM) { halt }
  notice $nick $logo(ERROR) Events are currently disabled. | halt
  if (!$2) { notice $Nick $logo(ERROR) Use the syntax !event (double/triple/giveaway/itemgiveaway) duration in minutes. | halt }
  if (!$3) { notice $Nick $logo(ERROR) Use the syntax !event (double/triple/giveaway/itemgiveaway) duration in minutes. | halt }
  if ($.readini(events.ini,event,double)) { notice $nick There is already a Double Loot Worth event going. | halt }
  if ($.readini(events.ini,event,triple)) { notice $nick There is already a Triple Loot Worth event going. | halt }
  if ($.readini(events.ini,event,giveaway)) { notice $nick There is already a Giveaway event going. | halt }
  if ($.readini(events.ini,event,giveawayitem)) { notice $nick There is already an Item Giveaway event going. | halt }
  if ($2 == double) { 
    ctcp iDM[US],iDM[LL],iDM[FU],iDM[BU],iDM[BA],iDM[PK],iDM[SN],iDM[AL],iDM[GO],iDM[HU],iDM[UB],iDM[LA],iDM[JH],iDM[AZ],iDM[TB],iDM[AA],iDM[CR],iDM[IM],iDM[BK],iDM[\\],iDM[BE],iDM[SL],iDM[EU],iDM[ZZ] event1
    set %time $calc($3 *60) 
    writeini -n events.ini event Double $calc($3 *60)
    writeini -n events.ini event nick $nick
    msg $chan Double loot event has been enabled for: $3 $iif($3 == 1, minute., minutes.) 
    timer 1 %time msg $chan The event: 2x Loot, has now ended, after: $3 $iif($3 == 1, minute, minutes) 
    timer 1 %time remini -n events.ini event 
    unset %time 
    halt 
  }
  if ($2 == triple) { 
    ctcp iDM[US],iDM[LL],iDM[FU],iDM[BU],iDM[BA],iDM[PK],iDM[SN],iDM[AL],iDM[GO],iDM[HU],iDM[UB],iDM[LA],iDM[JH],iDM[AZ],iDM[TB],iDM[AA],iDM[CR],iDM[IM],iDM[BK],iDM[\\],iDM[BE],iDM[SL],iDM[EU],iDM[ZZ] event2
    set %time $calc($3 *60) 
    writeini -n events.ini event Triple $calc($3 *60)
    writeini -n events.ini event nick $nick
    msg $chan Triple loot event has been enabled for: $3 $iif($3 == 1, minute., minutes.) 
    timer 1 %time msg $chan The event: 3x Loot, has now ended, after: $3 $iif($3 == 1, minute, minutes) 
    timer 1 %time remini -n events.ini event 
    unset %time 
    halt 
  }
  if ($2 == giveaway) { 
    if (!$4) { notice $nick Please select a minimum reward. !event giveaway time Min amount Max amount | halt }
    if (!$5) { notice $nick Please select a maximum reward. !event giveaway time Min amount Max amount | halt }
    set %time $calc($3 *60) 
    msg #idm $logo(Event) A $s2(Money Giveaway event) has been created by $s1($nick) $+ ! Join/rejoin #iDM to claim your prize! 
    writeini -n events.ini event giveaway $calc($3 *60)
    writeini -n events.ini event max $5
    writeini -n events.ini event min $4
    msg $chan The Giveaway event has been enabled for: $3 $iif($3 == 1, minute., minutes.) 
    timer 1 %time msg $chan The event: Giveaway, has now ended, after: $3 $iif($3 == 1, minute, minutes) 
    timer 1 %time remini -n events.ini event 
    timer 1 %time unset %giveaway*
    unset %time 
    halt
  }
  if ($2 == itemgiveaway) { 
    set %time $calc($3 *60) 
    writeini -n events.ini event itemgiveaway $calc($3 *60) 
    msg $chan The Item Giveaway event has been enabled for: $3 $iif($3 == 1, minute., minutes.) 
    timer 1 %time msg $chan The event: Item Giveaway, has now ended, after: $3 $iif($3 == 1, minute, minutes) 
    timer 1 %time remini -n events.ini event 
    timer 1 %time unset %itemgiveaway*
    unset %time 
    halt
  }
  notice $nick Error: Event not recognised.
}

ctcp *:event1:*: {
  if ($nick ison #iDM.staff) && (iDM isin $nick) {
    amsg $logo(Event) A $s2(2x Loot event) has been created by $s1($.readini(events.ini,event,nick)) $+ ! DM now to be a part of this event!
    timer 1 $.readini(events.ini, event,double) amsg $logo(Event) The $s2(2x Loot event) has now ended. Look out for more events like this soon.
  }
}
ctcp *:event2:*: {
  if ($nick ison #iDM.staff) && (iDM isin $nick) {
    amsg $logo(Event) A $s2(3x Loot event) has been created by $s1($.readini(events.ini,event,nick)) $+ ! DM now to be a part of this event! 
    timer 1 $.readini(events.ini, event,triple) amsg $logo(Event) The $s2(3x Loot event) has now ended. Look out for more events like this soon.
  }
}
ctcp *:event3:*: {
  if ($nick ison #iDM.staff) && (iDM isin $nick) {

  }
}






on *:join:#idm: {
  if ($.readini(events.ini, event,giveaway)) {
    if ($me != iDM) { halt }
    if (%giveaway. [ $+ [ $nick ] ]) { halt }
    set %giveaway. [ $+ [ $nick ] ] $rand($.readini(events.ini,event,min) , $.readini(events.ini,event,max))
    notice $nick $logo(Giveaway) You have received $price(%giveaway. [ $+ [ $nick ] ]) from this Giveaway, enjoy!
    set -u0 %g %giveaway. [ $+ [ $nick ] ]
    writeini -n Money.ini Money $nick $calc($.readini(Money.ini,Money,$nick) + %g)
  }
  if ($.readini(events.ini, event,itemgiveaway)) {
    if ($me != iDM) { halt }
    if (%itemgiveaway. [ $+ [ $nick ] ]) { halt }
    set %itemgiveaway. [ $+ [ $nick ] ] $rand(1,100)
    if (%itemgiveaway. [ $+ [ $nick ] ] == 10) { set -u0 %giveawayitem.name sgs | writeini -n equipment.ini sgs $nick on }
    if (%itemgiveaway. [ $+ [ $nick ] ] == 20) { set -u0 %giveawayitem.name zgs | writeini -n equipment.ini zgs $nick on }
    if (%itemgiveaway. [ $+ [ $nick ] ] == 30) { set -u0 %giveawayitem.name bgs | writeini -n equipment.ini bgs $nick on }
    if (%itemgiveaway. [ $+ [ $nick ] ] == 40) { set -u0 %giveawayitem.name ags | writeini -n equipment.ini ags $nick on }
    if (%itemgiveaway. [ $+ [ $nick ] ] == 50) { set -u0 %giveawayitem.name specpot | writeini -n equipment.ini specpot $nick $calc($.readini(equipment.ini,specpot,$nick) + 1) }
    if (%itemgiveaway. [ $+ [ $nick ] ] == 60) { set -u0 %giveawayitem.name void | writeini -n equipment.ini void $nick on }
    if (%itemgiveaway. [ $+ [ $nick ] ] == 70) { set -u0 %giveawayitem.name specpot | writeini -n equipment.ini specpot $nick $calc($.readini(equipment.ini,specpot,$nick) + 1) }
    if (%itemgiveaway. [ $+ [ $nick ] ] == 80) { set -u0 %giveawayitem.name mudkip | writeini -n equipment.ini mudkip $nick on }
    notice $nick $logo(Giveaway) You have received $iif(%giveawayitem.name == sgs, A Saradomin Godsword , $iif(%giveawayitem.name == zgs, A Zamorak Godsword , $iif(%giveawayitem.name == bgs, A Bandos Godsword , $iif(%giveawayitem.name == ags, An Armadyl Godsword , $iif(%giveawayitem.name == specpot, A SpecPot , $iif(%giveawayitem.name == void, A Set of Void Range Robes , $iif(%giveawayitem.name == mudkip, A Pet Mudkip , nothing)))})))) from this Giveaway, $iif(%giveawayitem.name == $null , better luck next time., enjoy!)
  }
}
