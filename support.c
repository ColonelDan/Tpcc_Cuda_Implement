//
// desc: supply the random function to statistics_generator
// date: 2018-3-27
// author: Xie Shangwei
//
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#include "support.h"

//set seed for random function.
void set_seed(int seed)
{
	srand(seed);
}	

// generate a int number bettween min and max.
int random_number(int min, int max)
{
	return min + (rand() % (max - min)+1);
}
