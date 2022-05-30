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

class Vertix
{
   public:
   int *Neigh,n;
   Vertix()
   {
      Neigh=nullptr;
      n=0;
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
      //cout << edges[i].v0 << " " << edges[i].v1 << " " << edges[i].wt<< "\n" ;
   }

   Vertix *vertices;
   i= cMM(&vertices, V*sizeof(Vertix));
   for(i=0;i<E;i++)
   {
      vertices[edges[i].v0-1].n++;
      vertices[edges[i].v1-1].n++;
   }
   for(int j=0;j<V;j++)
   {
      //cout << vertices[j].n << "\n";
      i=cMM(&vertices[j].Neigh, (vertices[j].n)*sizeof(Vertix));
   }
   return 0;
}