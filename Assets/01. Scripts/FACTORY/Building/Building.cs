using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Reflection;
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
    public int rotate;
    


    private void Awake() 
    {
        string myName = this.gameObject.name;
        myName = myName.Split('(')[0];
        buildingType = Enum.Parse<BuildingType>(myName);
        
    }
    public void SetBuildingType(Vector2Int curPos, int curRotation)
    {
        rotate = curRotation;
        string typeName = buildingType.ToString();
        switch (buildingType)
        {
            case BuildingType.Foundry:
            case BuildingType.SteelWorks:
            typeName = "FactoryBase";
            break;
        }
        var type = GetComponent(typeName);
        if(type != null)
        {
            type.GetType().GetMethod("AddToManager").Invoke(type, new object[]{curPos, curRotation});
        }
        for (int i = 0; i < ((rotate % 4) + 4) % 4; i++)
        {
            for (int j = 0; j < range.Count; j++)
            {
                range[j] = new Vector2Int(range[j].y, -range[j].x);
            }
        }
        foreach (var item in range)
        {
            InserterManager.Instance.FindAdjacency(curPos + item);
        }
        
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
