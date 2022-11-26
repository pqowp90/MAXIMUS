using System;
using Unity.VisualScripting;
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