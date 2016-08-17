#version 430

uniform vec3 cameraPosition;
uniform vec3 cameraDirection;

//our frustum rays
uniform vec3 ray00;
uniform vec3 ray10;
uniform vec3 ray11;
uniform vec3 ray01;

//Textures
layout(binding=0,rgba8) uniform image2D destTex;
layout(binding=1) uniform sampler2D boxTextureSampler;

layout (local_size_x = 16, local_size_y = 16) in;


//Lights
uniform vec3[50] lightPositions;
uniform int numLights;

//Diffuse lights
uniform vec3[50] diffuseLightingDirections;
uniform int numDiffuseLights;
//Spheres
uniform vec3[10] spherePositions; // Maximum of of 5 spheres
uniform float[10] sphereRadii;
uniform vec3 [10] sphereColors;
uniform int numSpheres;

//Triangles
uniform vec3[3*40] trianglePositions; // 3 corners times maximum of 10 triangles
uniform vec3[40] triangleColors;
uniform int numTrianglePositions;

// Test variables
uniform int test_windowHeight;
uniform int test_windowWidth;
uniform int test_numberOfLights;
uniform int test_numberOfTriangles;
uniform int test_numberOfBounces;

//BTH logo buffer
layout (std430, binding = 2) buffer shader_data
{
	float bthCorners[500*3];
};

layout (std430, binding = 3) buffer texture_data
{
	float textureCorners[500*2];
};

layout (std430, binding = 4) buffer material_data
{
	float material[200]; // Silly in a way...
};

layout (std430, binding = 5) buffer triangle_indices_data
{
	int triangleMaterialIndices[500];
};

// Hardcoded up-vector. used to figure out specific ups
vec3 cameraUp = vec3(0,1,0);


struct Ray
{
	vec3 dir;
	vec3 pos;
};

struct Hitdata
{
	bool hit;
	vec3 normal;
	vec3 position;
	int hitIndex; // negative means triangle was hit. Solid way to save us a bool...
	vec2 uv;
};

Ray RayDirection() // used to return vec3
{
	float width = test_windowWidth;
	float height = test_windowHeight;
	float normalized_i = ((gl_GlobalInvocationID.x / width) - 0.5);
	float normalized_j = ((gl_GlobalInvocationID.y / height) - 0.5);

	vec3 cameraRight = cross(cameraUp, cameraDirection);
	cameraUp = cross(cameraRight, cameraDirection);

	vec3 imagePoint = normalized_i * cameraRight +
						normalized_j * cameraUp + 
						cameraPosition + cameraDirection;

	Ray retRay;
	retRay.dir = normalize(imagePoint - cameraPosition);
	retRay.pos = imagePoint;
	return retRay;
	//return imagePoint - cameraPosition;
}

// More or less copy pasted from 3D lab 1 
// Kommer inte kunna lösa problem om vi har två objekt efter varandra 


float RayPwnSphere(vec3 rayPos, vec3 rayDir, vec3 spherePos, float sphereRad)
{
	float b = dot(rayDir, rayPos - spherePos);
	float c = dot((rayPos - spherePos), (rayPos - spherePos)) - pow(sphereRad, 2.0f);

	float f = pow(b, 2.0f) - c;

	if(f < 0.0f)
		return -1; // Was a miss
	
	
	float t1 = -b - sqrt(f);
	float t2 = -b + sqrt(f);
	
	if(t1 < 0 || t2 < 0) // Risky?
	{
		return -1;
	}

	float t = min(t1, t2);
		return t;
	
}
// taken from http://stackoverflow.com/questions/13655457/raytracing-ray-triangle-intersection
float RayPwnTriangle(Ray ray, vec3 p0, vec3 p1, vec3 p2)
{
	vec3 e1 = p1 - p0;
	vec3 e2 = p2 - p0;
	//vec3 e1e2 = cross(e1, e2);
	vec3 p = cross(ray.dir, e2);
	//e1e2 = normalize(e1e2);
	float a = dot(e1, p);


	if(a < 0.000001)
	{
		return -1;
	}
	
	float f = 1 / a;
	vec3 s = ray.pos - p0;
	float u = f*(dot(s, p));
	if(u < 0.0 || u > 1.0)
	{
		return -1;
	}
	vec3 q = cross(s, e1);
	float v = f * dot(ray.dir, q);
	if(v < 0.0 || u+v > 1.0)
	{
		return -1;
	}
	
	float t = f * dot(e2, q);
	return t;
}




