#include <stdio.h>  
#include <string.h>  
#include <stdlib.h>

#define IT_MAX_SIZE 100010 
#define IT_MAX_LENGTH 1000
#include <stdlib.h>
#include "tpcc_table.h"
int get_item(struct item *p_item_arr){ //?????????????????????????????????
	char file_name[] = "./csv/c_item.csv";  //?????????????????????????????????
    FILE *fp;  
    fp = fopen(file_name, "r");  
      
    if (!fp) {  
        fprintf(stderr, "failed to open file for reading\n");  
        return -1;  
    }
    
    char c;
    int i=0;
    int index=0;
    
    char **record_arr;
    record_arr=(char **)malloc(IT_MAX_SIZE*sizeof(char *));
    record_arr[index]=(char *)malloc(IT_MAX_LENGTH*sizeof(char));
    
    while(1){
      c=fgetc(fp);
      if(c==EOF){
        break;
      }
      if(c=='\n'){
        record_arr[index][i++]='\0';
        index++;
        record_arr[index]=(char *)malloc(IT_MAX_LENGTH*sizeof(char));
        i=0;
      }else{
        if(c!='"'){
          record_arr[index][i++]=c;
        }
      }
    }

//    *p_item_arr=(struct item *)malloc((index-1)*sizeof(struct item));//?????????????????????????????????
    
    for(i=1;i<index;i++){
      //printf("%s\n",record_arr[i]);
      char *token;
      
      token=strtok(record_arr[i],",");
      (p_item_arr)[i-1].I_ID=atol(token);//?????????????????????????????????
      //if(i<20) printf("I_ID: %ld, ", p_item_arr[i-1].I_ID);
      
      token=strtok(NULL, ",");
      (p_item_arr)[i-1].I_IM_ID=atol(token);//?????????????????????????????????
      //if(i<20) printf("I_IM_ID: %ld, ", p_item_arr[i-1].I_IM_ID);
      token=strtok(NULL, ",");
      strcpy((p_item_arr)[i-1].I_NAME,token);
      //if(i<20) printf("I_NAME: %s, ", p_item_arr[i-1].I_NAME);

      
	    token=strtok(NULL, ",");
      (p_item_arr)[i-1].I_PRICE=atof(token);//
      //if(i<20) printf("I_PRICE: %lf, ", p_item_arr[i-1].I_PRICE);
	  
      token=strtok(NULL, ",");
      strcpy((p_item_arr)[i-1].I_DATA,token);
      //if(i<20) printf("I_DATA: %s\n", p_item_arr[i-1].I_DATA);
      
      token=strtok(NULL, ",");
     	free(record_arr[i-1]); 
      //printf("!!!!!!!!!!!!!!!!\n%ld\n%s\n%s\n%s\n%s\n%s\n%s\n%lf\n%lf\n",item_arr[i].W_ID,item_arr[i].W_NAME,
	  //		item_arr[i].W_STREET_1,item_arr[i].W_STREET_2,item_arr[i].W_CITY,item_arr[i].W_STATE,
	  //		item_arr[i].W_ZIP,item_arr[i].W_TAX,item_arr[i].W_YTD);
    }
	free(record_arr);
     
    fclose (fp);  
    
    return index-1;
}
/*
int main(int argc, const char * argv[]) {  
    
    struct item *item_arr;//?????????????????????????????????
    int index=get_item(&item_arr);//?????????????????????????????????
    int i;
    for(i=1;i<index;i++){ //?????????????????????????????????
		printf("!!!!!!!!!!!!!!!!\n%ld\n %ld\n %s\n %lf\n %s\n",
        item_arr[i].I_ID,
        item_arr[i].I_IM_ID,
        item_arr[i].I_NAME,
        item_arr[i].I_PRICE,
        item_arr[i].I_DATA);
    }
    return 0;  
} */ 
