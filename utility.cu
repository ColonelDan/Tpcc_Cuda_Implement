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

//str1=str1+str2, the limit is the size of str1(not length)
__device__
void d_str_append(char *str1,char *str2,int limit){
	int str1_length=d_strlen(str1);
	int str1_index=str1_length;
	int str2_index=0;
	while(str1_index!=limit-1 && str2[str2_index]!='\0'){
		str1[str1_index]=str2[str2_index];
		str1_index++;
		str2_index++;
	}
	str1[str1_index]='\0';
}

//is same to ltoa but not return result, as an alternative, the result is to be a parameter of the function
__device__
void d_ltoa(long n,char *s){
	int i,count,sign;
	if((sign=n)<0){//记录符号
		n=-n;//使n成为正数
	}
	count=0;
	do{
		s[count++]=n%10+'0';//取下一个数字
	}while ((n/=10)>0);//删除该数字
	if(sign<0){
		s[count++]='-';
	}
	char c;
	for(i=0;i<count/2;i++){//生成数字是逆序的，所以要头尾置换
		c=s[i];
		s[i]=s[count-1-i];
		s[count-1-i]=c;
	}
	s[count]='\0';
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
