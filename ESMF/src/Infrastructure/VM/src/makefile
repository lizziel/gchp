# $Id: makefile,v 1.1.5.1 2013-01-11 20:23:44 mathomp4 Exp $

ALL: build_here 

SOURCEC	  = ESMCI_VM.C ESMCI_VMKernel.C
SOURCEF	  = 
SOURCEH	  = 

# List all .h files which should be copied to common include dir
STOREH	  = ESMCI_VM.h ESMCI_VMKernel.h

OBJSC     = $(addsuffix .o, $(basename $(SOURCEC)))
OBJSF     = $(addsuffix .o, $(basename $(SOURCEF)))

LIBBASE	  = libesmf
LOCDIR	  = src/Infrastructure/VM/src

CLEANDIRS  =
CLEANFILES =
CLOBBERDIS =

include ${ESMF_DIR}/makefile

DIRS	  = 

