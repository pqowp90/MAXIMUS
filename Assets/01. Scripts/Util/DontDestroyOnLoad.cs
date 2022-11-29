using System;
using UnityEngine;

public class DontDestroyOnLoadAttribute : Attribute
{
    public DontDestroyOnLoadAttribute()
    {
        var type = GetType();
        if (!type.IsSubclassOf(typeof(MonoBehaviour)))
            Debug.LogWarning(
                $"DontDestroyOnLoadAttribute can only be used on a MonoBehaviour. {type} is not a MonoBehaviour.");
    }
}