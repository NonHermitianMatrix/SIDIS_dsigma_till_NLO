ccccccccccccccccccccccccccccccccccccccccc
c
c file: fragfun_all.f
c date: 26/2/2001 
c changed 21.5.2002 to add Kretzer FF's
c
c contains fragmentation functions called from ephox
c
c conventions: 3digit number, xyz
c 
c x = group label:
c
c              x = 1  :  bkk (binnewies/kniehl/kramer)         
c              x = 2  :  kkp (kniehl/kramer/poetter) 
c              x = 3  :  owens
c              x = 4  :  bourhis et al. (photon) 
c              x = 5  :  bourhis et al. (all charged)
c              x = 6  :  kretzer
c
c y = hadron label:             
c
c     y   = 0 : gamma
c     y   = 1 : (pi^+ + pi^-)  /2
c     y   = 2 : (k^+ + k^-)    /2   
c     y   = 3 : (k^0 + k^0_bar)/2   
c     y   = 4 : (p + p_bar)    /2
c     y   = 5 : (pi^0)
c     y   = 6 : (n + n_bar)    /2
c     y   = 7 : (h^+ + h^-) 
c
c
c 
c
c z = iset: 
c
c      iset = 0 :  lo
c      iset = 1 : nlo for bkk and kkp, nlo set for Bourhis et al.
c      iset = 2 : further sets      
c
cccccccccccccccccccccccccccccccccccccccc
	subroutine dfrag(x,m2,ih,d)
	implicit real*8 (a-h,l-z)
	common/fragflag/iflag
        common/alfa/masch2,masbo2,masto2,lambda4square
	common/alem/iloopem
	dimension uff(2), dff(2), sff(2), cff(2), bff(2)
	dimension d(-6:6),dh(0:10)
c 
	call extract_udc(ih,iunite,idizaine,icentaine)
c parton labels in d array:
c	
c       1=d   2=u   3=s   4=c   5=b   6=t 
c  0=g -1=db -2=ub -3=sb -4=cb -5=bb -6=tb
c
	if (x.ge.1.d0) then
	  d(0)=0.d0
	  do i=1,6
	    d(i)=0.d0
	    d(-i)=0.d0
	  enddo
	  return
	endif
	if (icentaine.eq.1) then
	  if (idizaine.gt.7) then
	    write (*,*) 'the number which selects the hadron'
	    write (*,*) 'for bkk frag. functions is not implemented'
	    stop
	  endif 
	  if (iunite.gt.1) then
	    write (*,*) 'the number which selects LO/NLO'
	    write (*,*) 'for bkk frag. functions is not correct'
	    stop
	  endif 
c
c bkk
c	
	  if (m2.lt.2.d0) then
	    m2 = 2.d0
	  endif
	  qs = dsqrt(m2)
	  call bkk(idizaine,iunite,x,qs,dh)
	  d(0)  = dh(0)
	  d(1)  = dh(3)
	  d(-1) = dh(4)
	  d(2)  = dh(1)
	  d(-2) = dh(2)
	  d(3)  = dh(5)
	  d(-3) = dh(6)
	  d(4)  = dh(7)
	  d(-4) = dh(8)
	  d(5)  = dh(9)
	  d(-5) = dh(10)
	  d(6)  = 0.d0
	  d(-6) = 0.d0  
	else if (icentaine.eq.2) then
c
c kkp
c	
	  if (idizaine.gt.7) then
	    write (*,*) 'the number which selects the hadron'
	    write (*,*) 'for kkp frag. functions is not implemented'
	    stop
	  endif 
	  if (iunite.gt.1) then
	    write (*,*) 'the number which selects LO/NLO'
	    write (*,*) 'for kkp frag. functions is not correct'
	    stop
	  endif 
	  if (m2.lt.2.d0) then
	    m2 = 2.d0
	  endif
	  qs = dsqrt(m2)
	  call kkp(idizaine,iunite,x,qs,dh)
	  d(0)  = dh(0)
	  d(1)  = dh(3)
	  d(-1) = dh(4)
	  d(2)  = dh(1)
	  d(-2) = dh(2)
	  d(3)  = dh(5)
	  d(-3) = dh(6)
	  d(4)  = dh(7)
	  d(-4) = dh(8)
	  d(5)  = dh(9)
	  d(-5) = dh(10)
	  d(6)  = 0.d0
	  d(-6) = 0.d0  
	else if (icentaine.eq.3) then
	  if (idizaine.ne.0) then
	    write (*,*) 'Owens Fragmentation function'
	    write (*,*) 'only for photon'
	    stop
	  endif 
	  if (iunite.ne.1) then
	    write (*,*) 'the number which selects LO/NLO'
	    write (*,*) 'for Owens frag. functions is not correct'
	    stop
	  endif 
