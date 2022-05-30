#FC=/opt/nvidia/hpc_sdk/Linux_x86_64/2022/compilers/bin/nvfortran
#flags=-Mcuda -acc

#IsingFort:IsingFort.o
#$(FC) $(flags) -c++libs -o IsingFort.o

#IsingFort:IsingFort.f95 
#	$(FC) $(flags) IsingFort.f95 -o IsingFort

#cleanAll:
#	rm -rf IsingFort *.o *.mod
nv=/opt/nvidia/hpc_sdk/Linux_x86_64/2022/compilers/bin/nvcc
flags=
#Ising:Ising.cu
#	$(nv) $(flags) Ising.cu -o Ising

#cleanAll:
#	rm -rf IsingFort *.o *.mod Ising

GraphsWithIsing:GraphsWithIsing.cu
	$(nv) $(flags) GraphsWithIsing.cu -o GraphsWithIsing

cleanAll:
	rm -rf IsingFort *.o *.mod Ising GraphsWithIsing