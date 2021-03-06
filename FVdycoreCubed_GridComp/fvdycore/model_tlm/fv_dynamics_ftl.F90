!                           DISCLAIMER
!
!   This file was generated by TAF version 1.9.22
!
!   FASTOPT DISCLAIMS  ALL  WARRANTIES,  EXPRESS  OR  IMPLIED,
!   INCLUDING (WITHOUT LIMITATION) ALL IMPLIED  WARRANTIES  OF
!   MERCHANTABILITY  OR FITNESS FOR A PARTICULAR PURPOSE, WITH
!   RESPECT TO THE SOFTWARE AND USER PROGRAMS.   IN  NO  EVENT
!   SHALL  FASTOPT BE LIABLE FOR ANY LOST OR ANTICIPATED PROF-
!   ITS, OR ANY INDIRECT, INCIDENTAL, EXEMPLARY,  SPECIAL,  OR
!   CONSEQUENTIAL  DAMAGES, WHETHER OR NOT FASTOPT WAS ADVISED
!   OF THE POSSIBILITY OF SUCH DAMAGES.
!
!                           Haftungsbeschraenkung
!   FastOpt gibt ausdruecklich keine Gewaehr, explizit oder indirekt,
!   bezueglich der Brauchbarkeit  der Software  fuer einen bestimmten
!   Zweck.   Unter  keinen  Umstaenden   ist  FastOpt   haftbar  fuer
!   irgendeinen Verlust oder nicht eintretenden erwarteten Gewinn und
!   allen indirekten,  zufaelligen,  exemplarischen  oder  speziellen
!   Schaeden  oder  Folgeschaeden  unabhaengig  von einer eventuellen
!   Mitteilung darueber an FastOpt.
!
module     g_fv_dynamics_mod
!******************************************************************
!******************************************************************
!** This routine was generated by Automatic differentiation.     **
!** FastOpt: Transformation of Algorithm in Fortran, TAF 1.9.22  **
!******************************************************************
!******************************************************************
!==============================================
! referencing used modules
!==============================================
use constants_mod, only : grav,hlv,pi,radius
use dyn_core_mod, only : dyn_core
use mapz_module, only : compute_total_energy, lagrangian_to_eulerian
use tracer_2d_mod, only : tracer_2d, tracer_2d_1l
use fv_pack_mod, only : full_phys,hord_mt,hord_tm,hord_tr,hord_vt,k_top,kord_mt,kord_tm,kord_tr,nf_omega,p_ref,remap_t,rf_center,&
&tau,uniform_ppm,z_tracer
use grid_utils, only : da_min,ne_corner,nw_corner,ptop,se_corner,sina_u,sina_v,sw_corner,cubed_to_latlon, g_sum
use grid_tools, only : area,dx,dxa,dy,dya,rarea,rdxc,rdyc
use mp_mod, only : gid,ie,ied,is,isd,je,jed,js,jsd
use timingmodule, only : timing_off, timing_on
use diag_manager_mod, only : send_data
use fv_diagnostics_mod, only : fv_time,id_divg,id_te
use fv_dynamics_mod

!==============================================
! all entries are defined explicitly
!==============================================
implicit none

contains
subroutine g_fv_dynamics( npx, npy, npz, nq, ng, bdt, consv_te, fill, reproduce_sum, kappa, cp_air, zvir, ks, ncnst, n_split, &
&q_split, u, g_u, v, g_v, w, g_w, delz, g_delz, hydrostatic, pt, g_pt, delp, g_delp, q, g_q, ps, pe, g_pe, pk, g_pk, peln, pkz, &
&g_pkz, phis, omga, g_omga, ua, g_ua, va, g_va, uc, vc, ak, bk, mfx, g_mfx, mfy, g_mfy, cx, g_cx, cy, g_cy, u_srf, v_srf, srf_init,&
& ze0, g_ze0, hybrid_z, time_total )
!******************************************************************
!******************************************************************
!** This routine was generated by Automatic differentiation.     **
!** FastOpt: Transformation of Algorithm in Fortran, TAF 1.9.22  **
!******************************************************************
!******************************************************************
!==============================================
! referencing used modules
!==============================================
use g_mapz_module, only : g_compute_total_energy, g_lagrangian_to_eulerian
use g_tracer_2d_mod, only : g_tracer_2d, g_tracer_2d_1l
use g_dyn_core_mod, only : g_dyn_core

!==============================================
! all entries are defined explicitly
!==============================================
implicit none

