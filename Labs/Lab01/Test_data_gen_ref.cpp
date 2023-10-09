// ========================================================
// Project:  Lab01 reference code
// File:     Test_data_gen_ref.cpp
// Author:   Lai Lin-Hung @ Si2 Lab
// Date:     2021.09.15
// ========================================================

#include <cstdio>
#include <sstream>
#include <string.h>
#include <time.h>
#include <stdlib.h>
#include <algorithm>
#include <math.h>    
#include <vector>  
 
 using namespace std;
#define RED "\033[0;32;31m"
#define NONE "\033[m"
#define CYAN "\033[0;36m"

#define PATTERN_NUM 1000  //可調整PATTERN_NUM來決定PATTERN數目


/* dram.dat format
1. @10000
2. XX XX XX XX
3. @10004
4. XX XX XX XX
...
*/

/* Input format
1. [PATTERN_NUM] 

repeat(PATTERN_NUM)
	1. [mode] 
	2. [W_0 V_GS_0 V_DS_0]
	3. [W_1 V_GS_1 V_DS_1]
	4. [W_2 V_GS_2 V_DS_2]
	5. [W_3 V_GS_3 V_DS_3]
	6. [W_4 V_GS_4 V_DS_4]
	7. [W_5 V_GS_5 V_DS_5]

*/
/* Output format
1. [out_n]

*/


int main(){
	FILE *pIFile = fopen("input.txt", "w");
	FILE *pOFile = fopen("output.txt", "w");

	// INIT
    //srand(time(NULL));
	srand(2);
	int num_pattern = PATTERN_NUM;
	int mode = 0, out_n;
	int w[6],vgs[6],vds[6],gm[6],id[6];


	int count = 0;
	fprintf(pIFile,"%d\n",PATTERN_NUM);
	while(num_pattern--)
	{
		// Todo: 
        // You can generate test data here


        // Show on terminal
		printf(RED "PATTERN %d\n" NONE,num_pattern);
		for(int i = 0; i < 6; i++)
			printf("NO: %d | w: %d vgs: %d vds: %d\n",i,w[i],vgs[i],vds[i]);
		for(int i = 0; i < 6; i++)
			printf("id[%d]: %3d ",i,id[i]);
		printf("\n");
		for(int i = 0; i < 6; i++)
			printf("gm[%d]: %3d ",i,gm[i]);
		printf("\n");
		printf("mode = %d, out_n = %d\n",mode,out_n);
		
        // Output file
		fprintf(pIFile,"\n%d\n",mode);
		for(int i = 0; i < 6; i++)
			fprintf(pIFile,"%d %d %d\n",w[i],vgs[i],vds[i]);
		
		fprintf(pOFile,"%d\n",out_n);

	}


    return 0;

}
