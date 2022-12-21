using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InserterManager : MonoSingleton<InserterManager>, BuildAbility<Inserter>
{
    private List<Inserter> inserters = new List<Inserter>();
    Dictionary<Vector2Int, Inserter> inserterPoss = new Dictionary<Vector2Int, Inserter>();
    Vector2Int[] dir_rotation = {Vector2Int.up, Vector2Int.right, Vector2Int.down, Vector2Int.left};
    public void DeleteMe(Vector2Int pos, ItemSpace itemSpace)
    {
        foreach (var item1 in dir_rotation)
        {
            Inserter inserter = null;
            if(inserterPoss.TryGetValue(pos + item1, out inserter))
            {
                Debug.Log("찾았다");
                if(inserter.beforeItemCarrierBase == itemSpace)
                {
                    inserter.beforeItemCarrierBase = null;
                }
                foreach (var item2 in inserter.nextItemCarrierBase)
                {
                    if(item2 == itemSpace)
                    {
                        inserter.nextItemCarrierBase.Remove(itemSpace);
                    }
                }
            }
        }
    }
    public void FindAround(Inserter _inserter)
    {
        Vector2Int pos = dir_rotation[_inserter.Rotation];
        Debug.DrawRay(new Vector3(_inserter.pos.x, 0f, _inserter.pos.y), new Vector3(pos.x, 0f, pos.y), Color.red, 5f);
        pos = - dir_rotation[_inserter.Rotation];
        Debug.DrawRay(new Vector3(_inserter.pos.x, 0f, _inserter.pos.y), new Vector3(pos.x, 0f, pos.y), Color.red, 5f);
        List<ItemSpace> space = null;
        if(GridManager.Instance.canInsertPoss.TryGetValue(_inserter.pos + dir_rotation[_inserter.Rotation], out space))
        {
            foreach (var item in space)
            {
                if(item.canIn)
                {
                    _inserter.nextItemCarrierBase.Add(item);
                }
            }
        }
        space = null;
        if(GridManager.Instance.canInsertPoss.TryGetValue(_inserter.pos - dir_rotation[_inserter.Rotation], out space))
        {
            foreach (var item in space)
            {
                if(item.canOut)
                {
                    _inserter.beforeItemCarrierBase = item;
                }
            }
        }
    }
    public void FindAdjacency(Vector2Int pos)
    {
        foreach (var item in dir_rotation)
        {
            Inserter inserter = null;
            if(inserterPoss.TryGetValue(pos + item, out inserter))
            {
                FindAround(inserter);
            }
        }
    }
    

    public void Build(Vector2Int _pos, int _rotation, Inserter _inserter)
    {
        if(!inserters.Find(x => x == _inserter))
        {
            inserters.Add(_inserter);
            inserterPoss.Add(_pos, _inserter);
            _inserter.SetTransform(_rotation, _pos);
            
        }
        FindAround(_inserter);
    }

    public void Destroy(Inserter _inserter)
    {
        if(inserters.Find(x => x == _inserter))
        {
            inserters.Remove(_inserter);
            inserterPoss.Remove(_inserter.pos);
        }
    }
    private List<DropItem> movedItem = new List<DropItem>();
    public void Use()
    {
        movedItem.Clear();
        foreach (var item in inserters)
        {
            ItemSpace _beforeItemCarrierBase = item.beforeItemCarrierBase;
            foreach (var _nextItemCarrierBase in item.nextItemCarrierBase)
            {
                if(_nextItemCarrierBase != null && _beforeItemCarrierBase != null)
                {
                    if(_beforeItemCarrierBase.dropItem != null || _beforeItemCarrierBase.spaceType == SpaceType.Multy)
                    {
                        if(_nextItemCarrierBase.dropItem == null || _nextItemCarrierBase.spaceType == SpaceType.Multy)
                        {
                            if(_beforeItemCarrierBase.spaceType == SpaceType.Multy && _nextItemCarrierBase.spaceType == SpaceType.Multy)
                                break;
                            DropItem dropItem = movedItem.Find(x => x == _beforeItemCarrierBase.dropItem);
                            if(dropItem == null)
                            {
                                _nextItemCarrierBase.GiveItem(_beforeItemCarrierBase);
                                if(_nextItemCarrierBase.dropItem)
                                    _nextItemCarrierBase.dropItem.transform.position = item.transform.position;
                                movedItem.Add(_nextItemCarrierBase.dropItem);
                            }
                        }
                    }
                }
            }
        }
    }
}