!==============================================
! declare arguments
!==============================================
integer, intent(in) :: npz
real, intent(in) :: ak(npz+1)
real, intent(in) :: bdt
real, intent(in) :: bk(npz+1)
real, intent(in) :: consv_te
real, intent(in) :: cp_air
real, intent(inout) :: cx(is:ie+1,jsd:jed,npz)
real, intent(inout) :: cy(isd:ied,js:je+1,npz)
real, intent(inout) :: delp(isd:ied,jsd:jed,npz)
real, intent(inout) :: delz(is:ie,js:je,npz)
logical, intent(in) :: fill
real, intent(inout) :: g_cx(is:ie+1,jsd:jed,npz)
real, intent(inout) :: g_cy(isd:ied,js:je+1,npz)
real, intent(inout) :: g_delp(isd:ied,jsd:jed,npz)
real, intent(inout) :: g_delz(is:ie,js:je,npz)
real, intent(inout) :: g_mfx(is:ie+1,js:je,npz)
real, intent(inout) :: g_mfy(is:ie,js:je+1,npz)
real, intent(inout) :: g_omga(isd:ied,jsd:jed,npz)
real, intent(inout) :: g_pe(is-1:ie+1,npz+1,js-1:je+1)
real, intent(inout) :: g_pk(is:ie,js:je,npz+1)
real, intent(inout) :: g_pkz(is:ie,js:je,npz)
real, intent(inout) :: g_pt(isd:ied,jsd:jed,npz)
integer, intent(in) :: ncnst
real, intent(inout) :: g_q(isd:ied,jsd:jed,npz,ncnst)
real, intent(inout) :: g_u(isd:ied,jsd:jed+1,npz)
real, intent(inout) :: g_ua(isd:ied,jsd:jed,npz)
real, intent(inout) :: g_v(isd:ied+1,jsd:jed,npz)
real, intent(inout) :: g_va(isd:ied,jsd:jed,npz)
real, intent(inout) :: g_w(isd:ied,jsd:jed,npz)
real, intent(inout) :: g_ze0(is:ie,js:je,npz+1)
logical, intent(in) :: hybrid_z
logical, intent(in) :: hydrostatic
real, intent(in) :: kappa
integer, intent(in) :: ks
real, intent(inout) :: mfx(is:ie+1,js:je,npz)
real, intent(inout) :: mfy(is:ie,js:je+1,npz)
integer, intent(in) :: n_split
integer, intent(in) :: ng
integer, intent(in) :: npx
integer, intent(in) :: npy
integer, intent(in) :: nq
real, intent(inout) :: omga(isd:ied,jsd:jed,npz)
real, intent(inout) :: pe(is-1:ie+1,npz+1,js-1:je+1)
real, intent(inout) :: peln(is:ie,npz+1,js:je)
real, intent(inout) :: phis(isd:ied,jsd:jed)
real, intent(inout) :: pk(is:ie,js:je,npz+1)
real, intent(inout) :: pkz(is:ie,js:je,npz)
real, intent(inout) :: ps(isd:ied,jsd:jed)
real, intent(inout) :: pt(isd:ied,jsd:jed,npz)
real, intent(inout) :: q(isd:ied,jsd:jed,npz,ncnst)
integer, intent(in) :: q_split
logical, intent(in) :: reproduce_sum
logical, intent(inout) :: srf_init
real,optional, intent(in) :: time_total
real, intent(inout) :: u(isd:ied,jsd:jed+1,npz)
real, intent(out) :: u_srf(is:ie,js:je)
real, intent(inout) :: ua(isd:ied,jsd:jed,npz)
real, intent(inout) :: uc(isd:ied+1,jsd:jed,npz)
real, intent(inout) :: v(isd:ied+1,jsd:jed,npz)
real, intent(out) :: v_srf(is:ie,js:je)
real, intent(inout) :: va(isd:ied,jsd:jed,npz)
real, intent(inout) :: vc(isd:ied,jsd:jed+1,npz)
real, intent(inout) :: w(isd:ied,jsd:jed,npz)
real, intent(inout) :: ze0(is:ie,js:je,npz+1)
real, intent(in) :: zvir

!==============================================
! declare local variables
!==============================================
real :: akap
real :: dp1(is:ie,js:je,1:npz)
real :: g_dp1(is:ie,js:je,1:npz)
real :: g_pelnh(is:ie,npz+1,js:je)
real :: g_pem(is-1:ie+1,1:npz+1,js-1:je+1)
real :: g_q2(isd:ied,jsd:jed,nq)
real :: g_uch(isd:ied+1,jsd:jed,npz)
real :: g_vch(isd:ied,jsd:jed+1,npz)
integer :: i
integer :: iq
integer :: j
integer :: k
real :: pem(is-1:ie+1,1:npz+1,js-1:je+1)
real :: pfull(npz)
real :: ph1
real :: ph2
real :: q2(isd:ied,jsd:jed,nq)
real :: rg
real :: te_2d(is:ie,js:je)
real :: teq(is:ie,js:je)
logical :: used

