using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BulletObj : MonoBehaviour, IPoolable
{
    public Bullet bullet;
    public Rigidbody rigidbody;

    public void OnPool()
    {
        GetComponent<ECExplodingProjectile>().damage = bullet.damage;
        rigidbody = GetComponent<Rigidbody>();
    }
}
