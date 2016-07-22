// This class
#include "ModelLoader.h"
// Standard libraries
#include <stdio.h>





using namespace std;
ModelLoader::ModelLoader()
{
}


ModelLoader::~ModelLoader()
{
}

vector<Triangle> ModelLoader::LoadModel(const char * p_fileName)
{

    FILE* t_file = fopen(p_fileName, "r");

    while (true)
    {
        char t_lineHeader[128];
        int t_res = fscanf(t_file, "%s", t_lineHeader);
        if (t_res == EOF)
            break;

        // Load material
        if (strcmp(t_lineHeader, "mtllib") == 0)
        {

        }
        // Load positions
        else if (strcmp(t_lineHeader, "v") == 0)
        {
        }
        // Load texture coordinates
        else if (strcmp(t_lineHeader, "vt") == 0)
        {
        }
        // Load normals
        else if (strcmp(t_lineHeader, "vn") == 0)
        {
        }
        // Indexing/faces
        else if (strcmp(t_lineHeader, "f") == 0)
        {
        }
        else if (strcmp(t_lineHeader, "usemtl") == 0)
        {

        }

    }



    return vector<Triangle>();

}
