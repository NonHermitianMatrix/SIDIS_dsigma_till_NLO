program hqqprime_direct_madgraph_reference
  use, intrinsic :: iso_fortran_env, only : real64
  implicit none

  real(real64) :: momentum(0:3, 6)
  real(real64) :: matrix_element
  real(real64) :: root_three
  real(real64) :: outgoing_energy
  real(real64) :: momentum_residual(0:3)
  real(real64) :: mass_squared(6)
  character(len=512) :: parameter_card
  integer :: particle

  call get_command_argument(1, parameter_card)
  if (len_trim(parameter_card) == 0) then
    error stop "HQQPRIME_MG_FATAL: parameter-card argument is required"
  end if

  call setparamlog(.false.)
  call setpara(parameter_card)

  root_three = sqrt(3.0_real64)
  outgoing_energy = 250.0_real64
  momentum = 0.0_real64

  momentum(:, 1) = [500.0_real64, 0.0_real64, 0.0_real64, 500.0_real64]
  momentum(:, 2) = [500.0_real64, 0.0_real64, 0.0_real64, -500.0_real64]
  momentum(:, 3) = outgoing_energy * &
    [1.0_real64, 1.0_real64/root_three, &
     1.0_real64/root_three, 1.0_real64/root_three]
  momentum(:, 4) = outgoing_energy * &
    [1.0_real64, 1.0_real64/root_three, &
     -1.0_real64/root_three, -1.0_real64/root_three]
  momentum(:, 5) = outgoing_energy * &
    [1.0_real64, -1.0_real64/root_three, &
     1.0_real64/root_three, -1.0_real64/root_three]
  momentum(:, 6) = outgoing_energy * &
    [1.0_real64, -1.0_real64/root_three, &
     -1.0_real64/root_three, 1.0_real64/root_three]

  momentum_residual = momentum(:, 1) + momentum(:, 2) - &
    sum(momentum(:, 3:6), dim=2)
  do particle = 1, 6
    mass_squared(particle) = momentum(0, particle)**2 - &
      sum(momentum(1:3, particle)**2)
  end do

  call m0_smatrix(momentum, matrix_element)

  write(*, '(A,ES26.17E3)') "HQQPRIME_DIRECT_MATRIX=", matrix_element
  write(*, '(A,ES26.17E3)') "HQQPRIME_DIRECT_MAX_CONSERVATION=", &
    maxval(abs(momentum_residual))
  write(*, '(A,ES26.17E3)') "HQQPRIME_DIRECT_MAX_MASS2=", &
    maxval(abs(mass_squared))
end program hqqprime_direct_madgraph_reference
