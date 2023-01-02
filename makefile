LUNAR_MAGIC=lunar_magic_333
SYM_DIR=.sym
ASAR=asar --symbols=wla --symbols-path=${SYM_DIR}/$(notdir $@).sym
TEST_EMU=snes9x-gtk
DBG_EMU=bsnes
FLIPS=flips
CLEAN_ROM_NAME=smw.smc
ROM_BASE_PATH=rom_src
CLEAN_ROM_FULL=${ROM_BASE_PATH}/${CLEAN_ROM_NAME}
#CLEAN_ROM_SHA1=da39a3ee5e6b4b0d3255bfef95601890afd80709

ROM_NAME_BASE=ons
ROM_NAME=${ROM_NAME_BASE}.smc
SYM_NAME=${ROM_NAME_BASE}.sym

ROM_RAW_BASE_SRC=rom_src/smw_1m_lmfastrom.smc
ROM_RAW_BASE_SRC_P=rom_src/smw_1m_lmfastrom.bps
GLOBALANI_SRC_ROM=rom_src/ani.smc
GLOBALANI_SRC_P=rom_src/ani.bps
OVERWORLD_SRC_ROM=rom_src/ow.smc
OVERWORLD_SRC_P=rom_src/ow.bps


.PHONY: one_night_stand \
	clean all_export \
	level_export \
	m16_export \
	globalani_export \
	overworld_export \
	test \
	debug \

asm_dir=asm
asm_features_dir=${asm_dir}/features
asm_tweaks_dir=${asm_dir}/tweaks

GEN_ROUTINE_FILES=$(wildcard ${asm_dir}/headers/routines/*.asm)

CUSTOM_SPR_COLLECTION_FILES=${ROMNAME}.ssc, ${ROMNAME}.mwt, ${ROMNAME}.mw2
CUSTOM_SPR_COLLECTION_JSON_DEFS_DIR=custom_sprite_collections
CUSTOM_SPR_COLLECTION_DEF_FILES=$(wildcard ${CUSTOM_SPR_COLLECTION_JSON_DEFS_DIR}/*.json)
CUSTOM_SPR_COLLECTION_SSC_BASE=${ROM_BASE_PATH}/base.ssc

ASM_HEADERS=$(wildcard ${asm_dir}/headers/*.asm) $(wildcard ${asm_dir}/headers/**/*.asm)

M16_FILE=AllMap16.map16

ASM_PATCHES=custom_bounce_blocks.asm dsx.asm main_gamemode_changes.asm
ASM_PATCH_TS=$(addprefix ${TS_DIR}/, $(patsubst %.asm,%_ts,$(ASM_PATCHES)))
ASM_PATCHES_FULL=$(addprefix ${asm_features_dir}/, ${ASM_PATCHES})

ASM_TWEAKS=optimize_2132_store.asm \
	yoshi_egg_spawn_fix.asm \
	vram_optimize.asm \
	solid_slope_assist_131.asm \
	obj_tiles.asm \
	no_death_scroll.asm \
	sspipe_fixes.asm \
	qblocks_item_mem.asm \
	level_constrain.asm \
	timer_backup.asm \
	left_at_goal.asm \
	layer2_ledge_fix.asm \
	mosaic.asm \

ASM_TWEAK_TS=$(addprefix ${TS_DIR}/, $(patsubst %.asm, %_ts,$(ASM_TWEAKS)))
ASM_TWEAKS_FULL=$(addprefix ${asm_tweaks_dir}/, ${ASM_TWEAKS})

TS_DIR=.ts

AMK_FAKE_TS=${TS_DIR}/addmusic
SPRITES_FAKE_TS=${TS_DIR}/sprites_run
GPS_FAKE_TS=${TS_DIR}/gps_run
UBER_FAKE_TS=${TS_DIR}/uberasm_run
GFX_FAKE_TS=${TS_DIR}/gfx_ins
SBAR_FAKE_TS=${TS_DIR}/statusbar_code
M16_FAKE_TS=${TS_DIR}/all_map16
MWL_FAKE_TS=${TS_DIR}/mwl_insert
GLOBAL_ANI_TS=${TS_DIR}/globalani
OVERWORLD_TS=${TS_DIR}/overworld
OBJTOOL_TS=${TS_DIR}/objtool
INIT_LEVEL_TS=${TS_DIR}/initial_level
FT_IMEM_TS=${TS_DIR}/item_mem
8x8_DMA_TS=${TS_DIR}/8x8dyn
SPR_COLLECTION_TS=${TS_DIR}/sprcoll

