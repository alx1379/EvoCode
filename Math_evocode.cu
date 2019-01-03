#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>
#include "common.h"
//#include <cuda_runtime.h>

// Structure for creature
struct Creature {
	int Energy; 
	int Velocity;
	int TimeLeft;
	int Code[100];
	int codelen, codepos;
	int ParentRef;
	int Ref;
	long Output[3];
	bool Child;
};

typedef struct Creature Creature;

// Structure for World
struct World {
	int Energy;
	int TimeLeft;
	struct Creature Lifes[50000];
//	bool ChildLifes[5000];
	int NumOfLifes;
	int AliveCreatures;
	int MaxEnergy;
	int Input[3];
	int Fitness[3];
};

typedef struct World World;

// Return rnadom number between min and max 
int range_rand(int min_num, int max_num) {

	if(min_num > max_num) {
		fprintf(stderr, "min_num %i is greater than max_num %i!\n", min_num, max_num); 
	}
	// Return random number in range
	return min_num + (rand() % (max_num - min_num + 1));
} 

bool IsAlive(Creature *Life)
{
	if  (Life->Energy > 0 && Life->TimeLeft > 0) return(true);
	return(false);
}

Creature FindCreature(World *Iteration, int Ref)
{
	for (int i = 0; i < Iteration->NumOfLifes; i++)
	{
		if (Iteration->Lifes[i].Ref == Ref) return(Iteration->Lifes[i]);
	}
}

void PrintCode(Creature *Life)
{
	for (int i = 0; i < Life->codelen; i++)
	printf("%i", Life->Code[i]);
}

// Calculate All World Energy  
int AllEnergy(World *Iteration)
{
	int totalenergy = 0;
	for (int i = 0; i < Iteration->NumOfLifes; i++)
	{
		if (Iteration->Lifes[i].TimeLeft > 0)
		totalenergy += Iteration->Lifes[i].Energy;
	}
	return(totalenergy);
}

void PrintLife(Creature *Life)
{
        printf("\n\rFunction:PrintLife Energy:%i Velocity:%i TimeLeft:%i codelen:%i codepos: %i parentref: %i ref: %i OUTPUT:%i#%i#%i# \nCode:",
        Life->Energy, Life->Velocity, Life->TimeLeft, Life->codelen, Life->codepos, Life->ParentRef, Life->Ref, Life->Output[0], Life->Output[1], Life->Output[2]);

        for (int k = 0; k < Life->codelen; k++) {
		if (k == Life->codepos) printf("*"); 
		printf("%i,", Life->Code[k]);
	}
}

Creature InitLife(World *Iteration, int ParRef)
{
	Creature Life;

	Life.Energy = Iteration->MaxEnergy - AllEnergy(Iteration); 
	if (Life.Energy > 5) Life.Energy = 15;

	Life.Velocity = 1;
	Life.TimeLeft = 19;
	Life.codelen = range_rand(5, 10);
	Life.codepos = 0;
	Life.Child = false;
	Life.Output[0] = 0;
	Life.Output[1] = 0;
	Life.Output[2] = 0;
	for (int i = 0; i < Life.codelen; i++) Life.Code[i] = range_rand(1, 9);
//	Life.Ref = range_rand(1, 65535);
	Life.Ref = Iteration->NumOfLifes;
//	if (ParRef == 0) printf("\n *** REF IS BROKEN");
	Life.ParentRef = ParRef;

//	printf("\n LIFE BORN");
//	PrintLife(Life);

	Iteration->Lifes[Iteration->NumOfLifes] = Life;
	Iteration->NumOfLifes++;

	return(Life);
}

void NewLife(World *Iteration, int ParRef, Creature *Life)
{
        Life->Energy = Iteration->MaxEnergy - Iteration->Energy;
        if (Life->Energy > 5) Life->Energy = 15;

        Life->Velocity = 1;
        Life->TimeLeft = 19;
        Life->codelen = range_rand(5, 10);
        Life->codepos = 0;
	Life->Child = false;
	Life->Output[0] = 0;
	Life->Output[1] = 0;
	Life->Output[2] = 0;
        for (int i = 0; i < Life->codelen; i++) Life->Code[i] = range_rand(1, 9);
        Life->Ref = Iteration->NumOfLifes;
//        if (ParRef == 0) printf("\n *** REF IS BROKEN");
        Life->ParentRef = ParRef;

//      printf("\n LIFE BORN");
//      PrintLife(Life);

        Iteration->Lifes[Iteration->NumOfLifes] = *Life;
        Iteration->NumOfLifes++;
}

