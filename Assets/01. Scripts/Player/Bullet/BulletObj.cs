using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BulletObj : MonoBehaviour, IPoolable
{
    public Rigidbody _rigidbody;
    public ECExplodingProjectile projectile;

    public void OnPool()
    {
        _rigidbody = GetComponent<Rigidbody>();
        projectile = GetComponent<ECExplodingProjectile>();
    }
}
