<?php

class idm
{    
    function normal (&$irc, &$data)
    {
        $text = 'Text1';
        
        $irc->message(SMARTIRC_TYPE_CHANNEL, '#idm.staff', $text);
    }    
}

$idm = &new idm();
$irc->registerActionhandler(SMARTIRC_TYPE_CHANNEL, '^!test', $idm, 'normal');
?>