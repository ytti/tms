# TMS - Trivial Monitoring System

I needed stop-gap solution for commercial/license issue, I had very trivial
requirements just poll forbasic stuff and handle traps and do email/irc if
something happens.
I ended up NIHing this, instead of deploy some proper solution.

What TMS does

 * Periodically refereshes list of nodes from somewhere (corona)
 * Periodically discoveres interfaces from nodes
 * Receives traps (system reloaded, ifdown, ifup)
 * Periodically ICMP pings host
 * If interface/host changes from up->down, down->up sends email/irc msg
 * Records state changes in event DB

