using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using TMPro;

public class TextPopup : MonoBehaviour
{

    private void Start()
    {
        transform.DOMoveY(transform.position.y + 2f, 3f);
        Invoke("TextDestroy", 1.5f);
    }

    private void TextDestroy()
    {
        Sequence seq = DOTween.Sequence();
        seq.Append(GetComponent<TMP_Text>().DOFade(0, 1f));
        seq.AppendCallback(() => Destroy(gameObject));
    }

    private void Update()
    {
        transform.forward = Camera.main.transform.forward;
    }
}
