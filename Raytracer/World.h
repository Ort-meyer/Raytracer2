#pragma once

// Standard libraries
#include <vector>

// Our own stuff
#include "PointLight.h"
#include "Sphere.h"

using namespace std;
class World
{
public:
	World();
	~World();

	vector<Sphere*> m_spheres;
	vector<PointLight*> m_pointLights;

	void GetSphereInfo(vector<vec3>& o_spherePositions, vector<float>& o_sphereRadii);

private:
	void SetupWorld();

};

