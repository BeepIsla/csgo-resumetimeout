# CSGO Resume Timeout
This plugin allows you to resume the match after calling a timeout. When calling a timeout again it will have the remaining timeout length. Everything is handled via the ingame vote menu.

Call a timeout: ESC > Call vote > Start Timeout

End a timeout: Just press F1, once everyone agrees the timeout resumes

# Todo
- Test what happens if someone joins while a resume-vote is on-going. I assume they don't get the vote popup and therefore cannot vote unless using the console command `vote option1`.
- Reset internal voting variables when the match is getting restarted via `mp_restartgame` (Currently only reloading the map will do anything)
- Split the plugin into more files to increase readability
