#include<iostream>
#include<fstream>
#include<cuda.h>
#include <thrust/reduce.h>
#include <thrust/random.h>
#include <thrust/random/linear_congruential_engine.h>
#include <thrust/random/uniform_int_distribution.h>

using namespace std;

#define cMM cudaMallocManaged

template<class T> void print1D( T *array,int const N )
{
   for(int i=0;i<N;i++)
   {
      cout << array[i] << "\n"; 
   }
}

class Edge
{
   public:
   int v0,v1,wt;
   __device__ __host__ Edge()
   {
      v0=0,v1=0,wt=0;
   }
};

class Vertix
{
   public:
   int *Neigh,n,*wt;
   __device__ __host__ Vertix()
   {
      Neigh=nullptr;
      wt=nullptr;
      n=0;
   }
};

int get_energy(int *lattice, Vertix *vertices, int const V)
{
   int LocalEnergy=0,GlobalEnergy=0,i,j;
   for(i=0; i<V; i++)
   {
      for(j=0;j<vertices[i].n;j++)
      {
         //cout << vertices[i].wt[j] << "\t";
         LocalEnergy+=vertices[i].wt[j]*lattice[vertices[i].Neigh[j]-1];
         //cout << vertices[i].wt[j] << " " << lattice[vertices[i].Neigh[j]-1] <<"\t";
      }
      //cout << "\n";
      GlobalEnergy+=LocalEnergy*lattice[i];
   }
   return GlobalEnergy;
}

void metropolis(int *net_spins,int *net_energy,int *lattice,Vertix *vertices, int V ,int times, int InEnergy)
{
   int t,x,spin_i,spin_f,E_i,E_f,j,dE, energy=0;

   thrust::random::ranlux24_base rnd;
   thrust::uniform_int_distribution<int> dist(0,V-1);

   for(t=0;t<times;t++)
   {
      x=dist(rnd);

      spin_i =  lattice[x];   //initial spin
      spin_f = -spin_i;       //proposed spin flip

      //compute change in energy
      E_i = 0;
      E_f = 0;

      for(j=0;j<vertices[x].n;j++)
      {
         E_i+=vertices[x].wt[j]*spin_i;
         E_f+=vertices[x].wt[j]*spin_f;
      }

      dE = E_f-E_i;
      if(dE<0)
      {
         lattice[x]=spin_f;
         energy+=dE;
      }

      net_spins[t] = thrust::reduce(thrust::host, lattice, lattice+V, lattice[0]);
      net_energy[t]= energy;
   }

}

int main()
{
   int V,E;
   ifstream Graph;
   Graph.open("G13.txt");

   Graph >> V >> E;

   Edge *edges;

   int i= cMM(&edges, E*sizeof(Edge)),j;
   for(i=0;i<E;i++)
   {
      Graph >> edges[i].v0 >> edges[i].v1 >> edges[i].wt;
      //cout << edges[i].v0 << " " << edges[i].v1 << " " << edges[i].wt<< "\n" ;
   }

//Calculating Number of neighbours for each vertix
   Vertix *vertices;
   i= cMM(&vertices, V*sizeof(Vertix));
   for(i=0;i<E;i++)
   {
      vertices[edges[i].v0-1].n++;
      vertices[edges[i].v1-1].n++;
   }
   for(j=0;j<V;j++)
   {
      //cout << vertices[j].n << "\n";
      i=cMM(&vertices[j].Neigh, (vertices[j].n)*sizeof(int));
      i=cMM(&vertices[j].wt, (vertices[j].n)*sizeof(int));
      vertices[j].n=0;
   }

//Storing Neughbours for each vertix
   for(i=0;i<E;i++)
   {
      vertices[edges[i].v0-1].Neigh[vertices[edges[i].v0-1].n]=edges[i].v1;
      vertices[edges[i].v1-1].Neigh[vertices[edges[i].v1-1].n]=edges[i].v0;

      vertices[edges[i].v0-1].wt[vertices[edges[i].v0-1].n]=edges[i].wt;
      vertices[edges[i].v1-1].wt[vertices[edges[i].v1-1].n]=edges[i].wt;

      vertices[edges[i].v0-1].n+=1;
      vertices[edges[i].v1-1].n+=1;
   }

//Printing Neighbours for each Vertix
   /*for(i=0;i<V;i++)
   {
      cout << i+1 << "\t";
      for(j=0;j<vertices[i].n;j++)
      {
         cout << vertices[i].wt[j] << "\t";
      }
      cout << "\n";
   }*/

//Creating lattice
   thrust::random::ranlux24_base rng;
   thrust::uniform_real_distribution<double> dist(0,1);
   int *lattice;
   i=cMM(&lattice,V*sizeof(int));
   double k;

//Making 50% of the vertices positive
   for(i=0;i<V;i++)
   {
      k=dist(rng);
      if(k<0.50)
      {
         lattice[i]=-1;
      }
      else
      {
         lattice[i]=1;
      }
   }

//Calculating Energy
   //cout << "Energy of System is "<< get_energy(lattice,vertices,V) <<"\n";

//Calling Metropolis Algorithm
   int *net_spins,*net_energy,times=10000;
   i=cMM(&net_spins,times*sizeof(int));
   i=cMM(&net_energy,times*sizeof(int));
   metropolis(net_spins, net_energy,lattice,vertices, V ,times, get_energy(lattice,vertices,V));

   print1D<int>(net_energy,times);
   return 0;
}
