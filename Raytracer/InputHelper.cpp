#include "InputHelper.h"


void Input::UpdateKeyDown(char key)
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

void Input::UpdateKeyUp(char key)
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