#CORE_BUILD_RULES= \
#	${GFX_FAKE_TS} \
#	${INIT_LEVEL_TS} \
#	${OVERWORLD_TS} \
#	${GLOBAL_ANI_TS} \
#	${PIXI_FAKE_TS} \
#	${MWL_FAKE_TS} \
#	${M16_FAKE_TS} \
#	${OBJTOOL_TS} \
#	${GPS_FAKE_TS} \
#	${AMK_FAKE_TS} \
#	${UBER_FAKE_TS} \
#	${SBAR_FAKE_TS} \
#	${ASM_PATCH_TS} \
#	${ASM_TWEAK_TS} \
#	${FT_IMEM_TS} \
#	${8x8_DMA_TS} \
#	${SPR_COLLECTION_TS} \


CORE_BUILD_RULES= \
	${GFX_FAKE_TS} \
	${M16_FAKE_TS} \
	${GLOBAL_ANI_TS} \
	${OBJTOOL_TS} \
	${SPRITES_FAKE_TS} \
	${GPS_FAKE_TS} \
	${AMK_FAKE_TS} \
	${SBAR_FAKE_TS} \
	${ASM_PATCH_TS} \
	${ASM_TWEAK_TS} \
	${FT_IMEM_TS} \
	${8x8_DMA_TS}

