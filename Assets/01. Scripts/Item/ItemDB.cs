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
    public List<Item> GetItemList(ITEM_TYPE iTEM_TYPE)
    {
        return itemList.FindAll(i => i.item_type == iTEM_TYPE);
    }
}
