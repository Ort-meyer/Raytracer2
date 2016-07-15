#pragma once

// Third party libraries
#include <glm\glm.hpp>

using namespace glm;

class Sphere
{
public:
	Sphere();
	Sphere(vec3 p_position, float p_radius);
	~Sphere();
	
	vec3 m_position;
	float m_radius;
	
};

