#pragma once
#include <glm\glm.hpp>
using namespace glm;
class DiffuseLight
{
public:
	DiffuseLight();
	DiffuseLight(vec3 p_diffuseLightDirection);
	~DiffuseLight();
	vec3 m_diffuseLightDirection;
};

