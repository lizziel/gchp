! $Id: ESMF_StateReconcileUTest.F90,v 1.1.5.1 2013-01-11 20:23:44 mathomp4 Exp $
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


module ESMF_StateReconcileUTest_Mod
use ESMF
implicit none

contains

subroutine comp_dummy(gcomp, rc)
   type(ESMF_GridComp) :: gcomp
   integer, intent(out) :: rc

   rc = ESMF_SUCCESS
end subroutine comp_dummy
    

! Initialize routine which creates "field1" on PETs 0 and 1
subroutine comp1_init(gcomp, istate, ostate, clock, rc)
    type(ESMF_GridComp)  :: gcomp
    type(ESMF_State)     :: istate, ostate
    type(ESMF_Clock)     :: clock
    integer, intent(out) :: rc

    type(ESMF_Field) :: field1, field1nest
    type(ESMF_State) :: neststate

    print *, "i am comp1_init"

    rc = ESMF_FAILURE
    field1 = ESMF_FieldEmptyCreate(name="Comp1 Field", rc=rc)
    if (rc .ne. ESMF_SUCCESS) return
  
    call ESMF_StateAdd(istate, (/field1/), rc=rc)
    if (rc .ne. ESMF_SUCCESS) return

    neststate = ESMF_StateCreate(name="Nested State", rc=rc)
    if (rc .ne. ESMF_SUCCESS) return
    
    call ESMF_StateAdd(istate, (/neststate/), rc=rc)
    if (rc .ne. ESMF_SUCCESS) return
    
    field1nest = ESMF_FieldEmptyCreate(name="Comp1 Field in nested State", rc=rc)
    if (rc .ne. ESMF_SUCCESS) return

    call ESMF_StateAdd(neststate, (/field1nest/), rc=rc)
    if (rc .ne. ESMF_SUCCESS) return

end subroutine comp1_init

! Initialize routine which creates "field2" on PETs 2 and 3
subroutine comp2_init(gcomp, istate, ostate, clock, rc)
    type(ESMF_GridComp)  :: gcomp
    type(ESMF_State)     :: istate, ostate
    type(ESMF_Clock)     :: clock
    integer, intent(out) :: rc

    type(ESMF_Field) :: field2

    print *, "i am comp2_init"

    rc = ESMF_FAILURE
    field2 = ESMF_FieldEmptyCreate(name="Comp2 Field", rc=rc)
    if (rc .ne. ESMF_SUCCESS) return
    
    call ESMF_StateAdd(istate, (/field2/), rc=rc)
    if (rc .ne. ESMF_SUCCESS) return

end subroutine comp2_init

! Finalize routine which destroys "field1" on PETs 0 and 1
subroutine comp1_final(gcomp, istate, ostate, clock, rc)
    type(ESMF_GridComp)  :: gcomp
    type(ESMF_State)     :: istate, ostate
    type(ESMF_Clock)     :: clock
    integer, intent(out) :: rc

    type(ESMF_Field) :: field1, field1nest
    type(ESMF_State) :: neststate

    print *, "i am comp1_final"

    call ESMF_StateGet(istate, "Comp1 Field", field1,  rc=rc)
    if (rc .ne. ESMF_SUCCESS) return

    call ESMF_FieldDestroy(field1, rc=rc)
    if (rc .ne. ESMF_SUCCESS) return

    call ESMF_StateGet(istate, "Nested State", neststate,  rc=rc)
    if (rc .ne. ESMF_SUCCESS) return

    call ESMF_StateGet(neststate, "Comp1 Field in nested State", field1nest,  rc=rc)
    if (rc .ne. ESMF_SUCCESS) return

    call ESMF_FieldDestroy(field1nest, rc=rc)
    if (rc .ne. ESMF_SUCCESS) return

    call ESMF_StateDestroy(neststate, rc=rc)
    if (rc .ne. ESMF_SUCCESS) return

end subroutine comp1_final

