program hqg_direct_madgraph_reference
  use, intrinsic :: iso_fortran_env, only : real64
  implicit none

  integer, parameter :: point_count = 3
  real(real64) :: momentum(0:3, 6, point_count)
  real(real64) :: base_momentum(0:3, 6)
  real(real64) :: temporary_momentum(0:3)
  real(real64) :: matrix_element
  real(real64) :: root_three
  real(real64) :: outgoing_energy
  real(real64) :: momentum_residual(0:3)
  real(real64) :: mass_squared(6)
  real(real64) :: maximum_conservation
  real(real64) :: maximum_mass_squared
  character(len=512) :: parameter_card
  integer :: particle
  integer :: point

  call get_command_argument(1, parameter_card)
  if (len_trim(parameter_card) == 0) then
    error stop "HQG_MG_FATAL: parameter-card argument is required"
  end if

  call setparamlog(.false.)
  call setpara(parameter_card)

  root_three = sqrt(3.0_real64)
  outgoing_energy = 250.0_real64
  base_momentum = 0.0_real64

  base_momentum(:, 1) = [500.0_real64, 0.0_real64, 0.0_real64, 500.0_real64]
  base_momentum(:, 2) = [500.0_real64, 0.0_real64, 0.0_real64, -500.0_real64]
  base_momentum(:, 3) = outgoing_energy * &
    [1.0_real64, 1.0_real64/root_three, &
     1.0_real64/root_three, 1.0_real64/root_three]
  base_momentum(:, 4) = outgoing_energy * &
    [1.0_real64, 1.0_real64/root_three, &
     -1.0_real64/root_three, -1.0_real64/root_three]
  base_momentum(:, 5) = outgoing_energy * &
    [1.0_real64, -1.0_real64/root_three, &
     1.0_real64/root_three, -1.0_real64/root_three]
  base_momentum(:, 6) = outgoing_energy * &
    [1.0_real64, -1.0_real64/root_three, &
     -1.0_real64/root_three, 1.0_real64/root_three]

  momentum(:, :, 1) = base_momentum
  momentum(:, :, 2) = base_momentum
  temporary_momentum = momentum(:, 3, 2)
  momentum(:, 3, 2) = momentum(:, 5, 2)
  momentum(:, 5, 2) = temporary_momentum
  momentum(:, :, 3) = base_momentum
  temporary_momentum = momentum(:, 3, 3)
  momentum(:, 3, 3) = momentum(:, 4, 3)
  momentum(:, 4, 3) = temporary_momentum

  maximum_conservation = 0.0_real64
  maximum_mass_squared = 0.0_real64
  do point = 1, point_count
    momentum_residual = momentum(:, 1, point) + momentum(:, 2, point) - &
      sum(momentum(:, 3:6, point), dim=2)
    do particle = 1, 6
      mass_squared(particle) = momentum(0, particle, point)**2 - &
        sum(momentum(1:3, particle, point)**2)
    end do
    maximum_conservation = max(maximum_conservation, &
      maxval(abs(momentum_residual)))
    maximum_mass_squared = max(maximum_mass_squared, &
      maxval(abs(mass_squared)))
    call m0_smatrix(momentum(:, :, point), matrix_element)
    write(*, '(A,I0,A,ES26.17E3)') &
      "HQG_DIRECT_MATRIX_", point, "=", matrix_element
  end do

  write(*, '(A,ES26.17E3)') "HQG_DIRECT_MAX_CONSERVATION=", &
    maximum_conservation
  write(*, '(A,ES26.17E3)') "HQG_DIRECT_MAX_MASS2=", maximum_mass_squared
end program hqg_direct_madgraph_reference

