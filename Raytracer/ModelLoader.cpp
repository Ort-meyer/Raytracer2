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

vector<Triangle> ModelLoader::LoadModel(const char * p_fileName)
{
	vector<vec3> t_positions;
	vector<vec2> t_texCoordsCorners;
	vector<vec3> t_corners;
	vector<vec2> t_texCoords;
   vector<int> t_materialIndices;
	t_positions.resize(0);
	t_texCoordsCorners.resize(0);
	t_corners.resize(0);
	t_texCoords.resize(0);
    //FILE* t_file = fopen(p_fileName, "r");
    FILE* t_file;
    //p_fileName = "test.txt";    
    fopen_s(&t_file, p_fileName, "r");


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
        else if (strcmp(t_lineHeader, "v") == 0)// && t_positions.size() < 21)
        {
            vec3 t_position;
            fscanf_s(t_file, "%f %f %f\n", &t_position.x, &t_position.y, &t_position.z);
            mat4x4 t_scaleMat;// = scale(vec3(0.1, 0.1, 0.1) * 5.0f);
			mat4x4 t_rotMat;// = rotate(-(3.1415f / 2.0f), vec3(1, 0, 0));
			mat4x4 t_rotMat2;// = rotate(3.1415f / 2.0f, vec3(0, 0, 1));
			vec3 t_translation = vec3(-2.5, -0.5, 0);
			t_scaleMat = t_rotMat * t_rotMat2 * t_scaleMat;
			//t_scaleMat *= 0.1f;
            t_positions.push_back(t_translation + vec3(t_scaleMat * vec4(t_position,0)));
        }
        // Load texture coordinates
        else if (strcmp(t_lineHeader, "vt") == 0)
        {
			vec2 t_texCoord;
			fscanf_s(t_file, "%f %f\n", &t_texCoord.x, &t_texCoord.y);
			t_texCoords.push_back(t_texCoord);
        }
        // Load normals
        else if (strcmp(t_lineHeader, "vn") == 0)
        {
            // Empty
        }
        // Indexing/faces
        else if (strcmp(t_lineHeader, "f") == 0)
        {
			unsigned int vertexIndex[3], texCoordIndex[3], normalIndex[3];
         int materialIndex = 0;
			//int matches = fscanf_s(t_file, "%d%d/%d %d/%d/%d %d/%d/%d\n", maybe should be %d/%d/%d %d/%d/%d %d/%d/%d\n",
			//	&vertexIndex[0], &texCoordIndex[0], &normalIndex[0],
			//	&vertexIndex[1], &texCoordIndex[1], &normalIndex[1],
			//	&vertexIndex[2], &texCoordIndex[2], &normalIndex[2]);
			int read = fscanf_s(t_file, "%d  %d  %d - %d %d %d - %d",
				&vertexIndex[0], &vertexIndex[1], &vertexIndex[2],
				&texCoordIndex[0], &texCoordIndex[1], &texCoordIndex[2], &materialIndex);
			for (size_t i = 0; i < 3; i++)
			{
				t_corners.push_back(t_positions[vertexIndex[i]-1]);
				t_texCoordsCorners.push_back(t_texCoords[texCoordIndex[i] - 1]);
			}
         t_materialIndices.push_back(materialIndex);
        }
        else if (strcmp(t_lineHeader, "usemtl") == 0)
        {
        }



    }

    // Transform positions into triangles
    vector<Triangle> t_triangles;
	for (size_t j = 0; j < 1; j++) // Number of boxes sortof
	{



		for (size_t i = 0; i < t_corners.size() - 1; i += 3)
		{
			vec3 trans = vec3(1.5, 0, 0);
			vector<vec3> t_cornersPos;
			t_cornersPos.push_back(t_corners[i] + (float)j * trans);
			t_cornersPos.push_back(t_corners[i + 1] + (float)j * trans);
			t_cornersPos.push_back(t_corners[i + 2] + (float)j * trans);

			vector<vec2> t_texCorners;
			t_texCorners.push_back(t_texCoordsCorners[i]);
			t_texCorners.push_back(t_texCoordsCorners[i + 1]);
			t_texCorners.push_back(t_texCoordsCorners[i + 2]);
			t_texCorners.push_back(vec2(t_corners[i].x, t_corners[i].y) * 2.0f);
			t_texCorners.push_back(vec2(t_corners[i + 1].x, t_corners[i + 1].y) * 2.0f);
			t_texCorners.push_back(vec2(t_corners[i + 2].x, t_corners[i + 2].y) * 2.0f);

			//t_texCorners.push_back(vec2(0,0));
			//t_texCorners.push_back(vec2(1, 0));
			//t_texCorners.push_back(vec2(1, 1));


			t_triangles.push_back(Triangle(t_cornersPos, t_texCorners, vec3(1, 1, 0), t_materialIndices[i / 3]));

		}
	}
	//t_triangles.clear();
	//
	//
	//mat4x4 t_roomScaleMat = scale(1.0f * vec3(1, 1, 1));
	//// Floor part
	//t_corners.clear();
	//t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, -1, -1, 1)));
	//t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, -1, 1, 1)));
	//t_corners.push_back(vec3(t_roomScaleMat * vec4(1, -1, 1, 1)));
	//t_triangles.push_back(Triangle(t_corners, vec3(0, 0, 1)));
	//t_corners.clear();
	//t_corners.push_back(vec3(t_roomScaleMat * vec4(1, -1, 1, 1)));
	//t_corners.push_back(vec3(t_roomScaleMat * vec4(1, -1, -1, 1)));
	//t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, -1, -1, 1)));
	//t_triangles.push_back(Triangle(t_corners, vec3(0, 0, 1)));


    return t_triangles;

}
