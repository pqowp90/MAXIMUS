    using System.Collections;
using System.Collections.Generic;
using UnityEngine;



public class ConveyorBelt : MonoBehaviour, BuildingTransfrom 
{
    private int rotation;
    public int Rotation{set{rotation = (value%4 + 4) % 4;}get{return rotation;}}
    public Vector2Int pos;
    public int GroupID;
    public ConveyorBelt nextConveyorBelt;
    public List<ConveyorBelt> beforeConveyorBelts = new List<ConveyorBelt>();

    public ItemSpace space;
    private void Awake() {
        space = gameObject.AddComponent<ItemSpace>();
        space.spaceType = SpaceType.Solo;
    }

    private float itemMoveDamp = 10f;
    private void Start() {
        
    }
    private void Update() {
        if(space.dropItem!=null)
            space.dropItem.transform.position = Vector3.Lerp(space.dropItem.transform.position, transform.position + Vector3.up * 0.3f, itemMoveDamp * Time.deltaTime);
    }
    private void OnDisable() {
        nextConveyorBelt = null;
        beforeConveyorBelts.Clear();
    }
    public void AddToManager(Vector2Int curPos, int curRotation)
    {
        ConveyorBeltManager.Instance.Build(curPos, curRotation, this);
    }

    public void SetTransform(int _rotation, Vector2Int _pos)
    {
        Rotation = _rotation;
        pos = _pos;
    }
}
