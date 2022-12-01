using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
[Serializable]
public class RenderAndMaterial
{
    public MeshRenderer meshRenderer;
    public Material material1;
    public Material material2;
}
public class Building : MonoBehaviour, IPoolable
{
    public bool _onoff;
    public bool onoff {get{return _onoff;}set{_onoff = value; SetBuildingOnOff(value);}}

    public List<Vector2Int> range = new List<Vector2Int>();
    [SerializeField]
    public bool canJupe = false;
    public BuildingType buildingType;
    [SerializeField]
    private List<RenderAndMaterial> renderAndMaterials = new List<RenderAndMaterial>();
    [SerializeField]
    private List<GameObject> onOffGameObjects = new List<GameObject>();

    private void Awake() 
    {
        string myName = this.gameObject.name;
        myName = myName.Split('(')[0];
        buildingType = Enum.Parse<BuildingType>(myName);
        
    }
    public void SetBuildingType(Vector2Int curPos, int curRotation)
    {
        switch(buildingType)
        {
            case BuildingType.ConveyorBelt:
            ConveyorBelt conveyorBelt = gameObject.GetComponent<ConveyorBelt>();
            ConveyorBeltManager.Instance.Build(curPos, curRotation, conveyorBelt);
            break;
            case BuildingType.Inserter:
            Inserter inserter = gameObject.GetComponent<Inserter>();
            InserterManager.Instance.Build(curPos, curRotation, inserter);
            break;
        }

        InserterManager.Instance.FindAdjacency(curPos);
    }
    public void OnPool()
    {
        onoff = false;
        SetBuildingOnOff(onoff);
    }
    private void SetBuildingOnOff(bool _onoff)
    {
        if(_onoff)
        {
            foreach (var item in renderAndMaterials)
            {
                item.meshRenderer.material = item.material1;
            }
        }
        else{
            foreach (var item in renderAndMaterials)
            {
                item.meshRenderer.material = item.material2;
            }
        }
        foreach (var item in onOffGameObjects)
        {
            item.SetActive(onoff);
        }
    }
}
