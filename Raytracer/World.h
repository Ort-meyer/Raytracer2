#pragma once

// Standard libraries
#include <vector>

// Our own stuff
#include "PointLight.h"
#include "Sphere.h"
#include "Triangle.h"

using namespace std;
class World
{
public:
	World();
	~World();

	void UpdateWorld();

	void GetSphereInfo(vector<vec3>& o_spherePositions, vector<float>& o_sphereRadii);
	void GetPointLightInfor(vector<vec3>& o_pointLightPositions);
	void GetTriangleInfo(vector<vec3>& o_triangleCorners);

private:
	void SetupWorld();

	vector<Sphere*> m_spheres;
	vector<PointLight*> m_pointLights;
	vector<Triangle*> m_triangles;
};

