using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FactoryBaseManager : MonoSingleton<ConveyorBeltManager>, BuildAbility<FactoryBase>
{
    List<FactoryBase> factoryBases = new List<FactoryBase>();
    public void Build(Vector2Int _pos, int _rotation, FactoryBase building)
    {
        building.SetTransform(_rotation, _pos);
        foreach (var item in building.GetComponent<Building>().range)
        {
            GridManager.Instance.canInsertPoss.TryAdd(item + _pos, building.space);
        }
        factoryBases.Add(building);
    }

    public void Destroy(FactoryBase building)
    {
        List<Vector2Int> buildingRanges = building.GetComponent<Building>().range;
        foreach (var item in buildingRanges)
        {
            GridManager.Instance.canInsertPoss.Remove(item + building.pos);
        }
        factoryBases.Remove(building);
    }

    public void Use()
    {
        foreach (var item in factoryBases)
        {
            item.space.GetNextDropItem();
        }
        
    }
}
