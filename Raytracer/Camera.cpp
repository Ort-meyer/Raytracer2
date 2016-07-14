#include "Camera.h"

#include "InputHelper.h"


Camera::Camera(vec3 p_target, vec3 p_up, vec3 p_position)
	:m_target(normalize(p_target)), m_up(p_up), m_position(p_position)
{
	m_view = lookAt(m_position, m_target + m_position, m_up);
	m_projection = perspectiveFov(90.0f, 1024.0f, 768.0f, 0.5f, 10.0f); // hard-coded zfar
	// UNUSED so far
	m_rotateAngle = 0;
	m_verticalAngle = 0;
	m_horizonalAngle = 3.1415; // pi

	// Image a unit-cope, and use the projectionmatrix to expand it into a frustum
	//m_frustum.ray00 = vec3(inverse(GetViewProj())*vec4(-1, -1, 1, 0));
	//m_frustum.ray10 = vec3(inverse(GetViewProj())*vec4(1, -1, 1, 0));
	//m_frustum.ray11 = vec3(inverse(GetViewProj())*vec4(1, 1, 1, 0));
	//m_frustum.ray01 = vec3(inverse(GetViewProj())*vec4(-1, 1, 1, 0));

	//m_frustum.ray00 = vec3((GetViewProj())*vec4(-1, -1, 1, 0));
	//m_frustum.ray10 = vec3((GetViewProj())*vec4(1, -1, 1, 0));
	//m_frustum.ray11 = vec3((GetViewProj())*vec4(1, 1, 1, 0));
	//m_frustum.ray01 = vec3((GetViewProj())*vec4(-1, 1, 1, 0));

	//m_frustum.ray00 = vec3(inverse(m_projection) *vec4(-1, -1, 1, 0));
	//m_frustum.ray10 = vec3(inverse(m_projection) *vec4(1, -1, 1, 0));	// <--- proper one
	//m_frustum.ray11 = vec3(inverse(m_projection) *vec4(1, 1, 1, 0));
	//m_frustum.ray01 = vec3(inverse(m_projection) *vec4(-1, 1, 1, 0));

	m_frustum.ray00 = vec3(m_projection *vec4(-1, -1, 1, 0));
	m_frustum.ray10 = vec3(m_projection *vec4(1, -1, 1, 0));	// <--- proper one
	m_frustum.ray11 = vec3(m_projection *vec4(1, 1, 1, 0));
	m_frustum.ray01 = vec3(m_projection *vec4(-1, 1, 1, 0));

	//m_frustum.ray00 = vec3(inverse(m_projection) *vec4(-1, -1, 1, 0));
	//m_frustum.ray10 = vec3(inverse(m_projection) *vec4(1, -1, 1, 0));
	//m_frustum.ray11 = vec3(inverse(m_projection) *vec4(1, 1, 1, 0));
	//m_frustum.ray01 = vec3(inverse(m_projection) *vec4(-1, 1, 1, 0));
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
    UpdatePosition();
}

void Camera::UpdatePosition()
{
    using namespace Input;
    /// Check which keys/ are held down
    // Forward and back
    if (g_keysPressed & (int)Keys::W)
    {
        m_position += m_target * g_movementSpeed;
    }

    if (g_keysPressed & (int)Keys::S)
    {
        m_position -= m_target * g_movementSpeed;
    }
    // Sideways
    // Get right vector to move along (Risky if we look too far up)
    vec3 t_up = vec3(0, 1, 0);
    vec3 t_right = cross(t_up, m_target);
    t_right = normalize(t_right);
    if (g_keysPressed & (int)Keys::A)
    {
        m_position += t_right * g_movementSpeed;
    }

    if (g_keysPressed & (int)Keys::D)
    {
        m_position -= t_right  * g_movementSpeed;
    }
}

void Camera::UpdateRotation()
{

}

