#include <iostream>
#include <fstream>
#include <cuda.h>
#include <thrust/reduce.h>
#include <thrust/random.h>
#include <thrust/random/linear_congruential_engine.h>
#include <thrust/random/uniform_int_distribution.h>

#include<openacc_curand.h>
#include<curand.h>

using namespace std;

#define cMM cudaMallocManaged

template <class T>
void print1D(T *array, int const N)
{
   for (int i = 0; i < N; i++)
   {
      cout << array[i] << "\n";
   }
}

class Edge
{
public:
   int v0, v1, wt;
   __device__ __host__ Edge()
   {
      v0 = 0, v1 = 0, wt = 0;
   }
};

class Vertix
{
public:
   int *Neigh, n, *wt;
   __device__ __host__ Vertix()
   {
      Neigh = nullptr;
      wt = nullptr;
      n = 0;
   }
};

int get_energy(int *lattice, Vertix *vertices, int const V)
{
   int LocalEnergy = 0, GlobalEnergy = 0, i, j;
   for (i = 0; i < V; i++)
   {
      for (j = 0; j < vertices[i].n; j++)
      {
         // cout << vertices[i].wt[j] << "\t";
         LocalEnergy += vertices[i].wt[j] * lattice[vertices[i].Neigh[j] - 1];
         // cout << vertices[i].wt[j] << " " << lattice[vertices[i].Neigh[j]-1] <<"\t";
      }
      // cout << "\n";
      GlobalEnergy += LocalEnergy * lattice[i];
   }
   return GlobalEnergy;
}

void metropolis(int *net_spins, int *net_energy, int *latticeO, Vertix *vertices, int V, int times, int energy)
{
   int t, x, spin_i, spin_f, E_i, E_f, j, dE, Fp = 200; // number of flips

   thrust::random::ranlux24_base rnd;
   thrust::uniform_int_distribution<int> dist(0, V - 1);
   thrust::uniform_int_distribution<double> dist2(0, 1);
   thrust::uniform_int_distribution<int> dist3(0, Fp);

   double beta = 0.7, p = Fp, decay = 0.01,y;
   int lattice[V], i, s = 0,z;
   //i = cMM(&lattice, V * sizeof(int));

   curandState_t state;

#pragma acc data create(lattice [0:V - 1]) copy(latticeO [0:V - 1], vertices [0:V - 1])
   {
      while (s < times)
      {
//#pragma acc kernels
         {
#pragma acc parallel loop gang num_gangs(V) present(latticeO)
            for (i = 0; i < V; i++)
            {
               lattice[i] = latticeO[i];
            }

#pragma acc parallel loop gang num_gangs(V) private(state) present(latticeO,vertices)
            for (t = 0; t < V; t++)
            {
               curand_init(t*(s+1), 0ULL, 0ULL, &state);
               //x = dist(rnd);
               x=(int)(curand_uniform(&state)*V);
               //printf("%d\n",x);

               spin_i = lattice[x]; // initial spin
               spin_f = -spin_i;    // proposed spin flip

               // compute change in energy
               E_i = 0;
               E_f = 0;

#pragma acc loop
               for (j = 0; j < vertices[x].n; j++)
               {
                  E_i += vertices[x].wt[j] * latticeO[vertices[x].Neigh[j] - 1] * spin_i;
                  E_f += vertices[x].wt[j] * latticeO[vertices[x].Neigh[j] - 1] * spin_f;
               }

               dE = E_f - E_i;
               //y=dist2(rnd);
               y = curand_uniform(&state);
               //printf("%f\n",y);
               //z=dist3(rnd);
               z=(int)(curand_uniform(&state)*Fp);
               //printf("%d\n",z);
               if ((dE > 0) && (y < exp(-beta * dE)) && (z < p))
               {
                  lattice[x] = spin_f;
                  // energy += dE;
               }
               else if ((dE < 0) && (z < p))
               {
                  lattice[x] = spin_f;
                  // energy += dE;
               }

               // net_spins[t] = thrust::reduce(thrust::host, latticeO, latticeO+V, latticeO[0]);
               // net_energy[t] = energy;
            }

#pragma acc parallel loop gang num_gangs(V) present(latticeO)
            for (i = 0; i < V; i++)
            {
               latticeO[i] = lattice[i];
            }
         }
         s++;
         p = p * decay;
      }
   }
}

