using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class DropItemInfo
{
    public Item item;
    public float rate;
}

[CreateAssetMenu(fileName = "Drop Item Table SO", menuName = "Inventory/Items/DropItemTable")]
public class DropItemTableSO : ScriptableObject
{

    public List<DropItemInfo> itemList;
    public Item GetDropItem()
    {
        float sum = 0f;
        for (int i = 0; i < itemList.Count; i++)
        {
            sum += itemList[i].rate;
        }

        float randomValue = UnityEngine.Random.Range(0, sum);
        float tempSum = 0;

        for (int i = 0; i < itemList.Count; i++)
        {
            if (randomValue >= tempSum && randomValue < tempSum + itemList[i].rate)
            {
                return itemList[i].item;
            }
            else
            {
                tempSum += itemList[i].rate;
            }
        }

        return itemList[0].item;
    }
}



