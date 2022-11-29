using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using UnityEngine;

[CreateAssetMenu(fileName = "Item DB SO", menuName = "Inventory/ItemDB")] 
public class ItemDB : ScriptableObject
{
    public List<Item> itemList = new List<Item>();
    public void OnValidate()
    {
        for(int i = 0; i < itemList.Count; i++)
        {
            itemList[i].item_ID = i;
        }
    }

    [ContextMenu("인벤 초기화")]
    public void InventoryReset()
    {
        foreach(Item item in itemList)
        {
            item.amount = 0;
        }
        itemList.Clear();
    }
}
