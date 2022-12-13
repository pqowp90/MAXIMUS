using System;
using UnityEngine;

public class DayCycleManager : MonoSingleton<DayCycleManager>
{
    public enum Cycle
    {
        Day,
        Night
    }

    [SerializeField] private bool isCycling = true;
    [SerializeField] public Cycle currentCycle = Cycle.Day;

    public Action<Cycle> OnCycled = cycle => { };

    public void ChangeCycle(Cycle cycle)
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