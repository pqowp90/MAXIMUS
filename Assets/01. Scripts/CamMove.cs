using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEditor.Animations;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class CamMove : MonoBehaviour
{
    public float rotateSpdX;
    public float rotateSpdY;

    public Transform orientation; // πÊ«‚

    private float _rotationX;
    private float _rotationY;

    private void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    private void LateUpdate()
    {
        float x = Input.GetAxisRaw("Mouse X") * Time.deltaTime * rotateSpdX;
        float y = Input.GetAxisRaw("Mouse Y") * Time.deltaTime * rotateSpdY;

        _rotationY += x;
        _rotationX -= y;
        _rotationX = Mathf.Clamp(_rotationX, -90f, 90f);

        transform.rotation = Quaternion.Euler(_rotationX, _rotationY, 0);
        orientation.rotation = Quaternion.Euler(0, _rotationY, 0);
    }
}
