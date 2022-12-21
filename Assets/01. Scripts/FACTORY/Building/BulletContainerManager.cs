using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BulletContainerManager : MonoSingleton<BulletContainerManager>, BuildAbility<BulletContainer>
{
    List<BulletContainer> bulletContainer = new List<BulletContainer>();
    public void Build(Vector2Int _pos, int _rotation, BulletContainer building)
    {
        building.SetTransform(_rotation, _pos);
        building.space.canIn = true;
        building.space.canOut = false;
        foreach (var item in building.GetComponent<Building>().rangeArray)
        {
            GridManager.Instance.canInsertPoss.TryAdd(item + _pos, new List<ItemSpace>());
            GridManager.Instance.canInsertPoss[item + _pos].Add(building.space);
            //GridManager.Instance.canInsertPoss.TryAdd(item + _pos, building.space);
        }
        bulletContainer.Add(building);
    }

    public void Destroy(BulletContainer building)
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
        bulletContainer.Remove(building);
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
