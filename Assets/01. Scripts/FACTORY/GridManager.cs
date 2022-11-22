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
    Inserter,
    // ...
    Count,
}
public class GridManager : MonoSingleton<GridManager>
{
    [SerializeField]
    private GameObject rightClickUI;
    // 우클릭을 눌러서 취소
    public List<List<Vector2Int>> ranges = new List<List<Vector2Int>>();
    // 앞으로 설치할 렌지들

    [SerializeField]
    private List<Range> rangeGameobjects = new List<Range>();   // 범위표시 프리펩 위치
    private bool buildingMode = false;                          // 건물을 짓는중인가
    private BuildingType curBuilding = BuildingType.Empty;      // 현재 지으려고 하는 빌딩
    public Grid grid = new Grid(1000, 1000);                    // 건물의 정보가 그리드에 저장됨
    private GameObject buildingGameObject = null;               // 미리보기 건물임, 설치하면 고정됨
    [SerializeField]
    private int curRotate = 0;                                  // 현재 건축중인 건물의 각도 여기에 90곱함
    private float realCurRotate = 0;                            // 진짜 보여지는 각도
    [SerializeField]
    private float rotateDemp = 0f;                              //각도댐프
    [SerializeField]
    private LayerMask layerMask;

    private void Awake()
    {
        rightClickUI?.SetActive(buildingMode);
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
        if(Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition),out hit, Camera.main.focalLength, layerMask))
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
                    buildingMode = false;
                    for (int i = 0; i < vector2Ints.Count; i++)
                    {
                        grid.SetGrid(vector2Ints[i] + pos, (int)curBuilding);
                    }

                    buildingGameObject.transform.position = new Vector3(pos.x, 0, pos.y);
                    buildingGameObject.transform.rotation = Quaternion.Euler(new Vector3(0, curRotate * 90f, 0));

                    buildingGameObject = null;

                    

                    RemoveRanges();
                }
            }

            if(Input.GetMouseButtonDown(1)){
                buildingMode = false;
                RemoveRanges();
            }

            if (Input.GetAxis("Mouse ScrollWheel") < 0f ) // forward
            {
                curRotate++;
                for (int j = 0; j < vector2Ints.Count; j++)
                {
                    vector2Ints[j] = new Vector2Int(vector2Ints[j].y, -vector2Ints[j].x);
                }
            }
            else if (Input.GetAxis("Mouse ScrollWheel") > 0f ) // backwards
            {
                curRotate--;
                for (int j = 0; j < vector2Ints.Count; j++)
                {
                    vector2Ints[j] = new Vector2Int(-vector2Ints[j].y, vector2Ints[j].x);
                }
            }
            


            if(buildingGameObject != null){
                buildingGameObject.transform.position = new Vector3(pos.x, 0, pos.y);
                buildingGameObject.transform.rotation = Quaternion.Euler(new Vector3(0, realCurRotate * 90f, 0));
            }

            realCurRotate = Mathf.Lerp(realCurRotate, curRotate, Time.deltaTime * rotateDemp);

            rightClickUI?.SetActive(buildingMode);
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
        rightClickUI?.SetActive(buildingMode);

        for (int i = 0; i < ranges[building].Count; i++)
        {
            rangeGameobjects.Add(PoolManager.GetItem<Range>("InstallationRange"));
        }

        buildingGameObject = PoolManager.GetItem<Building>(curBuilding.ToString()).gameObject;
    }
    private void RemoveRanges()
    {
        buildingGameObject?.SetActive(false);

        for (; 0 < rangeGameobjects.Count;)
        {
            rangeGameobjects[0].gameObject.SetActive(false);
            rangeGameobjects.RemoveAt(0);
        }
    }
}
