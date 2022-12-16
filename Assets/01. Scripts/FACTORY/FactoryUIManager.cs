using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class FactoryUIManager : MonoSingleton<FactoryUIManager>
{
    [SerializeField]
    private LayerMask buildingLayerMask;
    [Header("DropperUI")]
    //-------------------------------------------
    [SerializeField]
    private GameObject dropperUI;
    [SerializeField]
    private GameObject content;
    [SerializeField]
    private Dropper dropper;
    [SerializeField]
    private ItemPanel curItemPanel;
    [SerializeField]
    private GameObject canvas;
    private List<GameObject> dropperItemPanels = new List<GameObject>();
    //-------------------------------------------
    [Header("FactoryUI")]
    //-------------------------------------------
    [SerializeField]
    private GameObject makingUI;
    [SerializeField]
    private GameObject notMakeingUI;
    [SerializeField]
    private GameObject FactoryUI;
    private FactoryBase factoryBase;
    
    [SerializeField]
    private ItemPanel resultPanel;
    [SerializeField]
    private List<GameObject> inputPanelList = new List<GameObject>();
    [SerializeField]
    private GameObject recipePanelParent;
    private List<GameObject> recipePanelList = new List<GameObject>();
    [SerializeField]
    private GameObject poolSpace;


    //-------------------------------------------

    // Start is called before the first frame update
    void Start()
    {
        PoolManager.CreatePool<ItemPanel>("ItemPanel", content);
        PoolManager.CreatePool<Billboard>("Billboard", canvas);
        PoolManager.CreatePool<RecipePanel>("RecipePanel", recipePanelParent);
        PoolManager.CreatePool<ItemPanel>("ItemUI", poolSpace);
        InputManager.Instance.FactoryKeyAction -= PressESC;
        InputManager.Instance.FactoryKeyAction += PressESC;
    }
    public ItemPanel GetItemUI(GameObject parent)
    {
        ItemPanel itemPanel = PoolManager.GetItem<ItemPanel>("ItemUI");
        itemPanel.transform.SetParent(parent.transform);
        return itemPanel;
    }
    public void GiveBackItemUI(GameObject itemPanel)
    {
        itemPanel.transform.SetParent(poolSpace.transform);
        itemPanel.SetActive(false);
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
        if(Camera.main == null)
            return;
        if(Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition),out hit, Mathf.Infinity, buildingLayerMask))
        {
            
            
            Building building = hit.collider.GetComponentInParent<Building>();
            if(building != null)
            {
                if(GridManager.Instance.disassemblyMode || GridManager.Instance.buildingMode)
                    return;
                switch (building.buildingType)
                {
                    
                    case BuildingType.Dropper:
                    {
                        SetDropperUI();
                        
                        dropper = building.GetComponent<Dropper>();
                        if(curItemPanel != null && dropper != null)
                            SetCurItemPanel(dropper.space.connectSO, curItemPanel);
                        dropperUI.SetActive(true);
                    }
                    break;
                    case BuildingType.Foundry:
                    {
                        factoryBase = building.GetComponent<FactoryBase>();
                        if(!factoryBase)return;
                        List<FactoryRecipesSO> recipes = factoryBase.factoryRecipesSO;
                        SetFactoryUI(recipes);
                        FactoryUI.SetActive(true);
                    }
                    break;
                }
            }
        }else{
            CloseTap();
        }
        
    }
    private void PressESC()
    {
        if(Input.GetKeyDown(KeyCode.Escape))
        {
            CloseTap();
        }
    }
    private void CloseTap()
    {
        if(dropperUI.activeSelf)
        {
            dropperUI.SetActive(false);
            dropper = null;
        }
        if(FactoryUI.activeSelf)
        {
            FactoryUI.SetActive(false);
            factoryBase = null;
        }
    }
    private void SetRecipe(FactoryRecipesSO recipesSO)
    {
        if(recipesSO == null)
            return;
        resultPanel.itemImage.sprite = recipesSO.result.item.icon;
        resultPanel.itemText.text = factoryBase.outPutSpace.count.ToString();
        for (int i = 0; i < recipesSO.ingredients.Count; i++)
        {
            ItemPanel itemPanel = PoolManager.GetItem<ItemPanel>("ItemPanel");
            itemPanel.itemImage.sprite = factoryBase.inputSpaces[i].connectSO.icon;
            itemPanel.itemText.text = factoryBase.inputSpaces[i].count.ToString();
            inputPanelList.Add(itemPanel.gameObject);
        }
    }
    private void SetFactoryUI(List<FactoryRecipesSO> recipes)
    {

        // if(factoryBase.curRecipe){
        //     resultPanel.itemImage.sprite = factoryBase.curRecipe.result.item.icon;
        //     resultPanel.itemText.text = factoryBase.curRecipe.result.count.ToString();
            
        // }
        // else{
        //     resultPanel.itemImage.sprite = null;
        // }
        foreach (var item in recipePanelList)
        {
            item.SetActive(false);
        }
        recipePanelList.Clear();
        if(factoryBase.curRecipe == null)
        {
            notMakeingUI.SetActive(true);
            makingUI.SetActive(false);
        }
        else
        {
            notMakeingUI.SetActive(false);
            makingUI.SetActive(true);
        }
        

        foreach (var recipesSO in recipes)
        {
            RecipePanel recipePanel = PoolManager.GetItem<RecipePanel>("RecipePanel");
            recipePanel.ClearRecipe();
            recipePanel.SetRecipe(recipesSO);
            recipePanel.button.onClick.AddListener(delegate{factoryBase.SetRecipe(recipesSO);});
            recipePanelList.Add(recipePanel.gameObject);
        }
        
    }
    
    private void SetDropperUI()
    {
        foreach (var item in dropperItemPanels)
        {
            item.SetActive(false);
        }
        List<Item> items = ItemManager.Instance.GetItemsByType(ITEM_TYPE.Ore);
        foreach (var item in items)
        {
            ItemPanel itemPanel = PoolManager.GetItem<ItemPanel>("ItemPanel");
            SetCurItemPanel(item, itemPanel);
            dropperItemPanels.Add(itemPanel.gameObject);
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
