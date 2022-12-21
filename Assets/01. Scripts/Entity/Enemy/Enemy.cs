using System.Linq;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;

public sealed class Enemy : Entity, IEnemy, IDamageable, IPoolable
{

    [Header("Target")]
    [SerializeField] private Vector3 targetPosition = Vector3.zero;     // 타켓의 좌표
    [SerializeField] private Entity target;                             // 타켓

    #region 공격 관련 정보
    [field: SerializeField] public float Health { get; set; }
    [field: SerializeField] public EnemyData Data { get; set; }
    [field: SerializeField] public UnityEvent<float> OnDamageTaken { get; set; }
    #endregion

    private Animator _animator;
    private Rigidbody _rigidbody;
    private Transform _transform;
    private HPBar _hpBar;

    private void Awake()
    {
        Type = EntityType.Enemy;
        _rigidbody = GetComponent<Rigidbody>();
        _animator = GetComponentInChildren<Animator>();
        _hpBar = GetComponentInChildren<HPBar>();
        _transform = transform;
    }

    private void Update()
    {
        FindTarget();
        Move();
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.gray;
        Gizmos.DrawLine(transform.position, targetPosition);
    }

    public int EnemyType { get; private set; }

    public void Init(EnemyData data, bool health = false)
    {
        Data = data;
        EnemyType = Data.type;
        Health = Data.health;
        if(health) _hpBar.Init(Health);
    }

    private void FindTarget()
    {
        var closeDistance = Mathf.Infinity;

        foreach (var entity in EntityManager.Instance.Entities)
        {
            if (entity.Type != EntityType.Player && entity.Type != EntityType.Structure) continue;
            var closestDistance = Vector3.Distance(entity.transform.position, transform.position);

            if (!(closestDistance < closeDistance)) continue;
            closeDistance = closestDistance;
            target = entity;
        }

        if (target == null) return;
        targetPosition = target!.Collider.ClosestPoint(_transform.position);
    }

    private void Move()
    {
        transform.LookAt(target.transform);
        transform.rotation = Quaternion.Euler(0, transform.eulerAngles.y, 0);

        if (target == null) FindTarget();

        float length = Vector3.Distance(transform.position, targetPosition);

        if(length <= Data.attackRange)
        {
            _animator.SetBool("Attack", true);
        }
        else
        {
            transform.position = Vector3.MoveTowards(transform.position, targetPosition, Data.speed * Time.deltaTime);
            _animator.SetBool("Attack", false);
        }
            
    }

    public void TakeDamage(float damage)
    {
        float dmg = damage;
        if(Health - dmg < 0) // 10 - 13 < 0
        {
            dmg += Health - dmg;
        }

        Health -= dmg;
        OnDamageTaken?.Invoke(dmg);
        UIManager.Instance.Popup(transform, dmg.ToString());
        _hpBar.Value -= dmg;

        if (_hpBar.Value <= 0)
        {
            Death();
        }
    }

    private void Death()
    {
        EnemyManager.Instance.DeathEnemy(this);
    }

    public void Attack()
    {
        if(_animator.GetBool("Attack") == true)
            target.GetComponent<Player>().TakeDamage(Data.damage);
    }

    public void OnPool()
    {
        targetPosition = WaveManager.Instance.transform.position;
        _hpBar.Init(Health);
    }
}
