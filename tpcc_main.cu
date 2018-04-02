//
//  	desc: tpcc benchmark implementation in GPU
//	date: 2018-3-27
//	author: Xie Shangwei
//


#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>

#include <cuda_runtime.h>

#include "tpcc_table.h"

int get_item(struct item *item_arr);
int get_warehouse(struct warehouse *warehouse_arr);
int get_order(struct order *order);
int get_customer(struct customer *c);
int get_new_order(struct new_order *n);
int get_order_line(struct order_line *o);
int get_district(struct district *d);
int get_stock(struct stock *s);
int get_history(struct history *h);


//get 9 tables.
struct warehouse h_warehouses[MAX_WAREHOUSE_NUM];
struct district h_districts[MAX_DISTRICT_NUM];
struct customer h_customers[MAX_CUSTOMER_NUM];
struct history h_historys[MAX_HISTORY_NUM];
struct new_order h_neworders[MAX_NEWORDER_NUM];
struct order h_orders[MAX_ORDER_NUM];
struct order_line h_orderlines[MAX_ORDER_LINE_NUM];
struct stock h_stocks[MAX_STOCK_NUM];
struct item h_items[MAX_ITEM_NUM];

//tables's slot flag, mark the slot is used or not.
char  h_warehouses_flag[MAX_WAREHOUSE_NUM];
char  h_districts_flag[MAX_DISTRICT_NUM];   
char  h_customers_flag[MAX_CUSTOMER_NUM];   
char  h_historys_flag[MAX_HISTORY_NUM];      
char  h_neworders_flag[MAX_NEWORDER_NUM];  
char  h_orders_flag[MAX_ORDER_NUM];            
char  h_orderlines_flag[MAX_ORDER_LINE_NUM];  
char  h_items_flag[MAX_ITEM_NUM];               
char  h_stocks_flag[MAX_STOCK_NUM];

struct warehouse *h_d_warehouses;
struct district *h_d_districts;
struct customer *h_d_customers;
struct history *h_d_historys;
struct new_order *h_d_new_orders;
struct order *h_d_orders;
struct orderline *h_d_orderlines;
struct item *h_d_items;
struct stock *h_d_stocks;

char *h_d_warehouses_flag;
char *h_d_districts_flag;
char *h_d_customers_flag;
char *h_d_historys_flag;
char *h_d_new_orders_flag;
char *h_d_orders_flag;
char *h_d_orderlines_flag;
char *h_d_items_flag;
char *h_d_stocks_flag;

__device__ char *d_warehouses_flag;
__device__ char *d_districts_flag;
__device__ char *d_customers_flag;
__device__ char *d_historys_flag;
__device__ char *d_new_orders_flag;
__device__ char *d_orders_flag;
__device__ char *d_orderlines_flag;
__device__ char *d_items_flag;
__device__ char *d_stocks_flag;

__device__ struct warehouse *d_warehouses;
__device__ struct district *d_districts;
__device__ struct customer *d_customers;
__device__ struct history *d_historys;
__device__ struct new_order *d_new_orders;
__device__ struct order *d_orders;
__device__ struct orderline *d_orderlines;
__device__ struct item *d_items;
__device__ struct stock *d_stocks;

__device__ 
void d_memcpy(void *des, void *src, int size);

__device__
int d_strcmp(char *des, char *src);

__device__
void insert_rec(int table_type, void *record);

__device__
void delete_rec(int table_type, int record_id);

__device__
void update(int table_type, void *record);

__device__
void *get(int table_type, int rid);

__device__
void get_table_head(int table_type, void **table_head);

__device__
void get_flag_head(int table_type, char **flag_head);

__device__
void get_table_size(int table_type, int *table_size);

__device__
void get_record_size(int table_type, int *record_size);

__device__
int table_scan(int table_type, int attr_type, int attr_size,  int attr_offset, int op , void *value, int rid);

//
// desc : get a free slot id from the table.
// intput : slot flag arry , table type.
// output : the slot id or -1 if there is no
//          free slot exists.
//
__device__
int get_free_slot(char *slot_flag_arry, int table_type);

