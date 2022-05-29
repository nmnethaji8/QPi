MODULE FUNC
   CONTAINS
   SUBROUTINE get_energy(lattice,N)
      IMPLICIT NONE
      INTEGER(KIND=4),INTENT(IN)::N
      INTEGER(KIND=4),INTENT(IN)::lattice(N,N)
   END SUBROUTINE get_energy
END MODULE FUNC

PROGRAM MAIN
   USE CUDAFOR
   USE FUNC
   IMPLICIT NONE
   INTEGER(KIND=4), PARAMETER::N=5
   INTEGER(KIND=4),DIMENSION(N, N),MANAGED::lattice_n,lattice_p

   lattice_n=transpose(reshape((/1, -1, -1, -1, -1,  1,  1, 1, -1, -1, 1, -1, -1, -1, -1,  1,  1, -1, -1, -1, -1, -1, -1,  1, -1/), shape(lattice_n)))
   lattice_p=transpose(reshape((/1,  1,  1,  1,  1, -1,  1, 1,  1,  1, 1,  1,  1,  1, -1, -1, -1, -1,  1,  1,  1,  1,  1,  1, -1/),shape(lattice_p)))

   CALL get_energy(lattice_p,N)
END PROGRAM MAIN
