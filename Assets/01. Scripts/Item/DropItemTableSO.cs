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
            sum += itemList[i].rate; //��� �����۵��� ���Ȯ�� �ջ�
        }

        float randomValue = UnityEngine.Random.Range(0, sum);
        float tempSum = 0;

        for (int i = 0; i < itemList.Count; i++)
        {
            //���� �������� tempSum���� ũ�� �������� i��° ������ ����ġ���� ������
            if (randomValue >= tempSum && randomValue < tempSum + itemList[i].rate)
            {
                //���° ���������� ��ȯ
                return itemList[i].item;
            }
            else
            {
                //tempSum�� i��° ������ ����ġ�� ���Ѵ�.
                tempSum += itemList[i].rate;
            }
        }

        return itemList[0].item;
    }
}