//
// desc : mark the slot as used by slot id.
//
__device__
void mark_slot_used(char *slot_flag_array, int slot_id);

//
// desc : mark the slot as freed by slot id.
//
__device__
void mark_slot_free(char *slot_flag_array, int slot_id);

__global__
void test_table_scan(struct warehouse *h_d_warehouses, char *h_d_warehouses_flag){
	printf("into kernel\n");
	d_warehouses = h_d_warehouses;
	d_warehouses_flag = h_d_warehouses_flag;
	
	int rid = 0;
	struct warehouse ware_tmp;
	rid = table_scan(WAREHOUSE, LONG, 0, 0, NO, NULL, rid);
	while(rid != -1){
		printf("rid: %d\n", rid);
		void *result = get(WAREHOUSE, rid);
		d_memcpy((void *)&ware_tmp, result, sizeof(struct warehouse));
		printf("W_ID : %d\n", ware_tmp.W_ID);
		rid = table_scan(WAREHOUSE, LONG, 0, 0, NO, NULL, rid+1);
	}
	
}

void load_data();
//void cp_data_to_dev();
int main(int argc, char **argv){
	load_data();
	printf("load data succeed!\n");

	
// memory allocation.
{
	cudaMalloc( (void **)&h_d_warehouses, sizeof(struct warehouse)*(MAX_WAREHOUSE_NUM));
	cudaMalloc( (void **)&h_d_districts,  sizeof(struct district)*(MAX_DISTRICT_NUM));
	cudaMalloc( (void **)&h_d_customers,  sizeof(struct customer)*(MAX_CUSTOMER_NUM));
	cudaMalloc( (void **)&h_d_historys,  sizeof(struct history)*(MAX_HISTORY_NUM));
	cudaMalloc( (void **)&h_d_new_orders,  sizeof(struct new_order)*(MAX_NEWORDER_NUM));
	cudaMalloc( (void **)&h_d_orders,  sizeof(struct order)*(MAX_ORDER_NUM));
	cudaMalloc( (void **)&h_d_orderlines,  sizeof(struct order_line)*(MAX_ORDER_LINE_NUM));
	cudaMalloc( (void **)&h_d_items,  sizeof(struct item)*(MAX_ITEM_NUM));
	cudaMalloc( (void **)&h_d_stocks,  sizeof(struct stock)*(MAX_STOCK_NUM));

	cudaMalloc( (void **)&h_d_warehouses_flag, sizeof(char)*MAX_WAREHOUSE_NUM);
	cudaMalloc( (void **)&h_d_districts_flag, sizeof(char)*MAX_DISTRICT_NUM);
	cudaMalloc( (void **)&h_d_customers_flag, sizeof(char)*MAX_CUSTOMER_NUM);
	cudaMalloc( (void **)&h_d_historys_flag, sizeof(char)*MAX_HISTORY_NUM);
	cudaMalloc( (void **)&h_d_new_orders_flag, sizeof(char)*MAX_NEWORDER_NUM);
	cudaMalloc( (void **)&h_d_orders_flag, sizeof(char)*MAX_ORDER_NUM);
	cudaMalloc( (void **)&h_d_orderlines_flag, sizeof(char)*MAX_ORDER_LINE_NUM);
	cudaMalloc( (void **)&h_d_items_flag, sizeof(char)*MAX_ITEM_NUM);
	cudaMalloc( (void **)&h_d_stocks_flag, sizeof(char)*MAX_STOCK_NUM);
	printf("device memory allocate succeed.\n");	

	cudaMemcpy(h_d_warehouses, h_warehouses, sizeof(struct warehouse)*(MAX_WAREHOUSE_NUM), cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_districts, h_districts, sizeof(struct district)*MAX_DISTRICT_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_customers, h_customers, sizeof(struct customer)*MAX_CUSTOMER_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_historys, h_historys, sizeof(struct history)*MAX_HISTORY_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_new_orders, h_neworders, sizeof(struct new_order)*MAX_NEWORDER_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_orders, h_orders, sizeof(struct order)*MAX_ORDER_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_orderlines, h_orderlines, sizeof(struct order_line)*MAX_ORDER_LINE_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_items, h_items, sizeof(struct item)*MAX_ITEM_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_stocks, h_stocks, sizeof(struct stock)*MAX_STOCK_NUM, cudaMemcpyHostToDevice);
	
	cudaMemcpy(h_d_warehouses_flag, h_warehouses_flag, sizeof(char)*(MAX_WAREHOUSE_NUM), cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_districts_flag, h_districts_flag, sizeof(char)*MAX_DISTRICT_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_customers_flag, h_customers_flag, sizeof(char)*MAX_CUSTOMER_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_historys_flag, h_historys_flag, sizeof(char)*MAX_HISTORY_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_new_orders_flag, h_neworders_flag, sizeof(char)*MAX_NEWORDER_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_orders_flag, h_orders_flag, sizeof(char)*MAX_ORDER_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_orderlines_flag, h_orderlines_flag, sizeof(char)*MAX_ORDER_LINE_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_items_flag, h_items_flag, sizeof(char)*MAX_ITEM_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_stocks_flag, h_stocks_flag, sizeof(char)*MAX_STOCK_NUM, cudaMemcpyHostToDevice);
	printf("memcpy succeed.\n");
}
	// test table scan.
	test_table_scan<<<1, 1>>>(h_d_warehouses, h_d_warehouses_flag);
	cudaMemcpy(h_warehouses_flag, h_d_warehouses_flag, sizeof(char)*MAX_WAREHOUSE_NUM, cudaMemcpyDeviceToHost);
	
	return 0;
}

