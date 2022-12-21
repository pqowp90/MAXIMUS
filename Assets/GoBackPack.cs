using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GoBackPack : MonoSingleton<GoBackPack>
{
    [SerializeField]
    private Animator backPackAnimator;
    private CameraCtrl cameraCtrl;
    private bool isBackPack = true;
    public override void Awake()
    {
        cameraCtrl = FindObjectOfType<CameraCtrl>();
        cameraCtrl.GoGoBackPack -= delegate{FactoryManager.Instance.UpdateScene();};
        cameraCtrl.GoGoBackPack += delegate{FactoryManager.Instance.UpdateScene();};
    }
    public void GoBag()
    {
        InputManager.Instance.stopInput = !isBackPack;
        backPackAnimator.SetBool("IsBackPack", isBackPack);
        cameraCtrl.isBackPack = isBackPack;
        isBackPack = !isBackPack;
    }


}
