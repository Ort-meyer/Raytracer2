#pragma once

// Standard libraries
#include <vector>

// Third party
#include <glm\glm.hpp>

using namespace std;
using namespace glm;
class PointLight
{
public:
	PointLight();
	PointLight(vector<vec3>p_waypoints, vec3 p_color, float p_moveSpeed);
	~PointLight();

	void UpdatePosition();

	vec3 GetPosition();
	vec3 GetColor();

private:
	vec3 m_color;
	vec3 m_position;

	// Patrol stuff. Might be changed later
	float m_moveSpeed;
	vector<vec3> m_waypoints;
	int m_currentWaypoint;

	// Temporary movement stuff
	float m_movement;
};

