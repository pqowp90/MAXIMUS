using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class ItemPanel : MonoBehaviour, IPoolable
{
    [SerializeField]
    public Image itemImage;
    [SerializeField]
    public TMP_Text  itemText;
    [SerializeField]
    public TMP_Text  itemDiscription;
    public int itemID;
    public void Awake()
    {
        //itemImage = GetComponentInChildren<Image>();
        //itemText = GetComponentInChildren<TMP_Text>();
    }
    public void OnPool()
    {
    }
    public void ButtonClick()
    {
        FactoryUIManager.Instance.SetDropperItem(itemID);
    }

    
}
