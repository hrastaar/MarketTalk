#include "bloom.h"
#include <iostream>

// hash functions
unsigned int BloomFilter::hash1(std::string temp)
{
	unsigned int myHash = 0;
	for(int i = 0; i < temp.size(); i++)
	{
		myHash += temp[i]+((5*temp[i]%size));
		if(i % 2 == 0) myHash += 2*temp[i];
	}
	return myHash;
}

unsigned int BloomFilter::hash2(std::string temp)
{
	unsigned int myHash = 0;
	for(int i = 0; i < temp.size(); i++)
	{
		myHash += (10*(int)temp[i]);
	}
	return myHash;
}

unsigned int BloomFilter::hash3(std::string temp)
{
	unsigned int myHash = 0;
	for(int i = 0; i < temp.size(); i++)
	{
		myHash += (i*(i+1)*(int)temp[i]);
	}
	return myHash;
}

// only true if the three different hash values exist
bool BloomFilter::find(std::string string1) 
{
	return (filter[hash1(string1)% size] && filter[hash2(string1)% size] && filter[hash3(string1)% size]);
}
// insert into the three different positions
void BloomFilter::insert(std::string string1)
{
	// get the three different hash indexes
	unsigned int hashA = hash1(string1);
	unsigned int hashB = hash2(string1);
	unsigned int hashC = hash3(string1);
	// set them equal to true
	filter[hashA] = true;
	filter[hashB] = true;
	filter[hashC] = true;
	// increase size
	size++;
}