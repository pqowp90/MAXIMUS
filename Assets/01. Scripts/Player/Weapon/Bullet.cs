using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[Serializable]
public class Bullet
{
    [Header("설정값")]
    public string bullet_name;
    public float attackDelay;
    public int minDamage;
    public int maxDamage;

    public int Damage => UnityEngine.Random.Range(minDamage, maxDamage + 1);
    
    public int Ammo
    {
        get
        {
            if (bulletItem == null) return 0;
            return bulletItem.amount;
        }
        set
        {
            bulletItem.amount = value;
        }
    }

    [HideInInspector]
    public Item bulletItem;
}
