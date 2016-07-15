#pragma once

#include <vector>

#include <glm\glm.hpp>
using namespace std;
using namespace glm;
class Triangle
{
public:
	Triangle();
	Triangle(vector<vec3> p_corners);
	~Triangle();
	
	vector<vec3> m_corners;

	vector<vec3> GetCorners();
	
};

