#include "DiffuseLight.h"



DiffuseLight::DiffuseLight()
{
}

DiffuseLight::DiffuseLight(vec3 p_diffuseLightDirection)
	:m_diffuseLightDirection(p_diffuseLightDirection)
{
	m_rotation = 0.02;
}


DiffuseLight::~DiffuseLight()
{
}

void DiffuseLight::Update()
{
	vec4 rotation4 = vec4(m_diffuseLightDirection, 0);
	mat4x4 rotationMat = rotate(m_rotation, vec3(0, 0,0));
	rotation4 = rotationMat * rotation4;
	m_diffuseLightDirection = vec3(rotation4.x, rotation4.y, rotation4.z);
}
