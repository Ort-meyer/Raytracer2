#include "Triangle.h"



Triangle::Triangle()
{
}

Triangle::Triangle(vector<vec3> p_corners, vector<vec2> p_texCoords, vec3 p_color, int p_materialIndex)
	:m_corners(p_corners),m_texCoords(p_texCoords), m_color(p_color), m_materialIndex(p_materialIndex)
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
