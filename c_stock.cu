#include <stdio.h>  
#include <string.h>  
#include <stdlib.h>

#define STOCK_RECORD_MAX_SIZE	300010 
#define STOCK_RECORD_MAX_LENGTH 1000
#include "tpcc_table.h"
int get_stock(struct stock *p_stock_arr){ //
	char file_name[] = "./csv/c_stock.csv";  //
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
    record_arr=(char **)malloc(STOCK_RECORD_MAX_SIZE*sizeof(char *));
    record_arr[index]=(char *)malloc(STOCK_RECORD_MAX_LENGTH*sizeof(char));
    
    while(1){
      c=fgetc(fp);
      if(c==EOF){
        break;
      }
      if(c=='\n'){
        record_arr[index][i++]='\0';
        index++;
        record_arr[index]=(char *)malloc(STOCK_RECORD_MAX_LENGTH*sizeof(char));
        i=0;
      }else{
        if(c!='"'){
          record_arr[index][i++]=c;
        }
      }
    }
    
    for(i=1;i<index;i++){
      char *token;
      token=strtok(record_arr[i],",");
      (p_stock_arr)[i].S_I_ID=atol(token);
     
      token=strtok(NULL, ",");
      (p_stock_arr)[i].S_W_ID=atol(token);//
	    token=strtok(NULL, ",");
      (p_stock_arr)[i].S_QUANTITY=atof(token);//
      
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
      
      
	free(record_arr[i]);
    }
    free(record_arr);
    fclose (fp);  
    return index;
}
