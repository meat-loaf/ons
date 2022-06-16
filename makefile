LUNAR_MAGIC=lunar_magic_330

#ROM_NAME=port2.smc
ROM_NAME=ons.smc

.PHONY: one_night_stand clean

asm_dir=asm
asm_features_dir=${asm_dir}/features

ASM_PATCHES=custom_bounce_blocks.asm dsx.asm item_memory.asm oam_alloc.asm
ASM_PATCH_TS=$(addprefix ${TS_DIR}/, $(patsubst %.asm,%_ts,$(ASM_PATCHES)))
ASM_PATCHES_FULL=$(addprefix ${asm_features_dir}/, ${ASM_PATCHES})

TS_DIR=.ts

AMK_FAKE_TS=${TS_DIR}/addmusic
PIXI_FAKE_TS=${TS_DIR}/pixi_run
GPS_FAKE_TS=${TS_DIR}/gps_run
GFX_FAKE_TS=${TS_DIR}/gfx_ins
SBAR_FAKE_TS=${TS_DIR}/statusbar_code
M16_FAKE_TS=${TS_DIR}/all_map16
MWL_FAKE_TS=${TS_DIR}/mwl_insert
GLOBAL_ANI_TS=${TS_DIR}/globalani
OBJTOOL_TS=${TS_DIR}/objtool
INIT_LEVEL_TS=${TS_DIR}/initial_level

# order is important here! when building clean,
# things that force LM to insert hijacks (levels, graphics)
# need to be done first, before the tools run
CORE_BUILD_RULES= \
	${INIT_LEVEL_TS} \
	${GFX_FAKE_TS} \
	${PIXI_FAKE_TS} \
	${MWL_FAKE_TS} \
	${M16_FAKE_TS} \
	${GLOBAL_ANI_TS} \
	${GPS_FAKE_TS} \
	${AMK_FAKE_TS} \
	${SBAR_FAKE_TS} \
	${OBJTOOL_TS} \
	${ASM_PATCH_TS} \

# should list _all_ the deps here but too many files have spaces.
# it's a ton of stuff to change and not currently worth the effort
# windows users truly do deserve the gulag
AMK_MUSIC_DEPS= \
	$(wildcard ./amk/music/*.txt)

PIXI_DIR=pixi
PIXI_FLAGS+=-d255spl
PIXI_LIST=${PIXI_DIR}/list.txt

GPS_FLAGS+=

GPS_DIR=gps
GPS_BLK_DIR=${GPS_DIR}/blocks
GPS_RT_DIR=${GPS_DIR}/routines

sprites_dir=${PIXI_DIR}/sprites
clusspr_dir=${PIXI_DIR}/cluster
shooter_dir=${PIXI_DIR}/shooters


asm_base_deps=${asm_dir}/main.asm \
	$(wildcard ${asm_dir}/headers/*.asm)

gfx_files= \
	$(wildcard Graphics/*.bin) \
	$(wildcard ExGraphics/*.bin)

sbar_dir=${asm_features_dir}/statusbar
statusbar_main=${sbar_dir}/status.asm
statusbar_deps=${sbar_dir}/statusbar_defs.asm \
	${sbar_dir}/disable_irq.asm

pixi_asm_sources= \
	$(wildcard ${PIXI_DIR}/asm/*.asm) \
	$(wildcard ${PIXI_DIR}/asm/spriteset/*.asm) \
	$(wildcard ${PIXI_DIR}/asm/spriteset/remaps/*.asm) \
	$(wildcard ${PIXI_DIR}/routines/*.asm) \
	$(wildcard ${sprites_dir}/*.asm) \
	$(wildcard ${sprites_dir}/*.cfg) \
	$(wildcard ${shooter_dir}/*.asm) \
	$(wildcard ${shooter_dir}/*.cfg) \
	$(wildcard ${clusspr_dir}/*.asm)

gps_asm_sources= ${GPS_DIR}/main.asm \
	$(wildcard ${GPS_BLK_DIR}/*.asm) \
	$(wildcard ${GPS_RT_DIR}/*.asm)

MWL_DIR=lvl
MWL_FNAME_BASE=level
MWL_FILES=$(wildcard ${MWL_DIR}/${MWL_FNAME_BASE}\\ *.mwl)

OBJTOOL_DIR=${asm_features_dir}/objectool

one_night_stand: ${TS_DIR} ${ROM_NAME} ${CORE_BUILD_RULES}

${ROM_NAME}:
	cp rom_src/smw_c.smc ${ROM_NAME}

# really, all these rules should have ${ROM_NAME} as a dependency...

${INIT_LEVEL_TS}: rom_src/smw_orig_1ff.mwl
	${LUNAR_MAGIC} -ImportLevel ${ROM_NAME} $< 1FF
	touch $@

${AMK_FAKE_TS}: ${AMK_MUSIC_DEPS}
	cd ./amk && WINEPREFIX=~/.wineprefix/smw_amk wine AddmusicK.exe ../${ROM_NAME}
	touch $@

${PIXI_FAKE_TS}: ${pixi_asm_sources} ${PIXI_LIST}
	${PIXI_DIR}/pixi ${PIXI_FLAGS} -l ${PIXI_LIST} ${ROM_NAME}
	touch $@

${GPS_FAKE_TS}: ${gps_asm_sources} ${GPS_DIR}/list.txt
	cd gps && ./gps ../${ROM_NAME} ${GPS_FLAGS}
	touch $@

${GFX_FAKE_TS}: ${gfx_files}
	${LUNAR_MAGIC} -ImportAllGraphics ${ROM_NAME}
	touch $@

${SBAR_FAKE_TS}: ${statusbar_main} ${statusbar_deps} ${asm_base_deps}
	asar $< ${ROM_NAME}
	touch $@

${M16_FAKE_TS}: AllMap16.map16
	${LUNAR_MAGIC} -ImportAllMap16 ${ROM_NAME} $<
	touch $@

${MWL_FAKE_TS}: ${MWL_FILES}
	${LUNAR_MAGIC} -ImportMultLevels ${ROM_NAME} ./${MWL_DIR}
	touch $@

${GLOBAL_ANI_TS}: rom_src/ani.smc
	${LUNAR_MAGIC} -TransferLevelGlobalExAnim ${ROM_NAME} $<
	touch $@

${OBJTOOL_TS}: ${OBJTOOL_DIR}/objectool.asm ${OBJTOOL_DIR}/custobjcode.asm
	asar $< ${ROM_NAME}
	touch $@

${ASM_PATCH_TS}: ${ASM_PATCHES_FULL}
	# this feels immensely cursed
	asar $(patsubst ${TS_DIR}%, ${asm_features_dir}%, $(patsubst %_ts, %.asm, $@) ${ROM_NAME})
	touch $@

${TS_DIR}:
	mkdir -p ${TS_DIR}
clean:
	rm -rf ${TS_DIR}
	rm ${ROM_NAME}
