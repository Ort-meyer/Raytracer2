#pragma once

#include <glm\glm.hpp>
using namespace glm;
/* 
Returns the new target vector of the camera.
x and y are screen coordinates of the mouse cursor*/
vec3 GetNewTarget(vec3 p_oldTarget, int x, int y);

/*
Returns the new position of the camera.
Key is the key which was pressed*/
vec3 GetNewPosition(vec3 p_oldPosition, char key);