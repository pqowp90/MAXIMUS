using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class InventoryPanel : MonoBehaviour
{
    private Item        _item;
    public Item Item => _item;
    private Image       _icon;
    private Text        _amountText;

    private void Awake() {
        _icon = transform.Find("Icon").GetComponent<Image>();
        _amountText = transform.Find("Amount").GetComponent<Text>();
    }

    public void Init(Item item)
    {
        _item = item;
        _icon.sprite = item.icon;
        _amountText.text = item.amount.ToString();
    }

    public void AmountReload()
    {
        _amountText.text = _item.amount.ToString();
    }
}
