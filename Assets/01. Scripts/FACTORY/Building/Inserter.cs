using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Inserter : MonoBehaviour, BuildingTransfrom
{
    private int rotation;
    public int Rotation{set{rotation = (value%4 + 4) % 4;}get{return rotation;}}
    public Vector2Int pos;
    public List<ItemSpace> nextItemCarrierBase = new List<ItemSpace>();
    public ItemSpace beforeItemCarrierBase;


    private void OnDisable() {
        //InserterManager.Instance.RemoveInserter(this);
    }
    public void AddToManager(Vector2Int curPos, int curRotation)
    {
        InserterManager.Instance.Build(curPos, curRotation, this);
        nextItemCarrierBase.Clear();
    }
    public void SetTransform(int _rotation, Vector2Int _pos)
    {
        Rotation = _rotation;
        pos = _pos;
    }

    public void DeleteBuilding()
    {
        if(beforeItemCarrierBase != null)
            if(beforeItemCarrierBase.dropItem!=null){
                Debug.Log("Inserter DeleteBuilding");
                beforeItemCarrierBase.dropItem.gameObject.SetActive(false);
                beforeItemCarrierBase.dropItem = null;
            }
        InserterManager.Instance.Destroy(this);
    }
}

