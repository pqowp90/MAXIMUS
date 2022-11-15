using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class Grid
{
    private int width, height;
    private int[,] gridBuildArray;
    

    public Grid(int width, int height)
    {
        this.width = width;
        this.height = height;

        gridBuildArray = new int[width, height];
    }
    public bool IsEmpty(Vector2Int pos)
    {
        if(gridBuildArray[(int)pos.x,(int)pos.y] == 0)
            return true;
        return false;
    }
    public Vector2Int IsEmpty(Vector2Int start, Vector2Int end)
    {

        for (int i = 1; i <= Vector2Int.Distance(start, end); i++)
        {
            Vector2Int pos = Vector2Int.RoundToInt(Vector2.Lerp(start, end, i/Vector2.Distance(start, end)));
            if(gridBuildArray[(int)pos.x,(int)pos.y] != 0)
            {
                return  Vector2Int.RoundToInt(Vector2.Lerp(start, end, (i-1)/Vector2.Distance(start, end)));
            }
        }
        return end;
    }
    public void SetGrid(Vector2Int pos, int index)
    {
        gridBuildArray[(int)pos.x,(int)pos.y] = index;
    }
}
public enum BuildingType
{
    Empty = 0,
    Foundation,
    Hub,
    Count,
}
public class GridManager : MonoSingleton<GridManager>
{
    [SerializeField]
    private GameObject rightClickUI;
    public List<List<Vector2Int>> ranges = new List<List<Vector2Int>>();

    [SerializeField]
    private List<Range> rangeGameobjects = new List<Range>();
    private bool buildingMode = false;
    private BuildingType curBuilding = BuildingType.Empty;

    public Grid grid = new Grid(1000, 1000);
    public Grid rangeGrid = new Grid(1000, 1000);

    public void Build(Vector2Int pos, BuildingType buildings)
    {
        
        grid.SetGrid(pos, (int)buildings);
        GameObject building = PoolManager.GetItem<Building>(buildings.ToString()).gameObject;
        building.transform.position = new Vector3(pos.x, 0, pos.y);
    }
    private void Awake()
    {
        rightClickUI.SetActive(buildingMode);
        ranges.Add(new List<Vector2Int>());
        for (int i = 1; i < (int)BuildingType.Count; i++)
        {
            ranges.Add(new List<Vector2Int>());
            PoolManager.CreatePool<Building>(((BuildingType)i).ToString(), gameObject);
        }
        PoolManager.CreatePool<Range>("InstallationRange", gameObject, 10);
        //Build(new Vector2Int(10, 10), BuildingType.Foundation);
        //Build(new Vector2Int(10, 10), BuildingType.Hub);
    }
    Vector3 point;
    private void Update() {
        if(buildingMode){
            BuildingMouse();
            
        }
        
    }
    private void BuildingMouse()
    {
        

        RaycastHit hit;
        if(Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition),out hit))
        {
            Vector2Int pos = new Vector2Int(Mathf.RoundToInt(hit.point.x), Mathf.RoundToInt(hit.point.z));
            Debug.DrawLine(Camera.main.transform.position, hit.point, Color.blue, 0.1f);
            List<Vector2Int> vector2Ints = ranges[(int)curBuilding];
            for (int i = 0; i < vector2Ints.Count; i++)
            {
                rangeGameobjects[i].transform.position = new Vector3(Mathf.RoundToInt(vector2Ints[i].x) + pos.x, 0, Mathf.RoundToInt(vector2Ints[i].y) + pos.y);
            }

            bool canBuild = true;

            for (int i = 0; i < vector2Ints.Count; i++)
            {
                if(!grid.IsEmpty(vector2Ints[i] + pos))
                {
                    rangeGameobjects[i].ChangeMaterial(true);
                    canBuild = false;
                }else{
                    rangeGameobjects[i].ChangeMaterial(false);
                }
            }

            if(Input.GetMouseButtonDown(0)){
                if(UnityEngine.EventSystems.EventSystem.current.IsPointerOverGameObject() == true) 
                    return;
                
                
                if(!canBuild) return;

                {
                    Build(pos, curBuilding);
                    buildingMode = false;
                    for (int i = 0; i < vector2Ints.Count; i++)
                    {
                        grid.SetGrid(vector2Ints[i] + pos, 1);
                    }
                    RemoveRanges();
                }
            }
            if(Input.GetMouseButtonDown(1)){
                buildingMode = false;
                RemoveRanges();
            }
            rightClickUI.SetActive(buildingMode);
        }
        
            
        

    }
    public void SetBuilding(int building)
    {
        if(!Enum.IsDefined(typeof(BuildingType), building))
        {
            Debug.LogError("없는 건물입니다");

            return;
        }
        RemoveRanges();
        buildingMode = true;
        curBuilding = (BuildingType)building;
        rightClickUI.SetActive(buildingMode);
        //PoolManager.GetItem<Building>(curBuilding.ToString());
        for (int i = 0; i < ranges[building].Count; i++)
        {
            rangeGameobjects.Add(PoolManager.GetItem<Range>("InstallationRange"));
        }
    }
    private void RemoveRanges()
    {
        for (; 0 < rangeGameobjects.Count;)
        {
            rangeGameobjects[0].gameObject.SetActive(false);
            rangeGameobjects.RemoveAt(0);
        }
    }
}
