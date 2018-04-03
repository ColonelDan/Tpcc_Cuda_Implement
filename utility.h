//
//  	desc: some utility prgrome.
//	date: 2018-4-3
//	author: Xie Shangwei
//


#ifndef UTILITY_H
#define UTILITY_H

__device__ 
void d_memcpy(void *des, void *src, int size);

__device__
int d_strcmp(char *des, char *src);

__device__
int d_strlen(char *des);
#endif
