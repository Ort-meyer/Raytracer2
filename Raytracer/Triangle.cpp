#include "Triangle.h"



Triangle::Triangle()
{
}

Triangle::Triangle(vector<vec3> p_corners, vector<vec2> p_texCoords, vec3 p_color)
	:m_corners(p_corners),m_texCoords(p_texCoords), m_color(p_color)
{

}


Triangle::~Triangle()
{
}

vector<vec3> Triangle::GetCorners()
{
	return m_corners;
}

vector<vec2> Triangle::GetTexCoords()
{
	return m_texCoords;
}
