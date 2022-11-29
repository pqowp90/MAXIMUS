using System.Linq;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;

public sealed class Enemy : Entity, IEnemy, IDamageable
{
    [field: SerializeField] public UnityEvent<float> OnDamageTaken { get; set; }

    public LayerMask enemyLayerMask;
    [SerializeField] private float distance;
    [SerializeField] private float maxDistance;

    [SerializeField] private Vector3 targetPosition = Vector3.zero;
    [SerializeField] private Entity target;

    [SerializeField] private EntityType targetEnemyTypes;

    [field: SerializeField] public float Health { get; set; }

    private MeshRenderer _meshRenderer;
    private Rigidbody _rigidbody;

    private Transform _transform;

    [field: SerializeField] public EnemyData Data { get; set; }

    private void Awake()
    {
        Type = EntityType.Enemy;
        _meshRenderer = GetComponent<MeshRenderer>();
        _rigidbody = GetComponent<Rigidbody>();
        _transform = transform;
    }

    private void Start()
    {
        targetPosition = WaveManager.Instance.transform.position;
        maxDistance = distance;
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
        _meshRenderer.material = Data.meterial;
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
        if (target == null) FindTarget();

        if (Vector3.Distance(transform.position, targetPosition) >= maxDistance)
            transform.position =
                Vector3.MoveTowards(transform.position, targetPosition, Data.speed * Time.deltaTime);
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

        if (Health <= 0)
        {
            Death();
        }
    }

    private void Death()
    {
        EnemyManager.Instance.DeathEnemy(this);
    }
}
