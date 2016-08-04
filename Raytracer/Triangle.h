#pragma once

#include <vector>

#include <glm\glm.hpp>
using namespace std;
using namespace glm;
class Triangle
{
public:
	Triangle();
	Triangle(vector<vec3> p_corners, vector<vec2> p_texCoords, vec3 p_color);
	~Triangle();
	
	vector<vec3> m_corners;
	vector<vec2> m_texCoords;
	vec3 m_color;

	vector<vec3> GetCorners();
	vector<vec2> GetTexCoords();
};

