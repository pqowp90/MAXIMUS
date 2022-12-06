using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.VisualScripting;
using UnityEngine;

public class ItemManager : MonoSingleton<ItemManager>
{
    [SerializeField]
    public ItemDB inventorySO;                  // Inventory SO

    [Header("Item Drop")]
    [SerializeField]
    public GameObject poolObj;                // 풀링 부모;

    public float dropTime = 60.0f;                // �������� ����Ǿ��ִ� �ð�

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

        return itemObj;
    }

    public void GetItem(Item item)
    {
        foreach(var _item in inventorySO.itemList)
        {
            if(_item.item_ID == item.item_ID)
            {
                if(_item.isStackable == true)
                {
                    _item.amount += 1;
                    return;
                }
            }
        }

        item.amount = 1;
        inventorySO.itemList.Add(item);
    }
    public List<Item> GetItemsByTypeFromSO(ITEM_TYPE iTEM_TYPE)
    {
        return itemSO.GetItemList(iTEM_TYPE);
    }
    public List<Item> GetItemsByType(ITEM_TYPE iTEM_TYPE)
    {
        return inventorySO.GetItemList(iTEM_TYPE);
    }
    public Item GetItem(int item_id)
    {
        return itemSO.itemList.FirstOrDefault(i => i.item_ID == item_id);
    }
    public Item GetItemFromSO(int item_id)
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
