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
        ItemSpace space = null;
        if(GridManager.Instance.canInsertPoss.TryGetValue(_inserter.pos + dir_rotation[_inserter.Rotation], out space))
        {
            if(space.canIn)
            {
                _inserter.nextItemCarrierBase = space;
            }
        }
        space = null;
        if(GridManager.Instance.canInsertPoss.TryGetValue(_inserter.pos - dir_rotation[_inserter.Rotation], out space))
        {
            if(space.canOut)
            {
                _inserter.beforeItemCarrierBase = space;
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
    private List<DropItem> dropItems = new List<DropItem>();
    public void Use()
    {
        dropItems.Clear();
        foreach (var item in inserters)
        {
            if(item.nextItemCarrierBase != null && item.beforeItemCarrierBase != null)
            {
                if(item.nextItemCarrierBase.itemSpace == null && item.beforeItemCarrierBase.itemSpace != null)
                {
                    DropItem dropItem = dropItems.Find(x => x == item.beforeItemCarrierBase.itemSpace);
                    if(dropItem == null)
                    {
                        item.nextItemCarrierBase.itemSpace = item.beforeItemCarrierBase.itemSpace;
                        item.beforeItemCarrierBase.itemSpace = null;
                        item.beforeItemCarrierBase.GetNextDropItem();
                        dropItems.Add(item.nextItemCarrierBase.itemSpace);
                    }
                }
            }
            
        }
    }
}
