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

    private Vector3 arrowInputDir = Vector3.zero;
    [SerializeField]
    private Vector3 realMove = Vector3.zero;
    private Camera myCamera;
    private Vector3 curRotation = Vector3.zero;
    [SerializeField]
    private float rotationSpeed = 100f;
    // Start is called before the first frame update
    void Awake()
    {
        
    }
    private void Start()
    {
        InputManager.Instance.FactoryKeyAction -= WASD_Move;
        InputManager.Instance.FactoryKeyAction += WASD_Move;
    }

    // Update is called once per frame
    void Update()
    {
        Move();
    }
    private void Move()
    {
        
        MoveRotation();
        Input.GetAxisRaw("Mouse ScrollWheel");
    }
    private void MoveRotation()
    {
        arrowInputDir = new Vector3(Input.GetAxisRaw("ArrowVertical"), Input.GetAxisRaw("ArrowHorizontal"), 0) * Time.deltaTime * rotationSpeed;
        curRotation += arrowInputDir;
        transform.rotation = Quaternion.Euler(curRotation);
    }
    private void WASD_Move()
    {
        inputDir = new Vector3(Input.GetAxisRaw("Horizontal"), 0, Input.GetAxisRaw("Vertical"));
        if(Input.GetKey(KeyCode.Q))
        {
            
        }
        if(Input.GetKey(KeyCode.E))
        {
            
        }
        realMove = Vector3.Lerp(realMove, inputDir.normalized, cameraMoveDemp * Time.deltaTime);
        Quaternion rotate = transform.rotation;

        rotate.x = 0;
        rotate.z = 0;
        transform.localPosition += rotate * (cameraSpeed * realMove * Time.deltaTime);
    }
}
