using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;
using DG.Tweening;

public class PlayerAttack : MonoBehaviour
{
    [SerializeField] public List<Transform> turrets = new List<Transform>();
    [SerializeField] private float _radius;
    [SerializeField] private LayerMask _layer;

    public Bullet bullet => BulletManager.Instance.currentBullet;

    private bool _isAttackDelay = false;
    public bool AttackPossible => _isAttackDelay;

    private bool _shoulderHold = false;
    public bool Shoulder => _shoulderHold;

    private Vector3 _direction;

    [Header("Animation")]
    [SerializeField] private Animator _turret1Animatior;
    [SerializeField] private Animator _turret2Animatior;

    [Header("Sound")]
    [SerializeField] private AudioClip _bulletShoot;

    private void Start() 
    {
        PoolManager.CreatePool<PoolingEffect>("BulletShell", ItemManager.Instance.poolObj, 10);
    }

    public void Attack()
    {
        if(Shoulder == false)
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

                turrets[0].LookAt(new Vector3(_target.position.x, _target.position.y + Random.Range(1.0f, 3.0f), _target.position.z));
                turrets[1].LookAt(new Vector3(_target.position.x, _target.position.y + Random.Range(1.0f, 3.0f), _target.position.z));
            }
            else
            {
                turrets[0].forward = transform.forward;
                turrets[1].forward = transform.forward;
            }
        }
        
        TurratShoot(bullet.Ammo == 1 ? 1 : 2);
    }

    private void TurratShoot(int amount)
    {
        for(int i = 0; i < amount; i++)
        {
            Transform _turrat = turrets[i];
            bullet.Ammo--;

            var _bullet = PoolManager.GetItem<BulletObj>($"Bullet_{bullet.bulletItem.item_name}");
            _bullet.transform.position = _turrat.Find("ShootPos").transform.position;
            _bullet.transform.rotation = _turrat.rotation;
            _bullet.projectile.damage = bullet.Damage;
            _bullet.GetComponent<Rigidbody>().velocity = Vector3.zero;
            _bullet.GetComponent<Rigidbody>().AddForce(_turrat.forward * 7000);

            var shell = PoolManager.GetItem<PoolingEffect>("BulletShell");
            shell.transform.position = _turrat.Find("ShellPos").transform.position;

            var muzzle = Instantiate(BulletManager.Instance.currentBullet.muzzlePrefab);
            muzzle.transform.parent = _turrat.Find("ShootPos");
            muzzle.transform.position = _turrat.Find("ShootPos").position;
            muzzle.transform.rotation = _turrat.rotation;

            SoundManager.Instance.PlayClip(SoundType.EFFECT, _bulletShoot);
        }
        
        _isAttackDelay = true;
        UIManager.Instance.SlotAmountReload();

        _turret1Animatior.SetTrigger("Shoot");
        _turret2Animatior.SetTrigger("Shoot");

        Invoke("AttackDelay", bullet.attackDelay);
    }

    private void AttackDelay()
    {
        _isAttackDelay = false;
    }

    public void ShoulderHold(bool hold)
    {   
        _shoulderHold = hold;
        Camera.main.DOFieldOfView(hold ? 40 : 50, 0.2f);
    }
}