// DemoParser.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include "pch.h"
#include <iostream>
#include <string>
#include <vector>
#include "grammar_specs.tab.h"

extern "C" int yyparse();
extern "C" int yydebug;

class NameValue
{
public:
	NameValue()
	{
	}

	NameValue(const char* lpszName, int iValue) :
		strName(lpszName),
		value(iValue)
	{
	}

	std::string strName;
	int			value;
};

std::vector<NameValue> vecNVPairs;

std::vector<NameValue>::iterator GetNameValue(const std::string strName)
{
	std::vector<NameValue>::iterator theIterator;

	for (theIterator = vecNVPairs.begin(); theIterator != vecNVPairs.end(); theIterator++)
	{
		if ((*theIterator).strName == strName)
		{
			return theIterator;
		}
	}

	return vecNVPairs.end();
}

void SetNameValue(const NameValue nameValue)
{
	std::vector<NameValue>::iterator theIterator;
	int iValueTemp = 0;

	theIterator = GetNameValue(nameValue.strName);

	if (theIterator == vecNVPairs.end())
	{
		vecNVPairs.push_back(nameValue);
	}
	else
	{
		*theIterator = NameValue(nameValue);
	}
}

/* Returns the value of a given symbol. */
extern "C" int symbolVal(char* symbol, int* pValueReceiver)
{
	// Get the NameValue associated with the next IDENTIFIER.
	std::vector<NameValue>::iterator theIterator = GetNameValue(std::string(symbol));

	if (theIterator == vecNVPairs.end())
	{
		*pValueReceiver = 0;
		return 0;
	}
	else
	{
		*pValueReceiver = (*theIterator).value;
		return 1;
	}
}

/* Updates the value of a given symbol. */
extern "C" int updateSymbolVal(char* symbol, int val)
{
	SetNameValue(NameValue(symbol, val));
	return 1;
}

int main()
{
	//yydebug = 1;
	yyparse();
}

// Run program: Ctrl + F5 or Debug > Start Without Debugging menu
// Debug program: F5 or Debug > Start Debugging menu

// Tips for Getting Started: 
//   1. Use the Solution Explorer window to add/manage files
//   2. Use the Team Explorer window to connect to source control
//   3. Use the Output window to see build output and other messages
//   4. Use the Error List window to view errors
//   5. Go to Project > Add New Item to create new code files, or Project > Add Existing Item to add existing code files to the project
//   6. In the future, to open this project again, go to File > Open > Project and select the .sln file
