using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FactoryBaseManager : MonoSingleton<FactoryBaseManager>, BuildAbility<FactoryBase>
{
    List<FactoryBase> factoryBases = new List<FactoryBase>();
    public void Build(Vector2Int _pos, int _rotation, FactoryBase building)
    {
        building.SetTransform(_rotation, _pos);
        foreach (var item in building.GetComponent<Building>().rangeArray)
        {
            //GridManager.Instance.canInsertPoss.TryAdd(item + _pos, building.outPutSpace);
            GridManager.Instance.canInsertPoss.TryAdd(item + _pos, new List<ItemSpace>());
            GridManager.Instance.canInsertPoss[item + _pos].Add(building.outPutSpace);
            foreach (var Space in building.inputSpaces)
            {
                GridManager.Instance.canInsertPoss[item + _pos].Add(Space);   
            }
        }
        factoryBases.Add(building);
    }

    public void Destroy(FactoryBase building)
    {
        foreach (var item in building.GetComponent<Building>().rangeArray)
        {
            InserterManager.Instance.DeleteMe(building.pos + item, building.outPutSpace);
            foreach (var item2 in building.inputSpaces)
            {
                InserterManager.Instance.DeleteMe(item, item2);
            }
        }
        foreach (var item in building.inputSpaces)
        {
            InserterManager.Instance.DeleteMe(building.pos, item);
        }
        InserterManager.Instance.DeleteMe(building.pos, building.outPutSpace);

        List<Vector2Int> buildingRanges = building.GetComponent<Building>().range;
        foreach (var item in buildingRanges)
        {
            GridManager.Instance.canInsertPoss.Remove(item + building.pos);
        }
        factoryBases.Remove(building);
    }

    public void Use()
    {
        foreach (var factory in factoryBases)
        {
            if(factory.curRecipe == null)
                continue;
            bool isCanUse = true;
            foreach (var recipe in factory.curRecipe.ingredients)
            {
                ItemSpace itemSpace = factory.inputSpaces.Find(x => x.connectSO == recipe.item);
                if(itemSpace == null)
                {
                    isCanUse = false;
                    break;
                }else
                {
                    if(itemSpace.count < recipe.count)
                    {
                        isCanUse = false;
                        break;
                    }
                }
                
            }
            if(isCanUse)
            {
                factory.OneTick();
            }
        }
    }
}
