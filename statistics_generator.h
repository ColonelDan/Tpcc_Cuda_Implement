//
// desc : the head file of statistics_generator.
// date: 2018-3-27
// author: Xie Shangwei
//
#ifndef  STATISTICS_GENERATOR_H
#define STATISTICS_GENERATOR_H

#include <stdlib.h>
#include <stdio.h>

#include "support.h"

void load_items(); 	// load random data into table item

void load_warehouses();

void load_customers() ;

void load_orders();

////////////////////////
int stock(int w_id);	

int district(int w_id);

void customer(int d_id, int w_id);

void order(int d_id, int w_id);

#endif
