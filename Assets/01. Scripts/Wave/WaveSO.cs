using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
[CreateAssetMenu(fileName = "New Wave", menuName = "Wave")]
public class WaveSO : ScriptableObject
{  
    [Header("Day: 소환할 광물 리스트")]
    [Tooltip("소환할 광물 SO와 가치")]
    public List<OreSpawnInfo> oreSpawnList = new List<OreSpawnInfo>();  

    [Header("Night: 소환할 적 리스트")]
    [Tooltip("소환할 적 SO와 마리 수")]
    public List<EnemySpawnInfo> enemySpawnList = new List<EnemySpawnInfo>();
}

[System.Serializable]
public class OreSpawnInfo
{
    public EnemyData eData;
    public int rate;
}

[System.Serializable]
public class EnemySpawnInfo
{
    public EnemyData eData;
    public int count;
}