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
		Up = 0x10,
		Down = 0x20,

	};

	class InputHelper
	{
	public:


		static InputHelper* GetInstance();

		// Input bitmask. Keys pressed down are 1
		int m_keysPressed = 0;

		// Floats where we store rotations
		float m_deltaPixelsX = 0;
		float m_deltaPixelsY = 0;

		/*
		Updates the bit mask when a key is pressed.
		Called via glut callback*/
		void UpdateKeyDown(char key);

		/*
		Updates the bitmask when a key is released.
		Called via glut callback*/
		void UpdateKeyUp(char key);

		/*
		Warps the mouse to the middle and stores the
		distance it moved last frame (in pixels) in
		member variables*/
		void WarpMouseToMiddle(int x, int y);

	protected:
		InputHelper();
		~InputHelper();

		static InputHelper* m_singleton;
	};
}