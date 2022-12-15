using System.Linq;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;

public sealed class Enemy : Entity, IEnemy, IDamageable, IPoolable
{
    [field: SerializeField] public UnityEvent<float> OnDamageTaken { get; set; }

    public LayerMask enemyLayerMask;
    [SerializeField] private float distance;
    [SerializeField] private float maxDistance;

    [SerializeField] private Vector3 targetPosition = Vector3.zero;
    [SerializeField] private Entity target;

    [SerializeField] private EntityType targetEnemyTypes;

    [field: SerializeField] public float Health { get; set; }

    private Rigidbody _rigidbody;

    private Transform _transform;

    [field: SerializeField] public EnemyData Data { get; set; }

    private bool _isDelay = false;

    private Animator _animator;
    

    private void Awake()
    {
        Type = EntityType.Enemy;
        _rigidbody = GetComponent<Rigidbody>();
        _animator = GetComponentInChildren<Animator>();
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

    public void Init(IEnemy enemy)
    {
        Data = EnemyDataContainer.Instance.Cache[enemy.EnemyType];
        EnemyType = Data.type;
        Health = Data.health;
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
            Attack();
        }
        else if (length >= maxDistance)
        {
            transform.position = Vector3.MoveTowards(transform.position, targetPosition, Data.speed * Time.deltaTime);
            _animator.SetBool("Attack", false);
        }
            
    }

    public void AddTarget(EntityType type)
    {
        targetEnemyTypes |= type;
    }

    public void RemoveTarget(EntityType type)
    {
        targetEnemyTypes &= ~type;
    }

    public void SetTarget(EntityType type)
    {
        targetEnemyTypes = type;
    }

    public void TakeDamage(float damage)
    {
        Health -= damage;
        OnDamageTaken?.Invoke(damage);
        UIManager.Instance.Popup(transform, damage.ToString());

        if (Health <= 0)
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
        if(!_isDelay)
        {
            _isDelay = true;
            Invoke("AttackDelay", Data.attackDelay);
        }
    }

    private void AttackDelay()
    {
        _isDelay = false;
        if(_animator.GetBool("Attack") == true)
            target.GetComponent<Player>().TakeDamage(Data.damage);
    }

    public void OnPool()
    {
        targetPosition = WaveManager.Instance.transform.position;
        maxDistance = distance;
    }
}