// Big method that iterates through each geometry and returns hit data for the object we hit
Hitdata ComputeHit(Ray ray)
{

	float hitDistance = 1000000;

	Hitdata hitdata;
	hitdata.hit = false;

	// Iterate through all spheres
	for(int i = 0; i < numSpheres ; ++i)
	{
		float t = RayPwnSphere(ray.pos, ray.dir, spherePositions[i], sphereRadii[i]);
		if(t>0 && t < hitDistance)
		{
			// MOVE THIS SHIT OUT AND DO AT THE END??
			hitDistance = t;
			hitdata.hit = true;
			hitdata.hitIndex = i+1;
			hitdata.position = ray.pos + ray.dir * t;
			hitdata.normal = normalize(hitdata.position - spherePositions[i]);
		}
	}

	// Now iterate through all triangles in ssbo. Yup, this is smart
	for(int i = 0; i < test_numberOfTriangles * 9; i+=9)
	{
		vec3 p0 = vec3(bthCorners[i], bthCorners[i+1], bthCorners[i+2]);
		vec3 p1 = vec3(bthCorners[i+3], bthCorners[i+4], bthCorners[i+5]);
		vec3 p2 = vec3(bthCorners[i+6], bthCorners[i+7], bthCorners[i+8]);
		
		float t = RayPwnTriangle(ray, p0,p1,p2);
		if(t > 0 && t < hitDistance)
		{
			// MOVE THIS SHIT OUT AND DO AT THE END??
			hitDistance = t;
			vec3 normal = cross((p1-p0), (p2-p0));
			hitdata.normal = normalize(normal);
			hitdata.hit = true;
			hitdata.hitIndex  = -((i/9) + 1);
			hitdata.position = ray.pos + ray.dir * t;
		
			float v;
			float w;
			float u;

			vec3 v0 = p1 - p0;
			vec3 v1 = p2 - p0;
			vec3 v2 = hitdata.position - p0;

			float d00 = dot(v0, v0);
			float d01 = dot(v0, v1);
			float d11 = dot(v1, v1);
			float d20 = dot(v2, v0);
			float d21 = dot(v2, v1);

			float denom = d00 * d11 - d01 * d01;

			v = (d11 * d20 - d01 * d21) / denom;
			w = (d00 * d21 - d01 * d20) / denom;
			u = 1.0f - v - w;

			vec2 uvs[3];
			int index = -1 * hitdata.hitIndex;
			index -=1;
			index *=6;
			uvs[0] = vec2(textureCorners[index], textureCorners[index+1]);
			uvs[1] = vec2(textureCorners[index+2], textureCorners[index+3]);
			uvs[2] = vec2(textureCorners[index+4], textureCorners[index+5]);

			hitdata.uv = u * uvs[0] + v * uvs[1] + w * uvs[2];
		}
	}

	// Finally check manual triangles (the room)
	for(int i = 0; i < numTrianglePositions; i++)
	{
		vec3 p0 = trianglePositions[i*3];
		vec3 p1 = trianglePositions[i*3+1];
		vec3 p2 = trianglePositions[i*3+2];
	
		float t = RayPwnTriangle(ray, p0,p1,p2);
		if(t > 0 && t < hitDistance)
		{
			hitDistance = t;
			vec3 normal = cross((p1-p0), (p2-p0));
			hitdata.normal = normalize(normal);
			hitdata.hit = true;
			hitdata.hitIndex  = 0; // Hit the room
			hitdata.position = ray.pos + ray.dir * t;
		}
	
	
	}

	return hitdata;
}

float CalculateLightStrength(vec3 vertexToEye, vec3 lightDirection, vec3 hitNormal, int thisIndex)
{
	float diffuseIntensity = 0.4;
	float specularPower = 4;
	float specularIntensity = 0.6;
	float ambientIntensity = 0.1;

	if(thisIndex < 0) // It's a triangle. Change values to material of triangle
	{
		int matIndex = triangleMaterialIndices[-1*(thisIndex + 1)];
		diffuseIntensity = material[matIndex];
		specularIntensity = material[matIndex+1];
		specularPower = material[matIndex+4];
	}

	float diffuseFactor = dot(normalize(hitNormal), -lightDirection);
	float specularFactor = 0;
	if(diffuseFactor > 0.0001)
	{
		vec3 lightReflect = normalize(reflect(lightDirection, hitNormal));
		specularFactor = dot(vertexToEye, lightReflect);
		if(specularFactor > 0.0001)
		{
			specularFactor = pow(specularFactor, specularPower);
		}
		else
			specularFactor = 0;
	}
	else
		diffuseFactor = 0;

	return (ambientIntensity + diffuseFactor * diffuseIntensity + specularFactor * specularIntensity);


}

