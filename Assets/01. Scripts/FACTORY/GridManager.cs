using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using TMPro;
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
    ConveyorBelt,
    Hub,
    Inserter,
    // ...
    Count,
}
public enum BuildMode
{
    
    Single,
    Jupe,

}
public class GridManager : MonoSingleton<GridManager>
{
    [SerializeField]
    private TMP_Text curBuildingName;
    [SerializeField]
    private BuildMode buildMode = BuildMode.Single;
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
    private List<GameObject> buildingGameObject = new List<GameObject>();               // 미리보기 건물임, 설치하면 고정됨
    [SerializeField]
    private int curRotate = 0;                                  // 현재 건축중인 건물의 각도 여기에 90곱함
    private float realCurRotate = 0;                            // 진짜 보여지는 각도
    [SerializeField]
    private float rotateDemp = 0f;                              //각도댐프
    [SerializeField]
    private LayerMask groundLayerMask;
    [SerializeField]
    private LayerMask buildingLayerMask;
    private bool juping = false;
    private Vector2Int jupingPos = Vector2Int.zero;
    [SerializeField]
    private bool disassemblyMode = false;

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
        }else if(disassemblyMode)
        {
            DisassemblyMouse();
        }
        if(Input.GetKeyDown(KeyCode.F)){
            disassemblyMode = !disassemblyMode;
        }
    }
    private void DisassemblyMouse()
    {
        RaycastHit hit;
        if(Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition),out hit, Mathf.Infinity, buildingLayerMask))
        {
            
            Building building = hit.collider.GetComponentInParent<Building>();
            RemoveRanges();
            GetRanges((int)building.buildingType, true);
            List<Vector2Int> vector2Ints = ranges[(int)building.buildingType];
            for (int i = 0; i < vector2Ints.Count; i++) 
            {
                rangeGameobjects[i].transform.position = new Vector3(Mathf.RoundToInt(vector2Ints[i].x) + building.transform.position.x, 0, Mathf.RoundToInt(vector2Ints[i].y) + building.transform.position.z);
            }
        }
        else
        {
            RemoveRanges();
        }
    }
    private void BuildingMouse()
    {
        

        RaycastHit hit;
        if(Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition),out hit, Mathf.Infinity, groundLayerMask))
        {
            Vector2Int pos = new Vector2Int(Mathf.RoundToInt(hit.point.x), Mathf.RoundToInt(hit.point.z));
            Debug.DrawLine(Camera.main.transform.position, hit.point, Color.blue, 0.1f);
            List<Vector2Int> vector2Ints = ranges[(int)curBuilding];
            
            

            
            if(buildMode == BuildMode.Single)
            {
                for (int i = 0; i < vector2Ints.Count; i++) 
                {
                    rangeGameobjects[i].transform.position = new Vector3(Mathf.RoundToInt(vector2Ints[i].x) + pos.x, 0, Mathf.RoundToInt(vector2Ints[i].y) + pos.y);
                }
                if(buildingGameObject.Count>0){
                    buildingGameObject[0].transform.position = new Vector3(pos.x, 0, pos.y);
                }
            }
                    
            else if(buildMode == BuildMode.Jupe)
            {
                if(juping){
                    Vector2Int jupePos = pos - jupingPos;
                    if(Mathf.Abs(jupePos.x)>Mathf.Abs(jupePos.y))
                    {
                        jupePos.y = 0;
                    }
                    else
                    {
                        jupePos.x = 0;
                    }
                    SetListByCount((int)jupePos.magnitude+1);

                    for (int i = 0; i < buildingGameObject.Count; i++)
                    {
                        Vector2 Vec = (jupePos.magnitude == 0)?Vector2.zero:(Vector2.Lerp(Vector3.zero, new Vector2(jupePos.x, jupePos.y), i/Vector2.Distance(Vector3.zero, new Vector2(jupePos.x, jupePos.y))));
                        buildingGameObject[i].transform.position = new Vector3(Vec.x + jupingPos.x, 0, Vec.y + jupingPos.y);
                        rangeGameobjects[i].transform.position = new Vector3(Vec.x + jupingPos.x, 0, Vec.y + jupingPos.y);
                    }
                }
                else
                {
                    if(buildingGameObject.Count>0){
                        buildingGameObject[0].transform.position = new Vector3(pos.x, 0, pos.y);
                        rangeGameobjects[0].transform.position = new Vector3(pos.x, 0, pos.y);
                    }
                }
            }

            bool canBuild = true;


            for (int i = 0; i < rangeGameobjects.Count; i++)
            {
                Vector2 rangePos = new Vector2(rangeGameobjects[i].transform.position.x, rangeGameobjects[i].transform.position.z);
                if(!grid.IsEmpty(Vector2Int.RoundToInt(rangePos)))
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
                    
                    



                    switch(buildMode)
                    {
                        case BuildMode.Single:
                        RemoveRanges();
                        buildingMode = false;

                        for (int i = 0; i < vector2Ints.Count; i++)
                        {
                            grid.SetGrid(vector2Ints[i] + pos, (int)curBuilding);
                        }
                        if(buildingGameObject.Count>0){
                            buildingGameObject[0].transform.position = new Vector3(pos.x, 0, pos.y);
                        }
                            
                        foreach (var item in buildingGameObject)
                        {
                            item.transform.rotation = Quaternion.Euler(new Vector3(0, realCurRotate * 90f, 0));
                        }

                        break;
                        case BuildMode.Jupe:
                        if(juping == false)
                        {
                            juping = true;
                            jupingPos = pos;
                        }
                        else
                        {
                            for (int i = 0; i < rangeGameobjects.Count; i++)
                            {
                                Vector2 rangePos = new Vector2(rangeGameobjects[i].transform.position.x, rangeGameobjects[i].transform.position.z);
                                grid.SetGrid(Vector2Int.RoundToInt(rangePos), (int)curBuilding);
                            }
                            juping = false;
                            RemoveRanges();
                            buildingMode = false;
                        }
                        
                        break;
                    }



                }
            }
            

            if(Input.GetMouseButtonDown(1)){
                buildingMode = false;
                juping = false;
                RemoveBuildings();
                RemoveRanges();
            }

            if(Input.GetKeyDown(KeyCode.F)){
                buildingMode = false;
                juping = false;
                RemoveBuildings();
                RemoveRanges();
                disassemblyMode = true;
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
            


            if(buildingGameObject.Count>0){
                foreach (var item in buildingGameObject)
                {
                    item.transform.rotation = Quaternion.Euler(new Vector3(0, realCurRotate * 90f, 0));
                }
            }



            realCurRotate = Mathf.Lerp(realCurRotate, curRotate, Time.deltaTime * rotateDemp);

            rightClickUI?.SetActive(buildingMode);
        }
    }
    private void SetListByCount(int cnt)
    {
        for (;;)
        {
            if(buildingGameObject.Count > cnt)
            {
                buildingGameObject[0].SetActive(false);
                buildingGameObject.Remove(buildingGameObject[0]);
                rangeGameobjects[0].gameObject.SetActive(false);
                rangeGameobjects.Remove(rangeGameobjects[0]);
            }
            if(buildingGameObject.Count < cnt)
            {
                buildingGameObject.Add(PoolManager.GetItem<Building>(curBuilding.ToString()).gameObject);
                GetRanges((int)curBuilding);
            }
            if(buildingGameObject.Count == cnt)
            {
                break;
            }
        }
    }
    public void SetBuilding(int building)
    {
        if(!Enum.IsDefined(typeof(BuildingType), building))
        {
            Debug.LogError("없는 건물입니다");

            return;
        }
        RemoveBuildings();
        RemoveRanges();
        GetRanges(building);
        buildingMode = true;
        disassemblyMode = false;
        juping = false;
        curBuilding = (BuildingType)building;
        curBuildingName.text = curBuilding.ToString();

        Building createdBuilding = PoolManager.GetItem<Building>(curBuilding.ToString());
        if(!createdBuilding.canJupe && buildMode == BuildMode.Jupe)
        {
            buildMode = BuildMode.Single;
        } 

        buildingGameObject.Add(createdBuilding.gameObject);
    }
    private void GetRanges(int building, bool startRed = false)
    {
        for (int i = 0; i < ranges[building].Count; i++)
        {
            Range range = PoolManager.GetItem<Range>("InstallationRange");
            range.ChangeMaterial(startRed);
            rangeGameobjects.Add(range);
        }
    }
    private void RemoveBuildings()
    {
        foreach (var item in buildingGameObject)
        {
            item?.SetActive(false);
        }
    }
    private void RemoveRanges()
    {
        
        buildingGameObject.Clear();

        for (; 0 < rangeGameobjects.Count;)
        {
            rangeGameobjects[0].gameObject.SetActive(false);
            rangeGameobjects.RemoveAt(0);
        }
    }
}
