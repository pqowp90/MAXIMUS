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
    public float damage;
    public int maxAmmo;

    [Header("자동설정값")]
    public int haveAmmo;
    public int ammo;

    [Header("총알 프리팹")]
    public GameObject prefab;

    [HideInInspector]
    public Item bulletItem;

    public bool CheckReloaing
    {
        get
        {
            if(ammo != maxAmmo)
            {
                int addAmmo = maxAmmo - ammo;
                return addAmmo <= haveAmmo;
            }
            return false;
        }
    }

    public void AmmoReload()
    {
        int addAmmo = maxAmmo - ammo;
        ammo += addAmmo;
        haveAmmo -= addAmmo;
        bulletItem.amount -= addAmmo;
    }
}
