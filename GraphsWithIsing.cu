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
   int *Neigh,n,*wt;
   __device__ __host__ Vertix()
   {
      Neigh=nullptr;
      wt=nullptr;
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

   int i= cMM(&edges, E*sizeof(Edge)),j,k;
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
   for(i=0;i<V;i++)
   {
      cout << i+1 << "\t";
      for(j=0;j<vertices[i].n;j++)
      {
         cout << vertices[i].wt[j] << "\t";
      }
      cout << "\n";
   }
   return 0;
}