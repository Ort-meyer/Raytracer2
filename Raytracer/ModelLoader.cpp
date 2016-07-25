// This class
#include "ModelLoader.h"
// Standard libraries
#include <stdio.h>
#include <stdlib.h>

#include <glm\gtx\transform.hpp>
#include <glm\gtc\matrix_transform.hpp>



using namespace std;
using namespace glm;
ModelLoader::ModelLoader()
{
}


ModelLoader::~ModelLoader()
{
}

vector<Triangle*> ModelLoader::LoadModel(const char * p_fileName)
{

    //FILE* t_file = fopen(p_fileName, "r");
    FILE* t_file;
    //p_fileName = "test.txt";
    fopen_s(&t_file, p_fileName, "r");
    vector<vec3> t_positions;

    // Load all  positions of OBJ.
    while (true)
    {
        char t_lineHeader[128];
        int t_res = fscanf_s(t_file, "%s", t_lineHeader, _countof(t_lineHeader));
        if (t_res == EOF)
            break;

        // Load material
        if (strcmp(t_lineHeader, "mtllib") == 0)
        {
            // Empty
        }
        // Load positions
        else if (strcmp(t_lineHeader, "v") == 0)
        {
            vec3 t_position;
            fscanf_s(t_file, "%f %f %f\n", &t_position.x, &t_position.y, &t_position.z);
            mat4x4 t_scaleMat = scale(vec3(0.1, 0.1, 0.1));
            t_positions.push_back(vec3(t_scaleMat * vec4(t_position,0)));
        }
        // Load texture coordinates
        else if (strcmp(t_lineHeader, "vt") == 0)
        {
            // Empty
        }
        // Load normals
        else if (strcmp(t_lineHeader, "vn") == 0)
        {
            // Empty
        }
        // Indexing/faces
        else if (strcmp(t_lineHeader, "f") == 0)
        {
            // Empty. Possibly not necessary
        }
        else if (strcmp(t_lineHeader, "usemtl") == 0)
        {
            // Empty
        }



    }

    // Transform positions into triangles
    vector<Triangle*> t_triangles;
    for (size_t i = 0; i < t_positions.size() - 1; i+=3)
    {
        vector<vec3> t_corners;
        t_corners.push_back(t_positions[i]);
        t_corners.push_back(t_positions[i+2]);
        t_corners.push_back(t_positions[i+1]);
        
        t_triangles.push_back(new Triangle(t_corners,vec3(1,1,0)));
    }


    return t_triangles;

}
