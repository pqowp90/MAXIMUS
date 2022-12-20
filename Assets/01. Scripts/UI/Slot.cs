using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public enum SlotType
{
    Bullet,
    Skill
}

public class Slot : MonoBehaviour
{
    private Image _icon;
    private Text _amount;
    private GameObject _lockPanel;
    private Item _bullet;

    private void Awake() {
        _icon = transform.Find("Icon").GetComponent<Image>();
        _amount = transform.Find("Text").GetComponent<Text>();
        _lockPanel = transform.Find("ItemLock").gameObject;
    }

    public void Init(Item item)
    {
        _bullet = item;
        _icon.sprite = _bullet.icon;
        _amount.gameObject.SetActive(true);
        AmountReload();
        SlotUnEnable();
    }

    public void Init(Sprite skillIcon)
    {
        _amount.gameObject.SetActive(false);
        _icon.sprite = skillIcon;
        SlotUnEnable();
    }
    
    public void SlotEnable()
    {
        _icon.color = Color.white;
    }

    public void SlotUnEnable()
    {
        _icon.color = UIManager.Instance.unEnableColor;
    }

    public void Lock(bool value)
    {
        _lockPanel.SetActive(value);
    }

    public void AmountReload()
    {
        _amount.text = _bullet.amount.ToString();
    }
}
