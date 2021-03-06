// $Id$
//
// Earth System Modeling Framework
// Copyright 2002-2012, University Corporation for Atmospheric Research, 
// Massachusetts Institute of Technology, Geophysical Fluid Dynamics 
// Laboratory, University of Michigan, National Centers for Environmental 
// Prediction, Los Alamos National Laboratory, Argonne National Laboratory, 
// NASA Goddard Space Flight Center.
// Licensed under the University of Illinois-NCSA License.
//
//==============================================================================
#define ESMC_FILENAME "ESMCI_F90Interface_F.C"
//==============================================================================

#include "ESMCI_Macros.h"
#include "ESMCI_F90Interface.h"

// the interface subroutine names MUST be in lower case by ESMF convention

extern "C" {

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // ESMC_InterfaceInt interfaces
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  void FTN(c_esmc_interfaceintcreate1d)(ESMCI::InterfaceInt **array, 
    int *farray, int *len, int *rc){
#undef  ESMC_METHOD
#define ESMC_METHOD "c_esmc_interfaceintcreate1d()"
    *array = new ESMCI::InterfaceInt(farray, 1, len);
    *rc = ESMF_SUCCESS;
  }

  void FTN(c_esmc_interfaceintcreate2d)(ESMCI::InterfaceInt **array, 
    int *farray, int *len, int *rc){
#undef  ESMC_METHOD
#define ESMC_METHOD "c_esmc_interfaceintcreate2d()"
    *array = new ESMCI::InterfaceInt(farray, 2, len);
    *rc = ESMF_SUCCESS;
  }

  void FTN(c_esmc_interfaceintcreate3d)(ESMCI::InterfaceInt **array, 
    int *farray, int *len, int *rc){
#undef  ESMC_METHOD
#define ESMC_METHOD "c_esmc_interfaceintcreate3d()"
    *array = new ESMCI::InterfaceInt(farray, 3, len);
    *rc = ESMF_SUCCESS;
  }

  void FTN(c_esmc_interfaceintdestroy)(ESMCI::InterfaceInt **array,
    int *rc){
#undef  ESMC_METHOD
#define ESMC_METHOD "c_esmc_interfaceintdestroy()"
    delete *array;
    *rc = ESMF_SUCCESS;
  }

};
