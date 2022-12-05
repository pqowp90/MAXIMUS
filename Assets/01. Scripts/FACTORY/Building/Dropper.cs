using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Dropper : ItemCarrierBase, BuildingTransfrom
{
    public void AddToManager(Vector2Int curPos, int curRotation)
    {
        DropperManager.Instance.Build(curPos, curRotation, this);
    }

    public void SetTransform(int _rotation, Vector2Int _pos)
    {
        throw new System.NotImplementedException();
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
