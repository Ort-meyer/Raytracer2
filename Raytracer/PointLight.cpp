#include "PointLight.h"

#include <math.h>

PointLight::PointLight()
{
	
}


PointLight::PointLight(vector<vec3>p_waypoints, vec3 p_color, float p_moveSpeed)
	:m_waypoints(p_waypoints), m_color(p_color), m_moveSpeed(p_moveSpeed)
{
	m_position = m_waypoints[0]; // Slightly unsafe
	m_currentWaypoint = 0;
}

PointLight::~PointLight()
{
}

void PointLight::UpdatePosition()
{
	// TEMPORARY STUFF
	static float t_movement;
	t_movement += m_moveSpeed;
	m_position += sin(t_movement) * vec3(1, 0, 0);
}

vec3 PointLight::GetPosition()
{
	return m_position;
}

vec3 PointLight::GetColor()
{
	return m_color;
}
