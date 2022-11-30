using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemCarrierBase : MonoBehaviour
{
    public DropItem item;
    public DropItem Item{set{item = value; item?.OffRb(true);}get{return item;}}
}
