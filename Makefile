# Specify the OpenSCAD executable
OPENSCAD = openscad

# Template file
TEMPLATE = guided_sewing_foot_template.scad

# Source files
SCAD_FILES = \
	guided_sewing_foot_2_5mm.scad \
	guided_sewing_foot_8mm.scad \
	guided_sewing_foot_9_25mm.scad

# Output directory
OUT_DIR = out

# STL files (derived from SCAD_FILES)
STL_FILES = $(patsubst %.scad, $(OUT_DIR)/%.stl, $(SCAD_FILES))

# Default target
all: $(STL_FILES)

# Rule to generate STL files with a dependency on the template
$(OUT_DIR)/%.stl: %.scad $(TEMPLATE)
	mkdir -p $(OUT_DIR)
	$(OPENSCAD) -o $@ $<

# Clean target
clean:
	rm -rf $(OUT_DIR)

.PHONY: all clean
