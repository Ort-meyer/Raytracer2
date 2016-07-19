#pragma once

#include <vector>

#include <glm\glm.hpp>
using namespace std;
using namespace glm;
class Triangle
{
public:
	Triangle();
	Triangle(vector<vec3> p_corners, vec3 p_color);
	~Triangle();
	
	vector<vec3> m_corners;
	vec3 m_color;

	vector<vec3> GetCorners();
	
};

