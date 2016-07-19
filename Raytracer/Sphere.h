#pragma once

// Third party libraries
#include <glm\glm.hpp>

using namespace glm;

class Sphere
{
public:
	Sphere();
	Sphere(vec3 p_position, vec3 p_color, float p_radius);
	~Sphere();
	
	vec3 m_position;
	vec3 m_color;
	float m_radius;
	
};

