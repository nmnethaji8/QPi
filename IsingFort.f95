PROGRAM MAIN
   USE CUDAFOR
   INTEGER(KIND=4), PARAMETER::N=5
   INTEGER(KIND=4),DIMENSION(N, N),MANAGED::lattice_n,lattice_p

   lattice_n=transpose(reshape((/1, -1, -1, -1, -1,  1,  1, 1, -1, -1, 1, -1, -1, -1, -1,  1,  1, -1, -1, -1, -1, -1, -1,  1, -1/), shape(lattice_n)))
   lattice_p=transpose(reshape((/1,  1,  1,  1,  1, -1,  1, 1,  1,  1, 1,  1,  1,  1, -1, -1, -1, -1,  1,  1,  1,  1,  1,  1, -1/),shape(lattice_p)))
   PRINT*,lattice_p

END PROGRAM MAIN
