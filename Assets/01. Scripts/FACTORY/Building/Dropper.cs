using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Dropper : MonoBehaviour, BuildingTransfrom
{
    private int rotation;
    public int Rotation{set{rotation = (value%4 + 4) % 4;}get{return rotation;}}
    public Vector2Int pos;
    public ItemSpace space = new ItemSpace();
    //public List<Vector2Int> inPutRange = new List<Vector2Int>();
    public List<Vector2Int> outPutRange = new List<Vector2Int>();
    public void AddToManager(Vector2Int curPos, int curRotation)
    {
        DropperManager.Instance.Build(curPos, curRotation, this);
    }

    public void SetTransform(int _rotation, Vector2Int _pos)
    {
        Rotation = _rotation;
        pos = _pos;
    }

    // Start is called before the first frame update
    void Start()
    {
        space.body = transform;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
