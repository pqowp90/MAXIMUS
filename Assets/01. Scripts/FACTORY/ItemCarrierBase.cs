using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[System.Serializable]
public class ItemSpace
{
    public DropItem _itemSpace;
    public DropItem itemSpace{set{_itemSpace = value; _itemSpace?.OffRb(true);}get{return _itemSpace;}}
    public Transform body;
    public Item connectSO;
    public bool canIn = true;
    public bool canOut = true;
    public void GetNextDropItem()
    {
        if(connectSO != null && itemSpace == null)
        {
            if(connectSO.amount > 0){
                connectSO.amount--;
                itemSpace = ItemManager.Instance.DropItem(Vector3.zero, connectSO);
            }
        }
    }
    
}
// public class ItemCarrierBase : MonoBehaviour
// {
//     public ItemSpace space = new ItemSpace();
// }

