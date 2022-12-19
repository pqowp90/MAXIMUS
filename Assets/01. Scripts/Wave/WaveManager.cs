using System;
using UnityEngine;
using System.Collections.Generic;
using Random = UnityEngine.Random;

public class WaveManager : MonoSingleton<WaveManager>
{
    [SerializeField] private float radius = 10f;
    [SerializeField] private Vector3 waveSize = new(5f, 1f, 5f);

    [SerializeField] private float timer;
    [SerializeField] private float nextSpawnTime;
    [SerializeField] private bool isNight = false;

    [SerializeField] private Transform player;
    [SerializeField] private LayerMask _groundLayer;

    private readonly WaveRange[] _waveRanges = { new(), new(), new(), new() };

    public WaveRange[] WaveRanges => UpdateWaveRange();

    [field:SerializeField] public int WaveCount { get; private set; }
    public Wave CurrentWave { get; private set; }

    [Header("Wave Info")]
    public List<WaveSO> waveList = new List<WaveSO>();
    [SerializeField] private int _maxOreSpawnCount = 20;
    [SerializeField] private float _oreSpawnRadius = 30.0f;
    [SerializeField] private float _enemySpawnDelay;
    private int _day = 0;
    public int Day => _day;
    
    private void Start() 
    {
        timer = 0f;
        nextSpawnTime = 0;
        WaveCount = 0;
        _day = 1;
        CurrentWave = new Wave(waveList[WaveCount]);
        _enemySpawnDelay = Random.Range(30.0f, 40.0f) / CurrentWave.WAVESO.EnemySpawnCount;
        UIManager.Instance.DayUIReload(true);

        foreach(var list in waveList)
        {
            foreach(var enemy in list.enemySpawnList)
            {
                PoolManager.CreatePool<Enemy>($"Enemy {enemy.eData.type}", ItemManager.Instance.poolObj, 10);
            }
        }
    }

    private void Update()
    {
        if(!InputManager.Instance.factoryMode){
            timer += Time.deltaTime;
        }
        
        UpdateWaveRange();
        if(CurrentWave != null) SpawnTimer();
    }

    private void OnDrawGizmos()
    {
        UpdateWaveRange();

        foreach (var waveRange in WaveRanges)
        {
            var position = player.position;

            Gizmos.color = Color.white;
            Gizmos.DrawLine(position, new Vector3(waveRange.position.x, waveRange.position.y, position.z));
            Gizmos.color = Color.yellow;
            Gizmos.DrawWireCube(new Vector3(waveRange.position.x, waveRange.position.y, waveRange.position.z),
                new Vector3(waveRange.size.x, waveRange.size.y, waveRange.size.z));
        }

        Gizmos.color = Color.green;
        Gizmos.DrawWireCube(player.position, new Vector3(_oreSpawnRadius, 1f, _oreSpawnRadius));
    }

    private WaveRange[] UpdateWaveRange()
    {
        var position = player.position;

        _waveRanges[0].position = position + Vector3.forward * radius;
        _waveRanges[0].size = waveSize;
        _waveRanges[1].position = position + Vector3.back * radius;
        _waveRanges[1].size = waveSize;

        var reversed = new Vector3(waveSize.z, waveSize.y, waveSize.x);
        _waveRanges[2].position = position + Vector3.left * radius;
        _waveRanges[2].size = reversed;
        _waveRanges[3].position = position + Vector3.right * radius;
        _waveRanges[3].size = reversed;

        return _waveRanges;
    }

    public void StartWave(bool night)
    {
        if(isNight == night) return;
        
        timer = 0f;
        nextSpawnTime = 0;
        isNight = night;

        if(!isNight)
        {
            _day++;
            WaveCount++;
            if(waveList.Count <= WaveCount) WaveCount--;

            CurrentWave = new Wave(waveList[WaveCount]);

            _enemySpawnDelay = Random.Range(30.0f, 40.0f) / CurrentWave.WAVESO.EnemySpawnCount;
        }

        UIManager.Instance.DayUIReload(!isNight);
    }

    private void SpawnTimer()
    {
        if (nextSpawnTime > timer) return;
        if (CurrentWave.EnemyCount <= 0) return;

        if(isNight)
        {
            SpawnEnemy();
            nextSpawnTime += _enemySpawnDelay;
        }
        else 
        {
            SpawnOre();
            nextSpawnTime += CurrentWave.WAVESO.OreSpawnDelay;
        }

        
    }

    private void SpawnEnemy()
    {
        var waveRange = CurrentWave.SpawnRanges[Random.Range(0, CurrentWave.SpawnRanges.Length)];
        var position = new Vector3(
            Random.Range(waveRange.position.x - waveRange.size.x / 2f,
                waveRange.position.x + waveRange.size.x / 2f),
            100f,
            Random.Range(waveRange.position.z - waveRange.size.z / 2f,
                waveRange.position.z + waveRange.size.z / 2f)
        );

        RaycastHit hit;
        Physics.Raycast(position, Vector3.down, out hit, Mathf.Infinity, _groundLayer);
        position = new Vector3(position.x, hit.point.y + 0.5f, position.z);

        EnemyManager.Instance.SpawnEnemy(CurrentWave.GetEnemy(), position);
    }

    private void SpawnOre()
    {
        if(OreManager.Instance.oreList.Count >= _maxOreSpawnCount)
        {
            Debug.LogWarning("Ore Spawn Count is MAX");

            return;
        }

        var position = player.position + new Vector3( Random.Range((_oreSpawnRadius / 2) * -1, _oreSpawnRadius / 2), 0, Random.Range((_oreSpawnRadius / 2) * -1, _oreSpawnRadius / 2));

        RaycastHit hit;
        Physics.Raycast(position, Vector3.down, out hit, Mathf.Infinity, _groundLayer);
        position = new Vector3(position.x, hit.point.y + 0.5f, position.z);

        OreManager.Instance.SpawnOre(CurrentWave.GetOre(), position);
    }
}