__global__ void RunLife(World *Iteration, const int n)
{
	struct Creature NewLife; // Make a child with random permutation

	unsigned int i = blockIdx.x * blockDim.x + threadIdx.x;

        Iteration->TimeLeft--;
//	Iteration->AliveCreatures = 0;
//	Iteration->Energy = 0;
//        printf("\n\r------------------------\n\rFunction:PrintWorld TimeLeft:%i Energy:%i NumOfLifes:%i AliveCreatures: %i",
//        Iteration->TimeLeft, Iteration->Energy, Iteration->NumOfLifes, Iteration->AliveCreatures);
	
	if (i < n)
	{

	struct Creature Life = Iteration->Lifes[i];

	int NewRef = Life.Ref;

	// IsAlive
	if  (Life.Energy > 0 && Life.TimeLeft > 0)
	{
//		Iteration->Energy += Life.Energy;
//		Iteration->AliveCreatures++;

		// PrintLife	
//	        printf("\n\rFunction:PrintLife Energy:%i Velocity:%i TimeLeft:%i codelen:%i codepos: %i parentref: %i ref: %i \nCode:",
//	        Life.Energy, Life.Velocity, Life.TimeLeft, Life.codelen, Life.codepos, Life.ParentRef, Life.Ref);
//		for (int k = 0; k < Life.codelen; k++) printf("%i", Life.Code[k]);

		// run code "Velocity" number of times     
		for (int i = 0; i < Life.Velocity; i++) {
		int k;
		switch(Life.Code[Life.codepos])
		{
			case 1: Life.Energy += 2;
				break;
			case 2: Life.Velocity++; //if (Life.codelen > 3) Life.codelen = Life.codelen/2; // Half genome
				break;
			case 3: Life.Output[0] = Life.Output[0] * Life.Output[0];
				Life.Output[1] = Life.Output[1] * Life.Output[1];
				Life.Output[2] = Life.Output[2] * Life.Output[2];
				//for (k = 0; k < Life.codelen-1; k++) // Learn from myself? other creature
				//Life.Code[Life.codelen+k] = Life.Code[k+1];
				//Life.codelen = Life.codelen+k;
				break;
			case 4: //Life.Child = true;
				Life.Output[0]--;
				Life.Output[1]--;
				Life.Output[2]--;
				break;
			case 5: Life.Output[0]++;
				Life.Output[1]++;
				Life.Output[2]++;
				break;
			case 6: Life.Output[0] = Life.Output[0] + Iteration->Input[0]; 
				Life.Output[1] = Life.Output[1] + Iteration->Input[1];
				Life.Output[2] = Life.Output[2] + Iteration->Input[2];
				break;
                        case 7: Life.Output[0] = Life.Output[0] - Iteration->Input[0]; 
				Life.Output[1] = Life.Output[1] - Iteration->Input[1];
				Life.Output[2] = Life.Output[2] - Iteration->Input[2];
				break;
                        case 8: Life.Output[0] = Life.Output[0] * Iteration->Input[0]; 
				Life.Output[1] = Life.Output[1] * Iteration->Input[1];
				Life.Output[2] = Life.Output[2] * Iteration->Input[2];
				break;
                        case 9: Life.Output[0] = Life.Output[0] / Iteration->Input[0]; 
				Life.Output[1] = Life.Output[1] / Iteration->Input[1];
				Life.Output[2] = Life.Output[2] / Iteration->Input[2];
				break;
		}
		Life.codepos++;
		if (Life.codepos > Life.codelen) Life.codepos = 0;
		}
		Life.TimeLeft--;
		Life.Energy--;
	}
                // PrintLife
//                printf("\n\rFunction:PrintLife Energy:%i Velocity:%i TimeLeft:%i codelen:%i codepos: %i parentref: %i ref: %i \nCode:",
//                Life.Energy, Life.Velocity, Life.TimeLeft, Life.codelen, Life.codepos, Life.ParentRef, Life.Ref);
//                for (int k = 0; k < Life.codelen; k++) printf("%i", Life.Code[k]);

		Iteration->Lifes[i] = Life;
	}
//        printf("\n\r------------------------\n\rFunction:PrintWorld TimeLeft:%i Energy:%i NumOfLifes:%i AliveCreatures: %i",
//        Iteration->TimeLeft, Iteration->Energy, Iteration->NumOfLifes, Iteration->AliveCreatures);
}

