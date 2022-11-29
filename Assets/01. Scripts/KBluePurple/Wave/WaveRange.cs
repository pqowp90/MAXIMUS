using UnityEngine;
public class WaveRange
{
    public Vector3 position;
    public Vector3 size;

    public WaveRange()
    {
        position = Vector3.zero;
        size = Vector3.zero;
    }

    public WaveRange(Vector3 position, Vector3 size)
    {
        this.position = position;
        this.size = size;
    }
}