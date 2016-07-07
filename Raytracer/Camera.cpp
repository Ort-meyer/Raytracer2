#include "Camera.h"



Camera::Camera(vec3 p_target, vec3 p_up, vec3 p_position)
	:m_target(normalize(p_target)), m_up(p_up), m_position(p_position)
{
	m_view = lookAt(m_position, m_target + m_position, m_up);
	m_projection = perspectiveFov(90, g_windowWidth, g_windowheight, 0, 10000); // hard-coded zfar

	// UNUSED so far
	m_rotateAngle = 0;
	m_verticalAngle = 0;
	m_horizonalAngle = 3.1415; // pi

	// Image a unit-cope, and use the projectionmatrix to expand it into a frustum
	m_frustum.ray00 = vec3(inverse(GetViewProj())*vec4(-1, -1, 1, 0));
	m_frustum.ray10 = vec3(inverse(GetViewProj())*vec4(1, -1, 1, 0));
	m_frustum.ray11 = vec3(inverse(GetViewProj())*vec4(1, 1, 1, 0));
	m_frustum.ray01 = vec3(inverse(GetViewProj())*vec4(-1, 1, 1, 0));

}

Camera::~Camera()
{
}

mat4 Camera::GetViewProj()
{
	// Slightly haxxy. Can't remember why I do this...
	return rotate(m_rotateAngle, vec3(0, 1, 0));
}

void Camera::Update()
{

}
