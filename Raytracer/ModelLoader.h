#pragma once

// Standard librariers
#include <vector>

// Our stuff
#include "Triangle.h"
using namespace std;
class ModelLoader
{
public:
    ModelLoader();
    ~ModelLoader();

    vector<Triangle> LoadModel(const char* p_fileName);

};

