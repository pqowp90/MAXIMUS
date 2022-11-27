using UnityEngine;

namespace KBluePurple.Wave
{
    [CreateAssetMenu(fileName = "EnemyData", menuName = "KBluePurple/Data/EnemyData")]
    public class EnemyData : ScriptableObject
    {
        public int type;
        public Sprite sprite;
        public float health;
        public float speed;
        public float damage;
    }
}