c
c parametrisation a la owens, photon, nlo
c
	  pi = 4.d0*datan(1.d0)
	  alpha_em = alphaem(iloopem,m2)
	  alphas2pi = alpha_em/(2.d0*pi)
	  d(1)=anom(x,1)*dlog(m2/lambda4square)*alphas2pi
	  d(-1)=d(1)                         
	  d(2)=anom(x,2)*dlog(m2/lambda4square)*alphas2pi
	  d(-2)=d(2)                         
	  d(3)=anom(x,3)*dlog(m2/lambda4square)*alphas2pi
	  d(-3)=d(3)                         
	  d(4)=anom(x,4)*dlog(m2/masch2)*alphas2pi
	  d(-4)=d(4)                         
	  d(5)=anom(x,5)*dlog(m2/masbo2)*alphas2pi
	  d(-5)=d(5)                         
	  d(6)=anom(x,6)*dlog(m2/masto2)*alphas2pi
	  d(-6)=d(6)                         
	  d(0)=anogl(x)*dlog(m2/lambda4square)*alphas2pi	  
	else if (icentaine.eq.4) then
c	
c parametrisation bourhis et al., photon, nlo
c
	  if (idizaine.ne.0) then
	    write (*,*) 'Bourhis Fragmentation function'
	    write (*,*) 'only for photon'
	    stop
	  endif 
	  if (iunite.eq.0) then
	    write (*,*) 'No LO for Bourhis frag. functions'
	    stop
	  else if (iunite.gt.2) then
	    write (*,*) 'the number which selects the set'
	    write (*,*) 'for Bourhis frag. functions is not correct'
	    stop
	  endif 
	  call fonfra(x,iunite,m2,xdup,xdubp,xddp,xddbp,xdsp,xdcp,xdbp
     # ,xdbbp,xdtp,xdtbp,xdgp)
	  d(0) = xdgp/x
	  d(1) = xddp/x
	  d(-1) = xddbp/x
	  d(2) = xdup/x
	  d(-2) = xdubp/x
	  d(3) = xdsp/x
	  d(-3) = d(3)
	  d(4) = xdcp/x
	  d(-4) = d(4)
	  d(5) = xdbp/x
	  d(-5) = xdbbp/x
	  d(6) = xdtp/x
	  d(-6) = xdtbp/x
	else  if (icentaine.eq.5) then
c	
c parametrisation bourhis et al., all charged, nlo
c
	  if (idizaine.ne.7) then
	    write (*,*) 'Bourhis Fragmentation function'
	    write (*,*) 'only for all charged'
	    stop
	  endif 
	  if (iunite.eq.0) then
	    write (*,*) 'No LO for Bourhis frag. functions'
	    stop
	  else if (iunite.gt.3) then
	    write (*,*) 'the number which selects the set'
	    write (*,*) 'for Bourhis frag. functions is not correct'
	    stop
	  endif 
	  call fonfrac(x,iunite,m2,xdup,xdubp,xddp,xddbp,xdsp,xdcp,xdbp
     # ,xdbbp,xdgp)
	  d(0) = xdgp/x
	  d(1) = xddp/x
	  d(-1) = xddbp/x
	  d(2) = xdup/x
	  d(-2) = xdubp/x
	  d(3) = xdsp/x
	  d(-3) = d(3)
	  d(4) = xdcp/x
	  d(-4) = d(4)
	  d(5) = xdbp/x
	  d(-5) = xdbbp/x
	  d(6) = 0.d0
	  d(-6) = 0.d0
	  else  if (icentaine.eq.6) then
	    if (iunite.gt.1) then
	    write (*,*) 'the number which selects LO/NLO'
	    write (*,*) 'for Kretzer frag. functions is not correct'
	    stop
	    endif
c	
c kretzer FF's h+ + h-, only h+ or only h- not implemented
c
	   icharge=3
	   if (idizaine.eq.7) then  ! h^+ + h^-
	     if (iunite.eq.1) then
	       iset=6
	       call PKHFF(ISET,ICHARGE,X,m2,uff,dff,sff,cff,bff,gff)
	     else if (iunite.eq.0) then 
	       iset=5
	       call PKHFF(ISET,ICHARGE,X,m2,uff,dff,sff,cff,bff,gff)	     
	     endif
	  d(0)  = gff
	  d(1)  = dff(1)
	  d(-1) = dff(2)
	  d(2)  = uff(1)
	  d(-2) = uff(2)
	  d(3)  = sff(1)
	  d(-3) = sff(2)
	  d(4)  = cff(1)
	  d(-4) = cff(2)
	  d(5)  = bff(1)
	  d(-5) = bff(2)
	  d(6)  = 0.d0
	  d(-6) = 0.d0      
	   else if (idizaine.eq.2) then  ! (K+ + K-)/2
	     if (iunite.eq.1) then
	       iset=4
	       call PKHFF(ISET,ICHARGE,X,m2,uff,dff,sff,cff,bff,gff)
	     else if (iunite.eq.0) then 
	       iset=3
	       call PKHFF(ISET,ICHARGE,X,m2,uff,dff,sff,cff,bff,gff)	     
	     endif
	   d(0)  = gff/2.d0
	   d(1)  = dff(1)/2.d0
	   d(-1) = dff(2)/2.d0
	   d(2)  = uff(1)/2.d0
	   d(-2) = uff(2)/2.d0
	   d(3)  = sff(1)/2.d0
	   d(-3) = sff(2)/2.d0
	   d(4)  = cff(1)/2.d0
	   d(-4) = cff(2)/2.d0
	   d(5)  = bff(1)/2.d0
	   d(-5) = bff(2)/2.d0
	   d(6)  = 0.d0
	   d(-6) = 0.d0  
	   else if (idizaine.eq.1) then  ! (pi^+ + pi^-)/2
	     if (iunite.eq.1) then
	       iset=2
	       call PKHFF(ISET,ICHARGE,X,m2,uff,dff,sff,cff,bff,gff)
	     else if (iunite.eq.0) then 
	       iset=1
	       call PKHFF(ISET,ICHARGE,X,m2,uff,dff,sff,cff,bff,gff)	     
	     endif
	   d(0)  = gff/2.d0
	   d(1)  = dff(1)/2.d0
	   d(-1) = dff(2)/2.d0
	   d(2)  = uff(1)/2.d0
	   d(-2) = uff(2)/2.d0
	   d(3)  = sff(1)/2.d0
	   d(-3) = sff(2)/2.d0
	   d(4)  = cff(1)/2.d0
	   d(-4) = cff(2)/2.d0
	   d(5)  = bff(1)/2.d0
	   d(-5) = bff(2)/2.d0
	   d(6)  = 0.d0
	   d(-6) = 0.d0 
	   else 
	    write (*,*) 'the number which selects the hadron type'
	    write (*,*) 'for Kretzer frag. functions is not implemented'
	    stop 
   	  endif    
	endif 
	return
	end
c
c
c
	double precision function anom(x,i)
	implicit real*8 (a-h,l-z)
	common/charge/q(6)
	common/anomal/ianom
	if (ianom.eq.0) then
	  anom=q(i)**2 * (1.+(1.-x)**2)/x
	else
	  anom=q(i)**2 *
     #    (2.21-1.28*x+1.29*x**2)*x**(.049)/(1.-1.63*dlog(1.-x))/x
     #    +0.0020*(1.-x)**2 / x**2.54
	endif
	return
	end
c
c
	double precision function anogl(x)
	implicit real*8 (a-h,l-z)
	common/anomal/ianom
	if (ianom.eq.0) then
	  anogl=0.
	else
	  anogl=0.0243*(1.-x) / x**1.97
	endif
	return
	end
c
	block data photon
	implicit real*8 (a-h,l-z)
	common/charge/q(6)
	common/anomal/ianom
	data q/-0.33333,0.66667,-0.33333,0.66667,-0.33333,0.66667/
	data ianom/1/
	end
c
	subroutine extract_udc(inumb,iunite,idizaine,icentaine)
	implicit real*8(a-h,l-z)
c extract unite
	itemp1 = int(dfloat(inumb)/10.d0)
	iunite = inumb-itemp1*10
c extract dizaine
	itemp2 = int(dfloat(itemp1)/10.d0)
	idizaine = itemp1-itemp2*10
c extract centaine
	itemp3 = int(dfloat(itemp2)/10.d0)
	icentaine = itemp2-itemp3*10
	return
	end
