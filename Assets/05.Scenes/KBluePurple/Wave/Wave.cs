using System.Linq;
using UnityEngine;

namespace KBluePurple.Wave
{
    public class Wave
    {
        private WaveEnemy[] _enemies;
        public WaveRange[] SpawnRanges;

        public Wave()
        {
            InitializeEnemies(FormulaFunction.EnemyCount());
            InitializeSpawnRanges(FormulaFunction.DirectionCount());
        }

        public int EnemyCount { get; private set; }

        private void InitializeEnemies(int enemyCount)
        {
            EnemyCount = enemyCount;
            _enemies = new WaveEnemy[enemyCount];

            _enemies[0] = new WaveEnemy(0);

            for (var i = 1; i < enemyCount; i++) _enemies[i] = new WaveEnemy(i);

            _enemies[0].Ratio = 1 - _enemies[1..].Sum(x => x.Ratio);
        }

        private void InitializeSpawnRanges(int directionCount)
        {
            SpawnRanges = new WaveRange[directionCount];

            if (WaveManager.Instance.WaveRanges.Clone() is not WaveRange[] ranges) return;
            var waveRanges = ranges.ToList();

            for (var i = 0; i < ranges.Length - directionCount; i++)
                waveRanges.RemoveAt(Random.Range(0, waveRanges.Count));

            for (var i = 0; i < directionCount; i++)
                SpawnRanges[i] = waveRanges[i];
        }

        public WaveEnemy GetEnemy()
        {
            var random = Random.Range(0f, 1f);
            var sum = 0f;

            EnemyCount--;

            for (var i = 0; i < EnemyCount; i++)
            {
                sum += _enemies[i].Ratio;
                if (random <= sum) return _enemies[i];
            }

            return _enemies[0];
        }
    }
}