float CalculatePointLightLightingOnly(Hitdata hitdata, Ray ray, int thisIndex)
{
	//return lightFactorColor;

	float lightValue = 0;
	// Iterate through all point lights
	for(int i = 0; i < numLights && i < test_numberOfLights; ++i)
	{
		vec3 lightDirection =  hitdata.position - lightPositions[i];
		float distance = length(lightDirection);
		lightDirection = normalize(lightDirection);

		float thisLightValue = CalculateLightStrength(normalize(ray.pos - hitdata.position), lightDirection, hitdata.normal, thisIndex); // Use ray's position instead??

		float attenuation = 0.1 + 0.1 * distance + 0.1 * distance * distance; // Some made up attenuation values

		lightValue += thisLightValue / attenuation;
	}

	// Then get all directional lights
	for(int i = 0; i<numDiffuseLights; i++)
	{
		lightValue += CalculateLightStrength(normalize(cameraPosition - hitdata.position), diffuseLightingDirections[i], hitdata.normal, thisIndex);
	}

	return lightValue;
}

float CalculatePointLightShadowOnly(Hitdata hitdata, Ray ray)
{

	float lightFactorColor = 1;
	for(int i = 0; i < numLights && i < test_numberOfLights; i++)
	{
		// vector between light and where the ray hit an object
		vec3 hitLightVector = lightPositions[i] - hitdata.position;
		// "Angle" between hitLightVector and normal of hit
		float normalLightDot = dot(hitdata.normal, hitLightVector);
		if(normalLightDot > 0.0002)
		{
			// First, see if there's anything in the way.
			Ray shadowRay;
			shadowRay.dir = normalize(hitLightVector);
			shadowRay.pos = hitdata.position;
			Hitdata shadowHitdata = ComputeHit(shadowRay);
			// Hitdata och hitdistance går inte alltid att lita på.
			if(shadowHitdata.hit && length(shadowHitdata.position - shadowRay.pos) <= length(hitLightVector))
			{
				lightFactorColor *= 0.5; // How shadowy shadows become
				
			}
		}
	}
	for(int i = 0; i<numDiffuseLights; i++)
	{
		if(dot(hitdata.normal, - diffuseLightingDirections[i]) > 0)
		{
			Ray shadowRay;
			shadowRay.dir = - diffuseLightingDirections[i];
			shadowRay.pos = hitdata.position;
			Hitdata shadowHitdata = ComputeHit(shadowRay);
			if(shadowHitdata.hit)
			{
				lightFactorColor *= 0.5; // How shadowy shadows become
			}
		}

	}
	return lightFactorColor;
}


void main()
{
	// Get this pixels ray
	Ray ray = RayDirection();
	ray.dir = normalize(ray.dir);
	Hitdata derp;
	
	// Bounce new shit
	vec3 endColor = vec3(0,0,0);
	float reflectionFactor = 0;

	float x = 0.5;

	float lightValue = 0;

	for(int i = 0; i < test_numberOfBounces+1; i++)
	{
		Hitdata hitdata = ComputeHit(ray);
		if(hitdata.hit)
		{
			lightValue = 0.5;
			lightValue = CalculatePointLightLightingOnly(hitdata, ray, hitdata.hitIndex);
			lightValue *= CalculatePointLightShadowOnly(hitdata, ray);
	
			if(hitdata.hitIndex > 0) // Sphere
			{
				if(i == 0)
					reflectionFactor = 0.5;
				vec3 addColor = lightValue * sphereColors[hitdata.hitIndex-1];
				endColor = addColor * reflectionFactor + (1-reflectionFactor) * endColor;
				reflectionFactor = 0.5;
			}
			else if(hitdata.hitIndex == 0) //Hit the world box
			{
				if(i == 0)
					reflectionFactor = 0.5;
				vec3 addColor = lightValue * vec3(1,0,0);
				endColor = addColor * reflectionFactor + (1-reflectionFactor) * endColor;
				reflectionFactor = 0.5;
			}
			else // Triangle
			{
				if(i == 0)
				{
					int materialArrayReflectionSlot = (triangleMaterialIndices[-1*(hitdata.hitIndex+1)]-1) * 5 + 3;
					reflectionFactor = material[materialArrayReflectionSlot];
				}
				vec3 addColor = lightValue * texture(boxTextureSampler, hitdata.uv).xyz;
				endColor = addColor * reflectionFactor + endColor * (1-reflectionFactor);
				int materialArrayReflectionSlot = (triangleMaterialIndices[-1*(hitdata.hitIndex+1)]-1) * 5 + 3;
				reflectionFactor = material[materialArrayReflectionSlot];
				break;
			}
	
			// Change ray for bounce
			ray.pos = hitdata.position;
			ray.dir = normalize(reflect(normalize(ray.dir), normalize(hitdata.normal)));
		}
		else
			break;
	}
	

	ivec2 storePos = ivec2(gl_GlobalInvocationID.xy);
	storePos.y = test_windowHeight - storePos.y;

	imageStore(destTex, storePos, vec4(endColor.xyz,0));
}
