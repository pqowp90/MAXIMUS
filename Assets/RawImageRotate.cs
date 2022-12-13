using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RawImageRotate : MonoBehaviour
{
    void FixedUpdate()
    {
        InputManager.Instance.cameraRotation = transform.rotation;
    }
}
