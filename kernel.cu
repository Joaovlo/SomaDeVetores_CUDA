
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

// variáveis globais
// Legenda:
// int a e int b são vetores quaisquer
// int c é a soma deles
int* a, int* b, int* c;

//kernel -- GPU
__global__ void somaVec(int N, int* a, int* b, int* c) 
{
	int i = threadIdx.x;
	// identificando a thread 
	while (i < N) {
		c[i] = a[i] + b[i];
		i += blockDim.x;
	}
	
}

// código GPU
int main() {
	cudaDeviceReset();
	int* g_a, int* g_b, int* g_c;

	int n = 1024;
	int tamanho = n * sizeof(int);

	// malloc das variáveis a,b e c. liberar espaço na memória
	a = (int*)malloc(tamanho);
	b = (int*)malloc(tamanho);
	c = (int*)malloc(tamanho);

	// malloc da GPU
	cudaMalloc((void**)&g_a, tamanho);
	cudaMalloc((void**)&g_b, tamanho);
	cudaMalloc((void**)&g_c, tamanho);

	// controle dos valores
	for (int i = 0; i < n; i++)
		a[i] = i, b[i] = i;

	//transferindo os dados do host para o device/gpu
	cudaMemcpy(g_a, a, tamanho, cudaMemcpyHostToDevice);
	cudaMemcpy(g_b, b, tamanho, cudaMemcpyHostToDevice);

	// execução do kernel
	somaVec <<< 1, 1024 >>> (n, g_a, g_b, g_c);

	cudaDeviceSynchronize();

	// devolendo para o host
	cudaMemcpy(c, g_c, tamanho, cudaMemcpyDeviceToHost);

	printf(" \n Resultado da Soma: \n");
	for (int i = 0; i < n; i++) {
			printf("\n");
			printf("%d", c[i]);
		}

	// liberando memória
	cudaFree(g_a);
	cudaFree(g_b);
	cudaFree(g_c);
	return 0;

}