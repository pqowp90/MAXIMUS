using UnityEngine;
using System.Collections.Generic;
using System;
using System.Collections;

[CreateAssetMenu(fileName = "EnemyData", menuName = "KBluePurple/Data/EnemyData")]
public class EnemyData : ScriptableObject
{
    public int type;
    public Material meterial;
    public float health;
    public float speed;
    public float damage;

    public DropItemTableSO dropItemTable;
}