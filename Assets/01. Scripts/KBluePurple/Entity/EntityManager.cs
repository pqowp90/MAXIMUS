using System.Collections.Generic;
using UnityEngine;

public class EntityManager : MonoSingleton<EntityManager>
{
    [SerializeField] private List<Entity> entities = new();
    public IReadOnlyList<Entity> Entities => entities;

    public void RegisterEntity(Entity entity)
    {
        if (entities.Contains(entity)) return;
        entities.Add(entity);
        Debug.Log($"Registered entity {entity.name}");
    }

    public void UnregisterEntity(Entity entity)
    {
        if (!entities.Contains(entity)) return;
        entities.Remove(entity);
        Debug.Log($"Unregistered entity {entity.name}");
    }
}