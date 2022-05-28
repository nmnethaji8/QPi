#include<iostream>

using namespace std;

double System_Energy(int *lattice, int N)
{
   double Energy=0,a,b,c,d;
   int lattice2[N*N];
   for(int i=0; i<N; i++)
   {
      for(int j=0; j<N; j++)
      {
         if((i!=0)&&(i!=N-1)&&(j!=0)&&(j!=N-1))
         {
            Energy=lattice[(i+1)*N+j]+lattice[i*N+j+1]+lattice[(i-1)*N+j]+lattice[i*N+j-1];
            cout << lattice[(i+1)*N+j]+lattice[i*N+j+1]+lattice[(i-1)*N+j]+lattice[i*N+j-1] << "\t";
         }
         if((i==0)&&(i!=N-1)&&(j!=0)&&(j!=N-1))
         {
            Energy=lattice[(i+1)*N+j]+lattice[i*N+j+1]+lattice[i*N+j-1];
            cout << lattice[(i+1)*N+j]+lattice[i*N+j+1]+lattice[i*N+j-1] << "\t";
         }
         if((i!=0)&&(i==N-1)&&(j!=0)&&(j!=N-1))
         {
            Energy=lattice[i*N+j+1]+lattice[(i-1)*N+j]+lattice[i*N+j-1];
            cout << lattice[i*N+j+1]+lattice[(i-1)*N+j]+lattice[i*N+j-1] << "\t";
         }
         if((i!=0)&&(i!=N-1)&&(j==0)&&(j!=N-1))
         {
            Energy=lattice[(i+1)*N+j]+lattice[i*N+j+1]+lattice[(i-1)*N+j];
            cout << lattice[(i+1)*N+j]+lattice[i*N+j+1]+lattice[(i-1)*N+j]<< "\t";
         }
         if((i!=0)&&(i!=N-1)&&(j!=0)&&(j==N-1))
         {
            Energy=lattice[(i+1)*N+j]+lattice[(i-1)*N+j]+lattice[i*N+j-1];
            cout << lattice[(i+1)*N+j]+lattice[(i-1)*N+j]+lattice[i*N+j-1] << "\t";
         }
         if((i==0)&&(j==0))
         {
            Energy=lattice[(i+1)*N+j]+lattice[i*N+j+1];
            cout << lattice[(i+1)*N+j]+lattice[i*N+j+1]<< "\t";
         }
         if((i==N-1)&&(j==N-1))
         {
            Energy=lattice[(i-1)*N+j]+lattice[i*N+j-1];
            cout << lattice[(i-1)*N+j]+lattice[i*N+j-1] << "\t";
         }
         if((i==0)&&(j==N-1))
         {
            Energy=lattice[(i+1)*N+j]+lattice[i*N+j-1];
            cout << lattice[(i+1)*N+j]+lattice[i*N+j-1] << "\t";
         }
         if((i==N-1)&&(j==0))
         {
            Energy=lattice[i*N+j+1]+lattice[(i-1)*N+j];
            cout << lattice[i*N+j+1]+lattice[(i-1)*N+j] << "\t";
         }
         lattice2[i*N+j]=Energy;
      }
      cout << "\n";
   }
   return Energy;
}

int main()
{
   int lattice_n[]={ 1, -1, -1, -1, -1,  1,  1, 1, -1, -1, 1, -1, -1, -1, -1,  1,  1, -1, -1, -1, -1, -1, -1,  1, -1};
   int lattice_p[]={ 1,  1,  1,  1,  1, -1,  1, 1,  1,  1, 1,  1,  1,  1, -1, -1, -1, -1,  1,  1,  1,  1,  1,  1, -1};
   int N=5;

   cout << "Energy of System is \n"<< System_Energy(lattice_p,N) << endl;

   return 0;
}