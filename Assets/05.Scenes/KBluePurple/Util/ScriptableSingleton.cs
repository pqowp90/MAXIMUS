﻿using System.Linq;
using UnityEngine;

namespace KBluePurple.Wave
{
    public class ScriptableSingleton<T> : ScriptableObject where T : ScriptableObject
    {
        private static T _instance;

        public static T Instance
        {
            get
            {
                if (_instance != null) return _instance;

                var assets = Resources.LoadAll<T>("");

                switch (assets.Length)
                {
                    case 0:
                        Debug.LogError($"No {typeof(T).Name} found in Resources folder");
                        return null;
                    case > 1:
                        Debug.LogError($"Multiple {typeof(T).Name} found in Resources folder");
                        return null;
                    default:
                        _instance = assets.First();
                        return _instance;
                }
            }
        }
    }
}