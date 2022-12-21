using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InputManager : MonoSingleton<InputManager>
{
    public Action KeyAction = null;
    public Action FactoryKeyAction = null;
    private bool _factoryMode = true;
    public bool factoryMode{get{return _factoryMode;}set{_factoryMode = value;SetMode();}}
    public GameObject factoryCamera;
    public GameObject mainCamera;
    public Quaternion cameraRotation = Quaternion.identity;
    public bool stopInput = true;
    public override void Awake() {
        base.Awake();
    }
    public void SetMode()
    {
        factoryCamera?.SetActive(factoryMode);
        mainCamera?.SetActive(!factoryMode);
    }
    public void Update()
    {
        if (Input.anyKey == false && Input.mousePresent == false)
            return;

        if (KeyAction != null && stopInput)
            KeyAction.Invoke();

        if (FactoryKeyAction != null && factoryMode)
            FactoryKeyAction.Invoke();
    }
}