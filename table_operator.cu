//
//  	desc: tpcc benchmark implementation in GPU
//	date: 2018-4-3
//	author: Xie Shangwei
//

#include <stdio.h>

#include <cuda_runtime.h>

#include "tpcc_table.h"
#include "utility.h"
#include "table_operator.h"

//get 9 tables.
extern struct warehouse h_warehouses[MAX_WAREHOUSE_NUM];
extern struct district h_districts[MAX_DISTRICT_NUM];
extern struct customer h_customers[MAX_CUSTOMER_NUM];
extern struct history h_historys[MAX_HISTORY_NUM];
extern struct new_order h_neworders[MAX_NEWORDER_NUM];
extern struct order h_orders[MAX_ORDER_NUM];
extern struct order_line h_orderlines[MAX_ORDER_LINE_NUM];
extern struct stock h_stocks[MAX_STOCK_NUM];
extern struct item h_items[MAX_ITEM_NUM];
 
//tables's slot flag, mark the slot is used or not.
extern char  h_warehouses_flag[MAX_WAREHOUSE_NUM];
extern char  h_districts_flag[MAX_DISTRICT_NUM];   
extern char  h_customers_flag[MAX_CUSTOMER_NUM];   
extern char  h_historys_flag[MAX_HISTORY_NUM];      
extern char  h_neworders_flag[MAX_NEWORDER_NUM];  
extern char  h_orders_flag[MAX_ORDER_NUM];            
extern char  h_orderlines_flag[MAX_ORDER_LINE_NUM];  
extern char  h_items_flag[MAX_ITEM_NUM];               
extern char  h_stocks_flag[MAX_STOCK_NUM];

extern struct warehouse *h_d_warehouses;
extern struct district *h_d_districts;
extern struct customer *h_d_customers;
extern struct history *h_d_historys;
extern struct new_order *h_d_new_orders;
extern struct order *h_d_orders;
extern struct order_line *h_d_orderlines;
extern struct item *h_d_items;
extern struct stock *h_d_stocks;

extern char *h_d_warehouses_flag;
extern char *h_d_districts_flag;
extern char *h_d_customers_flag;
extern char *h_d_historys_flag;
extern char *h_d_new_orders_flag;
extern char *h_d_orders_flag;
extern char *h_d_orderlines_flag;
extern char *h_d_items_flag;
extern char *h_d_stocks_flag;

extern __device__ char *d_warehouses_flag;
extern __device__ char *d_districts_flag;
extern __device__ char *d_customers_flag;
extern __device__ char *d_historys_flag;
extern __device__ char *d_new_orders_flag;
extern __device__ char *d_orders_flag;
extern __device__ char *d_orderlines_flag;
extern __device__ char *d_items_flag;
extern __device__ char *d_stocks_flag;

extern __device__ struct warehouse *d_warehouses;
extern __device__ struct district *d_districts;
extern __device__ struct customer *d_customers;
extern __device__ struct history *d_historys;
extern __device__ struct new_order *d_new_orders;
extern __device__ struct order *d_orders;
extern __device__ struct order_line *d_orderlines;
extern __device__ struct item *d_items;
extern __device__ struct stock *d_stocks;


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
int insert_rec(int table_type, void *record){
	int record_size = 0;
	int slot_id = -1;
	const int bid = blockIdx.x;
	const int tid = threadIdx.x;
	void *table_head= NULL;
	char *flag_head = NULL;
	if(bid == 0 && tid ==0){
		get_table_head(table_type, &table_head);
		get_record_size(table_type, &record_size);
		get_flag_head(table_type, &flag_head);
		slot_id = get_free_slot(flag_head, table_type);
		d_memcpy( table_head+slot_id*record_size, record, record_size);
		mark_slot_used(flag_head, slot_id);
			return slot_id;
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
					attr_size = d_strlen((char *)attr_addr);
					d_memcpy(des, (char *)attr_addr, attr_size);
					des[attr_size+1] = '\0';
					char src[200];
					attr_size = d_strlen((char *)value);
					d_memcpy(src, (char *)value, attr_size);
					src[attr_size+1] = '\0';
					//printf("des : %s src : %s\n", des, src);
					switch(op){
						case(EQ):
							if( !d_strcmp(des, src) ){
								//printf("equal\n");
								return i;
							}
							break;
						case(NE):
							if(d_strcmp(des, src)){
								//printf("not equal\n");
								return i;
							}
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
			*record_size = sizeof(struct item);
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
