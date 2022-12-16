using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;

public class ItemEnterUI : MonoBehaviour, IPoolable
{
    private Image       _panelImage;
    public TMP_Text amountText;
    public Image       itemIcon;

    private void Awake()
    {
        _panelImage = GetComponent<Image>();
        amountText = transform.Find("Amount").GetComponent<TMP_Text>();
        itemIcon = transform.Find("Icon").GetComponent<Image>();
    }

    public void OnPool()
    {
        _panelImage.DOFade(0.35f, 0);
        amountText.DOFade(1f, 0);
        itemIcon.DOFade(1f, 0);
        Invoke("FadeOut", 3f);
    }

    private void FadeOut()
    {
        Sequence seq = DOTween.Sequence();
        seq.Append(_panelImage.DOFade(0, 1.5f));
        seq.Join(amountText.DOFade(0, 1.5f));
        seq.Join(itemIcon.DOFade(0, 1.5f));
        seq.AppendCallback(()=>UIManager.Instance.items.Remove(gameObject));
        seq.AppendCallback(()=>gameObject.SetActive(false));
    }
}
