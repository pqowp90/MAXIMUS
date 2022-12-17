using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using DG.Tweening;

public class ItemManager : MonoSingleton<ItemManager>
{
    [SerializeField]
    public ItemDB inventorySO;                  // Inventory SO

    [Header("Item Drop")]
    [SerializeField]
    public GameObject poolObj;                // 풀링 부모;
    [SerializeField] private Transform _itemGiveTrm;

    public float dropTime = 60.0f;                

    private void Start()
    {
        PoolManager.CreatePool<DropItem>("DropItem", poolObj, 50);
    }

    public DropItem DropItem(Vector3 pos, Item item)
    {
        DropItem itemObj = PoolManager.GetItem<DropItem>("DropItem");
        itemObj.item = item;
        itemObj.meshRenderer.material = itemObj.item.material;
        itemObj.meshFilter.mesh = itemObj.item.mesh;
        itemObj.transform.position = pos + new Vector3(0, 0.5f, 0);
        UIManager.Instance.ItemEnter(item, 1);

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

    private List<GameObject> flyingObts = new List<GameObject>();
    public void GetItem(GameObject itemObj, int amount)
    {
        if (flyingObts.Contains(itemObj) == true) return;

        Item item = itemObj.GetComponent<DropItem>().item;
        flyingObts.Add(itemObj);
        
        foreach(var _item in inventorySO.itemList)
        {
            if(_item.item_ID == item.item_ID)
            {
                if(_item.isStackable == true)
                {
                    _item.amount += amount;
                    ItemEnterAnimation(itemObj, amount);
                    return;
                }
            }
        }

        item.amount = amount;
        inventorySO.itemList.Add(item);
        ItemEnterAnimation(itemObj, amount);
    }

    private void ItemEnterAnimation(GameObject obj, int amount)
    {
        obj.GetComponent<DropItem>().OffRb(true);

        Sequence seq = DOTween.Sequence();
        seq.Append(obj.transform.DOMove(_itemGiveTrm.position, 0.5f).SetEase(Ease.InCubic));
        seq.AppendCallback(() => obj.SetActive(false));
        seq.AppendCallback(()=>UIManager.Instance.ItemEnter(obj.GetComponent<DropItem>().item, amount));
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
