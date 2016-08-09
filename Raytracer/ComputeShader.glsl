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



const int numTrianglesRendered = 1000;
const int numBounces = 1;

//BTH logo buffer
layout (std430, binding = 2) buffer shader_data
{
	float bthCorners[500*3];
};

layout (std430, binding = 3) buffer texture_data
{
	float textureCorners[500*2];
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
	int hitIndex;
	vec2 uv;
};

Ray RayDirection() // used to return vec3
{
	float width = 1024;
	float height = 768;
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
	for(int i = 0; i < numTrianglesRendered; i+=9)
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

			float denom = dot(normal, normal);

			float u = 0;
			float v = 0;

			vec3 c;
			// edge0. not needed?
			vec3 edge0 = p1-p0;
			vec3 vp0 = hitdata.position - p0;
			c = cross(edge0, vp0);

			// edge1
			vec3 edge1 = p2-p1;
			vec3 vp1 = hitdata.position-p1;
			c = cross(edge1, vp1);
			u = dot(normal, c);

			// edge2
			vec3 edge2 = p0 - p1;
			vec3 vp2 = hitdata.position - p2;
			c = cross(edge2, vp2);
			v = dot(normal, c);

			u /= denom;
			v /= denom;
			
			hitdata.uv = vec2(u, v);

		}
	}

	return hitdata;
}

float CalculateLightStrength(vec3 vertexToEye, vec3 lightDirection, vec3 hitNormal)
{
	float diffuseIntensity = 0.6;
	float specularPower = 4;
	float matSpecularIntensity = 0.4;
	
	// Simple diffuse calculation
	float diffuseFactor = dot(hitNormal, -lightDirection) * diffuseIntensity;
	// 
	float specularFactor = 0.0f;
	//if(diffuseFactor > 0)
	{
		vec3 lightReflect = normalize(reflect(lightDirection, hitNormal));
		specularFactor = dot(vertexToEye, lightReflect);
		//if(specularFactor > 0)
		{
			specularFactor = matSpecularIntensity * pow(specularFactor, specularPower);
		}
	}
	//return clamp(specularFactor + diffuseFactor, 0.1, 1.0f);
	return diffuseFactor + clamp(specularFactor, 0.1, 1.0f);
	//return diffuseFactor + specularFactor + 0.1;

}

float CalculatePointLightLightingOnly(Hitdata hitdata, Ray ray)
{
	float lightFactorColor = 0.1; // some ambient
	for(int i = 0; i < numLights; ++i)
	{
		vec3 lightDirection =  hitdata.position - lightPositions[i];
		float distance = length(lightDirection);
		lightDirection = normalize(lightDirection);
		
		float lightValue = CalculateLightStrength(cameraPosition - hitdata.position, lightDirection, hitdata.normal);
		
		//float constant = 0.1;
		//float linear = 0.1;
		//float exponant = 0.1;
		
		//float attenuation = constant + linear * distance + exponant * distance * distance;
		//float attenuation = 0.1 + 0.1 * distance + 0.1 * distance * distance;
		
		//lightFactorColor += lightValue / attentuation;
		lightFactorColor += lightValue / (0.1 + 0.1 * distance + 0.1 * distance * distance);
		
		// vector between light and where the ray hit an object
		vec3 hitLightVector = lightPositions[i] - hitdata.position;
		// "Angle" between hitLightVector and normal of hit
		float normalLightDot = dot(hitdata.normal, hitLightVector);
		
		//float inverseLightStrength = 0.145;
		float currentLightColorFactor = normalLightDot;
		//currentLightColorFactor *= 1 - length(hitLightVector) * inverseLightStrength; // This is for light cutoff 
		currentLightColorFactor *= 1 - length(hitLightVector) * 0.145; // This is for light cutoff 
		lightFactorColor += clamp(currentLightColorFactor, 0, 1);

	}
	for(int i = 0; i<numDiffuseLights; i++)
	{
		lightFactorColor += CalculateLightStrength(normalize(cameraPosition - hitdata.position), diffuseLightingDirections[i], hitdata.normal);
	}
	// Ensure there's always ambience
	lightFactorColor = clamp(lightFactorColor, 0.1f, 1.0f);
	return lightFactorColor;
}

float CalculatePointLightShadowOnly(Hitdata hitdata, Ray ray)
{

	float lightFactorColor = 1;
	for(int i = 0; i < numLights; i++)
	{
		// vector between light and where the ray hit an object
		vec3 hitLightVector = lightPositions[i] - hitdata.position;
		// "Angle" between hitLightVector and normal of hit
		float normalLightDot = dot(hitdata.normal, hitLightVector);
		if(normalLightDot > 0)
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
		//lightFactorColor *= 0.5;

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
	for(int i = 0; i < numBounces + 1; i++)
	{
		float lightValue = 0;
		Hitdata hitdata = ComputeHit(ray);
		if(hitdata.hit)
		{
			lightValue = 0.5;
			lightValue = CalculatePointLightLightingOnly(hitdata, ray);
			lightValue *= CalculatePointLightShadowOnly(hitdata, ray);
	
			endColor += vec3(1,0,0) * lightValue;
			if(hitdata.hitIndex > 0)
			{
				endColor += lightValue * sphereColors[hitdata.hitIndex-1];
			}
			else
			{
				//endColor += lightValue * vec3(0,1,0);//triangleColors[(-1*hitdata.hitIndex)-1];
				//endColor += 1 * vec3(textureCorners[i*3], textureCorners[i*3+1], 0);
				//endColor = 1 * vec3(textureCorners[4], textureCorners[5], 0);
				endColor = 1 * texture(boxTextureSampler, hitdata.uv).xyz;
				//endColor = texture(boxTextureSampler, vec2(0,0)).xyz;
				//endColor = vec3(hitdata.uv, 0);
			}
	
			// Change ray for bounce
			ray.pos = hitdata.position;
			ray.dir = normalize(reflect(normalize(ray.dir), normalize(hitdata.normal)));
	
		}
		else
			break;
	}

	ivec2 storePos = ivec2(gl_GlobalInvocationID.xy);
	storePos.y = 768 - storePos.y;

	imageStore(destTex, storePos, vec4(endColor.xyz,0));
}
