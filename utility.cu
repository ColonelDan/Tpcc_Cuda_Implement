//
//  	desc: tpcc benchmark implementation in GPU
//	date: 2018-3-27
//	author: Xie Shangwei
//

#include "utility.h"
__device__
void  d_memcpy(void *des, void *src, int size){
	int i ;
	for(i = 0; i< size; i++){
		((char *)des)[i] = ((char *)src)[i];
	} 
}

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

__device__
int d_strlen(char *des){
	int i = 0;
	while(des[i] != 0)
		i++;
	return i;
}
