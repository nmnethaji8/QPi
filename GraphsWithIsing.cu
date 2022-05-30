#include<iostream>
#include<fstream>
#include<cuda.h>

using namespace std;

class Edge
{
   public:
   int v0=0,v1=0,wt=0;
};

int main()
{
   int V,E;
   ifstream Graph;
   Graph.open("G13.txt");

   Graph >> V >> E;

   Edge edges[E];

   for(int i=0;i<E;i++)
   {
      Graph >> edges[i].v0 >> edges[i].v1 >> edges[i].wt;
   }
   return 0;
}