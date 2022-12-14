using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;

public class PlayerAttack : MonoBehaviour
{
    [SerializeField]
    private List<Transform> _turrats = new List<Transform>();
    [SerializeField]
    private float _radius;
    [SerializeField]
    private LayerMask _layer;

    public Weapon weapon => WeaponManager.Instance.weapon;

    private bool _isAttackDelay = false;
    public bool AttackPossible => _isAttackDelay;

    private Vector3 _direction;

    public void Attack()
    {
        Collider[] _targets = Physics.OverlapSphere(transform.position, _radius, _layer);
        if (_targets.Length > 0)
        {
            Transform _target = _targets[0].transform;
            foreach (var target in _targets)
            {
                if (Vector3.Distance(transform.position, target.transform.position) < Vector3.Distance(transform.position, _target.transform.position))
                {
                    _target = target.transform;
                }
            }

            _turrats[0].LookAt(new Vector3(_target.position.x, _target.position.y + 0.5f, _target.position.z));
            _turrats[1].LookAt(new Vector3(_target.position.x, _target.position.y + 0.5f, _target.position.z));
        }
        else
        {
            _turrats[0].forward = transform.forward;
            _turrats[1].forward = transform.forward;
        }

        weapon.bullet.ammo -= 2;
        int amount = 2;

        if (weapon.bullet.ammo < 0)
        {
            amount--;
            weapon.bullet.ammo = 0;
        }

        TurratShoot(amount);
    }

    private void TurratShoot(int amount)
    {
        for(int i = 0; i < amount; i++)
        {
            Transform _turrat = _turrats[i];

            var bullet = PoolManager.GetItem<BulletObj>($"Bullet_{weapon.bullet.bullet_name}");
            bullet.transform.position = _turrat.Find("ShootPos").transform.position;
            bullet.transform.rotation = _turrat.rotation;
            bullet.projectile.damage = weapon.bullet.damage;
            bullet.rigidbody.velocity = Vector3.zero;
            bullet.rigidbody.AddForce(_turrat.forward * 1000);
        }
        
        _isAttackDelay = true;
        Invoke("AttackDelay", weapon.bullet.attackDelay);
    }

    private void AttackDelay()
    {
        _isAttackDelay = false;
    }
}