using System;
using UnityEngine;
using Random = UnityEngine.Random;

namespace KBluePurple.Wave
{
    public class WaveManager : MonoSingleton<WaveManager>
    {
        [SerializeField] private float radius = 10f;
        [SerializeField] private Vector2 waveSize = new(5f, 1f);

        [SerializeField] private float timer;
        [SerializeField] private float nextSpawnTime;
        [SerializeField] private bool isBloodMoon;
        [SerializeField] private bool isWaveProgressing;

        private readonly WaveRange[] _waveRanges = { new(), new(), new(), new() };
        public Action<EnemySpawnArgs> OnEnemySpawn = args => { };
        public Action<WaveEndArgs> OnWaveEnd = args => { };
        public Action<WaveStartArgs> OnWaveStart = args => { };

        public WaveRange[] WaveRanges => UpdateWaveRange();

        public int WaveCount { get; private set; }
        public Wave CurrentWave { get; private set; }

        private void Update()
        {
            if (!isWaveProgressing) return;

            timer += Time.deltaTime;

            if (CurrentWave.EnemyCount > 0 || EnemyManager.Instance.EnemyCount > 0)
                SpawnTimer();
            else
                EndWave(CombatManager.Instance.KillCount, CombatManager.Instance.DamageCount);
        }

        private void OnDrawGizmos()
        {
            UpdateWaveRange();

            foreach (var waveRange in WaveRanges)
            {
                var position = transform.position;

                Gizmos.color = Color.white;
                Gizmos.DrawLine(position, new Vector3(waveRange.position.x, waveRange.position.y, position.z));
                Gizmos.color = Color.yellow;
                Gizmos.DrawWireCube(new Vector3(waveRange.position.x, waveRange.position.y),
                    new Vector3(waveRange.size.x, waveRange.size.y));
            }
        }

        private WaveRange[] UpdateWaveRange()
        {
            var position = transform.position;

            _waveRanges[0].position = position + Vector3.up * radius;
            _waveRanges[0].size = waveSize;
            _waveRanges[1].position = position + Vector3.down * radius;
            _waveRanges[1].size = waveSize;

            var reversed = new Vector2(waveSize.y, waveSize.x);
            _waveRanges[2].position = position + Vector3.left * radius;
            _waveRanges[2].size = reversed;
            _waveRanges[3].position = position + Vector3.right * radius;
            _waveRanges[3].size = reversed;

            return _waveRanges;
        }

        public void StartWave()
        {
            if (isWaveProgressing) return;
            isWaveProgressing = true;
            timer = 0f;
            nextSpawnTime = 0;

            WaveCount++;

            isBloodMoon = FormulaFunction.IsBloodMoon();
            CurrentWave = new Wave();

            OnWaveStart?.Invoke(new WaveStartArgs(WaveCount, isBloodMoon));
        }

        public void EndWave(int totalKill, int totalDamage)
        {
            if (!isWaveProgressing) return;
            isWaveProgressing = false;
            OnWaveEnd?.Invoke(new WaveEndArgs(WaveCount, isBloodMoon, totalKill, totalDamage, timer));
        }

        private void SpawnTimer()
        {
            if (nextSpawnTime > timer) return;
            if (CurrentWave.EnemyCount <= 0) return;

            SpawnEnemy();

            var remainTime = DayCycleManager.Instance.nightLength / 2 - timer;
            nextSpawnTime += Random.Range(0, remainTime / CurrentWave.EnemyCount);
        }

        private void SpawnEnemy()
        {
            var waveRange = CurrentWave.SpawnRanges[Random.Range(0, CurrentWave.SpawnRanges.Length)];
            var position = new Vector2(
                Random.Range(waveRange.position.x - waveRange.size.x / 2f,
                    waveRange.position.x + waveRange.size.x / 2f),
                Random.Range(waveRange.position.y - waveRange.size.y / 2f,
                    waveRange.position.y + waveRange.size.y / 2f)
            );

            OnEnemySpawn?.Invoke(new EnemySpawnArgs(CurrentWave.GetEnemy(), position));
        }
    }

    // TODO: 전투 매니저 ( 나중에 만들던가 말던가 )
    public class CombatManager
    {
        public static CombatManager Instance { get; } = new();

        public int KillCount { get; private set; } = 10;
        public int DamageCount { get; private set; } = 10;

        public void ResetCount()
        {
            KillCount = 0;
            DamageCount = 0;
        }
    }
}