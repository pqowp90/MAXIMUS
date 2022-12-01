using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[Serializable]
public class Bullet
{
    public string bullet_name;

    public int haveAmmo;

    private int _maxAmmo;

    public int MaxAmmo
    {
        get => _maxAmmo;
        set
        {
            _maxAmmo = value;
            ammo = value;
        }
    }
    public int ammo;

    public bool CheckReloaing
    {
        get
        {
            if(ammo != MaxAmmo)
            {
                int addAmmo = MaxAmmo - ammo;
                return addAmmo <= haveAmmo;
            }
            return false;
        }
    }

    public void Reloading()
    {
        int addAmmo = MaxAmmo - ammo;
        ammo += addAmmo;
        haveAmmo -= addAmmo;
    }
}
