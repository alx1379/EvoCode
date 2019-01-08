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
	long TimeLeft;
	struct Creature Lifes[32000];
	int NumOfLifes;
	int AliveCreatures;
	int MaxEnergy;
	int Input[3];
	long Fitness[3];
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
	return(Iteration->Lifes[0]);
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
        printf("\n\rFunction:PrintLife Energy:%i Velocity:%i TimeLeft:%i codelen:%i codepos: %i parentref: %i ref: %i OUTPUT:%ld#%ld#%ld# \nCode:",
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
	Life.Ref = Iteration->NumOfLifes;
//	if (ParRef == 0) printf("\n *** REF IS BROKEN");
	Life.ParentRef = ParRef;

//	printf("\n LIFE BORN");
//	PrintLife(Life);

	Iteration->Lifes[Iteration->NumOfLifes] = Life;
	Iteration->NumOfLifes++;

	return(Life);
}

void RunLife(World *Iteration, const int n)
{
	struct Creature NewLife; // Make a child with random permutation

//	unsigned int i = blockIdx.x * blockDim.x + threadIdx.x;

        Iteration->TimeLeft--;
//	Iteration->AliveCreatures = 0;
//	Iteration->Energy = 0;
//        printf("\n\r------------------------\n\rFunction:PrintWorld TimeLeft:%i Energy:%i NumOfLifes:%i AliveCreatures: %i",
//        Iteration->TimeLeft, Iteration->Energy, Iteration->NumOfLifes, Iteration->AliveCreatures);
	
	for (int i = 0; i < n; i++)
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

//		Life.Output[0] = Life.Output[1] = Life.Output[2] = 0;
		Life.Output[0] = Iteration->Input[0];
                Life.Output[1] = Iteration->Input[1];
                Life.Output[2] = Iteration->Input[2];

		// run code "Velocity" number of times     
		for (int i = 0; i < Life.codelen; i++) {
		int k;
		switch(Life.Code[i])
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

void NewWorld(World *Iteration)
{
        Iteration->Energy = 0;
        Iteration->TimeLeft = 1500000;
        Iteration->NumOfLifes = 0;
        Iteration->MaxEnergy = 50;
        Iteration->AliveCreatures = 0;
	int I0 = Iteration->Input[0] = 5;
//	Iteration->Fitness = ((((Iteration->Input + Iteration->Input + 1) * Iteration->Input) - Iteration->Input) / Iteration->Input) + Iteration->Input - 1;
	// Code:9,9,4,6,9,5,7,9,5,4,5,3,4,6,3,8,5,
//	Iteration->Fitness[0] = ()
	Iteration->Fitness[0] = (((I0 * I0) * I0 + 1 + I0) - 1) * I0;
        int I1 = Iteration->Input[1] = 10;
	Iteration->Fitness[1] = (((I1 * I1) * I1 + 1 + I1) - 1) * I1;
        int I2 = Iteration->Input[2] = 0;
        Iteration->Fitness[2] = (((I2 * I2) * I2 + 1 + I2) - 1) * I2;
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
	printf("\n\r------------------------\n\rFunction:PrintWorld TimeLeft:%ld Energy:%i NumOfLifes:%i AliveCreatures: %i\n--------------------", 
	Iteration->TimeLeft, Iteration->Energy, Iteration->NumOfLifes, Iteration->AliveCreatures);
}

int main(int argc, char **argv)
{
        time_t t;

        // Intializes random number generator
        srand((unsigned) time(&t));

	// set up device
/*	int dev = 0;
	cudaDeviceProp deviceProp;
	CHECK(cudaGetDeviceProperties(&deviceProp, dev));
	printf("device %d: %s \n", dev, deviceProp.name);
	CHECK(cudaSetDevice(dev));	

	// allocate host memory
	int nElem = 1<22;*/
	size_t nBytes = sizeof(World);
	World     *h_A = (World *)malloc(nBytes);
	World *hostRef = (World *)malloc(nBytes);
	World *gpuRef  = (World *)malloc(nBytes);

	// initialize host array
	NewWorld(gpuRef);

	// allocate device memory
	World *d_A, *d_C;

//	CHECK(cudaMalloc((World**)&d_A, nBytes));
//        CHECK(cudaMalloc((World**)&d_C, nBytes));
	
	// copy data from host to device
//	CHECK(cudaMemcpy(d_A, gpuRef, nBytes, cudaMemcpyHostToDevice));

        PrintLife(&gpuRef->Lifes[0]);
        PrintLife(&gpuRef->Lifes[1]);
        PrintLife(&h_A->Lifes[2]);

	PrintWorld(gpuRef);

        long BestFit[3];
	BestFit[0]  = abs(gpuRef->Fitness[0] - gpuRef->Lifes[0].Output[0]);
	BestFit[1]  = abs(gpuRef->Fitness[1] - gpuRef->Lifes[0].Output[1]);
	BestFit[2]  = abs(gpuRef->Fitness[2] - gpuRef->Lifes[0].Output[2]);
	
	int BestFitNo = 0;

        // Run World all iterations
	do
        {
                // copy data from host to device
//                CHECK(cudaMemcpy(d_A, gpuRef, nBytes, cudaMemcpyHostToDevice));

//		RunLife <<<1, gpuRef->NumOfLifes>>>(d_A, 1<<22);
//	        RunLife <<<64, 512>>>(d_A, 1<<22);
		RunLife(gpuRef, gpuRef->NumOfLifes);
//		CHECK(cudaDeviceSynchronize());
//	        CHECK(cudaMemcpy(gpuRef, d_A, nBytes, cudaMemcpyDeviceToHost));
		gpuRef->AliveCreatures = 0;
		gpuRef->Energy = 0;
	        BestFitNo = gpuRef->NumOfLifes-1;
		BestFit[0] = abs(gpuRef->Fitness[0] - gpuRef->Lifes[BestFitNo].Output[0]);
		BestFit[1] = abs(gpuRef->Fitness[1] - gpuRef->Lifes[BestFitNo].Output[1]);
	        BestFit[2] = abs(gpuRef->Fitness[2] - gpuRef->Lifes[BestFitNo].Output[2]);
		for (int j = 0; j < gpuRef->NumOfLifes; j++) {
//			PrintLife(&gpuRef->Lifes[j]);
//                        printf(">>%d", gpuRef->ChildLifes[j]);
			if (gpuRef->Lifes[j].Energy > 0 && gpuRef->Lifes[j].TimeLeft > 0) 
			{
//	                        PrintLife(&gpuRef->Lifes[j]);
				gpuRef->AliveCreatures++;
				gpuRef->Energy += gpuRef->Lifes[j].Energy;
//	                        PrintLife(&gpuRef->Lifes[j]);
//                                printf(" *** BestFit[0] = %ld - %ld = %ld vs CurBestFit %ld", gpuRef->Fitness[0], gpuRef->Lifes[j].Output[0], abs(gpuRef->Fitness[0] - gpuRef->Lifes[j].Output[0]), BestFit[0]);
//                                printf(" *** BestFit[1] = %ld - %ld = %ld vs CurBestFit %ld", gpuRef->Fitness[1], gpuRef->Lifes[j].Output[1], abs(gpuRef->Fitness[1] - gpuRef->Lifes[j].Output[1]), BestFit[1]);
//                                printf(" *** BestFit[2] = %ld - %ld = %ld vs CurBestFit %ld", gpuRef->Fitness[2], gpuRef->Lifes[j].Output[2], abs(gpuRef->Fitness[2] - gpuRef->Lifes[j].Output[2]), BestFit[2]);
//			if (abs(gpuRef->Fitness[0] - gpuRef->Lifes[j].Output[0]) < BestFit[0] && abs(gpuRef->Fitness[1] - gpuRef->Lifes[j].Output[1]) < BestFit[1] && abs(gpuRef->Fitness[2] - gpuRef->Lifes[j].Output[2]) < BestFit[2]) {
			if (abs(gpuRef->Fitness[0] - gpuRef->Lifes[j].Output[0]) + abs(gpuRef->Fitness[1] - gpuRef->Lifes[j].Output[1]) + abs(gpuRef->Fitness[2] - gpuRef->Lifes[j].Output[2]) < BestFit[0] + BestFit[1] + BestFit[2]) {
				printf("\n *** BestFit vs NewBestFit : %ld# vs %ld#", BestFit[0] + BestFit[1] + BestFit[2], abs(gpuRef->Fitness[0] - gpuRef->Lifes[j].Output[0]) + abs(gpuRef->Fitness[1] - gpuRef->Lifes[j].Output[1]) + abs(gpuRef->Fitness[2] - gpuRef->Lifes[j].Output[2]));
				BestFit[0] = abs(gpuRef->Fitness[0] - gpuRef->Lifes[j].Output[0]);
                                BestFit[1] = abs(gpuRef->Fitness[1] - gpuRef->Lifes[j].Output[1]);
                                BestFit[2] = abs(gpuRef->Fitness[2] - gpuRef->Lifes[j].Output[2]);
				BestFitNo = j;
//				printf(" *** BestFit[0] = %ld - %ld = %ld", gpuRef->Lifes[j].Output[0], gpuRef->Fitness[0], BestFit[0]);
				if (BestFit[0] == 0 && BestFit[1] == 0 && BestFit[2] == 0) {
					PrintLife(&gpuRef->Lifes[j]);
	                                printf(" *** BestFit[0] = %ld - %ld = %ld vs CurBestFit %ld", gpuRef->Fitness[0], gpuRef->Lifes[j].Output[0], abs(gpuRef->Fitness[0] - gpuRef->Lifes[j].Output[0]), BestFit[0]);
		                        printf(" *** BestFit[1] = %ld - %ld = %ld vs CurBestFit %ld", gpuRef->Fitness[1], gpuRef->Lifes[j].Output[1], abs(gpuRef->Fitness[1] - gpuRef->Lifes[j].Output[1]), BestFit[1]);
			                printf(" *** BestFit[2] = %ld - %ld = %ld vs CurBestFit %ld", gpuRef->Fitness[2], gpuRef->Lifes[j].Output[2], abs(gpuRef->Fitness[2] - gpuRef->Lifes[j].Output[2]), BestFit[2]);
					break;
				}
			}
			}
		}
		int p = 0;
		for (int n = 0; n < range_rand(10, 30); n++) 
		{
			for (p = p; p < gpuRef->NumOfLifes; p++) if (gpuRef->Lifes[p].TimeLeft <= 0 || gpuRef->Lifes[p].Energy <= 0) break;
			printf("\n ** Slot for new life is %i", p);
                        PrintLife(&gpuRef->Lifes[p]);
			gpuRef->Lifes[p].Energy = 29;
                        gpuRef->Lifes[p].TimeLeft = 29;
                        gpuRef->Lifes[p].Velocity = 1;
			if (range_rand(1, 4) == 1) {
				gpuRef->Lifes[p].codelen = gpuRef->Lifes[BestFitNo].codelen / 2;
			} else if (range_rand(1, 4) == 1) {
				gpuRef->Lifes[p].codelen = gpuRef->Lifes[BestFitNo].codelen * 2;
				if (gpuRef->Lifes[p].codelen > 49) gpuRef->Lifes[p].codelen = 49;
			} else {
				gpuRef->Lifes[p].codelen = gpuRef->Lifes[BestFitNo].codelen;
			}
                        gpuRef->Lifes[p].codepos = 0;
		        for (int k = 0; k < gpuRef->Lifes[BestFitNo].codelen; k++) {
				if (range_rand(1, 2) == 1) {
	                                gpuRef->Lifes[p].Code[k] = range_rand(1, 9);		
				}
				else { 
					gpuRef->Lifes[p].Code[k] = gpuRef->Lifes[BestFitNo].Code[k];
				}
			}
			gpuRef->Lifes[p].Ref = p;
                        gpuRef->Lifes[p].ParentRef = gpuRef->Lifes[BestFitNo].Ref;
			gpuRef->Lifes[p].Output[0] = 0;
                        gpuRef->Lifes[p].Output[1] = 0;
                        gpuRef->Lifes[p].Output[2] = 0;
                        PrintLife(&gpuRef->Lifes[BestFitNo]);
//			printf(" %ld#%ld#%ld#%ld", BestFit[0], BestFit[1], BestFit[2], BestFit[0] + BestFit[1] + BestFit[2]);
//                        printf("\n %ld#", BestFit[0] + BestFit[1] + BestFit[2]);

//				printf("\n *** Parent: %i", j);
//                        printf("\n ***LIFE IS BORN from %i", gpuRef->Lifes[BestFitNo].Ref);
                        PrintLife(&gpuRef->Lifes[p]);
                        if (p >= gpuRef->NumOfLifes) gpuRef->NumOfLifes++;
		}
                PrintWorld(gpuRef);
		// copy data from host to device
//	        CHECK(cudaMemcpy(d_A, gpuRef, nBytes, cudaMemcpyHostToDevice));
		if (BestFit[0] == 0 && BestFit[1] == 0 && BestFit[2] == 0) break;
	} while (gpuRef->Energy > 0 && gpuRef->TimeLeft > 0);

//	CHECK(cudaDeviceSynchronize());
//	CHECK(cudaMemcpy(gpuRef, d_A, nBytes, cudaMemcpyDeviceToHost));

	PrintWorld(gpuRef);

//	CHECK(cudaGetLastError());;

	printf("\n\n ### THE WINNER IS %i", BestFitNo);
	PrintLife(&gpuRef->Lifes[BestFitNo]);

/*	printf("\n\n *** Admire the winners genomes history:");
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
	}*/
/*        printf("\n\n *** Admire the winners story:");
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
*/
	printf("\n");
}
