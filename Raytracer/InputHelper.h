#pragma once

#include <glm\glm.hpp>
using namespace glm;

namespace Input
{
    // Input bitmask. Keys pressed down are 1
    static unsigned int g_keysPressed;

    // Floats where we store rotations
    static float g_deltaAngleX = 0;
    static float g_deltaAngleY = 0;

    /*
    Enums for input bitmask*/
    enum class Keys
    {
        W = 0x01,
        S = 0x02,
        A = 0x04,
        D = 0x08,

    };

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
}