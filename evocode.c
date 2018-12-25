#include <iostream>
#include <stdio.h>
#include <cstdlib>
#include <string.h>
#include <ctime>
 
// World Energy and time limit
const int WorldEnergy = 50;
const int MaxTime = 100;
 
// Structure for creature
struct Creature {
    int Energy; 
    int Velocity;
    int TimeLeft;
    int Code[100];
    int codelen, codepos;
    int ParentRef;
};
  
// All creatures
Creature Lifes[5000];
// number of life creatures
int NumOfLifes = 0;


// Calculate All World Energy  
int AllEnergy(void)
{
  int totalenergy = 0;
  for (int i=0;i<NumOfLifes;i++)
    {
    if (Lifes[i].TimeLeft > 0)
    totalenergy += Lifes[i].Energy;
    }
  return(totalenergy);
}

// Return rnadom number between min and max 
int range_rand(int min_num, int max_num) {
    if(min_num >= max_num) {
        fprintf(stderr, "min_num is greater or equal than max_num!\n"); 
    }
    return min_num + (rand() % (max_num - min_num));
} 
 
// Create new creature
struct Creature *InitLife(int num) 
{
    struct Creature *X;
     
    // create new creature in X, get it from last existing one
    X = &Lifes[NumOfLifes];

    // new life from scratch
    if (num < 0)
    {
        X->Energy = 5;
        X->Velocity = 1;
        X->TimeLeft = 5;
        X->Code[0] = 1;
        X->Code[1] = 4;
        X->Code[2] = 5;
        X->codelen = 3;
        X->codepos = 0;
    } else { // create child life from existing parent
	// reset world dependand values
        X->Energy = 5;
        X->Velocity = 1;
        X->TimeLeft = 5;
        // copy code/genome of parent
        for (int i = 0; i < Lifes[num].codelen; i++)
        {
            X->Code[i] = Lifes[num].Code[i];
        }
        X->codelen = Lifes[num].codelen;
        X->codepos = 0;
    }
     
    // Increase number of lifes
    NumOfLifes++; 
     
    int TotalE = AllEnergy();
    
    // if WorldEnergy exceeds the limit, deduct difference from current new life
    if (TotalE > WorldEnergy) X->Energy -= (TotalE - WorldEnergy);
     
    return(X);
}
  
// Run code iterations of Life with num number
// return vals:
// 1 - Feed (get +2 energy)
// 2 - Survive (half my genome)
// 3 - Expand (learn from others)
// 4 - Self-repro (copy paste itself with one random permutation)
// 5 - Increase Velocity
int RunCode(int num)
{
     
    struct Creature *X = &Lifes[num];
    struct Creature *Y = &Lifes[NumOfLifes-1];

    // find some neighbourhood creature that is alive and first code bit is not equal to creature running
    for (int i = NumOfLifes-1; i >= 0; i--)              {
    if (Y->Energy > 0 && Y->TimeLeft > 0 && Y->Code[0] != X->Code[0]) {
        break;
    }
    Y = &Lifes[i];
}

	// run code "Velocity" number of times     
    for (int i = 0; i < X->Velocity; i++) {
    switch(X->Code[X->codepos])
    {
        case 1: X->Energy += 2; // Feed
        	break;
        case 2: X->codelen -= range_rand(1, X->codelen/2); // Half genome
	        break;
        case 3: int k;
		for (k = 0; k < Y->codelen-1; k++) // Learn from other creature
		X->Code[X->codelen+k] = Y->Code[k+1];
	        X->codelen = X->codelen+k;
        	break;
        case 4: struct Creature *New; // Make a child with random permutation
		New = InitLife(num);
	        if (New->codelen < 9 && range_rand(1, 3) == 1) { // 1/3 likelyhood of permutation for short genome
		        New->Code[New->codelen] = range_rand(1, 9); // add new code at the end
		        New->codelen++;
		} else {
			New->Code[range_rand(0, New->codelen-1)] = range_rand(1, 9); // 100% likelyhood of permutation for long genome and short that out of 1/3
		}
	        New->ParentRef = num; // make parent reference
	        break;
	case 5:
	        X->Velocity++;
	        break;
    }
        X->Energy -= 1; // decrease energy for  any code run
        X->codepos++; // move current code position in genome
        if (X->codepos >= X->codelen) X->codepos = 0; // return code position to 0 if end is reached
    }
    X->TimeLeft -= 1; // decrease time left, clock it ticking )
    int TotalE = AllEnergy();
    // if WorldEnergy exceeds the limit, deduct difference from current new life
    if (TotalE > WorldEnergy) X->Energy -= (TotalE - WorldEnergy);
    // Die if time is over )
    if (X->TimeLeft < 1) X->Energy = 0;
}
  
int main()
{
    struct Creature A;
    struct Creature *B;
    // create at least two creatures
    B = InitLife(-1);
    InitLife(-1);
    
//  int newarr [] = {9,1,1,5,1,4,4,1,3,4,3,1,1,5,3,4,3,2,5,2,1,4};
    int newarr [] = {0, 9,9,1,4,1,4};
    
    // insert start code to first life
    int len = sizeof(newarr)/sizeof(int);
    for (int i = 0; i < len; i++) {
        Lifes[0].Code[i] = newarr[i];
    }
    Lifes[0].codelen = len;  

 //   int newarr1 [] = {8,1,4,5,1,4,4,1,3,4,3,1,1,5,3};
    int newarr1 [] = {6, 8, 8, 1,4,1};

    // insert start code to second life
    len = sizeof(newarr1)/sizeof(int);
    for (int i = 0; i < len; i++) {
        Lifes[1].Code[i] = newarr1[i];
    }
    Lifes[1].codelen = len;  

    // start the Wolrd spinning
    std::cout << "Hello world!";
    for (int i = 0; i < MaxTime; i++)
    {
        printf("\n\r------------------------\n\rWorld iteration %i", i);
         
	// Go through existing creatures and run each one
        for (int j = 0; j < NumOfLifes; j++)
        {
            A = Lifes[j];
            B = &Lifes[j];
         
	if (B->TimeLeft < 1) B->Energy = 0; // die if time has come )
        if (A.Energy > 0 && A.TimeLeft > 0) 
        {
		printf("\nCreature %i->%i E:%i T:%i Pos:%i Vel:%i \n", A.ParentRef, j, A.Energy, A.TimeLeft, A.codepos, A.Velocity);
	        if (i < MaxTime) {
           	for (int k = 0; k < A.codelen; k++)
		        printf("%i", A.Code[k]);
	        }
        	RunCode(j);
        }
 
        }
        printf("\nTotal energy: %i", AllEnergy());
	// quit if everyone has died
	if (AllEnergy() < 1) break;
    }
}
