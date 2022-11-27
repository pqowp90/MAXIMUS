using UnityEngine;

namespace KBluePurple.Wave
{
    public record EnemySpawnArgs(IEnemy Enemy, Vector2 Position);

    public record WaveStartArgs(int Index, bool IsBloodMoon);

    public record WaveEndArgs(int Index, bool IsBloodMoon, int TotalKills, int TotalDamage, float TotalTime);
}