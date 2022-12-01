using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InserterManager : MonoSingleton<InserterManager>
{
    [SerializeField]
    private List<Inserter> inserters = new List<Inserter>();
    Dictionary<Vector2Int, Inserter> inserterPoss = new Dictionary<Vector2Int, Inserter>();
    Vector2Int[] dir_rotation = {Vector2Int.up, Vector2Int.right, Vector2Int.down, Vector2Int.left};
    public void AddInserter(Vector2Int _pos, int _rotation, Inserter _inserter)
    {
        inserters.Add(_inserter);
        inserterPoss.Add(_pos, _inserter);
        _inserter.SetTransform(_rotation, _pos);
        FindAround(_inserter);
        
    }
    public void FindAround(Inserter _inserter)
    {
        ItemCarrierBase space = null;
        if(GridManager.Instance.canInsertPoss.TryGetValue(_inserter.pos + dir_rotation[_inserter.Rotation], out space))
        {
            _inserter.nextItemCarrierBase = space;
        }
        space = null;
        if(GridManager.Instance.canInsertPoss.TryGetValue(_inserter.pos - dir_rotation[_inserter.Rotation], out space))
        {
            _inserter.beforeItemCarrierBase = space;
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
    
    
    public void RemoveInserter(Inserter _inserter)
    {
        if(inserters.Find(x => x == _inserter))
        {
            inserters.Remove(_inserter);
            inserterPoss.Add(_inserter.pos, _inserter);
        }
        
    }
    private List<DropItem> dropItems = new List<DropItem>();
    public void MoveInserter()
    {
        dropItems.Clear();
        foreach (var item in inserters)
        {
            if(item.nextItemCarrierBase != null && item.beforeItemCarrierBase != null)
            {
                if(item.nextItemCarrierBase.item == null && item.beforeItemCarrierBase.item != null)
                {
                    DropItem dropItem = dropItems.Find(x => x == item.beforeItemCarrierBase.item);
                    if(dropItem == null)
                    {
                        item.nextItemCarrierBase.item = item.beforeItemCarrierBase.item;
                        item.beforeItemCarrierBase.item = null;
                        dropItems.Add(item.nextItemCarrierBase.item);
                    }
                }
            }
            
        }
    }

}
