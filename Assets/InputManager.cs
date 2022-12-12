using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InputManager : MonoSingleton<InputManager>
{
    public Action KeyAction = null;
    public bool factoryMode = true;

    public void Update()
    {
        if (Input.anyKey == false && Input.mousePresent == false)
            return;

        if (KeyAction != null)
            KeyAction.Invoke();
    }
}