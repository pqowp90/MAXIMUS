using KBluePurple.Wave;
using UnityEngine;

namespace KBluePurple
{
    public static class FormulaFunction
    {
        private static int WaveCount => WaveManager.Instance.WaveCount;

        public static int EnemyCount()
        {
            // return WaveCount * 2;
            return 10;
        }

        public static bool IsBloodMoon()
        {
            return false;
        }

        public static float EnemyRatio(int type)
        {
            float EliteEnemy()
            {
                return 0.1f;
            }

            return type switch
            {
                0 => 0f,
                1 => EliteEnemy(),
                _ => 0f
            };
        }

        public static int DirectionCount()
        {
            return Random.Range(1, 3);
        }

        public static float DropChestChance(IEnemy enemy)
        {
            var enemyType = enemy.EnemyType;

            return enemyType switch
            {
                0 => 0.1f,
                1 => 0.2f,
                _ => 0f
            };
        }
    }
}