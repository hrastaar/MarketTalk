#ifndef BLOOM_H
#define BLOOM_H

#include <vector>
#include <string>

class BloomFilter
{
private:
	// different hash functions
	unsigned int hash1(std::string);
	unsigned int hash2(std::string);
	unsigned int hash3(std::string);
	// size of the vector
	unsigned int size;

	// stores the bools if the string exists
	std::vector<bool> filter;

public:
	// constructor
	BloomFilter(unsigned int m) : size(m), filter(m, false) {}

	~BloomFilter() {};
	// only true if the three different hash values exist
	bool find(std::string string1);
	// insert into the three different positions
	void insert(std::string string1);
};

#endif