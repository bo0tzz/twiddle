# TODOs

This is a mess right now

* Refactor job/task runner setup (use a library, probably)
* Add test cases
* Implement channel following w/ CRON job
* Consider moving to a 'real' database for state storage
* Save ffmpeg logs for viewing in-app
* Path expansion for configured paths in config
* Post processing task for arbitrary commands
  * sed -i.bkp "s/\\\h//g" file.srt
  * Subtitle offset
* Job progress reporting system (w/ pubsub?)
* Character replacements in output filenames (remove illegal characters/spaces)
