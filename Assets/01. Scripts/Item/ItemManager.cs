using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.VisualScripting;
using UnityEngine;

public class ItemManager : MonoSingleton<ItemManager>
{
    [SerializeField]
    private ItemDB itemSO;                          // Item SO
    [SerializeField]
    private ItemDB inventorySO;                  // Inventory SO

    [Header("Item Drop")]
    [SerializeField]
    private GameObject _poolObj;                // 풀링 오브젝트가 들어갈 부모 오브젝트

    public float dropTime = 60.0f;                // 아이템이 드랍되어있는 시간

    private void Start()
    {
        PoolManager.CreatePool<DropItem>("DropItem", _poolObj, 50);
    }

    public void DropItem(Vector3 pos, int id = -1)
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

        inventorySO.itemList.Add(item);
    }
}
