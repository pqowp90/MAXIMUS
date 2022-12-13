using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateByImage : MonoBehaviour
{
    void FixedUpdate()
    {
        transform.localRotation = InputManager.Instance.mainCamera.transform.rotation;
    }
}
