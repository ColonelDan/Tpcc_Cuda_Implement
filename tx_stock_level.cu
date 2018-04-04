

#include  <stdio.h>

#include <curand_kernel.h>
#include <cuda_runtime.h>

#include "tpcc_table.h"
#include "tx.h"
#include "utility.h"
#include "table_operator.h"

__device__
int d_max(int a, int b){
		return a>b?a:b;
}

__device__
void tx_stock_level(){
	printf("into stock_level\n");
	
	//generate parameters.
	long D_W_ID;
	long D_ID;
	long W_ID;
	unsigned int limit;

	unsigned int rid = d_random(0, 20);
	struct district tmp_district;
	rid = table_scan(DISTRICT, LONG, 0, 0, NO, NULL, rid);
	//printf("rid : %d\n", rid);
	void *content = get(DISTRICT, rid);
	d_memcpy(&tmp_district, content, sizeof(struct district));
	D_W_ID = tmp_district.D_W_ID;
	D_ID = tmp_district.D_ID;
	W_ID = tmp_district.D_W_ID;
	limit = d_random(30, 60);

	printf("****** stock_level ******\nparameters:\n W_ID : %ld\n D_W_ID : %ld\n D_ID : %ld\n limit : %u\n", D_W_ID, D_W_ID, D_ID, limit);

	int offset_D_W_ID = (unsigned int)&tmp_district.D_W_ID - (unsigned int)&tmp_district.D_ID;
	int offset_D_ID = 0;
	// int rid1 = table_scan(DISTRICT, LONG, 0, offset_D_W_ID, EQ, &D_W_ID, 0);
	// int rid2;
	// while( rid1 != -1){
	// 	rid2 = table_scan(DISTRICT, LONG, 0, offset_D_ID, EQ, &D_ID, rid);
	// 	if(rid1 == rid2)
	// 		break;
	// 	rid1 = table_scan(DISTRICT, LONG, 0, offset_D_W_ID, EQ, &D_W_ID, rid1+1);
	// }

	int start_id = 0;
	int id1 = table_scan(DISTRICT, LONG, 0, offset_D_W_ID, EQ, &D_W_ID, start_id);
	int id2 =  table_scan(DISTRICT, LONG, 0, offset_D_ID, EQ, &D_ID, start_id);
	while(id1 != id2){
		//printf("id1 : %d, id2:%d\n", id1, id2);
		if(id1 == -1 || id2 == -1){
			//printf("no record satisfy requirement\n");
			break;
		}
		start_id = d_max(id1, id2);
		id1 = table_scan(DISTRICT, LONG, 0, offset_D_W_ID, EQ, &D_W_ID, start_id);
		id2 = table_scan(DISTRICT, LONG, 0, offset_D_ID, EQ, &D_ID, start_id);
	}

	printf("*id1 : %d, id2:%d\n", id1, id2);
	if(id1 == id2&& id1 != -1)
			content = get(DISTRICT, id1);
	else
		printf("no record satisfy requirement\n");
	d_memcpy(&tmp_district, content, sizeof(struct district));

	long next_order_id = tmp_district.D_NEXT_O_ID;
	//printf("D_NEXT_ID : %ld\n", next_order_id);


	//next step
	// scan orderline where OL_W_ID = W_ID, OL_D_ID = D_ID, D_NEXT_O_ID-20 <= OL_O_ID < D_NEXT_O_ID.

	//struct order_line *orderline_result[20];
	struct order_line tmp_orderline;
	struct order_line *odl;
	long item_id[20];
	int offset_OL_W_ID = (int )&tmp_orderline.OL_W_ID - (int)&tmp_orderline.OL_O_ID;
	start_id = 0;
	//printf("offset_Ol_W_ID: %d\n", offset_OL_W_ID);
	int result_num = 0;
	int id = table_scan(ORDER_LINE, LONG, 0, offset_OL_W_ID, EQ, &W_ID, start_id);
	while(id != -1){
			odl = (struct order_line *)get(ORDER_LINE, id);
		 	if(odl->OL_D_ID == D_ID &&
		 		odl->OL_O_ID>=next_order_id-20 &&
		 		odl->OL_O_ID < next_order_id){
		 			item_id[result_num%20] = odl->OL_I_ID;
		 			result_num++;
					//printf("%ld 		%ld		%ld\n", odl->OL_O_ID, odl->OL_D_ID, odl->OL_W_ID);
		 	}
		 	id = table_scan(ORDER_LINE, LONG, 0, offset_OL_W_ID, EQ, &W_ID, id+1);
	}
	printf("OL_I_ID		\n");
	for(int i = 0; i<20; i++){
			printf("%ld\n", item_id[i]);
	}

	//next step.
	// scan stock where S_I_ID = OL_I_ID, S_W_ID=W_ID, S_QUANTITY < limit.
	start_id = 0;
	struct stock tmp_stock;
	int offset_S_I_ID = (unsigned int)&tmp_stock.S_I_ID - (unsigned int)&tmp_stock.
	id = table_scan(STOCK, LONG, )
}
