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
    public ItemSpace itemSpace;
    public void SetItemRecipe(Item item, int count)
    {
        itemImage.sprite = item.icon;
        itemText.text = count.ToString();
    }
    public void ResetPanel()
    {
        itemImage.sprite = null;
        itemText.text = "";
    }
    public void ButtonClick()
    {
        FactoryUIManager.Instance.SetDropperItem(itemID);
    }
    private void Update() {
        if(itemSpace != null)
        {
            if(itemSpace.connectSO != null)
            {
                itemImage.sprite = itemSpace.connectSO.icon;
                itemText.text = itemSpace.count.ToString();
            }
        }
    }

    public void OnPool()
    {
    }
}
