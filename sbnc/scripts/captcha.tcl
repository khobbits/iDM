package require base64
package require http

setctx admin
bind join - * joincaptcha

proc joincaptcha {nick uhost hand chan} {
 if {[bncgetglobaltag "captcha.$chan"] == "1"} {
  upvar #0 captcha.$chan captcha
  set hash [base64::encode [expr rand()]]
  if {[info exists captcha]} {
    if {[llength $captcha] > 20} {
      set captcha [lrange $captcha end-19 end]
    }
  }
  lappend captcha "$hash@$nick"
  set url [http::formatQuery chan $chan user $hash]
  putnotc $nick "In order to be voiced in this channel, please complete this CAPTCHA: http://idm-bot.com/captcha.php?$url"
 }
}

proc captchareturn {chan action user message} {
  upvar #0 captcha.$chan captcha
  setctx admin
  if {[info exists captcha]} {
    set user [lsearch -inline $captcha "$user@*"]
    if {[string length $user] > 3} {
      lremove captcha $user
      set nick [lindex [split $user '@'] 1]
      if {[onchan $nick $chan]} {
        putchan $chan "$action $nick $message";
      }
      return 1
    } else {
      return "User code is invalid"
    }
  }
}

proc lremove {listVariable value} {
    upvar 1 $listVariable var
    set idx [lsearch -exact $var $value]
    set var [lreplace $var $idx $idx]
}