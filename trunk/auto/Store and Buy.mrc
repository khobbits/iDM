on $*:TEXT:/^[!@.]store/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if ($update) { notice $nick $logo(ERROR) IDM is currently disabled, please try again shortly | halt }
  if ($isbanned($nick)) { halt }
  $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(STORE) $&
    $s1(Archer Ring) (+4 to ranged attacks) ( $+ $s2($storeprice(archer)) $+ ) - $&
    $s1(Fire Cape) (+4 to melee attacks) ( $+ $s2($storeprice(fire cape)) $+ ) - $&
    $s1(Barrows Gloves) (+4 to melee attacks) ( $+ $+($s2($storeprice(barrows gloves)) $+ ) - $&
    $s1(Mage's Book) (+4 to mage attacks) ( $+ $s2($storeprice(mage book)) $+ ) - $&
    $s1(God Cape) (+4 to mage attacks) ( $+ $s2($storeprice(godcape)) $+ ) - $&
    $s1(Accumulator) (+4 to range attacks) ( $+ $s2($storeprice(accumulator)) $+ )
  $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(STORE) $&
    $s1(Armadyl Godsword) ( $+ $s2($storeprice(ags)) $+ ) - $&
    $s1(Bandos Godsword) ( $+ $s2($storeprice(bgs)) $+ ) - $&
    $s1(Saradomin Godsword) ( $+ $s2($storeprice(sgs)) $+ ) - $&
    $s1(Zamorak Godsword) ( $+ $s2($storeprice(zgs)) $+ ) - $&
    $s1(Dragon Claws) ( $+ $s2($storeprice(dclaws)) $+ ) - $&
    $s1(Mudkip) ( $+ $s2($storeprice(mudkip)) $+ ) - $&
    $s1(Elysian Spirit Shield) (Reduces attack damage by up to 10 $+ $chr(37) $+ ) ( $+ $s2($storeprice(elysian)) $+ ) - $&
    $s1(Ring of Wealth) (Doubles chance of rare drop) ( $+ $s2($storeprice(ring of wealth)) $+ )
}

on $*:TEXT:/^[!@.]buy/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if ($update) { notice $nick $logo(ERROR) IDM is currently disabled, please try again shortly | halt }
  if ($isbanned($nick)) { halt }
  if (!$islogged($nick,$address,3)) {
    notice $nick You have to login before you can use this command. (To check your auth type: /msg $me id)
    halt
  }
  if ($hget($nick)) { notice $nick $logo(ERROR) Please wait until the end of your DM to buy equipment. | halt }
  if (!$db.get(user,money,$nick)) { notice $nick $logo(ERROR) You have no money. | halt }

  if ($storematch($2-) != 0) {
    var %price = $calc($gettok($v1,1,32)*2)
    var %sname = $gettok($v1,2,32)
    var %table = $gettok($v1,3,32)
    var %winreq = $gettok($v1,4,32)
    var %fname = $gettok($v1,5-,32)
  }
  else {
    notice $nick Type !store for a list of items that can currently be bought.
    halt
  }
  if ($db.get(user,wins,$nick) < %winreq) {
    notice $nick You need atleast $s2(%winreq) wins to buy $s2($2-)
    halt
  }
  if ($db.get(%table,%sname,$nick) > 0) { notice $nick You already have an %fname $+ . | halt }
  if ($db.get(user,money,$nick) < %price) { notice $nick You don't have $s2($price(%price)) to buy this! | halt }
  db.set user money $nick - %price
  db.set %table %sname $nick + 1
  userlog buy $nick %fname

  notice $nick You have bought $s1(%fname) for $s2($price(%price)) $+ . You have: $s2($price($db.get(user,money,$nick))) left.
}

on $*:TEXT:/^[!@.]sell/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if ($update) { notice $nick $logo(ERROR) IDM is currently disabled, please try again shortly | halt }
  if ($isbanned($nick)) { halt }
  if (!$islogged($nick,$address,3)) {
    notice $nick You have to login before you can use this command. (To check your auth type: /msg $me id)
    halt
  }
  if ($hget($nick)) { notice $nick $logo(ERROR) Please wait until the end of your DM to sell equipment. | halt }

  if ($storematch($2-) != 0) {
    var %price = $gettok($v1,1,32)
    var %sname = $gettok($v1,2,32)
    var %table = $gettok($v1,3,32)
    var %fname = $gettok($v1,5-,32)
  }
  else {
    notice $nick You don't have this item to sell. For information about items that can be bought/sold at the store, type: !store
    halt
  }
  if (!$db.get(%table,%sname,$nick)) { notice $nick You don't have %fname $+ . | halt }
  db.set user money $nick + %price
  db.set %table %sname $nick - 1
  userlog sell $nick %fname

  notice $nick You have sold $s1(%fname) for $s2($price(%price)) $+ . You now have: $s2($price($db.get(user,money,$nick))) $+ .
  return
}

alias storeprice {
  if ($storematch($1) != 0) {
    return $price($calc($gettok($v1,1,32)*2)) $iif($winreq($1) > 0, and $v1 wins)
  }
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

alias sellprice {
  if ($storematch($1) != 0) {
    var %price = $price($calc($gettok($v1,1,32)))
  }
  else {
    var %price = 0
  }
  return %price
}

alias storename {
  if ($storematch($1-) != 0) {
    return $gettok($v1,5-,32)
  }
  else {
    return $null
  }
}

alias winreq {
  if ($storematch($1-) != 0) {
    return $gettok($v1,4,32)
  }
  else {
    return $null
  }
}

alias storematch {
  tokenize 32 - $1
  if ($2 == archer) {
    var %sname = archer
    var %fname = Archer Ring
    var %price = 400000000
    var %table = equip_armour
    var %winreq = 0
  }
  elseif ($regex($2,/^ely(sian)?(\s|-)?(s(pirit)?)?(\s|-)?(s(hield)?)?/Si)) {
    var %sname = elshield
    var %fname = Elysian spirit shield
    var %price = 4000000000
    var %table = equip_armour
    var %winreq = 0

  }
  elseif ($regex($2-,/^bar+ows?(\s|-)?(glo(ves))?/Si)) {
    var %sname = bgloves
    var %fname = Barrow Gloves
    var %price = 1500000000
    var %table = equip_armour
    var %winreq = 1000
  }
  elseif ($2 == dclaws) || ($2- == Dragon Claws) {
    var %sname = dclaws
    var %fname = Dragon Claws
    var %price = 1500000000
    var %table = equip_item
    var %winreq = 0
  }
  elseif ($2 == mudkip) {
    var %sname = mudkip
    var %fname = Mudkip Pouch
    var %price = 100000000
    var %table = equip_item
    var %winreq = 0
  }
  elseif ($2 == ring) || ($2 == wealth) {
    var %sname = wealth
    var %fname = Ring of Wealth
    var %price = 3500000000
    var %table = equip_item
    var %winreq = 0
  }
  elseif ($2 == fire) || ($2 == cape) || ($2 == firecape) {
    var %sname = firecape
    var %fname = Fire Cape
    var %price = 2000000000
    var %table = equip_armour
    var %winreq = 1000
  }
  elseif ($2 == ags) || ($2 == armadyl) || ($2 == arma) || ($2 == arm) {
    var %sname = ags
    var %fname = Armadyl Godsword
    var %price = 350000000
    var %table = equip_item
    var %winreq = 0
  }
  elseif ($2 == bgs) || ($2 == bandos) || ($2 == bando) {
    var %sname = bgs
    var %fname = Bandos Godsword
    var %price = 400000000
    var %table = equip_item
    var %winreq = 0
  }
  elseif ($2 == sgs) || ($2 == Sara) || ($2 == saradomin) {
    var %sname = sgs
    var %fname = Saradomin Godsword
    var %price = 350000000
    var %table = equip_item
    var %winreq = 0
  }
  elseif ($2 == zgs) || ($2 == Zammy) || ($2 == zamorak) {
    var %sname = zgs
    var %fname = Zamorak Godsword
    var %price = 250000000
    var %table = equip_item
    var %winreq = 0
  }
  elseif ($2 == mbook) || ($2 == mage's) || ($2 == mages) || ($2- == mage book) {
    var %sname = mbook
    var %fname = Mage's Book
    var %price = 400000000
    var %table = equip_armour
    var %winreq = 0
  }
  elseif ($2 == accumulator) || ($2 == accum) || ($2 == backpack) {
    var %sname = accumulator
    var %fname = Accumulator
    var %price = 750000000
    var %table = equip_armour
    var %winreq = 1000
  }
  elseif ($2 == god) || ($2 == godcape) || ($2- == god cape) {
    var %sname = godcape
    var %fname = God Cape
    var %price = 750000000
    var %table = equip_armour
    var %winreq = 1000
  }
  else {
    return 0
  }
  return %price %sname %table %winreq %fname
}
