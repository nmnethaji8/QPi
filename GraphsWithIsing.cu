#include<iostream>
#include<fstream>
#include<cuda.h>

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

class Vertices
{
   public:
   int *Neigh;
   Vertices()
   {
      Neigh=nullptr;
   }
};

int main()
{
   int V,E;
   ifstream Graph;
   Graph.open("G13.txt");

   Graph >> V >> E;

   Edge *edges;

   int i= cMM(&edges, E*sizeof(Edge));
   for(i=0;i<E;i++)
   {
      Graph >> edges[i].v0 >> edges[i].v1 >> edges[i].wt;
      cout << edges[i].v0 << " " << edges[i].v1 << " " << edges[i].wt<< "\n" ;
   }
   return 0;
}