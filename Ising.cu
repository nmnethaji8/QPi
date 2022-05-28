#include<iostream>

using namespace std;

double get_energy(int *lattice, int const N)
{
   double Energy=0,GlobalEnergy=0;
   for(int i=0; i<N; i++)
   {
      for(int j=0; j<N; j++)
      {
         if((i!=0)&&(i!=N-1)&&(j!=0)&&(j!=N-1))
         {
            Energy=lattice[(i+1)*N+j]+lattice[i*N+j+1]+lattice[(i-1)*N+j]+lattice[i*N+j-1];
         }
         if((i==0)&&(i!=N-1)&&(j!=0)&&(j!=N-1))
         {
            Energy=lattice[(i+1)*N+j]+lattice[i*N+j+1]+lattice[i*N+j-1];
         }
         if((i!=0)&&(i==N-1)&&(j!=0)&&(j!=N-1))
         {
            Energy=lattice[i*N+j+1]+lattice[(i-1)*N+j]+lattice[i*N+j-1];
         }
         if((i!=0)&&(i!=N-1)&&(j==0)&&(j!=N-1))
         {
            Energy=lattice[(i+1)*N+j]+lattice[i*N+j+1]+lattice[(i-1)*N+j];
         }
         if((i!=0)&&(i!=N-1)&&(j!=0)&&(j==N-1))
         {
            Energy=lattice[(i+1)*N+j]+lattice[(i-1)*N+j]+lattice[i*N+j-1];
         }
         if((i==0)&&(j==0))
         {
            Energy=lattice[(i+1)*N+j]+lattice[i*N+j+1];
         }
         if((i==N-1)&&(j==N-1))
         {
            Energy=lattice[(i-1)*N+j]+lattice[i*N+j-1];
         }
         if((i==0)&&(j==N-1))
         {
            Energy=lattice[(i+1)*N+j]+lattice[i*N+j-1];
         }
         if((i==N-1)&&(j==0))
         {
            Energy=lattice[i*N+j+1]+lattice[(i-1)*N+j];
         }
         GlobalEnergy=GlobalEnergy+(-lattice[i*N+j]*Energy);
      }
   }

   return GlobalEnergy;
}
//-----------------------------------------------------------------
void metropolis(int *net_spins, double *net_energy, int *spin_arr1, int const N, int const times, double const BJ, double const energy)
{
   int spin_arr[N*N];

   for(int i=0; i<N*N;i++)
   {
      spin_arr[i]=spin_arr1[i];
   }

   for(int i=0; i<times;i++)
   {
      net_spins[i]=0;
      net_energy[i]=0;
   }

}

int main()
{
   int lattice_n[]={ 1, -1, -1, -1, -1,  1,  1, 1, -1, -1, 1, -1, -1, -1, -1,  1,  1, -1, -1, -1, -1, -1, -1,  1, -1};
   int lattice_p[]={ 1,  1,  1,  1,  1, -1,  1, 1,  1,  1, 1,  1,  1,  1, -1, -1, -1, -1,  1,  1,  1,  1,  1,  1, -1};
   int N=5;

   cout << "Energy of System is "<< get_energy(lattice_p,N) <<"\t" << get_energy(lattice_n,N)<< endl;

   int *net_spins, times=100;
   double *net_energy;
   net_spins = new int[times];
   net_energy = new double[times];
   metropolis(net_spins, net_energy,lattice_n, N ,times, 0.7, get_energy(lattice_n,N));

   return 0;
}