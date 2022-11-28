using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ConveyorBelt : MonoBehaviour
{
    public int rotation;
    public DropItem item;
    public Vector2Int pos;
    public int GroupID;
    public ConveyorBelt nextConveyorBelt;
    public List<ConveyorBelt> beforeConveyorBelts = new List<ConveyorBelt>();

    private float itemMoveDamp = 10f;
    private void Update() {
        if(item!=null)
            item.transform.position = Vector3.Lerp(item.transform.position, transform.position, itemMoveDamp * Time.deltaTime);
    }
}
