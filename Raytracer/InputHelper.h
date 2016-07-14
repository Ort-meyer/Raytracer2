#pragma once

#include <glm\glm.hpp>
using namespace glm;

namespace Input
{		
	/*
	Enums for input bitmask*/
	enum class Keys
	{
		W = 0x01,
		S = 0x02,
		A = 0x04,
		D = 0x08,

	};

	class InputHelper
	{
	public:


		static InputHelper* GetInstance();

		// Input bitmask. Keys pressed down are 1
		int g_keysPressed = 0;


		// Floats where we store rotations
		float g_deltaAngleX = 0;
		float g_deltaAngleY = 0;

		/*
		Updates the bit mask when a key is pressed.
		Called via glut callback*/
		void UpdateKeyDown(char key);

		/*
		Updates the bitmask when a key is released.
		Called via glut callback*/
		void UpdateKeyUp(char key);

		/*
		Takes x and y coordinates of the mouse and translates
		into difference */
		void TranslateMouseIntoAngles(int x, int y);

	protected:
		InputHelper();
		~InputHelper();

		static InputHelper* m_singleton;
	};
}