using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CamearBillboard : MonoBehaviour
{
    public bool reverseFace = false;

    private Camera _cam;

    void Awake()
    { 
        _cam = Camera.main;
    }

    void LateUpdate()
    {
        Vector3 targetPos = transform.position + _cam.transform.rotation * (reverseFace ? Vector3.forward : Vector3.back);
        Vector3 targetOrientation = _cam.transform.rotation * Vector3.up;
        transform.LookAt(targetPos, targetOrientation);
    }
}
