
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// Structure for creature
struct Creature {
	int Energy; 
	int Velocity;
	int TimeLeft;
	int Code[100];
	int codelen, codepos;
	int ParentRef;
};

// Structure for World
struct World {
	int Energy;
	int TimeLeft;
	Creature Lifes[5000];
	int NumOfLifes;
};

// Return rnadom number between min and max 
int range_rand(int min_num, int max_num) {

	time_t t;

	if(min_num > max_num) {
		fprintf(stderr, "min_num %i is greater than max_num %i!\n", min_num, max_num); 
	}
	// Intializes random number generator 
	srand((unsigned) time(&t));
	// Return random number in range
	return min_num + (rand() % (max_num - min_num));
} 

// Calculate All World Energy  
int AllEnergy(World &Iteration)
{
	int totalenergy = 0;
	for (int i = 0; i < Iteration.NumOfLifes; i++)
	{
		if (Iteration.Lifes[i].TimeLeft > 0)
		totalenergy += Iteration.Lifes[i].Energy;
	}
	return(totalenergy);
}

Creature InitLife(void)
{
	Creature Life;

	Life.Energy = 5;
	Life.Velocity = 1;
	Life.TimeLeft = 5;
	Life.codelen = range_rand(5, 10);
	Life.codepos = 0;
	for (int i = 0; i < Life.codelen; i++) Life.Code[i] = range_rand(1, 5);
	Life.ParentRef = 0;

	return(Life);
}

void PrintLife(Creature &Life)
{
        printf("\n\rFunction:PrintLife Energy:%i Velocity:%i TimeLeft:%i codelen:%i codepos: %i parentref: %i", 
	Life.Energy, Life.Velocity, Life.TimeLeft, Life.codelen, Life.codepos, Life.ParentRef);
}

void RunLife(Creature &Life)
{

}

World InitWorld(void)
{
        World Iteration;

        Iteration.Energy = 0;
        Iteration.TimeLeft = 100;
	Iteration.NumOfLifes = 0;
	Iteration.Lifes[0] = InitLife();
        Iteration.Lifes[1] = InitLife();
	Iteration.NumOfLifes = 2;

	return(Iteration);
}

void PrintWorld(World &Iteration)
{
	printf("\n\r------------------------\n\rFunction:PrintWorld TimeLeft:%i Energy:%i NumOfLifes:%i", Iteration.TimeLeft, Iteration.Energy, Iteration.NumOfLifes);
}

// Run World Iteration
void RunWorld(World &Iteration)
{
	Iteration.Energy = AllEnergy(Iteration);
	Iteration.TimeLeft--;

	PrintWorld(Iteration);

	if (Iteration.TimeLeft > 0 && Iteration.Energy > 0) RunWorld(Iteration);
}

int main(void)
{
	World NewWorld = InitWorld();
	RunWorld(NewWorld);
}
