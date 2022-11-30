using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class ConveyorBeltManager : MonoSingleton<ConveyorBeltManager>
{
    
    Vector2Int[] dir_rotation = {Vector2Int.up, Vector2Int.right, Vector2Int.down, Vector2Int.left};
    Dictionary<Vector2Int, ConveyorBelt> conveyorPoss = new Dictionary<Vector2Int, ConveyorBelt>();
    Dictionary<int, int> conveyorBeltListDictionary = new Dictionary<int, int>();
    [SerializeField]
    List<ConveyorBelt> conveyorBelts = new List<ConveyorBelt>();
    private int idCount = 1;


    public void MoveConveyorBelt()
    {
        foreach (var item in conveyorBelts)
        {
            StartRecursiveSearch(item, item);
        }
    }
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    public void DestroyBelt(ConveyorBelt conveyorBelt)
    {
        conveyorBelts.Remove(conveyorBelt);
        ConveyorBelt getConveyorBelt = null;
        GridManager.Instance.canInsertPoss.Remove(conveyorBelt.pos);
        if(conveyorPoss.TryGetValue(conveyorBelt.pos + dir_rotation[conveyorBelt.Rotation], out getConveyorBelt))
        {
            getConveyorBelt.beforeConveyorBelts.Remove(conveyorBelt);
        }

        foreach (var item in dir_rotation)// 마지막으로 인접한 4방향의 컨베이어 벨트를 찾고
        {
            if(conveyorPoss.TryGetValue(conveyorBelt.pos + item, out getConveyorBelt))
            {
                if(dir_rotation[getConveyorBelt.Rotation] == -item)// 만약 나를 바라보고 있는 컨베이어 벨트가 있으면
                {
                    getConveyorBelt.nextConveyorBelt = null;
                    conveyorBelts.Add(getConveyorBelt);
                    
                }
            }
        }
        conveyorPoss.Remove(conveyorBelt.pos);
    }
    public void AddConveyorBelt(Vector2Int _pos, int _rotation, ConveyorBelt conveyorBelt)
    {
        bool imSolo = true;
        conveyorBelt.pos = _pos;
        conveyorBelt.Rotation = _rotation;
        if(conveyorPoss.TryAdd(conveyorBelt.pos, conveyorBelt)){
            GridManager.Instance.canInsertPoss.TryAdd(_pos, conveyorBelt);
            conveyorBelt.SetTransform(_rotation, _pos); 
            ConveyorBelt getConveyorBelt = null;
            // 먼저 자기가 보는 방향의 컨베이어 벨트를 찾고 없으면 자기자신을 마지막 컨베이어 벨트 리스트에 넣는다
            if(!conveyorPoss.TryGetValue(_pos + dir_rotation[conveyorBelt.Rotation], out getConveyorBelt))
            {
                conveyorBelts.Add(conveyorBelt);
            }else// 그게 아니면 자신의 앞에있는 벨트의 비폴컨베이어를 자기자신으로 하고 자신의 넥스트를 앞에있는걸로 지정한다
            {
                imSolo = false;
                conveyorBelt.GroupID = getConveyorBelt.GroupID;
                getConveyorBelt.beforeConveyorBelts.Add(conveyorBelt);
                conveyorBelt.nextConveyorBelt = getConveyorBelt;
                getConveyorBelt = null;
            }
            
            foreach (var item in dir_rotation)// 마지막으로 인접한 4방향의 컨베이어 벨트를 찾고
            {
                if(conveyorPoss.TryGetValue(_pos + item, out getConveyorBelt))
                    if(dir_rotation[getConveyorBelt.Rotation] == -item)// 만약 나를 바라보고 있는 컨베이어 벨트가 있으면
                    {
                        if(imSolo)
                        {
                            conveyorBelt.GroupID = getConveyorBelt.GroupID;
                        }
                        else
                        {
                            getConveyorBelt.GroupID = conveyorBelt.GroupID;
                            RecursiveSearchID(getConveyorBelt);
                        }
                        
                        if(getConveyorBelt.nextConveyorBelt == null)// 내가 그것을 막고있으면 마지막 벨트에서 해제한다
                        {
                            conveyorBelts.Remove(getConveyorBelt);
                        }
                        getConveyorBelt.nextConveyorBelt = conveyorBelt;
                        conveyorBelt.beforeConveyorBelts.Add(getConveyorBelt);// 내 이전벨트에 추가한다
                    }
            }

            if(imSolo && conveyorBelt.GroupID == 0)
            {
                conveyorBelt.GroupID = idCount;
                idCount++;
            }
            List<ConveyorBelt> conveyor = conveyorBelts.FindAll(x => x.GroupID == conveyorBelt.GroupID);
            if(conveyor.Count == 0)
            {
                conveyorBelts.Add(conveyorBelt);
            }


        }
    }
    public void RecursiveSearchID(ConveyorBelt conveyorBelt)
    {
        foreach (var item in conveyorBelt.beforeConveyorBelts)
        {
            item.GroupID = conveyorBelt.GroupID;
            RecursiveSearchID(item);
        }
    }
    private List<DropItem> dropItems = new List<DropItem>();
    public void StartRecursiveSearch(ConveyorBelt conveyorBelt, ConveyorBelt firstConveyorBelt)
    {
        dropItems.Clear();
        RecursiveSearch(conveyorBelt, firstConveyorBelt);
    }
    public void RecursiveSearch(ConveyorBelt conveyorBelt, ConveyorBelt firstConveyorBelt)
    {
        foreach (var item in conveyorBelt.beforeConveyorBelts)
        {
            DropItem dropItem = dropItems.Find(x => x == item.Item);
            if(dropItem == null)
            {
                if(conveyorBelt.Item == null)
                {
                    dropItems.Add(item.Item);
                    var temp = item.Item;
                    item.Item = null;
                    conveyorBelt.Item = temp;
                }
            }
            if(firstConveyorBelt != item)
            {
                
                RecursiveSearch(item, firstConveyorBelt);
            }
        }
    }
}
