#include "World.h"



World::World()
{
	SetupWorld();
}


World::~World()
{
}

void World::UpdateWorld()
{
	for (size_t i = 0; i < m_pointLights.size(); i++)
	{
		m_pointLights[i]->UpdatePosition();
	}
	for (size_t i = 0; i < m_diffuseLights.size(); i++)
	{
		m_diffuseLights[i]->Update();
	}
}

void World::GetSphereInfo(vector<vec3>& o_spherePositions, vector<float>& o_sphereRadii, vector<vec3>& o_sphereColors)
{
	for (size_t i = 0; i < m_spheres.size(); i++)
	{
		o_spherePositions.push_back(m_spheres[i]->m_position);
		o_sphereRadii.push_back(m_spheres[i]->m_radius);
		o_sphereColors.push_back(m_spheres[i]->m_color);
	}
}

void World::GetPointLightInfor(vector<vec3>& o_pointLightPositions)
{
	for (size_t i = 0; i < m_pointLights.size(); i++)
	{
		o_pointLightPositions.push_back(m_pointLights[i]->GetPosition());
	}
}

void World::GetTriangleInfo(vector<vec3>& o_triangleCorners, vector<vec3>& o_triangleColors)
{
	// Iterate over each triangle
	for (size_t i = 0; i < m_triangles.size(); i++)
	{
		// Iterate over each triangle's corners and toss them into output list
		vector<vec3> t_triangleCorners = m_triangles[i]->GetCorners();
		for (size_t j = 0; j < t_triangleCorners.size(); j++)
		{
			o_triangleCorners.push_back(t_triangleCorners[j]);
		}
		o_triangleColors.push_back(m_triangles[i]->m_color);
	}
}

void World::GetDiffuseLighting(vector<vec3>& o_diffuseLightingDirections)
{
	for (size_t i = 0; i < m_diffuseLights.size(); i++)
	{
		o_diffuseLightingDirections.push_back(normalize(m_diffuseLights[i]->m_diffuseLightDirection));
	}
}

void World::SetupWorld()
{
	// Diffuse lighting
	m_diffuseLights.push_back(new DiffuseLight(vec3(0, 0, 1)));
	// Setup spheres
	m_spheres.push_back(new Sphere(vec3(0, 0, 2), vec3(0, 1, 0), 0.25f));
	m_spheres.push_back(new Sphere(vec3(0, 1, 0), vec3(0, 0, 1), 0.10f));


	//m_spheres.push_back(new Sphere(vec3(0, -0.8, 0), 0.25f));


	// Setup point lights
	vector<vec3> t_waypoints;
	t_waypoints.clear();
	t_waypoints.push_back(vec3(0, 3, 0));
	//m_pointLights.push_back(new PointLight(t_waypoints, vec3(1, 1, 1), 0, vec3(0, 5, 0)));

	//for (int i = -2; i < 2; i++)
	//{
	//	for (int j = -2; j < 2; j++)
	//	{
	//		t_waypoints.clear();
	//		t_waypoints.push_back(vec3(i*0.1, 5,j*0.1));
	//		m_pointLights.push_back(new PointLight(t_waypoints, vec3(1, 1, 1), 0.0, vec3(0, 0.1, 0)));
	//	}
	//}

	// Setup triangles (should be done via obj later)

	vector<vec3> t_corners;

	/// Create ground plane
	//float t_groundScale = 10;
	//float t_groundHeight = -1;
	//
	//// Floor
	//t_corners.clear();
	//t_corners.push_back(vec3(-1 * t_groundScale, t_groundHeight, -1 * t_groundScale));
	//t_corners.push_back(vec3(-1 * t_groundScale, t_groundHeight, 1 * t_groundScale));
	//t_corners.push_back(vec3(1 * t_groundScale, t_groundHeight, 1 * t_groundScale));
	//m_triangles.push_back(new Triangle(t_corners, vec3(0, 1, 0)));
	//t_corners.clear();
	//
	//t_corners.clear();
	//t_corners.push_back(vec3(-1 * t_groundScale, t_groundHeight, -1 * t_groundScale));
	//t_corners.push_back(vec3(1 * t_groundScale, t_groundHeight, 1 * t_groundScale));
	//t_corners.push_back(vec3(1 * t_groundScale, t_groundHeight, -1 * t_groundScale));
	//m_triangles.push_back(new Triangle(t_corners, vec3(0, 0, 1)));



	/// Create world room
	mat4x4 t_roomScaleMat = scale(5.0f * vec3(1, 1, 1));
	// Floor part
	t_corners.clear();
	t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, -1, -1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, -1, 1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(1, -1, 1, 1)));
	m_triangles.push_back(new Triangle(t_corners, vec3(0, 0, 1)));
	t_corners.clear();
	t_corners.push_back(vec3(t_roomScaleMat * vec4(1, -1, 1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(1, -1, -1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, -1, -1, 1)));
	m_triangles.push_back(new Triangle(t_corners, vec3(0, 0, 1)));
	
	// roof part
	t_corners.clear();
	t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, 1, -1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(1, 1, 1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, 1, 1, 1)));
	m_triangles.push_back(new Triangle(t_corners, vec3(0, 0, 1)));
	t_corners.clear();
	t_corners.push_back(vec3(t_roomScaleMat * vec4(1, 1, 1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, 1, -1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(1, 1, -1, 1)));
	m_triangles.push_back(new Triangle(t_corners, vec3(0, 0, 1)));
	
	// Right part
	t_corners.clear();
	t_corners.push_back(vec3(t_roomScaleMat * vec4(1, -1, -1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(1, 1, 1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(1, 1, -1, 1)));
	m_triangles.push_back(new Triangle(t_corners, vec3(0, 0, 1)));
	t_corners.clear();
	t_corners.push_back(vec3(t_roomScaleMat * vec4(1, 1, 1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(1, -1, -1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(1, -1, 1, 1)));
	m_triangles.push_back(new Triangle(t_corners, vec3(0, 0, 1)));
	
	// Left
	t_corners.clear();
	t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, -1, -1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, 1, -1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, 1, 1, 1)));
	m_triangles.push_back(new Triangle(t_corners, vec3(0, 0, 1)));
	t_corners.clear();
	t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, 1, 1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, -1, 1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, -1, -1, 1)));
	m_triangles.push_back(new Triangle(t_corners, vec3(0, 0, 1)));
	
	// Front
	
	t_corners.clear();
	t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, -1, -1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(1, 1, -1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, 1, -1, 1)));
	m_triangles.push_back(new Triangle(t_corners, vec3(0, 0, 1)));
	t_corners.clear();
	t_corners.push_back(vec3(t_roomScaleMat * vec4(1, 1, -1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, -1, -1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(1, -1, -1, 1)));
	m_triangles.push_back(new Triangle(t_corners, vec3(0, 0, 1)));
	
	// Back
	t_corners.clear();
	t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, -1, 1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, 1, 1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(1, 1, 1, 1)));
	m_triangles.push_back(new Triangle(t_corners, vec3(0, 0, 1)));
	t_corners.clear();
	t_corners.push_back(vec3(t_roomScaleMat * vec4(1, 1, 1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(1, -1, 1, 1)));
	t_corners.push_back(vec3(t_roomScaleMat * vec4(-1, -1, 1, 1)));
	m_triangles.push_back(new Triangle(t_corners, vec3(0, 0, 1)));
}
