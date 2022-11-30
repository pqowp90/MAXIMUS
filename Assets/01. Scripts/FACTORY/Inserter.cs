using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Inserter : ItemCarrierBase, BuildingTransfrom
{
    private int rotation;
    public int Rotation{set{rotation = (value%4 + 4) % 4;}get{return rotation;}}
    public Vector2Int pos;
    


    private void OnDisable() {
        
    }
    public void SetTransform(int _rotation, Vector2Int _pos)
    {
        Rotation = _rotation;
        pos = _pos;
    }
}

