#include "Triangle.h"



Triangle::Triangle()
{
}

Triangle::Triangle(vector<vec3> p_corners, vec3 p_color)
	:m_corners(p_corners), m_color(p_color)
{
}


Triangle::~Triangle()
{
}

vector<vec3> Triangle::GetCorners()
{
	return m_corners;
}
