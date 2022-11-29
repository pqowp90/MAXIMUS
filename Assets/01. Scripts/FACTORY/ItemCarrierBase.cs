using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemCarrierBase : MonoBehaviour
{
    public int rotation;
    public int Rotation{set{rotation = (value%4 + 4) % 4;}get{return rotation;}}

    public Vector2Int pos;

    public List<ConveyorBelt> beforeConveyorBelts = new List<ConveyorBelt>();
    public List<ConveyorBelt> nextConveyorBelts = new List<ConveyorBelt>();

}
