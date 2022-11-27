using System.Collections.Generic;
using UnityEngine;

namespace KBluePurple.Wave
{
    [CreateAssetMenu(fileName = "EnemyDataContainer", menuName = "KBluePurple/Data/EnemyDataContainer", order = 0)]
    public class EnemyDataContainer : ScriptableSingleton<EnemyDataContainer>
    {
        public EnemyData[] enemyData;

        private Dictionary<int, EnemyData> _cache;
        public Dictionary<int, EnemyData> Cache => _cache ?? CacheEnemyData();

        private Dictionary<int, EnemyData> CacheEnemyData()
        {
            _cache = new Dictionary<int, EnemyData>();

            foreach (var data in enemyData) _cache[data.type] = data;

            return _cache;
        }
    }
}