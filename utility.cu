//
//  desc: tpcc benchmark implementation in GPU
//	date: 2018-3-27
//	author: Xie Shangwei
//
#include <time.h>

#include <cuda_runtime.h>
#include <curand_kernel.h>

#include "utility.h"

// is same to memcpy.
__device__
void  d_memcpy(void *des, void *src, int size){
	int i ;
	for(i = 0; i< size; i++){
		((char *)des)[i] = ((char *)src)[i];
	} 
}


// is same to strcmp.
__device__
int d_strcmp(char *des, char *src){
	int i=1;
	while(des[i-1] == src[i-1]){
		if(des[i-1] == '\0')	
			return 0;
		else{
			i++;
		}
	}
	return i;
}


//get the des string length.
__device__
int d_strlen(char *des){
	int i = 0;
	while(des[i] != 0)
		i++;
	return i;
}

//generate randon number in [min, max)
__device__
unsigned int d_random(int min, int max){
	curandState state;
	int id = threadIdx.x;
	time_t t = clock();
	curand_init( (unsigned int)t, id, 0, &state);
	return curand(&state)%(max-min)+min;
}
