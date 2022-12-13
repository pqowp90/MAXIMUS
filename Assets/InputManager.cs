using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InputManager : MonoSingleton<InputManager>
{
    public Action KeyAction = null;
    public bool _factoryMode = true;
    public bool factoryMode{get{return _factoryMode;}set{_factoryMode = value;SetMode();}}
    public Camera factoryCamera;
    public Camera mainCamera;
    public override void Awake() {
        base.Awake();
        DontDestroyOnLoad(this.gameObject);
    }
    public void SetMode()
    {
        if(factoryCamera)
            factoryCamera.targetDisplay = (!factoryMode)?1:0;
        if(mainCamera)
            mainCamera.targetDisplay = (factoryMode)?1:0;
    }
    public void Update()
    {
        if (Input.anyKey == false && Input.mousePresent == false)
            return;

        if (KeyAction != null)
            KeyAction.Invoke();
    }
}