using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Drop Item Talbe SO", menuName = "Inventory/Items/DropItemTable")]
public class DropItemTableSO : MonoBehaviour
{
    public class DropItemInfo
    {
        public List<Item> itemList;
        public float rate;
    }

    public List<DropItemInfo> itemList;
}



