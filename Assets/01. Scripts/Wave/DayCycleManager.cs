using System;
using UnityEngine;

public class DayCycleManager : MonoSingleton<DayCycleManager>
{
    public enum Cycle
    {
        Day,
        Night
    }

    [SerializeField] public Cycle currentCycle = Cycle.Day;

    public Action<Cycle> OnCycled = cycle => { };

    public void ChangeCycle(Cycle cycle)
    {
        currentCycle = cycle;

        switch (currentCycle)
        {
            case Cycle.Day:
                WaveManager.Instance.StartWave(false);
                break;
            case Cycle.Night:
                WaveManager.Instance.StartWave(true);
                break;
            default:
                throw new ArgumentOutOfRangeException();
        }

        OnCycled?.Invoke(cycle);
    }
}