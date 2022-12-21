using System;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class EnemyManager : MonoSingleton<EnemyManager>
{
    public Transform enemyParent;
    public List<Enemy> Enemies = new();

    public void SpawnEnemy(Enemy enemy, Vector3 position)
    {
        var enemyObject = PoolManager.GetItem<Enemy>($"Enemy {enemy.EnemyType}");
        enemyObject.transform.position = position;
        enemyObject.transform.rotation = Quaternion.identity;
        enemyObject.transform.SetParent(enemyParent);
        enemyObject.Init(enemy.Data, true);
        Enemies.Add(enemyObject);
    }

    public void DeathEnemy(Enemy enemy)
    {
        Enemies.Remove(enemy);
        enemy.gameObject.SetActive(false);
        enemy.transform.SetParent(ItemManager.Instance.poolObj.transform);
        Debug.Log(enemy.Data.dropItemTable.DropCount);
        for(int i = 0; i < enemy.Data.dropItemTable.DropCount; i++)
        {
            ItemManager.Instance.DropItem(enemy.transform.position, enemy.Data.dropItemTable.GetDropItem(), 1);
        }
        EntityManager.Instance.UnregisterEntity(enemy);
    }
}