includeonce

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FreeRAMs related.
;; You require at least 200 bytes of free ram to use this. You can reorganize the freerams as you desire if you know what are you doing.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!FreeRAM		= !star_coins_ram       ; If you need it, you can change this address to whatever address as long you have 200 bytes of consecutive RAMs. The default address uses freeRAMs after AddMusicK RAMs, so you can use with it without problems.

!LevelCoins		= !FreeRAM		;1 byte. Contains the flags of the star coins that has been collected within the level. Format 87654321.
!TempCoins		= !FreeRAM+1		;1 byte. A temporary value that holds the star coins flags collected within the level, this is for evade conflicts with the OW & the midway point. Format 87654321
!PreviousLevel		= !FreeRAM+2		;1 byte. Hold the previous level number played.
!PreviousCoins		= !FreeRAM+3		;1 byte. Hold ANOTHER backup of the star coins when you are travelling to a sublevel. Format 87654321.
!PreviousCoinsF		= !FreeRAM+4		;1 byte. Check if we are going to another level to make a backup of the star coins flags. Format: #$00 = No, Any other value = Yes
!LevelCoinsNum		= !FreeRAM+5		;1 byte. Hold the total number of star coins collected in a level, also used to know how many point will give a star coin.
!TotalCoinsNum		= !FreeRAM+6		;2 bytes. Hold the number of star coins collected in the game, this address gets updated when the "Course Clear!" appears and when the Keyhole is activated. Also this address is 16-bit.
!PerLevelFlags		= !FreeRAM+8		;96 bytes. Each byte contains the flags of the star coins collected in a level. Format 87654321
!PerMidPointFlags	= !PerLevelFlags+96	;96 bytes. Each byte contains the flags of the star coins collected in a level when the midpoint is collected. Format 87654321
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Misc things.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
!MaxStarCoins		= $05			;Max number of Star Coins in a level (max value possible is $08)
			 			;If you select more than five star coins, the counter will start to overwrite somethings in the vanilla status bar, like the bonus star counter and part of the item box.

!InstallStatusCounter	= 1			;Installs the counter in the status bar, it will destroy the yoshi coins counter and it doesn't require any freespace.		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Blocks stuff.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!UseNewSparkleEffect	= 0			;Change to 1 to use my sparkle effect. WARNING: May cause crashes if you do not install the Minor Extended Sprites patch.
!StarCoinSFXNumber	= $1A			;SFX that sounds when you touch the star coin. Visit this link if you want to change it: http://smwc.me/96604
!StarCoinSFXPort	= $1DFC			;SFX Port, check the same link if you want to change it.
!GivePoints		= 1			;Change to 1 if you want the star coins give points when they are collected.
!FirstPoints		= $09			;Amount of points that gives the FIRST star coin collected, no matter if you collect the third or the second star coin first, it will give this amount of points.
!SecondPoints		= $0A			;Same as above, but this is for the SECOND star coin.
!ThirdPoints		= $0B			;Same as above, but this is for the THIRD star coin.
!FourthPoints		= $0C			;Same as above, but this is for the FOURTH star coin.
!FifthPoints		= $0D			;Same as above, but this is for the FIFTH star coin.
!SixthPoints		= $0E			;Same as above, but this is for the SIXTH star coin.
!SeventhPoints		= $0E			;Same as above, but this is for the SEVENTH star coin.
!EighthPoints		= $0F			;Same as above, but this is for the EIGHTH star coin.
						;Allowed values:
						;$00 = Null/0
						;$01 = 10
						;$02 = 20
						;$03 = 40
						;$04 = 80
						;$05 = 100
						;$06 = 200
						;$07 = 400
						;$08 = 800
						;$09 = 1000
						;$0A = 2000
						;$0B = 4000
						;$0C = 8000
						;$0D = 1up
						;$0E = 2up
						;$0F = 3up
						;$10 = 5up (may glitch)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Layer 3 Status bar related.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!BlankStatusCoin	= $10			;Tile number used to fill spots in the status bar when there is no star coin collected.
!FullStatusCoin		= $12			;Tile number used to fill spots in the status bar when there is a star coin collected.
!Position		= $0EFF			;Position where the FIRST coin will be filled in the status bar, the other two coins will be filled in order to the right. Like: Coin 1, Coin 2, Coin 3
						;Check this diagrams to know how to replace this values.
						; http://media.smwcentral.net/Diagrams/StatusBarTiles.png
						; http://media.smwcentral.net/Diagrams/StatusBarMap.png
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Minor Extended Sprites related.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!SmallShine		= $6D			;Tile number of the smallest sparkle.
!MediumShine		= $6C			;Tile number of the small sparkle.
!LargeShine		= $5C			;Tile number of the large sparkle.
!Props			= $16			;Properties of ALL sparkles. Visit this link if you want to know how to replace this value: http://smwc.me/367797
!Size			= $00			;Size of ALL sparkles. $00 for 8x8, $02 for 16x16.
