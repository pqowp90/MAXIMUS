using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class ConveyorBeltManager : MonoSingleton<ConveyorBeltManager>, BuildAbility<ConveyorBelt>
{
    
    Vector2Int[] dir_rotation = {Vector2Int.up, Vector2Int.right, Vector2Int.down, Vector2Int.left};
    Dictionary<Vector2Int, ConveyorBelt> conveyorPoss = new Dictionary<Vector2Int, ConveyorBelt>();
    Dictionary<int, int> conveyorBeltListDictionary = new Dictionary<int, int>();
    [SerializeField]
    List<ConveyorBelt> conveyorBelts = new List<ConveyorBelt>();
    private int idCount = 1;



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
            DropItem dropItem = dropItems.Find(x => x == item.space.dropItem);
            if(dropItem == null)
            {
                if(conveyorBelt.space.dropItem == null)
                {
                    dropItems.Add(item.space.dropItem);
                    conveyorBelt.space.dropItem = item.space.TakeItem();
                }
            }
            if(firstConveyorBelt != item)
            {
                
                RecursiveSearch(item, firstConveyorBelt);
            }
        }
    }


    public void Use()
    {
        foreach (var item in conveyorBelts)
        {
            StartRecursiveSearch(item, item);
        }
    }

    public void Build(Vector2Int _pos, int _rotation, ConveyorBelt conveyorBelt)
    {
        bool imSolo = true;
        conveyorBelt.pos = _pos;
        conveyorBelt.Rotation = _rotation;
        if(conveyorPoss.TryAdd(conveyorBelt.pos, conveyorBelt)){
            GridManager.Instance.canInsertPoss.TryAdd(_pos, new List<ItemSpace>());
            GridManager.Instance.canInsertPoss[_pos].Add(conveyorBelt.space);
            //GridManager.Instance.canInsertPoss.TryAdd(_pos, conveyorBelt.space);
            conveyorBelt.SetTransform(_rotation, _pos); 
            ConveyorBelt getConveyorBelt = null;
            // ?????? ????????? ?????? ????????? ???????????? ????????? ?????? ????????? ??????????????? ????????? ???????????? ?????? ???????????? ?????????
            if(!conveyorPoss.TryGetValue(_pos + dir_rotation[conveyorBelt.Rotation], out getConveyorBelt))
            {
                conveyorBelts.Add(conveyorBelt);
            }else// ?????? ????????? ????????? ???????????? ????????? ????????????????????? ?????????????????? ?????? ????????? ???????????? ?????????????????? ????????????
            {
                imSolo = false;
                conveyorBelt.GroupID = getConveyorBelt.GroupID;
                getConveyorBelt.beforeConveyorBelts.Add(conveyorBelt);
                conveyorBelt.nextConveyorBelt = getConveyorBelt;
                getConveyorBelt = null;
            }
            
            foreach (var item in dir_rotation)// ??????????????? ????????? 4????????? ???????????? ????????? ??????
            {
                if(conveyorPoss.TryGetValue(_pos + item, out getConveyorBelt))
                    if(dir_rotation[getConveyorBelt.Rotation] == -item)// ?????? ?????? ???????????? ?????? ???????????? ????????? ?????????
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
                        
                        if(getConveyorBelt.nextConveyorBelt == null)// ?????? ????????? ??????????????? ????????? ???????????? ????????????
                        {
                            conveyorBelts.Remove(getConveyorBelt);
                        }
                        getConveyorBelt.nextConveyorBelt = conveyorBelt;
                        conveyorBelt.beforeConveyorBelts.Add(getConveyorBelt);// ??? ??????????????? ????????????
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

    public void Destroy(ConveyorBelt conveyorBelt)
    {
        InserterManager.Instance.DeleteMe(conveyorBelt.pos, conveyorBelt.space);
        conveyorBelts.Remove(conveyorBelt);
        ConveyorBelt getConveyorBelt = null;
        GridManager.Instance.canInsertPoss.Remove(conveyorBelt.pos);
        if(conveyorPoss.TryGetValue(conveyorBelt.pos + dir_rotation[conveyorBelt.Rotation], out getConveyorBelt))
        {
            getConveyorBelt.beforeConveyorBelts.Remove(conveyorBelt);
        }

        foreach (var item in dir_rotation)// ??????????????? ????????? 4????????? ???????????? ????????? ??????
        {
            if(conveyorPoss.TryGetValue(conveyorBelt.pos + item, out getConveyorBelt))
            {
                if(dir_rotation[getConveyorBelt.Rotation] == -item)// ?????? ?????? ???????????? ?????? ???????????? ????????? ?????????
                {
                    getConveyorBelt.nextConveyorBelt = null;
                    conveyorBelts.Add(getConveyorBelt);
                    
                }
            }
        }
        conveyorPoss.Remove(conveyorBelt.pos);
    }
}
