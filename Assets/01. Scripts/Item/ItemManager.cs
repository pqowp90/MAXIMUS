using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class ItemManager : MonoSingleton<ItemManager>
{
    [SerializeField]
    public ItemDB inventorySO;                  // Inventory SO

    private Dictionary<Item, int> _enterGoalDictionary = new Dictionary<Item, int>();
    private Dictionary<Item, int> _enterDictionary = new Dictionary<Item, int>();
    private Dictionary<Item, int> _enterCount = new Dictionary<Item, int>();

    [Header("Item Drop")]
    [SerializeField]
    public GameObject poolObj;                // 풀링 부모;
    [SerializeField] private Transform _itemGiveTrm;

    public float dropTime = 60.0f;                

    private void Start()
    {
        PoolManager.CreatePool<DropItem>("DropItem", poolObj, 50);
    }
    public Item TakeItem(int id, int amount)
    {
        Item item = inventorySO.itemList.Find(x => x.item_ID == id);
        if (item == null) return null;
        if (item.amount < amount) return null;
        item.amount -= amount;
        UIManager.Instance.InventoryReload(item);
        return item;
    }

    public DropItem DropItem(Vector3 pos, Item item)
    {
        DropItem itemObj = PoolManager.GetItem<DropItem>("DropItem");
        itemObj.item = item;
        itemObj.meshRenderer.material = itemObj.item.material;
        itemObj.meshFilter.mesh = itemObj.item.mesh;
        itemObj.transform.position = pos + new Vector3(0, 0.5f, 0);

        return itemObj;
    }

    public void DropItem(Vector3 pos, Item item, int amount)
    {
        for(int i = 1; i <= amount; i++)
        {
            DropItem itemObj = PoolManager.GetItem<DropItem>("DropItem");
            itemObj.item = item;
            itemObj.meshRenderer.material = itemObj.item.material;
            itemObj.meshFilter.mesh = itemObj.item.mesh;
            itemObj.transform.position = pos + new Vector3(Random.Range(-0.5f, 0.5f), Random.Range(-0.5f, 2f) + 0.5f, Random.Range(-0.5f, 0.5f));
        }
    }

    public void GetItem(List<DropItem> itemObj, int amount)
    {
        if(!_enterDictionary.ContainsKey(itemObj[0].item))
        {
            _enterGoalDictionary.Add(itemObj[0].item, amount);
            _enterDictionary.Add(itemObj[0].item, 0);
            _enterCount.Add(itemObj[0].item, 1);
        }
        else
        {
            _enterGoalDictionary[itemObj[0].item] *= 10;
            _enterGoalDictionary[itemObj[0].item] += amount;
            _enterCount[itemObj[0].item] *= 10;
        }

        foreach(var obj in itemObj)
        {
            ItemAdd(obj.gameObject);
        }
    }
    
    public void GetItem(Item item, int amount)
    {

        foreach(var _item in inventorySO.itemList)
        {
            if(_item.item_ID == item.item_ID)
            {
                if(_item.isStackable == true)
                {
                    _item.amount += amount;
                    ItemEnterAnimation(new Recipe(item, amount));
                    return;
                }
            }
        }

        item.amount = amount;
        inventorySO.itemList.Add(item);
        ItemEnterAnimation(new Recipe(item, amount));
        UIManager.Instance.InventoryItemAdd(item);
    }
    
    private void ItemAdd(GameObject itemObj)
    {
        Item item = itemObj.GetComponent<DropItem>().item;
        
        foreach(var _item in inventorySO.itemList)
        {
            if(_item.item_ID == item.item_ID)
            {
                if(_item.isStackable == true)
                {
                    _item.amount++;
                    ItemEnterAnimation(itemObj, 1);
                    return;
                }
            }
        }

        item.amount = 1;
        inventorySO.itemList.Add(item);
        ItemEnterAnimation(itemObj, 1);
        UIManager.Instance.InventoryItemAdd(item);
    }

    private void ItemEnter(Item item)
    {
        _enterDictionary[item]++;
        if(_enterDictionary[item] == _enterGoalDictionary[item] / _enterCount[item])
        {
            UIManager.Instance.ItemEnter(item, _enterDictionary[item]);
            _enterCount[item] /= 10;
            _enterDictionary[item] = 0;
            _enterGoalDictionary[item] /= 10;
            if(_enterCount[item] == 0)
            {
                _enterCount.Remove(item);
                _enterDictionary.Remove(item);
                _enterGoalDictionary.Remove(item);
            }
        }
    }

    private void ItemEnterAnimation(GameObject obj, int amount)
    {
        DropItem dItem = obj.GetComponent<DropItem>();
        dItem.OffRb(true);

        Sequence seq = DOTween.Sequence();
        seq.Append(obj.transform.DOMove(_itemGiveTrm.position, 0.5f).SetEase(Ease.InCubic));
        seq.AppendCallback(() => obj.SetActive(false));
        seq.AppendCallback(()=>ItemEnter(dItem.item));
        seq.AppendCallback(()=>UIManager.Instance.InventoryReload(dItem.item));
        seq.AppendCallback(()=>dItem.isEntering = false);
    }
    public void ItemEnterAnimation(Recipe recipe)
    {
        UIManager.Instance.ItemEnter(recipe.item, recipe.count);
        UIManager.Instance.InventoryReload(recipe.item);
    }

    public List<Item> GetItemsByType(ITEM_TYPE iTEM_TYPE)
    {
        return inventorySO.GetItemList(iTEM_TYPE);
    }
    public Item GetItem(int item_id)
    {
        return inventorySO.itemList.FirstOrDefault(i => i.item_ID == item_id);
    }


    public Item GetItemFromInventory(int item_id)
    {
        foreach (var _item in inventorySO.itemList)
        {
            if (_item.item_ID == item_id)
            {
                _item.amount -= 1;
                if(_item.amount <= 0)
                {
                    inventorySO.itemList.Remove(_item);
                }
                return _item;
            }
        }

        return null;
    }
}
