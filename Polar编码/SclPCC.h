/* Copyright: Huawei Technologies Co., Ltd. 2017 All rights reserved.   */
/* File name: SclPCC.h                                                  */
/* Author: CT HangZhou Alg                                              */
/* Description: Head file                                               */
/* History: Dec 8th, 2017 Cleaned                                       */

#ifndef _SCL_H_
#define _SCL_H_
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include <stdio.h>

#define SIGN(a) ( ( (a)<0 )? -1 : ( ( a)>0 ))
#define ABS(a)  ( ( (a)<0 )? -a : a )
#define MIN(a,b)( ( (a)<(b) )? a : b )
#define DB2LIN(dB)    pow(10., (dB) / 10.)
#define LIN2DB(W)     (10. * log10((W)))

#define CSET(v,i) ((v) |= 1 << i)
#define CCLEAR(v,i) ((v) &= ~(1 << i))
#define CGET(v,i) (((v) >> i) & 1)
#define CFLIP(v,i) ((v) ^= 1 << i)

#define PRIME 5

    double *gZin;
    int     *u;

    float	*gPM;
    char	*cc_reg;
    float	*gLLR;
    int		*gUs;
    int		*gU_hat;
    int     *gStageOrder;
    int     *gFG;
    float	*gLLR_Uhat;
  int CheckSizeIndex; /* index the position of dCheckSize*/
  int InfoBitsPosIndex;  /* index the position of subset of dInfoBitsPos*/

/* declare the functions */
void genStageOrder(int N, int m);
/*scl main function */
void scl();
/*update LLR*/
void updateLLR(int stage,int fg, int pathNum, int m, int Half_N, int N);
/*update decoded bit*/
void updateU(int Ubit,int depth, int *pathNum, int *LenDecode, int N, int L, float *dCheckBitsPos);

typedef struct {
  int i;
  float d;
} Sort;
int ascend(const void *p1, const void *p2);
int descend(const void *p1, const void *p2);

void genInfoSetId(int *SetId, int info_crc);
#endif _SCL_H_

