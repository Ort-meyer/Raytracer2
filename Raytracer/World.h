#pragma once

// Standard libraries
#include <vector>

// Our own stuff
#include "PointLight.h"
#include "Sphere.h"
#include "Triangle.h"
#include "DiffuseLight.h"


using namespace std;
class World
{
public:
	World();
	~World();

	void UpdateWorld();

	void GetSphereInfo(vector<vec3>& o_spherePositions, vector<float>& o_sphereRadii, vector<vec3>& o_sphereColors);
	void GetPointLightInfor(vector<vec3>& o_pointLightPositions);
	void GetTriangleInfo(vector<vec3>& o_triangleCorners, vector<vec3>& o_triangleColors);
	void GetDiffuseLighting(vector<vec3>& o_diffuseLightingDirections);

	void TenPointLightsTenSpheres(vector<Sphere*>& o_spherePositions, vector<PointLight*>& o_pointLightPositions);

	void OnePointLightsTenSpheres(vector<Sphere*>& o_spherePositions, vector<PointLight*>& o_pointLightPositions);

private:
	void SetupWorld();

	vector<Sphere*> m_spheres;
	vector<PointLight*> m_pointLights;
	vector<Triangle*> m_triangles;
	vector<DiffuseLight*> m_diffuseLights;
};

