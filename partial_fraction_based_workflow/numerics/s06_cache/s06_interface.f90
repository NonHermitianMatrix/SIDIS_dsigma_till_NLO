subroutine OpenData(filename)
  implicit none
  character(*) filename
  integer IU
  common /IU/ IU
  open(newunit=IU,file='/home/physics/projects/AI_Assisted_SIDIS/scripts/numerics/vendor/mrst2002/'//trim(filename),status='old',action='read')
end subroutine
subroutine sidis_pdf(x,q,output) bind(C)
  use iso_c_binding
  implicit none
  real(c_double),value :: x,q
  real(c_double) :: output(8),xx,qq
  integer mode
  xx=x
  qq=q
  mode=1
  call mrst2002(xx,qq,mode,output(1),output(2),output(3),output(4), &
                output(5),output(6),output(7),output(8))
end subroutine
subroutine sidis_kkp(z,q,ih,output) bind(C)
  use iso_c_binding
  implicit none
  real(c_double),value :: z,q
  integer(c_int),value :: ih
  real(c_double) :: output(0:10),zz,qq
  integer iset,hadron
  zz=z
  qq=q
  hadron=ih
  iset=1
  call kkp(hadron,iset,zz,qq,output)
end subroutine
subroutine sidis_kretzer(z,q2,charge,output) bind(C)
  use iso_c_binding
  implicit none
  real(c_double),value :: z,q2
  integer(c_int),value :: charge
  real(c_double) :: output(0:10),zz,qq2
  integer iset,icharge
  zz=z
  qq2=q2
  iset=2
  icharge=charge
  call pkhff(iset,icharge,zz,qq2,output(1:2),output(3:4), &
             output(5:6),output(7:8),output(9:10),output(0))
end subroutine
subroutine sidis_set_alpha(mc2,mb2,lambda2) bind(C)
  use iso_c_binding
  implicit none
  real(c_double),value :: mc2,mb2,lambda2
  real(c_double) :: masch2,masbo2,masto2,lambda4square
  common /alfa/ masch2,masbo2,masto2,lambda4square
  masch2=mc2
  masbo2=mb2
  masto2=huge(masto2)
  lambda4square=lambda2
end subroutine
function sidis_alpha(q2) result(a) bind(C)
  use iso_c_binding
  implicit none
  real(c_double),value :: q2
  real(c_double) :: a,alfas,qq2
  integer loops
  external alfas
  qq2=q2
  loops=2
  a=alfas(loops,qq2)
end function
