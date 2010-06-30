##
## The sockets
##

proc idm:help {chan text} {
	set data "\00307\[\00303COMMANDS\00307\] \003Stats \00307\[\00303!dmstats \[chan\]\003, \00303!dmdrops\003, \00303!dmoverall\003, \00303!dmdaily\00307\]"
	return $data
}

proc idm:stats {chan text} {
	package require http
	if {[string first "#" [lindex $text 0]] != -1} {
		set targetchan [lindex $text 0]
	} else {
		set targetchan $chan
	}
	set data [::http::data [::http::geturl http://idm-bot.com/parser.php?[::http::formatQuery type chan c $targetchan] -timeout 3000]]
	return $data
}

proc idm:drops {chan text} {
	package require http
	set data [::http::data [::http::geturl http://idm-bot.com/parser.php?type=drops -timeout 3000]]
	return $data
}

proc idm:dailyt5 {chan text} {
	package require http
	set data [::http::data [::http::geturl http://idm-bot.com/parser.php?type=dailyt5 -timeout 3000]]
	return $data
}

proc idm:overallt5 {chan text} {
	package require http
	set data [::http::data [::http::geturl http://idm-bot.com/parser.php?type=overallt5 -timeout 3000]]
	return $data
}

##
## The output methods
##

proc idm:output {data method} {
	foreach line [split $data "\n"] {
		if {[string match {notice*} $method] == 1} {
			set ctx [getctx]
			sbnc:lowestnotice
			putserv "$method :$line"
			setctx $ctx
		} else {
			putserv "$method :$line"
		}
	}
}

set dm1floodlines 4
set dm1floodin 120
variable dm1flood_array
if { [info exists dm1flood_array] == 1} { unset dm1flood_array }

proc dmflood {nick who command} {
	global dm1floodin dm1floodlines dm1flood_array
	if { [info exists dm1flood_array($nick,0)] == 0} {
		set i [expr $dm1floodlines - 1]
		set dm1flood_array($nick,warn) 0
		while {$i >= 0} {
			set dm1flood_array($nick,$i) 0
			incr i -1
		}
		return 1
	}
	set i [expr ${dm1floodlines} - 1]
	while {$i >= 1} {
		set dm1flood_array($nick,$i) $dm1flood_array($nick,[expr $i - 1])
		incr i -1
	}
	set dm1flood_array($nick,0) [unixtime]
	if {[expr [unixtime] - $dm1flood_array($nick,[expr ${dm1floodlines} - 1])] <= ${dm1floodin}} {
		if { [expr [unixtime] - $dm1flood_array($nick,warn)] > 600 } {
			set dm1flood_array($nick,warn) [unixtime]
			putserv "notice $nick :Please limit dm stat commands to 4 in 2 minutes"
		}
		return 0
	}
	return 1
}


##
## The bind methods
##
proc idm:helpPRIV	{nick host handle chan text} {	if {[dmflood $nick $nick help]} {	idm:output [idm:help $chan $text]	"notice $nick"	} }
proc idm:helpPUB	{nick host handle chan text} {	if {[dmflood $nick $chan help]} {	idm:output [idm:help $chan $text]	"privmsg $chan"	} }

proc idm:statsPRIV	{nick host handle chan text} {	if {[dmflood $nick $nick stat]} {	idm:output [idm:stats $chan $text]	"notice $nick"	} }
proc idm:statsPUB	{nick host handle chan text} {	if {[dmflood $nick $chan pubs]} {	idm:output [idm:stats $chan $text]	"privmsg $chan"	} }
proc idm:dropsPRIV	{nick host handle chan text} {	if {[dmflood $nick $nick drop]} {	idm:output [idm:drops $chan $text]	"notice $nick"	} }
proc idm:dropsPUB	{nick host handle chan text} {	if {[dmflood $nick $chan pubs]} {	idm:output [idm:drops $chan $text]	"privmsg $chan"	} }
proc idm:dailyt5PRIV	{nick host handle chan text} {	if {[dmflood $nick $nick daily]} {	idm:output [idm:dailyt5 $chan $text]	"notice $nick"	} }
proc idm:dailyt5PUB	{nick host handle chan text} {	if {[dmflood $nick $chan pubt]} {	idm:output [idm:dailyt5 $chan $text]	"privmsg $chan"	} }
proc idm:overallt5PRIV	{nick host handle chan text} {	if {[dmflood $nick $nick overall]} {	idm:output [idm:overallt5 $chan $text]	"notice $nick"	} }
proc idm:overallt5PUB	{nick host handle chan text} {	if {[dmflood $nick $chan pubt]} {	idm:output [idm:overallt5 $chan $text]	"privmsg $chan"	} }

##
## The binds
##

foreach user {stats} {
	setctx $user
	bind pub - !dmcommands	idm:helpPRIV
	bind pub - !dmstats	idm:statsPRIV
	bind pub - !dmdrops	idm:dropsPRIV
	bind pub - !dmoverall	idm:overallt5PRIV
	bind pub - !dmdaily	idm:dailyt5PRIV
	bind pub - .dmcommands	idm:helpPRIV
	bind pub - .dmstats	idm:statsPRIV
	bind pub - .dmdrops	idm:dropsPRIV
	bind pub - .dmoverall	idm:overallt5PRIV
	bind pub - .dmdaily	idm:dailyt5PRIV
	bind pub - @dmcommands	idm:helpPUB
	bind pub - @dmstats	idm:statsPUB
	bind pub - @dmdrops	idm:dropsPUB
	bind pub - @dmoverall	idm:overallt5PUB
	bind pub - @dmdaily	idm:dailyt5PUB
}

setctx admin

putserv "privmsg #idm.staff Loaded BNC Script idm-stats.tcl"