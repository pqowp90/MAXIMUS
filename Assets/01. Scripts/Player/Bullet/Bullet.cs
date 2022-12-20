using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[CreateAssetMenu(fileName = "New Bullet", menuName = "Inventory/Items/Bullet")]
public class Bullet : ScriptableObject
{
    [Header("탄환 아이템")]
    public Item bulletItem;

    [Header("공격설정")]
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

    [Header("총구 발사 이펙트")]
    public GameObject muzzlePrefab;
}
