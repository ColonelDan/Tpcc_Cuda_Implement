//
//	desc: define the 9 table in tpcc.
//	date: 2018-3.27
//	author: Xie Shangwei
//
//

#include "tpcc_table.h"

//
// desc : get a free slot id from the table.
// intput : slot flag arry , table type.
// output : the slot id or -1 if there is no
// 	    free slot exists.
//
__device__
int get_free_slot(char *slot_flag_arry, int table_type){
	int max_num = 0;
	const int pid = blockIdx.x;
	const int tid = threadIdx.x;
	switch(table_type){
		case(WAREHOUSE):
			max_num = MAX_WAREHOUSE_NUM;
			break;
		case(STOCK):
			max_num = MAX_STOCK_NUM;
			break;
		case(DISTRICT):
			max_num = MAX_DISTRICT_NUM;
			break;
		case(ITEM):
			max_num = MAX_ITEM_NUM;
			break;
		case(NEW_ORDER):
			max_num = MAX_NEWORDER_NUM;
			break;
		case(ORDER):
			max_num = MAX_ORDER_NUM;
			break;
		case(ORDER_LINE):
			max_num = MAX_ORDER_LINE_NUM;
			break;
		case(CUSTOMER):
			max_num = MAX_CUSTOMER_NUM;
			break;
	}
/*	
	int i ;
	for(i= bid*blockDim.x+tid; i< max_num ; i += gridDim.x*blockDim.x)
	{	
		if(slot_flag_arry[i] == 0) 
			return i;
	}*/
	if( pid==0 && tid == 0 ){
		int i ;
		for(i=0; i<max_num; i++)
		{
			if(slot_flag_arry[i] == 0)
				return i;
		}
	}
	return -1;
}

//
// desc : mark the slot as used by slot id.
//
__device__
void mark_slot_used(char *slot_flag_array, int slot_id){
	const int pid = blockIdx.x;
	const int tid = threadIdx.x;
	if (pid == 0&&tid == 0)
		slot_flag_array[slot_id] = 1;
}

//
// desc : mark the slot as freed by slot id.
//
__device__
void mark_slot_free(char *slot_flag_array, int slot_id){
	const int pid = blockIdx.x;
	const int tid = threadIdx.x;
	if(pid == 0 && tid ==0)
		slot_flag_array[slot_id] = 0;
}



