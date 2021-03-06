#include<iostream>
#include <thrust/reduce.h>
#include <thrust/random.h>
#include <thrust/random/linear_congruential_engine.h>
#include <thrust/random/uniform_int_distribution.h>
#include <cuda.h>
#include <curand.h>

using namespace std;
template<class T> void print1D( T *array,int const N )
{
   for(int i=0;i<N;i++)
   {
      cout << array[i] << "\t"; 
   }
   cout << "\n";
}
double get_energy(int *lattice, int const N)
{
   double Energy=0,GlobalEnergy=0;
   for(int i=0; i<N; i++)
   {
      for(int j=0; j<N; j++)
      {
         if((i!=0)&&(i!=(N-1))&&(j!=0)&&(j!=(N-1)))
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
void metropolis(int *net_spins, double *net_energy, int *spin_arr1, int const N, int const times, double const BJ, double energy)
{
   int spin_arr[N*N],x,y,spin_i,spin_f,E_i,E_f,dE;
   // create a uniform_int_distribution to produce ints from [-7,13]
   thrust::random::ranlux24_base rng, rng2;
   thrust::uniform_int_distribution<int> dist(0,N-1);
   thrust::uniform_real_distribution<double> dist2(0,1);
   for(int i=0; i<N*N;i++)
   {
      spin_arr[i]=spin_arr1[i];
   }

   for(int i=0; i<times;i++)
   {
      net_spins[i]=0;
      net_energy[i]=0;
   }

   for(int t=0;t<times;t++)
   {  
      x=dist(rng);
      y=dist(rng);
      //cout << "(" << x << "," << y << ")\t";

      spin_i = spin_arr[x*N+y]; //initial spin
      spin_f = spin_i*-1; //proposed spin flip

      //compute change in energy
      E_i = 0;
      E_f = 0;
      if(x>0)
      {
         E_i += -spin_i*spin_arr[(x-1)*N+y];
         E_f += -spin_f*spin_arr[(x-1)*N+y];
      }
      if(x<N-1)
      {
         E_i += -spin_i*spin_arr[(x+1)*N+y];
         E_f += -spin_f*spin_arr[(x+1)*N+y];
      }
      if(y>0)
      {
         E_i += -spin_i*spin_arr[x*N+y-1];
         E_f += -spin_f*spin_arr[x*N+y-1];
      }
      if(y<N-1)
      {
         E_i += -spin_i*spin_arr[x*N+y+1];
         E_f += -spin_f*spin_arr[x*N+y+1];
      }

      // 3 / 4. change state with designated probabilities
      dE = E_f-E_i;
      if((dE>0)&&(dist2(rng2) < exp(-BJ*dE)))
      {
         spin_arr[x*N+y]=spin_f;
         energy += dE;
      }
      else if(dE<=0)
      {
         spin_arr[x*N+y]=spin_f;
         energy += dE;
      }

      net_spins[t] = thrust::reduce(thrust::host, spin_arr, spin_arr + N*N, spin_arr[0]);
      net_energy[t]= energy;
   }
}

int main()
{
   thrust::random::ranlux24_base rng;
   thrust::uniform_real_distribution<double> dist(0,1);
   int const N=50;
   int lattice_n[N*N],lattice_p[N*N];
   double k;
   for(int i=0;i<N*N;i++)
   {
      k=dist(rng);
      if(k<0.75)
      {
         lattice_n[i]=-1;
      }
      else
      {
         lattice_n[i]=1;
      }

      k=dist(rng);
      if(k<0.75)
      {
         lattice_p[i]=1;
      }
      else
      {
         lattice_p[i]=-1;
      }
   }

   //int lattice_n[]={ 1, -1, -1, -1, -1,  1,  1, 1, -1, -1, 1, -1, -1, -1, -1,  1,  1, -1, -1, -1, -1, -1, -1,  1, -1};
   //int lattice_p[]={ 1,  1,  1,  1,  1, -1,  1, 1,  1,  1, 1,  1,  1,  1, -1, -1, -1, -1,  1,  1,  1,  1,  1,  1, -1};

   //cout << "Energy of System is "<< get_energy(lattice_p,N) <<"\t" << get_energy(lattice_n,N)<< endl;

   int *net_spins, times=1000000;
   double *net_energy,tb=0.7;
   net_spins = new int[times];
   net_energy = new double[times];
   metropolis(net_spins, net_energy,lattice_n, N ,times, tb, get_energy(lattice_n,N));

   //print1D(net_spins,times);
   //print1D(net_energy,times);
   return 0;
}