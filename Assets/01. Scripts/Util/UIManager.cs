using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using Unity.VisualScripting;
using DG.Tweening;
using UnityEngine.UI;
using UnityEngine.Rendering.PostProcessing;

public class UIManager : MonoSingleton<UIManager>
{
    [SerializeField]
    private GameObject damagePopup;
    [SerializeField] private TMP_Text messageText;
    private Player _player;

    #region Item Enter UI Popup

    public List<GameObject> items = new List<GameObject>();
    [SerializeField] private Canvas _itemCanvas;

    #endregion

    #region GUI

    [Header("Health Bar")]
    [SerializeField] private Text _healthText;
    [SerializeField] private Slider _healthSlider;
    [SerializeField] private Slider _healthLerpSlider;

    [Header("Skill Slot")]
    public Color unEnableColor;
    [SerializeField] private List<Sprite> _skillIcon = new List<Sprite>();
    [SerializeField] private Transform _skillSlotPanel;
    private List<Slot> _slotList = new List<Slot>();
    private int _slotIndex;

    [Header("Item Inventory")]
    private List<InventoryPanel> _inventoryPanels = new List<InventoryPanel>();
    [SerializeField] private Transform _inventoryPanel;
    [SerializeField] private GameObject _inventoryPanelPrefab;

    [Header("Day")]
    [SerializeField] private Sprite _sunIcon;
    [SerializeField] private Sprite _nightIcon;
    [SerializeField] private Text _dayText;
    [SerializeField] private Image _dayIcon;

    #endregion

    [Header("Pause Menu")]
    [SerializeField] private GameObject _pauseMenuPaenl;
    [SerializeField] private GameObject _blur;
    private bool _isPause = false;

    [SerializeField] private GameObject _gameoverPanel;
    [SerializeField] private Image _screenDamageImage;
    public bool isOption = false;

    public override void Awake()
    {
        base.Awake();
        _player = FindObjectOfType<Player>();
    }

    private void Start()
    {
        PoolManager.CreatePool<ItemEnterUI>("ItemEnterUIPrefab", _itemCanvas.gameObject, 10);

        for(int i = 0; i < 4; i++)
            _slotList.Add(_skillSlotPanel.GetChild(i).GetComponent<Slot>());
        SlotInit(SlotType.Bullet);
        InventoryInit();
    }

    #region  Skill Slot
    public void SlotInit(SlotType type)
    {
        for(int i = 0; i < 4; i++)
        {
            if(type == SlotType.Bullet)
            {
                if(BulletManager.Instance.bulletList.Count <= i)
                {
                    _slotList[i].Lock(true);
                }
                else
                {
                    _slotList[i].Lock(false);
                    _slotList[i].Init(BulletManager.Instance.bulletList[i].bulletItem);
                }
            }
            else if(type == SlotType.Skill)
            {
                if(_skillIcon.Count <= i) _slotList[i].Lock(true);
                else
                {
                    _slotList[i].Lock(false);
                    _slotList[i].Init(_skillIcon[i]);
                }
            }
        }
        
        _slotList[0].SlotEnable();
        _slotIndex = 0;
    }

    public void SlotChange()
    {
        _slotList[_slotIndex].SlotUnEnable();
        _slotIndex = BulletManager.Instance.BulletIndex;
        _slotList[_slotIndex].SlotEnable();
    }

    public void SlotAmountReload()
    {
        _slotList[_slotIndex].AmountReload();
    }
    #endregion

    #region Inventory
    public void InventoryInit()
    {
        foreach(var item in _player.inventory.itemList)
        {
            if(item.item_type == ITEM_TYPE.Bullet) continue;

            InventoryItemAdd(item);
        }
    }

    public void InventoryReload(Item item)
    {
        foreach(var panel in _inventoryPanels)
        {
            if(panel.Item == item)
            {
                panel.AmountReload();
            }
        }
    }

    public void InventoryItemAdd(Item item)
    {
        InventoryPanel panel = Instantiate(_inventoryPanelPrefab, _inventoryPanel).GetComponent<InventoryPanel>();
        panel.Init(item);
        _inventoryPanels.Add(panel);
        
        RectTransform rectTrm = _inventoryPanel.parent.GetComponent<RectTransform>();
        rectTrm.sizeDelta = new Vector2(rectTrm.sizeDelta.x, 80 * (_inventoryPanels.Count - 1) + 120);
    }
    #endregion

    #region Health Bar
    public void HelathBarInit()
    {
        _healthText.text = $"{_player.Health} / {_player.MaxHealth}";
        _healthSlider.maxValue = _player.MaxHealth;
        _healthSlider.value = _player.MaxHealth;
        _healthLerpSlider.maxValue = _player.MaxHealth;
        _healthLerpSlider.value = _player.MaxHealth;
    }

    public void HealthBarReload()
    {
        _healthText.text = $"{_player.Health} / {_player.MaxHealth}";
        StartCoroutine(HealthBarLerp());
    }

    private IEnumerator HealthBarLerp()
    {
        _healthSlider.DOValue(_player.Health, 0.2f);
        yield return new WaitForSeconds(0.1f);
        _healthLerpSlider.DOValue(_player.Health, 0.3f);
    }
    #endregion

    #region Day

    public void DayUIReload(bool isSun)
    {
        _dayText.text = $"Day {WaveManager.Instance.Day}";
        _dayIcon.sprite = isSun == true ? _sunIcon : _nightIcon;
    }

    #endregion
    
    public void Popup(Transform pos, string text, bool isPlayer = false)
    {
        var pop = Instantiate(damagePopup);
        pop.transform.position = new Vector3(pos.position.x, pos.position.y + 1f, pos.position.z);
        pop.transform.LookAt(_player.transform);
        pop.transform.DORotate(new Vector3(0, pop.transform.rotation.y, 0), 0);

        TMP_Text popText = pop.GetComponent<TMP_Text>();
        popText.text = text;
        if(isPlayer)
        {
            popText.color = Color.white;
            popText.fontSize = 3f;
        }
    }

    public void ItemEnter(Item item, int amount)
    {
        var ui = PoolManager.GetItem<ItemEnterUI>("ItemEnterUIPrefab");
        ui.itemIcon.sprite = item.icon;
        ui.amountText.text = $"+{amount}";

        items.Add(ui.gameObject);
        ui.transform.position = new Vector3(-130, 130);

        items[items.Count - 1].transform.DOMoveX(200, 0.3f);
        int cnt = items.Count - 1;
        for(int i = 0; i < items.Count - 1; i++)
        {
            items[i].transform.DOMoveY(80 * cnt-- + 130, 0.7f);
        }
    }

    public void Message(string text)
    {
        if(messageText.color.a == 1) messageText.DOFade(0, 0);
        messageText.text = text;
        messageText.DOFade(1, 0.3f);
    }

    public void MessageDown()
    {
        if(messageText.color.a == 1)
            messageText.DOFade(0, 0.3f);
    }

    public void PauseMenu(bool gameover = false)
    {
        _isPause = !_isPause;
        if(gameover) _gameoverPanel.SetActive(true);
        else
            _pauseMenuPaenl.SetActive(_isPause);
        _blur.SetActive(_isPause);
        Cursor.lockState = _isPause ? CursorLockMode.None : CursorLockMode.Locked;
        Cursor.visible = _isPause;
        Time.timeScale = _isPause ? 0 : 1;
    }

    public void ScreenDamage()
    {
        DG.Tweening.Sequence seq = DOTween.Sequence();
        seq.Append(_screenDamageImage.DOFade(0.8f, 0.1f));
        seq.Append(_screenDamageImage.DOFade(0, 0.3f));
    }
}
