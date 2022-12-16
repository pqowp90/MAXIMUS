using UnityEngine;
using System.Collections.Generic;
using System;
using System.Collections;

[System.Serializable]
[CreateAssetMenu(fileName = "EnemyData", menuName = "Wave/Enemy")]
public class EnemyData : ScriptableObject
{
    public int type;
    public GameObject prefab;
    public float health;
    public float speed;

    [Header("Attack")]
    public float damage;
    public float attackDelay;
    public float attackRange;

    public DropItemTableSO dropItemTable;
}