using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class Grid
{
    private int width, height;
    private int[,] gridArray;

    public Grid(int width, int height)
    {
        this.width = width;
        this.height = height;

        gridArray = new int[width, height];
    }
    public bool IsEmpty(Vector2Int pos)
    {
        if(gridArray[(int)pos.x,(int)pos.y] == 0)
            return true;
        return false;
    }
    public Vector2Int IsEmpty(Vector2Int start, Vector2Int end)
    {

        for (int i = 1; i <= Vector2Int.Distance(start, end); i++)
        {
            Vector2Int pos = Vector2Int.RoundToInt(Vector2.Lerp(start, end, i/Vector2.Distance(start, end)));
            if(gridArray[(int)pos.x,(int)pos.y] != 0)
            {
                return  Vector2Int.RoundToInt(Vector2.Lerp(start, end, (i-1)/Vector2.Distance(start, end)));
            }
        }
        return end;
    }
    public void SetGrid(Vector2Int pos, int index)
    {
        gridArray[(int)pos.x,(int)pos.y] = index;
    }
}
public enum BuildingType
{
    Empty = 0,
    Hub,
    Foundation,
    Count,
}
public class GridManager : MonoSingleton<GridManager>
{
    private bool buildingMode = false;
    private BuildingType curBuilding = BuildingType.Empty;

    public Grid grid = new Grid(1000, 1000);

    public void Build(Vector2Int pos, BuildingType buildings)
    {
        if(!Enum.IsDefined(typeof(BuildingType), buildings))
        {
            Debug.LogError("없는 건물입니다");

            return;
        }
        grid.SetGrid(pos, (int)buildings);
        GameObject building = PoolManager.GetItem<Building>(buildings.ToString()).gameObject;
        building.transform.position = new Vector3(pos.x, 0, pos.y);
    }
    private void Awake()
    {
        for (int i = 1; i < (int)BuildingType.Count; i++)
        {
            PoolManager.CreatePool<Building>(((BuildingType)i).ToString(), transform.gameObject);
        }
        Build(new Vector2Int(10, 10), BuildingType.Foundation);
        Build(new Vector2Int(10, 10), BuildingType.Hub);
    }
    Vector3 point;
    private void Update() {
        if(buildingMode)
            BuildingMouse();
        
    }
    private void BuildingMouse()
    {
        point = Camera.main.ScreenToWorldPoint(new Vector3(Input.mousePosition.x, 
				Input.mousePosition.y, -Camera.main.transform.position.z));
        if(Input.GetMouseButtonDown(0))
        {
            
        }
    }
}