! Finalize routine which destroys "field2" on PETs 2 and 3
subroutine comp2_final(gcomp, istate, ostate, clock, rc)
    type(ESMF_GridComp)  :: gcomp
    type(ESMF_State)     :: istate, ostate
    type(ESMF_Clock)     :: clock
    integer, intent(out) :: rc

    type(ESMF_Field) :: field2

    print *, "i am comp2_final"

    call ESMF_StateGet(istate, "Comp2 Field", field2,  rc=rc)
    if (rc .ne. ESMF_SUCCESS) return

    call ESMF_FieldDestroy(field2, rc=rc)
    if (rc .ne. ESMF_SUCCESS) return

end subroutine comp2_final

end module ESMF_StateReconcileUTest_Mod



program ESMF_StateReconcileUTest

!------------------------------------------------------------------------------
!==============================================================================
! !PROGRAM: ESMF_StateReconcileUTest - State reconciliation
!
! !DESCRIPTION:
!
! This program tests using the State Reconcile function
!  both concurrently and sequentially.
!
!-----------------------------------------------------------------------------
#include "ESMF_Macros.inc"

    ! ESMF Framework module
    use ESMF
    use ESMF_TestMod
    use ESMF_StateReconcileUTest_Mod
    implicit none


    !-------------------------------------------------------------------------
    ! Local variables
    integer :: rc
    type(ESMF_State) :: state1
    type(ESMF_GridComp) :: comp1, comp2
    type(ESMF_VM) :: vm
    character(len=ESMF_MAXSTR) :: comp1name, comp2name, statename
    logical :: reconcile_needed, recneeded_expected

    ! individual test failure message
    character(ESMF_MAXSTR) :: failMsg
    character(ESMF_MAXSTR) :: name
    integer :: result = 0, localPet

    !-------------------------------------------------------------------------

    call ESMF_TestStart(ESMF_SRCLINE, rc=rc)  ! calls ESMF_Initialize()

    if (.not. ESMF_TestMinPETs(4, ESMF_SRCLINE)) goto 10


    ! Get the global VM for this job.
    call ESMF_VMGetGlobal(vm=vm, rc=rc)
    
    call ESMF_VMGet(vm, localPet=localPet, rc=rc)

    !-------------------------------------------------------------------------
    ! exclusive component test section
    !-------------------------------------------------------------------------

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    comp1name = "Atmosphere"
    comp1 = ESMF_GridCompCreate(name=comp1name, petList=(/ 0, 1 /), rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Creating a Gridded Component"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)


    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    comp2name = "Ocean"
    comp2 = ESMF_GridCompCreate(name=comp2name, petList=(/ 2, 3 /), rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Creating a Gridded Component"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    statename = "Ocn2Atm"
    state1 = ESMF_StateCreate(name=statename, rc=rc)  
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Creating a State"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    reconcile_needed = ESMF_StateIsReconcileNeeded (state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Testing empty State for reconcile needed"
    call ESMF_Test(rc == ESMF_SUCCESS, name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    write(failMsg, *) "Did not return .false. for empty State"
    call ESMF_Test(.not. reconcile_needed, name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    reconcile_needed = ESMF_StateIsReconcileNeeded (state1,  &
        vm=vm, collectiveflag=.true., rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Testing empty State for reconcile needed (collective)"
    call ESMF_Test(rc == ESMF_SUCCESS, name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    write(failMsg, *) "Did not return .false. for empty State"
    call ESMF_Test(.not. reconcile_needed, name, failMsg, result, ESMF_SRCLINE)

    ! In SetServices() the VM for each component is initialized.
    ! Normally you would call SetEntryPoint inside set services,
    ! but to make this test very short, they are called inline below.

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompSetServices(comp1, userRoutine=comp_dummy, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompSetServices"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompSetServices(comp2, userRoutine=comp_dummy, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompSetServices"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompSetEntryPoint(comp1, ESMF_METHOD_INITIALIZE, &
      userRoutine=comp1_init, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompSetEntryPoint"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompSetEntryPoint(comp2, ESMF_METHOD_INITIALIZE, &
      userRoutine=comp2_init, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompSetEntryPoint"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompSetEntryPoint(comp1, ESMF_METHOD_FINALIZE, &
      userRoutine=comp1_final, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompSetEntryPoint"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompSetEntryPoint(comp2, ESMF_METHOD_FINALIZE, &
      userRoutine=comp2_final, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompSetEntryPoint"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompInitialize(comp1, importState=state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompInitialize"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompInitialize(comp2, importState=state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompInitialize"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_StateValidate(state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling StateValidate"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    reconcile_needed = ESMF_StateIsReconcileNeeded (state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Testing modified State for reconcile needed"
    call ESMF_Test(rc == ESMF_SUCCESS, name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    write(failMsg, *) "Did not return .true. for modified State"
    call ESMF_Test(reconcile_needed, name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    reconcile_needed = ESMF_StateIsReconcileNeeded (state1,  &
        vm=vm, collectiveflag=.true., rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Testing modified State for reconcile needed (collective)"
    call ESMF_Test(rc == ESMF_SUCCESS, name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    write(failMsg, *) "Did not return .true. for modified State"
    call ESMF_Test(reconcile_needed, name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_StateReconcile(state1, vm=vm, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling StateReconcile in concurrent mode"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_StateValidate(state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling StateValidate"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    reconcile_needed = ESMF_StateIsReconcileNeeded (state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Testing reconciled State for reconcile needed"
    call ESMF_Test(rc == ESMF_SUCCESS, name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    ! Note that even though the top level State should have its reconcileneeded
    ! flag cleared, the two nested States still should have their flags set.
    recneeded_expected = localpet == 0 .or. localpet == 1
    write(failMsg, *) "Did not return correct result for reconciled State",  &
        localpet, reconcile_needed, recneeded_expected
    call ESMF_Test(reconcile_needed .eqv. recneeded_expected,  &
        name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    reconcile_needed = ESMF_StateIsReconcileNeeded (state1,  &
        vm=vm, collectiveflag=.true., rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Testing reconciled State for reconcile needed (collective)"
    call ESMF_Test(rc == ESMF_SUCCESS, name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    ! Note that even though the top level State should have its reconcileneeded
    ! flag cleared, two nested States still should have their flags set.  So the
    ! collective ESMF_StateIsReconcileNeeded function should return .true..
    write(failMsg, *) "Did not return correct collective result for reconciled State",  &
        localpet, reconcile_needed, recneeded_expected
    call ESMF_Test(reconcile_needed,  &
        name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    ! Test redundant reconcile
    call ESMF_StateReconcile(state1, vm=vm, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling 2nd StateReconcile in concurrent mode"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_StateValidate(state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling StateValidate on 2nd StateReconcile"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompFinalize(comp1, importState=state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompFinalize"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompFinalize(comp2, importState=state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompFinalize"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompDestroy(comp1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompDestroy"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompDestroy(comp2, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompDestroy"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_StateDestroy(state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling StateDestroy"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)


    !-------------------------------------------------------------------------
    !-------------------------------------------------------------------------

    !-------------------------------------------------------------------------
    ! sequential component test section
    !-------------------------------------------------------------------------

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    comp1name = "Atmosphere"
    comp1 = ESMF_GridCompCreate(name=comp1name, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Creating a Gridded Component"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    comp2name = "Ocean"
    comp2 = ESMF_GridCompCreate(name=comp2name, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Creating a Gridded Component"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    statename = "Ocn2Atm"
    state1 = ESMF_StateCreate(name=statename, rc=rc)  
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Creating a State"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)


    ! In SetServices() the VM for each component is initialized.
    ! Normally you would call SetEntryPoint inside set services,
    ! but to make this test very short, they are called inline below.

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompSetServices(comp1, userRoutine=comp_dummy, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompSetServices"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompSetServices(comp2, userRoutine=comp_dummy, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompSetServices"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompSetEntryPoint(comp1, ESMF_METHOD_INITIALIZE, &
      userRoutine=comp1_init, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompSetEntryPoint"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompSetEntryPoint(comp2, ESMF_METHOD_INITIALIZE, &
      userRoutine=comp2_init, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompSetEntryPoint"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompSetEntryPoint(comp1, ESMF_METHOD_FINALIZE, &
      userRoutine=comp1_final, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompSetEntryPoint"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompSetEntryPoint(comp2, ESMF_METHOD_FINALIZE, &
      userRoutine=comp2_final, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompSetEntryPoint"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompInitialize(comp1, importState=state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompInitialize"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompInitialize(comp2, importState=state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompInitialize"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_StateValidate(state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling StateValidate"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_StateReconcile(state1, vm=vm, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling StateReconcile in sequential mode"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_StateValidate(state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling StateValidate"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    ! Test redundant reconcile
    call ESMF_StateReconcile(state1, vm=vm, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling 2nd StateReconcile in sequential mode"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_StateValidate(state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling StateValidate on 2nd StateReconcile"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompFinalize(comp1, importState=state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompFinalize"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompFinalize(comp2, importState=state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompFinalize"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompDestroy(comp1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompDestroy"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompDestroy(comp2, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompDestroy"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_StateDestroy(state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling StateDestroy"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)


    !-------------------------------------------------------------------------
    !-------------------------------------------------------------------------


    !-------------------------------------------------------------------------
    ! run-in-parent-context component test section
    !-------------------------------------------------------------------------

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    comp1name = "Atmosphere"
    comp1 = ESMF_GridCompCreate(name=comp1name, &
      contextflag=ESMF_CONTEXT_PARENT_VM, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Creating a Gridded Component"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    comp2name = "Ocean"
    comp2 = ESMF_GridCompCreate(name=comp2name, &
      contextflag=ESMF_CONTEXT_PARENT_VM, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Creating a Gridded Component"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    statename = "Ocn2Atm"
    state1 = ESMF_StateCreate(name=statename, rc=rc)  
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Creating a State"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)


    ! In SetServices() the VM for each component is initialized.
    ! Normally you would call SetEntryPoint inside set services,
    ! but to make this test very short, they are called inline below.

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompSetServices(comp1, userRoutine=comp_dummy, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompSetServices"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompSetServices(comp2, userRoutine=comp_dummy, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompSetServices"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompSetEntryPoint(comp1, ESMF_METHOD_INITIALIZE, &
      userRoutine=comp1_init, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompSetEntryPoint"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompSetEntryPoint(comp2, ESMF_METHOD_INITIALIZE, &
      userRoutine=comp2_init, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompSetEntryPoint"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompSetEntryPoint(comp1, ESMF_METHOD_FINALIZE, &
      userRoutine=comp1_final, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompSetEntryPoint"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompSetEntryPoint(comp2, ESMF_METHOD_FINALIZE, &
      userRoutine=comp2_final, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompSetEntryPoint"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompInitialize(comp1, importState=state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompInitialize"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompInitialize(comp2, importState=state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompInitialize"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_StateValidate(state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling StateValidate"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_StateReconcile(state1, vm=vm, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling StateReconcile in run-in-parent mode"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_StateValidate(state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling StateValidate"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    ! Test redundant reconcile
    call ESMF_StateReconcile(state1, vm=vm, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling 2nd StateReconcile in run-in-parent mode"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_StateValidate(state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling StateValidate on 2nd StateReconcile"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompFinalize(comp1, importState=state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompFinalize"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompFinalize(comp2, importState=state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompFinalize"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompDestroy(comp1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompDestroy"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_GridCompDestroy(comp2, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling GridCompDestroy"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)
  
    !-------------------------------------------------------------------------
    !NEX_UTest_Multi_Proc_Only
    call ESMF_StateDestroy(state1, rc=rc)
    write(failMsg, *) "Did not return ESMF_SUCCESS"
    write(name, *) "Calling StateDestroy"
    call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)


!-------------------------------------------------------------------------
10  continue

    call ESMF_TestEnd(result, ESMF_SRCLINE) ! calls ESMF_Finalize()

end program ESMF_StateReconcileUTest