# should list _all_ the deps here but too many files have spaces.
# it's a ton of stuff to change and not currently worth the effort
# windows users truly do deserve the gulag
AMK_MUSIC_DEPS= \
	$(wildcard ./amk/music/*.txt) \

SPRITES_DIR=sprites
#PIXI_FLAGS+=-d255spl -sym ${SYM_DIR}/pixi.sym
#PIXI_LIST=${PIXI_DIR}/list.txt
#PIXI=LD_LIBRARY_PATH=/usr/local/lib ${PIXI_DIR}/pixi3


GPS_FLAGS+=-sym ../${SYM_DIR}/gps.sym

GPS_DIR=gps
GPS_BLK_DIR=${GPS_DIR}/blocks
GPS_RT_DIR=${GPS_DIR}/routines
#$GPS=WINEPREFIX=${HOME}/.wineprefix/smw_gps wine ./gps.exe
GPS=./gps3

UBERASM_DIR=uberasm
UBERASM_ASM_FILES= \
	${UBERASM_DIR}/list.txt \
	$(wildcard ${UBERASM_DIR}/gamemode/*.asm) \
	$(wildcard ${UBERASM_DIR}/level/*.asm) \
	$(wildcard ${UBERASM_DIR}/library/*.asm) \
	$(wildcard ${UBERASM_DIR}/overworld/*.asm) \
	$(wildcard ${UBERASM_DIR}/asm/base/*.asm) \

sprites_dir=${PIXI_DIR}/sprites


asm_base_deps=${asm_dir}/main.asm \
	${ASM_HEADERS}

gfx_files= \
	$(wildcard gfx/*.bin) \
	$(wildcard Graphics/*.bin) \
	$(wildcard ExGraphics/*.bin)

sbar_dir=${asm_features_dir}/statusbar
statusbar_main=${sbar_dir}/status.asm
statusbar_deps=${sbar_dir}/statusbar_defs.asm \
	${sbar_dir}/disable_irq.asm \
	${sbar_dir}/sbar_tilemap_rewrite.asm

sprites_asm_main_file=${SPRITES_DIR}/sprites.asm
sprites_asm_sources= \
	${sprites_asm_main_file} \
	${SPRITES_DIR}/list.def \
	$(wildcard ${SPRITES_DIR}/engine/*.asm) \
	$(wildcard ${SPRITES_DIR}/include/*.def) \
	$(wildcard ${SPRITES_DIR}/macros/*.asm) \
	$(wildcard ${SPRITES_DIR}/sprites/*.asm) \
	$(wildcard ${SPRITES_DIR}/spritesets/*.asm) \
	$(wildcard ${SPRITES_DIR}/dyn_gfx/*.bin)

gps_asm_sources=${GPS_DIR}/main.asm \
	$(wildcard ${GPS_BLK_DIR}/*.asm) \
	$(wildcard ${GPS_BLK_DIR}/**/*.asm) \
	$(wildcard ${GPS_BLK_DIR}/**/**/*.asm) \
	$(wildcard ${GPS_RT_DIR}/*.asm)

MWL_DIR=lvl
MWL_FNAME_BASE=level
#MWL_FILES=$(wildcard ${MWL_DIR}/${MWL_FNAME_BASE}\ *.mwl)

OBJTOOL_DIR=${asm_features_dir}/objectool

one_night_stand: ${CLEAN_ROM_FULL} ${TS_DIR} ${SYM_DIR} ${ROM_NAME} ${CORE_BUILD_RULES} ${SYM_NAME}

test: one_night_stand
	${TEST_EMU} ${ROM_NAME} >/dev/null 2>&1 &

debug: one_night_stand
	${DBG_EMU} ${ROM_NAME} &

${SYM_NAME}: $(wildcard ${SYM_DIR}/*.sym) ${asm_base_deps}
	cat ${SYM_DIR}/*.sym | uniq > $@
	./scripts/define_to_wla_sym.py ./asm/headers/ram.asm ./asm/headers/consts.asm >> $@

all_export: level_export m16_export globalani_export overworld_export

level_export:
	${LUNAR_MAGIC} -ExportMultLevels ${ROM_NAME} ${MWL_DIR}/level
	scripts/mwl_clean.py ${MWL_DIR}/level\ *.mwl
	touch ${MWL_FAKE_TS}

m16_export:
	${LUNAR_MAGIC} -ExportAllMap16 ${ROM_NAME} ${M16_FILE}
	touch ${M16_FAKE_TS}

globalani_export: ${CLEAN_ROM_FULL}
	cp ${CLEAN_ROM_FULL} ${GLOBALANI_SRC_ROM}
	${LUNAR_MAGIC} -TransferLevelGlobalExAnim ${GLOBALANI_SRC_ROM} ${ROM_NAME}
	flips --create --bps-delta ${CLEAN_ROM_FULL} ${GLOBALANI_SRC_ROM} ${GLOBALANI_SRC_P}
	touch ${GLOBAL_ANI_TS}

overworld_export:
	cp ${CLEAN_ROM_FULL} ${OVERWORLD_SRC_ROM}
	${LUNAR_MAGIC} -TransferOverworld ${OVERWORLD_SRC_ROM} ${ROM_NAME}
	flips --create --bps-delta ${CLEAN_ROM_FULL} ${OVERWORLD_SRC_ROM} ${OVERWORLD_SRC_P}
	touch ${OVERWORLD_TS}

${CLEAN_ROM_FULL}:
	$(info Base SMW ROM Image not found at ${CLEAN_ROM_FULL}. Aborting.)
	exit 1

${ROM_NAME}: ${ROM_RAW_BASE_SRC}
	cp ${ROM_RAW_BASE_SRC} ${ROM_NAME}
	asar scripts/smw_clean.asm ${ROM_NAME}

${GLOBALANI_SRC_ROM}: ${GLOBALANI_SRC_P}
	flips --apply ${GLOBALANI_SRC_P} ${CLEAN_ROM_FULL} ${GLOBALANI_SRC_ROM}

${OVERWORLD_SRC_ROM}: ${OVERWORLD_SRC_P}
	flips --apply ${OVERWORLD_SRC_P} ${CLEAN_ROM_FULL} ${OVERWORLD_SRC_ROM}

# really, all these rules should have ${ROM_NAME} as a dependency...

${ROM_RAW_BASE_SRC}: ${ROM_RAW_BASE_SRC_P}
	flips --apply ${ROM_RAW_BASE_SRC_P} ${CLEAN_ROM_FULL} ${ROM_RAW_BASE_SRC}

${INIT_LEVEL_TS}: rom_src/smw_orig_105.mwl
	${LUNAR_MAGIC} -ImportLevel ${ROM_NAME} $< 105
	touch $@

${AMK_FAKE_TS}: ${AMK_MUSIC_DEPS} ./amk/Addmusic_list.txt ./amk/Addmusic_sample\ groups.txt ./amk/Addmusic_sound\ effects.txt ./amk/asm/InstrumentData.asm
	cd ./amk && ./amk ../${ROM_NAME}
	touch $@

#${PIXI_FAKE_TS}: ${pixi_asm_sources} ${PIXI_LIST} ${INIT_LEVEL_TS} ${OBJTOOL_TS} ${ASM_HEADERS}
#	${PIXI} ${PIXI_FLAGS} -l ${PIXI_LIST} ${ROM_NAME}
#	touch $@
${SPRITES_FAKE_TS}: ${sprites_asm_sources} ${OBJTOOL_TS} ${ASM_HEADERS}
	${ASAR} ${sprites_asm_main_file} ${ROM_NAME}
	touch $@

${GPS_FAKE_TS}: ${gps_asm_sources} ${GPS_DIR}/list.txt ${ASM_HEADERS}
	cd gps && ${GPS} ${GPS_FLAGS} ../${ROM_NAME}
	touch $@

# paths are relative to the uberasm directory, no matter where its run from...insanity
${UBER_FAKE_TS}: ${UBERASM_ASM_FILES} ${ASM_HEADERS}
	bash -c 'mono ${UBERASM_DIR}/UberASMTool.exe list.txt ../${ROM_NAME} 2>/dev/null <<< '\n' && echo'
	touch $@

${GFX_FAKE_TS}: ${gfx_files}
	${LUNAR_MAGIC} -ImportAllGraphics ${ROM_NAME}
	touch $@

${SBAR_FAKE_TS}: ${statusbar_main} ${statusbar_deps} ${asm_base_deps} ${ASM_HEADERS}
	${ASAR} $< ${ROM_NAME}
	touch $@

${M16_FAKE_TS}: ${M16_FILE}
	${LUNAR_MAGIC} -ImportAllMap16 ${ROM_NAME} $<
	touch $@

${MWL_FAKE_TS}: ${MWL_DIR}/level\ *.mwl
	${LUNAR_MAGIC} -ImportMultLevels ${ROM_NAME} ./${MWL_DIR}
	touch $@

${GLOBAL_ANI_TS}: ${GLOBALANI_SRC_ROM}
	${LUNAR_MAGIC} -TransferLevelGlobalExAnim ${ROM_NAME} $<
	touch $@

${OVERWORLD_TS}: ${OVERWORLD_SRC_ROM}
	${LUNAR_MAGIC} -TransferOverworld ${ROM_NAME} $<
	touch $@

${OBJTOOL_TS}: ${OBJTOOL_DIR}/objectool.asm ${OBJTOOL_DIR}/custobjcode.asm ${FT_IMEM_TS}
	${ASAR} $< ${ROM_NAME}
	touch $@

${ASM_PATCH_TS}: ${ASM_PATCHES_FULL} ${asm_base_deps} ${FT_IMEM_TS}
	${ASAR} $(patsubst ${TS_DIR}%, ${asm_features_dir}%, $(patsubst %_ts, %.asm, $@) ${ROM_NAME})
	touch $@

${TS_DIR}/%_ts: ${asm_tweaks_dir}/%.asm ${asm_base_deps} ${FT_IMEM_TS}
	${ASAR} $(patsubst ${TS_DIR}%, ${asm_tweaks_dir}%, $(patsubst %_ts, %.asm, $@) ${ROM_NAME})
	touch $@

${FT_IMEM_TS}: ${asm_features_dir}/item_memory.asm
	${ASAR} $< ${ROM_NAME} > ${asm_dir}/headers/routines/item_memory_rts.asm
	touch $@

${8x8_DMA_TS}: ${asm_features_dir}/mario_8x8_dma/mario_8x8_dma.asm ${asm_features_dir}/mario_8x8_dma/mario_ext_tiles.bin
	${ASAR} $< ${ROM_NAME}
	touch $@

${SPR_COLLECTION_TS}: ${PIXI_FAKE_TS} ${CUSTOM_SPR_COLLECTION_DEF_FILES}
	./scripts/generate_sprite_collection.py --name-prefix ${ROM_NAME_BASE} --base-ssc ${CUSTOM_SPR_COLLECTION_SSC_BASE} -x 7 -y 7 ${CUSTOM_SPR_COLLECTION_DEF_FILES}
	touch $@

${TS_DIR}:
	mkdir -p ${TS_DIR}

${SYM_DIR}:
	mkdir -p ${SYM_DIR}

clean:
	rm -rf ${TS_DIR} ${GLOBALANI_SRC_ROM} ${OVERWORLD_SRC_ROM} ${GEN_ROUTINE_FILES} ${SYM_DIR} `find -name '${ROM_NAME_BASE}.*' -and -not -name '*.s16'`

