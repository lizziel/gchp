! $Id: ESMF_LogErrEx.F90,v 1.1.5.1 2013-01-11 20:23:44 mathomp4 Exp $
!
! Earth System Modeling Framework
! Copyright 2002-2012, University Corporation for Atmospheric Research,
! Massachusetts Institute of Technology, Geophysical Fluid Dynamics
! Laboratory, University of Michigan, National Centers for Environmental
! Prediction, Los Alamos National Laboratory, Argonne National Laboratory,
! NASA Goddard Space Flight Center.
! Licensed under the University of Illinois-NCSA License.
!
!==============================================================================
!

    program ESMF_LogErrEx

!------------------------------------------------------------------------------
!ESMF_EXAMPLE	Writing messages to log with different methods.
!==============================================================================
!BOC
! !PROGRAM: ESMF_LogErrEx - Log Error examples
!
! !DESCRIPTION:
!
! This program shows examples of Log Error writing
!-----------------------------------------------------------------------------

! Macros for cpp usage
! File define
#define ESMF_FILENAME "ESMF_LogErrEx.F90"
! Method define
#define ESMF_METHOD "program ESMF_LogErrEx"
#include "ESMF_LogMacros.inc"

    ! ESMF Framework module
    use ESMF
    implicit none
    
    ! return variables
    integer :: rc1, rc2, rc3, rcToTest, allocRcToTest
    type(ESMF_LOG) :: alog  ! a log object that is not the default log
    type(ESMF_LogKind_Flag) :: logkindflag
    type(ESMF_Time) :: time
    integer, pointer :: intptr(:)
!EOC
    integer :: finalrc
    finalrc = ESMF_SUCCESS

!BOE
!\subsubsection{Default Log}

! This example shows how to use the default Log.  This example does not use cpp
! macros but does use multi Logs.  A separate Log will be created for each PET.
!EOE

!BOC
    ! Initialize ESMF to initialize the default Log
    call ESMF_Initialize(rc=rc1, logkindflag=ESMF_LOGKIND_MULTI)
!EOC

    if (rc1.NE.ESMF_SUCCESS) then
        finalrc = ESMF_RC_OBJ_BAD
    end if

!BOC
    ! LogWrite 
    call ESMF_LogWrite("Log Write 2", ESMF_LOGMSG_INFO, rc=rc2)
!EOC

    if (rc2.NE.ESMF_SUCCESS) then
        finalrc = ESMF_RC_OBJ_BAD
    end if

!BOC
    ! LogMsgSetError
    call ESMF_LogSetError(ESMF_RC_OBJ_BAD, msg="Convergence failure", &
                             rcToReturn=rc2)
    ! LogMsgFoundError
    call ESMF_TimeSet(time, calkindflag=ESMF_CALKIND_NOCALENDAR)
    call ESMF_TimeSyncToRealTime(time, rc=rcToTest)
    if (ESMF_LogFoundError(rcToTest, msg="getting wall clock time", &
                              rcToReturn=rc2)) then
        ! Error getting time. The previous call will have printed the error
        ! already into the log file.  Add any additional error handling here.
        ! (This call is expected to provoke an error from the Time Manager.)
    endif

    ! LogMsgFoundAllocError
    allocate(intptr(10), stat=allocRcToTest)
    if (ESMF_LogFoundAllocError(allocRcToTest, msg="integer array", &
                                   rcToReturn=rc2)) then
        ! Error during allocation.  The previous call will have logged already
        ! an error message into the log.
    endif
    deallocate(intptr)
!EOC

!BOE
!\subsubsection{User created Log}
! This example shows how to use a user created Log.  This example uses
! cpp macros.
!EOE

!BOC
    ! Open a Log named "Testlog.txt" associated with alog.
    call ESMF_LogOpen(alog, "TestLog.txt", rc=rc1)
!EOC

    if (rc1.NE.ESMF_SUCCESS) then
        finalrc = ESMF_FAILURE
    end if

!BOC
    ! LogWrite
    call ESMF_LogWrite("Log Write 2", ESMF_LOGMSG_INFO, &
                       line=__LINE__, file=ESMF_FILENAME, &
                       method=ESMF_METHOD, log=alog, rc=rc2)
!EOC

    if (rc2.NE.ESMF_SUCCESS) then
        finalrc = ESMF_RC_OBJ_BAD
    end if

!BOC
    ! LogMsgSetError
    call ESMF_LogSetError(ESMF_RC_OBJ_BAD,  msg="Interpolation Failure", &
                          line=__LINE__, file=ESMF_FILENAME, &
                           method=ESMF_METHOD, rcToReturn=rc2, log=alog)
!EOC

    if (rc2.NE.ESMF_RC_OBJ_BAD) then
        finalrc = ESMF_RC_OBJ_BAD
    end if

!BOE
!\subsubsection{Get and Set}
! This example shows how to use Get and Set routines, on both the default Log
! and the user created Log from the previous examples.
!EOE

!BOC
    ! This is an example showing a query of the default Log.  Please note that
    ! no Log is passed in the argument list, so the default Log will be used.
    call ESMF_LogGet(logkindflag=logkindflag, rc=rc3)
!EOC

    if (rc3.NE.ESMF_SUCCESS) then
        finalrc = ESMF_RC_OBJ_BAD
    end if

!BOC
    ! This is an example setting a property of a Log that is not the default.
    ! It was opened in a previous example, and the handle for it must be
    ! passed in the argument list.
    call ESMF_LogSet(log=alog, logmsgAbort=(/ESMF_LOGMSG_ERROR/), rc=rc2)
!EOC

    if (rc2.NE.ESMF_SUCCESS) then
        finalrc = ESMF_RC_OBJ_BAD
    end if

!BOC
    ! Close the user log.
    call ESMF_LogClose(alog, rc=rc3)
!EOC

    if (rc3.NE.ESMF_SUCCESS) then
        finalrc = ESMF_RC_OBJ_BAD
    end if

!BOC
    ! Finalize ESMF to close the default log
    call ESMF_Finalize(rc=rc1)
!EOC

    if (rc1.NE.ESMF_SUCCESS) then
        finalrc = ESMF_RC_OBJ_BAD
    end if

    if (finalrc.EQ.ESMF_SUCCESS) then
        print *, "PASS: ESMF_LogErrEx.F90"
    else
        print *, "FAIL: ESMF_LogErrEx.F90"
    end if

end program
