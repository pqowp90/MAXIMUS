using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class CameraCtrl : MonoBehaviour
{
    [Header("ī�޶� �⺻�Ӽ�")]
    private Transform _camTransform = null; //ī�޶� ĳ���غ�
    public GameObject objTarget = null;
    private Transform _objTargetTransform = null;
    public Transform player = null;

    [Header("3��Ī ī�޶�")]
    //������ �Ÿ�
    public float distance = 6.0f;

    //�߰��� ����
    public float height = 1.75f;

    public float heightDamp = 2.0f;
    public float rotateDamp = 3.0f;

    private void Update()
    {
        if(Input.GetMouseButton(1))
        {
            float mouseX = Input.GetAxis("Mouse X");
            float rotationX = _camTransform.localEulerAngles.y + mouseX * 10f;
            rotationX = (rotationX > 180.0f) ? rotationX - 360.0f : rotationX;
            _camTransform.localEulerAngles = new Vector3(-_camTransform.rotation.y, rotationX);
        }
    }

    private void LateUpdate()
    {
        if (objTarget == null) return;

        if (_objTargetTransform == null) _objTargetTransform = objTarget.transform;

        ThirdCamera();
    }

    private void Start()
    {
        _camTransform = GetComponent<Transform>();

        if (objTarget != null)
        {
            _objTargetTransform = objTarget.transform;
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

        _camTransform.LookAt(_objTargetTransform);
    }
}