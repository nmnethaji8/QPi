#include<iostream>
#include<fstream>
#include<cuda.h>
#include <thrust/random.h>
#include <thrust/random/linear_congruential_engine.h>
#include <thrust/random/uniform_int_distribution.h>

using namespace std;

#define cMM cudaMallocManaged

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
   int lattice[V];
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
   cout << "Energy of System is "<< get_energy(lattice,vertices,V) <<"\n";
   return 0;
}