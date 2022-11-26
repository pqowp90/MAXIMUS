using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class CanvasGroupAlpha : MonoBehaviour
{
    [SerializeField]
    private float fadeDemp = 20f;
    private CanvasGroup canvasGroup;
    [SerializeField]
    private float curAlpha;
    [SerializeField]
    private float realCurAlpha;
    [SerializeField]
    private float showTime = 3f;
    [SerializeField]
    private float timmer = 0f;
    [SerializeField]
    private TMP_Text tMP_Text;




    private void Awake() {
        canvasGroup = GetComponent<CanvasGroup>();
    }
    private void OnDisable() {
        curAlpha = 0f;
        realCurAlpha = 0f;
        canvasGroup.alpha = 0f;
    }
    public void TurnOnOffGroup(bool on, string text = "")
    {
        if(tMP_Text != null)
            tMP_Text.text = text;
        if(on)
        {
            timmer = 0f;
            curAlpha = 1f;
        }
        else
        {
            curAlpha = 0f;
        }
    }
    private void Update() {

        realCurAlpha = Mathf.Lerp(realCurAlpha, curAlpha, Time.deltaTime * fadeDemp);

        canvasGroup.alpha = realCurAlpha;

        if(timmer > showTime)
        {
            curAlpha = 0f;
        }else
        {
            timmer += Time.deltaTime;
        }

    }
}
