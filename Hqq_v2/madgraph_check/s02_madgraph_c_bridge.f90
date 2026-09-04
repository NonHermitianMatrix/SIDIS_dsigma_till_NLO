module hqq_v2_madgraph_c_bridge
  use, intrinsic :: iso_c_binding
  use, intrinsic :: ieee_arithmetic, only : ieee_is_nan
  implicit none

contains

  subroutine hqq_v2_mg_init(c_path, status) bind(C, name="hqq_v2_mg_init")
    character(kind=c_char), intent(in) :: c_path(*)
    integer(c_int), intent(out) :: status
    character(len=1024) :: fortran_path
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
      status = 1_c_int
      return
    end if

    call setparamlog(.false.)
    call setpara(fortran_path)
    status = 0_c_int
  end subroutine hqq_v2_mg_init

  subroutine hqq_v2_mg_eval(pdgs, process_id, momentum, alpha_s, answer, &
      status) bind(C, name="hqq_v2_mg_eval")
    integer(c_int), intent(in) :: pdgs(6)
    integer(c_int), value, intent(in) :: process_id
    real(c_double), intent(in) :: momentum(4, 6)
    real(c_double), value, intent(in) :: alpha_s
    real(c_double), intent(out) :: answer
    integer(c_int), intent(out) :: status
    integer(c_int) :: particle_count
    integer(c_int) :: helicity
    real(c_double) :: scale_squared

    if (process_id < 1_c_int .or. process_id > 3_c_int) then
      answer = 0.0_c_double
      status = 1_c_int
      return
    end if

    particle_count = size(pdgs, kind=c_int)
    helicity = -1_c_int
    scale_squared = 0.0_c_double
    answer = 0.0_c_double
    status = 0_c_int

    call f77_smatrixhel( &
      pdgs, process_id, particle_count, momentum, alpha_s, &
      scale_squared, helicity, answer &
    )

    if (ieee_is_nan(answer)) status = 2_c_int
  end subroutine hqq_v2_mg_eval

end module hqq_v2_madgraph_c_bridge
