using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Weapon : ScriptableObject
{
    public int weapon_id;
    public string weapon_name;
    public Bullet bullet;
    public float reloadingTime = 1f;
    public string ammoText => $"{bullet.ammo}/{bullet.MaxAmmo}";
    
}
