// $Id: ESMCI_F90Interface.C,v 1.1.5.1 2013-01-11 20:23:44 mathomp4 Exp $
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
#define ESMC_FILENAME "ESMCI_F90Interface.C"
//==============================================================================

//-----------------------------------------------------------------------------

#include "ESMCI_Macros.h"
#include "ESMCI_LogErr.h"                  // for LogErr
#include "ESMCI_LogMacros.inc"
#include "ESMCI_F90Interface.h"

//-----------------------------------------------------------------------------

//==============================================================================
// prototypes for Fortran interface routines called by C++ code below
extern "C" {
  void FTN(f_esmf_fortranudtpointersize)(int *size);
  void FTN(f_esmf_fortranudtpointercopy)(void *dst, void *src);
}
//==============================================================================

namespace ESMCI {
  
  F90ClassHolder::F90ClassHolder(void **udtPtr){
    // constructor that stores a user derived type (UDT) inside F90ClassHolder
#undef  ESMC_METHOD
#define ESMC_METHOD "F90ClassHolder()"
    int udtSize;
    FTN(f_esmf_fortranudtpointersize)(&udtSize);
    if (sizeof(ESMCI::F90ClassHolder) < udtSize){
      int localrc = ESMC_RC_NOT_IMPL;
      ESMC_LogDefault.MsgFoundError(ESMC_RC_INTNRL_BAD, 
        "- hardcoded ESMCI::F90ClassHolder size smaller than UDT size"
        " determined at runtime", ESMC_CONTEXT, &localrc);
      throw localrc;  // bail out with exception
    }
    FTN(f_esmf_fortranudtpointercopy)((void *)this, (void *)udtPtr); 
  }
  
  int F90ClassHolder::castToFortranUDT(void **udtPtr){
    int rc=ESMC_RC_NOT_IMPL;
    FTN(f_esmf_fortranudtpointercopy)((void *)udtPtr, (void *)this);
    // return successfully
    rc = ESMF_SUCCESS;
    return rc;
  }
  
  //--------------------------------------------------------------------------

  InterfaceInt::InterfaceInt(void){
    // constructor
    array = NULL;
    dimCount = 0;
  }

  InterfaceInt::InterfaceInt(int *arrayArg, int lenArg){
    // constructor, special case 1d
    array = arrayArg;
    dimCount = 1;
    extent[0]=lenArg;
  }

  InterfaceInt::InterfaceInt(std::vector<int> &arrayArg){
    // constructor, special case 1d
    array = &(arrayArg[0]);
    dimCount = 1;
    extent[0]=arrayArg.size();
  }

  InterfaceInt::InterfaceInt(int *arrayArg, int dimArg, const int *lenArg){
    // constructor
    array = arrayArg;
    dimCount = dimArg;
    for (int i=0; i<dimCount; i++)
      extent[i]=lenArg[i];
  }

  InterfaceInt::~InterfaceInt(void){
    // destructor
    array = NULL;
    dimCount = 0;
  }
  
  

} // namespace ESMCI
