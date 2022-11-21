using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Building : MonoBehaviour, IPoolable
{
    
    public List<Vector2Int> range = new List<Vector2Int>();
    public void OnPool()
    {
        
    }
}
