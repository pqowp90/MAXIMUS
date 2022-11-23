using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;


public class Building : MonoBehaviour, IPoolable
{
    
    public List<Vector2Int> range = new List<Vector2Int>();
    [SerializeField]
    public bool canJupe = false;
    public BuildingType buildingType;
    private void Awake() 
    {
        string myName = this.gameObject.name;
        myName = myName.Split('(')[0];
        Debug.Log(myName);
        buildingType = Enum.Parse<BuildingType>(myName);
    }
    public void OnPool()
    {
        
    }
}
