#pragma once
#include <glm\glm.hpp>
#include <glm\gtx\transform.hpp>
#include <glm\gtc\matrix_transform.hpp>

using namespace glm;
class DiffuseLight
{
public:
	DiffuseLight();
	DiffuseLight(vec3 p_diffuseLightDirection);
	~DiffuseLight();
	vec3 m_diffuseLightDirection;

	void Update();

private:
	float m_rotation;
};

