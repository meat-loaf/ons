This is (was, more likely) my main SMW hacking project for some time. It's rather
in a messy state (mainly, older levels need sprites remapped from when I
overhauled the sprite system) and currently has more than a few warts. I'd like to
revisit it someday and clean up the features I was working on, but I find that
unlikely to happen anytime soon. I thought at least some of the code might be good
as a reference for someone else interested in making sweeping changes to the game's
sprite system. You can build a test version by placing a headered USA v1.0 Super Mario
World rom named smw.smc in the `rom_src' directory, then run 'make'.
  * note: there's likely some small code clashing in the sprite code; you
    may find you need to patch the sprite code again afterwards.
Build system depends on GNU make, python3, and the flips bps patcher.

Non-comprehensive list of things I modified:
  * Completely custom sprite system ('normal' sprites are
    very similar to before but called long; the multitude
    of minor sprite types are condensed into a single 'ambient'
    sprite type).
    * Many sprites of both types still need to be implemented,
      bugs in ambient gfx routines (mostly lazy/bad high oam mirror
      setup)
  * Camera scripting subsystem allowing fine camera control
    * Needs heavy work to iron out, this feature is in its
      infancy
  * A better Spritesets implementation, to be completely dynamic
    * Slot allocation still needs to be done
  * A slightly modified 'dsx.asm' (for dynamic sprites) to allow for
    more efficient slot uploading (reduces the number of dmas needed
    to fill a slot in vram, saving a little vblank time)
  * uberasm not used, replaced with a custom implementation that can
    select things based on header values/unused (or now-hardcoded)
    exgfx slots
