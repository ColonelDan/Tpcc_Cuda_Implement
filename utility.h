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

__device__
void d_str_append(char *str1,char *str2,int limit);

__device__
void d_ltoa(long n,char *s);

__device__
unsigned int d_random(int min, int max);
#endif
