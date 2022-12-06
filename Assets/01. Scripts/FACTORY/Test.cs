using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{
    [SerializeField]
    private Item item;
    [ContextMenu("컨베이어벨트에 삽입")]
    public void TestFunc(ConveyorBelt conveyorBelt)
    {
        if(conveyorBelt.space.itemSpace == null)
            conveyorBelt.space.itemSpace = ItemManager.Instance.DropItem(new Vector3(conveyorBelt.pos.x, 0, conveyorBelt.pos.y), item);
    }
}
