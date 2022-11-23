using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class ItemManager : MonoSingleton<ItemManager>
{
    [SerializeField]
    private ItemDB itemSO;                          // Item SO

    [Header("Item Drop")]
    [SerializeField]
    private GameObject dropItemPrefab;       // 드랍 게임 오브젝트 프리팹   

    public float dropTime = 60.0f;                // 아이템이 드랍되어있는 시간
    

    public void DropItem(Vector3 pos, int id = -1)
    {
        Item drop;
        if(id != -1)
        {
            drop = itemSO.itemList.FirstOrDefault(i => i.item_ID == id);
        }
        else
        {
            drop = itemSO.itemList[Random.Range(0, itemSO.itemList.Length)];
        }

        GameObject itemObj = Instantiate(dropItemPrefab);
        itemObj.GetComponent<SpriteRenderer>().sprite = drop.icon;
        itemObj.transform.localPosition = pos;
    }

    public void GetItem(Item item)
    {

    }
}
