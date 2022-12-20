using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyAnimation : MonoBehaviour
{
    private Enemy _enemy;

    private void Awake() {
        _enemy = transform.parent.GetComponent<Enemy>();
    }

    public void Attack()
    {
        _enemy.Attack();
    }
}
