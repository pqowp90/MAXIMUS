using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;
using DG.Tweening;

public class PlayerAttack : MonoBehaviour
{
    [SerializeField] private List<Transform> _turrats = new List<Transform>();
    [SerializeField] private float _radius;
    [SerializeField] private LayerMask _layer;

    public Bullet bullet => BulletManager.Instance.currentBullet;

    private bool _isAttackDelay = false;
    public bool AttackPossible => _isAttackDelay;

    private Vector3 _direction;

    [Header("Sound")]
    [SerializeField] private AudioClip _bulletShoot;

    private void Start() {
        PoolManager.CreatePool<PoolingEffect>("BulletShell", ItemManager.Instance.poolObj, 10);
    }

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

            _turrats[0].LookAt(new Vector3(_target.position.x, _target.position.y + Random.Range(1.0f, 3.0f), _target.position.z));
            _turrats[1].LookAt(new Vector3(_target.position.x, _target.position.y + Random.Range(1.0f, 3.0f), _target.position.z));
        }
        else
        {
            _turrats[0].forward = transform.forward;
            _turrats[1].forward = transform.forward;
        }

        TurratShoot(bullet.Ammo == 1 ? 1 : 2);
    }

    private void TurratShoot(int amount)
    {
        for(int i = 0; i < amount; i++)
        {
            Transform _turrat = _turrats[i];
            bullet.Ammo--;

            var _bullet = PoolManager.GetItem<BulletObj>($"Bullet_{bullet.bulletItem.item_name}");
            _bullet.transform.position = _turrat.Find("ShootPos").transform.position;
            _bullet.transform.rotation = _turrat.rotation;
            _bullet.projectile.damage = bullet.Damage;
            _bullet.rigidbody.velocity = Vector3.zero;
            _bullet.rigidbody.AddForce(_turrat.forward * 7000);

            var shell = PoolManager.GetItem<PoolingEffect>("BulletShell");
            shell.transform.position = _turrat.Find("ShellPos").transform.position;

            var muzzle = Instantiate(BulletManager.Instance.currentBullet.muzzlePrefab);
            muzzle.transform.parent = _turrat.Find("ShootPos");
            muzzle.transform.position = _turrat.Find("ShootPos").position;
            muzzle.transform.rotation = _turrat.rotation;

            SoundManager.Instance.PlayClip(_bulletShoot);
        }
        
        _isAttackDelay = true;
        UIManager.Instance.SlotAmountReload();
        Invoke("AttackDelay", bullet.attackDelay);
    }

    private void AttackDelay()
    {
        _isAttackDelay = false;
    }
}
