using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Dropper : MonoBehaviour, BuildingTransfrom
{
    private int rotation;
    public int Rotation{set{rotation = (value%4 + 4) % 4;}get{return rotation;}}
    public Vector2Int pos;
    private Billboard billboard;
    public ItemSpace space;
    private void Awake() {
        space = gameObject.AddComponent<ItemSpace>();
        space.Reset();
        space.canIn = false;
        space.spaceType = SpaceType.Connected;
    }
    //public List<Vector2Int> inPutRange = new List<Vector2Int>();

    public void AddToManager(Vector2Int curPos, int curRotation)
    {
        space.Reset();
        
        space.spaceType = SpaceType.Connected;
        DropperManager.Instance.Build(curPos, curRotation, this);
    }
    private void OnDisable() {
        if(billboard != null)
            billboard.gameObject.SetActive(false);
        //billboard.gameObject.SetActive(false);
    }

    public void SetTransform(int _rotation, Vector2Int _pos)
    {
        Rotation = _rotation;
        pos = _pos;

        billboard = PoolManager.GetItem<Billboard>("Billboard");
        if(billboard != null)
            billboard.target = transform;
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(!billboard) return;
        if(space.dropItem == null)
        {
            billboard.UpdateText("None", null);

        }
        else
        {
            billboard.UpdateText(space.dropItem.item.amount.ToString(), space.dropItem.item.icon);
        }
        
    }
}
