#
# Makefile for COCS Game of Life Project Spring 2018
#
#
#
# Location of the processing programs
#
RASM  = /home/fac/wrc/bin/rasm
RLINK = /home/fac/wrc/bin/rlink

#
# Suffixes to be used or created
#
.SUFFIXES:	.asm .obj .lst .out

#
# Object files
#
OBJFILES = colony.obj get_input.obj

#
# Transformation rule: .asm into .obj
#
.asm.obj:
	$(RASM) -l $*.asm > $*.lst

#
# Transformation rule: .obj into .out
#
.obj.out:
	$(RLINK) -m -o $*.out $*.obj > $*.map

#
# Main target
#
colony.out:	$(OBJFILES)
	$(RLINK) -m -o $*.out $(OBJFILES) > $*.map

#
# Input Target
#
get_input.out: get_input.obj

