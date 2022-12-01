using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Inserter : MonoBehaviour, BuildingTransfrom
{
    private int rotation;
    public int Rotation{set{rotation = (value%4 + 4) % 4;}get{return rotation;}}
    public Vector2Int pos;
    public ItemCarrierBase nextItemCarrierBase;
    public ItemCarrierBase beforeItemCarrierBase;


    private void OnDisable() {
        //InserterManager.Instance.RemoveInserter(this);
    }
    public void SetTransform(int _rotation, Vector2Int _pos)
    {
        Rotation = _rotation;
        pos = _pos;
    }
}

