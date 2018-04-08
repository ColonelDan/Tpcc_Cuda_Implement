#include <stdio.h>

#include <curand_kernel.h>
#include <cuda_runtime.h>

#include "tpcc_table.h"
#include "tx.h"
#include "utility.h"
#include "table_operator.h"

//test for new-order transaction!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

__device__
void tx_new_order(){
	//输入的数据
	long no_W_ID=1;	//warehouse ID
	long no_D_W_ID=1;	long no_D_ID=3;	//district ID
	long no_C_W_ID=1;	long no_C_D_ID=3;	long no_C_ID=3;	//customer ID
	int no_OL_CNT=2;	//order_line count
	long no_OL_I_ID_arr[] = {1,2};	//
	long no_OL_SUPPLY_W_ID_arr[] = {1,1};	//
	double no_OL_QUANTITY_arr[] = {1.0,2.0};

	long no_O_ID=1;//必须要用到的新订单的ID
	double no_OL_AMOUNT_arr[2];//必须要用到的各分录的价格
	long no_OL_NUMBER_arr[]={1,2};//必须要用到的各分录的分录号

	//事务启动
	printf("New-Order Transaction is start!\n");
	
	//在仓库表（warehouses）中查询仓库代码（W_ID）。取税率（W_TAX）。
	struct warehouse warehouse_tmp;	//为了求attr_offset 
	int rid_in_warehouses=0;
	//int table_scan(int table_type, int attr_type, int attr_size, int attr_offset, int op, void *value, int r_id);
	rid_in_warehouses= table_scan(WAREHOUSE, LONG, sizeof(long int), ((long)&(warehouse_tmp.W_ID)-(long)&(warehouse_tmp)), EQ, &no_W_ID, rid_in_warehouses);	//扫描整张warehouses表找出W_ID为no_W_ID的记录号 
	if(rid_in_warehouses==-1){	//warehouses中没有no_W_ID对应的记录 
		printf("Transaction Exception:\tW_ID is not in warehouse table!");
		return;
	}
	struct warehouse *p_warehouse_tmp =(struct warehouse *)get(WAREHOUSE, rid_in_warehouses);	//获取no_W_ID对应的记录
	printf("rid_in_warehouses:%d\tW_ID:%ld\tW_TAX:%lf\n",
		rid_in_warehouses,
		p_warehouse_tmp->W_ID,
		p_warehouse_tmp->W_TAX);//取税率(W_TAX)
	
	
	//在地区表（districts）中查询地区代码（D_W_ID,D_ID）。取税率（D_TAX）;取下一订单号（D_NEXT_O_ID）并且对其加一
	struct district district_tmp;
	struct district *p_district_tmp;
	int rid_in_districts=0;
	while(1){
		rid_in_districts = table_scan(DISTRICT, LONG, sizeof(long int), ((long)&(district_tmp.D_W_ID)-(long)&(district_tmp.D_ID)), EQ, &no_D_W_ID, rid_in_districts);	//扫描整张districts表找出D_W_ID为no_D_W_ID的记录号
		if(rid_in_districts == -1){	//districts中没有no_D_W_ID对应的记录 
			printf("Transaction Exception:\tD_W_ID is not in district table!");
			return;
		}
		p_district_tmp=(struct district *)get(DISTRICT, rid_in_districts);	//获取no_D_W_ID对应的记录
		if(p_district_tmp->D_ID == no_D_ID){	//district中有no_D_W_ID,no_D_ID对应的记录
			break;
		}else{
			rid_in_districts++;
		}
	}
	printf("rid_in_districts:%d\tD_W_ID:%ld\tD_ID:%ld\tD_TAX:%lf\tD_NEXT_O_ID:%ld\n",
		rid_in_districts,
		p_district_tmp->D_W_ID,
		p_district_tmp->D_ID,
		p_district_tmp->D_TAX,	//取税率（D_TAX）
		p_district_tmp->D_NEXT_O_ID);	//取下一订单号（D_NEXT_O_ID）
	//void  d_memcpy(void *des, void *src, int size)
	d_memcpy(&district_tmp,p_district_tmp,sizeof(struct district));
	district_tmp.D_NEXT_O_ID++;
	//void update(int table_type, int record_id, void *record);
	update(DISTRICT,rid_in_districts,&district_tmp);	//对下一订单号（D_NEXT_O_ID）加一
	// //验证D_NEXT_O_ID是否已经加一 
	// printf("rid_in_districts:%d\tD_W_ID:%ld\tD_ID:%ld\tD_NEXT_O_ID:%ld\n",
	// 	rid_in_districts,
	// 	p_district_tmp->D_W_ID,
	// 	p_district_tmp->D_ID,
	// 	p_district_tmp->D_NEXT_O_ID);	//取下一订单号（D_NEXT_O_ID）
	

	//在客户表（customers）中查询地区代码（C_W_ID,C_D_ID,C_ID）。取客户折扣率（C_DISCOUNT），姓（C_LAST），信用（C_CREDIT）
	struct customer customer_tmp;
	struct customer *p_customer_tmp;
	int rid_in_customers=0;
	while(1){
		rid_in_customers = table_scan(CUSTOMER, LONG, sizeof(long int), ((long)&(customer_tmp.C_W_ID)-(long)&(customer_tmp.C_ID)), EQ, &no_C_W_ID, rid_in_customers);	//扫描整张customer表找出C_W_ID为no_C_W_ID的记录号
		if(rid_in_customers == -1){	//customers中没有no_C_W_ID对应的记录 
			printf("Transaction Exception:\tC_W_ID is not in customer table!\n");
			return;
		}
		p_customer_tmp=(struct customer *)get(CUSTOMER, rid_in_customers);	//获取no_C_W_ID对应的记录
		if(p_customer_tmp->C_D_ID == no_C_D_ID && p_customer_tmp->C_ID == no_C_ID){	//customers中有no_C_W_ID,no_C_D_ID,no_C_ID对应的记录
			break;
		}else{
			rid_in_customers++;
		}
	}
	printf("rid_in_customers:%d\tC_W_ID:%ld\tC_D_ID:%ld\tC_ID:%ld\tC_DISCOUNT:%lf\tC_LAST:%s\tC_CREDIT:%s\n",
		rid_in_customers,
		p_customer_tmp->C_W_ID,
		p_customer_tmp->C_D_ID,
		p_customer_tmp->C_ID,
		p_customer_tmp->C_DISCOUNT,	//取客户折扣率（C_DISCOUNT）
		p_customer_tmp->C_LAST,	//姓（C_LAST）
		p_customer_tmp->C_CREDIT);	//信用（C_CREDIT）


	//向新订单表（new_orders）和订单表（orders）分别插入一条新记录
	int i;
	int no_O_ALL_LOCAL=0;
	for(i=0;i<no_OL_CNT;i++){
		if(no_W_ID!=no_OL_SUPPLY_W_ID_arr[i]){
			break;
		}
	}
	if(i==no_OL_CNT){
		no_O_ALL_LOCAL=1;
	}
	struct new_order new_order_tmp={no_O_ID, no_D_ID, no_W_ID};
	struct order order_tmp={no_O_ID, no_D_ID, no_W_ID, no_C_ID, 1189, 0, no_OL_CNT, no_O_ALL_LOCAL};
	insert_rec(NEW_ORDER,&new_order_tmp);
	int rid_in_orders=insert_rec(ORDER,&order_tmp);
	struct order *p_order_tmp=(struct order *)get(ORDER, rid_in_orders);
	printf("rid_in_orders:%d\tO_ID:%ld\tO_D_ID:%ld\tO_W_ID:%ld\tO_C_ID:%ld\tO_ENTRY_DATE:%ld\tO_CARRIER_ID:%ld\tO_OL_CNT:%d\tO_ALL_LOCAL:%d\n",
		rid_in_orders,
		p_order_tmp->O_ID,
		p_order_tmp->O_D_ID,
		p_order_tmp->O_W_ID,
		p_order_tmp->O_C_ID,
		p_order_tmp->O_ENTRY_DATE,
		p_order_tmp->O_CARRIER_ID,
		p_order_tmp->O_OL_CNT,
		p_order_tmp->O_ALL_LOCAL);

	//处理每笔分录（order_line）
	for(i=0;i<no_OL_CNT;i++){
		//在商品表（items）中查询商品代码（I_ID）。取价格（I_PRICE）、名称（I_NAME）、备注（I_DATA）
		struct item item_tmp;
		struct item *p_item_tmp;
		int rid_in_items=0;
		rid_in_items = table_scan(ITEM, LONG, sizeof(long int), ((long)&(item_tmp.I_ID)-(long)&(item_tmp.I_ID)), EQ, &no_OL_I_ID_arr[i], 0);	//扫描整张item表找出I_ID为no_OL_I_ID_arr[i]的记录号
		if(rid_in_items == -1){	//items中没有no_OL_I_ID_arr[i]对应的记录 
			printf("Transaction Exception:\tI_ID is not in item table!\n");
			return;
		}
		p_item_tmp=(struct item *)get(ITEM, rid_in_items);	//获取no_OL_I_ID_arr[i]对应的记录
		printf("rid_in_items:%d\tI_ID:%ld\tI_PRICE:%lf\tI_NAME:%s\tI_DATA:%s\n",
			rid_in_items,
			p_item_tmp->I_ID,
			p_item_tmp->I_PRICE,
			p_item_tmp->I_NAME,
			p_item_tmp->I_DATA);


		//在库存表（stocks）中查询商品代码（S_I_ID）与仓库代码（S_W_ID）。取库存（S_QUANTITY）、地区说明（S_DIST_XX）、备注（S_DATA）；
		struct stock stock_tmp;
		struct stock *p_stock_tmp;
		int rid_in_stocks=0;
		while(1){
			rid_in_stocks = table_scan(STOCK, LONG, sizeof(long int), ((long)&(stock_tmp.S_I_ID)-(long)&(stock_tmp.S_I_ID)), EQ, &no_OL_I_ID_arr[i], rid_in_stocks);	//扫描整张stock表找出S_I_ID为no_OL_I_ID_arr[i]的记录号
			if(rid_in_stocks == -1){	//stocks中没有no_OL_I_ID_arr[i]对应的记录 
				printf("Transaction Exception:\tS_I_ID is not in stock table!\n");
				return;
			}
			p_stock_tmp=(struct stock *)get(STOCK, rid_in_stocks);	//获取对应no_OL_I_ID_arr[i]的记录
			if(p_stock_tmp->S_W_ID == no_OL_SUPPLY_W_ID_arr[i]){	//stocks中有no_OL_I_ID_arr[i],no_OL_SUPPLY_W_ID_arr[i]对应的记录
				break;
			}else{
				rid_in_stocks++;
			}
		}
		char *no_S_DIST_tmp;
		switch(no_OL_SUPPLY_W_ID_arr[i]){
			case 1:no_S_DIST_tmp=p_stock_tmp->S_DIST_01;break;
			case 2:no_S_DIST_tmp=p_stock_tmp->S_DIST_02;break;
			case 3:no_S_DIST_tmp=p_stock_tmp->S_DIST_03;break;
			case 4:no_S_DIST_tmp=p_stock_tmp->S_DIST_04;break;
			case 5:no_S_DIST_tmp=p_stock_tmp->S_DIST_05;break;
			case 6:no_S_DIST_tmp=p_stock_tmp->S_DIST_06;break;
			case 7:no_S_DIST_tmp=p_stock_tmp->S_DIST_07;break;
			case 8:no_S_DIST_tmp=p_stock_tmp->S_DIST_08;break;
			case 9:no_S_DIST_tmp=p_stock_tmp->S_DIST_09;break;
			case 10:no_S_DIST_tmp=p_stock_tmp->S_DIST_10;break;
		}
		printf("rid_in_stocks:%d\tS_I_ID:%ld\tS_W_ID:%ld\tS_QUANTITY:%lf\tS_DIST_INFO:%s\tS_DATA:%s\n",
			rid_in_stocks,
			p_stock_tmp->S_I_ID,
			p_stock_tmp->S_W_ID,
			p_stock_tmp->S_QUANTITY,	//取库存（S_QUANTITY）
			no_S_DIST_tmp,	//地区说明（S_DIST_XX）
			p_stock_tmp->S_DATA);//	备注（S_DATA）
		d_memcpy(&stock_tmp,p_stock_tmp,sizeof(struct stock));
		stock_tmp.S_QUANTITY-=no_OL_QUANTITY_arr[i];	//库存量减去商品数量
		stock_tmp.S_YTD+=no_OL_QUANTITY_arr[i];	//累计供货数量加上商品数量
		stock_tmp.S_ORDER_CNT++;	//累计定单数量加一
		if(stock_tmp.S_W_ID!=no_W_ID){	//如果分录中的商品在其他仓库，则累计其他仓库供货数量加一
			stock_tmp.S_REMOTE_CNT++;
		}
		update(STOCK,rid_in_stocks,&stock_tmp);
		// //验证S_QUANTITY是否已经变化
		// printf("rid_in_stocks:%d\tS_I_ID:%ld\tS_W_ID:%ld\tS_QUANTITY:%lf\n",
		// 	rid_in_stocks,
		// 	p_stock_tmp->S_I_ID,
		// 	p_stock_tmp->S_W_ID,
		// 	p_stock_tmp->S_QUANTITY);//	取库存（S_QUANTITY）


		no_OL_AMOUNT_arr[i]=no_OL_QUANTITY_arr[i]*p_item_tmp->I_PRICE;//计算价格


		struct order_line new_orderline;
		new_orderline.OL_O_ID=no_O_ID,
		new_orderline.OL_D_ID=no_D_ID,
		new_orderline.OL_W_ID=no_W_ID,
		new_orderline.OL_NUMBER=no_OL_NUMBER_arr[i],
		new_orderline.OL_I_ID=no_OL_I_ID_arr[i],
		new_orderline.OL_SUPPLY_W_ID=no_OL_SUPPLY_W_ID_arr[i],
		new_orderline.OL_DELIVERY_D=0,
		new_orderline.OL_QUANTITY=no_OL_QUANTITY_arr[i],
		new_orderline.OL_AMOUNT=no_OL_AMOUNT_arr[i],
		d_memcpy(&new_orderline,no_S_DIST_tmp,24+1);
		insert_rec(ORDER_LINE,&new_orderline);	//分录表中插入新分录
	}

	double sum_OL_AMOUNT=0;
	for(i=0;i<no_OL_CNT;i++){
		sum_OL_AMOUNT+=no_OL_AMOUNT_arr[i];
	}
	double final_price=sum_OL_AMOUNT*(1-p_customer_tmp->C_DISCOUNT)*(1+p_warehouse_tmp->W_TAX+p_district_tmp->D_TAX);//计算定单总价格
	printf("final price is %lf\n",final_price);

	//事务提交 
	printf("New-Order Transaction is finished!\n");
}