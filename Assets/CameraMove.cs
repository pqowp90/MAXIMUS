using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMove : MonoBehaviour
{
    [SerializeField]
    private float cameraSpeed = 0;
    [SerializeField]
    private float cameraMoveDemp = 0;
    [SerializeField]
    private Vector3 inputDir = Vector3.zero;
    [SerializeField]
    private Vector3 realMove = Vector3.zero;
    private Camera myCamera;
    // Start is called before the first frame update
    void Awake()
    {
        myCamera = GetComponent<Camera>();
    }
    private void Start() 
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Move();
    }
    private void Move()
    {
        inputDir = new Vector3(Input.GetAxisRaw("Horizontal"), 0, Input.GetAxisRaw("Vertical"));
        realMove = Vector3.Lerp(realMove, inputDir.normalized, cameraMoveDemp * Time.deltaTime);
        transform.localPosition += cameraSpeed * realMove * Time.deltaTime;
    }
}
