      PROGRAM HGG_CHECK
      IMPLICIT NONE
      INCLUDE 'coupl.inc'
      REAL*8 P(0:3,5), EPS(0:3), ANS
      INTEGER I,J,K,POINT,NPOINTS
      LOGICAL HELRESET
      COMMON/HGG_INPUT_CURRENT/EPS
      COMMON/HELRESET/HELRESET
      CALL SETPARA('standalone/Cards/param_card.dat')
      WRITE(*,'(A,3(1X,ES25.16))') 'COUPLINGS',
     $ DBLE(GC_2*DCONJG(GC_2))*G**4,G,ABS(GC_2)
      OPEN(11,FILE='s03_momenta.dat',STATUS='OLD')
      READ(11,*) NPOINTS
      DO POINT=1,NPOINTS
        DO J=1,5
          READ(11,*) (P(I,J),I=0,3)
        ENDDO
        DO K=0,5
          EPS=0D0
          IF(K.LE.3) EPS(K)=1D0
          IF(K.EQ.4) EPS=P(:,2)
          IF(K.EQ.5) EPS=P(:,1)
C         Evaluate every helicity for every supplied current.
          HELRESET=.TRUE.
          CALL SMATRIX(P,ANS)
          WRITE(*,'(A,2(1X,I3),1X,ES25.16)')
     $      'CURRENT',POINT,K,ANS
        ENDDO
      ENDDO
      CLOSE(11)
      END

      SUBROUTINE HGG_CURRENT(W)
      IMPLICIT NONE
      COMPLEX*16 W(*)
      REAL*8 EPS(0:3)
      INTEGER I
      COMMON/HGG_INPUT_CURRENT/EPS
C     Preserve the HELAS momentum entries; replace polarization only.
      DO I=0,3
        W(I+3)=DCMPLX(EPS(I),0D0)
      ENDDO
      END
