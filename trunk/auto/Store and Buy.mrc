on $*:TEXT:/^[!@.]store/Si:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($update) || ($allupdate) { notice $nick $logo(ERROR) Use of the store is disabled, as we're performing an update. | halt }
  $iif($left($1,1) == @,msg #,notice $nick) $logo(STORE) $&
    $s1(Void Range) (+5 to ranged attacks) ( $+ $s2($buyprice(void range)) $+ ) - $&
    $s1(Void Mage) (+5 to mage attacks) ( $+ $s2($buyprice(void mage)) $+ ) - $&
    $s1(Fire Cape) (+5 to melee attacks) ( $+ $s2($buyprice(fire cape)) $+ ) - $&
    $s1(Barrows Gloves) (+3 to melee attacks) ( $+ $+($s2($buyprice(barrows gloves)),$chr(44),$chr(32),$s2(2K+ DMs),$chr(44),$chr(32),$s2(1K+ Wins)) $+ ) - $&
    $s1(Mage's Book) (+5 to mage attacks) ( $+ $s2($buyprice(mage book)) $+ ) - $&
    $s1(God Cape) (+5 to mage attacks) ( $+ $s2($buyprice(godcape)) $+ ) - $&
    $s1(Accumulator) (+5 to range attacks) ( $+ $s2($buyprice(accumulator)) $+ )
  $iif($left($1,1) == @,msg #,notice $nick) $logo(STORE) $&
    $s1(Armadyl Godsword) ( $+ $s2($buyprice(ags)) $+ ) - $&
    $s1(Bandos Godsword) ( $+ $s2($buyprice(bgs)) $+ ) - $&
    $s1(Saradomin Godsword) ( $+ $s2($buyprice(sgs)) $+ ) - $&
    $s1(Zamorak Godsword) ( $+ $s2($buyprice(zgs)) $+ ) - $&
    $s1(Dragon Claws) ( $+ $s2($buyprice(dclaws)) $+ ) - $&
    $s1(Mudkip) ( $+ $s2($buyprice(mudkip)) $+ ) - $&
    $s1(Elysian Spirit Shield) (Reduces melee and range atks up to 15 $+ $chr(37) $+ ) ( $+ $s2($buyprice(elysian)) $+ ) - $&
    $s1(Ring of Wealth) (Doubles chance of rare drop) ( $+ $s2($buyprice(ring of wealth)) $+ )
}

on $*:TEXT:/^[!@.]buy/Si:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($update) || ($allupdate) { notice $nick $logo(ERROR) Use of the store is disabled, as we're performing an update. | halt }
  if ($db.get(user,login,$nick) < 1) { notice $nick You have to login before you can use this command. ( $+ $s2(/msg $me $iif($db.get(user,pass,$nick),id,reg) pass) $+ ) (Don't use your RuneScape password) | halt }
  if (%stake [ $+ [ $chan ] ]) { notice $nick $logo(ERROR) Please wait until the end of the DM to buy equipment. | halt }
  if ($.readini(status.ini,currentdm,$nick)) { notice $nick $logo(ERROR) Please wait until the end of your DM to buy equipment. | halt }
  if (!$db.get(user,money,$nick)) { notice $nick $logo(ERROR) You have no money. | halt }

  if ($storematch($2-) != 0) {
    var %price = $calc($gettok($v1,1,32)*2)
    var %sname = $gettok($v1,2,32)
    var %table = $gettok($v1,3,32)
    var %fname = $gettok($v1,4-,32)
  }
  else {
    notice $nick Type !store for a list of items that can currently be bought.
    halt
  }
  if (%sname == bgloves) && (($db.get(user,wins,$nick) < 1000) || ($calc($db.get(user,wins,$nick) + $db.get(user,losses,$nick)) < 2000)) {
    notice $nick You need atleast $s2($bytes(1000,bd)) wins and have played over $s2($bytes(2000,bd)) DMs to purchase Barrow Gloves.
    halt
  }
  if ($db.get(%table,%sname,$nick) > 0) { notice $nick You already have an %fname $+ . | halt }
  if ($db.get(user,money,$nick) < %price) { notice $nick You don't have $s2($price(%price)) to buy this! | halt }
  db.set user money $nick - %price
  db.set %table %sname $nick + 1
  write BuyStore.txt $timestamp $nick bought from the store ( $+ $2- $+ ) $address
  notice $nick You have bought $s1(%fname) for $s2($price(%price)) $+ . You have: $s2($price($db.get(user,money,$nick))) left.

}

on $*:TEXT:/^[!@.]sell/Si:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($update) || ($allupdate) { notice $nick $logo(ERROR) Use of the store is disabled, as we're performing an update. | halt }
  if ($db.get(user,login,$nick) < 1) { notice $nick You have to login before you can use this command. ( $+ $s2(/msg $me $iif($db.get(user,pass,$nick),id,reg) pass) $+ ) (Don't use your RuneScape password) | halt }

  if ($storematch($2-) != 0) {
    var %price = $gettok($v1,1,32)
    var %sname = $gettok($v1,2,32)
    var %table = $gettok($v1,3,32)
    var %fname = $gettok($v1,4-,32)
  }
  else {
    notice $nick You don't have this item to sell. For information about items that can be bought/sold at the store, type: !store
    halt
  }
  if (!$db.get(%table,%sname,$nick)) { notice $nick You don't have %fname $+ . | halt }
  db.set user money $nick + %price
  db.set %table %sname $nick - 1
  notice $nick You have sold $s1(%fname) for $s2($price(%price)) $+ . You now have: $s2($price($db.get(user,money,$nick))) $+ .
  return
}

alias buyprice {
  if ($storematch($1) != 0) {
    var %price = $price($calc($gettok($v1,1,32)*2))
  }
  else {
    var %price = 0
  }
  return %price
}

alias storematch {
  tokenize 32 - $1
  if ($regex($2-,/^void(\s|-)?range$/Si)) {
    var %sname = void
    var %fname = Full Void Knight Ranged
    var %price = 250000000
    var %table = equip_armour
  }
  elseif ($regex($2-,/^void(\s|-)?mage$/Si)) {
    var %sname = void-mage
    var %fname = Full Void Knight Mage
    var %price = 400000000
    var %table = equip_armour
  }
  elseif ($regex($2,/^ely(sian)?(\s|-)?(s(pirit)?)?(\s|-)?(s(hield)?)?/Si)) {
    var %sname = elshield
    var %fname = Elysian spirit shield
    var %price = 4000000000
    var %table = equip_armour
  }
  elseif ($regex($2-,/^bar+ows?(\s|-)?(glo(ves))?/Si)) {
    var %sname = bgloves
    var %fname = Barrow Gloves
    var %price = 1500000000
    var %table = equip_armour
  }
  elseif ($2 == dclaws) || ($2- == Dragon Claws) {
    var %sname = dclaws
    var %fname = Dragon Claws
    var %price = 1250000000
    var %table = equip_item
  }
  elseif ($2 == mudkip) {
    var %sname = mudkip
    var %fname = Mudkip Pouch
    var %price = 100000000
    var %table = equip_item
  }
  elseif ($2 == ring) || ($2 == wealth) {
    var %sname = wealth
    var %fname = Ring of Wealth
    var %price = 1500000000
    var %table = equip_item
  }
  elseif ($2 == fire) || ($2 == cape) || ($2 == firecape) {
    var %sname = firecape
    var %fname = Fire Cape
    var %price = 2000000000
    var %table = equip_armour
  }
  elseif ($2 == ags) || ($2 == armadyl) || ($2 == arma) || ($2 == arm) {
    var %sname = ags
    var %fname = Armadyl godsword
    var %price = 200000000
    var %table = equip_item
  }
  elseif ($2 == bgs) || ($2 == bandos) || ($2 == bando) {
    var %sname = bgs
    var %fname = Bandos godsword
    var %price = 250000000
    var %table = equip_item
  }
  elseif ($2 == sgs) || ($2 == Sara) || ($2 == saradomin) {
    var %sname = sgs
    var %fname = Saradomin godsword
    var %price = 300000000
    var %table = equip_item
  }
  elseif ($2 == zgs) || ($2 == Zammy) || ($2 == zamorak) {
    var %sname = zgs
    var %fname = Zamorak godsword
    var %price = 200000000
    var %table = equip_item
  }
  elseif ($2 == mbook) || ($2 == mage's) || ($2 == mages) || ($2- == mage book) {
    var %sname = mbook
    var %fname = Mage's Book
    var %price = 500000000
    var %table = equip_armour
  }
  elseif ($2 == accumulator) || ($2 == accum) || ($2 == backpack) {
    var %sname = accumulator
    var %fname = Accumulator
    var %price = 500000000
    var %table = equip_armour
  }
  elseif ($2 == god) || ($2 == godcape) || ($2- == god cape) {
    var %sname = godcape
    var %fname = God Cape
    var %price = 600000000
    var %table = equip_armour
  }
  else {
    return 0
  }
  return %price %sname %table %fname
}
