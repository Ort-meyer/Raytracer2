#pragma once
/*
Class that handles the camera attributes*/

// Third party libraries
#include <glm\glm.hpp>
#include <glm\gtx\transform.hpp>
#include <glm\gtc\matrix_transform.hpp>
#include <GL\freeglut.h>

// My stuff
#include "GlobalConstants.h"

using namespace glm;
using namespace std;

// Struct representing the four "corner-rays" of a frustum
struct RayFrustum
{
	vec3 ray10;
	vec3 ray11;
	vec3 ray01;
	vec3 ray00;
};

class Camera
{
public:
	Camera(vec3 target, vec3 up, vec3 position);
	~Camera();

	/*
	Simple update-method where the attributes of the camera
	get update.*/
	void Update();
	/*
	Returns the view projection matrix.
	WARNING! This is slightly haxxy now, for some reason
	I'm sure is extraordinarily intelligent*/
	mat4 GetViewProj();

	
	// Where the camera looks. Only get
	vec3 m_target;
	// Where the camera is positioned. Only get
	vec3 m_position;
	// Up-vector of camera. only get
	vec3 m_up;

	// View matrix of the camera. Only get
	mat4 m_view;
	// Projection matrix. Only get
	mat4 m_projection;

	// Frustum of the camear. Only get
	RayFrustum m_frustum;

private:

	// Private variables to handle rotations. Debug-y.
	float m_rotateAngle, m_horizonalAngle, m_verticalAngle;

    float m_movementSpeed;
	float m_turnSpeed;

    void UpdatePosition();
    void UpdateRotation();
};