/*World InitWorld(void)
{
        World Iteration;

        Iteration.Energy = 0;
        Iteration.TimeLeft = 200;
	Iteration.NumOfLifes = 0;
	Iteration.MaxEnergy = 50;
	Iteration.AliveCreatures = 0;
	Iteration.Input = 0;
        Iteration.Fitness = ((((Iteration.Input + Iteration.Input) * Iteration.Input) - Iteration.Input) / Iteration.Input) + Iteration.Input;
	InitLife(&Iteration, 0);
	InitLife(&Iteration, 0);

	return(Iteration);
}*/

void NewWorld(World *Iteration)
{
        Iteration->Energy = 0;
        Iteration->TimeLeft = 20000;
        Iteration->NumOfLifes = 0;
        Iteration->MaxEnergy = 50;
        Iteration->AliveCreatures = 0;
	Iteration->Input[0] = 5;
//	Iteration->Fitness = ((((Iteration->Input + Iteration->Input + 1) * Iteration->Input) - Iteration->Input) / Iteration->Input) + Iteration->Input - 1;
	Iteration->Fitness[0] = (Iteration->Input[0] * Iteration->Input[0]) * Iteration->Input[0] + 1;
//	Iteration->Fitness[0] = 1;
        Iteration->Input[1] = 10;
	Iteration->Fitness[1] = (Iteration->Input[1] * Iteration->Input[1]) * Iteration->Input[1] + 1;
//	Iteration->Fitness[1] = 1;
        Iteration->Input[2] = 0;
        Iteration->Fitness[2] = (Iteration->Input[2] * Iteration->Input[2]) * Iteration->Input[2] + 1;
//        Iteration->Fitness[2] = 1;
	for (int i = 0; i < 2; i++)
	{
	        InitLife(Iteration, 0);
	}
	Creature ArtLife = InitLife(Iteration, -1);
//	ArtLife.Code = {5,1,8,2,6,6,1,3,3,1,6};
	ArtLife.Code[0] = 8;
	ArtLife.Code[1] = 4;
	ArtLife.codelen = 2;
}

void PrintWorld(World *Iteration)
{
	printf("\n\r------------------------\n\rFunction:PrintWorld TimeLeft:%i Energy:%i NumOfLifes:%i AliveCreatures: %i\n--------------------", 
	Iteration->TimeLeft, Iteration->Energy, Iteration->NumOfLifes, Iteration->AliveCreatures);
}

// Run World Iteration
void RunWorld(World *Iteration)
{
	Iteration->Energy = AllEnergy(Iteration);
	Iteration->TimeLeft--;

	PrintWorld(Iteration);

//	int i;
//	scanf("%i", &i);

	Iteration->AliveCreatures = 0;

	RunLife <<<1, 10>>>(Iteration, 1<<22);
	cudaDeviceSynchronize();

//	for (int i = 0; i < Iteration->NumOfLifes; i++) 
//	{
//		printf("\n Life number: %i", i);
//		int CurRef = RunLife <<<1, 1>>>(Iteration, &Iteration->Lifes[i]);
//		RunLife <<<1, 1>>>(Iteration, &Iteration->Lifes[i]);
//	}

	if (Iteration->TimeLeft > 0 && Iteration->Energy > 0) RunWorld(Iteration);
}

__global__ void helloFromGPU(void)
{
  printf("Hello World from GPU thread");
}

