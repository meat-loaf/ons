This is (was, more likely) my main SMW hacking project for some time. It's rather in a messy state (mainly, older levels need sprites remapped from when I overhauled the sprite system) and
currently has more than a few warts. I'd like to revisit it someday and clean up the features I was working on, but I find that unlikely to happen anytime soon.
I thought at least some of the code might be good as a reference for someone else interested in making sweeping changes to the game's sprite system.
You can build a test version by placing a rom named smw.smc in the `rom_src' directory. The version I used was headered and had a sha1 sum
of 15b51da40ed5d1f868edfcb9a2b73784cfa0a326.
Build system depends on GNU make, python3, and the flips bps patcher.
