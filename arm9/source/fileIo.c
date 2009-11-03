#include <nds.h>
#include <stdio.h>
#include <malloc.h>
#include <fat.h>
#include <unistd.h>

#include "zlib.h"
#include "efs_lib.h"    // include EFS lib

char *pFileBuffer = NULL;

int readFile(char *fileName)
{ 
	FILE *pFile;
	struct stat fileStat;
	size_t result;
	
	if(pFileBuffer != NULL)
		free(pFileBuffer);

	pFile = fopen(fileName, "rb");
	
	if(pFile == NULL)
		return 0;

	if(stat(fileName, &fileStat) != 0)
	{
		fclose(pFile);
		return 0;
	}

	pFileBuffer = (char *) malloc(fileStat.st_size);
	
	if(pFileBuffer == NULL)
	{
		fclose(pFile);
		return 0;
	}
	
	result = fread(pFileBuffer, 1, fileStat.st_size, pFile);
	
	if(result != fileStat.st_size)
	{
		fclose(pFile);
		return 0;
	}

	fclose(pFile);
	
	return result;
}

int readFileBuffer(char *fileName, char *pBuffer)
{ 
	FILE *pFile;
	struct stat fileStat;
	size_t result;

	pFile = fopen(fileName, "rb");
	
	if(pFile == NULL)
		return 0;

	if(stat(fileName, &fileStat) != 0)
	{
		fclose(pFile);
		return 0;
	}

	result = fread(pBuffer, 1, fileStat.st_size, pFile);
	
	if(result != fileStat.st_size)
	{
		fclose(pFile);
		return 0;
	}

	fclose(pFile);
	
	return result;
}

int writeFileBuffer(char *fileName, char *pBuffer)
{ 
	FILE *pFile;
	struct stat fileStat;
	size_t result;

	pFile = fopen(fileName, "wb+");
	
	if(pFile == NULL)
		return 0;
		
	if(stat(fileName, &fileStat) != 0)
	{
		fclose(pFile);
		return 0;
	}

	result = fwrite(pBuffer, 1, fileStat.st_size, pFile);
	
	if(result != fileStat.st_size)
	{
		fclose(pFile);
		return 0;
	}

	fclose(pFile);
	
	return result;
}

int decompressFileBuffer(char *fileName, char *pBuffer, int bufferLen)
{
	FILE *pFile;
	struct stat fileStat;
	size_t result;

	pFile = fopen(fileName, "rb");
	
	if(pFile == NULL)
		return 0;

	if(stat(fileName, &fileStat) != 0)
	{
		fclose(pFile);
		return 0;
	}
	
	void *pZLibBuffer = malloc(fileStat.st_size);
	
	if(pZLibBuffer == NULL)
	{
		fclose(pFile);
		return 0;
	}

	result = fread(pZLibBuffer, 1, fileStat.st_size, pFile);
	
	if(result != fileStat.st_size)
	{
		free(pZLibBuffer);
		fclose(pFile);
		return 0;
	}
	
	uLongf unCompSize = bufferLen;
	uncompress((Bytef*)pBuffer, &unCompSize, (const Bytef*) pZLibBuffer, fileStat.st_size);

	free(pZLibBuffer);
	fclose(pFile);
	
	return result;
}