!----------------------------------------------
! TANGENT LINEAR AND FUNCTION STATEMENTS
!----------------------------------------------
akap = kappa
rg = kappa*cp_air
do k = 1, npz
  ph1 = ak(k)+bk(k)*p_ref
  ph2 = ak(k+1)+bk(k+1)*p_ref
  pfull(k) = (ph2-ph1)/log(ph2/ph1)
end do
if (consv_te .gt. 0.) then
  call g_compute_total_energy( is,ie,js,je,isd,ied,jsd,jed,npz,u,g_u,v,g_v,pt,delp,q,pe,peln,phis,zvir,cp_air,rg,hlv,te_2d,ua,g_ua,&
&va,g_va,teq,full_phys,id_te )
endif
if (tau .gt. 0.) then
  call g_rayleigh_friction( bdt,npz,ks,pfull,tau,rf_center,u,g_u,v,g_v,w,pt,g_pt,ua,g_ua,va,g_va,cp_air,rg,hydrostatic, .true.  )
endif
do k = 1, npz
  do j = js, je
    do i = is, ie
      g_pt(i,j,k) = (-(g_pkz(i,j,k)*cp_air*pt(i,j,k)/(pkz(i,j,k)*pkz(i,j,k))*(1.+zvir*q(i,j,k,1))))+g_pt(i,j,k)*cp_air/pkz(i,j,k)*&
&(1.+zvir*q(i,j,k,1))+g_q(i,j,k,1)*cp_air*pt(i,j,k)/pkz(i,j,k)*zvir
      pt(i,j,k) = cp_air*pt(i,j,k)/pkz(i,j,k)*(1.+zvir*q(i,j,k,1))
    end do
  end do
end do
do k = 1, npz
  do j = js, je
    do i = is, ie
      g_dp1(i,j,k) = g_delp(i,j,k)
      dp1(i,j,k) = delp(i,j,k)
    end do
  end do
end do
g_uch = 0.
g_vch = 0.
call g_dyn_core( npx,npy,npz,ng,bdt,n_split,cp_air,akap,grav,hydrostatic,u,g_u,v,g_v,w,g_w,delz,pt,g_pt,delp,g_delp,pe,g_pe,pk,&
&g_pk,phis,omga,g_omga,ptop,pfull,ua,g_ua,va,g_va,uc,g_uch,vc,g_vch,mfx,g_mfx,mfy,g_mfy,cx,g_cx,cy,g_cy,pem,g_pem,pkz,uniform_ppm,&
&time_total )
if (nq .ne. 0) then
  if (z_tracer) then
    do k = 1, npz
      do iq = 1, nq
        do j = js, je
          do i = is, ie
            g_q2(i,j,iq) = g_q(i,j,k,iq)
            q2(i,j,iq) = q(i,j,k,iq)
          end do
        end do
      end do
      call g_tracer_2d_1l( q2,g_q2,dp1(is,js,k),g_dp1(is,js,k),mfx(is,js,k),g_mfx(is,js,k),mfy(is,js,k),g_mfy(is,js,k),cx(is,jsd,k)&
&,g_cx(is,jsd,k),cy(isd,js,k),g_cy(isd,js,k),npx,npy,npz,nq,hord_tr,q_split,k,q,g_q,bdt,uniform_ppm,id_divg )
    end do
  else
    call g_tracer_2d( q,dp1,g_dp1,mfx,g_mfx,mfy,g_mfy,cx,cy,npx,npy,npz,nq,hord_tr,q_split,bdt,uniform_ppm,id_divg )
  endif
  if (id_divg .gt. 0) then
    used = send_data(id_divg,dp1,fv_time)
  endif
endif
if (npz .gt. 4) then
  g_pelnh = 0.
  call g_lagrangian_to_eulerian( consv_te,ps,pe,g_pe,delp,g_delp,pkz,g_pkz,pk,g_pk,bdt,npz,is,ie,js,je,isd,ied,jsd,jed,nq,u,g_u,v,&
&g_v,w,delz,g_delz,pt,g_pt,q,g_q,phis,grav,zvir,cp_air,akap,kord_mt,kord_tr,kord_tm,peln,g_pelnh,te_2d,ng,ua,g_ua,va,g_va,omga,&
&g_omga,dp1,g_dp1,pem,fill,reproduce_sum,ak,bk,ks,ze0,g_ze0,remap_t,hydrostatic,hybrid_z,k_top,ncnst )
endif

