using System;
using UnityEngine;

namespace KBluePurple.Wave
{
    public class DayCycleManager : MonoSingleton<DayCycleManager>
    {
        public enum Cycle
        {
            Day,
            Night
        }

        public float dayLength = 60f;
        public float nightLength = 60f;

        [SerializeField] private bool isCycling = true;
        [SerializeField] private Cycle currentCycle = Cycle.Day;

        [SerializeField] private float timer;

        public Action<Cycle> OnCycled = cycle => { };

        private void Update()
        {
            if (!isCycling) return;

            timer += Time.deltaTime;

            switch (currentCycle)
            {
                case Cycle.Day when timer >= dayLength:
                    ChangeCycle(Cycle.Night);
                    timer = 0f;
                    break;
                case Cycle.Night when timer >= nightLength:
                    ChangeCycle(Cycle.Day);
                    timer = 0f;
                    break;
                default:
                    return;
            }
        }

        private void ChangeCycle(Cycle cycle)
        {
            currentCycle = cycle;

            switch (currentCycle)
            {
                case Cycle.Day:
                    WaveManager.Instance.EndWave(CombatManager.Instance.KillCount, CombatManager.Instance.KillCount);
                    CombatManager.Instance.ResetCount();
                    break;
                case Cycle.Night:
                    WaveManager.Instance.StartWave();
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            OnCycled?.Invoke(cycle);
        }
    }
}