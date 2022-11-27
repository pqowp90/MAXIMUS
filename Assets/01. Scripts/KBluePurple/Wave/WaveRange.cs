using UnityEngine;

namespace KBluePurple.Wave
{
    public class WaveRange
    {
        public Vector2 position;
        public Vector2 size;

        public WaveRange()
        {
            position = Vector2.zero;
            size = Vector2.zero;
        }

        public WaveRange(Vector2 position, Vector2 size)
        {
            this.position = position;
            this.size = size;
        }
    }
}