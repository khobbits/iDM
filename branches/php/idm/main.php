#!/usr/bin/php
<?php
include_once('../SmartIRC.php');

$irc = &new Net_SmartIRC();
$irc->setDebug(4095);
$irc->setUseSockets(TRUE); 
$irc->setChannelSynching(FALSE);

$irc->connect('localhost', 12000);
$irc->login('admin', 'admin', 0, 'admin', 'omglikethisisapass');

include_once('idm.php');

$irc->listen();
$irc->disconnect();
?>