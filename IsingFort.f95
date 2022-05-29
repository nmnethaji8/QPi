MODULE FUNC
   CONTAINS
   SUBROUTINE get_energy(lattice,N,GlobalEnergy)
      IMPLICIT NONE
      INTEGER(KIND=4),INTENT(IN)::N
      INTEGER(KIND=4),INTENT(IN)::lattice(N,N)

      REAL(KIND=8),INTENT(OUT)::GlobalEnergy
      REAL(KIND=8)::Energy=0
      INTEGER(KIND=4)::I,J

      GlobalEnergy=0
      DO I=1,N 
         DO J=1,N 
            IF((I.NE.1).AND.(I.NE.N).AND.(J.NE.1).AND.(J.NE.N)) Energy=lattice(J,I+1)+lattice(J+1,I)+lattice(J,I-1)+lattice(J-1,I)!PRINT'(i2,i2,i2,i2)',lattice(J,I+1),lattice(J+1,I),lattice(J,I-1),lattice(J-1,I) !
            IF((I.EQ.1).AND.(I.NE.N).AND.(J.NE.1).AND.(J.NE.N)) Energy=lattice(J,I+1)+lattice(J+1,I)+lattice(J-1,I) !PRINT'(i2,i2,i2)',lattice(J,I+1),lattice(J+1,I),lattice(J-1,I)!
            IF((I.NE.1).AND.(I.EQ.N).AND.(J.NE.1).AND.(J.NE.N)) Energy=lattice(J+1,I)+lattice(J,I-1)+lattice(J-1,I) !PRINT'(i2,i2,i2)',lattice(J+1,I),lattice(J,I-1),lattice(J-1,I)!
            IF((I.NE.1).AND.(I.NE.N).AND.(J.EQ.1).AND.(J.NE.N)) Energy=lattice(J,I+1)+lattice(J+1,I)+lattice(J,I-1) !PRINT'(i2,i2,i2)',lattice(J,I+1),lattice(J+1,I),lattice(J,I-1)!
            IF((I.NE.1).AND.(I.NE.N).AND.(J.NE.1).AND.(J.EQ.N)) Energy=lattice(J,I+1)+lattice(J,I-1)+lattice(J-1,I) !PRINT'(i2,i2,i2)',lattice(J,I+1),lattice(J,I-1),lattice(J-1,I)!
            IF((I.EQ.1).AND.(J.EQ.1))Energy=lattice(J,I+1)+lattice(J+1,I) !PRINT'(i2,i2)',lattice(J,I+1),lattice(J+1,I) !
            IF((I.EQ.N).AND.(J.EQ.N))Energy=lattice(J,I-1)+lattice(J-1,I) !PRINT'(i2,i2)',lattice(J,I-1),lattice(J-1,I) !
            IF((I.EQ.1).AND.(J.EQ.N))Energy=lattice(J,I+1)+lattice(J-1,I) !PRINT'(i2,i2)',lattice(J,I+1),lattice(J-1,I) !
            IF((I.EQ.N).AND.(J.EQ.1))Energy=lattice(J+1,I)+lattice(J,I-1) !PRINT'(i2,i2)',lattice(J+1,I),lattice(J,I-1) !
            GlobalEnergy=GlobalEnergy+(-lattice(J,I)*Energy)
         ENDDO 
      ENDDO
   END SUBROUTINE get_energy

   SUBROUTINE metropolis(net_spins, net_energy, spin_arr,  N, times, BJ, energy)
      IMPLICIT NONE
      INTEGER(KIND=4),INTENT(IN)::N,times
      INTEGER(KIND=4),DIMENSION(times)::net_spins
      REAL(KIND=8),DIMENSION(times)::net_energy
      INTEGER(KIND=4),DIMENSION(N,N)::spin_arr
      REAL(KIND=8), INTENT(INOUT)::BJ, energy

      INTEGER(KIND=4)::I,T,x,y, spin_i, spin_f
      REAL(KIND=8)::u,E_i,E_f,dE

      DO T=1,times
         call random_number(u)
         x=1+FLOOR((N)*u)
         call random_number(u)
         y=1+FLOOR((N)*u)

         spin_i = spin_arr(y,x); !initial spin
         spin_f = -spin_i; !proposed spin flip

         E_i = 0
         E_f = 0

         IF(x.GT.1)THEN
            E_i =E_i-spin_i*spin_arr(y,x-1)
            E_f =E_i-spin_f*spin_arr(y,x-1)
         ENDIF
         IF(x.LT.N)THEN
            E_i =E_i-spin_i*spin_arr(y,x+1)
            E_f =E_f-spin_f*spin_arr(y,x+1)
         ENDIF
         IF(y.GT.1)THEN
            E_i =E_i-spin_i*spin_arr(y-1,x)
            E_f =E_f-spin_f*spin_arr(y-1,x)
         ENDIF
         IF(y.LT.N)THEN
            E_i =E_i-spin_i*spin_arr(y+1,x)
            E_f =E_f-spin_f*spin_arr(y+1,x)
         ENDIF

         dE = E_f-E_i
         call random_number(u)
         IF((dE.GT.0).AND.(u.LT.exp(-BJ*dE))) THEN
            spin_arr(y,x)=spin_f
            energy = energy+ dE
         ELSE IF( dE.LE.0 ) THEN
            spin_arr(y,x)=spin_f
            energy = energy+ dE
         ENDIF

         net_spins(T)=SUM(SUM(spin_arr,1),1)
         net_energy(T)= energy
      ENDDO
   END SUBROUTINE metropolis
END MODULE FUNC

PROGRAM MAIN
   USE CUDAFOR
   USE FUNC
   IMPLICIT NONE
   INTEGER(KIND=4), PARAMETER::N=5,times=100
   INTEGER(KIND=4),DIMENSION(N, N),MANAGED::lattice_n,lattice_p
   REAL(KIND=8)::Energy,BJ=0.7
   INTEGER(KIND=4),MANAGED,DIMENSION(times)::net_spins
   REAL(KIND=8),MANAGED,DIMENSION(times)::net_energy
   
   lattice_n=reshape((/1, -1, -1, -1, -1,  1,  1, 1, -1, -1, 1, -1, -1, -1, -1,  1,  1, -1, -1, -1, -1, -1, -1,  1, -1/),shape(lattice_n))
   lattice_p=reshape((/1,  1,  1,  1,  1, -1,  1, 1,  1,  1, 1,  1,  1,  1, -1, -1, -1, -1,  1,  1,  1,  1,  1,  1, -1/),shape(lattice_p))

   CALL get_energy(lattice_p,N,Energy)
   PRINT*,Energy
   CALL metropolis(net_spins, net_energy,lattice_n, N ,times, BJ, Energy)
END PROGRAM MAIN
