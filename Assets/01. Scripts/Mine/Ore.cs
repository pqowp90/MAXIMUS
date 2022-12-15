using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Ore : MonoBehaviour, IDamageable, IPoolable
{
    public OreSO data;
    
    public int dropAmount => Random.Range(data.dropMinAmount, data.dropMaxAmount);

    public UnityEvent<float> OnDamageTaken { get; set; }

    private float _maxHealth;
    [SerializeField] private float _health;
    public float Health { get => _health; set => _health = value; }

    public float rate;

    private MeshRenderer _meshRenderer;
    private MeshCollider _meshColider;
    private MeshFilter _meshFilter;

    private void Awake() {
        _meshRenderer = GetComponent<MeshRenderer>();
        _meshColider = GetComponent<MeshCollider>();
        _meshFilter = GetComponent<MeshFilter>();
    }

    public void Init(OreSO _data, float _rate)
    {
        data = _data;
        _maxHealth = data.maxHealth;
        Health = data.maxHealth;
        rate = _rate;
    }

    public void ResourceInit(Mesh mesh, Material material)
    {
        _meshColider.sharedMesh = mesh;
        _meshRenderer.material = material;
        _meshFilter.mesh = mesh;
    }

    public void TakeDamage(float damage)
    {
        Health -= damage;
        if(Health == 0)
        {
            ItemManager.Instance.DropItem(transform.position, data.dropItem, dropAmount * 3);
            gameObject.SetActive(false);
        }
    }

    public void OnPool()
    {
        
    }
}
