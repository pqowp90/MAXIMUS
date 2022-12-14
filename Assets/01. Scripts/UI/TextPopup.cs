using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using TMPro;
using static UnityEditor.PlayerSettings;

public class TextPopup : MonoBehaviour
{

    private void Start()
    {
        transform.DOMoveX(transform.position.x + (transform.forward.x * 2), 0.1f);
        transform.DOMoveY(transform.position.y + 2f, 2.5f);
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
