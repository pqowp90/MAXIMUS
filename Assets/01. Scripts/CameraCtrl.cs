using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class CameraCtrl : MonoBehaviour
{
    [Header("ī�޶� �⺻�Ӽ�")]
    private Transform _camTransform = null; //ī�޶� ĳ���غ�
    public GameObject objTarget = null;
    private Transform _objTargetTransform = null;
    [SerializeField]
    private Transform _lookObj = null;

    [Header("3��Ī ī�޶�")]
    //������ �Ÿ�
    public float distance = 6.0f;

    //�߰��� ����
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
    /// 3��Ī ī�޶�
    /// </summary>
    void ThirdCamera()
    {

        float _objTargetRotationAngle = _objTargetTransform.eulerAngles.y;
        float _objHeight = _objTargetTransform.position.y + height;

        float _nowRotationAngle = _camTransform.eulerAngles.y;
        float _nowHeight = _camTransform.position.y;

        _nowRotationAngle = Mathf.LerpAngle(_nowRotationAngle, _objTargetRotationAngle, rotateDamp * Time.deltaTime);

        _nowHeight = Mathf.Lerp(_nowHeight, _objHeight, heightDamp * Time.deltaTime);

        //����Ƽ�� euler�� �� ������ quaternion���� ��ȯ
        Quaternion _nowRotation = Quaternion.Euler(0f, _nowRotationAngle, 0f);

        _camTransform.position = _objTargetTransform.position;
        //_nowRotation * Vector3.forward: �������
        // ������Ͷ� �Ÿ��� ���� �� ���ϱ� �Ÿ���ŭ �ڷΰ�
        _camTransform.position -= _nowRotation * Vector3.forward * distance;

        _camTransform.position = new Vector3(_camTransform.position.x, _nowHeight, _camTransform.position.z);

        _camTransform.LookAt(_lookObj);
    }

    private void RotateCamera()
    {
        //���콺 x,y �� �� ��������
        float mouseX = Input.GetAxis("Mouse X");
        float mouseY = Input.GetAxis("Mouse Y");

        float rotationX;
        float rotationY;

        //ī�޶��� y������ ���콺(���콺 * ������)����ŭ �����δ�. 
        //���콺�� �������� �ʾҴٸ� 0�̴�.
        rotationX = _objTargetTransform.localEulerAngles.y + mouseX * 0.5f;

        //���̳ʽ� ������ �����ϱ� ���� ������ �������ش�.
        //���� ������ �����ָ� ���̳ʽ��� ������ �ٲ�� ���� Ƣ�� ���� Ȯ�� �� �� �ִ�.
        rotationX = (rotationX > 180.0f) ? rotationX - 360.0f : rotationX;

        //���� y���� ���콺�� ������ ��(���콺 + ������)��ŭ �����ش�.
        rotationY = mouseY * 0.5f;
        //���� ���̳ʽ� ���� ������ �ϱ� ���� 
        rotationY = (rotationY > 180.0f) ? rotationY - 360.0f : rotationY;

        //���콺�� x,y���� ���� x,y��� �ݴ뿩�� �ݴ�� Vector�� ����� �ش�.
        _objTargetTransform.localEulerAngles = new Vector3(-rotationY, rotationX, 0f);
    }
}
