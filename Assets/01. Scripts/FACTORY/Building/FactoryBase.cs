using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FactoryBase : MonoBehaviour, BuildingTransfrom
{
    private int rotation;
    private int Rotation{set{rotation = (value%4 + 4) % 4;}get{return rotation;}}
    private Vector2Int pos;
    public List<FactoryRecipesSO> factoryRecipesSO = new List<FactoryRecipesSO>();
    private Billboard billboard;
    [SerializeField]
    private int inputCount = 1;
    protected List<ItemSpace> inputSpaces = new List<ItemSpace>();
    protected ItemSpace outPutSpace;
    

    
    public void AddToManager(Vector2Int curPos, int curRotation)
    {
        //DropperManager.Instance.Build(curPos, curRotation, this);
    }

    public void SetTransform(int _rotation, Vector2Int _pos)
    {
        Rotation = _rotation;
        pos = _pos;

        billboard = PoolManager.GetItem<Billboard>("Billboard");
        if(billboard != null)
            billboard.target = transform;
    }
    private void OnDisable() {
        if(billboard != null)
            billboard.gameObject.SetActive(false);
    }

    void Start()
    {
        outPutSpace = gameObject.AddComponent<ItemSpace>();
        for (int i = 0; i < inputCount; i++)
        {
            inputSpaces.Add(gameObject.AddComponent<ItemSpace>());
        }
    }

    void Update()
    {
        
        
    }
}
