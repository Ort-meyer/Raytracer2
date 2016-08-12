#include "PointLight.h"

#include <math.h>


//debug
#include <iostream>
using namespace std;
PointLight::PointLight()
{
	
}


PointLight::PointLight(vector<vec3>p_waypoints, vec3 p_color, float p_moveSpeed, vec3 p_movementVector)
	:m_waypoints(p_waypoints), m_color(p_color), m_moveSpeed(p_moveSpeed), m_movementVector(p_movementVector)
{
	m_position = m_waypoints[0]; // Slightly unsafe
	m_currentWaypoint = 0;
	m_movement = 0;
}

PointLight::~PointLight()
{
}

void PointLight::UpdatePosition()
{
	// TEMPORARY STUFF
	m_movement += m_moveSpeed;
	m_position = m_waypoints[0] + sin(m_movement) * m_movementVector;
	//cout << m_position.y << endl;
}

vec3 PointLight::GetPosition()
{
	return m_position;
}

vec3 PointLight::GetColor()
{
	return m_color;
}
