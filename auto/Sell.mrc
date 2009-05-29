on *:TEXT:!sell*:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  if ($update) || ($allupdate) { notice $nick $logo(ERROR) Use of the store is disabled, as we're performing an update. | halt }
  if ($.readini(lent.ini,borrowing,$nick)) { notice $nick You cannot sell this item as you are borrowing it. | halt }
  if (!$.readini(login.ini,login,$nick)) { notice $nick You have to login before you can use this command. ( $+ $s2(/msg $me $iif($.readini(Passes.ini,Passes,$nick),id,reg) pass) $+ ) (Don't use your RuneScape password) | halt }
  if ($regex($2-,/^void(\s|-)?range$/Si)) {
    if (!$.readini(Equipment.ini,Void,$nick)) { notice $nick You don't have void range. | halt }
    writeini -n Money.ini Money $nick $calc($.readini(Money.ini,money,$nick) + 250000000)
    writeini -n Equipment.ini void $nick $calc($.readini(equipment.ini,void,$nick) -1)  
    if ($.readini(equipment.ini,void,$nick) < 1) {
      remini -n Equipment.ini void $nick
    }    
    notice $nick You have sold $s1(Full Void Knight Ranged) for $s2(250M) $+ . You now have: $s2($price($.readini(Money.ini,money,$nick))) $+ . | halt 
  }
  if ($regex($2-,/^void(\s|-)?mage$/Si)) {
    if (!$.readini(Equipment.ini,void-mage,$nick)) { notice $nick You don't have void mage. | halt }
    writeini -n Money.ini Money $nick $calc($.readini(Money.ini,money,$nick) + 400000000)
    writeini -n Equipment.ini void-mage $nick $calc($.readini(equipment.ini,void-mage,$nick) -1)  
    if ($.readini(equipment.ini,void-mage,$nick) < 1) {
      remini -n Equipment.ini void-mage $nick
    }   
    notice $nick You have sold $s1(Full Void Knight Mage) for $s2(400M) $+ . You now have: $s2($price($.readini(Money.ini,money,$nick))) $+ . | halt 
  }
  if ($regex($2,/^ely?s+ian/Si)) {
    if (!$.readini(Equipment.ini,elshield,$nick)) { notice $nick You don't have a Elysian spirit shield. | halt }
    writeini -n Money.ini Money $nick $calc($.readini(Money.ini,money,$nick) + 4000000000)
    writeini -n Equipment.ini elshield $nick $calc($.readini(equipment.ini,elshield,$nick) -1)  
    if ($.readini(equipment.ini,elshield,$nick) < 1) {
      remini -n Equipment.ini elshield $nick
    }  
    notice $nick You have sold $s1(Elysian spirit shield) for $s2(4B) $+ . You now have: $s2($price($.readini(Money.ini,money,$nick))) $+ . | halt 
  }
  if ($regex($2-,/^b(ar+ows?)?(\s|-)?glo?ves?/Si)) {
    if (!$.readini(Equipment.ini,bgloves,$nick)) { notice $nick You don't have barrow gloves. | halt }
    writeini -n Money.ini Money $nick $calc($.readini(Money.ini,money,$nick) + 1500000000)
    writeini -n Equipment.ini bgloves $nick $calc($.readini(equipment.ini,bgloves,$nick) -1)  
    if ($.readini(equipment.ini,bgloves,$nick) < 1) {
      remini -n Equipment.ini bgloves $nick
    }   
    notice $nick You have sold $s1(Barrow Gloves) for $s2(1.5B) $+ . You now have: $s2($price($.readini(Money.ini,money,$nick))) $+ . | halt 
  }
  if ($2 == dclaws) || ($2- == Dragon Claws) {
    if (!$.readini(Equipment.ini,dclaws,$nick)) { notice $nick You don't have any Dragon Claws. | halt }
    writeini -n Money.ini Money $nick $calc($.readini(Money.ini,money,$nick) + 1250000000)
    writeini -n Equipment.ini dclaws $nick $calc($.readini(equipment.ini,dclaws,$nick) -1)  
    if ($.readini(equipment.ini,dclaws,$nick) < 1) {
      remini -n Equipment.ini dclaws $nick
    }   
    notice $nick You have sold $s1(Dragon Claws) for $s2(1.25B) $+ . You now have: $s2($price($.readini(Money.ini,money,$nick))) $+ . | halt 
  }
  if ($2 == mudkip) {
    if (!$.readini(Equipment.ini,mudkip,$nick)) { notice $nick You don't have any Mudkip. | halt }
    writeini -n Money.ini Money $nick $calc($.readini(Money.ini,money,$nick) + 100000000)
    writeini -n Equipment.ini mudkip $nick $calc($.readini(equipment.ini,mudkip,$nick) -1)  
    if ($.readini(equipment.ini,mudkip,$nick) < 1) {
      remini -n Equipment.ini mudkip $nick
    }    
    notice $nick You have sold a $s1(Mudkip Pouch) for $s2(100M) $+ . You now have: $s2($price($.readini(Money.ini,money,$nick))) $+ . | halt 
  }
  if ($2 == ring) || ($2 == wealth) {
    if (!$.readini(Equipment.ini,Wealth,$nick)) { notice $nick You don't have a ring of wealth. | halt }
    writeini -n Money.ini Money $nick $calc($.readini(Money.ini,money,$nick) + 1500000000)
    writeini -n Equipment.ini wealth $nick $calc($.readini(equipment.ini,wealth,$nick) -1)  
    if ($.readini(equipment.ini,wealth,$nick) < 1) {
      remini -n Equipment.ini wealth $nick
    }
    notice $nick You have sold $s1(Ring of Wealth) for $s2(1.5B) $+ . You now have: $s2($price($.readini(Money.ini,money,$nick))) $+ . | halt 
  }
  if ($2 == fire) || ($2 == cape) {
    if (!$.readini(Equipment.ini,Firecape,$nick)) { notice $nick You don't have a fire cape. | halt }
    writeini -n Money.ini Money $nick $calc($.readini(Money.ini,money,$nick) + 2000000000)
    writeini -n Equipment.ini firecape $nick $calc($.readini(equipment.ini,firecape,$nick) -1)  
    if ($.readini(equipment.ini,firecape,$nick) < 1) {
      remini -n Equipment.ini firecape $nick
    }    
    notice $nick You have sold $s1(Fire Cape) for $s2(2B) $+ . You now have: $s2($price($.readini(Money.ini,money,$nick))) $+ . | halt 
  }
  if ($2 == ags) || ($2 == armadyl) || ($2 == arma) || ($2 == arm) {
    if (!$.readini(Equipment.ini,ags,$nick)) { notice $nick You don't have an Armadyl godsword.. | halt }
    writeini -n Money.ini Money $nick $calc($.readini(Money.ini,money,$nick) + 200000000)
    writeini -n Equipment.ini ags $nick $calc($.readini(equipment.ini,ags,$nick) -1)  
    if ($.readini(equipment.ini,ags,$nick) < 1) {
      remini -n Equipment.ini ags $nick
    }    
    notice $nick You have sold $s1(Armadyl godsword) for $s2(200M) $+ . You now have: $s2($price($.readini(Money.ini,money,$nick))) $+ . | halt 
  }
  if ($2 == bgs) || ($2 == bandos) || ($2 == bando) {
    if (!$.readini(Equipment.ini,bgs,$nick)) { notice $nick You don't have a Bandos godsword.. | halt }
    writeini -n Money.ini Money $nick $calc($.readini(Money.ini,money,$nick) + 250000000)
    writeini -n Equipment.ini bgs $nick $calc($.readini(equipment.ini,bgs,$nick) -1)  
    if ($.readini(equipment.ini,bgs,$nick) < 1) {
      remini -n Equipment.ini bgs $nick
    }    
    notice $nick You have sold $s1(Bandos godsword) for $s2(250M) $+ . You now have: $s2($price($.readini(Money.ini,money,$nick))) $+ . | halt 
  }
  if ($2 == sgs) || ($2 == Sara) || ($2 == saradomin) {
    if (!$.readini(Equipment.ini,sgs,$nick)) { notice $nick You don't have a Saradomin godsword.. | halt }
    writeini -n Money.ini Money $nick $calc($.readini(Money.ini,money,$nick) + 300000000)
    writeini -n Equipment.ini sgs $nick $calc($.readini(equipment.ini,sgs,$nick) -1)  
    if ($.readini(equipment.ini,sgs,$nick) < 1) {
      remini -n Equipment.ini sgs $nick
    }   
    notice $nick You have sold $s1(Saradomin godsword) for $s2(300M) $+ . You now have: $s2($price($.readini(Money.ini,money,$nick))) $+ . | halt 
  }
  if ($2 == zgs) || ($2 == Zammy) || ($2 == zamorak) {
    if (!$.readini(Equipment.ini,zgs,$nick)) { notice $nick You don't have a Zamorak godsword.. | halt }
    writeini -n Money.ini Money $nick $calc($.readini(Money.ini,money,$nick) + 200000000)
    writeini -n Equipment.ini zgs $nick $calc($.readini(equipment.ini,zgs,$nick) -1)  
    if ($.readini(equipment.ini,zgs,$nick) < 1) {
      remini -n Equipment.ini zgs $nick
    }     
    notice $nick You have sold $s1(Zamorak godsword) for $s2(200M) $+ . You now have: $s2($price($.readini(Money.ini,money,$nick))) $+ . | halt 
  }
  if ($2 == mbook) || ($2 == mage's) || ($2 == mages) { 
    if (!$.readini(Equipment.ini,mbook,$nick)) { notice $nick You don't have a Mage's book.. | halt }
    writeini -n Money.ini Money $nick $calc($.readini(Money.ini,money,$nick) + 500000000)
    writeini -n Equipment.ini mbook $nick $calc($.readini(equipment.ini,mbook,$nick) -1)  
    if ($.readini(equipment.ini,mbook,$nick) < 1) {
      remini -n Equipment.ini mbook $nick
    }      
    notice $nick You have sold $s1(Mage's Book) for $s2(500M) $+ . You now have: $s2($price($.readini(Money.ini,money,$nick))) $+ . | halt
  }
  if ($2 == accumulator) || ($2 == accum) || ($2 == backpack) { 
    if (!$.readini(Equipment.ini,accumulator,$nick)) { notice $nick You don't have an Accumulator.. | halt }
    writeini -n Money.ini Money $nick $calc($.readini(Money.ini,money,$nick) + 500000000)
    writeini -n Equipment.ini accumulator $nick $calc($.readini(equipment.ini,accumulator,$nick) -1)  
    if ($.readini(equipment.ini,accumulator,$nick) < 1) {
      remini -n Equipment.ini accumulator $nick
    }     
    notice $nick You have sold $s1(Accumulator) for $s2(500M) $+ . You now have: $s2($price($.readini(Money.ini,money,$nick))) $+ . | halt
  }
  else notice $nick You don't have any items bought from the store. For information about items that can be bought at the store, type: !store
}