int main(int argc, char **argv)
{
        time_t t;

        // Intializes random number generator
        srand((unsigned) time(&t));

	// set up device
	int dev = 0;
	cudaDeviceProp deviceProp;
	CHECK(cudaGetDeviceProperties(&deviceProp, dev));
	printf("%s test struct of array at ", argv[0]);
	printf("device %d: %s \n", dev, deviceProp.name);
	CHECK(cudaSetDevice(dev));	

	// allocate host memory
	int nElem = 1<22;
	size_t nBytes = sizeof(World);
	World     *h_A = (World *)malloc(nBytes);
	World *hostRef = (World *)malloc(nBytes);
	World *gpuRef  = (World *)malloc(nBytes);

	// initialize host array
	NewWorld(gpuRef);

	// allocate device memory
	World *d_A, *d_C;

	CHECK(cudaMalloc((World**)&d_A, nBytes));
        CHECK(cudaMalloc((World**)&d_C, nBytes));
	
	// copy data from host to device
//	CHECK(cudaMemcpy(d_A, gpuRef, nBytes, cudaMemcpyHostToDevice));

        PrintLife(&gpuRef->Lifes[0]);
        PrintLife(&gpuRef->Lifes[1]);
        PrintLife(&h_A->Lifes[2]);

	PrintWorld(gpuRef);

        int BestFit[3];
	BestFit[0]  = abs(gpuRef->Fitness[0] - gpuRef->Lifes[0].Output[0]);
	BestFit[1]  = abs(gpuRef->Fitness[1] - gpuRef->Lifes[0].Output[1]);
	BestFit[2]  = abs(gpuRef->Fitness[2] - gpuRef->Lifes[0].Output[2]);

        // Run World all iterations
//        for (int i = 0; i < 200; i++)
	do
        {
//                for (int j = 0; j < gpuRef->NumOfLifes; j++) {
//			gpuRef->ChildLifes[j] = false;
//			printf(">>%d", gpuRef->ChildLifes[j]);
//		}

                // copy data from host to device
                CHECK(cudaMemcpy(d_A, gpuRef, nBytes, cudaMemcpyHostToDevice));

//		RunLife <<<1, gpuRef->NumOfLifes>>>(d_A, 1<<22);
	        RunLife <<<1, 512>>>(d_A, 1<<22);
		CHECK(cudaDeviceSynchronize());
	        CHECK(cudaMemcpy(gpuRef, d_A, nBytes, cudaMemcpyDeviceToHost));
		gpuRef->AliveCreatures = 0;
		gpuRef->Energy = 0;
		BestFit[0] = abs(gpuRef->Fitness[0] - gpuRef->Lifes[0].Output[0]);
		BestFit[1] = abs(gpuRef->Fitness[1] - gpuRef->Lifes[0].Output[1]);
	        BestFit[2] = abs(gpuRef->Fitness[2] - gpuRef->Lifes[0].Output[2]);
		int BestFitNo = 0;
		for (int j = 0; j < gpuRef->NumOfLifes; j++) {
//			PrintLife(&gpuRef->Lifes[j]);
//                        printf(">>%d", gpuRef->ChildLifes[j]);
			if (gpuRef->Lifes[j].Energy > 0 && gpuRef->Lifes[j].TimeLeft > 0) {
//	                        PrintLife(&gpuRef->Lifes[j]);
				gpuRef->AliveCreatures++;
				gpuRef->Energy += gpuRef->Lifes[j].Energy;
//	                        PrintLife(&gpuRef->Lifes[j]);
//                                printf(" *** BestFit[0] = %i - %i = %i vs CurBestFit %i", gpuRef->Fitness[0], gpuRef->Lifes[j].Output[0], abs(gpuRef->Fitness[0] - gpuRef->Lifes[j].Output[0]), BestFit[0]);
//                                printf(" *** BestFit[1] = %i - %i = %i vs CurBestFit %i", gpuRef->Fitness[1], gpuRef->Lifes[j].Output[1], abs(gpuRef->Fitness[1] - gpuRef->Lifes[j].Output[1]), BestFit[1]);
//                                printf(" *** BestFit[2] = %i - %i = %i vs CurBestFit %i", gpuRef->Fitness[2], gpuRef->Lifes[j].Output[2], abs(gpuRef->Fitness[2] - gpuRef->Lifes[j].Output[2]), BestFit[2]);
			if (abs(gpuRef->Fitness[0] - gpuRef->Lifes[j].Output[0]) < BestFit[0] && abs(gpuRef->Fitness[1] - gpuRef->Lifes[j].Output[1]) < BestFit[1] && abs(gpuRef->Fitness[2] - gpuRef->Lifes[j].Output[2]) < BestFit[2]) {
				BestFit[0] = abs(gpuRef->Fitness[0] - gpuRef->Lifes[j].Output[0]);
                                BestFit[1] = abs(gpuRef->Fitness[1] - gpuRef->Lifes[j].Output[1]);
                                BestFit[2] = abs(gpuRef->Fitness[2] - gpuRef->Lifes[j].Output[2]);
				BestFitNo = j;
//				printf(" *** BestFit[0] = %i - %i = %i", gpuRef->Lifes[j].Output[0], gpuRef->Fitness[0], BestFit[0]);
				if (BestFit[0] == 0 && BestFit[1] == 0 && BestFit[2] == 0) {
					PrintLife(&gpuRef->Lifes[j]);
	                                printf(" *** BestFit[0] = %i - %i = %i vs CurBestFit %i", gpuRef->Fitness[0], gpuRef->Lifes[j].Output[0], abs(gpuRef->Fitness[0] - gpuRef->Lifes[j].Output[0]), BestFit[0]);
		                        printf(" *** BestFit[1] = %i - %i = %i vs CurBestFit %i", gpuRef->Fitness[1], gpuRef->Lifes[j].Output[1], abs(gpuRef->Fitness[1] - gpuRef->Lifes[j].Output[1]), BestFit[1]);
			                printf(" *** BestFit[2] = %i - %i = %i vs CurBestFit %i", gpuRef->Fitness[2], gpuRef->Lifes[j].Output[2], abs(gpuRef->Fitness[2] - gpuRef->Lifes[j].Output[2]), BestFit[2]);

					break;
				}
			}
			}
		}
//			if (gpuRef->Lifes[j].Child == true) 
//			{
//				gpuRef->Lifes[j].Child = false;
//				printf("\n ***LIFE IS BORN from %i", gpuRef->Lifes[BestFitNo].Ref);
//                                PrintLife(&gpuRef->Lifes[BestFitNo]);
			gpuRef->Lifes[gpuRef->NumOfLifes].Energy = 15;
                        gpuRef->Lifes[gpuRef->NumOfLifes].TimeLeft = 19;
                        gpuRef->Lifes[gpuRef->NumOfLifes].Velocity = 1;
                        gpuRef->Lifes[gpuRef->NumOfLifes].codelen = gpuRef->Lifes[BestFitNo].codelen;
                        gpuRef->Lifes[gpuRef->NumOfLifes].codepos = 0;
		        for (int k = 0; k < gpuRef->Lifes[BestFitNo].codelen; k++) {
				if (range_rand(1, 3) == 1) {
	                                gpuRef->Lifes[gpuRef->NumOfLifes].Code[k] = range_rand(1, 9);		
				}
				else { 
					gpuRef->Lifes[gpuRef->NumOfLifes].Code[k] = gpuRef->Lifes[BestFitNo].Code[k];
				}
			}
			gpuRef->Lifes[gpuRef->NumOfLifes].Ref = gpuRef->NumOfLifes;
                        gpuRef->Lifes[gpuRef->NumOfLifes].ParentRef = gpuRef->Lifes[BestFitNo].Ref;
//				printf("\n *** Parent: %i", j);
//                        printf("\n ***LIFE IS BORN from %i", gpuRef->Lifes[BestFitNo].Ref);
//                        PrintLife(&gpuRef->Lifes[gpuRef->NumOfLifes]);
                        gpuRef->NumOfLifes++;
//			}
//		}
                PrintWorld(gpuRef);
		// copy data from host to device
//	        CHECK(cudaMemcpy(d_A, gpuRef, nBytes, cudaMemcpyHostToDevice));
		if (BestFit[0] == 0 && BestFit[1] == 0 && BestFit[2] == 0) break;
	} while (gpuRef->Energy > 0 && gpuRef->TimeLeft > 0);

	CHECK(cudaDeviceSynchronize());
	CHECK(cudaMemcpy(gpuRef, d_A, nBytes, cudaMemcpyDeviceToHost));

	PrintWorld(gpuRef);

//	PrintLife(&gpuRef->Lifes[0]);
//        PrintLife(&gpuRef->Lifes[1]);
//        PrintLife(&gpuRef->Lifes[2]);

	CHECK(cudaGetLastError());

//	RunWorld(&NewWorld);

	printf("\n\n *** Admire the winners genomes history:");
        for (int i = 0; i < gpuRef->NumOfLifes; i++)
	{
		Creature Parent = gpuRef->Lifes[i];
		if (IsAlive(&Parent)) {
			PrintLife(&Parent);
			while (Parent.ParentRef > 0) {
				Parent = FindCreature(gpuRef, Parent.ParentRef);
				printf("->");
				PrintCode(&Parent);
//				PrintLife <<<1,1>>>(Parent);
			}
		}
	}
        printf("\n\n *** Admire the winners story:");
        for (int i = 0; i < gpuRef->NumOfLifes; i++)
        {
                Creature Parent = gpuRef->Lifes[i];
                if (IsAlive(&Parent)) {
//                        PrintLife(Parent);
			printf("\n");
                        while (Parent.ParentRef > 0) {
				printf("%i->", Parent.Ref);
                                Parent = FindCreature(gpuRef, Parent.ParentRef);
//                              PrintLife <<<1, 1>>>(Parent);
                        }
                }
        }

	printf("\n");
}
