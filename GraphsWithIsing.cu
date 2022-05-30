#include<iostream>
#include<fstream>
#include<cuda.h>

using namespace std;

int main()
{
   int V,E;
   ifstream Graph;
   Graph.open("G13.txt");

   Graph >> V >> E;

   cout << V << " " << E;
   return 0;
}