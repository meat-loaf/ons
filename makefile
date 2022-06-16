ASM_DIR=asm
PATCHES=sr

LUNAR_MAGIC=lunar_magic_330

ROM_NAME=port2.smc

.PHONY: one_night_stand

BAISC_PATCHES=custom_bounce_blocks \
	dsx \
	item_memory \
	oam_alloc \
	

TS_DIR=.ts

AMK_FAKE_TS=${TS_DIR}/addmusic
PIXI_FAKE_TS=${TS_DIR}/pixi_run
GPS_FAKE_TS=${TS_DIR}/gps_run
GFX_FAKE_TS=${TS_DIR}/gfx_ins
SBAR_FAKE_TS=${TS_DIR}/statusbar_code
M16_FAKE_TS=${TS_DIR}/all_map16
MWL_FAKE_TS=${TS_DIR}/mwl_insert

CORE_BUILD_RULES= \
	${AMK_FAKE_TS} \
	${PIXI_FAKE_TS} \
	${GPS_FAKE_TS} \
	${GFX_FAKE_TS} \
	${SBAR_FAKE_TS} \
	${M16_FAKE_TS} \
	${MWL_FAKE_TS}

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

asm_dir=asm
asm_features_dir=${asm_dir}/features

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

one_night_stand: ${TS_DIR} ${CORE_BUILD_RULES}

${AMK_FAKE_TS}: ${AMK_MUSIC_DEPS}
	cd ./amk && WINEPREFIX=~/.wineprefix/smw_amk wine AddmusicK.exe ../${ROM_NAME}
	touch ${AMK_FAKE_TS}

${PIXI_FAKE_TS}: ${pixi_asm_sources} ${PIXI_LIST}
	${PIXI_DIR}/pixi ${PIXI_FLAGS} -l ${PIXI_LIST} ${ROM_NAME}
	touch ${PIXI_FAKE_TS}

${GPS_FAKE_TS}: ${gps_asm_sources} ${GPS_DIR}/list.txt
	cd gps && ./gps ../${ROM_NAME} ${GPS_FLAGS}
	touch ${GPS_FAKE_TS}

${GFX_FAKE_TS}: ${gfx_files}
	${LUNAR_MAGIC} -ImportAllGraphics ${ROM_NAME}
	touch ${GFX_FAKE_TS}

${SBAR_FAKE_TS}: ${statusbar_main} ${statusbar_deps} ${asm_base_deps}
	asar $< ${ROM_NAME}
	touch ${SBAR_FAKE_TS}

${M16_FAKE_TS}: AllMap16.map16
	${LUNAR_MAGIC} -ImportAllMap16 ${ROM_NAME} $<
	touch ${M16_FAKE_TS}

${MWL_FAKE_TS}: ${MWL_FILES}
	${LUNAR_MAGIC} -ImportMultLevels ${ROM_NAME} ./${MWL_DIR}
	touch ${MWL_FAKE_TS}

${TS_DIR}:
	mkdir -p ${TS_DIR}