//void cp_data_to_dev(){
	
//}

void load_data(){
		int warehouse_num = get_warehouse(h_warehouses);
		int i;
		for(i = 0; i<warehouse_num ; i++){
			h_warehouses_flag[i] = (char)1;
			printf("load: h_warehouses_flag %d , val : %d\n", i, h_warehouses_flag[i]);
		}

			

//		printf("load warehouse succeed.\n");		


		int stock_num = get_stock(h_stocks);
		for( i = 0; i<stock_num ; i++){
			h_stocks_flag[i] = 1;
		}


//		printf("load stock succeed.\n");		

		int district_num = get_district(h_districts);
		for( i = 0; i<district_num ; i++){
			h_districts_flag[i] = 1;
		}


//		printf("load district succeed.\n");		
		
		int customer_num = get_customer(h_customers);
		for( i = 0; i<customer_num ; i++){
			h_customers_flag[i] = 1;
		}
//		printf("load customer succeed.\n");		

			
		int new_order_num = get_new_order(h_neworders);
		for( i = 0; i<new_order_num ; i++){
			h_neworders_flag[i] = 1;
		}
//		printf("load new_order succeed.\n");	


		
		int order_num = get_order(h_orders);
		for( i = 0; i<order_num ; i++){
			h_orders_flag[i] = 1;
		}
//		printf("load order_num succeed.\n");		


	
		int order_line_num = get_order_line(h_orderlines);
		for( i = 0; i<order_line_num ; i++){
			h_orderlines_flag[i] = 1;
		}
//		printf("load order_line succeed.\n");	


		
		int item_num = get_item(h_items);
		for( i = 0; i<item_num ; i++){
			h_items_flag[i] = 1;
		}		
//		printf("load item succeed.\n");	
		int history_num = get_history(h_historys);
		for( i = 0; i<history_num ; i++){
			h_historys_flag[i] = 1;
		}
//		printf("load history succeed.\n");		

		
}

__device__
void delete_rec(int table_type, int record_id){
	const int bid = blockIdx.x;
	const int tid = blockIdx.x;
	char *flag_head = NULL;
	if(bid == 0 && tid == 0){
		get_flag_head(table_type, &flag_head);
		mark_slot_free(flag_head, record_id);	
	}
}

