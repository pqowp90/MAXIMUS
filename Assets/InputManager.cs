using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InputManager : MonoSingleton<InputManager>
{
    public Action KeyAction = null;
    public bool _factoryMode = true;
    public bool factoryMode{get{return _factoryMode;}set{_factoryMode = value;SetMode();}}
    public GameObject factoryCamera;
    public GameObject mainCamera;
    public override void Awake() {
        base.Awake();
        DontDestroyOnLoad(this.gameObject);
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

        if (KeyAction != null)
            KeyAction.Invoke();
    }
}