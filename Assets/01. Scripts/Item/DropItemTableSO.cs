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
            sum += itemList[i].rate; //모든 아이템들의 드랍확률 합산
        }

        float randomValue = UnityEngine.Random.Range(0, sum);
        float tempSum = 0;

        for (int i = 0; i < itemList.Count; i++)
        {
            //만약 랜덤값이 tempSum보다 크고 랜덤값이 i번째 아이템 가중치보다 작으면
            if (randomValue >= tempSum && randomValue < tempSum + itemList[i].rate)
            {
                //몇번째 아이템인지 반환
                return itemList[i].item;
            }
            else
            {
                //tempSum에 i번째 아이템 가중치를 더한다.
                tempSum += itemList[i].rate;
            }
        }

        return itemList[0].item;
    }
}