end subroutine g_fv_dynamics


subroutine g_rayleigh_friction( dt, npz, ks, pm, tau, p_c, u, g_u, v, g_v, w, pt, g_pt, ua, g_ua, va, g_va, cp, rg, hydrostatic, &
&conserve )
!******************************************************************
!******************************************************************
!** This routine was generated by Automatic differentiation.     **
!** FastOpt: Transformation of Algorithm in Fortran, TAF 1.9.22  **
!******************************************************************
!******************************************************************
!==============================================
! referencing used modules
!==============================================
use grid_utils, only : g_cubed_to_latlon

!==============================================
! all entries are defined explicitly
!==============================================
implicit none

!==============================================
! declare parameters
!==============================================
real, parameter :: sday = 86400.
real, parameter :: wfac = 10.

!==============================================
! declare arguments
!==============================================
logical, intent(in) :: conserve
real, intent(in) :: cp
real, intent(in) :: dt
integer, intent(in) :: npz
real, intent(inout) :: g_pt(isd:ied,jsd:jed,npz)
real, intent(inout) :: g_u(isd:ied,jsd:jed+1,npz)
real, intent(inout) :: g_ua(isd:ied,jsd:jed,npz)
real, intent(inout) :: g_v(isd:ied+1,jsd:jed,npz)
real, intent(inout) :: g_va(isd:ied,jsd:jed,npz)
logical, intent(in) :: hydrostatic
integer, intent(in) :: ks
real, intent(in) :: p_c
real, intent(in) :: pm(npz)
real, intent(inout) :: pt(isd:ied,jsd:jed,npz)
real, intent(in) :: rg
real, intent(in) :: tau
real, intent(inout) :: u(isd:ied,jsd:jed+1,npz)
real, intent(inout) :: ua(isd:ied,jsd:jed,npz)
real, intent(inout) :: v(isd:ied+1,jsd:jed,npz)
real, intent(inout) :: va(isd:ied,jsd:jed,npz)
real, intent(inout) :: w(isd:ied,jsd:jed,npz)

!==============================================
! declare local variables
!==============================================
real :: c1
real :: fac
integer :: i
integer :: j
integer :: k
integer :: kmax
real :: pc
real :: rf(npz)
logical :: rf_initialized =  .false. 
real :: rw(npz)

!----------------------------------------------
! TANGENT LINEAR AND FUNCTION STATEMENTS
!----------------------------------------------
kmax = max(npz/3+1,ks)
if ( .not. rf_initialized) then
  if (p_c .le. 0.) then
    pc = pm(1)
  else
    pc = p_c
  endif
  c1 = 1./(tau*sday)
  do k = 1, kmax
    if (pm(k) .lt. 3000.) then
      rf(k) = c1*(1.+tanh(log10(pc/pm(k))))
      rf(k) = 1./(1.+dt*rf(k))
      rw(k) = 1./(1.+dt*rf(k)*wfac)
    endif
  end do
endif
if (conserve) then
  call g_cubed_to_latlon( u,g_u,v,g_v,ua,g_ua,va,g_va,dx,dy,dxa,dya,npz )
endif
do k = 1, kmax
  if (pm(k) .lt. 3000.) then
    if (conserve) then
      fac = 0.5*(1.-rf(k)**2)/(cp-rg*ptop/pm(k))
      do j = js, je
        do i = is, ie
          g_pt(i,j,k) = g_pt(i,j,k)+2*g_ua(i,j,k)*fac*ua(i,j,k)+2*g_va(i,j,k)*fac*va(i,j,k)
          pt(i,j,k) = pt(i,j,k)+fac*(ua(i,j,k)**2+va(i,j,k)**2)
        end do
      end do
    endif
    do j = js, je+1
      do i = is, ie
        g_u(i,j,k) = g_u(i,j,k)*rf(k)
        u(i,j,k) = u(i,j,k)*rf(k)
      end do
    end do
    do j = js, je
      do i = is, ie+1
        g_v(i,j,k) = g_v(i,j,k)*rf(k)
        v(i,j,k) = v(i,j,k)*rf(k)
      end do
    end do
    if ( .not. hydrostatic) then
      do j = js, je
        do i = is, ie
          w(i,j,k) = w(i,j,k)*rw(k)
        end do
      end do
    endif
  endif
end do

end subroutine g_rayleigh_friction


end module     g_fv_dynamics_mod


