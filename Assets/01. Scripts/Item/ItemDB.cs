using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Item DB SO", menuName = "Inventory/ItemDB")] 
public class ItemDB : ScriptableObject
{
    public Item[] itemList;
    public void OnValidate()
    {
        for(int i = 0; i < itemList.Length; i++)
        {
            itemList[i].item_ID = i;
        }
    }
}
