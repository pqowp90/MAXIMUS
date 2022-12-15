using UnityEngine;
using System.Collections.Generic;
using System;
using System.Collections;

[CreateAssetMenu(fileName = "EnemyData", menuName = "KBluePurple/Data/EnemyData")]
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