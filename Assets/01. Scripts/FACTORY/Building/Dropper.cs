using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Dropper : MonoBehaviour, BuildingTransfrom
{
    public ItemSpace space = new ItemSpace();
    //public List<Vector2Int> inPutRange = new List<Vector2Int>();
    public List<Vector2Int> outPutRange = new List<Vector2Int>();
    public void AddToManager(Vector2Int curPos, int curRotation)
    {
        DropperManager.Instance.Build(curPos, curRotation, this);
    }

    public void SetTransform(int _rotation, Vector2Int _pos)
    {
        
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
