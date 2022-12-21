using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OreManager : MonoSingleton<OreManager>
{
    public Transform oreParent;
    public List<Ore> oreList = new List<Ore>();

    private void Start() {
        PoolManager.CreatePool<Ore>("Ore", oreParent.gameObject, 20);
    }
    
    public void SpawnOre(OreSO ore, Vector3 pos)
    {
        var enemyObject = PoolManager.GetItem<Ore>("Ore");
        enemyObject.Init(ore, 0);
        enemyObject.ResourceInit(ore.mesh, ore.material);
        enemyObject.transform.localScale = Vector3.one * 4f;
        enemyObject.transform.position = pos;
        enemyObject.transform.rotation = Quaternion.identity;
        enemyObject.transform.SetParent(oreParent);
        oreList.Add(enemyObject);
    }

    public void DeathOre(Ore ore)
    {
        oreList.Remove(ore);
        ore.gameObject.SetActive(false);
    }
}
