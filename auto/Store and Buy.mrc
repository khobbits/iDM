on *:TEXT:?store:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($update) || ($allupdate) { notice $nick $logo(ERROR) Use of the store is disabled, as we're performing an update. | halt }
  if ($left($1,1) isin !@) && ($right($1,-1) == store) {
    $iif($left($1,1) == !,notice $nick,msg #) $logo(STORE) $&
      $s1(Void Range) (+5 to ranged attacks) ( $+ $s2(500M) $+ ) - $&
      $s1(Void Mage) (+5 to mage attacks) ( $+ $s2(800M) $+ ) - $&
      $s1(Fire Cape) (+5 to melee attacks) ( $+ $s2(4B) $+ ) - $&
      $s1(Barrow Gloves) (+3 to melee attacks) ( $+ $+($s2(3B),$chr(44),$chr(32),$s2(2K+ DMs),$chr(44),$chr(32),$s2(1K+ Wins)) $+ ) - $&
      $s1(Mage's Book) (+5 to mage attacks) ( $+ $s2(1B) $+ ) - $&
      $s1(Accumulator) (+5 to range attacks) ( $+ $s2(1B) $+ )
    $iif($left($1,1) == !,notice $nick,msg #) $logo(STORE) $&
      $s1(Armadyl Godsword) ( $+ $s2(400M) $+ ) - $&
      $s1(Bandos Godsword) ( $+ $s2(500M) $+ ) - $&
      $s1(Saradomin Godsword) ( $+ $s2(600M) $+ ) - $&
      $s1(Zamorak Godsword) ( $+ $s2(400M) $+ ) - $&
      $s1(Dragon Claws) ( $+ $s2(2.5B) $+ ) - $&
      $s1(Mudkip) ( $+ $s2(200M) $+ ) - $&
      $s1(Elysian Spirit Shield) (Reduces melee and range atks up to 15 $+ $chr(37) $+ ) ( $+ $s2(8B) $+ ) - $&
      $s1(Ring of Wealth) (Doubles chance of rare drop) ( $+ $s2(3B) $+ )
  }
}
on *:TEXT:!buy*:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($update) || ($allupdate) { notice $nick $logo(ERROR) Use of the store is disabled, as we're performing an update. | halt }
  if (!$readini(login.ini,login,$nick)) { notice $nick You have to login before you can use this command. ( $+ $s2(/msg $me $iif($readini(Passes.ini,Passes,$nick),id,reg) pass) $+ ) (Don't use your RuneScape password) | halt }
  if (%stake [ $+ [ $chan ] ]) { notice $nick $logo(ERROR) Please wait until the end of your DM to buy equipment. | halt }
  if ($readini(status.ini,currentdm,$nick)) { notice $nick $logo(ERROR) Please wait until the end of your DM to buy equipment. | halt }
  if (!$readini(money.ini,money,$nick)) { notice $nick $logo(ERROR) You have no money. | halt }
  if ($regex($2-,/^void(\s|-)?range$/Si)) {
    if ($readini(Equipment.ini,Void,$nick)) { notice $nick You already have Void Range.. | halt }
    if ($readini(money.ini,money,$nick) < 500000000) { notice $nick You don't have $s2(500M) to buy this! | halt }
    writeini -n Money.ini Money $nick $calc($readini(Money.ini,money,$nick) - 500000000)
    writeini -n Equipment.ini Void $nick 1 
    write BuyStore.txt $nick bought from the store ( $+ $2- $+ ) $address
    notice $nick You have bought $s1(Full Void Knight Ranged) for $s2(500M) $+ . You have: $s2($price($readini(Money.ini,money,$nick))) left. | halt 
  }
  if ($regex($2-,/^void(\s|-)?mage$/Si)) {
    if ($readini(Equipment.ini,void-mage,$nick)) { notice $nick You already have Void Mage.. | halt }
    if ($readini(money.ini,money,$nick) < 800000000) { notice $nick You don't have $s2(800M) to buy this! | halt }
    writeini -n Money.ini Money $nick $calc($readini(Money.ini,money,$nick) - 800000000)
    writeini -n Equipment.ini void-mage $nick 1 
    write BuyStore.txt $nick bought from the store ( $+ $2- $+ ) $address
    notice $nick You have bought $s1(Full Void Knight Mage) for $s2(800M) $+ . You have: $s2($price($readini(Money.ini,money,$nick))) left. | halt 
  }
  if ($2 == ring) || ($2 == wealth) {
    if ($readini(Equipment.ini,Wealth,$nick)) { notice $nick You already have a ring of wealth.. | halt }
    if ($readini(money.ini,money,$nick) < 3000000000) { notice $nick You don't have $s2(3B) to buy this! | halt }
    writeini -n Money.ini Money $nick $calc($readini(Money.ini,money,$nick) - 3000000000)
    writeini -n Equipment.ini Wealth $nick 1    
    write BuyStore.txt $nick bought from the store ( $+ $2- $+ ) $address
    notice $nick You have bought $s1(Ring of Wealth) for $s2(3B) $+ . You have: $s2($price($readini(Money.ini,money,$nick))) left. | halt 
  }
  if ($2 == Dclaws) || ($2- == Dragon Claws) {
    if ($readini(Equipment.ini,dclaws,$nick)) { notice $nick You already have Dragon Claws. | halt }
    if ($readini(money.ini,money,$nick) < 2500000000) { notice $nick You don't have $s2(2.5B) to buy this! | halt }
    writeini -n Money.ini Money $nick $calc($readini(Money.ini,money,$nick) - 2500000000)
    writeini -n Equipment.ini Dclaws $nick 1        
    write BuyStore.txt $nick bought from the store ( $+ $2- $+ ) $address                         
    notice $nick You have bought $s1(Dragon Claws) for $s2(2.5B) $+ . You have: $s2($price($readini(Money.ini,money,$nick))) left. | halt 
  }
  if ($2 == mudkip) {
    if ($readini(Equipment.ini,mudkip,$nick)) { notice $nick You already have a mudkip. | halt }
    if ($readini(money.ini,money,$nick) < 200000000) { notice $nick You don't have $s2(200M) to buy this! | halt }
    writeini -n Money.ini Money $nick $calc($readini(Money.ini,money,$nick) - 200000000)
    writeini -n Equipment.ini mudkip $nick 1    
    write BuyStore.txt $nick bought from the store ( $+ $2- $+ ) $address
    notice $nick You have bought a $s1(Mudkip Pouch) for $s2(200M) $+ . You have: $s2($price($readini(Money.ini,money,$nick))) left. | halt 
  }
  if ($2 == fire) || ($2 == cape) {
    if ($readini(Equipment.ini,Firecape,$nick)) { notice $nick You already have a fire cape.. | halt }
    if ($readini(money.ini,money,$nick) < 4000000000) { notice $nick You don't have $s2(4B) to buy this! | halt }
    writeini -n Money.ini Money $nick $calc($readini(Money.ini,money,$nick) - 4000000000)
    writeini -n Equipment.ini Firecape $nick 1   
    write BuyStore.txt $nick bought from the store ( $+ $2- $+ ) $address 
    notice $nick You have bought $s1(Fire Cape) for $s2(4B) $+ . You have: $s2($price($readini(Money.ini,money,$nick))) left. | halt 
  }
  if ($2 == ags) || ($2 == armadyl) || ($2 == arma) || ($2 == arm) {
    if ($readini(Equipment.ini,ags,$nick)) { notice $nick You already have an Armadyl godsword.. | halt }
    if ($readini(money.ini,money,$nick) < 400000000) { notice $nick You don't have $s2(400M) to buy this! | halt }
    writeini -n Money.ini Money $nick $calc($readini(Money.ini,money,$nick) - 400000000)
    writeini -n Equipment.ini ags $nick 1   
    write BuyStore.txt $nick bought from the store ( $+ $2- $+ ) $address 
    notice $nick You have bought $s1(Armadyl godsword) for $s2(400M) $+ . You have: $s2($price($readini(Money.ini,money,$nick))) left. | halt 
  }
  if ($2 == bgs) || ($2 == bandos) || ($2 == bando) {
    if ($readini(Equipment.ini,bgs,$nick)) { notice $nick You already have a Bandos godsword.. | halt }
    if ($readini(money.ini,money,$nick) < 500000000) { notice $nick You don't have $s2(500M) to buy this! | halt }
    writeini -n Money.ini Money $nick $calc($readini(Money.ini,money,$nick) - 500000000)
    writeini -n Equipment.ini bgs $nick 1    
    write BuyStore.txt $nick bought from the store ( $+ $2- $+ ) $address
    notice $nick You have bought $s1(Bandos godsword) for $s2(500M) $+ . You have: $s2($price($readini(Money.ini,money,$nick))) left. | halt 
  }
  if ($2 == sgs) || ($2 == Sara) || ($2 == saradomin) {
    if ($readini(Equipment.ini,sgs,$nick)) { notice $nick You already have a Saradomin godsword.. | halt }
    if ($readini(money.ini,money,$nick) < 600000000) { notice $nick You don't have $s2(600M) to buy this! | halt }
    writeini -n Money.ini Money $nick $calc($readini(Money.ini,money,$nick) - 600000000)
    writeini -n Equipment.ini sgs $nick 1    
    write BuyStore.txt $nick bought from the store ( $+ $2- $+ ) $address
    notice $nick You have bought $s1(Saradomin godsword) for $s2(600M) $+ . You have: $s2($price($readini(Money.ini,money,$nick))) left. | halt 
  }
  if ($2 == zgs) || ($2 == Zammy) || ($2 == zamorak) {
    if ($readini(Equipment.ini,zgs,$nick)) { notice $nick You already have a Zamorak godsword.. | halt }
    if ($readini(money.ini,money,$nick) < 400000000) { notice $nick You don't have $s2(400M) to buy this! | halt }
    writeini -n Money.ini Money $nick $calc($readini(Money.ini,money,$nick) - 400000000)
    writeini -n Equipment.ini zgs $nick 1    
    write BuyStore.txt $nick bought from the store ( $+ $2- $+ ) $address
    notice $nick You have bought $s1(Zamorak godsword) for $s2(400M) $+ . You have: $s2($price($readini(Money.ini,money,$nick))) left. | halt 
  }
  if ($regex($2,/^ely?s+ian/Si)) {
    if ($readini(Equipment.ini,elshield,$nick)) { notice $nick You already have a Elysian spirit shield.. | halt }
    if ($readini(money.ini,money,$nick) < 8000000000) { notice $nick You don't have $s2(8B) to buy this! | halt }
    writeini -n Money.ini Money $nick $calc($readini(Money.ini,money,$nick) - 8000000000)
    writeini -n Equipment.ini elshield $nick 1    
    write BuyStore.txt $nick bought from the store ( $+ $2- $+ ) $address
    notice $nick You have bought $s1(Elysian spirit shield) for $s2(8B) $+ . You have: $s2($price($readini(Money.ini,money,$nick))) left. | halt 
  }
  if ($regex($2-,/^b(ar+ows?)?(\s|-)?glo?ves?/Si)) {
    if ($readini(Equipment.ini,bgloves,$nick)) { notice $nick You already have Barrow Gloves.. | halt }
    if ($readini(money.ini,money,$nick) < 3000000000) { notice $nick You don't have $s2(3B) to buy this! | halt }
    if ($readini(wins.ini,wins,$nick) < 1000) || ($calc($readini(wins.ini,wins,$nick) + $readini(losses.ini,losses,$nick)) < 2000) { notice $nick You need atleast $s2($bytes(1000,bd)) wins and have played over $s2($bytes(2000,bd)) DMs to purchase Barrow Gloves. | halt }
    writeini -n Money.ini Money $nick $calc($readini(Money.ini,money,$nick) - 3000000000)
    writeini -n Equipment.ini bgloves $nick 1    
    write BuyStore.txt $nick bought from the store ( $+ $2- $+ ) $address
    notice $nick You have bought $s1(Barrow Gloves) for $s2(3B) $+ . You have: $s2($price($readini(Money.ini,money,$nick))) left. | halt 
  }
  if ($2 == mbook) || ($2 == mage's) || ($2 == mages) {
    if ($readini(Equipment.ini,mbook,$nick)) { notice $nick You already have a Mage's book.. | halt }
    if ($readini(money.ini,money,$nick) < 1000000000) { notice $nick You don't have $s2(1B) to buy this! | halt }
    writeini -n Money.ini Money $nick $calc($readini(Money.ini,money,$nick) - 1000000000)
    writeini -n Equipment.ini mbook $nick 1    
    write BuyStore.txt $nick bought from the store ( $+ $2- $+ ) $address
    notice $nick You have bought $s1(Mage's book) for $s2(1B) $+ . You have: $s2($price($readini(Money.ini,money,$nick))) left. | halt 
  }
  if ($2 == accumulator) || ($2 == accum) || ($2 == backpack) {
    if ($readini(Equipment.ini,accumulator,$nick)) { notice $nick You already have an Accumulator.. | halt }
    if ($readini(money.ini,money,$nick) < 1000000000) { notice $nick You don't have $s2(1B) to buy this! | halt }
    writeini -n Money.ini Money $nick $calc($readini(Money.ini,money,$nick) - 1000000000)
    writeini -n Equipment.ini accumulator $nick 1   
    write BuyStore.txt $nick bought from the store ( $+ $2- $+ ) $address 
    notice $nick You have bought $s1(Accumulator) for $s2(1B) $+ . You have: $s2($price($readini(Money.ini,money,$nick))) left. | halt 
  }
  else notice $nick Type !store for a list of items that can currently be bought.
}
