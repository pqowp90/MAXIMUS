using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using DG.Tweening; 

public class TitleButton : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    private GameObject _selectPanel;

    private void Awake() {
        _selectPanel = transform.Find("SelectPanel").gameObject;
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        _selectPanel.SetActive(true);
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        _selectPanel.SetActive(false);
    }
}
