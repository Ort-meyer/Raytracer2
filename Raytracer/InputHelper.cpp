// This class
#include "InputHelper.h"

// Third party libraries
#include <GL\freeglut.h>

// My own stuff
#include "GlobalConstants.h"

using namespace Input;

InputHelper* InputHelper::m_singleton = nullptr;

InputHelper::InputHelper()
{
}

void InputHelper::UpdateKeyDown(char key)
{
    switch (key)
    {
    case 'w':
    case 'W':
		m_keysPressed |= (int)Keys::W;
        break;

    case 'a':
    case 'A':
		m_keysPressed |= (int)Keys::A;
        break;

    case 's':
    case 'S':
		m_keysPressed |= (int)Keys::S;
        break;

    case 'd':
    case 'D':
		m_keysPressed |= (int)Keys::D;
        break;

    }
}

void InputHelper::UpdateKeyUp(char key)
{
    switch (key)
    {
    case 'w':
    case 'W':
		m_keysPressed ^= (int)Keys::W;
        break;

    case 'a':
    case 'A':
		m_keysPressed ^= (int)Keys::A;
        break;

    case 's':
    case 'S':
		m_keysPressed ^= (int)Keys::S;
        break;

    case 'd':
    case 'D':
		m_keysPressed ^= (int)Keys::D;
        break;
    }
}

void Input::InputHelper::WarpMouseToMiddle(int x, int y)
{
	glutWarpPointer(g_windowWidth / 2, g_windowheight / 2);
	m_deltaPixelsX = x - g_windowWidth / 2;
	m_deltaPixelsY = y - g_windowheight / 2;

}


InputHelper * InputHelper::GetInstance()
{

	if (m_singleton != nullptr)
	{
		return m_singleton;
	}
	else
	{
		m_singleton = new InputHelper();
		return m_singleton;
	}
}
