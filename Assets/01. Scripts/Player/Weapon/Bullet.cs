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
    public int ammo;
    
    public int haveAmmo
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

    public bool CheckReloaing
    {
        get
        {
            if(ammo != maxAmmo && haveAmmo > 0)
            {
                if(haveAmmo < maxAmmo)
                {
                    return true;
                }
                int addAmmo = maxAmmo - ammo;
                return addAmmo <= haveAmmo;
            }
            return false;
        }
    }

    public void AmmoReload()
    {
        int addAmmo = maxAmmo - ammo;
        if (haveAmmo < maxAmmo)
        {
            addAmmo = haveAmmo;
        }
        ammo += addAmmo;
        haveAmmo -= addAmmo;
    }
}
