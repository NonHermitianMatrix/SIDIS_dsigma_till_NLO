      PROGRAM HQQPRIME_CHECK
      IMPLICIT NONE
      INCLUDE 'coupl.inc'
      REAL*8 P(0:3,5), EPS(0:3), ANS, QMODEL(2), QTEST(2)
      COMPLEX*16 QEDBASE
      INTEGER I,J,K,POINT,NPOINTS
      LOGICAL HELRESET
      COMMON/HQQPRIME_INPUT_CURRENT/EPS
      COMMON/HELRESET/HELRESET
      CALL SETPARA('standalone/Cards/param_card.dat')
      OPEN(11,FILE='s03_momenta.dat',STATUS='OLD')
      READ(11,*) NPOINTS
      READ(11,*) QMODEL
      QEDBASE=GC_2/QMODEL(1)
      IF(ABS(QEDBASE-GC_1/QMODEL(2)).GT.
     $ 1D-12*ABS(QEDBASE)) STOP 1
      WRITE(*,'(A,3(1X,ES25.16))') 'COUPLINGS',
     $ DBLE(QEDBASE*DCONJG(QEDBASE))*G**4,G,ABS(QEDBASE)
      DO POINT=1,NPOINTS
        DO J=1,5
          READ(11,*) (P(I,J),I=0,3)
        ENDDO
        READ(11,*) QTEST
        GC_2=QEDBASE*QTEST(1)
        GC_1=QEDBASE*QTEST(2)
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

      SUBROUTINE HQQPRIME_CURRENT(W)
      IMPLICIT NONE
      COMPLEX*16 W(*)
      REAL*8 EPS(0:3)
      INTEGER I
      COMMON/HQQPRIME_INPUT_CURRENT/EPS
C     Preserve the HELAS momentum entries; replace polarization only.
      DO I=0,3
        W(I+3)=DCMPLX(EPS(I),0D0)
      ENDDO
      END
