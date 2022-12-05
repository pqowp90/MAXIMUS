using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemCarrierBase : MonoBehaviour
{
    public DropItem item;
    public DropItem Item{set{item = value; item?.OffRb(true);}get{return item;}}
    public bool canIn = true;
    public bool canOut = true;
    public Item itemSpace;
    
    public void GetNextDropItem()
    {
        if(itemSpace != null)
        {
            itemSpace.amount--;
            Item = ItemManager.Instance.DropItem(Vector3.zero, itemSpace.item_ID);
        }
    }
}

