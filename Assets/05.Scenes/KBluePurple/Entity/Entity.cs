using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;

namespace KBluePurple.Wave
{
    public class Entity : MonoBehaviour, IEntity
    {
        public Collider2D Collider { get; private set; }

        private void Awake()
        {
            Collider = GetComponent<Collider2D>();
            SceneManager.sceneUnloaded += OnSceneUnloaded;
            SceneManager.sceneLoaded += OnSceneLoaded;
        }

        private void OnSceneLoaded(Scene prev, LoadSceneMode scene)
        {
            OnEnable();
        }

        private void OnSceneUnloaded(Scene scene)
        {
            OnDisable();
        }

        private void OnEnable()
        {
            if (EntityManager.IsInitialized)
                EntityManager.Instance.RegisterEntity(this);
        }

        private void OnDisable()
        {
            if (EntityManager.IsInitialized)
                EntityManager.Instance.UnregisterEntity(this);
        }

        [field: SerializeField] public EntityType Type { get; set; }
    }

    public interface IDamageable : IHealth
    {
        public UnityEvent<float> OnDamageTaken { get; set; }
        public void TakeDamage(float damage);
    }

    public interface IHealth
    {
        public float Health { get; set; }
    }
}