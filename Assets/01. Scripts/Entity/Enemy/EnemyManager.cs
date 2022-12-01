﻿using System;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

// TODO: 적 매니저 ( 나중에 만들던가 말던가 )
public class EnemyManager : MonoSingleton<EnemyManager>
{
    public GameObject enemyPrefab;
    public Transform enemyParent;
    public List<Enemy> Enemies = new();

    [SerializeField] private GameObject chestPrefab;

    public int EnemyCount => Enemies.Count;

    private void Start()
    {
        WaveManager.Instance.OnEnemySpawn += OnEnemySpawn;
        WaveManager.Instance.OnWaveEnd += OnWaveEnd;

        PoolManager.CreatePool<Enemy>("Enemy", ItemManager.Instance.poolObj, 50);
    }

    // 적 한번에 모두 처치 ( 디버그용 )
    // private void Update()
    // {
    //     if (Input.GetKeyDown(KeyCode.Space))
    //     {
    //         var enemies = new Enemy[Enemies.Count];
    //         Enemies.CopyTo(enemies);
    //         foreach (var enemy in enemies)
    //         {
    //             enemy.TakeDamage(100);
    //         }
    //     }
    // }

    private void OnWaveEnd(WaveEndArgs e)
    {
    }

    private void OnEnemySpawn(EnemySpawnArgs e)
    {
        SpawnEnemy(e.Enemy, e.Position);
    }

    private void SpawnEnemy(IEnemy enemy, Vector3 position)
    {
        var enemyObject = PoolManager.GetItem<Enemy>("Enemy");
        enemyObject.transform.position = position;
        enemyObject.transform.rotation = Quaternion.identity;
        enemyObject.transform.SetParent(enemyParent);
        var enemyComponent = enemyObject.GetComponent<Enemy>();
        enemyComponent.Init(enemy);
        Enemies.Add(enemyComponent);
    }

    public void DeathEnemy(Enemy enemy)
    {
        Enemies.Remove(enemy);
        PoolManager.GetItem<Enemy>("Enemy");
        ItemManager.Instance.DropItem(enemy.transform.position, enemy.Data.dropItemTable.GetDropItem().item_ID);
        EntityManager.Instance.UnregisterEntity(enemy);
    }
}