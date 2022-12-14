using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InserterManager : MonoSingleton<InserterManager>, BuildAbility<Inserter>
{
    private List<Inserter> inserters = new List<Inserter>();
    Dictionary<Vector2Int, Inserter> inserterPoss = new Dictionary<Vector2Int, Inserter>();
    Vector2Int[] dir_rotation = {Vector2Int.up, Vector2Int.right, Vector2Int.down, Vector2Int.left};
    public void FindAround(Inserter _inserter)
    {
        List<ItemSpace> space = null;
        if(GridManager.Instance.canInsertPoss.TryGetValue(_inserter.pos + dir_rotation[_inserter.Rotation], out space))
        {
            foreach (var item in space)
            {
                if(item.canIn)
                {
                    _inserter.nextItemCarrierBase = item;
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
                InserterManager.Instance.FindAround(inserter);
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
            FindAround(_inserter);
        }
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
            if(item.nextItemCarrierBase != null && item.beforeItemCarrierBase != null)
            {
                if(item.nextItemCarrierBase.dropItem == null && item.beforeItemCarrierBase.dropItem != null)
                {
                    DropItem dropItem = movedItem.Find(x => x == item.beforeItemCarrierBase.dropItem);
                    if(dropItem == null)
                    {
                        item.beforeItemCarrierBase.dropItem.transform.position = item.transform.position;
                        item.nextItemCarrierBase.dropItem = item.beforeItemCarrierBase.TakeItem();
                        movedItem.Add(item.nextItemCarrierBase.dropItem);
                    }
                }
            }
            
        }
    }
}