__device__
void insert_rec(int table_type, void *record){
	int record_size = 0;
	int slot_id = -1;
	const int bid = blockIdx.x;
	const int tid = threadIdx.x;
	void *table_head = NULL;
	char *flag_head = NULL;
	if(bid == 0 && tid ==0){
		get_table_head(table_type, &table_head);
		get_record_size(table_type, &record_size);
		get_flag_head(table_type, &flag_head);
		slot_id = get_free_slot(flag_head, table_type);
		d_memcpy( table_head+slot_id*record_size, record, record_size);
		mark_slot_used(flag_head, slot_id);
	}
}

__device__
void update(int table_type, int record_id, void *record){
	void *table_head = NULL;
	int record_size;
	const int bid = blockIdx.x;
	const int tid = threadIdx.x;
	if( bid==0 && tid ==0){
		get_table_head(table_type, &table_head);
		get_record_size(table_type, &record_size);
		d_memcpy( table_head+record_id*record_size, record, record_size);
	}
}

__device__
void *get(int table_type, int record_id){
	void *table_head = NULL;
	int record_size;
	const int bid = blockIdx.x;
	const int tid = threadIdx.x;
	if(bid==0 && tid ==0){
		get_table_head(table_type, &table_head);
		get_record_size(table_type, &record_size);
		return (void *)(table_head+record_id*record_size);
	}
	return NULL;
}

// desc: scan table by compare some attribute in the table from the r_id.
// output: the record_id or -1 if there is no record match condition.
__device__
int table_scan(int table_type, int attr_type, int attr_size, int attr_offset, int op, void *value, int r_id){
	const int bid = blockIdx.x;
	const int tid = threadIdx.x;
	void *table_head = NULL;
	char *flag_head = NULL;
	int table_size;
	int record_size;
	if(bid == 0 && tid == 0){
		get_table_head(table_type, &table_head);
		get_table_size(table_type, &table_size);
		get_record_size(table_type, &record_size);
		get_flag_head(table_type, &flag_head);
		int i;
		for(i = r_id; i<table_size; i++){
			if(!(int)flag_head[i]){
				continue;
			}
			if(op == NO)
				return i;
			void *record_addr = (void *)(table_head + record_size*i);
			void *attr_addr = (void *)(record_addr + attr_offset);
			switch(attr_type){
				case(INT):
					{
					int des = *((int *)attr_addr);
					int src = *((int *)value);
					switch(op){
						case(EQ):
							if(des == src)
								return i;
							break;
						case(LT):
							if(des < src)
								return i;
							break;
						case(GT):
							if(des > src)
								return i;
							break;
						case(LE):
							if(des <= src)
								return i;
							break;
						case(GE):
							if(des >= src)
								return i;
							break;
						case(NE):
							if(des != src)
								return i;
							break;
					}
					}
					break;
				case(LONG):
					{
					long des = *((long *)attr_addr);
					long src = *((long *)value);
					switch(op){
						case(EQ):
							if(des == src)
								return i;
							break;
						case(LT):
							if(des < src)
								return i;
							break;
						case(GT):
							if(des > src)
								return i;
							break;
						case(LE):
							if(des <= src)
								return i;
							break;
						case(GE):
							if(des >= src)
								return i;
							break;
						case(NE):
							if(des != src)
								return i;
							break;
					}
					}
					break;
				case(DOUBLE):
					{
					double des = *((double *)attr_addr);
					double src = *((double *)value);
					switch(op){
						case(EQ):
							if(des == src)
								return i;
							break;
						case(LT):

							if(des < src)
								return i;
							break;
						case(GT):

							if(des > src)
								return i;
							break;
						case(LE):
							if(des <= src)
								return i;

							break;
						case(GE):
							if(des >= src)
								return i;
							break;
						case(NE):
							if(des != src)
								return i;
							break;
					}
					}
					break;
				case(STR):
					{
					char des[200];
					d_memcpy(des, (char *)attr_addr, attr_size);
					des[attr_size+1] = '\0';
					char src[200];
					d_memcpy(src, (char *)value, attr_size);
					src[attr_size+1] = '\0';
					switch(op){
						case(EQ):
							if( !d_strcmp(des, src) )
								return i;
							break;
						case(NE):
							if(d_strcmp(des, src))
								return i;
							break;
					}
					}
					break;
			}	
		}
	}	
	return -1;
}

