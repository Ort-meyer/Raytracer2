#include "InputHelper.h"

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
		g_keysPressed |= (int)Keys::W;
        break;

    case 'a':
    case 'A':
        g_keysPressed |= (int)Keys::A;
        break;

    case 's':
    case 'S':
        g_keysPressed |= (int)Keys::S;
        break;

    case 'd':
    case 'D':
        g_keysPressed |= (int)Keys::D;
        break;

    }
}

void InputHelper::UpdateKeyUp(char key)
{
    switch (key)
    {
    case 'w':
    case 'W':
        g_keysPressed  ^= (int)Keys::W;
        break;

    case 'a':
    case 'A':
        g_keysPressed ^= (int)Keys::A;
        break;

    case 's':
    case 'S':
        g_keysPressed ^= (int)Keys::S;
        break;

    case 'd':
    case 'D':
        g_keysPressed ^= (int)Keys::D;
        break;

    }
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
