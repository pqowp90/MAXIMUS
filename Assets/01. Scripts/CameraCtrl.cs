using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class CameraCtrl : MonoBehaviour
{
    [Header("카메라 기본속성")]
    private Transform _camTransform = null; //카메라 캐싱준비
    public GameObject objTarget = null;
    private Transform _objTargetTransform = null;
    [SerializeField]
    private Transform _lookObj = null;

    [Header("3인칭 카메라")]
    //떨어진 거리
    public float distance = 6.0f;

    //추가된 높이
    public float height = 1.75f;

    public float heightDamp = 2.0f;
    public float rotateDamp = 3.0f;

    private void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;

        _camTransform = GetComponent<Transform>();

        if (objTarget != null)
        {
            _objTargetTransform = objTarget.transform;
        }
    }

    private void LateUpdate()
    {
        if (objTarget == null) return;

        if (_objTargetTransform == null) _objTargetTransform = objTarget.transform;

        ThirdCamera();
        if(Input.GetMouseButton(1))
        {
            RotateCamera();
        }
    }

    /// <summary>
    /// 3인칭 카메라
    /// </summary>
    void ThirdCamera()
    {

        float _objTargetRotationAngle = _objTargetTransform.eulerAngles.y;
        float _objHeight = _objTargetTransform.position.y + height;

        float _nowRotationAngle = _camTransform.eulerAngles.y;
        float _nowHeight = _camTransform.position.y;

        _nowRotationAngle = Mathf.LerpAngle(_nowRotationAngle, _objTargetRotationAngle, rotateDamp * Time.deltaTime);

        _nowHeight = Mathf.Lerp(_nowHeight, _objHeight, heightDamp * Time.deltaTime);

        //유니티가 euler을 못 읽으니 quaternion으로 변환
        Quaternion _nowRotation = Quaternion.Euler(0f, _nowRotationAngle, 0f);

        _camTransform.position = _objTargetTransform.position;
        //_nowRotation * Vector3.forward: 방향백터
        // 방향백터랑 거리랑 곱한 후 빼니까 거리만큼 뒤로감
        _camTransform.position -= _nowRotation * Vector3.forward * distance;

        _camTransform.position = new Vector3(_camTransform.position.x, _nowHeight, _camTransform.position.z);

        _camTransform.LookAt(_lookObj);
    }

    private void RotateCamera()
    {
        //마우스 x,y 축 값 가져오기
        float mouseX = Input.GetAxis("Mouse X");
        float mouseY = Input.GetAxis("Mouse Y");

        float rotationX;
        float rotationY;

        //카메라의 y각도에 마우스(마우스 * 디테일)값만큼 움직인다. 
        //마우스를 움직이지 않았다면 0이다.
        rotationX = _objTargetTransform.localEulerAngles.y + mouseX * 0.5f;

        //마이너스 각도를 조절하기 위해 각도를 조절해준다.
        //각도 조절을 안해주면 마이너스로 각도가 바뀌는 순간 튀는 것을 확인 할 수 있다.
        rotationX = (rotationX > 180.0f) ? rotationX - 360.0f : rotationX;

        //현재 y값에 마우스가 움직인 값(마우스 + 디테일)만큼 더해준다.
        rotationY = mouseY * 0.5f;
        //역시 마이너스 각도 조절을 하기 위해 
        rotationY = (rotationY > 180.0f) ? rotationY - 360.0f : rotationY;

        //마우스의 x,y축이 실제 x,y축과 반대여서 반대로 Vector를 만들어 준다.
        _objTargetTransform.localEulerAngles = new Vector3(-rotationY, rotationX, 0f);
    }
}