/*
__device__
void get_next_record(){

}

__device__
void clsoe_scan(){

}
*/
__device__
void get_table_head(int table_type, void **table_head){

	switch(table_type){
		case(WAREHOUSE):
			*table_head = (void *)d_warehouses;
			break;
		case(STOCK):
			*table_head = (void *)d_stocks;
			break;
		case(DISTRICT):
			*table_head = (void *)d_districts;
			break;
		case(ITEM):
			*table_head = (void *)d_items;
			break;
		case(NEW_ORDER):
			*table_head = (void *)d_new_orders;
			break;
		case(ORDER):
			*table_head = (void *)d_orders;
			break;
		case(ORDER_LINE):
			*table_head = (void *)d_orderlines;
			break;
		case(CUSTOMER):
			*table_head = (void *)d_customers;
			break;
	}

}

__device__
void get_flag_head(int table_type, char **flag_head){

	switch(table_type){
		case(WAREHOUSE):
			*flag_head = d_warehouses_flag;
			break;
		case(STOCK):
			*flag_head = d_stocks_flag;
			break;
		case(DISTRICT):
			*flag_head = d_districts_flag;
			break;
		case(ITEM):
			*flag_head = d_items_flag;
			break;
		case(NEW_ORDER):
			*flag_head = d_new_orders_flag;
			break;
		case(ORDER):
			*flag_head = d_orders_flag;
			break;
		case(ORDER_LINE):
			*flag_head = d_orderlines_flag;
			break;
		case(CUSTOMER):
			*flag_head = d_customers_flag;
			break;
	}
}

__device__
void get_record_size(int table_type, int *record_size){
	
	switch(table_type){
		case(WAREHOUSE):
			*record_size = sizeof(struct warehouse);
			break;
		case(STOCK):
			*record_size = sizeof(struct stock);
			break;
		case(DISTRICT):
			*record_size = sizeof(struct district);
			break;
		case(ITEM):
			*record_size = sizeof(struct customer);
			break;
		case(NEW_ORDER):
			*record_size = sizeof(struct new_order);
			break;
		case(ORDER):
			*record_size = sizeof(struct order);
			break;
		case(ORDER_LINE):
			*record_size = sizeof(struct order_line);
			break;
		case(CUSTOMER):
			*record_size = sizeof(struct customer);
			break;
	}
}

__device__
void get_table_size(int table_type, int *table_size){

	switch(table_type){
		case(WAREHOUSE):
			*table_size = MAX_WAREHOUSE_NUM;
			break;
		case(STOCK):
			*table_size = MAX_STOCK_NUM;
			break;
		case(DISTRICT):
			*table_size = MAX_DISTRICT_NUM;
			break;
		case(ITEM):
			*table_size = MAX_ITEM_NUM;
			break;
		case(NEW_ORDER):
			*table_size = MAX_NEWORDER_NUM;
			break;
		case(ORDER):
			*table_size = MAX_ORDER_NUM;
			break;
		case(ORDER_LINE):
			*table_size = MAX_ORDER_LINE_NUM;
			break;
		case(CUSTOMER):
			*table_size = MAX_CUSTOMER_NUM;
			break;
	}
}
__device__
void  d_memcpy(void *des, void *src, int size){
	int i ;
	for(i = 0; i< size; i++){
		((char *)des)[i] = ((char *)src)[i];
	} 
}

__device__
int d_strcmp(char *des, char *src){
	int i=0;
	while(des[i] == src[i]){
		if(des[i] == '\0')	
			return 0;
		else{
			i++;
		}
	}
	return i;
}