int main()
{
   int V, E;
   ifstream Graph;
   Graph.open("G13.txt");

   Graph >> V >> E;

   Edge *edges;

   int i = cMM(&edges, E * sizeof(Edge)), j;
   for (i = 0; i < E; i++)
   {
      Graph >> edges[i].v0 >> edges[i].v1 >> edges[i].wt;
      // cout << edges[i].v0 << " " << edges[i].v1 << " " << edges[i].wt<< "\n" ;
   }

   // Calculating Number of neighbours for each vertix
   Vertix *vertices;
   i = cMM(&vertices, V * sizeof(Vertix));
   for (i = 0; i < E; i++)
   {
      vertices[edges[i].v0 - 1].n++;
      vertices[edges[i].v1 - 1].n++;
   }
   for (j = 0; j < V; j++)
   {
      // cout << vertices[j].n << "\n";
      i = cMM(&vertices[j].Neigh, (vertices[j].n) * sizeof(int));
      i = cMM(&vertices[j].wt, (vertices[j].n) * sizeof(int));
      vertices[j].n = 0;
   }

   // Storing Neughbours for each vertix
   for (i = 0; i < E; i++)
   {
      vertices[edges[i].v0 - 1].Neigh[vertices[edges[i].v0 - 1].n] = edges[i].v1;
      vertices[edges[i].v1 - 1].Neigh[vertices[edges[i].v1 - 1].n] = edges[i].v0;

      vertices[edges[i].v0 - 1].wt[vertices[edges[i].v0 - 1].n] = edges[i].wt;
      vertices[edges[i].v1 - 1].wt[vertices[edges[i].v1 - 1].n] = edges[i].wt;

      vertices[edges[i].v0 - 1].n += 1;
      vertices[edges[i].v1 - 1].n += 1;
   }

   // Printing Neighbours for each Vertix
   /*for(i=0;i<V;i++)
   {
      cout << i+1 << "\t";
      for(j=0;j<vertices[i].n;j++)
      {
         cout << vertices[i].wt[j] << "\t";
      }
      cout << "\n";
   }*/

   // Creating lattice
   thrust::random::ranlux24_base rng;
   thrust::uniform_real_distribution<double> dist(0, 1);
   int *lattice;
   i = cMM(&lattice, V * sizeof(int));
   double k;

   // Making 50% of the vertices positive
   for (i = 0; i < V; i++)
   {
      k = dist(rng);
      if (k < 0.50)
      {
         lattice[i] = -1;
      }
      else
      {
         lattice[i] = 1;
      }
   }

   // Calculating Energy
   cout << "Energy of System is " << get_energy(lattice, vertices, V) << "\n";

   // Calling Metropolis Algorithm
   int *net_spins, *net_energy, times = 1000; // Sweeps or times
   i = cMM(&net_spins, times * sizeof(int));
   i = cMM(&net_energy, times * sizeof(int));
   metropolis(net_spins, net_energy, lattice, vertices, V, times, get_energy(lattice, vertices, V));

   //print1D<int>(net_energy,times);
   cout << "Energy of System is " << get_energy(lattice, vertices, V) << "\n";

   // Calculating the Best Cut
   int BestCut = 0;
   for (i = 0; i < E; i++)
   {
      if (lattice[edges[i].v0 - 1] != lattice[edges[i].v1 - 1])
      {
         BestCut++;
      }
   }
   cout << "The best cut is\t" << BestCut << "\n";
   return 0;
}
