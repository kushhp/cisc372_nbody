#include <stdlib.h>
#include <math.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include "vector.h"
#include "config.h"
//#include "compute.h"

__global__ void make_accel_matrix(vector3** accels, vector3* values) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= NUMENTITIES) {
        return;
    }
    accels[i] = &values[i*NUMENTITIES];
}

__global__ void computeAccel(vector3** accels, vector3* values, vector3 *accel_sum, vector3* hPos, double* mass) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j, k;

    if (i >= NUMENTITIES) {
        return;
    }
    accels[i] = &values[i*NUMENTITIES];

    for (j=0;j<NUMENTITIES;j++) {
        if (i == j) {
            FILL_VECTOR(accels[i][j], 0, 0, 0)
        } else {
            vector3 distance;
            for (k=0;k<3;k++) distance[k]=hPos[i][k]-hPos[j][k];
            double magnitude_sq=distance[0]*distance[0]+distance[1]*distance[1]+distance[2]*distance[2];
            double magnitude=sqrt(magnitude_sq);
            double accelmag=-1*GRAV_CONSTANT*mass[j]/magnitude_sq;
            FILL_VECTOR(accels[i][j],accelmag*distance[0]/magnitude,accelmag*distance[1]/magnitude,accelmag*distance[2]/magnitude);
        }
    }
}

__global__ void computeSum(vector3** accels, vector3 *accel_sum, vector3* hVel, vector3* hPos) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j, k;

    if (i >= NUMENTITIES) {
        return;
    }

    for (j=0;j<NUMENTITIES;j++){
		for (k=0;k<3;k++)
			accel_sum[i][j] += accels[i][j][k];
	}

    for (k=0;k<3;k++){
		hVel[i][k]+=accel_sum[i][k]*INTERVAL;
		hPos[i][k]=hVel[i][k]*INTERVAL;
	}
}