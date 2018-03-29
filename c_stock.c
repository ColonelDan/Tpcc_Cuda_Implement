#include <stdio.h>  
#include <string.h>  
#include <stdlib.h>

#define STOCK_RECORD_MAX_SIZE	300010 
#define STOCK_RECORD_MAX_LENGTH 1000
#include "tpcc_table.h"
int get_stock(struct stock *p_stock_arr){ //?????????????????????????????????
	char file_name[] = "./csv/c_stock.csv";  //?????????????????????????????????
    FILE *fp;  
    fp = fopen(file_name, "r");  
      
    if (!fp) {  
        fprintf(stderr, "c stock failed to open file for reading\n");  
        return -1;  
    }
    
    char c;
    int i=0;
    int index=0;
    
    char **record_arr;
    record_arr=malloc(STOCK_RECORD_MAX_SIZE*sizeof(char *));
    record_arr[index]=malloc(STOCK_RECORD_MAX_LENGTH*sizeof(char));
    
    while(1){
      c=fgetc(fp);
      if(c==EOF){
        break;
      }
      if(c=='\n'){
        record_arr[index][i++]='\0';
        index++;
        record_arr[index]=malloc(STOCK_RECORD_MAX_LENGTH*sizeof(char));
        i=0;
      }else{
        if(c!='"'){
          record_arr[index][i++]=c;
        }
      }
    }

   //*p_stock_arr=(struct stock *)malloc(index*sizeof(struct stock));//?????????????????????????????????
    
    for(i=1;i<index;i++){
      //printf("%s\n",record_arr[i]);
      char *token;
      
      token=strtok(record_arr[i],",");
      (p_stock_arr)[i].S_I_ID=atol(token);//?????????????????????????????????
      
      token=strtok(NULL, ",");
      (p_stock_arr)[i].S_W_ID=atol(token);//?????????????????????????????????

	    token=strtok(NULL, ",");
      (p_stock_arr)[i].S_QUANTITY=atof(token);//?????????????????????????????????
      
      token=strtok(NULL, ",");
      strcpy((p_stock_arr)[i].S_DIST_01,token);
	  
      token=strtok(NULL, ",");
      strcpy((p_stock_arr)[i].S_DIST_02,token);

      token=strtok(NULL, ",");
      strcpy((p_stock_arr)[i].S_DIST_03,token);

      token=strtok(NULL, ",");
      strcpy((p_stock_arr)[i].S_DIST_04,token);

      token=strtok(NULL, ",");
      strcpy((p_stock_arr)[i].S_DIST_05,token);

      token=strtok(NULL, ",");
      strcpy((p_stock_arr)[i].S_DIST_06,token);

      token=strtok(NULL, ",");
      strcpy((p_stock_arr)[i].S_DIST_07,token);

      token=strtok(NULL, ",");
      strcpy((p_stock_arr)[i].S_DIST_08,token);

      token=strtok(NULL, ",");
      strcpy((p_stock_arr)[i].S_DIST_09,token);

      token=strtok(NULL, ",");
      strcpy((p_stock_arr)[i].S_DIST_10,token);

      token=strtok(NULL, ",");
      (p_stock_arr)[i].S_YTD=atof(token);//?????????????????????????????????
      
      token=strtok(NULL, ",");
      (p_stock_arr)[i].S_ORDER_CNT=atof(token);//?????????????????????????????????
      

      token=strtok(NULL, ",");
      (p_stock_arr)[i].S_REMOTE_CNT=atof(token);//?????????????????????????????????
      
      
      token=strtok(NULL, ",");
      
	free(record_arr[i]);
      //printf("!!!!!!!!!!!!!!!!\n%ld\n%s\n%s\n%s\n%s\n%s\n%s\n%lf\n%lf\n",stock_arr[i].W_ID,stock_arr[i].W_NAME,
	  //		stock_arr[i].W_STREET_1,stock_arr[i].W_STREET_2,stock_arr[i].W_CITY,stock_arr[i].W_STATE,
	  //		stock_arr[i].W_ZIP,stock_arr[i].W_TAX,stock_arr[i].W_YTD);
    }
     free(record_arr);
    fclose (fp);  
    
    return index;
}
/*
int main(int argc, const char * argv[]) {  
    
    struct stock *stock_arr;//?????????????????????????????????
    int index=get_stock(&stock_arr);//?????????????????????????????????
    int i;
    for(i=1;i<index;i++){ //?????????????????????????????????
		printf("!!!!!!!!!!!!!!!!\n%ld\n %ld\n %lf\n %s\n %s\n %s\n %s\n %s\n %s\n %s\n %s\n %s\n %s\n %lf\n %lf\n %lf\n",
        stock_arr[i].S_I_ID,
        stock_arr[i].S_W_ID,
        stock_arr[i].S_QUANTITY,
        stock_arr[i].S_DIST_01,
        stock_arr[i].S_DIST_02,
        stock_arr[i].S_DIST_03,
        stock_arr[i].S_DIST_04,
        stock_arr[i].S_DIST_05,
        stock_arr[i].S_DIST_06,
        stock_arr[i].S_DIST_07,
        stock_arr[i].S_DIST_08,
        stock_arr[i].S_DIST_09,
        stock_arr[i].S_DIST_10,
        stock_arr[i].S_YTD,
        stock_arr[i].S_ORDER_CNT,
        stock_arr[i].S_REMOTE_CNT);
    }
      
    return 0;  
} */ 
