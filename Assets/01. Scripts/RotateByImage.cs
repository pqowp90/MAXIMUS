using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateByImage : MonoBehaviour
{
    void FixedUpdate()
    {
        if(InputManager.Instance.mainCamera)
            transform.localRotation = InputManager.Instance.mainCamera.transform.rotation;
    }
}