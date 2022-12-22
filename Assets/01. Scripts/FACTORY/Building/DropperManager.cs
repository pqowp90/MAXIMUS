using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DropperManager : MonoSingleton<DropperManager>, BuildAbility<Dropper>
{
    List<Dropper> droppers = new List<Dropper>();
    public void Build(Vector2Int _pos, int _rotation, Dropper building)
    {
        building.SetTransform(_rotation, _pos);
        building.space.canIn = false;
        foreach (var item in building.GetComponent<Building>().rangeArray)
        {
            GridManager.Instance.canInsertPoss.TryAdd(item + _pos, new List<ItemSpace>());
            GridManager.Instance.canInsertPoss[item + _pos].Add(building.space);
            //GridManager.Instance.canInsertPoss.TryAdd(item + _pos, building.space);
        }
        droppers.Add(building);
    }

    public void Destroy(Dropper building)
    {
        foreach (var item in building.GetComponent<Building>().rangeArray)
        {
            InserterManager.Instance.DeleteMe(building.pos + item, building.space);
        }
        
        List<Vector2Int> buildingRanges = building.GetComponent<Building>().range;
        foreach (var item in buildingRanges)
        {
            GridManager.Instance.canInsertPoss.Remove(item + building.pos);
        }
        droppers.Remove(building);
    }

    public void Use()
    {
        foreach (var item in droppers)
        {
            item.space.GetNextDropItem();
        }
        
    }


}
