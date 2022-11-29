using UnityEngine;

public class EnemySpawnArgs
{
    public IEnemy Enemy;
    public Vector3 Position;

    public EnemySpawnArgs(IEnemy Enemy, Vector3 Position) { this.Enemy = Enemy; this.Position = Position; }
}

public class WaveStartArgs
{
    public WaveStartArgs(int Index, bool IsBloodMoon) { }
}

public class WaveEndArgs
{
    public WaveEndArgs(int Index, bool IsBloodMoon, int TotalKills, int TotalDamage, float TotalTime) { }
}