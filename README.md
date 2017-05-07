# iDM

iDM was a toy project many many years ago.

There were a number of contributing authors over the years, and when I joined the team the game was already operational.

The project undertook a huge growth while I was lead developer, and the old hosting method (each bot required it's own copy of mIRC running on a windows server), was unable to scale to demand, so it was combined with sbnc multiplexing scripts, to work around things like per connection throttles and channel limits.

Due to this growth, multiple authors, and the addition of the sbnc layer, the code base is somewhat complicated.

The 'trunk' folder contains the primary mIRC-SL code.  
The 'sbnc' folder contains the sbnc code
The 'public_html' folder contains the php code.

I am aware the codebase contains all the original passwords for databases, irc accounts, etc, but as the site and software is nolonger running, I do not see reason to censor the data.

If you decide to read through this code, I recommend you do so with healthy skepticism, while there are some interesting tricks, and techniques embedded within, they aren't nessessaryly good choices, and unliely to be good programming practices.

Thanks,
KHobbits

## Implementation notes

### SBNC

SBNC was mainly used for multiplexing.  This allowed the bot to get around channel limits and message thottles.

Many of the files and scripts in the repo are not relevant to the project, the most interesting ones are:

https://github.com/khobbits/iDM/blob/master/sbnc/scripts/notice.tcl  
This file implements the 'notice mirror', which splits incoming and outgoing messages to use one bot for 'notice' commands, and the other for 'privmsg'.  
This file also handled the load balancing.  When an iDM bot was requested, this script found the bot with the lowest load to join the channel.

https://github.com/khobbits/iDM/blob/master/sbnc/scripts/idm-stats.tcl  
This file implemented the 'stats' commands, which simply returned data served by the website.

### mIRC Scripting Language

The core of the IRC bot was written in mIRC-SL.  

iDM was (re)written to move a large amount of the configuration, and user data to mySQL.  mIRC doesn't natively support mySQL, so a DLL was required.  
A wrapping script was created, to simplify the use of SQL as not all of the development team was familiar with it, and by using a wrapper we were able to mostly 'find and replace' a lot of the original code base.  
https://github.com/khobbits/iDM/blob/master/trunk/auto/SQLDatabase.mrc

I wrote a script 'autoloader', which when combined with svn commands, allowed us to remotely update scripts across all the instances of mIRC including those running on other servers.  
https://github.com/khobbits/iDM/blob/master/trunk/autoload.mrc

The entire 'attack' command system was rewritten to be database driven.  This meant adjusting damage or adding new attacks, was simply tweaking rows in databases.  
https://github.com/khobbits/iDM/blob/master/trunk/auto/All%20DM%20Commands.mrc

### Database

The database contained much of the iDM magic.

![db1](http://www.khobbits.co.uk/idm/idm1.png)
![db5](http://www.khobbits.co.uk/idm/idm5.png)
![db6](http://www.khobbits.co.uk/idm/idm6.png)
![db4](http://www.khobbits.co.uk/idm/idm4.png)

### PHP

The website was mainly used for three purposes, administraton (our staff members could query data, and handle ban appeals etc), and serve as home to the user shop.

The most interesting part about the site was that access to the players accounts, and the admin panel was done so via single use url's that you could request from IRC (if you were authenticated via nickserv).  This meant there was never any need for iDM to have any sort of password system.

