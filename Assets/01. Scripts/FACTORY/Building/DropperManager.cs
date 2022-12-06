using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DropperManager : MonoSingleton<DropperManager>, BuildAbility<Dropper>
{
    public void Build(Vector2Int _pos, int _rotation, Dropper building)
    {
        building.space.canIn = false;
        foreach (var item in building.outPutRange)
        {
            GridManager.Instance.canInsertPoss.TryAdd(item, building.space);
        }
    }

    public void Destroy(Dropper building)
    {
        List<Vector2Int> buildingRanges = building.GetComponent<Building>().range;
        foreach (var item in buildingRanges)
        {
            GridManager.Instance.canInsertPoss.Remove(item);
        }
    }

    public void Use()
    {

    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
