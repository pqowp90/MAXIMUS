using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BulletObj : MonoBehaviour, IPoolable
{
    public Rigidbody rigidbody;
    public ECExplodingProjectile projectile;

    public void OnPool()
    {
        rigidbody = GetComponent<Rigidbody>();
        projectile = GetComponent<ECExplodingProjectile>();
    }
}
