#include<iostream>

using namespace std;

double System_Energy(int *lattice, int const N)
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

int main()
{
   int lattice_n[]={ 1, -1, -1, -1, -1,  1,  1, 1, -1, -1, 1, -1, -1, -1, -1,  1,  1, -1, -1, -1, -1, -1, -1,  1, -1};
   int lattice_p[]={ 1,  1,  1,  1,  1, -1,  1, 1,  1,  1, 1,  1,  1,  1, -1, -1, -1, -1,  1,  1,  1,  1,  1,  1, -1};
   int N=5;

   cout << "Energy of System is "<< System_Energy(lattice_p,N) << endl;

   return 0;
}