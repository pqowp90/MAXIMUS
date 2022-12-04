using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.VisualScripting;
using UnityEngine;

public class ItemManager : MonoSingleton<ItemManager>
{
    [SerializeField]
    private ItemDB itemSO;                          // Item SO
    public ItemDB inventorySO;                  // Inventory SO

    [Header("Item Drop")]
    [SerializeField]
    public GameObject poolObj;                // 풀링 부모;

    public float dropTime = 60.0f;                // �������� ����Ǿ��ִ� �ð�

    private void Start()
    {
        PoolManager.CreatePool<DropItem>("DropItem", poolObj, 50);
    }

    public DropItem DropItem(Vector3 pos, int id = -1)
    {
        Item drop;
        if(id != -1)
        {
            drop = itemSO.itemList.FirstOrDefault(i => i.item_ID == id);
        }
        else
        {
            drop = itemSO.itemList[Random.Range(0, itemSO.itemList.Count)];
        }

        DropItem itemObj = PoolManager.GetItem<DropItem>("DropItem");
        itemObj.item = drop;
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
