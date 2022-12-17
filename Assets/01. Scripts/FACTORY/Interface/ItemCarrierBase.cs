using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum SpaceType
{
    Solo,
    Multy,
    Connected,
}
[System.Serializable]

public class ItemSpace : MonoBehaviour
{
    public DropItem _itemSpace;
    public DropItem dropItem{set{_itemSpace = value; _itemSpace?.OffRb(true);}get{return _itemSpace;}}
    public Item _connectSO;
    public Item connectSO{get{return _connectSO;}set{_connectSO = value;ChangeSO();}}
    public bool canIn = true;
    public bool canOut = true;
    public SpaceType spaceType = SpaceType.Solo;
    public int count = 0;
    public void Reset() {
        
        connectSO = null;
        dropItem = null;
        count = 0;
    }
    private void ChangeSO()
    {
        if(dropItem)
        {
            dropItem.gameObject.SetActive(false);
            dropItem.item.amount++;
            dropItem = null;
        }
    }
    public void GetNextDropItem()
    {
        if(connectSO != null && dropItem == null)
        {
            if(connectSO.amount > 0){
                connectSO.amount--;
                dropItem = ItemManager.Instance.DropItem(Vector3.zero, connectSO);
            }
        }
    }
    public void GiveItem(ItemSpace _space)
    {

        if(spaceType == SpaceType.Multy)
        {
            if(dropItem == null)
                dropItem = _space.TakeItem();
            else if(dropItem == _space)
                count++;
            else
                return;
        }
        else if(spaceType == SpaceType.Solo)
        {
            if(dropItem == null)
                dropItem = _space.TakeItem();
            else
                return;
        }
    }
    public DropItem TakeItem()
    {
        DropItem temp = dropItem;
        if(spaceType == SpaceType.Connected){
            if(dropItem != null)
            {
                GetNextDropItem();
                temp = dropItem;
                dropItem = null;
            }
        }
        else if(spaceType == SpaceType.Multy)
        {
            if(dropItem != null)
            {
                count--;
                if(count <= 0)
                {
                    count = 0;
                    dropItem = null;
                }
                temp = ItemManager.Instance.DropItem(Vector3.zero, connectSO);
            }
        }
        else if(spaceType == SpaceType.Solo)
        {
            if(dropItem != null)
            {
                count--;
                if(count <= 0)
                {
                    count = 0;
                    dropItem = null;
                }
            }
        }
        
        return temp;
    }
    
}
// public class ItemCarrierBase : MonoBehaviour
// {
//     public ItemSpace space = new ItemSpace();
// }

