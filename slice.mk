# slic3r config
SLIR3R ?=${HOME}/.Slic3r

FILAMENT ?=default
PRINT ?=default
PRINTER ?=default


# Strip out the suffix if a '.ini' is passed in (tab completion), make_all.sh
FILAMENT:=$(subst .ini,,${FILAMENT})
PRINT:=$(subst .ini,,${PRINT})
PRINTER:=$(subst .ini,,${PRINTER})

NOZZLE ?=0.4
PRINT_CENTER ?=150,150
SLIC3R_ARGS?=--print-center=${PRINT_CENTER} --nozzle-diameter=${NOZZLE}

# Find STL files if not already specified.
STL ?=$(shell find . -name "*.stl" | sort)

## Output Configuration:
# Directory structure for the output gcode.

# Protip, set this to Octoprint's folder for gcode.
BUILD_DEST?=build
GCODE_PATH:=${BUILD_DEST}/${PRINTER}-${NOZZLE}-${FILAMENT}
# Add suffix to base .stl
GCODE_NAME:=-${PRINT}
# Build gcode file path.
GCODE:=$(patsubst %.stl, \
	${GCODE_PATH}/%${GCODE_NAME}.gcode, \
	${STL:./%=%})

# Determine the number of threads to use.
THREADS?=$(shell grep -c ^processor /proc/cpuinfo)

# G-Code targets.
.PHONY: gcode
gcode: ${GCODE}

.PHONY: configs
configs:
	$(info $(shell find ~/.Slic3r/ -name *.ini | cut -f2 -d"."))

# Slice the STL files into G-code
${GCODE_PATH}/%${GCODE_NAME}.gcode: %.stl
	@mkdir -p ${dir ${@}}
	@echo Slicing: ${<}
	@slic3r ${SLIC3R_ARGS} \
	  --threads=${THREADS} \
	  --load=${SLIR3R}/filament/${FILAMENT}.ini \
	  --load=${SLIR3R}/print/${PRINT}.ini \
	  --load=${SLIR3R}/printer/${PRINTER}.ini \
	  --output=${@} \
	  ${<}
