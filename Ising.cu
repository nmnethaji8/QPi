#include<iostream>

using namespace std;

double System_Energy(int *lattice, int N)
{
   double Energy=0;
   for(int i=0; i<N; i++)
   {
      for(int j=0; j<N; j++)
      {
         cout << lattice[i*N+j] << "\t";
         //Energy=lattice[(i+1)*N+j]+lattice[i*N+j+1]+lattice[(i-1)*N+j]+lattice[i*N+j-1];
      }
      cout << "\n";
   }
   return 0;
}

int main()
{
   int lattice_n[]={ 1, -1, -1, -1, -1,  1,  1, 1, -1, -1, 1, -1, -1, -1, -1,  1,  1, -1, -1, -1, -1, -1, -1,  1, -1};
   int lattice_p[]={ 1,  1,  1,  1,  1, -1,  1, 1,  1,  1, 1,  1,  1,  1, -1, -1, -1, -1,  1,  1,  1,  1,  1,  1, -1};
   int N=5;

   System_Energy(lattice_p,N);

   return 0;
}