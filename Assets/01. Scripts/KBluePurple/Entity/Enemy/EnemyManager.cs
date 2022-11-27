using System;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

namespace KBluePurple.Wave
{
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
            var enemyObject = Instantiate(enemyPrefab, position, Quaternion.identity);
            enemyObject.transform.SetParent(enemyParent);
            var enemyComponent = enemyObject.GetComponent<Enemy>();
            enemyComponent.Init(enemy);
            Enemies.Add(enemyComponent);
        }

        public void DeathEnemy(Enemy enemy)
        {
            Enemies.Remove(enemy);
            Destroy(enemy.gameObject);
            EntityManager.Instance.UnregisterEntity(enemy);

            var chestChance = FormulaFunction.DropChestChance(enemy);

            if (!(Random.Range(0f, 1f) < chestChance)) return;

            var chest = Instantiate(chestPrefab, enemy.transform.position, Quaternion.identity);
            chest.transform.SetParent(enemyParent);
        }
    }
}