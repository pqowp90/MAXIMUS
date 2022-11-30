using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public interface BuildingTransfrom
{
    void SetTransform(int _rotation, Vector2Int _pos);
}
public class ConveyorBelt : ItemCarrierBase, BuildingTransfrom
{
    private int rotation;
    public int Rotation{set{rotation = (value%4 + 4) % 4;}get{return rotation;}}
    public Vector2Int pos;
    public int GroupID;
    public ConveyorBelt nextConveyorBelt;
    public List<ConveyorBelt> beforeConveyorBelts = new List<ConveyorBelt>();

    private float itemMoveDamp = 10f;
    private void Update() {
        if(item!=null)
            item.transform.position = Vector3.Lerp(item.transform.position, transform.position + Vector3.up * 0.3f, itemMoveDamp * Time.deltaTime);
    }
    private void OnDisable() {
        nextConveyorBelt = null;
        beforeConveyorBelts.Clear();
    }
    public void SetTransform(int _rotation, Vector2Int _pos)
    {
        Rotation = _rotation;
        pos = _pos;
    }
}
