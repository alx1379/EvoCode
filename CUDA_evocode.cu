#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>
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
};

typedef struct Creature Creature;

// Structure for World
struct World {
	int Energy;
	int TimeLeft;
	struct Creature Lifes[5000];
	int NumOfLifes;
	int AliveCreatures;
	int MaxEnergy;
};

typedef struct World World;

// Return rnadom number between min and max 
int range_rand(int min_num, int max_num) {

	if(min_num > max_num) {
		fprintf(stderr, "min_num %i is greater than max_num %i!\n", min_num, max_num); 
	}
	// Return random number in range
	return min_num + (rand() % (max_num - min_num));
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
        printf("\n\rFunction:PrintLife Energy:%i Velocity:%i TimeLeft:%i codelen:%i codepos: %i parentref: %i ref: %i \nCode:",
        Life->Energy, Life->Velocity, Life->TimeLeft, Life->codelen, Life->codepos, Life->ParentRef, Life->Ref);

        for (int k = 0; k < Life->codelen; k++) printf("%i", Life->Code[k]);
}

Creature InitLife(World *Iteration, int ParRef)
{
	Creature Life;

	Life.Energy = Iteration->MaxEnergy - AllEnergy(Iteration); 
	if (Life.Energy > 5) Life.Energy = 5;

	Life.Velocity = 1;
	Life.TimeLeft = 5;
	Life.codelen = range_rand(5, 10);
	Life.codepos = 0;
	for (int i = 0; i < Life.codelen; i++) Life.Code[i] = range_rand(1, 5);
//	Life.Ref = range_rand(1, 65535);
	Life.Ref = Iteration->NumOfLifes;
	if (ParRef == 0) printf("\n *** REF IS BROKEN");
	Life.ParentRef = ParRef;

//	printf("\n LIFE BORN");
//	PrintLife(Life);

	Iteration->Lifes[Iteration->NumOfLifes] = Life;
	Iteration->NumOfLifes++;

	return(Life);
}

int RunLife(World *Iteration, Creature *Life)
{
	struct Creature New; // Make a child with random permutation

	int NewRef = Life->Ref;

	if (IsAlive(Life))
	{
		PrintLife(Life);
		Iteration->AliveCreatures++;

		// run code "Velocity" number of times     
		for (int i = 0; i < Life->Velocity; i++) {
		int k;
		switch(Life->Code[Life->codepos])
		{
			case 1: Life->Energy += 2; // Feed
				break;
			case 2: if (Life->codelen > 3) Life->codelen -= range_rand(1, Life->codelen/2); // Half genome
				break;
			case 3: 
				for (k = 0; k < Life->codelen-1; k++) // Learn from other creature
				Life->Code[Life->codelen+k] = Life->Code[k+1];
				Life->codelen = Life->codelen+k;
				break;
			case 4: New = InitLife(Iteration, Life->Ref);
				if (New.codelen < 9 && range_rand(1, 3) == 1) { // 1/3 likelyhood of permutation for short genome
					New.Code[New.codelen] = range_rand(1, 5); // add new code at the end
					New.codelen++;
				} else {
					New.Code[range_rand(1, New.codelen-1)] = range_rand(1, 5); // 100% likelyhood of permutation for long genome and short that out of 1/3
				}
				NewRef = New.Ref;
				break;
			case 5: Life->Velocity++;
				break;
		}
		Life->codepos++;
		}
		Life->TimeLeft--;
		Life->Energy--;
	}
	return(NewRef);
}

World InitWorld(void)
{
        World Iteration;

        Iteration.Energy = 0;
        Iteration.TimeLeft = 100;
	Iteration.NumOfLifes = 0;
	Iteration.MaxEnergy = 50;
	Iteration.AliveCreatures = 0;
	InitLife(&Iteration, 0);
	InitLife(&Iteration, 0);

	return(Iteration);
}

void PrintWorld(World *Iteration)
{
	printf("\n\r------------------------\n\rFunction:PrintWorld TimeLeft:%i Energy:%i NumOfLifes:%i AliveCreatures: %i", 
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
	for (int i = 0; i < Iteration->NumOfLifes; i++) 
	{
//		printf("\n Life number: %i", i);
		int CurRef = RunLife(Iteration, &Iteration->Lifes[i]);
	}

	if (Iteration->TimeLeft > 0 && Iteration->Energy > 0) RunWorld(Iteration);
}

__global__ void helloFromGPU(void)
{
  printf("Hello World from GPU thread");
}

int main(void)
{
        time_t t;

        // Intializes random number generator
        srand((unsigned) time(&t));

	helloFromGPU <<<1, 512>>>();
	cudaDeviceSynchronize();
	//  cudaDeviceReset();

	World NewWorld = InitWorld();
//	RunWorld <<<1, 10>>>(&NewWorld);
	RunWorld(&NewWorld);

	printf("\n\n *** Admire the winners genomes history:");
        for (int i = 0; i < NewWorld.NumOfLifes; i++)
	{
		Creature Parent = NewWorld.Lifes[i];
		if (IsAlive(&Parent)) {
			PrintLife(&Parent);
			while (Parent.ParentRef > 0) {
				Parent = FindCreature(&NewWorld, Parent.ParentRef);
				printf("->");
				PrintCode(&Parent);
//				PrintLife(Parent);
			}
		}
	}
        printf("\n\n *** Admire the winners story:");
        for (int i = 0; i < NewWorld.NumOfLifes; i++)
        {
                Creature Parent = NewWorld.Lifes[i];
                if (IsAlive(&Parent)) {
//                        PrintLife(Parent);
			printf("\n");
                        while (Parent.ParentRef > 0) {
				printf("%i->", Parent.Ref);
                                Parent = FindCreature(&NewWorld, Parent.ParentRef);
//                              PrintLife(Parent);
                        }
                }
        }


	printf("\n");
}
