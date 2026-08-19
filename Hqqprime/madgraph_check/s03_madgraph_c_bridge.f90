module hqqprime_madgraph_c_bridge
  use, intrinsic :: iso_c_binding
  implicit none

contains

  subroutine hqqprime_mg_init(c_path) bind(C, name="hqqprime_mg_init")
    character(kind=c_char), intent(in) :: c_path(*)
    character(len=512) :: fortran_path
    integer :: index
    logical :: found_terminator

    fortran_path = " "
    found_terminator = .false.
    do index = 1, len(fortran_path)
      if (c_path(index) == c_null_char) then
        found_terminator = .true.
        exit
      end if
      fortran_path(index:index) = c_path(index)
    end do

    if (.not. found_terminator) then
      error stop "HQQPRIME_MG_FATAL: parameter-card path exceeds 511 bytes"
    end if

    call setparamlog(.false.)
    call setpara(fortran_path)
  end subroutine hqqprime_mg_init

  subroutine hqqprime_mg_eval(momentum, alpha_s, answer) &
      bind(C, name="hqqprime_mg_eval")
    real(c_double), intent(in) :: momentum(4, 6)
    real(c_double), value, intent(in) :: alpha_s
    real(c_double), intent(out) :: answer
    integer(c_int) :: pdgs(6)
    integer(c_int) :: process_id
    integer(c_int) :: particle_count
    integer(c_int) :: helicity
    real(c_double) :: scale_squared

    pdgs = [11_c_int, 2_c_int, 11_c_int, 4_c_int, 2_c_int, -4_c_int]
    process_id = 1_c_int
    particle_count = 6_c_int
    helicity = -1_c_int
    scale_squared = 0.0_c_double
    answer = 0.0_c_double

    call f77_smatrixhel( &
      pdgs, process_id, particle_count, momentum, alpha_s, &
      scale_squared, helicity, answer &
    )
  end subroutine hqqprime_mg_eval

  subroutine hqqprime_mg_metadata(pdgs, identity_factor) &
      bind(C, name="hqqprime_mg_metadata")
    integer(c_int), intent(out) :: pdgs(6)
    integer(c_int), intent(out) :: identity_factor

    pdgs = [11_c_int, 2_c_int, 11_c_int, 4_c_int, 2_c_int, -4_c_int]
    identity_factor = 12_c_int
  end subroutine hqqprime_mg_metadata

end module hqqprime_madgraph_c_bridge
