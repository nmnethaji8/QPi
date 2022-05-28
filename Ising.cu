#include<iostream>

using namespace std;

double System_Energy(int *lattice, int N)
{
   double Energy=0,a,b,c,d;
   for(int i=1; i<N-1; i++)
   {
      for(int j=1; j<N-1; j++)
      {

         Energy=Energy+lattice[(i+1)*N+j]+lattice[i*N+j+1]+lattice[(i-1)*N+j]+lattice[i*N+j-1];
      }
   }
   return Energy;
}

int main()
{
   int lattice_n[]={ 1, -1, -1, -1, -1,  1,  1, 1, -1, -1, 1, -1, -1, -1, -1,  1,  1, -1, -1, -1, -1, -1, -1,  1, -1};
   int lattice_p[]={ 1,  1,  1,  1,  1, -1,  1, 1,  1,  1, 1,  1,  1,  1, -1, -1, -1, -1,  1,  1,  1,  1,  1,  1, -1};
   int N=5;

   cout << "Energy of System is "<< System_Energy(lattice_p,N) << endl;

   return 0;
}