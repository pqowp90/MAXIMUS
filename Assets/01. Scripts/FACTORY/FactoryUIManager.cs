using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class FactoryUIManager : MonoSingleton<FactoryUIManager>
{
    [SerializeField]
    private LayerMask buildingLayerMask;
    [SerializeField]
    private GameObject dropperUI;
    [SerializeField]
    private Transform content;
    [SerializeField]
    private Dropper dropper;
    [SerializeField]
    private ItemPanel curItemPanel;
    // Start is called before the first frame update
    void Start()
    {
        PoolManager.CreatePool<ItemPanel>("ItemPanel", content.gameObject);
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetMouseButtonDown(0))
        {
            ClickBuilding();
        }
    }
    private void ClickBuilding()
    {
        if(EventSystem.current.IsPointerOverGameObject())
        {
            return;
        }
        RaycastHit hit;
        if(Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition),out hit, Mathf.Infinity, buildingLayerMask))
        {
            SetDropperUI();
            
            Building building = hit.collider.GetComponentInParent<Building>();
            if(building != null)
            {
                if(building.buildingType == BuildingType.Dropper)
                {
                    if(GridManager.Instance.disassemblyMode || GridManager.Instance.buildingMode)
                        return;
                    dropperUI.SetActive(true);
                    dropper = building.GetComponent<Dropper>();
                }
            }
        }else{
            dropperUI.SetActive(false);
            dropper = null;
        }
        if(curItemPanel != null && dropper != null)
            SetCurItemPanel(dropper.space.connectSO, curItemPanel);
    }
    private List<GameObject> itemPanels = new List<GameObject>();
    private void SetDropperUI()
    {
        foreach (var item in itemPanels)
        {
            item.SetActive(false);
        }
        List<Item> items = ItemManager.Instance.GetItemsByType(ITEM_TYPE.Ore);
        foreach (var item in items)
        {
            ItemPanel itemPanel = PoolManager.GetItem<ItemPanel>("ItemPanel");
            SetCurItemPanel(item, itemPanel);
            itemPanels.Add(itemPanel.gameObject);
        }
        
    }
    private void SetCurItemPanel(Item item, ItemPanel _ItemPanel)
    {
        if(!item)
            return;
        _ItemPanel.itemImage.sprite = item.icon;
        _ItemPanel.itemText.text = item.item_name;
        if(_ItemPanel.itemDiscription)
            _ItemPanel.itemDiscription.text = item.explain;
        _ItemPanel.itemID = item.item_ID;

    }
    public void SetDropperItem(int id)
    {
        dropper.space.connectSO = ItemManager.Instance.GetItem(id);
        if(curItemPanel != null && dropper != null)
            SetCurItemPanel(dropper.space.connectSO, curItemPanel);
        //dropperUI.SetActive(false);
    }
}
