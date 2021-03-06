! $Id: ESMF_ArrayDataUTest.F90,v 1.1.5.1 2013-01-11 20:23:43 mathomp4 Exp $
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
program ESMF_ArrayDataUTest

!------------------------------------------------------------------------------

#include "ESMF_Macros.inc"

!==============================================================================
!BOP
! !PROGRAM: ESMF_ArrayDataTest - Check Array data storage integrity
!
! !DESCRIPTION:
!
! The code in this file drives Fortran Array data unit tests.
! The companion file ESMF\_Array.F90 contains the definitions for the
! LocalArray methods.
!
!-----------------------------------------------------------------------------
! !USES:
  use ESMF_TestMod     ! test methods
  use ESMF

  implicit none

!------------------------------------------------------------------------------
! The following line turns the CVS identifier string into a printable variable.
  character(*), parameter :: version = &
    '$Id: ESMF_ArrayDataUTest.F90,v 1.1.5.1 2013-01-11 20:23:43 mathomp4 Exp $'
!------------------------------------------------------------------------------
    
  ! cumulative result: count failures; no failures equals "all pass"
  integer :: result = 0

  ! individual test result code
  integer :: rc

  ! individual test failure message
  character(ESMF_MAXSTR) :: failMsg
  character(ESMF_MAXSTR) :: name

  integer :: i, j, petCount
  logical :: looptest

  ! Fortran array pointer of 4-byte integers
  integer (ESMF_KIND_I4),dimension(:), pointer :: fdata
  integer (ESMF_KIND_I4),dimension(:), pointer :: fdataSlice
  integer (ESMF_KIND_I4),dimension(:), pointer :: fptr

  type(ESMF_DistGrid) :: distgrid
  type(ESMF_Array)    :: array
  type(ESMF_VM)       :: vm

  character, allocatable :: buffer(:)
  integer :: buff_len, offset
  integer :: alloc_err
  type(ESMF_AttReconcileFlag) :: attreconflag
  type(ESMF_InquireFlag) :: inquireflag

  !-----------------------------------------------------------------------------
  call ESMF_TestStart(ESMF_SRCLINE, rc=rc)
  !-----------------------------------------------------------------------------

  ! get global VM
  call ESMF_VMGetGlobal(vm, rc=rc)
  if (rc /= ESMF_SUCCESS) call ESMF_Finalize(endflag=ESMF_END_ABORT)
  call ESMF_VMGet(vm, petCount=petCount, rc=rc)
  if (rc /= ESMF_SUCCESS) call ESMF_Finalize(endflag=ESMF_END_ABORT)

  ! prepare for Fortran allocatable array "data"
  allocate(fdata(-12:-6), stat=rc)
  do i = -12, -6
    fdata(i) = i*1000
  enddo

  ! prepare DistGrid
  distgrid = ESMF_DistGridCreate(minIndex=(/1/), maxIndex=(/7*petCount/), rc=rc)
  if (rc /= ESMF_SUCCESS) call ESMF_Finalize(endflag=ESMF_END_ABORT)

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Creating an Array from allocated Fortran array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  array = ESMF_ArrayCreate(distgrid, fdata, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Printing Array created from allocated Fortran array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayPrint(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Obtaining access to data in Array via Fortran array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayGet(array, farrayPtr=fptr, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Verifying data in Array via Fortran array pointer access"
  write(failMsg, *) "Incorrect data detected"
  looptest = .true.
  do i = -12, -6
    j = i + 12 + lbound(fptr, 1)
    print *, fptr(j), fdata(i)
    if (fptr(j) /= fdata(i)) looptest = .false.
  enddo
  call ESMF_Test(looptest, name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------
  
  !-----------------------------------------------------------------------------
  ! Fill in different values
  do i = -12, -6
    fdata(i) = fdata(i) + 57
  enddo
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Printing Array created from allocated Fortran array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayPrint(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Verifying data in Array via Fortran array pointer access"
  write(failMsg, *) "Incorrect data detected"
  looptest = .true.
  do i = -12, -6
    j = i + 12 + lbound(fptr, 1)
    print *, fptr(j), fdata(i)
    if (fptr(j) /= fdata(i)) looptest = .false.
  enddo
  call ESMF_Test(looptest, name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------
  
  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Destroying Array created from an allocated Fortran ",&
    "array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Creating an Array from allocated Fortran array pointer using ESMF_DATACOPY_VALUE"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  array = ESMF_ArrayCreate(distgrid, fdata, datacopyflag=ESMF_DATACOPY_VALUE, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Printing Array created from allocated Fortran array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayPrint(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Obtaining access to data in Array via Fortran array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayGet(array, farrayPtr=fptr, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Verifying data in Array via Fortran array pointer access"
  write(failMsg, *) "Incorrect data detected"
  looptest = .true.
  do i = -12, -6
    j = i + 12 + lbound(fptr, 1)
    print *, fptr(j), fdata(i)
    if (fptr(j) /= fdata(i)) looptest = .false.
  enddo
  call ESMF_Test(looptest, name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------
  
  !-----------------------------------------------------------------------------
  ! Fill in different values
  do i = -12, -6
    fdata(i) = fdata(i) + 57
  enddo
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Printing Array created from allocated Fortran array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayPrint(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Verifying data in Array via Fortran array pointer access"
  write(failMsg, *) "Incorrect data detected"
  looptest = .true.
  do i = -12, -6
    j = i + 12 + lbound(fptr, 1)
    print *, fptr(j), fdata(i)
    if (fptr(j) /= fdata(i)-57) looptest = .false.
  enddo
  call ESMF_Test(looptest, name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------
  
  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Destroying Array created from an allocated Fortran ",&
    "array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  ! test with array slice
  fdataSlice => fdata(:)

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Creating an Array from allocated Fortran array pointer slice"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  array = ESMF_ArrayCreate(distgrid, fdataSlice, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Printing Array created from allocated Fortran array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayPrint(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Obtaining access to data in Array via Fortran array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayGet(array, farrayPtr=fptr, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Verifying data in Array via Fortran array pointer access"
  write(failMsg, *) "Incorrect data detected"
  looptest = .true.
  do i = -12, -6
    j = i + 12 + lbound(fptr, 1)
    print *, fptr(j), fdata(i)
    if (fptr(j) /= fdata(i)) looptest = .false.
  enddo
  call ESMF_Test(looptest, name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------
  
  !-----------------------------------------------------------------------------
  ! Fill in different values
  do i = -12, -6
    fdata(i) = fdata(i) + 57
  enddo
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Printing Array created from allocated Fortran array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayPrint(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Verifying data in Array via Fortran array pointer access"
  write(failMsg, *) "Incorrect data detected"
  looptest = .true.
  do i = -12, -6
    j = i + 12 + lbound(fptr, 1)
    print *, fptr(j), fdata(i)
    if (fptr(j) /= fdata(i)) looptest = .false.
  enddo
  call ESMF_Test(looptest, name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------
  
  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Destroying Array created from an allocated Fortran ",&
    "array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  ! test with array slice
  deallocate(fdata)
  allocate(fdata(-20:10))
  do i = -20, 10
    fdata(i) = i*1000
  enddo
  fdataSlice => fdata(-12:-6)

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Creating an Array from allocated Fortran array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  array = ESMF_ArrayCreate(distgrid, fdataSlice, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Printing Array created from allocated Fortran array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayPrint(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Obtaining access to data in Array via Fortran array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayGet(array, farrayPtr=fptr, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Verifying data in Array via Fortran array pointer access"
  write(failMsg, *) "Incorrect data detected"
  looptest = .true.
  do i = -12, -6
    j = i + 12 + lbound(fptr, 1)
    print *, fptr(j), fdata(i)
    if (fptr(j) /= fdata(i)) looptest = .false.
  enddo
  call ESMF_Test(looptest, name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------
  
  !-----------------------------------------------------------------------------
  ! Fill in different values
  do i = -12, -6
    fdata(i) = fdata(i) + 57
  enddo
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Printing Array created from allocated Fortran array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayPrint(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Verifying data in Array via Fortran array pointer access"
  write(failMsg, *) "Incorrect data detected"
  looptest = .true.
  do i = -12, -6
    j = i + 12 + lbound(fptr, 1)
    print *, fptr(j), fdata(i)
    if (fptr(j) /= fdata(i)) looptest = .false.
  enddo
  call ESMF_Test(looptest, name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------
  
  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Destroying Array created from an allocated Fortran ",&
    "array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Creating an Array from allocated Fortran array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  array = ESMF_ArrayCreate(distgrid, fdataSlice, datacopyflag=ESMF_DATACOPY_VALUE, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Printing Array created from allocated Fortran array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayPrint(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Obtaining access to data in Array via Fortran array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayGet(array, farrayPtr=fptr, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Verifying data in Array via Fortran array pointer access"
  write(failMsg, *) "Incorrect data detected"
  looptest = .true.
  do i = -12, -6
    j = i + 12 + lbound(fptr, 1)
    print *, fptr(j), fdata(i)
    if (fptr(j) /= fdata(i)) looptest = .false.
  enddo
  call ESMF_Test(looptest, name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------
  
  !-----------------------------------------------------------------------------
  ! Fill in different values
  do i = -12, -6
    fdata(i) = fdata(i) + 57
  enddo
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Printing Array created from allocated Fortran array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayPrint(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Verifying data in Array via Fortran array pointer access"
  write(failMsg, *) "Incorrect data detected"
  looptest = .true.
  do i = -12, -6
    j = i + 12 + lbound(fptr, 1)
    print *, fptr(j), fdata(i)
    if (fptr(j) /= fdata(i)-57) looptest = .false.
  enddo
  call ESMF_Test(looptest, name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  ! BEGIN tests of certain INTERNAL methods.  They are subject
  ! to change and are NOT part of the ESMF user API.

  !-----------------------------------------------------------------------------
  !NEX_UTest
  ! test the serialize inquire-only option
  ! WARNING: This is testing an INTERNAL method.  It is NOT
  ! part of the supported ESMF user API!
  write(name, *) "Computing space for serialization buffer"
  write(failMsg, *) "Size could not be determined"
  buff_len = 1
  allocate (buffer(buff_len))
  offset = 0
  attreconflag = ESMF_ATTRECONCILE_OFF
  inquireflag  = ESMF_INQUIREONLY
  call c_esmc_arrayserialize (array, buffer, buff_len, offset,  &
      attreconflag, inquireflag, rc)
  print *, 'computed serialization buffer length =', offset, ' bytes'
  call ESMF_Test((rc == ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  deallocate (buffer)
  !-----------------------------------------------------------------------------
 
  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Allocate serialization buffer"
  write(failMsg, *) "Size was illegal"
  buff_len = offset
  allocate (buffer(buff_len), stat=alloc_err)
  rc = merge (ESMF_SUCCESS, ESMF_FAILURE, alloc_err == 0)
  call ESMF_Test((rc == ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------
  
  !-----------------------------------------------------------------------------
  !NEX_UTest
  ! test actually doing the serialization
  ! WARNING: This is testing an INTERNAL method.  It is NOT 
  ! part of the supported ESMF user API!
  write(name, *) "Serialization Array data"
  write(failMsg, *) "Serialization failed"
  buff_len = size (buffer)
  offset = 0
  attreconflag = ESMF_ATTRECONCILE_OFF
  inquireflag  = ESMF_NOINQUIRE
  call c_esmc_arrayserialize (array, buffer, buff_len, offset,  &
      attreconflag, inquireflag, rc)
  call ESMF_Test((rc == ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  !-----------------------------------------------------------------------------
  !NEX_UTest
  write(name, *) "Destroying Array created from an allocated Fortran ",&
    "array pointer"
  write(failMsg, *) "Did not return ESMF_SUCCESS"
  call ESMF_ArrayDestroy(array, rc=rc)
  call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

  ! garbage collection
  deallocate(fdata, stat=rc)

  call ESMF_DistGridDestroy(distgrid, rc=rc)
  if (rc /= ESMF_SUCCESS) call ESMF_Finalize(endflag=ESMF_END_ABORT)

  !-----------------------------------------------------------------------------
  call ESMF_TestEnd(result, ESMF_SRCLINE)
  !-----------------------------------------------------------------------------

end program ESMF_ArrayDataUTest
